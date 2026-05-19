// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityResponse _$CityResponseFromJson(Map<String, dynamic> json) => CityResponse(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String,
      etapeCity: json['etape_city'] as bool?,
      geom:
          GeometryResponse.fromJson(json['geo_point'] as Map<String, dynamic>),
      route: (json['route'] as List<dynamic>)
          .map((e) => CityNestedObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      routePoint: (json['route_point'] as List<dynamic>)
          .map((e) => CityNestedObject.fromJson(e as Map<String, dynamic>))
          .toList(),
      country: json['country'] as String?,
      region: json['region'] as String?,
      province: json['province'] as String?,
      km: (json['km'] as num?)?.toInt(),
      hasAtm: json['has_atm'] as bool?,
      hasBarCafe: json['has_bar_cafe'] as bool?,
      hasShop: json['has_shop'] as bool?,
      hasMedClinic: json['has_med_clinic'] as bool?,
      hasPharmacy: json['has_pharmacy'] as bool?,
      hasFountain: json['has_fountain'] as bool?,
      hasPostOffice: json['has_post_office'] as bool?,
      hasTrainStation: json['has_train_station'] as bool?,
      shareUrl: json['share_url'] as String?,
      search: json['search'] as String?,
      bCityId: json['b_city_id'] as String?,
      openweathermapId: json['openweathermap_id'] as String?,
      notesTranslationId: (json['notes_translation_id'] as num?)?.toInt(),
      hasTobaccoStore: json['has_tobacco_store'] as bool?,
      hasAirport: json['has_airport'] as bool?,
      hasBusStation: json['has_bus_station'] as bool?,
      hasRestaurant: json['has_restaurant'] as bool?,
    );

Map<String, dynamic> _$CityResponseToJson(CityResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'name': instance.name,
      'country': instance.country,
      'region': instance.region,
      'province': instance.province,
      'slug': instance.slug,
      'km': instance.km,
      'has_atm': _boolToInt(instance.hasAtm),
      'has_bar_cafe': _boolToInt(instance.hasBarCafe),
      'has_shop': _boolToInt(instance.hasShop),
      'has_med_clinic': _boolToInt(instance.hasMedClinic),
      'has_pharmacy': _boolToInt(instance.hasPharmacy),
      'has_fountain': _boolToInt(instance.hasFountain),
      'has_post_office': _boolToInt(instance.hasPostOffice),
      'has_train_station': _boolToInt(instance.hasTrainStation),
      'etape_city': _boolToInt(instance.etapeCity),
      'share_url': instance.shareUrl,
      'search': instance.search,
      'b_city_id': instance.bCityId,
      'openweathermap_id': instance.openweathermapId,
      'notes_translation_id': instance.notesTranslationId,
      'has_tobacco_store': _boolToInt(instance.hasTobaccoStore),
      'has_airport': _boolToInt(instance.hasAirport),
      'has_bus_station': _boolToInt(instance.hasBusStation),
      'has_restaurant': _boolToInt(instance.hasRestaurant),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

CityNestedObject _$CityNestedObjectFromJson(Map<String, dynamic> json) =>
    CityNestedObject(
      id: (json['id'] as num).toInt(),
    );

Map<String, dynamic> _$CityNestedObjectToJson(CityNestedObject instance) =>
    <String, dynamic>{
      'id': instance.id,
    };
