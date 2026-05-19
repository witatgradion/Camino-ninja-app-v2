import 'dart:convert';

import 'package:camino_ninja_flutter/mapbox/style_definitions/albergue_marker_style.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_albergues_map.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class AlbergueClusterDelegate {
  AlbergueClusterDelegate({
    required this.locations,
    this.onMarkerTap,
  });

  final List<AlbergueLocation> locations;
  final ValueChanged<AlbergueLocation>? onMarkerTap;

  static const _source = 'albergue-source';
  static const _clusterLayer = 'albergue-cluster-layer';
  static const _clusterBadgeLayer = 'albergue-cluster-badge-layer';
  static const _individualLayer = 'albergue-layer';

  Future<void> setup(StyleManager style) async {
    // Register icons once. The individual layer and the cluster's hotel
    // layer share the hotel-circle icon; the cluster's badge overlay
    // layer uses the solid circular badge.
    if (await style.getStyleImage(AlbergueMarkerStyle.iconId) == null) {
      await style.addStyleImage(
        AlbergueMarkerStyle.iconId,
        2,
        await AlbergueMarkerStyle.buildIcon(),
        false,
        [],
        [],
        null,
      );
    }
    if (await style.getStyleImage(AlbergueMarkerStyle.clusterBadgeIconId) ==
        null) {
      await style.addStyleImage(
        AlbergueMarkerStyle.clusterBadgeIconId,
        2,
        await AlbergueMarkerStyle.buildClusterBadge(),
        false,
        [],
        [],
        null,
      );
    }

    // Remove stale layers/source. Order mirrors the add-order below
    // (individual -> cluster hotel -> cluster badge) for readability.
    if (await style.styleLayerExists(_individualLayer)) {
      await style.removeStyleLayer(_individualLayer);
    }
    if (await style.styleLayerExists(_clusterLayer)) {
      await style.removeStyleLayer(_clusterLayer);
    }
    if (await style.styleLayerExists(_clusterBadgeLayer)) {
      await style.removeStyleLayer(_clusterBadgeLayer);
    }
    if (await style.styleSourceExists(_source)) {
      await style.removeStyleSource(_source);
    }

    if (locations.isEmpty) return;

    final features = locations
        .map(
          (loc) => {
            'type': 'Feature',
            'properties': {'id': loc.albergueId, 'name': loc.name},
            'geometry': {
              'type': 'Point',
              'coordinates': [loc.latLng.longitude, loc.latLng.latitude],
            },
          },
        )
        .toList();

    await style.addSource(
      GeoJsonSource(
        id: _source,
        data: jsonEncode({'type': 'FeatureCollection', 'features': features}),
        cluster: true,
        clusterMaxZoom: 16,
        clusterRadius: 50,
      ),
    );

    // Layer order matters (Mapbox's addLayer appends to the TOP of the
    // stack, so later = drawn on top). Desired stacking for this map:
    //   individual albergue (bottom)
    //   cluster hotel icon
    //   cluster count badge (on top of the cluster group)
    //   city marker (on top of everything, added outside this delegate
    //   via the city annotation manager — see controller)
    //
    // 1. individual albergue marker (bottom)
    await style.addLayer(SymbolLayer(id: _individualLayer, sourceId: _source));
    await style.setStyleLayerProperties(
      _individualLayer,
      jsonEncode(AlbergueMarkerStyle.individualLayerProps),
    );

    // 2. cluster hotel icon (middle)
    await style.addLayer(SymbolLayer(id: _clusterLayer, sourceId: _source));
    await style.setStyleLayerProperties(
      _clusterLayer,
      jsonEncode(AlbergueMarkerStyle.clusterHotelLayerProps),
    );

    // 3. cluster count badge (on top of the cluster hotel icon)
    await style.addLayer(
      SymbolLayer(id: _clusterBadgeLayer, sourceId: _source),
    );
    await style.setStyleLayerProperties(
      _clusterBadgeLayer,
      jsonEncode(AlbergueMarkerStyle.clusterBadgeLayerProps),
    );
  }

  /// Returns true if the tap was consumed (cluster or marker hit).
  Future<bool> handleTap(MapboxMap map, ScreenCoordinate point) async {
    try {
      final hits = await map.queryRenderedFeatures(
        RenderedQueryGeometry.fromScreenCoordinate(point),
        RenderedQueryOptions(
          layerIds: [_clusterLayer, _clusterBadgeLayer, _individualLayer],
        ),
      );
      final hit = hits.firstOrNull;
      if (hit == null) return false;

      final featureMap = hit.queriedFeature.feature
          .map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
      final props = (featureMap['properties'] as Map?)
          ?.map((k, v) => MapEntry(k.toString(), v));

      if (props != null && props.containsKey('cluster')) {
        final geometry = featureMap['geometry'] as Map?;
        final coords = geometry?['coordinates'] as List?;
        if (coords == null || coords.length < 2) return true;
        final currentZoom = (await map.getCameraState()).zoom;
        await map.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(
                (coords[0] as num).toDouble(),
                (coords[1] as num).toDouble(),
              ),
            ),
            zoom: currentZoom + 3,
          ),
          MapAnimationOptions(duration: 400),
        );
        return true;
      }

      if (onMarkerTap != null) {
        final rawId = props?['id'];
        final albergueId = rawId is int
            ? rawId
            : rawId is num
                ? rawId.toInt()
                : int.tryParse(rawId?.toString() ?? '');
        final location = locations.firstWhereOrNull(
          (loc) => loc.albergueId == albergueId,
        );
        if (location != null) {
          onMarkerTap!(location);
          return true;
        }
      }
    } catch (e) {
      AppLogger.e(
        'AlbergueClusterDelegate tap error',
        tag: 'AlbergueClusterDelegate',
        error: e,
      );
    }
    return false;
  }
}
