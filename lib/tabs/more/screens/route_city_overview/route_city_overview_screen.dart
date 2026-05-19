import 'dart:async';

import 'package:camino_ninja_flutter/mapbox/mapbox.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/route_city_overview/cubit/route_city_overview_cubit.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

class RouteCityOverviewScreen extends StatelessWidget {
  const RouteCityOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteCityOverviewCubit()..loadRoutes(),
      child: Scaffold(
        appBar: const CaminoNinjaAppBar(
          title: 'Route City Overview',
        ),
        body: BlocBuilder<RouteCityOverviewCubit,
            RouteCityOverviewState>(
          builder: (context, state) {
            if (state.status ==
                    RouteCityOverviewStatus.loading &&
                state.routes.isEmpty) {
              return const Center(child: LoadingWidget());
            }
            if (state.status ==
                RouteCityOverviewStatus.failure) {
              return const Center(
                child: Text('Failed to load data'),
              );
            }
            return _Body(state: state);
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final RouteCityOverviewState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _RouteDropdown(
          routes: state.routes,
          selectedRouteId: state.selectedRouteId,
        ),
        if (state.selectedRouteId == null)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Select a route to see its cities',
              ),
            ),
          )
        else ...[
          for (var i = 0; i < state.segments.length; i++)
            _SegmentSection(
              segment: state.segments[i],
              isActive: i == state.segments.length - 1,
            ),

          if (state.status ==
              RouteCityOverviewStatus.loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            ),

          // Ending destination + map + action buttons.
          if (state.status ==
                  RouteCityOverviewStatus.success &&
              state.segments.isNotEmpty) ...[
            if (state.segments.last.visibleEntries
                .isNotEmpty)
              _EndDestination(
                city: state.segments.last.visibleEntries
                    .last.city,
              ),
            const SizedBox(height: 12),
            _PathMapView(segments: state.segments),
            const SizedBox(height: 12),
            const _MakePlanButton(),
          ],

          if (state.segments.length > 1)
            _GoBackButton(
              onTap: () => context
                  .read<RouteCityOverviewCubit>()
                  .goBack(),
            ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
// Route dropdown
// ──────────────────────────────────────────────────────────

class _RouteDropdown extends StatelessWidget {
  const _RouteDropdown({
    required this.routes,
    required this.selectedRouteId,
  });

  final List<RouteEntity> routes;
  final int? selectedRouteId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: DropdownButtonFormField<int>(
        initialValue: selectedRouteId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Starting Route',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: routes
            .map(
              (r) => DropdownMenuItem<int>(
                value: r.id,
                child: Text(
                  r.routeSubName != null
                      ? '${r.routeName}'
                          ' (${r.routeSubName})'
                      : r.routeName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (routeId) {
          if (routeId != null) {
            context
                .read<RouteCityOverviewCubit>()
                .selectRoute(routeId);
          }
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Segment section — header + grouped city entries
// ──────────────────────────────────────────────────────────

class _SegmentSection extends StatelessWidget {
  const _SegmentSection({
    required this.segment,
    required this.isActive,
  });

  final OverviewSegment segment;

  /// True if this is the last (active) segment — only active
  /// segments show route buttons at junctions.
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final visible = segment.visibleEntries;
    final children = _buildGroupedChildren(visible);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SegmentHeader(segment: segment),
        // Indent the city list under the header.
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  /// Groups entries into junction rows and collapsible
  /// plain-city groups.
  List<Widget> _buildGroupedChildren(
    List<CityOverviewEntry> entries,
  ) {
    final widgets = <Widget>[];
    var plainBuffer = <CityEntity>[];

    void flushPlainBuffer() {
      if (plainBuffer.isEmpty) return;
      if (plainBuffer.length == 1) {
        widgets.add(_PlainCityRow(city: plainBuffer.first));
      } else {
        widgets.add(
          _CollapsibleCityGroup(
            key: ValueKey(
              '${segment.routeId}_${plainBuffer.first.id}',
            ),
            cities: List.of(plainBuffer),
          ),
        );
      }
      plainBuffer = <CityEntity>[];
    }

    for (final entry in entries) {
      if (entry.isJunction) {
        flushPlainBuffer();
        widgets.add(
          _JunctionCityRow(
            entry: entry,
            showRoutes: isActive,
          ),
        );
      } else {
        plainBuffer.add(entry.city);
      }
    }
    flushPlainBuffer();

    return widgets;
  }
}

// ──────────────────────────────────────────────────────────
// Segment header — route name with colored indicator
// ──────────────────────────────────────────────────────────

class _SegmentHeader extends StatelessWidget {
  const _SegmentHeader({required this.segment});

  final OverviewSegment segment;

  @override
  Widget build(BuildContext context) {
    final label = segment.routeSubName != null
        ? '${segment.routeName} (${segment.routeSubName})'
        : segment.routeName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: segment.routeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: segment.routeColor,
              ),
            ),
          ),
          Text(
            '${segment.visibleEntries.length} cities',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Plain city row — non-junction city
// ──────────────────────────────────────────────────────────

class _PlainCityRow extends StatelessWidget {
  const _PlainCityRow({required this.city});

  final CityEntity city;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 16,
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context)
                  .colorScheme
                  .outline
                  .withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              city.name,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Collapsible group of consecutive plain cities
// ──────────────────────────────────────────────────────────

class _CollapsibleCityGroup extends StatefulWidget {
  const _CollapsibleCityGroup({
    required this.cities,
    super.key,
  });

  final List<CityEntity> cities;

  @override
  State<_CollapsibleCityGroup> createState() =>
      _CollapsibleCityGroupState();
}

class _CollapsibleCityGroupState
    extends State<_CollapsibleCityGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cities = widget.cities;
    final muted = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: 0.45);

    if (_expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final city in cities)
            _PlainCityRow(city: city),
          GestureDetector(
            onTap: () => setState(() => _expanded = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.expand_less,
                    size: 16,
                    color: muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Collapse',
                    style: TextStyle(
                      fontSize: 12,
                      color: muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _expanded = true),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        child: Row(
          children: [
            Icon(Icons.more_vert, size: 16, color: muted),
            const SizedBox(width: 4),
            Text(
              '${cities.length} cities',
              style: TextStyle(
                fontSize: 12,
                color: muted,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: muted,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Junction city row — city name + always-visible route buttons
// ──────────────────────────────────────────────────────────

class _JunctionCityRow extends StatelessWidget {
  const _JunctionCityRow({
    required this.entry,
    required this.showRoutes,
  });

  final CityOverviewEntry entry;

  /// False for split (past) segments — hides route buttons.
  final bool showRoutes;

  @override
  Widget build(BuildContext context) {
    final available = showRoutes
        ? entry.junctionRoutes
        : <RouteEntity>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // City name with junction icon.
            Row(
              children: [
                Icon(
                  Icons.fork_right,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry.city.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface,
                    ),
                  ),
                ),
              ],
            ),

            if (available.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Split to:',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 6),
              for (final item
                  in available.asMap().entries)
                _RouteSplitButton(
                  route: item.value,
                  index: item.key,
                  junctionCityId: entry.city.id,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Route split button — prominent, obviously tappable
// ──────────────────────────────────────────────────────────

class _RouteSplitButton extends StatelessWidget {
  const _RouteSplitButton({
    required this.route,
    required this.index,
    required this.junctionCityId,
  });

  final RouteEntity route;
  final int index;
  final int junctionCityId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RouteCityOverviewCubit>();
    final color = cubit.routeColor(route, index);
    final label = route.routeSubName != null
        ? '${route.routeName} (${route.routeSubName})'
        : route.routeName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => cubit.splitToRoute(
            junctionCityId: junctionCityId,
            newRouteId: route.id,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Path map — multi-colored polyline for each segment
// ──────────────────────────────────────────────────────────

class _PathMapView extends StatefulWidget {
  const _PathMapView({required this.segments});

  final List<OverviewSegment> segments;

  @override
  State<_PathMapView> createState() => _PathMapViewState();
}

class _PathMapViewState extends State<_PathMapView>
    with MapboxHostMixin {
  MapboxMap? _map;
  bool _mapReady = false;
  bool _styleLoaded = false;
  bool _wasDark = false;

  final PolylineDelegate _polylineDelegate = PolylineDelegate();
  late GestureDelegate _gestureDelegate;

  @override
  MapboxMap? get hostMap => _map;

  @override
  void initState() {
    super.initState();
    _gestureDelegate = const GestureDelegate(locationEnabled: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = context.isDarkMode;
    if (_mapReady && isDark != _wasDark) {
      _wasDark = isDark;
      unawaited(
        swapStyle(
          isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
        ),
      );
    }
  }

  @override
  void didUpdateWidget(_PathMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_styleLoaded && oldWidget.segments != widget.segments) {
      unawaited(_redraw());
    }
  }

  @override
  void dispose() {
    disposeHost();
    _mapReady = false;
    _styleLoaded = false;
    unawaited(_polylineDelegate.clear().catchError((_) {}));
    _polylineDelegate.resetForStyleReload();
    _map = null;
    super.dispose();
  }

  /// Trims route points to the visible city range.
  /// For split segments, finds the exact route point at
  /// the last visible city and cuts there. Falls back to
  /// coordinate proximity if the ID match fails.
  List<RoutePointEntity> _visibleRoutePoints(
    OverviewSegment segment,
  ) {
    final points = segment.routePoints;
    if (points.isEmpty ||
        segment.splitAtCityId == null ||
        segment.visibleEntries.isEmpty) {
      return points;
    }
    final lastCity = segment.visibleEntries.last.city;
    final segmentRouteId = segment.routeId;

    // Try exact match via the city's route point ID.
    var trimIdx = -1;
    if (lastCity.routePoints.isNotEmpty) {
      final cityRoutePoint =
          lastCity.routePoints.cast<RoutePointEntity?>().firstWhere(
                (rp) => rp!.routeId == segmentRouteId,
                orElse: () => null,
              );
      if (cityRoutePoint != null) {
        trimIdx = points.indexWhere(
          (p) => p.id == cityRoutePoint.id,
        );
      }
    }

    // Fall back to coordinate proximity if ID not found.
    if (trimIdx < 0) {
      var closestDist = double.infinity;
      for (var j = 0; j < points.length; j++) {
        final dx = points[j].latitude - lastCity.latitude;
        final dy = points[j].longitude - lastCity.longitude;
        final dist = dx * dx + dy * dy;
        if (dist < closestDist) {
          closestDist = dist;
          trimIdx = j;
        }
      }
    }

    return points.sublist(0, trimIdx + 1);
  }

  List<LatLng> _allPoints() {
    return widget.segments
        .expand(
          (s) => MapUtil.getLatLngsFromRoutePoints(
            _visibleRoutePoints(s),
          ),
        )
        .toList();
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    if (disposed) return;
    _map = map;
    _wasDark = context.isDarkMode;
    setInitialStyleUri(
      _wasDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
    );
    await _gestureDelegate.apply(map);
    _mapReady = true;
  }

  Future<void> _onStyleLoaded() async {
    if (disposed || !_mapReady) return;
    final map = _map;
    if (map == null) return;
    _polylineDelegate.resetForStyleReload();
    await _polylineDelegate.initialize(map.annotations);
    _styleLoaded = true;
    await _redraw();
  }

  Future<void> _redraw() async {
    if (disposed) return;
    await _syncPolylines();
    await _fitBounds();
  }

  Future<void> _syncPolylines() async {
    final manager = _polylineDelegate.manager;
    if (manager == null) return;
    await _polylineDelegate.clear();
    for (var i = 0; i < widget.segments.length; i++) {
      final segment = widget.segments[i];
      final visible = _visibleRoutePoints(segment);
      if (visible.isEmpty) continue;
      final coords = visible
          .map((p) => Position(p.longitude, p.latitude))
          .toList();
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: segment.routeColor.toARGB32(),
          lineWidth: 4,
        ),
      );
    }
  }

  Future<void> _fitBounds() async {
    final points = _allPoints();
    if (points.isEmpty) return;
    await MapUtil.fitBounds(
      mapController: _map,
      points: points,
      zoomConstant: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPts = _allPoints();
    if (allPts.isEmpty) return const SizedBox.shrink();

    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 300,
          child: GestureDetector(
            onVerticalDragStart: (_) {},
            child: MapWidget(
              styleUri:
                  isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(
                    allPts.first.longitude,
                    allPts.first.latitude,
                  ),
                ),
                zoom: 6,
              ),
              onMapCreated: _onMapCreated,
              onStyleLoadedListener: (_) => _onStyleLoaded(),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// End destination indicator
// ──────────────────────────────────────────────────────────

class _EndDestination extends StatelessWidget {
  const _EndDestination({required this.city});

  final CityEntity city;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .tertiaryContainer
              .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .tertiary
                .withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.flag,
              size: 20,
              color:
                  Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destination',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    city.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Make plan placeholder button
// ──────────────────────────────────────────────────────────

class _MakePlanButton extends StatelessWidget {
  const _MakePlanButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.map_outlined, size: 18),
        label: const Text('Make plan based on this'),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Go back button
// ──────────────────────────────────────────────────────────

class _GoBackButton extends StatelessWidget {
  const _GoBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.undo, size: 16),
        label: const Text('Undo last split'),
      ),
    );
  }
}
