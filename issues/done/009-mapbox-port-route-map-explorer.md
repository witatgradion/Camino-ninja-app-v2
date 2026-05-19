## Parent PRD

`issues/prd.md`

## What to build

Port the dev-only route map explorer screen from `google_maps_flutter` to `mapbox_maps_flutter ^2.4.0`. Per parent PRD section "Chunk plan / C5".

File to port:
- `lib/tabs/more/screens/route_graph/route_map_screen.dart`

Lower priority since dev-only (More tab > Route Graph explorer), but must still compile and render correctly so the dev flavor builds clean and developers can keep using the explorer for debugging.

Document smoke checklist results.

## Acceptance criteria

- [ ] File compiles without `google_maps_flutter` import
- [ ] Smoke checklist passes in dev flavor:
  - Screen accessible from More tab → Route Graph
  - Route map renders correctly
  - All existing dev-only controls function
- [ ] No crashes in dev flavor
- [ ] `flutter analyze` clean

## Blocked by

- Blocked by `issues/002-atomic-merge-release-2-2-410.md`

## User stories addressed

- User story 17

## Progress note (2026-05-14) — OBSOLETE

This issue is obsolete. The target file `lib/tabs/more/screens/route_graph/route_map_screen.dart` was **deleted in C1** along with the rest of `lib/tabs/more/screens/route_graph/` (see `issues/done/002-atomic-merge-release-2-2-410.md` "Progress note (2026-05-14, decision)"). The directory was a dev-only debug screen that depended on the unavailable `graphview` package; product owner approved deleting it rather than porting.

The PRD's C5 chunk has been removed; see `issues/prd.md` "Progress note (2026-05-14)" for the updated chunk plan.

**Status: obsolete. Move to `issues/done/`.**
