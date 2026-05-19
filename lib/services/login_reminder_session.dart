/// Process-scoped session flag for the Stage Planner login reminder banner.
///
/// Dismissal is intentionally session-only: the user dismisses the urgency
/// banner on one screen and it stays dismissed across screens until the app
/// process restarts. No persistence.
class LoginReminderSession {
  bool _isDismissedThisSession = false;

  /// Whether the banner has been dismissed during the current app session.
  bool get isDismissedThisSession => _isDismissedThisSession;

  /// Marks the banner as dismissed for the remainder of this session.
  void dismiss() {
    _isDismissedThisSession = true;
  }
}
