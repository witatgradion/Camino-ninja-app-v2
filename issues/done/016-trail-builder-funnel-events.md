## Parent PRD

`issues/prd.md`

## What to build

Add trail builder funnel analytics events. Per parent PRD section "Analytics".

In `packages/analytics_services/lib/src/events/plan_events.dart` (or a new file if cleaner):
- `TrailBuilderJunctionDecisionEvent` — property `decision_number` (1-based); event name `trail_builder_junction_decision`
- `TrailBuilderUndoEvent` — no properties; event name `trail_builder_undo` (friction signal)
- `TrailBuilderFinalizedEvent` — no properties; event name `trail_builder_finalized` (terminal success)

Wire from `TrailBuilderCubit` state transitions. Each event fires exactly once per occurrence (e.g., undoing and re-deciding fires `_undo` once and a fresh `_junction_decision` event).

Unit tests for event properties.

## Acceptance criteria

- [ ] Three new event classes with correct names + properties
- [ ] Events fire from `TrailBuilderCubit` at the right transitions
- [ ] `decision_number` increments correctly across junctions
- [ ] Undo event fires per undo (not batched)
- [ ] Finalized event fires once on commit
- [ ] Unit tests added and pass
- [ ] Events visible in Firebase Analytics DebugView and Amplitude debug stream

## Blocked by

- Blocked by `issues/007-mapbox-port-trail-builder.md`

## User stories addressed

- User story 12
- User story 22
