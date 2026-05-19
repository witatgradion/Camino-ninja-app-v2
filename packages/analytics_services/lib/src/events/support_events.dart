import 'package:analytics_services/src/analytics_event.dart';

/// Fired when the Buy Me a Coffee button on the More screen is tapped.
class BuyMeACoffeeTappedEvent extends AnalyticsEvent {
  @override
  String get name => 'buy_me_a_coffee_tapped';

  @override
  Map<String, dynamic> get properties => const {};
}
