part of 'preferences_cubit.dart';

class PreferencesState extends Equatable {
  const PreferencesState({
    this.doNotAskBugReportAgain = false,
    this.doNotAskStagePlannerAnnouncement = false,
    this.hasSeenNotificationPrompt = false,
  });

  final bool doNotAskBugReportAgain;
  final bool doNotAskStagePlannerAnnouncement;
  final bool hasSeenNotificationPrompt;

  PreferencesState copyWith({
    bool? doNotAskBugReportAgain,
    bool? doNotAskStagePlannerAnnouncement,
    bool? hasSeenNotificationPrompt,
  }) {
    return PreferencesState(
      doNotAskBugReportAgain:
          doNotAskBugReportAgain ?? this.doNotAskBugReportAgain,
      doNotAskStagePlannerAnnouncement:
          doNotAskStagePlannerAnnouncement ??
              this.doNotAskStagePlannerAnnouncement,
      hasSeenNotificationPrompt: hasSeenNotificationPrompt ??
          this.hasSeenNotificationPrompt,
    );
  }

  @override
  List<Object?> get props => [
        doNotAskBugReportAgain,
        doNotAskStagePlannerAnnouncement,
        hasSeenNotificationPrompt,
      ];
}
