import 'dart:async';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum TopNotificationBarType {
  reviewSuccess,
  feedbackSuccess,
  reportSuccess,
  reviewError,
  feedbackError,
  reportError,
  uploadSuccess,
  uploadError,
  uploadCancel,
  bugReportSuccess,
  bugReportError,
  deletePlanSuccess,
  deleteStageSuccess,
  noStageToday,
  importSuccess,
  commonError,
  saveQrCodeSuccess,
  qrCodeInvalid,
  deleteAccountSuccess,
  syncSuccess,
  syncFailure;

  String title(BuildContext context) {
    return switch (this) {
      TopNotificationBarType.reviewSuccess ||
      TopNotificationBarType.feedbackSuccess =>
        AppLocalizations.of(context).feedbackSubmitted,
      TopNotificationBarType.reviewError ||
      TopNotificationBarType.feedbackError =>
        AppLocalizations.of(context).feedbackSubmissionFailed,
      TopNotificationBarType.reportSuccess ||
      TopNotificationBarType.reportError =>
        AppLocalizations.of(context).missingAccommodationReported,
      TopNotificationBarType.uploadCancel =>
        AppLocalizations.of(context).canceled,
      TopNotificationBarType.uploadError =>
        AppLocalizations.of(context).uploadFailed,
      TopNotificationBarType.uploadSuccess =>
        AppLocalizations.of(context).photoUploaded,
      TopNotificationBarType.bugReportSuccess =>
        AppLocalizations.of(context).bugReportSuccessTitle,
      TopNotificationBarType.bugReportError =>
        AppLocalizations.of(context).oopsSomethingWentWrong,
      TopNotificationBarType.commonError =>
        AppLocalizations.of(context).oopsSomethingWentWrong,
      TopNotificationBarType.deletePlanSuccess =>
        AppLocalizations.of(context).planDeletedSuccessfully,
      TopNotificationBarType.deleteStageSuccess =>
        AppLocalizations.of(context).stageDeletedSuccessfully,
      TopNotificationBarType.noStageToday =>
        AppLocalizations.of(context).noStagePlannedToday,
      TopNotificationBarType.importSuccess =>
        AppLocalizations.of(context).importSuccess,
      TopNotificationBarType.saveQrCodeSuccess =>
        AppLocalizations.of(context).qrCodeSaved,
      TopNotificationBarType.qrCodeInvalid =>
        AppLocalizations.of(context).qrCodeInvalid,
      TopNotificationBarType.deleteAccountSuccess =>
        AppLocalizations.of(context).accountDeleted,
      TopNotificationBarType.syncSuccess =>
        AppLocalizations.of(context).syncSuccessTitle,
      TopNotificationBarType.syncFailure =>
        AppLocalizations.of(context).syncFailureTitle,
    };
  }

  String? description(BuildContext context) {
    return switch (this) {
      TopNotificationBarType.reviewSuccess ||
      TopNotificationBarType.feedbackSuccess =>
        AppLocalizations.of(context).feedbackSubmitSuccessMessage,
      TopNotificationBarType.reviewError ||
      TopNotificationBarType.reportError ||
      TopNotificationBarType.uploadError ||
      TopNotificationBarType.feedbackError =>
        AppLocalizations.of(context).pleaseTryAgainLater,
      TopNotificationBarType.reportSuccess =>
        AppLocalizations.of(context).reportMissingAlbergueMessage,
      TopNotificationBarType.uploadCancel =>
        AppLocalizations.of(context).uploadFailDueToCancellation,
      TopNotificationBarType.uploadSuccess =>
        AppLocalizations.of(context).uploadPhotoSuccessMessage,
      TopNotificationBarType.bugReportSuccess =>
        AppLocalizations.of(context).bugReportSuccessDescription,
      TopNotificationBarType.bugReportError =>
        AppLocalizations.of(context).bugReportFailureDescription,
      TopNotificationBarType.commonError =>
        AppLocalizations.of(context).pleaseTryAgainLater,
      TopNotificationBarType.saveQrCodeSuccess =>
        AppLocalizations.of(context).qrCodeSaveSuccess,
      TopNotificationBarType.qrCodeInvalid =>
        AppLocalizations.of(context).qrCodeInvalidError,
      TopNotificationBarType.importSuccess =>
        AppLocalizations.of(context).plansImportSuccess,
      TopNotificationBarType.deleteAccountSuccess =>
        AppLocalizations.of(context).deleteExitGreeting,
      TopNotificationBarType.syncSuccess =>
        AppLocalizations.of(context).syncSuccessDescription,
      TopNotificationBarType.syncFailure =>
        AppLocalizations.of(context).syncFailureDescription,
      _ => null,
    };
  }

  Color get backgroundColor {
    return switch (this) {
      TopNotificationBarType.reviewSuccess ||
      TopNotificationBarType.reportSuccess ||
      TopNotificationBarType.feedbackSuccess ||
      TopNotificationBarType.uploadSuccess ||
      TopNotificationBarType.bugReportSuccess ||
      TopNotificationBarType.importSuccess ||
      TopNotificationBarType.saveQrCodeSuccess ||
      TopNotificationBarType.deleteAccountSuccess ||
      TopNotificationBarType.syncSuccess =>
        AppColors.primary80,
      TopNotificationBarType.reviewError ||
      TopNotificationBarType.reportError ||
      TopNotificationBarType.feedbackError ||
      TopNotificationBarType.uploadCancel ||
      TopNotificationBarType.uploadError ||
      TopNotificationBarType.bugReportError ||
      TopNotificationBarType.noStageToday ||
      TopNotificationBarType.commonError ||
      TopNotificationBarType.qrCodeInvalid ||
      TopNotificationBarType.syncFailure =>
        AppColors.red100,
      _ => AppColors.primary80,
    };
  }

  Color get contextColor {
    return switch (this) {
      TopNotificationBarType.reviewSuccess ||
      TopNotificationBarType.reportSuccess ||
      TopNotificationBarType.feedbackSuccess ||
      TopNotificationBarType.uploadSuccess ||
      TopNotificationBarType.bugReportSuccess ||
      TopNotificationBarType.importSuccess ||
      TopNotificationBarType.saveQrCodeSuccess ||
      TopNotificationBarType.deleteAccountSuccess ||
      TopNotificationBarType.syncSuccess =>
        Colors.black,
      TopNotificationBarType.reviewError ||
      TopNotificationBarType.reportError ||
      TopNotificationBarType.feedbackError ||
      TopNotificationBarType.uploadCancel ||
      TopNotificationBarType.uploadError ||
      TopNotificationBarType.bugReportError ||
      TopNotificationBarType.commonError ||
      TopNotificationBarType.qrCodeInvalid ||
      TopNotificationBarType.syncFailure =>
        AppColors.red700,
      _ => Colors.black,
    };
  }
}

class TopNotificationBar extends StatelessWidget {
  const TopNotificationBar(
      {required this.type, required this.onClose, super.key,});
  final TopNotificationBarType type;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: type.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.84),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.title(context),
                  style: context.textTheme.titleMedium?.copyWith(
                    color: type.contextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (type.description(context) != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    type.description(context)!,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: type.contextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onClose,
            child: SvgPicture.asset(
              'assets/ic_close.svg',
              color: type.contextColor,
              width: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class TopNotificationController extends ChangeNotifier {
  TopNotificationBarType? _currentNotificationType;
  Timer? _hideTimer;
  int _notificationId = 0;

  void changeNotificationType(TopNotificationBarType? type) {
    // Cancel any existing timer
    _hideTimer?.cancel();
    _hideTimer = null;

    _currentNotificationType = type;
    if (type != null) {
      _notificationId++; // Increment to force re-trigger for same type
    }
    notifyListeners();

    if (type != null) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (!hasListeners) return; // Don't notify if disposed
        _currentNotificationType = null;
        notifyListeners();
      });
    }
  }

  TopNotificationBarType? get type => _currentNotificationType;
  int get notificationId => _notificationId;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _hideTimer = null;
    super.dispose();
  }
}

class TopNotificationOverlay extends StatefulWidget {
  const TopNotificationOverlay({required this.controller, super.key});
  final TopNotificationController controller;

  @override
  State<TopNotificationOverlay> createState() => _TopNotificationOverlayState();
}

class _TopNotificationOverlayState extends State<TopNotificationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  TopNotificationBarType? _currentNotificationType;
  int _lastNotificationId = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin:
          -150, // Start above the screen (adjust based on notification bar height)
      end: 0, // End at the top of the screen
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    widget.controller.addListener(_handleNotificationChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleNotificationChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleNotificationChange() {
    if (!mounted) return;

    final newType = widget.controller.type;
    final newId = widget.controller.notificationId;
    final isNewNotification = newId != _lastNotificationId;

    if (newType == null && _currentNotificationType != null) {
      // Hide animation
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentNotificationType = null;
          });
        }
      });
    } else if (newType != null && isNewNotification) {
      // Show new notification (or re-show same type)
      _lastNotificationId = newId;

      // Stop any ongoing animation
      if (_animationController.isAnimating) {
        _animationController.stop();
      }
      _animationController.reset();

      setState(() {
        _currentNotificationType = newType;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentNotificationType == newType) {
          _animationController.forward();
        }
      });
    } else if (newType != null &&
        _currentNotificationType != newType &&
        !isNewNotification) {
      // Just update the type without animation (edge case)
      setState(() {
        _currentNotificationType = newType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated TopNotificationBar
        AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Positioned(
              top: _slideAnimation.value,
              left: 0,
              right: 0,
              child: _currentNotificationType != null
                  ? TopNotificationBar(
                      type: _currentNotificationType!,
                      onClose: () {
                        widget.controller.changeNotificationType(null);
                      },
                    )
                  : const SizedBox.shrink(),
            );
          },
        ),
      ],
    );
  }
}
