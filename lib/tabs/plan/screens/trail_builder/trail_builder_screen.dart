import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/select_starting_point_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/widgets/junction_decision_card.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/widgets/junction_mini_graph.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/widgets/trail_flow_diagram.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/widgets/trail_preview_map.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_route/cubit/select_route_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class TrailBuilderScreenArguments {
  const TrailBuilderScreenArguments({this.planName});
  final String? planName;
}

/// Screen that guides the user through building a custom
/// multi-route trail by choosing routes at junction cities.
///
/// Returns a [MultiRouteTrail] when confirmed, or null
/// when cancelled.
class TrailBuilderScreen extends StatefulWidget {
  const TrailBuilderScreen({
    this.arguments,
    super.key,
  });

  final TrailBuilderScreenArguments? arguments;

  @override
  State<TrailBuilderScreen> createState() => _TrailBuilderScreenState();
}

class _TrailBuilderScreenState extends State<TrailBuilderScreen> {
  static const _graphHeight = 280.0;

  late final TrailBuilderCubit _cubit;

  /// Junction city names collected as the user makes
  /// decisions, used by [TrailFlowDiagram] to label the
  /// dots between segment chips.
  final Map<int, String> _junctionCityNames = {};

  /// Whether the user has toggled to map view.
  /// Persists across junction/complete phase transitions.
  bool _showMap = true;
  _TrailMapData? _currentMapData;

  @override
  void initState() {
    super.initState();
    _cubit = TrailBuilderCubit()..loadRoutes();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  bool _showHeader(TrailBuilderStatus status) {
    return status == TrailBuilderStatus.junction ||
        status == TrailBuilderStatus.complete;
  }

  void _invalidateMapData(TrailBuilderState state) {
    if (!_showMap) return;
    _computeMapData(state).then((data) {
      if (mounted) {
        setState(() => _currentMapData = data);
      }
    });
  }

  Future<_TrailMapData> _computeMapData(
    TrailBuilderState state,
  ) async {
    final routePoints = await _cubit.getTrailRoutePoints();
    final polylines = <TrailSegmentPolyline>[];

    for (final segment in state.segments) {
      final points = routePoints[segment.routeId];
      if (points == null || points.isEmpty) continue;
      final sliced = await _sliceSegmentPoints(
        cubit: _cubit,
        points: points,
        segment: segment,
      );
      polylines.add(
        TrailSegmentPolyline(
          points: sliced,
          color: Color(segment.colorValue),
        ),
      );
    }

    // In-progress segment (junction phase only)
    List<LatLng>? inProgressPoints;
    Color? inProgressColor;
    final currentRouteId = state.currentRouteId;
    final junction = state.currentJunction;
    if (currentRouteId != null && junction != null) {
      final points = routePoints[currentRouteId];
      if (points != null && points.isNotEmpty) {
        final startCityId = state.segmentStartCityId;
        var startIdx = 0;
        if (startCityId != null) {
          final city =
              await _cubit.resolveCityById(startCityId);
          if (city != null) {
            startIdx = MapUtil.findNearestPointIndex(
              points,
              city.latitude,
              city.longitude,
            );
          }
        }
        final endIdx = MapUtil.findNearestPointIndex(
          points,
          junction.city.latitude,
          junction.city.longitude,
        );
        final lo = startIdx < endIdx ? startIdx : endIdx;
        final hi = startIdx < endIdx ? endIdx : startIdx;
        inProgressPoints = points.sublist(lo, hi + 1);
        final route = state.routes.firstWhere(
          (r) => r.id == currentRouteId,
          orElse: () => RouteEntity(
            id: currentRouteId,
            orderKey: 0,
            routeName: '',
          ),
        );
        inProgressColor = Color(
          JunctionMiniGraph.parseColorValue(
            route,
            isDark: _cubit.isDark,
          ),
        );
      }
    }

    // Branch preview polylines (junction phase only)
    final branchPreviews = <TrailSegmentPolyline>[];
    if (junction != null) {
      final branchPoints =
          await _cubit.getBranchRoutePoints();
      final allBranchRoutes = <RouteEntity>[
        junction.currentRoute,
        ...junction.branchRoutes,
      ];
      for (final route in allBranchRoutes) {
        final pts = branchPoints[route.id];
        if (pts == null || pts.isEmpty) continue;
        final jIdx = MapUtil.findNearestPointIndex(
          pts,
          junction.city.latitude,
          junction.city.longitude,
        );
        if (jIdx >= pts.length - 1) continue;
        final color = Color(
          JunctionMiniGraph.parseColorValue(
            route,
            isDark: _cubit.isDark,
          ),
        );
        branchPreviews.add(
          TrailSegmentPolyline(
            points: pts.sublist(jIdx),
            color: color,
            routeName: route.routeName,
          ),
        );
      }
    }

    return _TrailMapData(
      polylines: polylines,
      inProgressPoints: inProgressPoints,
      inProgressColor: inProgressColor,
      junctionCity: junction?.city,
      branchPreviewPolylines: branchPreviews,
    );
  }

  Widget _buildMapView() {
    final data = _currentMapData;
    if (data == null) {
      return const Center(child: LoadingWidget());
    }
    return TrailPreviewMap(
      segmentPolylines: data.polylines,
      inProgressPoints: data.inProgressPoints,
      inProgressColor: data.inProgressColor,
      junctionCity: data.junctionCity,
      branchPreviewPolylines:
          data.branchPreviewPolylines,
    );
  }

  Widget _buildHeader(TrailBuilderState state) {
    final isDark = context.isDarkMode;
    final headerColor =
        isDark ? AppColors.gray800 : Colors.white;
    final junction = state.currentJunction;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SizedBox(
        height: _graphHeight,
        child: _showMap
            ? _buildMapView()
            : (junction != null
                ? JunctionMiniGraph(
                    graphData:
                        state.junctionGraphData,
                    junctionInfo: junction,
                  )
                : const SizedBox.shrink()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _cubit.isDark = context.isDarkMode;
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<TrailBuilderCubit, TrailBuilderState>(
        listenWhen: (prev, curr) =>
            prev.currentJunction != curr.currentJunction ||
            prev.status != curr.status,
        listener: (context, state) {
          final junction = state.currentJunction;
          if (junction != null) {
            _junctionCityNames[junction.city.id] = junction.city.name;
          }
          if (_showHeader(state.status)) {
            _invalidateMapData(state);
          }
        },
        child: BlocBuilder<TrailBuilderCubit, TrailBuilderState>(
          builder: (context, state) {
            final hasHeader = _showHeader(state.status);
            return Scaffold(
              appBar: CaminoNinjaAppBar(
                title: _appBarTitle(state.status),
                backgroundColor: hasHeader
                    ? (context.isDarkMode
                        ? AppColors.gray800
                        : Colors.white)
                    : null,
                onBackTap: state.status ==
                        TrailBuilderStatus.citySelection
                    ? _cubit.backToRouteSelection
                    : null,
                actions: [
                  if (state.status ==
                          TrailBuilderStatus.junction &&
                      _cubit.canUndo)
                    IconButton(
                      onPressed: _cubit.undoLastDecision,
                      icon: Icon(
                        Icons.history_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                      tooltip: 'Undo',
                    ),
                ],
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    if (hasHeader) _buildHeader(state),
                    Expanded(
                      child: _buildBody(context, state),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _appBarTitle(TrailBuilderStatus status) {
    // TODO(l10n): all title strings
    return switch (status) {
      TrailBuilderStatus.routeSelection =>
        'Choose Starting Route',
      TrailBuilderStatus.citySelection =>
        'Choose Starting City',
      TrailBuilderStatus.junction => 'Trail Junction',
      TrailBuilderStatus.complete => 'Trail Summary',
      _ => 'Build Custom Trail',
    };
  }

  Widget _buildBody(
    BuildContext context,
    TrailBuilderState state,
  ) {
    return switch (state.status) {
      TrailBuilderStatus.initial ||
      TrailBuilderStatus.loading =>
        const Center(child: LoadingWidget()),
      TrailBuilderStatus.routeSelection => _RouteSelectionBody(
          routes: state.routes,
          onRouteSelected: _cubit.selectStartingRoute,
        ),
      TrailBuilderStatus.citySelection => _CitySelectionBody(
          cities: state.routeCities,
          onCitySelected: _cubit.selectStartingCity,
        ),
      TrailBuilderStatus.junction => _JunctionBody(
          state: state,
          junctionCityNames: _junctionCityNames,
          cubit: _cubit,
        ),
      TrailBuilderStatus.complete => _CompleteBody(
          state: state,
          junctionCityNames: _junctionCityNames,
          cubit: _cubit,
          onConfirm: () {
            final trail = _cubit.buildTrail();
            context.pop(trail);
          },
          onReset: _cubit.reset,
        ),
      TrailBuilderStatus.failure => _FailureBody(
          onRetry: _cubit.loadRoutes,
        ),
    };
  }
}

// ── Route Selection Phase ────────────────────────────────

class _RouteSelectionBody extends StatefulWidget {
  const _RouteSelectionBody({
    required this.routes,
    required this.onRouteSelected,
  });

  final List<RouteEntity> routes;
  final void Function(int routeId) onRouteSelected;

  @override
  State<_RouteSelectionBody> createState() => _RouteSelectionBodyState();
}

class _RouteSelectionBodyState extends State<_RouteSelectionBody> {
  late SelectRouteCubit _selectRouteCubit;

  @override
  void initState() {
    super.initState();
    _selectRouteCubit = SelectRouteCubit()..fetchRoutes(null);
  }

  @override
  void dispose() {
    _selectRouteCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider.value(
      value: _selectRouteCubit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              0,
            ),
            child: Text(
              // TODO(l10n): choose starting route header
              'Choose your starting route',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          BlocBuilder<SelectRouteCubit, SelectRouteState>(
            builder: (context, state) {
              if (state.initStatus == SelectRouteInitStatus.loading) {
                return const Expanded(
                  child: Center(child: LoadingWidget()),
                );
              }

              return Expanded(
                child: Column(
                  children: [
                    SearchField(
                      enableDebouncer: true,
                      onChanged: _selectRouteCubit.searchRoutes,
                    ),
                    Expanded(
                      child: _buildRouteList(
                        context,
                        state,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRouteList(
    BuildContext context,
    SelectRouteState state,
  ) {
    if (state.filteredRoutes.isEmpty) {
      return const EmplyStateWidget();
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: state.filteredRoutes.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 24,
        endIndent: 24,
      ),
      itemBuilder: (context, index) {
        final routeData = state.filteredRoutes[index];
        return _RoutePickerTile(
          routeData: routeData,
          onTap: () => widget.onRouteSelected(
            routeData.routeId,
          ),
        );
      },
    );
  }
}

/// A simplified route list item for the trail builder
/// route selection phase.
class _RoutePickerTile extends StatelessWidget {
  const _RoutePickerTile({
    required this.routeData,
    required this.onTap,
  });

  final RouteDistanceElevation routeData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final routeColor = parseRouteColor(
      routeData.route,
      isDark: isDark,
    );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: routeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    routeData.routeName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primary80 : AppColors.primary40,
                    ),
                  ),
                  if (routeData.routeSubName?.isNotEmpty ?? false)
                    Text(
                      routeData.routeSubName!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

}

// ── City Selection Phase ─────────────────────────────────

class _CitySelectionBody extends StatefulWidget {
  const _CitySelectionBody({
    required this.cities,
    required this.onCitySelected,
  });

  final List<CityEntity> cities;
  final void Function(int cityId) onCitySelected;

  @override
  State<_CitySelectionBody> createState() =>
      _CitySelectionBodyState();
}

class _CitySelectionBodyState
    extends State<_CitySelectionBody> {
  String _query = '';

  List<CityEntity> get _filteredCities {
    if (_query.isEmpty) return widget.cities;
    final lower = _query.toLowerCase();
    return widget.cities
        .where(
          (c) => c.name.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final filteredCities = _filteredCities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            0,
          ),
          child: Text(
            // TODO(l10n): choose starting city header
            'Where do you want to start?',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SearchField(
          enableDebouncer: true,
          onChanged: (value) => setState(
            () => _query = value,
          ),
        ),
        Expanded(
          child: filteredCities.isEmpty
              ? const EmplyStateWidget()
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                  ),
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    return Column(
                      children: [
                        StartingPointListItem(
                          name: city.name,
                          onClick: () =>
                              widget.onCitySelected(
                            city.id,
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Junction Phase ───────────────────────────────────────

/// Junction body — trail-so-far card, junction labels,
/// and decision cards. Header (graph/map) is managed by
/// the parent [_TrailBuilderScreenState].
class _JunctionBody extends StatelessWidget {
  const _JunctionBody({
    required this.state,
    required this.junctionCityNames,
    required this.cubit,
  });

  final TrailBuilderState state;
  final Map<int, String> junctionCityNames;
  final TrailBuilderCubit cubit;

  @override
  Widget build(BuildContext context) {
    final junction = state.currentJunction;
    if (junction == null) {
      return const Center(child: LoadingWidget());
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: _TrailSoFarCard(
            segments: state.segments,
            currentRoute: junction.currentRoute,
            junctionCityNames: junctionCityNames,
            currentJunctionCityName:
                junction.city.name,
          ),
        ),
        const SizedBox(height: 8),
        _JunctionLabels(
          cityName: junction.city.name,
          routeName: junction.currentRoute.routeName,
          routeColor: Color(
            JunctionMiniGraph.parseColorValue(
              junction.currentRoute,
              isDark: context.isDarkMode,
            ),
          ),
        ),
        const SizedBox(height: 16),
        JunctionDecisionCard(
          junctionInfo: junction,
          onContinue: cubit.continueOnRoute,
          onSwitchToRoute: cubit.switchToRoute,
          onEndTrail: cubit.endTrailHere,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Displays the trail segments built so far as a
/// horizontal scrollable row of colored route chips
/// with junction city names between them.
class _TrailSoFarCard extends StatelessWidget {
  const _TrailSoFarCard({
    required this.segments,
    required this.currentRoute,
    required this.junctionCityNames,
    this.currentJunctionCityName,
  });

  final List<TrailSegment> segments;
  final RouteEntity currentRoute;
  final Map<int, String> junctionCityNames;

  /// The city name of the current junction, shown as
  /// separator between the last segment and current route.
  final String? currentJunctionCityName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            // TODO(l10n): trail so far
            'Trail so far',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildChips(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteChip(
    BuildContext context, {
    required String name,
    required Color color,
  }) {
    final textTheme = context.textTheme;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: color.withAlpha(153),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.primary90
                  : AppColors.primary10,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;
    final chips = <Widget>[];

    // Past segments
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        // Junction city name between segment chips
        _addSeparator(
          chips,
          cityId: segments[i].junctionCityId,
          textTheme: textTheme,
          colorScheme: colorScheme,
        );
      }

      final segment = segments[i];
      chips.add(
        _buildRouteChip(
          context,
          name: segment.routeName,
          color: Color(segment.colorValue),
        ),
      );
    }

    // Separator before current route (if segments exist)
    if (segments.isNotEmpty) {
      final name = currentJunctionCityName;
      if (name != null && name.isNotEmpty) {
        chips.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
            ),
            child: Text(
              name,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        );
      } else {
        chips.add(
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }
    }

    // Current route — always shown as last chip
    chips.add(
      _buildRouteChip(
        context,
        name: currentRoute.routeName,
        color: Color(
          JunctionMiniGraph.parseColorValue(
            currentRoute,
            isDark: context.isDarkMode,
          ),
        ),
      ),
    );

    return chips;
  }

  void _addSeparator(
    List<Widget> chips, {
    required int? cityId,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    final name =
        cityId != null ? junctionCityNames[cityId] : null;
    if (name != null && name.isNotEmpty) {
      chips.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          child: Text(
            name,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ),
      );
    } else {
      chips.add(
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }
  }
}


/// Junction labels showing "Junction", city name, and
/// the current route subtitle.
class _JunctionLabels extends StatelessWidget {
  const _JunctionLabels({
    required this.cityName,
    required this.routeName,
    required this.routeColor,
  });

  final String cityName;
  final String routeName;
  final Color routeColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDarkMode;

    return Column(
      children: [
        // "Junction" label
        Text(
          // TODO(l10n): junction label
          'Junction',
          style: textTheme.labelMedium?.copyWith(
            color: isDark
                ? AppColors.primary60
                : colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        // City name
        Text(
          cityName,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // "Still on [route]"
        Text(
          // TODO(l10n): still on route
          'Still on $routeName',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Complete Phase ───────────────────────────────────────

class _CompleteBody extends StatelessWidget {
  const _CompleteBody({
    required this.state,
    required this.junctionCityNames,
    required this.cubit,
    required this.onConfirm,
    required this.onReset,
  });

  final TrailBuilderState state;
  final Map<int, String> junctionCityNames;
  final TrailBuilderCubit cubit;
  final VoidCallback onConfirm;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TrailFlowDiagram(
                segments: state.segments,
                junctionCityNames: junctionCityNames,
              ),
              const SizedBox(height: 24),
              Text(
                // TODO(l10n): segment breakdown header
                'Segment Breakdown',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...state.segments.asMap().entries.map(
                    (entry) => _SegmentSummaryTile(
                      index: entry.key,
                      segment: entry.value,
                    ),
                  ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: onReset,
                  child: Text(
                    // TODO(l10n): start over
                    'Start over',
                    style:
                        textTheme.labelLarge?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _ConfirmButton(onConfirm: onConfirm),
      ],
    );
  }
}

class _SegmentSummaryTile extends StatelessWidget {
  const _SegmentSummaryTile({
    required this.index,
    required this.segment,
  });

  final int index;
  final TrailSegment segment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;
    final isDark = context.isDarkMode;

    final routeColor = Color(segment.colorValue);
    final cityCount = segment.cityIds.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: routeColor.withAlpha(15),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: routeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    segment.routeName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.primary90 : AppColors.primary10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    // TODO(l10n): city count
                    '$cityCount '
                    '${cityCount == 1 ? 'city' : 'cities'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _SegmentIndexBadge(index: index + 1),
          ],
        ),
      ),
    );
  }
}

class _SegmentIndexBadge extends StatelessWidget {
  const _SegmentIndexBadge({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$index',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: onConfirm,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          // TODO(l10n): confirm and continue
          'Confirm & continue',
        ),
      ),
    );
  }
}

// ── Trail Map Helpers ────────────────────────────────────

class _TrailMapData {
  const _TrailMapData({
    required this.polylines,
    this.inProgressPoints,
    this.inProgressColor,
    this.junctionCity,
    this.branchPreviewPolylines,
  });

  final List<TrailSegmentPolyline> polylines;
  final List<LatLng>? inProgressPoints;
  final Color? inProgressColor;
  final CityEntity? junctionCity;
  final List<TrailSegmentPolyline>? branchPreviewPolylines;
}

/// Slices the full route points to cover only the cities
/// in a finalized [TrailSegment].
Future<List<LatLng>> _sliceSegmentPoints({
  required TrailBuilderCubit cubit,
  required List<LatLng> points,
  required TrailSegment segment,
}) async {
  if (segment.cityIds.isEmpty || points.isEmpty) {
    return points;
  }

  final firstCity =
      await cubit.resolveCityById(segment.cityIds.first);
  final lastCity =
      await cubit.resolveCityById(segment.cityIds.last);

  if (firstCity == null || lastCity == null) return points;

  final startIdx = MapUtil.findNearestPointIndex(
    points,
    firstCity.latitude,
    firstCity.longitude,
  );
  final endIdx = MapUtil.findNearestPointIndex(
    points,
    lastCity.latitude,
    lastCity.longitude,
  );

  final lo = startIdx < endIdx ? startIdx : endIdx;
  final hi = startIdx < endIdx ? endIdx : startIdx;
  return points.sublist(lo, hi + 1);
}

class _MapToggleButton extends StatelessWidget {
  const _MapToggleButton({
    required this.showMap,
    required this.onToggle,
  });

  final bool showMap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh.withAlpha(204),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onToggle,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            showMap
                ? Icons.account_tree_outlined
                : Icons.map_outlined,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Failure Phase ────────────────────────────────────────

class _FailureBody extends StatelessWidget {
  const _FailureBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              // TODO(l10n): error loading
              'Something went wrong',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              // TODO(l10n): error description
              'Could not load route data. '
              'Please try again.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text(
                // TODO(l10n): retry
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
