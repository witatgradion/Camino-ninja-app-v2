import 'dart:convert';

import 'package:camino_ninja_flutter/mapbox/style_definitions/route_layer_style_defs.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

const _routeLinesSource = 'route-lines';
const _routeLabelsSource = 'route-labels';
const _routeLinesLayer = 'route-lines-layer';
const _routeLabelsLayer = 'route-labels-layer';

class RouteLayerDelegate {
  int? _highlightedRouteId;

  int? get highlightedRouteId => _highlightedRouteId;

  Future<void> setup(
    StyleManager style,
    String linesGeoJson,
    String labelsGeoJson,
  ) async {
    await teardown(style);

    await style.addSource(
      GeoJsonSource(id: _routeLinesSource, data: linesGeoJson),
    );
    await style.addSource(
      GeoJsonSource(id: _routeLabelsSource, data: labelsGeoJson),
    );

    await style.addLayer(
      LineLayer(id: _routeLinesLayer, sourceId: _routeLinesSource),
    );
    await style.setStyleLayerProperties(
      _routeLinesLayer,
      jsonEncode(RouteLayerStyleDefs.lineLayer),
    );

    await style.addLayer(
      SymbolLayer(id: _routeLabelsLayer, sourceId: _routeLabelsSource),
    );
    await style.setStyleLayerProperties(
      _routeLabelsLayer,
      jsonEncode(RouteLayerStyleDefs.labelLayer),
    );
  }

  Future<void> updateSourceData(
    StyleManager style,
    String linesGeoJson,
    String labelsGeoJson,
  ) async {
    final linesExist = await style.styleSourceExists(_routeLinesSource);
    if (!linesExist) return;

    await style.setStyleSourceProperty(
      _routeLinesSource,
      'data',
      linesGeoJson,
    );
    await style.setStyleSourceProperty(
      _routeLabelsSource,
      'data',
      labelsGeoJson,
    );
  }

  Future<void> teardown(StyleManager style) async {
    try {
      if (await style.styleLayerExists(_routeLabelsLayer)) {
        await style.removeStyleLayer(_routeLabelsLayer);
      }
      if (await style.styleLayerExists(_routeLinesLayer)) {
        await style.removeStyleLayer(_routeLinesLayer);
      }
      if (await style.styleSourceExists(_routeLabelsSource)) {
        await style.removeStyleSource(_routeLabelsSource);
      }
      if (await style.styleSourceExists(_routeLinesSource)) {
        await style.removeStyleSource(_routeLinesSource);
      }
    } catch (_) {}
  }

  Future<void> _setRouteHighlightedState(
    MapboxMap map,
    int routeId,
    bool highlighted,
  ) async {
    final state = jsonEncode({'highlighted': highlighted});
    final featureId = routeId.toString();
    await Future.wait([
      map.setFeatureState(
        _routeLinesSource,
        null,
        featureId,
        state,
      ),
      map.setFeatureState(
        _routeLabelsSource,
        null,
        featureId,
        state,
      ),
    ]);
  }

  Future<void> applyHighlightedRoute(
    MapboxMap map,
    int? routeId,
  ) async {
    final style = map.style;
    if (!await style.styleSourceExists(_routeLinesSource)) return;
    if (_highlightedRouteId == routeId) return;

    final previous = _highlightedRouteId;
    _highlightedRouteId = routeId;

    if (previous != null) {
      await _setRouteHighlightedState(map, previous, false);
    }
    if (routeId != null) {
      await _setRouteHighlightedState(map, routeId, true);
    }
  }

  int? _extractRouteId(QueriedRenderedFeature? hit) {
    if (hit == null) return null;
    try {
      final featureMap = hit.queriedFeature.feature.map<String, dynamic>(
        (key, value) => MapEntry(key!, value),
      );
      final properties = featureMap['properties'] as Map<dynamic, dynamic>?;
      if (properties == null) return null;
      final routeId = properties['routeId'];
      if (routeId is int) return routeId;
      if (routeId is num) return routeId.toInt();
      if (routeId is String) return int.tryParse(routeId);
    } catch (_) {}
    return null;
  }

  Future<int?> queryTappedRouteId(
    MapboxMap map,
    ScreenCoordinate point,
  ) async {
    final labelHits = await map.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenCoordinate(point),
      RenderedQueryOptions(layerIds: [_routeLabelsLayer]),
    );
    final labelRouteId = _extractRouteId(labelHits.firstOrNull);
    if (labelRouteId != null) return labelRouteId;

    const tapPadding = 10.0;
    final screenBox = ScreenBox(
      min: ScreenCoordinate(
        x: point.x - tapPadding,
        y: point.y - tapPadding,
      ),
      max: ScreenCoordinate(
        x: point.x + tapPadding,
        y: point.y + tapPadding,
      ),
    );
    final lineHits = await map.queryRenderedFeatures(
      RenderedQueryGeometry.fromScreenBox(screenBox),
      RenderedQueryOptions(layerIds: [_routeLinesLayer]),
    );
    return _extractRouteId(lineHits.firstOrNull);
  }
}
