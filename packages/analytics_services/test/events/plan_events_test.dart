import 'package:analytics_services/analytics_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreatePlanEvent', () {
    test('uses create_plan as the event name', () {
      final event = CreatePlanEvent(
        routeId: 1,
        routeName: 'Camino Francés',
      );
      expect(event.name, 'create_plan');
    });

    test('emits route_id and route_name as base properties', () {
      final event = CreatePlanEvent(
        routeId: 7,
        routeName: 'Camino Francés',
      );
      expect(event.properties['route_id'], 7);
      expect(event.properties['route_name'], 'Camino Francés');
    });

    test('omits optional properties when null', () {
      final event = CreatePlanEvent(
        routeId: 1,
        routeName: 'Camino Francés',
      );
      expect(event.properties.containsKey('has_starting_date'), isFalse);
      expect(event.properties.containsKey('source'), isFalse);
      expect(event.properties.containsKey('plan_type'), isFalse);
      expect(event.properties.containsKey('trail_route_count'), isFalse);
    });

    test('emits plan_type when provided', () {
      final event = CreatePlanEvent(
        routeId: 1,
        routeName: 'Camino Francés',
        planType: 'custom_trail',
      );
      expect(event.properties['plan_type'], 'custom_trail');
    });

    test('emits trail_route_count when provided', () {
      final event = CreatePlanEvent(
        routeId: 1,
        routeName: 'Camino Francés',
        trailRouteCount: 3,
      );
      expect(event.properties['trail_route_count'], 3);
    });

    test('emits trail_route_count == 1 for single-route plans', () {
      final event = CreatePlanEvent(
        routeId: 1,
        routeName: 'Camino Francés',
        planType: 'single_route',
        trailRouteCount: 1,
      );
      expect(event.properties['plan_type'], 'single_route');
      expect(event.properties['trail_route_count'], 1);
    });
  });

  group('PlanTypeChoiceShownEvent', () {
    test('uses plan_type_choice_shown as the event name', () {
      final event = PlanTypeChoiceShownEvent();
      expect(event.name, 'plan_type_choice_shown');
    });

    test('emits no properties', () {
      final event = PlanTypeChoiceShownEvent();
      expect(event.properties, isEmpty);
    });
  });

  group('PlanTypeChoiceSelectedEvent', () {
    test('uses plan_type_choice_selected as the event name', () {
      final event = PlanTypeChoiceSelectedEvent(planType: 'single_route');
      expect(event.name, 'plan_type_choice_selected');
    });

    test('emits the plan_type property verbatim', () {
      final event = PlanTypeChoiceSelectedEvent(planType: 'custom_trail');
      expect(event.properties, {'plan_type': 'custom_trail'});
    });

    test('round-trips each of the three known plan_type values', () {
      for (final value in const ['single_route', 'custom_trail', 'journey']) {
        final event = PlanTypeChoiceSelectedEvent(planType: value);
        expect(event.properties['plan_type'], value);
      }
    });
  });

  group('FeatureFlagExposureEvent', () {
    test('uses feature_flag_exposure as the event name', () {
      final event = FeatureFlagExposureEvent(
        flagName: 'feature_custom_trail_enabled',
        flagValue: true,
      );
      expect(event.name, 'feature_flag_exposure');
    });

    test('emits flag_name and flag_value verbatim', () {
      final event = FeatureFlagExposureEvent(
        flagName: 'feature_journey_planner_enabled',
        flagValue: false,
      );
      expect(event.properties, {
        'flag_name': 'feature_journey_planner_enabled',
        'flag_value': false,
      });
    });

    test('round-trips both boolean values', () {
      for (final value in const [true, false]) {
        final event = FeatureFlagExposureEvent(
          flagName: 'feature_x',
          flagValue: value,
        );
        expect(event.properties['flag_value'], value);
      }
    });
  });

  group('TrailBuilderJunctionDecisionEvent', () {
    test('uses trail_builder_junction_decision as the event name', () {
      final event = TrailBuilderJunctionDecisionEvent(decisionNumber: 1);
      expect(event.name, 'trail_builder_junction_decision');
    });

    test('emits decision_number verbatim', () {
      final event = TrailBuilderJunctionDecisionEvent(decisionNumber: 3);
      expect(event.properties, {'decision_number': 3});
    });

    test('round-trips a range of decision numbers', () {
      for (final n in const [1, 2, 5, 10]) {
        final event = TrailBuilderJunctionDecisionEvent(decisionNumber: n);
        expect(event.properties['decision_number'], n);
      }
    });
  });

  group('TrailBuilderUndoEvent', () {
    test('uses trail_builder_undo as the event name', () {
      final event = TrailBuilderUndoEvent();
      expect(event.name, 'trail_builder_undo');
    });

    test('emits no properties', () {
      final event = TrailBuilderUndoEvent();
      expect(event.properties, isEmpty);
    });
  });

  group('TrailBuilderFinalizedEvent', () {
    test('uses trail_builder_finalized as the event name', () {
      final event = TrailBuilderFinalizedEvent();
      expect(event.name, 'trail_builder_finalized');
    });

    test('emits no properties', () {
      final event = TrailBuilderFinalizedEvent();
      expect(event.properties, isEmpty);
    });
  });

  group('JourneyPlannerStartCitySelectedEvent', () {
    test('uses journey_planner_start_city_selected as the event name', () {
      final event = JourneyPlannerStartCitySelectedEvent(cityId: 7);
      expect(event.name, 'journey_planner_start_city_selected');
    });

    test('emits city_id verbatim', () {
      final event = JourneyPlannerStartCitySelectedEvent(cityId: 42);
      expect(event.properties, {'city_id': 42});
    });

    test('round-trips a range of city ids', () {
      for (final id in const [1, 17, 100, 9999]) {
        final event = JourneyPlannerStartCitySelectedEvent(cityId: id);
        expect(event.properties['city_id'], id);
      }
    });
  });

  group('JourneyPlannerDestinationSelectedEvent', () {
    test('uses journey_planner_destination_selected as the event name', () {
      final event = JourneyPlannerDestinationSelectedEvent(cityId: 11);
      expect(event.name, 'journey_planner_destination_selected');
    });

    test('emits city_id verbatim', () {
      final event = JourneyPlannerDestinationSelectedEvent(cityId: 88);
      expect(event.properties, {'city_id': 88});
    });

    test('round-trips a range of city ids', () {
      for (final id in const [2, 23, 250, 12345]) {
        final event = JourneyPlannerDestinationSelectedEvent(cityId: id);
        expect(event.properties['city_id'], id);
      }
    });
  });

  group('JourneyPlannerRouteOptionSelectedEvent', () {
    test('uses journey_planner_route_option_selected as the event name', () {
      final event = JourneyPlannerRouteOptionSelectedEvent(
        optionType: 'direct',
        positionIndex: 0,
      );
      expect(event.name, 'journey_planner_route_option_selected');
    });

    test('emits option_type and position_index verbatim', () {
      final event = JourneyPlannerRouteOptionSelectedEvent(
        optionType: 'via_junction',
        positionIndex: 3,
      );
      expect(event.properties, {
        'option_type': 'via_junction',
        'position_index': 3,
      });
    });

    test('round-trips each of the three known option_type values', () {
      for (final value in const ['direct', 'via_junction', 'multi_trail']) {
        final event = JourneyPlannerRouteOptionSelectedEvent(
          optionType: value,
          positionIndex: 0,
        );
        expect(event.properties['option_type'], value);
      }
    });

    test('round-trips a range of position indices', () {
      for (final idx in const [0, 1, 5, 9, 20]) {
        final event = JourneyPlannerRouteOptionSelectedEvent(
          optionType: 'direct',
          positionIndex: idx,
        );
        expect(event.properties['position_index'], idx);
      }
    });
  });

  group('resolveStageNoteAction', () {
    test('returns null when both sides are null', () {
      expect(resolveStageNoteAction(null, null), isNull);
    });

    test('returns null when both sides are empty/whitespace', () {
      expect(resolveStageNoteAction('', '   '), isNull);
    });

    test('returns null when the trimmed text is unchanged', () {
      expect(resolveStageNoteAction('hello', '  hello  '), isNull);
    });

    test('returns added when going from empty to non-empty', () {
      expect(resolveStageNoteAction(null, 'first note'), 'added');
      expect(resolveStageNoteAction('', 'first note'), 'added');
    });

    test('returns cleared when going from non-empty to empty/null', () {
      expect(resolveStageNoteAction('was here', null), 'cleared');
      expect(resolveStageNoteAction('was here', ''), 'cleared');
      expect(resolveStageNoteAction('was here', '   '), 'cleared');
    });

    test('returns edited when both sides differ and are non-empty', () {
      expect(resolveStageNoteAction('old', 'new'), 'edited');
    });
  });
}
