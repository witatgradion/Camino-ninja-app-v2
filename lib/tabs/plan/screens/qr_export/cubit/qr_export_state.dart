part of 'qr_export_cubit.dart';

enum QrExportInitStatus {
  initial,
  loading,
  success,
  failure,
}

enum QrExportActionStatus {
  idle,
  processing,
  saveSuccess,
  shareSuccess,
  error,
}

class QrExportState extends Equatable {
  const QrExportState({
    this.plans = const [],
    this.initStatus = QrExportInitStatus.initial,
    this.actionStatus = QrExportActionStatus.idle,
    this.qrData,
    this.isDeepLink = false,
    this.errorMessage,
    this.sharedImagePath,
  });

  final List<StagePlanModel> plans;
  final QrExportInitStatus initStatus;
  final QrExportActionStatus actionStatus;
  final String? qrData;
  final bool isDeepLink;
  final String? errorMessage;
  final String? sharedImagePath;

  bool get isProcessing => actionStatus == QrExportActionStatus.processing;

  QrExportState copyWith({
    List<StagePlanModel>? plans,
    QrExportInitStatus? initStatus,
    QrExportActionStatus? actionStatus,
    String? qrData,
    bool? isDeepLink,
    String? errorMessage,
    String? sharedImagePath,
    bool clearError = false,
    bool clearSharedImagePath = false,
  }) {
    return QrExportState(
      plans: plans ?? this.plans,
      initStatus: initStatus ?? this.initStatus,
      actionStatus: actionStatus ?? this.actionStatus,
      qrData: qrData ?? this.qrData,
      isDeepLink: isDeepLink ?? this.isDeepLink,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sharedImagePath: clearSharedImagePath
          ? null
          : (sharedImagePath ?? this.sharedImagePath),
    );
  }

  @override
  List<Object?> get props => [
        plans,
        initStatus,
        actionStatus,
        qrData,
        isDeepLink,
        errorMessage,
        sharedImagePath,
      ];
}
