// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityEntity _$CityEntityFromJson(Map<String, dynamic> json) => CityEntity(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num).toInt(),
      name: json['name'] as String,
      country: json['country'] as String?,
      region: json['region'] as String?,
      province: json['province'] as String?,
      slug: json['slug'] as String,
      km: (json['km'] as num?)?.toInt(),
      hasAtm: intToBool((json['has_atm'] as num?)?.toInt()),
      hasBarCafe: intToBool((json['has_bar_cafe'] as num?)?.toInt()),
      hasShop: intToBool((json['has_shop'] as num?)?.toInt()),
      hasMedClinic: intToBool((json['has_med_clinic'] as num?)?.toInt()),
      hasPharmacy: intToBool((json['has_pharmacy'] as num?)?.toInt()),
      hasFountain: intToBool((json['has_fountain'] as num?)?.toInt()),
      hasPostOffice: intToBool((json['has_post_office'] as num?)?.toInt()),
      hasTrainStation: intToBool((json['has_train_station'] as num?)?.toInt()),
      etapeCity: intToBool((json['etape_city'] as num?)?.toInt()),
      shareUrl: json['share_url'] as String?,
      search: json['search'] as String?,
      bCityId: json['b_city_id'] as String?,
      openweathermapId: json['openweathermap_id'] as String?,
      notesTranslationId: (json['notes_translation_id'] as num?)?.toInt(),
      hasTobaccoStore: intToBool((json['has_tobacco_store'] as num?)?.toInt()),
      hasAirport: intToBool((json['has_airport'] as num?)?.toInt()),
      hasBusStation: intToBool((json['has_bus_station'] as num?)?.toInt()),
      hasRestaurant: intToBool((json['has_restaurant'] as num?)?.toInt()),
      hasAlbergues: intToBool((json['has_albergues'] as num?)?.toInt()),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CityEntityToJson(CityEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'name': instance.name,
      'country': instance.country,
      'region': instance.region,
      'province': instance.province,
      'slug': instance.slug,
      'km': instance.km,
      'has_atm': instance.hasAtm,
      'has_bar_cafe': instance.hasBarCafe,
      'has_shop': instance.hasShop,
      'has_med_clinic': instance.hasMedClinic,
      'has_pharmacy': instance.hasPharmacy,
      'has_fountain': instance.hasFountain,
      'has_post_office': instance.hasPostOffice,
      'has_train_station': instance.hasTrainStation,
      'etape_city': instance.etapeCity,
      'share_url': instance.shareUrl,
      'search': instance.search,
      'b_city_id': instance.bCityId,
      'openweathermap_id': instance.openweathermapId,
      'notes_translation_id': instance.notesTranslationId,
      'has_tobacco_store': instance.hasTobaccoStore,
      'has_airport': instance.hasAirport,
      'has_bus_station': instance.hasBusStation,
      'has_restaurant': instance.hasRestaurant,
      'has_albergues': instance.hasAlbergues,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'routes': instance.routes,
      'routePoints': instance.routePoints,
    };
