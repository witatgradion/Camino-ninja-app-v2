import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_scanner/cubit/qr_scanner_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_scanner/select_import_plan_bottomsheet.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/corner_painter.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:repository/repository.dart';

class QrScannerScreenArguments {
  const QrScannerScreenArguments({required this.plans});

  final List<StagePlanModel> plans;
}

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({this.plans = const [], super.key});

  final List<StagePlanModel> plans;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrScannerCubit(plans: plans)..initCameraPermission(),
      child: const _QrScannerView(),
    );
  }
}

class _QrScannerView extends StatefulWidget {
  const _QrScannerView();

  @override
  State<_QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<_QrScannerView>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final ImagePicker _imagePicker = ImagePicker();
  late TopNotificationController _topNotificationController;

  @override
  void initState() {
    super.initState();
    _topNotificationController = TopNotificationController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _topNotificationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // User may have toggled the permission in system Settings.
      context.read<QrScannerCubit>().refreshCameraPermission();
    }
  }

  Future<void> _pickImageAndAnalyze() async {
    final cubit = context.read<QrScannerCubit>();
    if (cubit.state.isOpeningGallery) return;

    cubit.setOpeningGallery(true);

    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) {
        if (mounted) {
          cubit.setOpeningGallery(false);
        }
        return;
      }

      final result = await _controller.analyzeImage(image.path);
      if (!mounted) return;

      cubit.setOpeningGallery(false);

      if (result != null && result.barcodes.isNotEmpty) {
        final code = result.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty && !cubit.state.hasScanned) {
          await cubit.decodeQrCode(code, source: QrScanSource.gallery);
        } else {
          _topNotificationController.changeNotificationType(
            TopNotificationBarType.qrCodeInvalid,
          );
        }
      } else {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.qrCodeInvalid,
        );
      }
    } catch (e, st) {
      AppLogger.w(
        'Failed to pick or analyze gallery image',
        tag: 'QrScanner',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        context.read<QrScannerCubit>().setOpeningGallery(false);
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.qrCodeInvalid,
        );
      }
    }
  }

  Future<void> _onGalleryButtonTap() async {
    await _pickImageAndAnalyze();
  }

  void _onDetect(BarcodeCapture capture) {
    final cubit = context.read<QrScannerCubit>();
    if (cubit.state.hasScanned) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    cubit.decodeQrCode(code, source: QrScanSource.scan);
  }

  Future<void> _showPlanSelectionAndImport(List<StagePlanModel> plans) async {
    try {
      if (plans.isEmpty) return;
      final selectedPlan = await showSelectImportPlanBottomsheet(
        context,
        plan: plans.first,
      );

      if (!mounted) return;

      final cubit = context.read<QrScannerCubit>();
      if (selectedPlan != null) {
        await cubit.importPlans([selectedPlan]);
      } else {
        cubit.cancelSelection();
      }
    } catch (e, st) {
      AppLogger.w(
        'Failed to show plan selection bottomsheet',
        tag: 'QrScanner',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        context.read<QrScannerCubit>().cancelSelection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrScannerCubit, QrScannerState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus ||
          previous.decodedPlans != current.decodedPlans,
      listener: (context, state) {
        // Handle decoded plans - show selection bottomsheet
        if (state.decodedPlans != null &&
            state.decodedPlans!.isNotEmpty &&
            state.actionStatus == QrScannerActionStatus.idle) {
          _showPlanSelectionAndImport(state.decodedPlans!);
        }

        // Handle action status changes
        switch (state.actionStatus) {
          case QrScannerActionStatus.importSuccess:
            _topNotificationController.changeNotificationType(
              TopNotificationBarType.importSuccess,
            );
            final importedPlanId = state.importedPlanId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pop(importedPlanId);
              }
            });
          case QrScannerActionStatus.decodeError:
            _topNotificationController.changeNotificationType(
              TopNotificationBarType.qrCodeInvalid,
            );
            context.read<QrScannerCubit>().resetActionStatus();
          case QrScannerActionStatus.importError:
            _topNotificationController.changeNotificationType(
              TopNotificationBarType.commonError,
            );
            context.read<QrScannerCubit>().resetActionStatus();
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: CaminoNinjaAppBar(
          title: AppLocalizations.of(context).scanOrUploadQr,
        ),
        body: BlocBuilder<QrScannerCubit, QrScannerState>(
          buildWhen: (p, c) => p.cameraPermission != c.cameraPermission,
          builder: (context, state) {
            // Exhaustive switch over the 3-value enum so future additions
            // are caught at compile time.
            final permissionView = switch (state.cameraPermission) {
              CameraPermissionUiState.granted => null,
              // Initial state — permission status not yet resolved. Render
              // a centered loading indicator so the body isn't empty under
              // the floating gallery FAB.
              CameraPermissionUiState.unknown =>
                const Center(child: LoadingWidget()),
              CameraPermissionUiState.permanentlyDenied =>
                const _CameraPermissionExplainer(),
            };
            return Stack(
              children: [
                // Camera surface — only when granted. The explainer otherwise
                // covers the whole body (the gallery FAB stays on top).
                if (state.cameraPermission ==
                    CameraPermissionUiState.granted) ...[
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  _buildOverlay(context),
                ] else if (permissionView != null)
                  permissionView,
                // Gallery button — visible regardless of camera permission so
                // users can still import a QR from photos.
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: BlocBuilder<QrScannerCubit, QrScannerState>(
                    buildWhen: (p, c) =>
                        p.isOpeningGallery != c.isOpeningGallery,
                    builder: _buildUploadFromGallery,
                  ),
                ),
                TopNotificationOverlay(
                  key: const ValueKey('qr_scanner_top_notification_overlay'),
                  controller: _topNotificationController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width / 390 * 230;

    return BlocBuilder<QrScannerCubit, QrScannerState>(
      builder: (context, state) {
        return Stack(
          children: [
            // Semi-transparent overlay
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Corner decorations
            Center(
              child: SizedBox(
                width: scanAreaSize,
                height: scanAreaSize,
                child: CustomPaint(
                  painter: CornerPainter(
                    color: Colors.white,
                    strokeWidth: 6,
                    cornerLength: 32,
                    radius: 16,
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                height: scanAreaSize + 42 + 24,
                child: Column(
                  children: [
                    SizedBox(height: scanAreaSize),
                    const SizedBox(height: 42),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showSelectImportPlanBottomsheet(
                              context,
                              plan: context
                                  .read<QrScannerCubit>()
                                  .state
                                  .plans
                                  .first,
                            );
                          },
                          child: Container(
                            height: 24,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: context.isDarkMode
                                  ? AppColors.primary80
                                  : AppColors.primary40,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context).scanHere,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUploadFromGallery(BuildContext context, QrScannerState state) {
    return GestureDetector(
      onTap: state.isOpeningGallery ? null : _onGalleryButtonTap,
      child: Row(
        children: [
          RichText(
            textAlign: TextAlign.end,
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context).uploadFromGallery,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: ' ${AppLocalizations.of(context).here}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary80,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? AppColors.primary80
                  : AppColors.primary40,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: state.isOpeningGallery
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/ic_qrcode.svg',
                      width: 32,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-bleed explainer rendered in place of the camera preview when the
/// user has not granted camera access. Only ever shown when the OS will
/// no longer present the permission dialog, so the CTA always routes to
/// system Settings. The gallery FAB is composed on top of this by the
/// parent so users can still import a QR from photos.
class _CameraPermissionExplainer extends StatelessWidget {
  const _CameraPermissionExplainer();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.primary80
                    : AppColors.primary40,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.cameraPermissionTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cameraPermissionBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: openAppSettings,
              child: Text(l10n.openSettings),
            ),
          ],
        ),
      ),
    );
  }
}
