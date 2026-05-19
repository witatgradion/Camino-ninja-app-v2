import 'dart:math';

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/app_database.dart';
import 'package:storage/src/models/bool_mapper.dart';
import 'package:storage/src/models/models.dart';

part 'city_entity.g.dart';

@JsonSerializable()
class CityEntity extends Equatable {
  const CityEntity({
    required this.id,
    required this.orderKey,
    required this.name,
    this.country,
    this.region,
    this.province,
    required this.slug,
    this.km,
    this.hasAtm,
    this.hasBarCafe,
    this.hasShop,
    this.hasMedClinic,
    this.hasPharmacy,
    this.hasFountain,
    this.hasPostOffice,
    this.hasTrainStation,
    this.etapeCity,
    this.shareUrl,
    this.search,
    this.bCityId,
    this.openweathermapId,
    this.notesTranslationId,
    this.hasTobaccoStore,
    this.hasAirport,
    this.hasBusStation,
    this.hasRestaurant,
    this.hasAlbergues,
    required this.latitude,
    required this.longitude,
    this.routes = const [],
    this.routePoints = const [],
  });

  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  final String name;
  final String? country;
  final String? region;
  final String? province;
  final String slug;
  final int? km;
  @JsonKey(name: 'has_atm', fromJson: intToBool)
  final bool? hasAtm;
  @JsonKey(name: 'has_bar_cafe', fromJson: intToBool)
  final bool? hasBarCafe;
  @JsonKey(name: 'has_shop', fromJson: intToBool)
  final bool? hasShop;
  @JsonKey(name: 'has_med_clinic', fromJson: intToBool)
  final bool? hasMedClinic;
  @JsonKey(name: 'has_pharmacy', fromJson: intToBool)
  final bool? hasPharmacy;
  @JsonKey(name: 'has_fountain', fromJson: intToBool)
  final bool? hasFountain;
  @JsonKey(name: 'has_post_office', fromJson: intToBool)
  final bool? hasPostOffice;
  @JsonKey(name: 'has_train_station', fromJson: intToBool)
  final bool? hasTrainStation;
  @JsonKey(name: 'etape_city', fromJson: intToBool)
  final bool? etapeCity;
  @JsonKey(name: 'share_url')
  final String? shareUrl;
  final String? search;
  @JsonKey(name: 'b_city_id')
  final String? bCityId;
  @JsonKey(name: 'openweathermap_id')
  final String? openweathermapId;
  @JsonKey(name: 'notes_translation_id')
  final int? notesTranslationId;
  @JsonKey(name: 'has_tobacco_store', fromJson: intToBool)
  final bool? hasTobaccoStore;
  @JsonKey(name: 'has_airport', fromJson: intToBool)
  final bool? hasAirport;
  @JsonKey(name: 'has_bus_station', fromJson: intToBool)
  final bool? hasBusStation;
  @JsonKey(name: 'has_restaurant', fromJson: intToBool)
  final bool? hasRestaurant;
  @JsonKey(name: 'has_albergues', fromJson: intToBool)
  final bool? hasAlbergues;
  final double latitude;
  final double longitude;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final List<RouteEntity> routes;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final List<RoutePointEntity> routePoints;

  // List<int> get routeIds => routes.map((r) => r.id).toList();
  // List<int> get routePointIds => routePoints.map((rp) => rp.id).toList();

  @override
  List<Object?> get props => [
        id,
        orderKey,
        name,
        country,
        region,
        province,
        slug,
        km,
        hasAtm,
        hasBarCafe,
        hasShop,
        hasMedClinic,
        hasPharmacy,
        hasFountain,
        hasPostOffice,
        hasTrainStation,
        etapeCity,
        shareUrl,
        search,
        bCityId,
        openweathermapId,
        notesTranslationId,
        hasTobaccoStore,
        hasAirport,
        hasBusStation,
        hasRestaurant,
        hasAlbergues,
        latitude,
        longitude,
        routes,
        routePoints,
      ];

  factory CityEntity.fromJson(Map<String, dynamic> json) =>
      _$CityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$CityEntityToJson(this);

  static Future<CityEntity> fromDatabaseRow(
    Map<String, dynamic> row,
    Future<List<RouteEntity>> Function(List<int> ids) fetchRoutes,
    Future<List<RoutePointEntity>> Function(List<int> ids) fetchRoutePoints,
  ) async {
    // Convert the concatenated IDs back to lists (safely handle invalid data)
    final routeIds = (row['route_ids'] as String?)
            ?.split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e))
            .whereType<int>()
            .toList() ??
        [];
    final routePointIds = (row['route_point_ids'] as String?)
            ?.split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e))
            .whereType<int>()
            .toList() ??
        [];

    // Fetch the related routes and route points
    final routes = await fetchRoutes(routeIds);
    final routePoints = await fetchRoutePoints(routePointIds);

    // Create a copy of the row without the concatenated IDs and order
    final cleanRow = Map<String, dynamic>.from(row)
      ..remove('route_ids')
      ..remove('route_point_ids')
      ..remove('route_point_order');

    // Create a new CityEntity with the routes and route points
    final city = CityEntity.fromJson(cleanRow);
    return CityEntity(
      id: city.id,
      orderKey: city.orderKey,
      name: city.name,
      country: city.country,
      region: city.region,
      province: city.province,
      slug: city.slug,
      km: city.km,
      hasAtm: city.hasAtm,
      hasBarCafe: city.hasBarCafe,
      hasShop: city.hasShop,
      hasMedClinic: city.hasMedClinic,
      hasPharmacy: city.hasPharmacy,
      hasFountain: city.hasFountain,
      hasPostOffice: city.hasPostOffice,
      hasTrainStation: city.hasTrainStation,
      etapeCity: city.etapeCity,
      shareUrl: city.shareUrl,
      search: city.search,
      bCityId: city.bCityId,
      openweathermapId: city.openweathermapId,
      notesTranslationId: city.notesTranslationId,
      hasTobaccoStore: city.hasTobaccoStore,
      hasAirport: city.hasAirport,
      hasBusStation: city.hasBusStation,
      hasRestaurant: city.hasRestaurant,
      hasAlbergues: city.hasAlbergues,
      latitude: city.latitude,
      longitude: city.longitude,
      routes: routes,
      routePoints: routePoints,
    );
  }

  /// Lite version: uses pre-fetched route points from cache instead of DB queries
  static CityEntity fromDatabaseRowLite(
    Map<String, dynamic> row,
    List<RoutePointEntity> allRoutePoints,
  ) {
    final routePointIds = (row['route_point_ids'] as String?)
            ?.split(',')
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e))
            .whereType<int>()
            .toSet() ??
        <int>{};

    // Look up route points from provided list (O(n) but typically small)
    final routePoints = allRoutePoints
        .where((rp) => routePointIds.contains(rp.id))
        .toList();

    final cleanRow = Map<String, dynamic>.from(row)
      ..remove('route_ids')
      ..remove('route_point_ids')
      ..remove('route_point_order');

    final city = CityEntity.fromJson(cleanRow);
    return CityEntity(
      id: city.id,
      orderKey: city.orderKey,
      name: city.name,
      country: city.country,
      region: city.region,
      province: city.province,
      slug: city.slug,
      km: city.km,
      hasAtm: city.hasAtm,
      hasBarCafe: city.hasBarCafe,
      hasShop: city.hasShop,
      hasMedClinic: city.hasMedClinic,
      hasPharmacy: city.hasPharmacy,
      hasFountain: city.hasFountain,
      hasPostOffice: city.hasPostOffice,
      hasTrainStation: city.hasTrainStation,
      etapeCity: city.etapeCity,
      shareUrl: city.shareUrl,
      search: city.search,
      bCityId: city.bCityId,
      openweathermapId: city.openweathermapId,
      notesTranslationId: city.notesTranslationId,
      hasTobaccoStore: city.hasTobaccoStore,
      hasAirport: city.hasAirport,
      hasBusStation: city.hasBusStation,
      hasRestaurant: city.hasRestaurant,
      hasAlbergues: city.hasAlbergues,
      latitude: city.latitude,
      longitude: city.longitude,
      routes: const [], // Not needed for stage planner
      routePoints: routePoints,
    );
  }
}

Future<List<Destination>> calculateCityDistances(
  List<CityEntity> cities,
  List<RoutePointEntity> routePoints,
  AppDatabase databaseHelper,
) async {
  final result = <Destination>[];
  var cumulativeDistance = 0.0;

  for (var i = 0; i < cities.length; i++) {
    final currentCity = cities[i];
    var distanceFromPrevious = 0.0;

    if (i > 0) {
      final previousCity = cities[i - 1];
      distanceFromPrevious =
          getDistanceBetweenCities(previousCity, currentCity, routePoints);
      cumulativeDistance += distanceFromPrevious;
    }

    result.add(
      Destination(
        id: currentCity.id,
        name: currentCity.name,
        totalDistance: cumulativeDistance / 1000,
        distanceFromPrevious: distanceFromPrevious / 1000,
        availableServices: parseAvailableServices(
          city: currentCity,
          hasAlbergues: currentCity.hasAlbergues == true,
        ),
        etapeCity: currentCity.etapeCity == true,
        city: currentCity,
      ),
    );
  }

  return result;
}

double getDistanceBetweenCities(
  CityEntity city1,
  CityEntity city2,
  List<RoutePointEntity> routePoints,
) {
  // Guard against empty lists
  if (city1.routes.isEmpty ||
      city2.routes.isEmpty ||
      city1.routePoints.isEmpty ||
      city2.routePoints.isEmpty ||
      routePoints.isEmpty) {
    return 0.0;
  }

  // Find the route points that belong to the same route
  final commonRoute = city1.routes.firstWhere(
    (route) => city2.routes.any((r) => r.id == route.id),
    orElse: () => city1.routes.first,
  );

  // Get the route points for the common route
  final city1RoutePoint = city1.routePoints.firstWhere(
    (rp) => rp.routeId == commonRoute.id,
    orElse: () => city1.routePoints.first,
  );
  final city2RoutePoint = city2.routePoints.firstWhere(
    (rp) => rp.routeId == commonRoute.id,
    orElse: () => city2.routePoints.first,
  );

  var countStart = false;
  var routeLength = 0.0;

  for (var i = 0; i < routePoints.length; i++) {
    if (city1RoutePoint.id == routePoints[i].id) {
      countStart = true;
      routeLength = 0;
    } else if (countStart && i > 0) {
      final dist = calculateDistance(
        routePoints[i - 1].latitude,
        routePoints[i - 1].longitude,
        routePoints[i].latitude,
        routePoints[i].longitude,
      );
      final height =
          (routePoints[i].elevation - routePoints[i - 1].elevation).abs();
      routeLength += sqrt(dist * dist + height * height);
    }

    if (city2RoutePoint.id == routePoints[i].id) {
      return routeLength;
    }
  }

  return routeLength;
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = GeoConstants.earthRadiusM;
  final dLat = (lat2 - lat1) * (pi / 180);
  final dLon = (lon2 - lon1) * (pi / 180);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * (pi / 180)) *
          cos(lat2 * (pi / 180)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

List<AvailableService> parseAvailableServices({
  required CityEntity city,
  required bool hasAlbergues,
}) {
  final result = <AvailableService>[];
  if (hasAlbergues) {
    result.add(AvailableService.hotel);
  }
  if (city.hasAtm == true) {
    result.add(AvailableService.atm);
  }
  if (city.hasBarCafe == true) {
    result.add(AvailableService.cafe);
  }
  if (city.hasShop == true) {
    result.add(AvailableService.shopping);
  }
  if (city.hasTobaccoStore == true) {
    result.add(AvailableService.tobacco);
  }
  if (city.hasMedClinic == true) {
    result.add(AvailableService.clinic);
  }
  if (city.hasPharmacy == true) {
    result.add(AvailableService.pharmacy);
  }
  if (city.hasFountain == true) {
    result.add(AvailableService.fountain);
  }
  if (city.hasPostOffice == true) {
    result.add(AvailableService.postOffice);
  }
  if (city.hasTrainStation == true) {
    result.add(AvailableService.trainStation);
  }
  if (city.hasAirport == true) {
    result.add(AvailableService.airport);
  }
  if (city.hasBusStation == true) {
    result.add(AvailableService.busStation);
  }
  if (city.hasRestaurant == true) {
    result.add(AvailableService.restaurant);
  }

  return result;
}
