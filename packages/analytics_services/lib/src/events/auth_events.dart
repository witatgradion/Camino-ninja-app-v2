import 'package:analytics_services/src/analytics_event.dart';

/// Fired when a sign-in button is tapped.
class SignInClickedEvent extends AnalyticsEvent {
  /// Creates a [SignInClickedEvent].
  SignInClickedEvent({required this.type});

  /// Sign-in provider: `'Google'` or `'Apple'`.
  final String type;

  @override
  String get name => 'sign_in_clicked';

  @override
  Map<String, dynamic> get properties => {'type': type};
}

/// Fired after a successful sign-in.
class SignInSuccessEvent extends AnalyticsEvent {
  /// Creates a [SignInSuccessEvent].
  SignInSuccessEvent({required this.type});

  /// Sign-in provider: `'Google'` or `'Apple'`.
  final String type;

  @override
  String get name => 'sign_in_success';

  @override
  Map<String, dynamic> get properties => {
        'type': type,
      };
}

/// Fired when sign-in fails.
class SignInFailEvent extends AnalyticsEvent {
  /// Creates a [SignInFailEvent].
  SignInFailEvent({required this.type, required this.error});

  /// Sign-in provider: `'Google'` or `'Apple'`.
  final String type;

  /// Error description.
  final String error;

  @override
  String get name => 'sign_in_fail';

  @override
  Map<String, dynamic> get properties => {
        'type': type,
        'error': error,
      };
}

/// Fired when the user chooses to proceed as guest.
class ProceedAsGuestEvent extends AnalyticsEvent {
  @override
  String get name => 'proceed_as_guest';

  @override
  Map<String, dynamic> get properties => {};
}

/// Fired when the user signs out.
class SignOutEvent extends AnalyticsEvent {
  @override
  String get name => 'sign_out';

  @override
  Map<String, dynamic> get properties => {};
}
