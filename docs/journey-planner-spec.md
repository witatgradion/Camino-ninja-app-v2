# Plan a Journey -- Route Suggestion Wizard

## Status: Draft
## Last updated: 2026-04-08

---

## 1. Overview

### Problem

The existing plan creation flow offers two options:

1. **Single Route** -- the user picks one Camino route, picks a starting city, and plans stages along that route. Simple, but only works when the user already knows which route they want.
2. **Custom Trail (Beta)** -- the trail builder walks the user through every junction decision one by one, building a `MultiRouteTrail`. Powerful, but requires the user to understand route geography, junction points, and route names. Too complex for someone who just knows "I want to walk from Porto to Santiago."

There is no middle ground. A pilgrim who knows their starting city and destination city -- but does not know which routes connect them -- has no way to discover the answer inside the app.

### Solution

**"Plan a Journey"** -- a guided wizard that asks two questions:

1. Where are you starting?
2. Where do you want to end up?

The app then computes all possible route combinations (single-route and multi-route via junctions) and presents them as ranked options. The user picks one, and the app auto-generates the `MultiRouteTrail` and feeds it into the existing plan creation flow.

### Where it fits

The journey planner appears as a third option in the `PlanTypeChoiceSheet`, alongside "Single Route" and "Custom Trail":

| Option | Target user | Complexity |
|---|---|---|
| Single Route | Knows which route they want | Low |
| **Plan a Journey** | Knows start and end cities | **Low** |
| Custom Trail (Beta) | Wants full junction control | High |

The journey planner is not a replacement for the trail builder. It is a simpler entry point that produces the same output (`MultiRouteTrail`) and flows into the same plan creation pipeline.

---

## 2. User Flow

### Step 1: Name the plan

Same as today -- the `NamePlanDialog` appears first. The user enters an optional plan name. This happens before the plan type selection, so the flow is identical to existing plan types.

### Step 2: Select "Plan a Journey" from the plan type sheet

A new third option appears in `PlanTypeChoiceSheet`:

- Icon: `Icons.explore_rounded` (or similar wayfinding icon)
- Title: "Plan a Journey"
- Subtitle: "Pick a start and destination, we'll suggest routes"
- No badge (this is a general-audience feature, not beta)

### Step 3: Select starting city

A searchable city list screen. The user searches across **all cities on all routes**.

**Key behaviors:**
- Search is against city `name` field (case-insensitive substring match)
- Results grouped by route name for clarity (a city like "Santiago de Compostela" appears on many routes)
- Each result shows: city name, route name(s), country/region
- The user selects a specific city (by ID, not by name alone -- this avoids the ambiguity problem)
- Cities are loaded from the local SQLite database (`cities` + `city_routes` tables) -- no network call needed

**What gets stored:** `startCityId: int` and `startCityRouteIds: Set<int>` (the set of routes this city belongs to).

### Step 4: Select destination city

A second searchable city list screen, visually identical to Step 3 but with **reachability filtering**.

**Key behaviors:**
- The search pool is **all cities** (not filtered upfront -- see rationale below)
- Results are tagged with reachability:
  - **Direct** -- reachable on a shared route (no junction needed)
  - **Via junction** -- reachable with 1-2 route changes
  - **Not reachable** -- no known path exists (shown grayed out at the bottom, with a note)
- The user can only select reachable cities
- Reachability is computed using the route connectivity graph (Section 3)

**Why not pre-filter?** Because showing unreachable cities with a clear "not reachable" label teaches the user about the route network. It is better UX than an empty search result with no explanation.

**What gets stored:** `endCityId: int` and `endCityRouteIds: Set<int>`.

### Step 5: View route suggestions

A results screen showing all valid route options between start and end, ranked by simplicity.

**Each route option card shows:**
- Route chain: names of routes in order, e.g. "Portugues Central" or "Portugues Central -> Portugues Coastal"
- Route colors: colored dots or line segments matching each route's `legendColor`
- Junction city names (if multi-route): "via Pontevedra"
- Estimated total distance (km) -- sum of segment distances
- Number of route changes: 0, 1, or 2
- Number of cities/stages: total city count across segments

**Ranking order (top = best):**
1. Direct routes (0 junctions) -- sorted by fewer cities (shorter walk)
2. Single-junction routes -- sorted by total distance ascending
3. Two-junction routes -- sorted by total distance ascending

**Empty state:** "No routes found between [start] and [end]. Try the Custom Trail builder for more flexibility."

### Step 6: Confirm and create plan

The user taps a route option. The app:

1. Builds the `MultiRouteTrail` from the selected option's `TrailSegmentDescriptor` list
2. Navigates to `AddEditStageScreen` with the trail pre-populated (same as custom trail flow)
3. The first stage is auto-created from start city to the suggested first stopping point
4. The user lands in the plan detail screen, ready to add/edit stages

This step reuses the existing trail-to-plan pipeline. No new plan creation logic is needed.

---

## 3. Route Discovery Algorithm

### 3.1 Route Connectivity Graph

The foundation is a **route-level adjacency graph** built from junction data.

**Definitions:**
- A **junction** is a city that belongs to 2+ routes (exists in `city_routes` with multiple `route_id` values for the same `city_id`)
- Two routes are **connected** if they share at least one junction city where both routes have forward cities (not a terminus)
- A **connection** between route A and route B via city C means: a pilgrim walking route A can switch to route B at city C

**Graph construction:**

```
Input:  cityRouteMap: Map<int, Set<int>>  (from JunctionService._cityRouteMap)
        allRoutes: List<RouteEntity>
        routeCities: Map<int, List<CityEntity>>  (ordered city lists per route)

Output: RouteGraph
          - adjacency: Map<int, List<RouteConnection>>
            where RouteConnection = { targetRouteId, junctionCityId, junctionCityName }
          - routeIndex: Map<int, RouteEntity>
          - cityRouteIndex: Map<int, Set<int>>  (city -> routes, same as cityRouteMap)
```

**Algorithm:**

```
for each (cityId, routeIds) in cityRouteMap:
    if routeIds.length < 2: skip

    for each pair (routeA, routeB) in routeIds:
        if cityId is NOT the last city on routeA AND NOT the last city on routeB:
            add edge: routeA --[cityId]--> routeB
            add edge: routeB --[cityId]--> routeA
```

This mirrors the filtering logic in `JunctionService.getJunctionsForRoute` (lines 116-153 of `junction_service.dart`), specifically:
- Skip cities that are the last city on a route (line 122-123)
- Skip routes where the junction city is a terminus (lines 142-151, `hasForwardCities` check)

**Additional filter (divergence check):** The existing junction service also filters out routes that share the next city (lines 129-137, the "still overlapping" check). For the route graph, we should apply this same filter to avoid suggesting junction switches at cities where routes are still running parallel. However, for the MVP we can skip this refinement and add it in Phase 2 -- the result would be a slightly suboptimal junction suggestion, not a broken one.

### 3.2 Path Finding: Start City to End City

Given `startCityId` and `endCityId`, find all valid route sequences.

**Step 1: Identify candidate routes**

```
startRoutes = cityRouteMap[startCityId]  // e.g. {1, 3}
endRoutes   = cityRouteMap[endCityId]    // e.g. {2, 5}
```

**Step 2: Find paths between route sets**

For each `(startRouteId, endRouteId)` pair:

- **Same route (direct):** If `startRouteId == endRouteId`, check that `endCityId` comes AFTER `startCityId` in the route's ordered city list. If yes, this is a direct single-route path.
- **Different routes:** BFS on the route graph from `startRouteId` to `endRouteId`, with max depth = 3 (i.e., at most 2 intermediate junctions, meaning 3 route segments).

**BFS details:**

```
queue = [(startRouteId, [startRouteId], [])]  // (currentRoute, visitedRoutes, junctions)

while queue not empty:
    (current, visited, junctions) = queue.pop()

    if current == endRouteId:
        yield Path(routeSequence=visited, junctionCityIds=junctions)
        continue

    if visited.length >= MAX_DEPTH (3):
        continue

    for each connection in adjacency[current]:
        if connection.targetRouteId not in visited:
            queue.push((
                connection.targetRouteId,
                [...visited, connection.targetRouteId],
                [...junctions, connection.junctionCityId]
            ))
```

**Step 3: Validate city ordering**

For each candidate path, verify that the city ordering is valid (walking direction is forward, not backward):

- On the first route: `startCityId` must come before the first junction city
- On intermediate routes: previous junction city must come before the next junction city
- On the last route: the last junction city must come before `endCityId`

Use the ordered city lists from `JunctionService.getCitiesForRoute` to check index ordering.

**Step 4: Build TrailSegmentDescriptor list**

For each valid path:

```
descriptors = [
    TrailSegmentDescriptor(routeId: routes[0], junctionCityId: null),
    TrailSegmentDescriptor(routeId: routes[1], junctionCityId: junctions[0]),
    TrailSegmentDescriptor(routeId: routes[2], junctionCityId: junctions[1]),
    ...
]
```

This is the exact format stored by `MultiRouteTrail.toStorageString()` and consumed by `MultiRouteTrail.parseDescriptors()`.

### 3.3 Distance Estimation

For each suggested path, estimate total walking distance:

- For each segment, use `RouteEntity.calculateRouteStatistics()` with the segment's start and end cities, passing the route's `routePoints`
- Sum the `distance` field across segments
- This gives a reasonable km estimate without needing any new computation infrastructure

### 3.4 Ranking

Sort the result list by:

1. Number of junctions ascending (0 first, then 1, then 2)
2. Within same junction count: total estimated distance ascending
3. Tiebreaker: route `orderKey` of the first segment ascending (popular routes first)

### 3.5 Edge Cases

| Case | Behavior |
|---|---|
| Start and end on the same route | Single direct option, no junctions |
| Start and end on same route but end is before start | Not a valid path (walking backward). Excluded from results. |
| No path exists | Empty results. Show "No routes found" empty state. |
| Multiple equivalent paths (same routes, different junction cities) | Show all -- different junction cities mean different walking experiences |
| Start city = end city | Reject in UI validation. "Start and destination must be different cities." |
| City belongs to 5+ routes | All route combinations explored. BFS max depth keeps this bounded. |

---

## 4. Data Requirements

### Already available (no changes needed)

| Data | Source | Used for |
|---|---|---|
| `city_routes` table | `AppDatabase` | Building the route connectivity graph |
| `JunctionService._cityRouteMap` | `Repository.getCityRouteMapping()` | City-to-routes lookup |
| Ordered city lists per route | `JunctionService.getCitiesForRoute()` | City ordering validation, distance computation |
| Route entities | `Repository.getRoutesFromDb()` | Route names, colors, metadata |
| Route points | `Repository.getRoutePointsByRouteIdFromDb()` | Distance estimation |
| `MultiRouteTrail` model | `packages/repository` | Output format for the plan creation pipeline |
| `TrailSegmentDescriptor` | `packages/repository` | Compact path representation |
| Plan creation flow | `AddEditStageScreen` | Creating the actual stage plan from a trail |

### New data structures (in-memory only, no DB changes)

| Structure | Purpose |
|---|---|
| `RouteGraph` | Adjacency list of route connections via junction cities |
| `RoutePath` | A candidate path: list of route IDs + junction city IDs + metadata |
| `JourneyOption` | A ranked, displayable route suggestion with distance and city counts |

### Performance considerations

**Graph construction:** The route connectivity graph is built from `city_routes` (one table scan). With ~20-30 routes and ~1000 cities, this is sub-millisecond work.

**Path finding:** BFS with max depth 3 on a graph of ~20-30 nodes. Even with high connectivity, this explores at most a few hundred paths. Negligible time.

**City ordering validation:** One `getCitiesForRoute` call per route in each path. These are cached in `JunctionService._routeCitiesCache`, so only the first call per route hits the DB.

**Distance estimation:** Requires loading route points for each route in the selected path. This is the most expensive operation, but it only happens once when the user views results, and `getRoutePointsByRouteIdFromDb` results can be cached per route.

**Bottom line:** No pre-computation or caching infrastructure is needed beyond what already exists. The algorithm runs entirely on local data already synced to the device.

---

## 5. UI Design Direction

### 5.1 City Search Screen (Steps 3 and 4)

Reusable screen used for both start and destination selection.

**Layout:**
- `AppBar` with title "Starting city" or "Destination city"
- Search text field (sticky at top)
- Scrollable city result list below

**City result item:**
- City name (bold)
- Route name(s) in subtitle text, separated by commas
- Country/region in tertiary text
- For destination search: reachability badge ("Direct", "Via 1 junction", "Not reachable")

**Search behavior:**
- Debounced (300ms) substring search on `city.name`
- Minimum 2 characters before searching
- Results capped at 50 for performance
- When no query: show nothing (blank state with helper text: "Search for a city by name")

### 5.2 Route Suggestions Screen (Step 5)

**Layout:**
- `AppBar` with title "Route options" and subtitle "[Start City] to [End City]"
- List of `JourneyOptionCard` widgets
- Empty state widget if no paths found

**JourneyOptionCard:**

```
+-----------------------------------------------+
|  [=] Portugues Central                    790km |
|      Porto -> ... -> Santiago de Compostela     |
|      Direct route  |  42 cities                 |
+-----------------------------------------------+

+-----------------------------------------------+
|  [=][=] Portugues Central -> Coastal      820km |
|         Porto -> ... Pontevedra -> ... Santiago  |
|         1 junction (via Pontevedra)  |  38 cities|
+-----------------------------------------------+
```

- Left edge: colored dots/segments for each route in the chain (using `legendColor`)
- Route chain: route names joined with arrow
- Distance: right-aligned, bold
- Subtitle: abbreviated city sequence (start, junction cities, end)
- Footer: junction count + total cities
- Tap: proceeds to Step 6

**Visual priority:**
- Text-based cards for MVP (no map preview)
- Phase 3 could add a mini-map preview using the route polylines already available

### 5.3 Not-reachable feedback

When the user selects a destination that has no path from the start:

- The destination appears grayed out in the list
- Tapping it shows a brief toast/snackbar: "No route connects [Start] to [End]"
- The user can still browse but cannot proceed

---

## 6. Architecture

### 6.1 New files

| File | Type | Responsibility |
|---|---|---|
| `packages/repository/lib/src/route_path_finder.dart` | Service | Builds route graph, runs BFS, validates paths, computes distances |
| `lib/tabs/plan/screens/journey_planner/cubit/journey_planner_cubit.dart` | Cubit | Manages the wizard state machine (city selection -> results -> creation) |
| `lib/tabs/plan/screens/journey_planner/cubit/journey_planner_state.dart` | State | Wizard state: selected cities, loading status, route options |
| `lib/tabs/plan/screens/journey_planner/journey_planner_screen.dart` | Screen | Top-level screen hosting the wizard steps |
| `lib/tabs/plan/screens/journey_planner/widgets/city_search_delegate.dart` | Widget | Searchable city list (reused for start and destination) |
| `lib/tabs/plan/screens/journey_planner/widgets/journey_option_card.dart` | Widget | Card displaying one route suggestion |
| `packages/repository/lib/src/models/route_graph.dart` | Model | `RouteGraph`, `RouteConnection`, `RoutePath`, `JourneyOption` |

### 6.2 Existing code reused (no changes needed)

| Component | How it is reused |
|---|---|
| `JunctionService` | Provides `_cityRouteMap`, `getCitiesForRoute`, `hasForwardCities` |
| `MultiRouteTrail` / `TrailSegmentDescriptor` | Output format -- journey planner produces these, plan creation consumes them |
| `AddEditStageScreen` | Takes the generated `MultiRouteTrail` and creates the plan + first stage |
| `PlanTypeChoiceSheet` | Gets a new `PlanType.journey` enum value and a third option tile |
| `Repository.getRoutesFromDb()` | Loads all routes for graph building |
| `Repository.getRoutePointsByRouteIdFromDb()` | Distance estimation |
| `RouteEntity.calculateRouteStatistics()` | Per-segment distance calculation |

### 6.3 Existing code modified

| Component | Change |
|---|---|
| `PlanTypeChoiceSheet` | Add `PlanType.journey` to enum, add third option tile |
| `PlanListScreen._goToAddPlan()` | Add `case PlanType.journey:` handler that navigates to journey planner |
| `app.dart` (GoRouter) | Add route `/plan/journey-planner` |
| DI setup | Register `RoutePathFinder` in GetIt (depends on `Repository` + `JunctionService`) |

### 6.4 State machine

```
JourneyPlannerStatus:
    initial
    -> loadingCities        (fetching all cities + building route graph)
    -> startCitySelection   (user searches for start city)
    -> destinationCitySelection  (user searches for destination)
    -> loadingRoutes        (computing path options)
    -> routeOptions         (displaying results)
    -> creatingPlan         (building MultiRouteTrail, navigating to plan creation)
    -> failure
```

The cubit holds:
- `allCities: List<CityEntity>` -- loaded once
- `allRoutes: List<RouteEntity>` -- loaded once
- `routeGraph: RouteGraph` -- built once from junction data
- `startCity: CityEntity?` -- user selection
- `endCity: CityEntity?` -- user selection
- `journeyOptions: List<JourneyOption>` -- computed results
- `status: JourneyPlannerStatus`

### 6.5 Navigation flow

```
PlanListScreen
  -> NamePlanDialog (returns plan name)
  -> PlanTypeChoiceSheet (returns PlanType.journey)
  -> JourneyPlannerScreen
       Step 1: CitySearchScreen (start) -- returns CityEntity
       Step 2: CitySearchScreen (destination) -- returns CityEntity
       Step 3: Route options list
       Step 4: User taps option -- returns MultiRouteTrail
  -> AddEditStageScreen (existing, receives trail + planName)
  -> PlanDetailScreen (existing)
```

---

## 7. Scope and Phases

### Phase 1: MVP -- Direct single-route suggestions only

**What ships:**
- "Plan a Journey" option in the plan type sheet
- City search screen (start and destination)
- Path finding limited to same-route matches only (no junction traversal)
- Route options screen showing direct routes
- Auto-creates plan via existing flow

**Why start here:**
- Validates the UX without the algorithm complexity
- Covers the most common use case (user knows they want Camino Frances, just needs to pick start/end)
- The `RoutePathFinder` service is built with the graph structure but only returns depth-0 paths
- Establishes the screen structure, navigation, and state management

**Complexity:** Simple

### Phase 2: Multi-route via 1 junction

**What ships:**
- BFS with max depth 2 (one junction change)
- Junction city shown on option cards
- Reachability badges on destination search
- Route graph fully operational

**Why this boundary:**
- Single-junction paths cover the vast majority of practical multi-route combinations
- Keeps the results list manageable (not flooded with obscure 3-route chains)

**Complexity:** Medium

### Phase 3: Multi-route via 2+ junctions + distance estimates

**What ships:**
- BFS max depth raised to 3
- Distance estimates on each option card (requires loading route points)
- Stage count estimates
- Mini route preview (optional -- colored polyline segments on a small static map)

**Complexity:** Medium

### Future possibilities (not scoped)

- **Popular route combos:** Curated "most walked" multi-route combinations, promoted to the top of results
- **Community recommendations:** "87% of pilgrims who started in Porto walked this route"
- **Time estimates:** Based on average walking speed + stage data
- **Accommodation density:** Show which route options have more albergue coverage
- **Reverse direction support:** Some routes can be walked in both directions
- **Saved journeys:** Remember previously computed journeys for quick re-access

---

## 8. Technical Risks and Considerations

### 8.1 City name ambiguity

**Risk:** The city "Sarria" exists on multiple routes. If the user searches "Sarria" and picks it, which route context do we use?

**Mitigation:** Cities are identified by ID, not name. The `city_routes` table maps each city ID to its route IDs. When the user selects a city, we store the `cityId` and look up its `routeIds` from `cityRouteMap`. The path finder explores all route combinations. No ambiguity.

**UI note:** The city search results must show which route(s) each city belongs to, so the user understands what they are selecting.

### 8.2 Performance of path finding

**Risk:** With many routes and high junction connectivity, BFS could explore too many paths.

**Mitigation:**
- Max depth of 3 limits the search space to O(R^3) where R is the number of routes (~20-30). Worst case: ~27,000 path candidates -- trivial for modern devices.
- City ordering validation quickly eliminates invalid paths without expensive computation.
- Distance estimation is deferred until the user views results, and only computed for valid paths.

### 8.3 Very long multi-route paths

**Risk:** A 3-route path could span 1500+ km. Is this useful to show?

**Mitigation:** Do not filter by distance -- let the user decide. But sort shorter paths higher. In Phase 3, showing distance estimates makes this self-evident.

### 8.4 Integration with existing plan creation flow

**Risk:** The `AddEditStageScreen` expects a `MultiRouteTrail` from the trail builder. Will it work with a journey planner output?

**Mitigation:** The journey planner produces the exact same `MultiRouteTrail` object. The `TrailSegmentDescriptor` format is identical. The `AddEditStageScreen` does not know or care how the trail was built -- it just receives a trail and creates stages from it. This is the key architectural advantage of reusing the existing model.

### 8.5 Data freshness

**Risk:** The route graph is built from locally cached data. If the user has not synced recently, the graph might be stale.

**Mitigation:** The graph is rebuilt every time the journey planner opens (it is cheap to compute). If the local DB is up to date (which happens on app launch via the data sync mechanism), the graph is accurate. No additional sync logic needed.

### 8.6 Overlapping routes

**Risk:** Some routes share long stretches of cities (e.g., two Portugues variants). The path finder might suggest switching between them at every shared city, flooding results with near-identical options.

**Mitigation:** Apply the same "divergence check" from `JunctionService` (the filter on lines 129-137 that skips cities where routes still share the next city). This ensures junction suggestions only appear at true divergence points. For Phase 1 (direct routes only), this is not relevant. For Phase 2+, this filter should be part of graph construction.

### 8.7 Walking direction

**Risk:** Routes have a canonical direction (ordered by `order_key`). A junction city might be reachable going backward on a route.

**Mitigation:** The city ordering validation (Section 3.2, Step 3) explicitly checks that all cities appear in forward order within each route segment. Backward walks are excluded from results.

---

## 9. Localization

All user-facing strings must be added to the ARB files (`lib/l10n/arb/`). Key strings needed:

| Key | English value |
|---|---|
| `planTypeJourneyTitle` | Plan a Journey |
| `planTypeJourneySubtitle` | Pick a start and destination, we'll suggest routes |
| `journeyStartCityTitle` | Starting city |
| `journeyDestCityTitle` | Destination city |
| `journeyCitySearchHint` | Search for a city by name |
| `journeyRouteOptionsTitle` | Route options |
| `journeyDirectRoute` | Direct route |
| `journeyViaJunction` | Via {junctionCity} |
| `journeyViaJunctions` | Via {city1} and {city2} |
| `journeyNoRoutes` | No routes found between these cities |
| `journeyNoRoutesHint` | Try the Custom Trail builder for more flexibility |
| `journeyCities` | {count} cities |
| `journeyJunctions` | {count} junction(s) |
| `journeySameCity` | Start and destination must be different cities |
| `journeyNotReachable` | Not reachable from {startCity} |
| `journeyReachableDirect` | Direct |
| `journeyReachableViaJunction` | Via junction |

---

## 10. Analytics Events

| Event | Parameters | When |
|---|---|---|
| `journey_planner_opened` | -- | User enters the journey planner |
| `journey_start_city_selected` | `city_id`, `city_name`, `route_count` | User picks a starting city |
| `journey_dest_city_selected` | `city_id`, `city_name`, `route_count` | User picks a destination city |
| `journey_routes_found` | `count`, `has_direct`, `max_junctions` | Route options computed |
| `journey_no_routes` | `start_city_id`, `end_city_id` | No paths found |
| `journey_option_selected` | `route_count`, `junction_count`, `estimated_km` | User picks a route option |
| `journey_plan_created` | `plan_id`, `route_count` | Plan successfully created |

---

## 11. Acceptance Criteria

### Phase 1 (MVP)

- [ ] "Plan a Journey" appears as a third option in the plan type choice sheet
- [ ] User can search for a starting city across all routes
- [ ] User can search for a destination city across all routes
- [ ] App shows all direct (same-route) options between start and end
- [ ] User can select an option and it creates a plan via the existing flow
- [ ] "No routes found" empty state works correctly
- [ ] Same city for start and end is rejected
- [ ] Walking direction is enforced (no backward paths)
- [ ] All strings are localized in all 20 supported languages

### Phase 2

- [ ] Multi-route options via 1 junction are discovered and shown
- [ ] Destination search shows reachability badges
- [ ] Junction city names appear on multi-route option cards
- [ ] Route colors are shown on option cards
- [ ] Overlapping route stretches are handled (divergence filter)

### Phase 3

- [ ] Multi-route options via 2 junctions are supported
- [ ] Distance estimates shown on each option card
- [ ] City/stage count estimates shown
- [ ] Results remain fast (< 2 seconds on a mid-range device)
