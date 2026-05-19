import 'dart:typed_data';

import 'package:remote_data/src/proto/proto.dart' as proto;

int? _boolToInt(bool? v) => v == null ? null : (v ? 1 : 0);

/// Parses RouteListResponse proto bytes to DB-shaped maps. Top-level for isolate/compute.
List<Map<String, dynamic>> parseRoutesProtoToMaps(Uint8List bytes) {
  final resp = proto.RouteListResponse.fromBuffer(bytes);
  return resp.items.map((r) {
    // backend may send '' for unset short_name; treat as null.
    final shortName =
        r.hasShortName() && r.shortName.isNotEmpty ? r.shortName : null;
    return <String, dynamic>{
      'id': r.id,
      'order_key': r.orderKey,
      'route_name': r.routeName,
      'route_sub_name': r.hasRouteSubName() ? r.routeSubName : null,
      'legend_color': r.hasLegendColor() ? r.legendColor : null,
      'light_legend_color':
          r.hasLightLegendColor() ? r.lightLegendColor : null,
      'dark_legend_color':
          r.hasDarkLegendColor() ? r.darkLegendColor : null,
      'short_name': shortName,
    };
  }).toList();
}

/// Parses RoutePointsListResponse proto bytes to DB-shaped maps. Top-level for isolate/compute.
List<Map<String, dynamic>> parseRoutePointsProtoToMaps(Uint8List bytes) {
  final resp = proto.RoutePointsListResponse.fromBuffer(bytes);
  return resp.items.map((r) {
    final gp = r.hasGeoPoint() ? r.geoPoint : null;
    return <String, dynamic>{
      'id': r.id,
      'order_key': r.orderKey,
      'elevation': r.elevation,
      'route_id': r.hasRouteId() ? r.routeId : null,
      'latitude': gp?.lat ?? 0.0,
      'longitude': gp?.lon ?? 0.0,
    };
  }).toList();
}

/// Parses CityListResponse proto bytes to DB-shaped maps (incl. route_ids, route_point_ids). Top-level for isolate/compute.
List<Map<String, dynamic>> parseCitiesProtoToMaps(Uint8List bytes) {
  final resp = proto.CityListResponse.fromBuffer(bytes);
  return resp.items.map((c) {
    final gp = c.hasGeoPoint() ? c.geoPoint : null;
    final lat = gp?.lat ?? 0.0;
    final lon = gp?.lon ?? 0.0;
    final routeIds = c.routes.map((e) => e.id).toList();
    final routePointIds = c.routePoints.map((e) => e.id).toList();
    return <String, dynamic>{
      'id': c.id,
      'order_key': 1,
      'name': c.name,
      'country': c.hasCountry() ? c.country : null,
      'region': c.hasRegion() ? c.region : null,
      'province': c.hasProvince() ? c.province : null,
      'slug': c.slug,
      'km': c.hasKm() ? c.km : null,
      'has_atm': _boolToInt(c.hasHasAtm() ? c.hasAtm : null),
      'has_bar_cafe': _boolToInt(c.hasHasBarCafe() ? c.hasBarCafe : null),
      'has_shop': _boolToInt(c.hasHasShop() ? c.hasShop : null),
      'has_med_clinic': _boolToInt(c.hasHasMedClinic() ? c.hasMedClinic : null),
      'has_pharmacy': _boolToInt(c.hasHasPharmacy() ? c.hasPharmacy : null),
      'has_fountain': _boolToInt(c.hasHasFountain() ? c.hasFountain : null),
      'has_post_office':
          _boolToInt(c.hasHasPostOffice() ? c.hasPostOffice : null),
      'has_train_station':
          _boolToInt(c.hasHasTrainStation() ? c.hasTrainStation : null),
      'etape_city': _boolToInt(c.hasEtapeCity() ? c.etapeCity : null),
      'share_url': c.hasShareUrl() ? c.shareUrl : null,
      'search': c.hasSearch() ? c.search : null,
      'has_tobacco_store':
          _boolToInt(c.hasHasTobaccoStore() ? c.hasTobaccoStore : null),
      'has_airport': _boolToInt(c.hasHasAirport() ? c.hasAirport : null),
      'has_bus_station':
          _boolToInt(c.hasHasBusStation() ? c.hasBusStation : null),
      'has_restaurant':
          _boolToInt(c.hasHasRestaurant() ? c.hasRestaurant : null),
      'latitude': lat,
      'longitude': lon,
      'route_ids': routeIds,
      'route_point_ids': routePointIds,
    };
  }).toList();
}

/// Parses routes, routePoints and cities proto in a single isolate to avoid
/// spawning 3 separate isolates. Top-level for isolate/compute.
List<List<Map<String, dynamic>>> parseAllCoreProto(List<Uint8List> inputs) {
  return [
    if (inputs[0].isNotEmpty) parseRoutesProtoToMaps(inputs[0]) else <Map<String, dynamic>>[],
    if (inputs[1].isNotEmpty) parseRoutePointsProtoToMaps(inputs[1]) else <Map<String, dynamic>>[],
    if (inputs[2].isNotEmpty) parseCitiesProtoToMaps(inputs[2]) else <Map<String, dynamic>>[],
  ];
}

/// Parses AltRoutePointsListResponse proto bytes. Returns map with
/// 'alt_route_points' and 'alt_route_points_values' lists. Top-level for isolate/compute.
Map<String, List<Map<String, dynamic>>> parseAltRoutePointsProtoToMaps(
    Uint8List bytes,) {
  final resp = proto.AltRoutePointsListResponse.fromBuffer(bytes);
  final points = <Map<String, dynamic>>[];
  final values = <Map<String, dynamic>>[];
  for (final p in resp.items) {
    points.add(<String, dynamic>{
      'id': p.id,
      'order_key': p.orderKey,
      'route_id': p.routeId,
      'color': p.color,
      'dotted': _boolToInt(p.dotted),
    });
    for (final v in p.altRoutePointsValues) {
      final gp = v.hasGeoPoint() ? v.geoPoint : null;
      values.add(<String, dynamic>{
        'id': v.id,
        'order_key': v.orderKey,
        'alt_route_points_id': v.altRoutePointsId,
        'latitude': gp?.lat ?? 0.0,
        'longitude': gp?.lon ?? 0.0,
      });
    }
  }
  return <String, List<Map<String, dynamic>>>{
    'alt_route_points': points,
    'alt_route_points_values': values,
  };
}

/// Parses AlbergueUserImagesListResponse proto bytes to DB-shaped maps. Top-level for isolate/compute.
List<Map<String, dynamic>> parseAlbergueUserImagesProtoToMaps(Uint8List bytes) {
  final resp = proto.AlbergueUserImagesListResponse.fromBuffer(bytes);
  return resp.items.map((e) => <String, dynamic>{
        'id': e.id,
        'albergue_id': e.albergueId,
        'file_name': e.fileKey,
        'width': null,
        'height': null,
      },).toList();
}
