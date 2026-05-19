import 'dart:io';
import 'dart:typed_data';

import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:gal/gal.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:share_plus/share_plus.dart';

part 'qr_export_state.dart';

class QrExportCubit extends Cubit<QrExportState> with SafeEmitMixin {
  QrExportCubit({
    required List<StagePlanModel> plans,
  }) : super(QrExportState(plans: plans));

  IAnalyticsService get _analytics => GetIt.instance<IAnalyticsService>();
  StagePlanRepository get _stagePlanRepo =>
      GetIt.instance<StagePlanRepository>();

  Map<String, dynamic> _buildCommonParams(List<StagePlanModel> plans) {
    final routeIds = plans.map((p) => p.route.id).toList();
    final routeNames = plans.map((p) => p.route.routeName).toList();
    final planNames = plans.map((p) => p.name ?? '').toList();
    final totalStages = plans.fold<int>(0, (sum, p) => sum + p.stages.length);

    return {
      'plan_count': plans.length,
      'total_stages': totalStages,
      'route_ids': routeIds,
      'route_names': routeNames,
      'plan_names': planNames,
    };
  }

  Future<void> init() async {
    safeEmit(state.copyWith(initStatus: QrExportInitStatus.loading));
    await _syncPlans();
    await _generateQrCode();
  }

  Future<void> _syncPlans() async {
    try {
      if (state.plans.isEmpty) return;
      await _stagePlanRepo.syncPlans();

      final ids = state.plans.map((p) => p.id).toList();
      final refreshed = <StagePlanModel>[];
      for (final id in ids) {
        refreshed.add(await _stagePlanRepo.getStagePlanById(id));
      }
      safeEmit(state.copyWith(plans: refreshed));
    } catch (e, st) {
      AppLogger.e(
        'Failed to reload plans after sync for QR export',
        tag: 'QrExportCubit',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _generateQrCode() async {
    if (state.plans.isEmpty) {
      safeEmit(state.copyWith(
        errorMessage: 'No plans to share',
        initStatus: QrExportInitStatus.failure,
      ));
      return;
    }

    try {
      // Try deep link sharing if the plan has a UUID (synced)
      final plan = state.plans.first;
      if (plan.uuid != null && plan.uuid!.isNotEmpty) {
        final deepLinkQrData = await _tryShareViaDeepLink(plan.uuid!);
        if (deepLinkQrData != null) {
          safeEmit(state.copyWith(
            qrData: deepLinkQrData,
            isDeepLink: true,
            initStatus: QrExportInitStatus.success,
            clearError: true,
          ));

          final deepLinkParams = _buildCommonParams(state.plans);
          _analytics.track(
            QrDeepLinkGeneratedEvent(
              planCount: deepLinkParams['plan_count'] as int,
              totalStages: deepLinkParams['total_stages'] as int,
              routeIds: deepLinkParams['route_ids'] as List<int>,
              routeNames: deepLinkParams['route_names'] as List<String>,
              planNames: deepLinkParams['plan_names'] as List<String>,
            ),
          );
          return;
        }
      }

      // Fall back to Base45 encoding
      await _generateBase45QrCode();
    } catch (e) {
      safeEmit(state.copyWith(
        errorMessage: e.toString(),
        initStatus: QrExportInitStatus.failure,
      ));

      final failParams = _buildCommonParams(state.plans);
      _analytics.track(
        QrGenerateFailedEvent(
          planCount: failParams['plan_count'] as int,
          totalStages: failParams['total_stages'] as int,
          routeIds: failParams['route_ids'] as List<int>,
          routeNames: failParams['route_names'] as List<String>,
          planNames: failParams['plan_names'] as List<String>,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<String?> _tryShareViaDeepLink(String uuid) async {
    try {
      final result = await _stagePlanRepo.sharePlan(uuid);
      if (result is ApiSuccess<PlanShareLinkResponse>) {
        return result.data.shortUrl;
      }
      return null;
    } catch (e) {
      AppLogger.e(
        'Failed to generate deep link for plan sharing',
        tag: 'QrExportCubit',
        error: e,
      );
      return null;
    }
  }

  Future<void> _generateBase45QrCode() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;
      final platform = Platform.isAndroid ? QrPlatform.android : QrPlatform.ios;

      final planDataList = state.plans.map((plan) {
        final stages = plan.stages.where((stage) {
          final date = stage.date;
          final startCityId = stage.startCity?.id;
          final endCityId = stage.endCity?.id;

          return date != null && startCityId != null && endCityId != null;
        }).map((stage) {
          final date = stage.date!;
          final startCityId = stage.startCity!.id;
          final endCityId = stage.endCity!.id;

          return StageData(
            date: date,
            startCityId: startCityId,
            endCityId: endCityId,
            startAlbergueId: stage.startAlbergue?.id,
            endAlbergueId: stage.endAlbergue?.id,
          );
        }).toList();

        return StagePlanData(
          routeId: plan.route.id,
          stages: stages,
          name: plan.name,
        );
      }).toList();

      final qrData = StagePlanCodec.encodeMultiple(
        planDataList,
        buildNumber: buildNumber,
        platform: platform,
      );

      safeEmit(state.copyWith(
        qrData: qrData,
        initStatus: QrExportInitStatus.success,
        clearError: true,
      ));

      final params = _buildCommonParams(state.plans);
      _analytics.track(
        QrGeneratedEvent(
          planCount: params['plan_count'] as int,
          totalStages: params['total_stages'] as int,
          routeIds: params['route_ids'] as List<int>,
          routeNames: params['route_names'] as List<String>,
          planNames: params['plan_names'] as List<String>,
        ),
      );
    } on CodecException catch (e) {
      safeEmit(state.copyWith(
        errorMessage: e.message,
        initStatus: QrExportInitStatus.failure,
      ));

      final params = _buildCommonParams(state.plans);
      _analytics.track(
        QrGenerateFailedEvent(
          planCount: params['plan_count'] as int,
          totalStages: params['total_stages'] as int,
          routeIds: params['route_ids'] as List<int>,
          routeNames: params['route_names'] as List<String>,
          planNames: params['plan_names'] as List<String>,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(
        errorMessage: e.toString(),
        initStatus: QrExportInitStatus.failure,
      ));

      final params = _buildCommonParams(state.plans);
      _analytics.track(
        QrGenerateFailedEvent(
          planCount: params['plan_count'] as int,
          totalStages: params['total_stages'] as int,
          routeIds: params['route_ids'] as List<int>,
          routeNames: params['route_names'] as List<String>,
          planNames: params['plan_names'] as List<String>,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> saveToGallery(Uint8List imageBytes) async {
    if (state.isProcessing) return;
    safeEmit(state.copyWith(actionStatus: QrExportActionStatus.processing));

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          safeEmit(state.copyWith(actionStatus: QrExportActionStatus.error));
          return;
        }
      }

      // Save to temporary file first
      final filePath = await _saveToTempFile(imageBytes);
      if (filePath == null) {
        safeEmit(state.copyWith(actionStatus: QrExportActionStatus.error));
        return;
      }

      // Save to gallery using gal
      await Gal.putImage(filePath);

      // Clean up temporary file
      await File(filePath).delete();

      safeEmit(state.copyWith(actionStatus: QrExportActionStatus.saveSuccess));

      final params = _buildCommonParams(state.plans);
      _analytics.track(
        QrSaveToGalleryEvent(
          planCount: params['plan_count'] as int,
          totalStages: params['total_stages'] as int,
          routeIds: params['route_ids'] as List<int>,
          routeNames: params['route_names'] as List<String>,
          planNames: params['plan_names'] as List<String>,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(actionStatus: QrExportActionStatus.error));
    }
  }

  Future<void> shareQrCode(Uint8List imageBytes) async {
    if (state.isProcessing) return;
    safeEmit(state.copyWith(actionStatus: QrExportActionStatus.processing));

    try {
      // Clean up previous shared image if exists
      await cleanupSharedImage();

      // Save to temporary file
      final filePath = await _saveToTempFile(imageBytes);
      if (filePath == null) {
        safeEmit(state.copyWith(actionStatus: QrExportActionStatus.error));
        return;
      }

      // Track the file path for cleanup on dispose
      safeEmit(state.copyWith(sharedImagePath: filePath));

      // Build share message
      final planCount = state.plans.length;
      final planText = planCount > 1 ? 'plans' : 'plan';
      final routeNames =
          state.plans.map((p) => p.route.routeName).toSet().join(', ');
      final message = 'Check out my Camino $planText! 🚶‍♂️\n'
          'Route: $routeNames\n'
          'Scan this QR code with Camino Ninja app to import the $planText.';

      // Share image only - some apps (Slack) don't support text + file together
      // Use subject for apps that support it (email clients)
      // ignore: unawaited_futures - don't await share result as it's unreliable
      Share.shareXFiles(
        [XFile(filePath)],
        subject: message,
      );

      // Reset status immediately since share sheet completion is unreliable
      // when user selects an app that opens externally
      safeEmit(state.copyWith(actionStatus: QrExportActionStatus.shareSuccess));

      final params = _buildCommonParams(state.plans);
      _analytics.track(
        QrShareViaSheetEvent(
          planCount: params['plan_count'] as int,
          totalStages: params['total_stages'] as int,
          routeIds: params['route_ids'] as List<int>,
          routeNames: params['route_names'] as List<String>,
          planNames: params['plan_names'] as List<String>,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(actionStatus: QrExportActionStatus.error));
    }
  }

  Future<String?> _saveToTempFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'camino_ninja_qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  Future<void> cleanupSharedImage() async {
    final path = state.sharedImagePath;
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Ignore cleanup errors
      }
      safeEmit(state.copyWith(clearSharedImagePath: true));
    }
  }

  void resetActionStatus() {
    safeEmit(state.copyWith(actionStatus: QrExportActionStatus.idle));
  }

  // DEBUG: Set test QR data directly
  void setTestQrData(String qrData) {
    safeEmit(
      state.copyWith(
        qrData: qrData,
        initStatus: QrExportInitStatus.success,
        clearError: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _cleanupSharedImageSync();
    return super.close();
  }

  /// Synchronous cleanup for use in close() - doesn't emit state
  Future<void> _cleanupSharedImageSync() async {
    final path = state.sharedImagePath;
    if (path != null) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e, st) {
        AppLogger.e(
          'Failed to cleanup shared image',
          tag: 'QrExportCubit',
          error: e,
          stackTrace: st,
        );
      }
    }
  }
}
