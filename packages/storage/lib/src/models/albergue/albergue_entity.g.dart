// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueEntity _$AlbergueEntityFromJson(Map<String, dynamic> json) =>
    AlbergueEntity(
      id: (json['id'] as num).toInt(),
      orderKey: (json['order_key'] as num?)?.toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String?,
      citySlug: json['city_slug'] as String?,
      status: (json['status'] as num?)?.toInt(),
      isMunicipal: intToBool((json['is_municipal'] as num?)?.toInt()),
      isAlbergue: intToBool((json['is_albergue'] as num?)?.toInt()),
      address: json['address'] as String?,
      postalCode: json['postal_code'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      shareUrl: json['share_url'] as String?,
      reservationTranslationId:
          (json['reservation_translation_id'] as num?)?.toInt(),
      openSeasonTranslationId:
          (json['open_season_translation_id'] as num?)?.toInt(),
      cityId: (json['city_id'] as num).toInt(),
      cityName: json['city_name'] as String?,
      web: json['web'] as String?,
      bookingComUrl: json['booking_com_url'] as String?,
      distCosta: (json['dist_costa'] as num?)?.toDouble(),
      distLitoral: (json['dist_litoral'] as num?)?.toDouble(),
      reserveUrl: json['reserve_url'] as String?,
      placesInDormitory: (json['places_in_dormitory'] as num?)?.toInt(),
      numberOfDormitories: (json['number_of_dormitories'] as num?)?.toInt(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      bookingPrice: (json['booking_price'] as num?)?.toDouble(),
      bookingPriceUpdatedAt: json['booking_price_updated_at'] as String?,
    );

Map<String, dynamic> _$AlbergueEntityToJson(AlbergueEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'name': instance.name,
      'slug': instance.slug,
      'city_slug': instance.citySlug,
      'status': instance.status,
      'is_municipal': instance.isMunicipal,
      'is_albergue': instance.isAlbergue,
      'address': instance.address,
      'postal_code': instance.postalCode,
      'province': instance.province,
      'region': instance.region,
      'country': instance.country,
      'share_url': instance.shareUrl,
      'reservation_translation_id': instance.reservationTranslationId,
      'open_season_translation_id': instance.openSeasonTranslationId,
      'city_id': instance.cityId,
      'city_name': instance.cityName,
      'web': instance.web,
      'booking_com_url': instance.bookingComUrl,
      'dist_costa': instance.distCosta,
      'dist_litoral': instance.distLitoral,
      'reserve_url': instance.reserveUrl,
      'places_in_dormitory': instance.placesInDormitory,
      'number_of_dormitories': instance.numberOfDormitories,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'booking_price': instance.bookingPrice,
      'booking_price_updated_at': instance.bookingPriceUpdatedAt,
    };
