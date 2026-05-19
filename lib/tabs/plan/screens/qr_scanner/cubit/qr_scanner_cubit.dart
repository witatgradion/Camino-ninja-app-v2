import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/stage_plan_share_service.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';

part 'qr_scanner_state.dart';

enum QrScanSource { scan, gallery }

final _planPathRegex = RegExp(r'^/plan/([A-Za-z0-9]{1,32})$');

class QrScannerCubit extends Cubit<QrScannerState> with SafeEmitMixin {
  QrScannerCubit({required List<StagePlanModel> plans})
      : super(QrScannerState(plans: plans));

  IAnalyticsService get _analytics => GetIt.instance<IAnalyticsService>();

  /// In-flight guard for the camera permission request. Presenting the OS
  /// permission dialog backgrounds the app, which fires resume on dismiss
  /// and races [refreshCameraPermission] against the still-pending request.
  bool _isRequesting = false;

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

  Future<Map<String, dynamic>> _buildDecodeParams({
    required QrScanSource source,
    DecodeResult? decodeResult,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'source': source.name,
      'qr_version': decodeResult?.buildNumber.toString() ?? 'unknown',
      'qr_generated_os': decodeResult?.platform.name ?? 'unknown',
      'current_app_version': packageInfo.buildNumber,
    };
  }

  /// Reads the current camera permission status. When called for the first
  /// time and the OS reports [PermissionStatus.denied] (i.e. never asked),
  /// proactively requests permission so the system dialog appears as soon as
  /// the user opens the scanner — that's the natural expectation.
  Future<void> initCameraPermission() async {
    final current = await Permission.camera.status;
    AppLogger.d('initCameraPermission: status=$current', tag: 'QrScanner');
    if (current.isDenied) {
      // First-run path: trigger the OS dialog without an extra tap.
      _isRequesting = true;
      try {
        final requested = await Permission.camera.request();
        AppLogger.d(
          'initCameraPermission: request result=$requested',
          tag: 'QrScanner',
        );
        _emitPermission(requested);
      } finally {
        _isRequesting = false;
      }
      return;
    }
    _emitPermission(current);
  }

  /// Re-checks permission without prompting (e.g. on app resume after the
  /// user returns from Settings). No-op while a request is in flight to
  /// avoid racing the pending permission request future.
  Future<void> refreshCameraPermission() async {
    if (_isRequesting) return;
    final status = await Permission.camera.status;
    _emitPermission(status);
  }

  void _emitPermission(PermissionStatus status) {
    final ui = switch (status) {
      PermissionStatus.granted ||
      PermissionStatus.limited ||
      PermissionStatus.provisional =>
        CameraPermissionUiState.granted,
      PermissionStatus.denied ||
      PermissionStatus.permanentlyDenied ||
      PermissionStatus.restricted =>
        CameraPermissionUiState.permanentlyDenied,
    };
    safeEmit(state.copyWith(cameraPermission: ui));
  }

  void setOpeningGallery(bool value) {
    safeEmit(
      state.copyWith(isOpeningGallery: value),
    );
  }

  void setHasScanned(bool value) {
    safeEmit(
      state.copyWith(hasScanned: value),
    );
  }

  Future<void> decodeQrCode(String code, {required QrScanSource source}) async {
    if (state.isProcessing) return;
    safeEmit(
      state.copyWith(
        actionStatus: QrScannerActionStatus.decoding,
        hasScanned: true,
      ),
    );

    DecodeResult? decodeResult;

    try {
      final shortCode = _extractPlanShortCode(code);
      final plans = shortCode != null
          ? await _decodeDeepLinkPlan(shortCode)
          : await _decodeLocalQr(code).then((value) {
              decodeResult = value.$1;
              return value.$2;
            });

      if (plans.isEmpty) {
        safeEmit(
          state.copyWith(
            actionStatus: QrScannerActionStatus.decodeError,
            hasScanned: false,
          ),
        );

        final decodeParams = await _buildDecodeParams(
          source: source,
          decodeResult: decodeResult,
        );
        final params = _buildCommonParams([]);
        _analytics.track(
          QrDecodeFailedEvent(
            planCount: params['plan_count'] as int,
            totalStages:
                params['total_stages'] as int,
            routeIds: params['route_ids'] as List<int>,
            routeNames:
                params['route_names'] as List<String>,
            planNames:
                params['plan_names'] as List<String>,
            source: decodeParams['source'] as String,
            qrVersion:
                decodeParams['qr_version'] as String,
            qrGeneratedOs:
                decodeParams['qr_generated_os']
                    as String,
            currentAppVersion:
                decodeParams['current_app_version']
                    as String,
            isDeepLink: shortCode != null,
            errorMessage: 'No valid plans found',
          ),
        );
        return;
      }

      safeEmit(
        state.copyWith(
          decodedPlans: plans,
          actionStatus: QrScannerActionStatus.idle,
        ),
      );

      final decodeParams = await _buildDecodeParams(
        source: source,
        decodeResult: decodeResult,
      );
      final successParams = _buildCommonParams(plans);
      _analytics.track(
        QrDecodedEvent(
          planCount:
              successParams['plan_count'] as int,
          totalStages:
              successParams['total_stages'] as int,
          routeIds:
              successParams['route_ids'] as List<int>,
          routeNames:
              successParams['route_names'] as List<String>,
          planNames:
              successParams['plan_names'] as List<String>,
          source: decodeParams['source'] as String,
          qrVersion:
              decodeParams['qr_version'] as String,
          qrGeneratedOs:
              decodeParams['qr_generated_os']
                  as String,
          currentAppVersion:
              decodeParams['current_app_version']
                  as String,
          isDeepLink: shortCode != null,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          actionStatus: QrScannerActionStatus.decodeError,
          hasScanned: false,
        ),
      );

      final decodeParams = await _buildDecodeParams(
        source: source,
        decodeResult: decodeResult,
      );
      final catchParams = _buildCommonParams([]);
      _analytics.track(
        QrDecodeFailedEvent(
          planCount:
              catchParams['plan_count'] as int,
          totalStages:
              catchParams['total_stages'] as int,
          routeIds:
              catchParams['route_ids'] as List<int>,
          routeNames:
              catchParams['route_names'] as List<String>,
          planNames:
              catchParams['plan_names'] as List<String>,
          source: decodeParams['source'] as String,
          qrVersion:
              decodeParams['qr_version'] as String,
          qrGeneratedOs:
              decodeParams['qr_generated_os']
                  as String,
          currentAppVersion:
              decodeParams['current_app_version']
                  as String,
          isDeepLink:
              _extractPlanShortCode(code) != null,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  String? _extractPlanShortCode(String code) {
    final uri = Uri.tryParse(code);
    if (uri == null) return null;
    final match = _planPathRegex.firstMatch(uri.path);
    if (match == null) return null;
    return match.group(1);
  }

  Future<(DecodeResult, List<StagePlanModel>)> _decodeLocalQr(String code) async {
    final service = GetIt.instance.get<StagePlanShareService>();
    final decodeResult = await service.decodePlan(code);
    final plans = await service.getPlans(decodeResult.plans);
    return (decodeResult, plans);
  }

  Future<List<StagePlanModel>> _decodeDeepLinkPlan(String shortCode) async {
    final stagePlanRepo = GetIt.instance<StagePlanRepository>();
    final shareService = GetIt.instance<StagePlanShareService>();
    final result = await stagePlanRepo.getSharedPlan(shortCode);
    if (result is! ApiSuccess<SharedPlanResponse>) {
      return const [];
    }
    final sharedPlan = await shareService.getSharedPlanFromResponse(result.data);
    return [sharedPlan];
  }

  Future<void> importPlans(List<StagePlanModel> selectedPlans) async {
    if (state.isProcessing) return;
    safeEmit(state.copyWith(actionStatus: QrScannerActionStatus.importing));

    try {
      final service = GetIt.instance.get<StagePlanShareService>();
      final result = await service.importPlans(selectedPlans);

      if (result.stagePlanIds.isEmpty) {
        safeEmit(
          state.copyWith(
            actionStatus: QrScannerActionStatus.importError,
            hasScanned: false,
          ),
        );

        final failParams =
            _buildCommonParams(selectedPlans);
        _analytics.track(
          PlanImportFailedEvent(
            planCount: failParams['plan_count'] as int,
            totalStages:
                failParams['total_stages'] as int,
            routeIds:
                failParams['route_ids'] as List<int>,
            routeNames:
                failParams['route_names'] as List<String>,
            planNames:
                failParams['plan_names'] as List<String>,
            errorMessage:
                'No plans could be imported',
          ),
        );
        return;
      }

      safeEmit(
        state.copyWith(
          actionStatus: QrScannerActionStatus.importSuccess,
          importedPlanId: result.stagePlanIds.first,
        ),
      );

      final successParams =
          _buildCommonParams(selectedPlans);
      _analytics.track(
        PlanImportSuccessEvent(
          planCount:
              successParams['plan_count'] as int,
          totalStages:
              successParams['total_stages'] as int,
          routeIds:
              successParams['route_ids'] as List<int>,
          routeNames:
              successParams['route_names'] as List<String>,
          planNames:
              successParams['plan_names'] as List<String>,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          actionStatus: QrScannerActionStatus.importError,
          hasScanned: false,
        ),
      );

      final errParams =
          _buildCommonParams(selectedPlans);
      _analytics.track(
        PlanImportFailedEvent(
          planCount:
              errParams['plan_count'] as int,
          totalStages:
              errParams['total_stages'] as int,
          routeIds:
              errParams['route_ids'] as List<int>,
          routeNames:
              errParams['route_names'] as List<String>,
          planNames:
              errParams['plan_names'] as List<String>,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void cancelSelection() {
    _analytics.track(
      QrImportCancelledEvent(
        planCount: state.decodedPlans?.length ?? 0,
      ),
    );
    safeEmit(
      state.copyWith(
        hasScanned: false,
        clearDecodedPlans: true,
      ),
    );
  }

  void resetActionStatus() {
    safeEmit(
      state.copyWith(
        actionStatus: QrScannerActionStatus.idle,
        clearDecodedPlans: true,
      ),
    );
  }
}
