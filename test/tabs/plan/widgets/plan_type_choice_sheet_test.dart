import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/plan_type_choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _RecordingAnalyticsService implements IAnalyticsService {
  final List<({String name, Map<String, dynamic> params})> tracked = [];

  @override
  void trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) {
    tracked.add((name: eventName, params: parameters ?? const {}));
  }

  @override
  void trackScreen({
    required String screenName,
    Map<String, dynamic>? parameters,
  }) {}

  @override
  void setUserId({String? userId}) {}

  @override
  void setUserProperties(Map<String, dynamic> properties) {}

  @override
  Future<void> flush() async {}
}

Future<void> _pumpContent(
  WidgetTester tester, {
  required Set<PlanType> visibleTypes,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PlanTypeChoiceContent(visibleTypes: visibleTypes),
      ),
    ),
  );
}

void main() {
  late _RecordingAnalyticsService analytics;

  setUp(() {
    analytics = _RecordingAnalyticsService();
    GetIt.instance.registerSingleton<IAnalyticsService>(analytics);
  });

  tearDown(GetIt.instance.reset);

  group('PlanTypeChoiceContent', () {
    testWidgets('renders all three options when all three are visible', (
      tester,
    ) async {
      await _pumpContent(
        tester,
        visibleTypes: PlanType.values.toSet(),
      );

      expect(find.text('Single Route'), findsOneWidget);
      expect(find.text('Custom Trail'), findsOneWidget);
      expect(find.text('Plan a Journey'), findsOneWidget);
    });

    testWidgets('renders only singleRoute when only it is visible', (
      tester,
    ) async {
      await _pumpContent(
        tester,
        visibleTypes: {PlanType.singleRoute},
      );

      expect(find.text('Single Route'), findsOneWidget);
      expect(find.text('Custom Trail'), findsNothing);
      expect(find.text('Plan a Journey'), findsNothing);
    });

    testWidgets('renders singleRoute + customTrail when journey is hidden', (
      tester,
    ) async {
      await _pumpContent(
        tester,
        visibleTypes: {PlanType.singleRoute, PlanType.customTrail},
      );

      expect(find.text('Single Route'), findsOneWidget);
      expect(find.text('Custom Trail'), findsOneWidget);
      expect(find.text('Plan a Journey'), findsNothing);
    });

    testWidgets('renders singleRoute + journey when customTrail is hidden', (
      tester,
    ) async {
      await _pumpContent(
        tester,
        visibleTypes: {PlanType.singleRoute, PlanType.journey},
      );

      expect(find.text('Single Route'), findsOneWidget);
      expect(find.text('Custom Trail'), findsNothing);
      expect(find.text('Plan a Journey'), findsOneWidget);
    });

    testWidgets('Beta badge renders only when Custom Trail is visible', (
      tester,
    ) async {
      await _pumpContent(
        tester,
        visibleTypes: {PlanType.singleRoute, PlanType.journey},
      );

      expect(find.text('Beta'), findsNothing);

      await _pumpContent(
        tester,
        visibleTypes: {PlanType.singleRoute, PlanType.customTrail},
      );

      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets(
      'tapping an option pops the route with that PlanType',
      (tester) async {
        PlanType? captured;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        captured = await showModalBottomSheet<PlanType>(
                          context: context,
                          builder: (_) => PlanTypeChoiceContent(
                            visibleTypes: PlanType.values.toSet(),
                          ),
                        );
                      },
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Custom Trail'));
        await tester.pumpAndSettle();

        expect(captured, PlanType.customTrail);
      },
    );
  });

  group('PlanTypeChoiceSheet analytics', () {
    testWidgets(
      'showPlanTypeChoiceSheet fires plan_type_choice_shown when opened',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => showPlanTypeChoiceSheet(
                        context,
                        visibleTypes: PlanType.values.toSet(),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        expect(analytics.tracked, isEmpty);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(
          analytics.tracked.map((e) => e.name),
          contains('plan_type_choice_shown'),
        );
      },
    );

    testWidgets(
      'selecting an option fires plan_type_choice_selected with the right '
      'plan_type value',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => showPlanTypeChoiceSheet(
                        context,
                        visibleTypes: PlanType.values.toSet(),
                      ),
                      child: const Text('open'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Plan a Journey'));
        await tester.pumpAndSettle();

        final selected = analytics.tracked
            .where((e) => e.name == 'plan_type_choice_selected')
            .toList();
        expect(selected, hasLength(1));
        expect(selected.single.params['plan_type'], 'journey');
      },
    );

    testWidgets(
      'each PlanType maps to the right analytics value when selected',
      (tester) async {
        Future<void> pumpAndSelect(PlanType type, String label) async {
          analytics.tracked.clear();
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () => showPlanTypeChoiceSheet(
                          context,
                          visibleTypes: PlanType.values.toSet(),
                        ),
                        child: const Text('open'),
                      ),
                    ),
                  );
                },
              ),
            ),
          );

          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }

        await pumpAndSelect(PlanType.singleRoute, 'Single Route');
        expect(
          analytics.tracked
              .firstWhere((e) => e.name == 'plan_type_choice_selected')
              .params['plan_type'],
          'single_route',
        );

        await pumpAndSelect(PlanType.customTrail, 'Custom Trail');
        expect(
          analytics.tracked
              .firstWhere((e) => e.name == 'plan_type_choice_selected')
              .params['plan_type'],
          'custom_trail',
        );

        await pumpAndSelect(PlanType.journey, 'Plan a Journey');
        expect(
          analytics.tracked
              .firstWhere((e) => e.name == 'plan_type_choice_selected')
              .params['plan_type'],
          'journey',
        );
      },
    );
  });

  group('PlanTypeAnalytics', () {
    test('analyticsValue maps each enum to snake_case', () {
      expect(PlanType.singleRoute.analyticsValue, 'single_route');
      expect(PlanType.customTrail.analyticsValue, 'custom_trail');
      expect(PlanType.journey.analyticsValue, 'journey');
    });
  });
}
