import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/geom/geometry_response.dart';

part 'city_response.g.dart';

@JsonSerializable()
class CityResponse extends Equatable {

  CityResponse({
    required this.id,
    required this.orderKey,
    required this.name,
    required this.slug, required this.etapeCity, required this.geom, required this.route, required this.routePoint, this.country,
    this.region,
    this.province,
    this.km,
    this.hasAtm,
    this.hasBarCafe,
    this.hasShop,
    this.hasMedClinic,
    this.hasPharmacy,
    this.hasFountain,
    this.hasPostOffice,
    this.hasTrainStation,
    this.shareUrl,
    this.search,
    this.bCityId,
    this.openweathermapId,
    this.notesTranslationId,
    this.hasTobaccoStore,
    this.hasAirport,
    this.hasBusStation,
    this.hasRestaurant,
  })  : latitude = geom.lat,
        longitude = geom.lon,
        routePointIds = routePoint.map((rp) => rp.id).toList(),
        routeIds = route.map((r) => r.id).toList();

  factory CityResponse.fromJson(Map<String, dynamic> json) =>
      _$CityResponseFromJson(json);
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<int> routeIds;
  final int id;
  @JsonKey(name: 'order_key')
  final int orderKey;
  final String name;
  final String? country;
  final String? region;
  final String? province;
  final String slug;
  final int? km;
  @JsonKey(name: 'has_atm', toJson: _boolToInt)
  final bool? hasAtm;
  @JsonKey(name: 'has_bar_cafe', toJson: _boolToInt)
  final bool? hasBarCafe;
  @JsonKey(name: 'has_shop', toJson: _boolToInt)
  final bool? hasShop;
  @JsonKey(name: 'has_med_clinic', toJson: _boolToInt)
  final bool? hasMedClinic;
  @JsonKey(name: 'has_pharmacy', toJson: _boolToInt)
  final bool? hasPharmacy;
  @JsonKey(name: 'has_fountain', toJson: _boolToInt)
  final bool? hasFountain;
  @JsonKey(name: 'has_post_office', toJson: _boolToInt)
  final bool? hasPostOffice;
  @JsonKey(name: 'has_train_station', toJson: _boolToInt)
  final bool? hasTrainStation;
  @JsonKey(name: 'etape_city', toJson: _boolToInt)
  final bool? etapeCity;
  @JsonKey(name: 'geo_point', includeToJson: false)
  final GeometryResponse geom;
  @JsonKey(name: 'share_url')
  final String? shareUrl;
  final String? search;
  @JsonKey(name: 'b_city_id')
  final String? bCityId;
  @JsonKey(name: 'openweathermap_id')
  final String? openweathermapId;
  @JsonKey(name: 'notes_translation_id')
  final int? notesTranslationId;
  @JsonKey(name: 'has_tobacco_store', toJson: _boolToInt)
  final bool? hasTobaccoStore;
  @JsonKey(name: 'has_airport', toJson: _boolToInt)
  final bool? hasAirport;
  @JsonKey(name: 'has_bus_station', toJson: _boolToInt)
  final bool? hasBusStation;
  @JsonKey(name: 'has_restaurant', toJson: _boolToInt)
  final bool? hasRestaurant;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<int> routePointIds;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double latitude;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double longitude;
  @JsonKey(name: 'route_point', includeToJson: false)
  final List<CityNestedObject> routePoint;
  @JsonKey(name: 'route', includeToJson: false)
  final List<CityNestedObject> route;

  Map<String, dynamic> toJson() {
    final json = _$CityResponseToJson(this);
    json.remove('routeIds');
    json.remove('routePointIds');
    return json;
  }

  @override
  List<Object?> get props => [
        routeIds,
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
        geom,
        shareUrl,
        search,
        bCityId,
        openweathermapId,
        notesTranslationId,
        hasTobaccoStore,
        hasAirport,
        hasBusStation,
        hasRestaurant,
        routePointIds,
        latitude,
        longitude,
        route,
        routePoint,
      ];
}

@JsonSerializable()
class CityNestedObject extends Equatable {
  const CityNestedObject({
    required this.id,
  });

  factory CityNestedObject.fromJson(Map<String, dynamic> json) =>
      _$CityNestedObjectFromJson(json);

  final int id;

  Map<String, dynamic> toJson() => _$CityNestedObjectToJson(this);

  @override
  List<Object> get props => [id];
}

int? _boolToInt(bool? value) => value == null ? null : (value ? 1 : 0);
