import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/cubit/qr_export_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/widgets/capture_hidden_qrcode.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/widgets/qrcode_widget.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/model_extensions.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repository/repository.dart';

// Debug utilities - uncomment import to enable debug buttons
// import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/qr_capacity_debug.dart';

class QrExportScreenArguments {
  const QrExportScreenArguments({required this.plans});
  final List<StagePlanModel> plans;
}

class QrExportScreen extends StatelessWidget {
  const QrExportScreen({
    required this.plans,
    super.key,
  });

  final List<StagePlanModel> plans;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrExportCubit(plans: plans)..init(),
      child: const _QrExportView(),
    );
  }
}

class _QrExportView extends StatefulWidget {
  const _QrExportView();

  @override
  State<_QrExportView> createState() => _QrExportViewState();
}

class _QrExportViewState extends State<_QrExportView> {
  late TopNotificationController _topNotificationController;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _topNotificationController = TopNotificationController();
  }

  @override
  void dispose() {
    _topNotificationController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureQrCodeImage() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final widgetContext = _repaintKey.currentContext;
      if (widgetContext == null || !widgetContext.mounted) return null;

      final renderObject = widgetContext.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) return null;

      final image = await renderObject.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _onSaveQrCode() async {
    final cubit = context.read<QrExportCubit>();
    if (cubit.state.isProcessing) return;

    final imageBytes = await _captureQrCodeImage();
    if (imageBytes == null) {
      _topNotificationController.changeNotificationType(
        TopNotificationBarType.commonError,
      );
      return;
    }
    if (mounted) {
      await cubit.saveToGallery(imageBytes);
    }
  }

  Future<void> _onShareQrCode() async {
    final cubit = context.read<QrExportCubit>();
    if (cubit.state.isProcessing) return;

    final imageBytes = await _captureQrCodeImage();
    if (imageBytes == null) {
      _topNotificationController.changeNotificationType(
        TopNotificationBarType.commonError,
      );
      return;
    }
    if (mounted) {
      await cubit.shareQrCode(imageBytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrSize = MediaQuery.of(context).size.width / 390 * 190;

    return BlocListener<QrExportCubit, QrExportState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        switch (state.actionStatus) {
          case QrExportActionStatus.saveSuccess:
            _topNotificationController.changeNotificationType(
              TopNotificationBarType.saveQrCodeSuccess,
            );
            context.read<QrExportCubit>().resetActionStatus();
          case QrExportActionStatus.shareSuccess:
            context.read<QrExportCubit>().resetActionStatus();
          case QrExportActionStatus.error:
            _topNotificationController.changeNotificationType(
              TopNotificationBarType.commonError,
            );
            context.read<QrExportCubit>().resetActionStatus();
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: CaminoNinjaAppBar(
          title: AppLocalizations.of(context).sharePlan,
        ),
        body: BlocBuilder<QrExportCubit, QrExportState>(
          builder: (context, state) {
            if (state.initStatus == QrExportInitStatus.loading) {
              return const Center(child: LoadingWidget());
            }

            return Stack(
              children: [
                if (state.qrData != null) ...[
                  SingleChildScrollView(
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: CaptureHiddenQrcode(
                        qrData: state.qrData!,
                        plans: state.plans,
                      ),
                    ),
                  ),
                ],
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: context.isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        if (state.errorMessage != null) ...[
                          _buildError(context, state.errorMessage!),
                        ] else if (state.qrData != null) ...[
                          const SizedBox(height: 16),
                          QrcodeWidget(qrSize: qrSize, qrData: state.qrData!),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: qrSize + 24,
                            child: CustomButton(
                              text: AppLocalizations.of(context).saveQrCode,
                              onTap: _onSaveQrCode,
                              isLoading: state.isProcessing,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: qrSize + 24,
                            child: CustomOutlineButton(
                              text: AppLocalizations.of(context).share,
                              onTap: _onShareQrCode,
                              isLoading: state.isProcessing,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildPlansInfo(context, state.plans),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
                TopNotificationOverlay(
                  key: const ValueKey('qr_export_top_notification_overlay'),
                  controller: _topNotificationController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String errorMessage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),
        const Icon(
          Icons.error_outline,
          size: 64,
          color: Colors.red,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context).exportError,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
        ),
      ],
    );
  }

  Widget _buildPlansInfo(BuildContext context, List<StagePlanModel> plans) {
    if (plans.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: context.isDarkMode ? AppColors.gray800 : AppColors.gray200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RouteNameText(
                    routeName: plan.route.routeName,
                    routeSubName: plan.route.routeSubName ?? '',
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode
                              ? AppColors.primary80
                              : AppColors.primary40,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    plan.getPlanSubtitle(context, plan),
                    style: context.textTheme.bodySmall,
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => Container(
              height: 1,
              color: context.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : AppColors.gray800,
            ),
            itemCount: plans.length,
          ),
        ],
      ),
    );
  }
}
