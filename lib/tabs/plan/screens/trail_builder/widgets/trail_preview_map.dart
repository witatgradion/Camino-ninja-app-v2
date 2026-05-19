import 'dart:async';

import 'package:camino_ninja_flutter/mapbox/mapbox.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/map_util.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:storage/storage.dart';

/// Data for a single segment polyline on the trail
/// preview map.
class TrailSegmentPolyline {
  const TrailSegmentPolyline({
    required this.points,
    required this.color,
    this.routeName,
  });

  final List<LatLng> points;
  final Color color;
  final String? routeName;
}

class TrailPreviewMap extends StatefulWidget {
  const TrailPreviewMap({
    required this.segmentPolylines,
    this.inProgressPoints,
    this.inProgressColor,
    this.junctionCity,
    this.branchPreviewPolylines,
    this.interactive = true,
    super.key,
  });

  final List<TrailSegmentPolyline> segmentPolylines;
  final List<LatLng>? inProgressPoints;
  final Color? inProgressColor;
  final CityEntity? junctionCity;
  final List<TrailSegmentPolyline>? branchPreviewPolylines;
  final bool interactive;

  @override
  State<TrailPreviewMap> createState() => _TrailPreviewMapState();
}

class _TrailPreviewMapState extends State<TrailPreviewMap>
    with MapboxHostMixin {
  MapboxMap? _map;
  bool _mapReady = false;
  bool _styleLoaded = false;

  final PolylineDelegate _polylineDelegate = PolylineDelegate();
  final WidgetMarkerDelegate _labelMarkerDelegate = WidgetMarkerDelegate();
  final WidgetMarkerDelegate _junctionMarkerDelegate = WidgetMarkerDelegate();

  late GestureDelegate _gestureDelegate;
  bool _wasDark = false;

  @override
  MapboxMap? get hostMap => _map;

  @override
  void initState() {
    super.initState();
    _gestureDelegate = GestureDelegate(
      scrollEnabled: widget.interactive,
      pinchToZoomEnabled: widget.interactive,
      doubleTapToZoomInEnabled: widget.interactive,
      locationEnabled: false,
    );
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
  void didUpdateWidget(TrailPreviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_inputsChanged(oldWidget) && _styleLoaded) {
      unawaited(_redraw());
    }
  }

  @override
  void dispose() {
    disposeHost();
    _mapReady = false;
    _styleLoaded = false;
    unawaited(_polylineDelegate.clear().catchError((_) {}));
    unawaited(_labelMarkerDelegate.clear().catchError((_) {}));
    unawaited(_junctionMarkerDelegate.clear().catchError((_) {}));
    _polylineDelegate.resetForStyleReload();
    _labelMarkerDelegate.resetForStyleReload();
    _junctionMarkerDelegate.resetForStyleReload();
    _map = null;
    super.dispose();
  }

  bool _inputsChanged(TrailPreviewMap old) {
    if (old.segmentPolylines.length != widget.segmentPolylines.length) {
      return true;
    }
    if (old.inProgressPoints?.length !=
        widget.inProgressPoints?.length) {
      return true;
    }
    if (old.junctionCity?.id != widget.junctionCity?.id) {
      return true;
    }
    if (old.branchPreviewPolylines?.length !=
        widget.branchPreviewPolylines?.length) {
      return true;
    }
    for (var i = 0; i < widget.segmentPolylines.length; i++) {
      final oldSeg = old.segmentPolylines[i];
      final newSeg = widget.segmentPolylines[i];
      if (oldSeg.points.length != newSeg.points.length) {
        return true;
      }
      if (oldSeg.color != newSeg.color) {
        return true;
      }
    }
    return false;
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
    _labelMarkerDelegate.resetForStyleReload();
    _junctionMarkerDelegate.resetForStyleReload();
    await _polylineDelegate.initialize(map.annotations);
    await _labelMarkerDelegate.initialize(map.annotations);
    await _junctionMarkerDelegate.initialize(map.annotations);
    _styleLoaded = true;
    await _redraw();
  }

  Future<void> _redraw() async {
    if (disposed) return;
    await _syncPolylines();
    await _syncMarkers();
    await _fitBounds();
  }

  Future<void> _syncPolylines() async {
    final manager = _polylineDelegate.manager;
    if (manager == null) return;
    await _polylineDelegate.clear();
    const outlineColor = Color.fromARGB(160, 0, 0, 0);

    for (var i = 0; i < widget.segmentPolylines.length; i++) {
      final seg = widget.segmentPolylines[i];
      if (seg.points.isEmpty) continue;
      final coords = seg.points
          .map((p) => Position(p.longitude, p.latitude))
          .toList();
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: outlineColor.toARGB32(),
          lineWidth: 8,
        ),
      );
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(coordinates: coords),
          lineColor: seg.color.toARGB32(),
          lineWidth: 5,
        ),
      );
    }

    final branches = widget.branchPreviewPolylines;
    if (branches != null) {
      for (final branch in branches) {
        if (branch.points.isEmpty) continue;
        await manager.create(
          PolylineAnnotationOptions(
            geometry: LineString(
              coordinates: branch.points
                  .map((p) => Position(p.longitude, p.latitude))
                  .toList(),
            ),
            lineColor: branch.color.toARGB32(),
            lineWidth: 4,
          ),
        );
      }
    }

    final inProgress = widget.inProgressPoints;
    if (inProgress != null && inProgress.isNotEmpty) {
      await manager.create(
        PolylineAnnotationOptions(
          geometry: LineString(
            coordinates: inProgress
                .map((p) => Position(p.longitude, p.latitude))
                .toList(),
          ),
          lineColor: (widget.inProgressColor ?? Colors.blue).toARGB32(),
          lineWidth: 3,
        ),
      );
    }
  }

  Future<void> _syncMarkers() async {
    await _labelMarkerDelegate.clear();
    await _junctionMarkerDelegate.clear();

    final branches = widget.branchPreviewPolylines;
    if (branches != null && mounted) {
      for (var i = 0; i < branches.length; i++) {
        final branch = branches[i];
        final name = branch.routeName;
        if (name == null || name.isEmpty) continue;
        if (branch.points.isEmpty) continue;
        final labelIdx = (branch.points.length * 0.15)
            .clamp(1, branch.points.length - 1)
            .toInt();
        final labelPos = branch.points[labelIdx];
        if (!mounted) return;
        await _labelMarkerDelegate.addWidgetMarker(
          context: context,
          widget: _RouteLabelWidget(
            name: name,
            color: branch.color,
          ),
          cacheKey: 'branch-label-$name',
          position: labelPos,
          iconAnchor: IconAnchor.CENTER,
        );
      }
    }

    final junction = widget.junctionCity;
    if (junction != null && mounted) {
      await _junctionMarkerDelegate.addWidgetMarker(
        context: context,
        widget: const _JunctionMarkerWidget(),
        cacheKey: 'trail-preview-junction',
        position: LatLng(junction.latitude, junction.longitude),
        iconAnchor: IconAnchor.CENTER,
      );
    }
  }

  List<LatLng> get _allPoints {
    final all = <LatLng>[];
    for (final seg in widget.segmentPolylines) {
      all.addAll(seg.points);
    }
    if (widget.inProgressPoints != null) {
      all.addAll(widget.inProgressPoints!);
    }
    return all;
  }

  /// Collects points near the junction for zooming:
  /// the start of each branch polyline (first ~15%).
  List<LatLng> get _junctionAreaPoints {
    final all = <LatLng>[];
    final branches = widget.branchPreviewPolylines;
    if (branches != null) {
      for (final branch in branches) {
        if (branch.points.isEmpty) continue;
        final end = (branch.points.length * 0.15)
            .clamp(1, branch.points.length)
            .toInt();
        all.addAll(branch.points.sublist(0, end));
      }
    }
    final junction = widget.junctionCity;
    if (junction != null) {
      all.add(LatLng(junction.latitude, junction.longitude));
    }
    return all;
  }

  Future<void> _fitBounds() async {
    final junctionPoints = _junctionAreaPoints;
    if (junctionPoints.length > 1) {
      await MapUtil.fitBounds(
        mapController: _map,
        points: junctionPoints,
        zoomConstant: 1.5,
      );
    } else {
      final points = _allPoints;
      if (points.isEmpty) return;
      await MapUtil.fitBounds(
        mapController: _map,
        points: points,
        zoomConstant: 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPoints = _allPoints;
    if (allPoints.isEmpty) {
      return const SizedBox.shrink();
    }
    final isDark = context.isDarkMode;
    return MapWidget(
      styleUri: isDark ? MapboxMapStyle.dark : MapboxMapStyle.light,
      cameraOptions: MapUtil.cameraForPoints(
            points: allPoints,
            zoomConstant: 2,
          ) ??
          CameraOptions(
            center: Point(
              coordinates: Position(
                allPoints.first.longitude,
                allPoints.first.latitude,
              ),
            ),
            zoom: 8,
          ),
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (_) => _onStyleLoaded(),
    );
  }
}

/// Small pill label for route names on the map.
class _RouteLabelWidget extends StatelessWidget {
  const _RouteLabelWidget({
    required this.name,
    required this.color,
  });

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

/// Junction marker. Replaces Google Maps's red default
/// marker; Mapbox does not ship a built-in pin sprite.
class _JunctionMarkerWidget extends StatelessWidget {
  const _JunctionMarkerWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
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
