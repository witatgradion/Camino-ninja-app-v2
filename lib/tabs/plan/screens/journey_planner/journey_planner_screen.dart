import 'dart:async';

import 'package:camino_ninja_flutter/mapbox/mapbox.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/journey_planner/cubit/journey_planner_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class JourneyPlannerScreenArguments {
  const JourneyPlannerScreenArguments({this.planName});
  final String? planName;
}

// Prototype: handpicked popular cities (replace with
// CMS-driven IDs later). Matched case-insensitively on
// `CityEntity.name`.
const Set<String> _popularCityNames = {
  'sarria',
  'roncesvalles',
  'león',
};

bool _isPopularCity(CityEntity city) {
  return _popularCityNames.contains(city.name.toLowerCase());
}

/// Screen that guides the user through picking a start
/// city and destination city, then shows route options
/// for the journey between them.
///
/// Returns a [MultiRouteTrail] when a journey option is
/// confirmed, or null when cancelled.
class JourneyPlannerScreen extends StatefulWidget {
  const JourneyPlannerScreen({
    this.arguments,
    super.key,
  });

  final JourneyPlannerScreenArguments? arguments;

  @override
  State<JourneyPlannerScreen> createState() => _JourneyPlannerScreenState();
}

class _JourneyPlannerScreenState extends State<JourneyPlannerScreen> {
  late final JourneyPlannerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = JourneyPlannerCubit()..init();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _appBarTitle(JourneyPlannerStatus status) {
    // TODO(l10n): all title strings
    return switch (status) {
      JourneyPlannerStatus.initial ||
      JourneyPlannerStatus.loadingCities =>
        'Plan a Journey',
      JourneyPlannerStatus.startCitySelection => 'Choose Start City',
      JourneyPlannerStatus.destinationCitySelection => 'Choose Destination',
      JourneyPlannerStatus.loadingRoutes => 'Finding Routes',
      JourneyPlannerStatus.routeOptions => 'Journey Options',
      JourneyPlannerStatus.failure => 'Plan a Journey',
    };
  }

  VoidCallback? _onBackTap(
    JourneyPlannerStatus status,
  ) {
    return switch (status) {
      JourneyPlannerStatus.destinationCitySelection => _cubit.backToStartCity,
      JourneyPlannerStatus.routeOptions => _cubit.backToDestination,
      _ => null,
    };
  }

  /// Progress through the two-step planner flow:
  /// 0.5 on start city selection, 1.0 once a start city
  /// has been picked. Null hides the bar (loading screens,
  /// the post-selection map, failure).
  double? _progressValue(JourneyPlannerStatus status) {
    return switch (status) {
      JourneyPlannerStatus.startCitySelection => 0.5,
      JourneyPlannerStatus.destinationCitySelection ||
      JourneyPlannerStatus.loadingRoutes =>
        1.0,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    _cubit.isDark = context.isDarkMode;
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<JourneyPlannerCubit, JourneyPlannerState>(
        builder: (context, state) {
          // Route options use an edge-to-edge map layout
          // with no AppBar. All other states use the
          // standard scaffold with AppBar.
          if (state.status == JourneyPlannerStatus.routeOptions) {
            return _buildBody(context, state);
          }
          final progress = _progressValue(state.status);
          return Scaffold(
            appBar: CaminoNinjaAppBar(
              title: _appBarTitle(state.status),
              onBackTap: _onBackTap(state.status),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Animated step indicator persists across
                  // state changes so the fill width tweens
                  // smoothly between pages.
                  SizedBox(
                    height: 3,
                    child: progress == null
                        ? const SizedBox.shrink()
                        : TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0,
                              end: progress,
                            ),
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOut,
                            builder: (context, value, _) {
                              return _JourneyStepIndicator(value: value);
                            },
                          ),
                  ),
                  Expanded(
                    child: _buildBody(context, state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    JourneyPlannerState state,
  ) {
    return switch (state.status) {
      JourneyPlannerStatus.initial ||
      JourneyPlannerStatus.loadingCities =>
        const Center(child: LoadingWidget()),
      JourneyPlannerStatus.startCitySelection => _CitySearchBody(
          cities: state.allCities,
          cityRouteNames: state.cityRouteNames,
          // TODO(l10n): header string
          headerText: 'Where do you start?',
          onCitySelected: _cubit.selectStartCity,
        ),
      JourneyPlannerStatus.destinationCitySelection =>
        _DestinationCitySearchBody(
          cities: state.allCities,
          cityRouteNames: state.cityRouteNames,
          state: state,
          onCitySelected: _cubit.selectDestinationCity,
          excludeCityId: state.startCity?.id,
        ),
      JourneyPlannerStatus.loadingRoutes =>
        const Center(child: LoadingWidget()),
      JourneyPlannerStatus.routeOptions => _RouteOptionsBody(
          state: state,
          onOptionSelected: _onOptionSelected,
          onBack: _cubit.backToDestination,
        ),
      JourneyPlannerStatus.failure => _FailureBody(onRetry: _cubit.reset),
    };
  }

  Future<void> _onOptionSelected(
    JourneyOption option,
  ) async {
    final trail = await _cubit.buildTrailFromOption(option);
    if (trail != null && mounted) {
      context.pop(trail);
    }
  }
}

// ── City Search Body ─────────────────────────────────

class _CitySearchBody extends StatefulWidget {
  const _CitySearchBody({
    required this.cities,
    required this.cityRouteNames,
    required this.headerText,
    required this.onCitySelected,
  });

  final List<CityEntity> cities;
  final Map<int, List<String>> cityRouteNames;
  final String headerText;
  final void Function(CityEntity city) onCitySelected;

  @override
  State<_CitySearchBody> createState() => _CitySearchBodyState();
}

class _CitySearchBodyState extends State<_CitySearchBody> {
  String _query = '';

  List<CityEntity> get _filteredCities {
    var cities = widget.cities;
    if (_query.isNotEmpty) {
      final lower = _query.toLowerCase();
      cities = cities
          .where(
            (c) => c.name.toLowerCase().contains(lower),
          )
          .toList();
    }
    // Popular cities first, then alphabetical.
    final sorted = [...cities]..sort((a, b) {
        final pa = _isPopularCity(a);
        final pb = _isPopularCity(b);
        if (pa != pb) return pa ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final filteredCities = _filteredCities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          enableDebouncer: true,
          onChanged: (value) => setState(
            () => _query = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            8,
          ),
          child: Text(
            widget.headerText,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: filteredCities.isEmpty
              ? const EmplyStateWidget()
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 24,
                  ),
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    final routeNames = widget.cityRouteNames[city.id];
                    return Column(
                      children: [
                        _CityListItem(
                          city: city,
                          routeNames: routeNames,
                          onTap: () => widget.onCitySelected(city),
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

// ── City List Item ───────────────────────────────────

class _CityListItem extends StatelessWidget {
  const _CityListItem({
    required this.city,
    required this.onTap,
    this.routeNames,
  });

  final CityEntity city;
  final VoidCallback onTap;
  final List<String>? routeNames;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final isPopular = _isPopularCity(city);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 24,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular) ...[
                    const _PopularBadge(),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    city.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.primary80
                          : AppColors.primary40,
                    ),
                  ),
                  if (routeNames != null && routeNames!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      routeNames!.join(', '),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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

// ── Destination City Search Body ─────────────────────

class _DestinationCitySearchBody extends StatefulWidget {
  const _DestinationCitySearchBody({
    required this.cities,
    required this.cityRouteNames,
    required this.state,
    required this.onCitySelected,
    this.excludeCityId,
  });

  final List<CityEntity> cities;
  final Map<int, List<String>> cityRouteNames;
  final JourneyPlannerState state;
  final void Function(CityEntity city) onCitySelected;
  final int? excludeCityId;

  @override
  State<_DestinationCitySearchBody> createState() =>
      _DestinationCitySearchBodyState();
}

class _DestinationCitySearchBodyState
    extends State<_DestinationCitySearchBody> {
  String _query = '';

  List<CityEntity> get _filteredCities {
    var cities = widget.cities;
    if (widget.excludeCityId != null) {
      cities = cities
          .where(
            (c) => c.id != widget.excludeCityId,
          )
          .toList();
    }
    if (_query.isNotEmpty) {
      final lower = _query.toLowerCase();
      cities = cities
          .where(
            (c) => c.name.toLowerCase().contains(lower),
          )
          .toList();
    }

    // Sort: reachability tier first (direct → via junction
    // → not reachable), then popular cities at the top of
    // each tier, then alphabetical.
    cities.sort((a, b) {
      final ra = widget.state.reachabilityOf(a.id);
      final rb = widget.state.reachabilityOf(b.id);
      final cmp = ra.index.compareTo(rb.index);
      if (cmp != 0) return cmp;
      final pa = _isPopularCity(a);
      final pb = _isPopularCity(b);
      if (pa != pb) return pa ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return cities;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filteredCities;

    final startCityName = widget.state.startCity?.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          enableDebouncer: true,
          onChanged: (value) => setState(
            () => _query = value,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            8,
          ),
          child: Text(
            // TODO(l10n): header string
            'Where are you going?',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (startCityName != null && startCityName.isNotEmpty)
          _StartCityPreview(cityName: startCityName),
        Expanded(
          child: filtered.isEmpty
              ? const EmplyStateWidget()
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 24,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final city = filtered[index];
                    // Prefer forward-walkable route names
                    // for reachable cities; fall back to
                    // all route names for unreachable
                    // ones (they're grayed out anyway).
                    final forwardNames =
                        widget.state.destinationRouteNames[city.id];
                    final routeNames =
                        forwardNames != null && forwardNames.isNotEmpty
                            ? forwardNames
                            : widget.cityRouteNames[city.id];
                    final reachability = widget.state.reachabilityOf(city.id);
                    final isReachable =
                        reachability != CityReachability.notReachable;
                    return Column(
                      children: [
                        _DestinationCityListItem(
                          city: city,
                          routeNames: routeNames,
                          reachability: reachability,
                          onTap: isReachable
                              ? () => widget.onCitySelected(city)
                              : null,
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

// ── Destination City List Item ───────────────────────

class _DestinationCityListItem extends StatelessWidget {
  const _DestinationCityListItem({
    required this.city,
    required this.reachability,
    this.routeNames,
    this.onTap,
  });

  final CityEntity city;
  final CityReachability reachability;
  final VoidCallback? onTap;
  final List<String>? routeNames;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = reachability == CityReachability.notReachable;

    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.45 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 24,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isPopularCity(city)) ...[
                      const _PopularBadge(),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            city.name,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDisabled
                                  ? colorScheme.onSurfaceVariant
                                  : isDark
                                      ? AppColors.primary80
                                      : AppColors.primary40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ReachabilityBadge(
                          reachability: reachability,
                        ),
                      ],
                    ),
                    if (routeNames != null && routeNames!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        routeNames!.join(', '),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (!isDisabled)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Popular Badge ────────────────────────────────────

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.yellow300,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        // TODO(l10n): popular badge
        'Popular',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ── Journey Step Indicator ───────────────────────────

/// Thin edge-to-edge progress bar showing where the user
/// is in the two-step journey planner flow. Renders a
/// concrete fill value; animation is driven by the parent
/// via TweenAnimationBuilder so the bar tweens smoothly
/// when the page transitions.
class _JourneyStepIndicator extends StatelessWidget {
  const _JourneyStepIndicator({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: 3,
      backgroundColor: colorScheme.surfaceContainerHighest,
      valueColor: AlwaysStoppedAnimation<Color>(
        colorScheme.primary.withAlpha(140),
      ),
    );
  }
}

// ── Start City Preview ───────────────────────────────

/// Subtle context strip on the destination screen,
/// reminding the user which start city they picked on the
/// previous step.
class _StartCityPreview extends StatelessWidget {
  const _StartCityPreview({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          Icon(
            Icons.my_location_rounded,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            // TODO(l10n): starting from label
            'Starting from ',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              cityName,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reachability Badge ───────────────────────────────

class _ReachabilityBadge extends StatelessWidget {
  const _ReachabilityBadge({
    required this.reachability,
  });

  final CityReachability reachability;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return switch (reachability) {
      CityReachability.direct => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            // Teal-ish using primary palette
            color: AppColors.primary40,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            // TODO(l10n): direct badge
            'Direct',
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      CityReachability.viaJunction => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.tertiary50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            // TODO(l10n): via junction badge
            'Via junction',
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      CityReachability.notReachable => Text(
          // TODO(l10n): not reachable label
          'Not reachable',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
    };
  }
}

// ── Route Options Body (Map + Bottom Sheet) ──────────

class _RouteOptionsBody extends StatefulWidget {
  const _RouteOptionsBody({
    required this.state,
    required this.onOptionSelected,
    required this.onBack,
  });

  final JourneyPlannerState state;
  final void Function(JourneyOption) onOptionSelected;
  final VoidCallback onBack;

  @override
  State<_RouteOptionsBody> createState() => _RouteOptionsBodyState();
}

class _RouteOptionsBodyState extends State<_RouteOptionsBody>
    with MapboxHostMixin {
  static const _tag = 'JourneyOptionsMap';

  final Repository _repository = GetIt.instance<Repository>();

  MapboxMap? _map;
  bool _mapReady = false;
  bool _styleLoaded = false;
  bool _wasDark = false;

  final PolylineDelegate _polylineDelegate = PolylineDelegate();
  final WidgetMarkerDelegate _markerDelegate = WidgetMarkerDelegate();
  late final GestureDelegate _gestureDelegate;

  /// Cached polyline points per option index.
  /// Each value is a list of segment point lists.
  final Map<int, List<List<LatLng>>> _optionPolylines = {};

  bool _isLoadingPolylines = true;

  @override
  MapboxMap? get hostMap => _map;

  @override
  void initState() {
    super.initState();
    _gestureDelegate = const GestureDelegate(locationEnabled: false);
    _loadAllPolylines();
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
  void didUpdateWidget(_RouteOptionsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_styleLoaded &&
        oldWidget.state.selectedOptionIndex !=
            widget.state.selectedOptionIndex) {
      unawaited(_redraw());
    }
  }

  @override
  void dispose() {
    disposeHost();
    _mapReady = false;
    _styleLoaded = false;
    unawaited(_polylineDelegate.clear().catchError((_) {}));
    unawaited(_markerDelegate.clear().catchError((_) {}));
    _polylineDelegate.resetForStyleReload();
    _markerDelegate.resetForStyleReload();
    _map = null;
    super.dispose();
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
    _markerDelegate.resetForStyleReload();
    await _polylineDelegate.initialize(map.annotations);
    await _markerDelegate.initialize(map.annotations);
    _styleLoaded = true;
    await _redraw();
  }

  Future<void> _redraw() async {
    if (disposed) return;
    await _syncPolylines();
    await _syncMarkers();
    final selectedIdx = widget.state.selectedOptionIndex;
    if (selectedIdx != null) {
      await _fitMapToOption(selectedIdx);
    } else {
      await _fitMapToAllOptions();
    }
  }

  Future<void> _loadAllPolylines() async {
    final options = widget.state.journeyOptions;
    // Load polylines for top 10 (same set that has
    // distance data).
    final limit = options.length > 10 ? 10 : options.length;

    for (var i = 0; i < limit; i++) {
      final option = options[i];
      final segments = <List<LatLng>>[];

      for (var s = 0; s < option.routes.length; s++) {
        final route = option.routes[s];
        final segStartId =
            s == 0 ? option.startCityId : option.path.junctionCityIds[s - 1];
        final segEndId = s == option.routes.length - 1
            ? option.endCityId
            : option.path.junctionCityIds[s];

        try {
          final points = await _repository.getRoutePointsByRouteIdFromDb(
            routeId: route.id,
            startingCityId: segStartId,
            destCityId: segEndId,
          );
          segments.add(
            points
                .map(
                  (p) => LatLng(
                    p.latitude,
                    p.longitude,
                  ),
                )
                .toList(),
          );
        } catch (e) {
          AppLogger.w(
            'Failed to load polyline for '
            'option $i segment $s: $e',
            tag: _tag,
          );
        }
      }

      _optionPolylines[i] = segments;
    }

    if (mounted) {
      setState(() => _isLoadingPolylines = false);
    }
  }

  Future<void> _syncPolylines() async {
    final manager = _polylineDelegate.manager;
    if (manager == null) return;
    final isDark = context.isDarkMode;
    await _polylineDelegate.clear();

    final selectedIdx = widget.state.selectedOptionIndex;

    // Two passes so the selected option draws on top of
    // the non-selected options. Mapbox annotation managers
    // honour insertion order rather than a numeric z-index.
    for (var pass = 0; pass < 2; pass++) {
      final wantSelectedPass = pass == 1;
      for (final entry in _optionPolylines.entries) {
        final optIdx = entry.key;
        final segments = entry.value;
        if (optIdx >= widget.state.journeyOptions.length) continue;
        final isSelected = selectedIdx == optIdx;
        if (isSelected != wantSelectedPass) continue;

        final option = widget.state.journeyOptions[optIdx];
        final isHighlighted = selectedIdx == null || isSelected;

        for (var s = 0; s < segments.length; s++) {
          final points = segments[s];
          if (points.isEmpty) continue;

          final route = option.routes[s];
          final baseColor = parseRouteColor(route, isDark: isDark);
          final color = isHighlighted ? baseColor : baseColor.withAlpha(80);
          final width = isSelected ? 5.0 : 3.0;

          final coords = points
              .map((p) => Position(p.longitude, p.latitude))
              .toList();

          // Outline for selected option.
          if (isSelected) {
            await manager.create(
              PolylineAnnotationOptions(
                geometry: LineString(coordinates: coords),
                lineColor: const Color.fromARGB(160, 0, 0, 0).toARGB32(),
                lineWidth: 8,
              ),
            );
          }

          await manager.create(
            PolylineAnnotationOptions(
              geometry: LineString(coordinates: coords),
              lineColor: color.toARGB32(),
              lineWidth: width,
            ),
          );
        }
      }
    }
  }

  Future<void> _syncMarkers() async {
    await _markerDelegate.clear();
    if (!mounted) return;

    final state = widget.state;
    final selectedIdx = state.selectedOptionIndex;

    final startCity = state.startCity;
    if (startCity != null) {
      await _markerDelegate.addWidgetMarker(
        context: context,
        widget: const _PinMarker(color: Color(0xFF34A853)),
        cacheKey: 'journey_planner_start_pin',
        position: LatLng(startCity.latitude, startCity.longitude),
        iconAnchor: IconAnchor.CENTER,
        symbolSortKey: 10,
      );
    }

    final endCity = state.endCity;
    if (endCity != null && mounted) {
      await _markerDelegate.addWidgetMarker(
        context: context,
        widget: const _PinMarker(color: Color(0xFFE53935)),
        cacheKey: 'journey_planner_end_pin',
        position: LatLng(endCity.latitude, endCity.longitude),
        iconAnchor: IconAnchor.CENTER,
        symbolSortKey: 10,
      );
    }

    if (selectedIdx != null && selectedIdx < state.journeyOptions.length) {
      final option = state.journeyOptions[selectedIdx];
      for (final jCity in option.junctionCities) {
        if (!mounted) return;
        await _markerDelegate.addWidgetMarker(
          context: context,
          widget: const _PinMarker(color: Color(0xFFFB8C00)),
          cacheKey: 'journey_planner_junction_pin',
          position: LatLng(jCity.latitude, jCity.longitude),
          iconAnchor: IconAnchor.CENTER,
          symbolSortKey: 8,
        );
      }
    }
  }

  Future<void> _fitMapToAllOptions() async {
    if (_map == null) return;
    final allPoints = <LatLng>[];
    for (final segments in _optionPolylines.values) {
      for (final seg in segments) {
        allPoints.addAll(seg);
      }
    }
    if (allPoints.isEmpty) return;

    await MapUtil.fitBounds(
      mapController: _map,
      points: allPoints,
      zoomConstant: 1.1,
    );
  }

  Future<void> _fitMapToOption(int index) async {
    if (_map == null) return;
    final segments = _optionPolylines[index];
    if (segments == null) return;

    final allPoints = <LatLng>[];
    for (final seg in segments) {
      allPoints.addAll(seg);
    }
    if (allPoints.isEmpty) return;

    await MapUtil.fitBounds(
      mapController: _map,
      points: allPoints,
      zoomConstant: 1.1,
    );
  }

  Future<void> _onOptionTapped(int index) async {
    final cubit = context.read<JourneyPlannerCubit>();
    final current = widget.state.selectedOptionIndex;
    if (current == index) {
      cubit.selectOption(null);
      return;
    }

    // Lazy-load polyline if not already cached.
    if (!_optionPolylines.containsKey(index)) {
      await _loadPolylineForOption(index);
      if (!mounted) return;
    }

    cubit.selectOption(index);
  }

  Future<void> _openThresholdSheet(BuildContext context) async {
    final cubit = context.read<JourneyPlannerCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _JunctionThresholdSheet(
          current: cubit.currentThreshold,
          onChanged: cubit.updateJunctionDistanceThreshold,
        );
      },
    );
  }

  Future<void> _loadPolylineForOption(int index) async {
    final options = widget.state.journeyOptions;
    if (index >= options.length) return;
    final option = options[index];
    final segments = <List<LatLng>>[];

    for (var s = 0; s < option.routes.length; s++) {
      final route = option.routes[s];
      final segStartId = s == 0
          ? option.startCityId
          : option.path.junctionCityIds[s - 1];
      final segEndId = s == option.routes.length - 1
          ? option.endCityId
          : option.path.junctionCityIds[s];

      try {
        final points = await _repository.getRoutePointsByRouteIdFromDb(
          routeId: route.id,
          startingCityId: segStartId,
          destCityId: segEndId,
        );
        segments.add(
          points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        );
      } catch (e) {
        AppLogger.w(
          'Failed to load polyline for '
          'option $index segment $s: $e',
          tag: _tag,
        );
      }
    }

    if (mounted) {
      setState(() {
        _optionPolylines[index] = segments;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final state = widget.state;

    if (state.journeyOptions.isEmpty) {
      return _EmptyRouteOptions(
        startCityName: state.startCity?.name ?? '',
        endCityName: state.endCity?.name ?? '',
        onBack: widget.onBack,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Stack(
          children: [
            // Full-screen Mapbox map
            if (_isLoadingPolylines)
              const Center(
                child: LoadingWidget(),
              )
            else
              MapWidget(
                styleUri: isDark
                    ? MapboxMapStyle.dark
                    : MapboxMapStyle.light,
                cameraOptions: CameraOptions(
                  center: Point(
                    coordinates: Position(
                      -8.5396835,
                      42.8760274,
                    ),
                  ),
                  zoom: 6,
                ),
                onMapCreated: _onMapCreated,
                onStyleLoadedListener: (_) => _onStyleLoaded(),
              ),
            // Floating back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: _FloatingBackButton(
                isDark: isDark,
                onTap: widget.onBack,
              ),
            ),
            // Dev/staging: floating tune button to adjust
            // the junction distance threshold at runtime.
            if (AppConfig.flavor != Flavor.production)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: _FloatingTuneButton(
                  isDark: isDark,
                  onTap: () => _openThresholdSheet(context),
                ),
              ),
            // Bottom sheet with option cards
            _OptionsBottomSheet(
              state: state,
              onOptionTapped: _onOptionTapped,
              onOptionSelected: widget.onOptionSelected,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty Route Options (no-map fallback) ────────────

class _EmptyRouteOptions extends StatelessWidget {
  const _EmptyRouteOptions({
    required this.startCityName,
    required this.endCityName,
    required this.onBack,
  });

  final String startCityName;
  final String endCityName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: 'Journey Options',
        onBackTap: onBack,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.route_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  // TODO(l10n): no routes found
                  'No routes found',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  // TODO(l10n): no routes description
                  'There is no route connecting '
                  '$startCityName '
                  'to $endCityName.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Floating Back Button ─────────────────────────────

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? AppColors.primary20 : AppColors.primary40;
    final iconColor = isDark ? AppColors.primary80 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/ic_chervon_left.svg',
              width: 24,
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Options Bottom Sheet ─────────────────────────────

class _OptionsBottomSheet extends StatefulWidget {
  const _OptionsBottomSheet({
    required this.state,
    required this.onOptionTapped,
    required this.onOptionSelected,
  });

  final JourneyPlannerState state;
  final void Function(int index) onOptionTapped;
  final void Function(JourneyOption) onOptionSelected;

  @override
  State<_OptionsBottomSheet> createState() =>
      _OptionsBottomSheetState();
}

class _OptionsBottomSheetState extends State<_OptionsBottomSheet> {
  final _sheetController = DraggableScrollableController();

  static const double _minSize = 0.35;
  static const double _maxSize = 0.65;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _onHandleDrag(DragUpdateDetails details) {
    if (!_sheetController.isAttached) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final deltaFraction =
        (details.primaryDelta ?? 0) / screenHeight;
    final newSize =
        (_sheetController.size - deltaFraction)
            .clamp(_minSize, _maxSize);
    _sheetController.jumpTo(newSize);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDarkMode;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _minSize,
      minChildSize: _minSize,
      maxChildSize: _maxSize,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: _onHandleDrag,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const _DragHandle(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, 12,
                      ),
                      child: _JourneySummaryChip(
                        startCityName:
                            state.startCity?.name ?? '',
                        endCityName:
                            state.endCity?.name ?? '',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 12,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          // TODO(l10n): options count
                          '${state.journeyOptions.length} '
                          '${state.journeyOptions.length == 1 ? 'option' : 'options'}'
                          ' found',
                          style: textTheme.labelMedium
                              ?.copyWith(
                            color:
                                colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 24,
                  ),
                  itemCount: state.journeyOptions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final option =
                        state.journeyOptions[index];
                    final isSelected =
                        state.selectedOptionIndex == index;
                    return _JourneyOptionCard(
                      option: option,
                      isDark: isDark,
                      isSelected: isSelected,
                      onTap: () =>
                          widget.onOptionTapped(index),
                      onSelect: () =>
                          widget.onOptionSelected(option),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Drag Handle ──────────────────────────────────────

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withAlpha(80),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Journey Summary Chip ─────────────────────────────

class _JourneySummaryChip extends StatelessWidget {
  const _JourneySummaryChip({
    required this.startCityName,
    required this.endCityName,
  });

  final String startCityName;
  final String endCityName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    final nameStyle = textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text.rich(
          // No ellipsis: city names always display in
          // full, wrapping to a new line if needed.
          TextSpan(
            children: [
              TextSpan(
                text: startCityName,
                style: nameStyle,
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextSpan(
                text: endCityName,
                style: nameStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Journey Option Card ──────────────────────────────

class _JourneyOptionCard extends StatelessWidget {
  const _JourneyOptionCard({
    required this.option,
    required this.isDark,
    required this.onTap,
    required this.onSelect,
    this.isSelected = false,
  });

  final JourneyOption option;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    // Left accent stripe: a vertical gradient through
    // every route's color so multi-route options show the
    // full palette of the trail (e.g., pink → purple →
    // yellow for a 3-route option).
    final routeColors = option.routes
        .map((r) => parseRouteColor(r, isDark: isDark))
        .toList();
    if (routeColors.isEmpty) routeColors.add(colorScheme.primary);
    final stripeGradient = routeColors.length == 1
        ? null
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: routeColors,
          );
    final stripeSolidColor = routeColors.first;

    final cardBg = isDark ? AppColors.gray800 : AppColors.primary95;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pill-shaped accent stripe: inset from
                // the card's top and bottom so it sits as
                // a floating marker on the left edge.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                  ),
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: stripeGradient == null
                          ? stripeSolidColor
                          : null,
                      gradient: stripeGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12, 16, 16, 16,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _RouteChain(
                          routes: option.routes,
                          isDark: isDark,
                          junctionCities: option.junctionCities,
                        ),
                        const SizedBox(height: 8),
                        // Direct routes still show the
                        // "Direct route" caption. Multi-
                        // route options now show their
                        // junctions inline (above), so the
                        // bottom Junction summary is no
                        // longer needed.
                        if (option.path.isDirect)
                          _JunctionInfoRow(
                            option: option,
                            textTheme: textTheme,
                            colorScheme: colorScheme,
                          ),
                        const SizedBox(height: 4),
                        _OptionStatsRow(
                          option: option,
                          textTheme: textTheme,
                          colorScheme: colorScheme,
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: onSelect,
                              child: const Text(
                                // TODO(l10n): select route
                                'Select this route',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

// ── Option Stats Row (distance + cities) ─────────────

class _OptionStatsRow extends StatelessWidget {
  const _OptionStatsRow({
    required this.option,
    required this.textTheme,
    required this.colorScheme,
  });

  final JourneyOption option;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final statStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final items = <Widget>[];

    if (option.estimatedDistanceKm != null) {
      items.add(
        Text(
          // TODO(l10n): distance label
          '~${option.estimatedDistanceKm!.toStringAsFixed(0)} km',
          style: statStyle,
        ),
      );
    }

    if (option.cityCount != null) {
      items.add(
        Text(
          // TODO(l10n): city count
          '${option.cityCount} '
          '${option.cityCount == 1 ? 'city' : 'cities'}',
          style: statStyle,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      children: items,
    );
  }
}

// ── Route Chain (route names only) ───────────────────

/// Renders the sequence of route names that make up an
/// option. Each route is prefixed with a small dot in its
/// designated route color so users can visually associate
/// the route with its line on the map. Junction city
/// names appear between each pair of routes so the user
/// can see exactly where the transfer happens.
class _RouteChain extends StatelessWidget {
  const _RouteChain({
    required this.routes,
    required this.isDark,
    this.junctionCities = const [],
  });

  final List<RouteEntity> routes;
  final bool isDark;
  final List<CityEntity> junctionCities;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final nameStyle = textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.primary80 : AppColors.primary20,
    );
    final junctionLabelStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    if (routes.isEmpty) return const SizedBox.shrink();

    Widget buildRouteRow(RouteEntity route) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: parseRouteColor(route, isDark: isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              route.routeName,
              style: nameStyle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRouteRow(routes.first),
        for (var i = 1; i < routes.length; i++) ...[
          if (i - 1 < junctionCities.length)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 0, 8),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      // TODO(l10n): city junction here label
                      text: 'City junction: ',
                      style: junctionLabelStyle?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: junctionCities[i - 1].name,
                      style: junctionLabelStyle,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          buildRouteRow(routes[i]),
        ],
      ],
    );
  }
}

// ── Junction Info Row ────────────────────────────────

class _JunctionInfoRow extends StatelessWidget {
  const _JunctionInfoRow({
    required this.option,
    required this.textTheme,
    required this.colorScheme,
  });

  final JourneyOption option;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (option.path.isDirect) {
      return Text(
        // TODO(l10n): direct route label
        'Direct route',
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final names = option.junctionCities.map((c) => c.name).toList();
    // TODO(l10n): via junction label
    final viaLabel = switch (names.length) {
      0 => 'junction',
      1 => names.first,
      _ => '${names.sublist(0, names.length - 1).join(', ')}'
          ' and ${names.last}',
    };

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            // TODO(l10n): junction header
            text: 'Junction',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(
            text: '  Via $viaLabel',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ── Floating Tune Button (dev/staging) ───────────────

class _FloatingTuneButton extends StatelessWidget {
  const _FloatingTuneButton({
    required this.isDark,
    required this.onTap,
  });

  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? AppColors.primary20 : AppColors.primary40;
    final iconColor = isDark ? AppColors.primary80 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.tune,
              size: 24,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Junction Threshold Sheet (dev/staging) ───────────

class _JunctionThresholdSheet extends StatefulWidget {
  const _JunctionThresholdSheet({
    required this.current,
    required this.onChanged,
  });

  final double current;
  final Future<void> Function(double meters) onChanged;

  @override
  State<_JunctionThresholdSheet> createState() =>
      _JunctionThresholdSheetState();
}

class _JunctionThresholdSheetState
    extends State<_JunctionThresholdSheet> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.current.clamp(0, 5000);
  }

  String _formatKm(double meters) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  Future<void> _onChangeEnd(double value) async {
    await widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Junction distance threshold',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Filter junctions where routes don't actually "
              'meet within this distance.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  _formatKm(_value),
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '0 – 5 km',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Slider(
              value: _value,
              max: 5000,
              divisions: 50,
              label: _formatKm(_value),
              onChanged: (value) =>
                  setState(() => _value = value),
              onChangeEnd: _onChangeEnd,
            ),
            const SizedBox(height: 4),
            Text(
              'Changes take effect immediately.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Failure Body ─────────────────────────────────────

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
              'Could not load city data. '
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

// ── Pin Marker (Mapbox widget-marker bitmap) ─────────

/// Coloured circular pin used for start/end/junction
/// markers on the journey options map. Mapbox does not
/// ship a built-in pin sprite, so each colour variant is
/// rendered to a bitmap via `MarkerHelper` and cached
/// per cacheKey by `WidgetMarkerDelegate`.
class _PinMarker extends StatelessWidget {
  const _PinMarker({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
