import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:flutter/widgets.dart';

enum ReviewFeedbackType {
  reviewAlbergue,
  feedbackAlbergue,
  missingAccommodation,
  bugReport,
  bugReportInMoreTab;

  bool get showRating => this == ReviewFeedbackType.reviewAlbergue;
  bool get showName =>
      this != ReviewFeedbackType.bugReport &&
      this != ReviewFeedbackType.bugReportInMoreTab &&
      this != ReviewFeedbackType.reviewAlbergue;
  bool get showEmail =>
      this != ReviewFeedbackType.missingAccommodation &&
      this != ReviewFeedbackType.reviewAlbergue;
  bool get showDescription => this != ReviewFeedbackType.missingAccommodation;

  /// Whether this flow surfaces the "include stage plan data"
  /// checkbox. Only the bug-report variants do — review and
  /// missing-accommodation flows have nothing useful to do with
  /// a DB export.
  bool get showIncludeDbDump =>
      this == ReviewFeedbackType.bugReport ||
      this == ReviewFeedbackType.bugReportInMoreTab;

  String title(BuildContext context) {
    return switch (this) {
      ReviewFeedbackType.reviewAlbergue =>
        AppLocalizations.of(context).reviewAlbergueBottomSheetTitle,
      ReviewFeedbackType.feedbackAlbergue =>
        AppLocalizations.of(context).feedbackAlbergueBottomSheetTitle,
      ReviewFeedbackType.missingAccommodation =>
        AppLocalizations.of(context).reportMissingAlbergueBottomSheetTitle,
      ReviewFeedbackType.bugReport =>
        AppLocalizations.of(context).bugReportTitle,
      ReviewFeedbackType.bugReportInMoreTab =>
        AppLocalizations.of(context).somethingNotWorking,
    };
  }

  String description(BuildContext context) {
    return switch (this) {
      ReviewFeedbackType.reviewAlbergue =>
        AppLocalizations.of(context).reviewAlbergueBottomSheetDescription,
      ReviewFeedbackType.feedbackAlbergue =>
        AppLocalizations.of(context).feedbackAlbergueBottomSheetDescription,
      ReviewFeedbackType.missingAccommodation => AppLocalizations.of(context)
          .reportMissingAlbergueBottomSheetDescription,
      ReviewFeedbackType.bugReport =>
        AppLocalizations.of(context).bugReportDescription,
      ReviewFeedbackType.bugReportInMoreTab =>
        AppLocalizations.of(context).bugReportDescriptionNew,
    };
  }

  String feedbackEmptyError(BuildContext context) {
    return switch (this) {
      ReviewFeedbackType.missingAccommodation =>
        AppLocalizations.of(context).feedbackIsRequired,
      _ => AppLocalizations.of(context).thisFieldIsRequired,
    };
  }

  String feedbackLabel(BuildContext context) {
    return switch (this) {
      ReviewFeedbackType.missingAccommodation =>
        AppLocalizations.of(context).missingAccommodationPlaceholder,
      ReviewFeedbackType.bugReport ||
      ReviewFeedbackType.bugReportInMoreTab =>
        AppLocalizations.of(context).tellUsMoreAboutTheIssue,
      _ => AppLocalizations.of(context).additionalFeedback,
    };
  }

  String nameLabel(BuildContext context) {
    return switch (this) {
      ReviewFeedbackType.missingAccommodation =>
        '${AppLocalizations.of(context).accommodationName} (${AppLocalizations.of(context).optional})',
      _ =>
        '${AppLocalizations.of(context).name} (${AppLocalizations.of(context).optional})',
    };
  }
}
