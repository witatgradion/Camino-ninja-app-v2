part of 'qr_scanner_cubit.dart';

enum QrScannerActionStatus {
  idle,
  decoding,
  importing,
  importSuccess,
  decodeError,
  importError,
}

/// UI state for the camera permission gate on the QR scanner screen.
enum CameraPermissionUiState {
  /// Initial state — we haven't checked the OS yet, so don't render either
  /// the scanner or the explainer (avoids a flash of the wrong UI).
  unknown,

  /// Permission has been granted; render the camera scanner.
  granted,

  /// Permission is not granted and the only path forward is the system
  /// Settings app. Covers OS [PermissionStatus.permanentlyDenied] and
  /// [PermissionStatus.restricted] as well as transient
  /// [PermissionStatus.denied] (which we treat uniformly as "no path
  /// forward but Settings"; the auto-request in `initCameraPermission`
  /// is the only place we trigger the OS dialog).
  permanentlyDenied,
}

class QrScannerState extends Equatable {
  const QrScannerState({
    this.plans = const [],
    this.isOpeningGallery = false,
    this.hasScanned = false,
    this.decodedPlans,
    this.actionStatus = QrScannerActionStatus.idle,
    this.importedPlanId,
    this.cameraPermission = CameraPermissionUiState.unknown,
  });

  final List<StagePlanModel> plans;
  final bool isOpeningGallery;
  final bool hasScanned;
  final List<StagePlanModel>? decodedPlans;
  final QrScannerActionStatus actionStatus;
  final int? importedPlanId;
  final CameraPermissionUiState cameraPermission;

  bool get isProcessing =>
      actionStatus == QrScannerActionStatus.decoding ||
      actionStatus == QrScannerActionStatus.importing;

  QrScannerState copyWith({
    List<StagePlanModel>? plans,
    bool? isOpeningGallery,
    bool? hasScanned,
    List<StagePlanModel>? decodedPlans,
    QrScannerActionStatus? actionStatus,
    int? importedPlanId,
    CameraPermissionUiState? cameraPermission,
    bool clearDecodedPlans = false,
  }) {
    return QrScannerState(
      plans: plans ?? this.plans,
      isOpeningGallery: isOpeningGallery ?? this.isOpeningGallery,
      hasScanned: hasScanned ?? this.hasScanned,
      decodedPlans:
          clearDecodedPlans ? null : (decodedPlans ?? this.decodedPlans),
      actionStatus: actionStatus ?? this.actionStatus,
      importedPlanId: importedPlanId ?? this.importedPlanId,
      cameraPermission: cameraPermission ?? this.cameraPermission,
    );
  }

  @override
  List<Object?> get props => [
        plans,
        isOpeningGallery,
        hasScanned,
        decodedPlans,
        actionStatus,
        importedPlanId,
        cameraPermission,
      ];
}
