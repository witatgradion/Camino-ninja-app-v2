import 'dart:async';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/mapbox/controllers/mapbox_host_mixin.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/gesture_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/polyline_delegate.dart';
import 'package:camino_ninja_flutter/mapbox/delegates/widget_marker_delegate.dart';
import 'package:camino_ninja_flutter/repositories/offline_map_repository.dart';
import 'package:camino_ninja_flutter/tabs/map/map_location_handler.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/cubit/stage_map_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/combine_marker.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/combine_marker_data.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/stage_directional_arrow_marker.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/marker_const.dart';
import 'package:camino_ninja_flutter/utils/marker_helpers/marker_helper.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Controller for `EmbeddedStageMap` — owns the map, the
/// [StageMapCubit], all delegates and the [MapLocationHandler].
///
/// The widget is reduced to UI + Bloc glue; every draw call, gesture
/// config and location callback lives here.
///
/// ### Delegate topology
/// Two separate [WidgetMarkerDelegate] instances are used: one for the
/// city / combine markers, another for the single directional arrow.
/// Keeping them separate sidesteps the single-manager `deleteAll`
/// collision the pre-migration widget had — each delegate owns its own
/// [PointAnnotationManager] so `clear()` on one does not touch the
/// other.
///
/// ### Polyline drawing
/// [PolylineDelegate.syncRoutePolylines] does not cover the
/// stage/alt/selected branching this screen needs (per-stage colouring,
/// selected-route highlight, unselected-stage colour). We use the
/// delegate for lifecycle (`clear()` and the exposed manager) but build
/// annotations manually — mirrors [drawPolylines] in
/// `MapScreenController`.
class EmbeddedStageMapController with MapboxHostMixin {
  EmbeddedStageMapController({
    required StageModel selectedStage,
    required int routeId,
    required this.onLocationStateChanged,
    int? stagePlanId,
  })  : _routeId = routeId,
        cubit = StageMapCubit(
          selectedStage: selectedStage,
          routeId: routeId,
          stagePlanId: stagePlanId,
        )..init();

  /// The cubit owned by this controller. Exposed so the widget can wire
  /// it into its `BlocProvider` and rebuild on state changes.
  final StageMapCubit cubit;

  /// Callback fired whenever the underlying [MapLocationHandler] signals
  /// a state change. The widget typically responds by calling
  /// `setState()` so the location button can re-render.
  final VoidCallback onLocationStateChanged;

  int _routeId;
  MapboxMap? _map;
  final PolylineDelegate _polylineDelegate = PolylineDelegate();
  final WidgetMarkerDelegate _combineMarkerDelegate = WidgetMarkerDelegate();
  final WidgetMarkerDelegate _arrowMarkerDelegate = WidgetMarkerDelegate();
  MapLocationHandler? _locationHandler;
  Cancelable? _polylineTapSubscription;
  Cancelable? _combineMarkerTapSubscription;

  int? _previousSelectedStageId;
  bool _isInitialDraw = true;
  bool _autoDownloadTriggered = false;

  /// One-shot flag set by [onAppThemeChanged] before swapping the style;
  /// checked-and-cleared in [onStyleLoaded]. Lets the post-style-load
  /// redraw refit the camera AFTER polylines/markers have been
  /// recreated, instead of running `fitBounds` against a half-rendered
  /// style.
  bool _pendingFitBoundsAfterStyleReload = false;

  /// Maps a polyline annotation `id` to the stage `id` it represents.
  /// Rebuilt from scratch on every [drawPolylines] call — annotation IDs
  /// can roll over between draws when we clear and re-create. The tap
  /// listener guards against stale IDs by treating a missing entry as a
  /// no-op.
  final Map<String, int> _stageIdByPolylineAnnotationId = {};

  /// Maps a combine-marker annotation `id` to the primary stage `id` it
  /// represents (the first start stage, falling back to the first end
  /// stage). Rebuilt from scratch on every [drawMarkers] call.
  final Map<String, int> _stageIdByCombineMarkerAnnotationId = {};

  MapboxMap? get mapboxMap => _map;
  @override
  MapboxMap? get hostMap => _map;

  /// Called when the parent widget's `routeId` changes. Mirrors the
  /// previous `didUpdateWidget` latch reset so a new route can
  /// auto-download.
  void updateRouteId(int newRouteId) {
    if (_routeId == newRouteId) return;
    _routeId = newRouteId;
    _autoDownloadTriggered = false;
  }

  /// Called from `MapWidget.onMapCreated`.
  Future<void> onMapCreated(BuildContext context, MapboxMap map) async {
    if (disposed) return;
    _map = map;
    setInitialStyleUri(
      context.isDarkMode ? MapboxMapStyle.dark : MapboxMapStyle.light,
    );
    // Initialize eagerly, before any `await`, so that the "my location"
    // button works regardless of whether the `BlocListener`'s
    // `listenWhen` ever fires. Must run while `context` is fresh —
    // `_initializeLocationHandler` captures it.
    _initializeLocationHandler(context);

    await _polylineDelegate.initialize(map.annotations);
    await _combineMarkerDelegate.initialize(map.annotations);
    await _arrowMarkerDelegate.initialize(map.annotations);

    _registerAnnotationClickListeners();

    // Original widget enabled location + pulsing in `onMapCreated`
    // unconditionally; the location handler then toggles via
    // `onMyLocationEnabledChanged`. Match that by starting both on.
    await const GestureDelegate(
      locationPulsingEnabled: true,
    ).apply(map);

    final state = cubit.state;
    if (state.initStatus == StageMapInitStatus.success) {
      await drawPolylines(context, state);
      await drawMarkers(context, state);
      await drawDirectionalArrow(context, state);
      await MapUtil.fitBounds(
        mapController: _map,
        points: MapUtil.getLatLngsFromRoutePoints(
          state.selectedStage?.selectedRoutePoints ?? [],
        ),
        zoomConstant: 1.6,
      );
    }
  }

  /// Called from `MapWidget.onStyleLoadedListener`.
  ///
  /// Annotation managers (polyline + the two `WidgetMarkerDelegate`
  /// instances) do NOT survive a `loadStyleURI` swap — recreate them
  /// here BEFORE redrawing, then re-register the tap listeners that
  /// were originally attached in `onMapCreated` (listeners are bound to
  /// the manager and are lost along with it).
  ///
  /// On the *initial* style load (right after `onMapCreated`) the
  /// delegates already hold freshly-created managers, so the
  /// `resetForStyleReload` + `initialize` pair becomes a no-op for the
  /// reset (the next initialize then re-uses the same manager because
  /// `initialize` short-circuits when `_manager != null`). The reset is
  /// only meaningful after a real style swap.
  Future<void> onStyleLoaded(BuildContext context) async {
    if (disposed) return;
    final map = _map;
    if (map == null) return;

    // Recreate annotation managers on the freshly-loaded style.
    _polylineDelegate.resetForStyleReload();
    _combineMarkerDelegate.resetForStyleReload();
    _arrowMarkerDelegate.resetForStyleReload();
    await _polylineDelegate.initialize(map.annotations);
    await _combineMarkerDelegate.initialize(map.annotations);
    await _arrowMarkerDelegate.initialize(map.annotations);

    // Listeners are registered against the manager instance — after a
    // recreate, the old registrations point at a dead object. Re-bind.
    _registerAnnotationClickListeners();

    final state = cubit.state;
    await drawPolylines(context, state);
    await drawMarkers(context, state);
    await drawDirectionalArrow(context, state);

    // If a theme swap kicked off this style load, refit AFTER the
    // redraw. Doing it here (instead of inside `onAppThemeChanged`
    // right after the `loadStyleURI` await) guarantees the polylines /
    // markers driving the bounds are actually present.
    if (_pendingFitBoundsAfterStyleReload) {
      _pendingFitBoundsAfterStyleReload = false;
      await MapUtil.fitBounds(
        mapController: _map,
        points: MapUtil.getLatLngsFromRoutePoints(
          state.selectedStage?.selectedRoutePoints ?? [],
        ),
        zoomConstant: 1.6,
      );
    }
  }

  /// Forwarded from the widget's `BlocListener<StageMapCubit>`.
  Future<void> onCubitStateChanged(
    BuildContext context,
    StageMapState state,
  ) async {
    if (disposed) return;
    final isSelectionChange =
        _previousSelectedStageId != state.selectedStage?.id;
    final isInitialLoad =
        _isInitialDraw && state.initStatus == StageMapInitStatus.success;

    if (isInitialLoad) {
      _isInitialDraw = false;
      _triggerAutoDownload(state);
      await drawPolylines(context, state);
      await drawMarkers(context, state);
      await drawDirectionalArrow(context, state);
    } else if (isSelectionChange) {
      await drawPolylines(context, state);
      await drawMarkers(context, state);
      await drawDirectionalArrow(context, state);
    }

    _previousSelectedStageId = state.selectedStage?.id;

    // Skip the refit on initial load — `onMapCreated` already fit the
    // camera once. A second unconditional fit here produces visible
    // jank on slower devices.
    if (isSelectionChange && _map != null) {
      await MapUtil.fitBounds(
        mapController: _map,
        points: MapUtil.getLatLngsFromRoutePoints(
          state.selectedStage?.selectedRoutePoints ?? [],
        ),
        zoomConstant: 1.6,
      );
    }
  }

  /// Forwarded from the widget's `BlocListener<AppCubit>` on theme
  /// change. Clears the widget-marker bitmap cache and reloads the
  /// Mapbox style — `loadStyleURI` auto-refires `onStyleLoaded` which
  /// recreates the annotation managers, redraws polylines / markers /
  /// arrow with the fresh theme and re-fits the camera.
  ///
  /// `loadStyleURI`'s await returns when the style URI is *requested*,
  /// not when layers have re-rendered, so we can't safely call
  /// `fitBounds` here. Instead we set [_pendingFitBoundsAfterStyleReload]
  /// and let the re-fired [onStyleLoaded] do the refit AFTER the
  /// polylines / markers it depends on have been recreated.
  Future<void> onAppThemeChanged(
    BuildContext context, {
    required bool isDark,
  }) async {
    if (disposed) return;
    MarkerHelper.clearWidgetMarkerCache();
    final newUri = isDark ? MapboxMapStyle.dark : MapboxMapStyle.light;
    if (_map == null || currentStyleUri == newUri) return;
    // Theme changed while satellite is on — keep the satellite overlay
    // and just update the URI we'll restore to.
    if (isSatelliteView) {
      updatePreSatelliteThemeUri(newUri);
      return;
    }
    _pendingFitBoundsAfterStyleReload = true;
    await swapStyle(newUri);
  }

  /// Routes a satellite toggle through the mixin's serialised
  /// [MapboxHostMixin.toggleSatellite].
  Future<void> toggleSatelliteView({required bool isDark}) async {
    if (disposed) return;
    final themeUri = isDark ? MapboxMapStyle.dark : MapboxMapStyle.light;
    await toggleSatellite(themeUri: themeUri);
  }

  /// Draws the main route, alt routes, the selected stage and any
  /// unselected stages. Ordering is identical to the pre-migration
  /// inline implementation. Kept in the controller (rather than routed
  /// through [PolylineDelegate.syncRoutePolylines]) because
  /// stage-specific colouring and sort-key logic do not fit that
  /// helper — same rationale as `MapScreenController.drawPolylines`.
  Future<void> drawPolylines(
    BuildContext context,
    StageMapState state, {
    bool? isDarkOverride,
  }) async {
    final manager = _polylineDelegate.manager;
    if (manager == null) return;
    // Resolve theme-dependent values before the first await to avoid
    // `use_build_context_synchronously` warnings on later reads.
    final isDark = isDarkOverride ?? context.isDarkMode;
    await _polylineDelegate.clear();
    // Clear the annotation-id → stage-id map: annotation IDs from the
    // previous draw are invalidated by `clear()`, and we're about to
    // rebuild entries for the new draw. Main route / alt routes are
    // intentionally NOT mapped — tapping them should be a no-op.
    _stageIdByPolylineAnnotationId.clear();

    final routePoints = state.routePoints;
    final altRoutePoints = state.altRoutePoints;
    final selectedRoutePoints = state.selectedStage?.selectedRoutePoints ?? [];
    final otherStages =
        state.allStages.where((e) => e.id != state.selectedStage?.id).toList();
    final selectedRouteColor =
        isDark ? AppColors.primary80 : AppColors.primary40;

    if (routePoints.isNotEmpty) {
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: routePoints
                .map((e) => Position(e.longitude, e.latitude))
                .toList(),
          ),
          lineColor: Colors.red.value,
          lineWidth: 4.0,
          lineSortKey: 1.0,
        ),
      );
    }

    if (altRoutePoints.isNotEmpty) {
      for (final ap in altRoutePoints) {
        await manager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: ap.values
                  .map((e) => Position(e.longitude, e.latitude))
                  .toList(),
            ),
            lineColor: HexColor.fromHex('88${ap.color ?? 'FF0000'}').value,
            lineWidth: 3.0,
            lineSortKey: 2.0,
          ),
        );
      }
    }

    final selectedStageId = state.selectedStage?.id;
    if (selectedRoutePoints.isNotEmpty && selectedStageId != null) {
      final annotation = await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: selectedRoutePoints
                .map((e) => Position(e.longitude, e.latitude))
                .toList(),
          ),
          lineColor: selectedRouteColor.value,
          lineWidth: 5.0,
          lineSortKey: 4.0,
        ),
      );
      _stageIdByPolylineAnnotationId[annotation.id] = selectedStageId;
    }

    if (otherStages.isNotEmpty) {
      final unselectedColor = isDark ? AppColors.gray400 : AppColors.gray500;
      for (final stage in otherStages) {
        final stagePoints = stage.selectedRoutePoints ?? [];
        if (stagePoints.isNotEmpty) {
          final annotation = await manager.create(
            PolylineAnnotationOptions(
              geometry: LineString(
                coordinates: stagePoints
                    .map((e) => Position(e.longitude, e.latitude))
                    .toList(),
              ),
              lineColor: unselectedColor.value,
              lineWidth: 5.0,
              lineSortKey: 3.0,
            ),
          );
          final stageId = stage.id;
          if (stageId != null) {
            _stageIdByPolylineAnnotationId[annotation.id] = stageId;
          }
        }
      }
    }
  }

  /// Draws the city / combine markers using the dedicated delegate.
  /// Cache key format matches the original `_buildMarkerCacheKey`
  /// verbatim so bitmaps cached before migration remain valid.
  Future<void> drawMarkers(
    BuildContext context,
    StageMapState state, {
    bool? isDarkOverride,
    TextTheme? textThemeOverride,
  }) async {
    try {
      final combineMarkerDataList = state.combineMarkerDataList;
      if (combineMarkerDataList.isEmpty) {
        await _combineMarkerDelegate.clear();
        _stageIdByCombineMarkerAnnotationId.clear();
        return;
      }
      // Resolve theme-dependent values before the first await.
      final isDark = isDarkOverride ?? context.isDarkMode;
      final textTheme = textThemeOverride ?? Theme.of(context).textTheme;
      final startLabel = AppLocalizations.of(context).iWillStartHere;
      final endLabel = AppLocalizations.of(context).iWillGoHere;
      await _combineMarkerDelegate.clear();
      // Clear the annotation-id → stage-id map: annotation IDs from the
      // previous draw are invalidated by `clear()`, and we're about to
      // rebuild entries for the new draw.
      _stageIdByCombineMarkerAnnotationId.clear();

      for (final d in combineMarkerDataList) {
        if (!context.mounted) return;
        final cacheKey = _buildMarkerCacheKey(d, isDark: isDark);
        final combineMarker = CombineMarker(
          city: d.city,
          isDarkMode: isDark,
          textTheme: textTheme,
          startStages: d.startStages,
          endStages: d.endStages,
          startText: startLabel,
          endText: endLabel,
        );
        final annotation = await _combineMarkerDelegate.addWidgetMarker(
          context: context,
          widget: combineMarker,
          cacheKey: cacheKey,
          position: LatLng(d.city.latitude, d.city.longitude),
          symbolSortKey: kPriorityCityZIndex.toDouble(),
        );
        final primaryStageId = d.startStages.firstOrNull?.stage.id ??
            d.endStages.firstOrNull?.stage.id;
        if (annotation != null && primaryStageId != null) {
          _stageIdByCombineMarkerAnnotationId[annotation.id] = primaryStageId;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error drawing markers',
        tag: 'EmbeddedStageMap',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Draws the single directional arrow at the middle route point of
  /// the currently-selected stage. Uses a dedicated delegate so
  /// [drawMarkers] clearing does not remove the arrow.
  Future<void> drawDirectionalArrow(
    BuildContext context,
    StageMapState state, {
    bool? isDarkOverride,
  }) async {
    // Resolve theme-dependent values before the first await.
    final isDark = isDarkOverride ?? context.isDarkMode;
    await _arrowMarkerDelegate.clear();

    final routePoints = state.selectedStage?.selectedRoutePoints ?? [];
    if (routePoints.length < 2) return;

    final totalPoints = routePoints.length;
    final middleIndex = (totalPoints / 2).floor();
    if (middleIndex == 0 || middleIndex >= totalPoints - 1) return;

    final middlePoint = routePoints[middleIndex];
    final prevPoint = routePoints[middleIndex - 1];
    final nextPoint = routePoints[middleIndex + 1];

    final bearing = MarkerHelper.calculateBearing(
      prevPoint.latitude,
      prevPoint.longitude,
      nextPoint.latitude,
      nextPoint.longitude,
    );

    final cacheKey = 'directional_arrow_${isDark ? 'dark' : 'light'}';

    if (!context.mounted) return;
    await _arrowMarkerDelegate.addWidgetMarker(
      context: context,
      widget: StageDirectionalArrowMarker(isDarkMode: isDark),
      cacheKey: cacheKey,
      position: LatLng(middlePoint.latitude, middlePoint.longitude),
      iconAnchor: IconAnchor.CENTER,
      iconRotate: bearing - 90,
      symbolSortKey: kArrowZIndex.toDouble(),
    );
  }

  /// Handler for the floating "my location" button.
  void onMyLocationTap() {
    if (disposed) return;
    _locationHandler?.initialize(
      forceAnimated: true,
      shouldShowDoNotShowAgain: false,
      isMyLocationClicked: true,
      source: 'stage_planner',
    );
  }

  /// Registers tap listeners on the polyline and combine-marker
  /// annotation managers. Called from [onMapCreated] for the initial
  /// setup AND from [onStyleLoaded] after a style swap, since the
  /// annotation managers are recreated on every style reload and the
  /// listener bindings are lost with them. Arrow markers are
  /// intentionally non-interactive.
  void _registerAnnotationClickListeners() {
    // Cancel any previously-registered subscriptions before re-binding —
    // happens on every style swap (`onStyleLoaded` re-invokes this).
    _polylineTapSubscription?.cancel();
    _combineMarkerTapSubscription?.cancel();
    _polylineTapSubscription = null;
    _combineMarkerTapSubscription = null;

    final polylineManager = _polylineDelegate.manager;
    if (polylineManager != null) {
      _polylineTapSubscription =
          polylineManager.tapEvents(onTap: _onPolylineTapped);
    }

    final combineMarkerManager = _combineMarkerDelegate.manager;
    if (combineMarkerManager != null) {
      _combineMarkerTapSubscription =
          combineMarkerManager.tapEvents(onTap: _onCombineMarkerTapped);
    }
  }

  void _onPolylineTapped(PolylineAnnotation annotation) {
    if (disposed) return;
    final stageId = _stageIdByPolylineAnnotationId[annotation.id];
    if (stageId == null) return;
    _selectStageById(stageId);
  }

  void _onCombineMarkerTapped(PointAnnotation annotation) {
    if (disposed) return;
    final stageId = _stageIdByCombineMarkerAnnotationId[annotation.id];
    if (stageId == null) return;
    _selectStageById(stageId);
  }

  void _selectStageById(int stageId) {
    if (disposed || cubit.isClosed) return;
    final stage = cubit.state.allStages
        .where((StageModel s) => s.id == stageId)
        .firstOrNull;
    if (stage == null) return;
    cubit.onSelectStage(stage);
  }

  String _buildMarkerCacheKey(
    CombineMarkerData d, {
    required bool isDark,
  }) {
    final startIds = d.startStages.map(
      (CombineMarkerStageData s) => '${s.stage.id}_${s.isSelected}',
    );
    final endIds = d.endStages.map(
      (CombineMarkerStageData s) => '${s.stage.id}_${s.isSelected}',
    );
    final mode = isDark ? 'dark' : 'light';
    return 'city_${d.city.id}_${mode}_'
        's${startIds.join(',')}_e${endIds.join(',')}';
  }

  void _triggerAutoDownload(StageMapState state) {
    if (_autoDownloadTriggered) return;
    if (state.routePoints.isEmpty) return;
    _autoDownloadTriggered = true;
    unawaited(
      GetIt.instance<OfflineMapRepository>().downloadIfNeeded(
        routeId: _routeId,
        routeName: state.route?.routeName ?? '',
        points: state.routePoints,
      ),
    );
  }

  void _initializeLocationHandler(BuildContext context) {
    _locationHandler = MapLocationHandler(
      context: context,
      onLocationStateChanged: onLocationStateChanged,
      onDistanceChanged: (_) {},
      onAltitudeChanged: (_) {},
      onMyLocationEnabledChanged: (enabled) {
        _map?.location.updateSettings(
          LocationComponentSettings(
            enabled: enabled,
            pulsingEnabled: enabled,
          ),
        );
      },
      getMapController: () => _map,
      getRoutePoints: () => cubit.state.routePoints,
      getChartRoutePoints: () => [],
      getUnit: () => UnitEnum.metric,
      getRoute: () => RouteEntity(
        id: cubit.state.route?.id ?? _routeId,
        routeName: cubit.state.route?.routeName ?? '',
        orderKey: 0,
      ),
    );
  }

  void dispose() {
    if (disposed) return;
    disposeHost();
    // Cancel annotation tap subscriptions before tearing down the
    // delegates. The subscriptions close over `this` via the
    // `_onPolylineTapped` / `_onCombineMarkerTapped` instance methods —
    // leaving them live would keep the controller (and through it the
    // cubit) reachable from the native side after widget unmount.
    _polylineTapSubscription?.cancel();
    _combineMarkerTapSubscription?.cancel();
    _polylineTapSubscription = null;
    _combineMarkerTapSubscription = null;

    // Drop the annotation manager references each delegate holds.
    // Without this the native managers stay reachable from Dart, which
    // pins the entire annotation graph on every push/pop of
    // `StageMapScreen`.
    //
    // WHY clear-then-reset order is load-bearing: `clear()` is
    // `async => _manager?.deleteAll();` — it reads `_manager`
    // *synchronously* on entry, before the first await. If `clear()`
    // ever gets refactored to read `_manager` after an await, the
    // `resetForStyleReload()` calls below will null the field first and
    // every `clear()` will silently no-op, re-opening the leak.
    unawaited(_polylineDelegate.clear().catchError((_) {}));
    unawaited(_combineMarkerDelegate.clear().catchError((_) {}));
    unawaited(_arrowMarkerDelegate.clear().catchError((_) {}));
    _polylineDelegate.resetForStyleReload();
    _combineMarkerDelegate.resetForStyleReload();
    _arrowMarkerDelegate.resetForStyleReload();

    _stageIdByPolylineAnnotationId.clear();
    _stageIdByCombineMarkerAnnotationId.clear();

    _locationHandler?.dispose();
    if (!cubit.isClosed) {
      cubit.close();
    }
    _map = null;
  }
}
