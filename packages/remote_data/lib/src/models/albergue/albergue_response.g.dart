// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueResponse _$AlbergueResponseFromJson(Map<String, dynamic> json) =>
    AlbergueResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      cityId: (json['city_id'] as num).toInt(),
      facilities:
          FacilityResponse.fromJson(json['facilities'] as Map<String, dynamic>),
      prices: PriceResponse.fromJson(json['prices'] as Map<String, dynamic>),
      orderKey: (json['order_key'] as num?)?.toInt(),
      slug: json['slug'] as String?,
      citySlug: json['city_slug'] as String?,
      geom: json['geo_point'] == null
          ? null
          : GeometryResponse.fromJson(
              json['geo_point'] as Map<String, dynamic>),
      address: json['address'] as String?,
      postalCode: json['postal_code'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      country: json['country'] as String?,
      shareUrl: json['share_url'] as String?,
      numberOfDormitories: (json['number_of_dormitories'] as num?)?.toInt(),
      placesInDormitory: (json['places_in_dormitory'] as num?)?.toInt(),
      cityName: json['city_name'] as String?,
      images: (json['albergue_images'] as List<dynamic>?)
              ?.map((e) =>
                  AlbergueImageResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      operatingHours: json['operating_hours'] == null
          ? null
          : OperatingHoursResponse.fromJson(
              json['operating_hours'] as Map<String, dynamic>),
      reviews: json['reviews'] == null
          ? null
          : ReviewResponse.fromJson(json['reviews'] as Map<String, dynamic>),
      socialMedias: json['social_media'] == null
          ? null
          : AlbergueSocialMediaResponse.fromJson(
              json['social_media'] as Map<String, dynamic>),
      phones: (json['phones'] as List<dynamic>?)
              ?.map((e) =>
                  AlberguePhoneResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      emails: (json['emails'] as List<dynamic>?)
              ?.map((e) =>
                  AlbergueEmailResponse.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: (json['status'] as num?)?.toInt(),
      isMunicipal: json['is_municipal'] as bool?,
      isAlbergue: json['is_albergue'] as bool?,
      reservationTranslationId:
          (json['reservation_translation_id'] as num?)?.toInt(),
      openSeasonTranslationId:
          (json['open_season_translation_id'] as num?)?.toInt(),
      web: json['web'] as String?,
      bookingComUrl: json['booking_com_url'] as String?,
      distCosta: (json['dist_costa'] as num?)?.toDouble(),
      distLitoral: (json['dist_litoral'] as num?)?.toDouble(),
      reserveUrl: json['reserve_url'] as String?,
      bookingPrice: (json['booking_price'] as num?)?.toDouble(),
      bookingPriceUpdatedAt: json['booking_price_updated_at'] as String?,
    );

Map<String, dynamic> _$AlbergueResponseToJson(AlbergueResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_key': instance.orderKey,
      'name': instance.name,
      'slug': instance.slug,
      'city_slug': instance.citySlug,
      'status': instance.status,
      'is_municipal': _boolToInt(instance.isMunicipal),
      'is_albergue': _boolToInt(instance.isAlbergue),
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

FacilityResponse _$FacilityResponseFromJson(Map<String, dynamic> json) =>
    FacilityResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      hasKitchen: json['has_kitchen'] as bool?,
      hasCooktops: json['has_cooktops'] as bool?,
      hasMicrowave: json['has_microwave'] as bool?,
      hasWaterBoiler: json['has_water_boiler'] as bool?,
      hasPlatesUtensils: json['has_plates_utensils'] as bool?,
      hasCookingPots: json['has_cooking_pots'] as bool?,
      hasBreakfast: json['has_breakfast'] as bool?,
      isBreakfastIncluded: json['is_breakfast_included'] as bool?,
      hasClothesLine: json['has_clothes_line'] as bool?,
      hasWifi: json['has_wifi'] as bool?,
      hasTv: json['has_tv'] as bool?,
      hasRestaurant: json['has_restaurant'] as bool?,
      hasCommunityDinner: json['has_community_dinner'] as bool?,
      hasDinner: json['has_dinner'] as bool?,
      hasWashingMachine: json['has_washing_machine'] as bool?,
      hasSpinDryer: json['has_spin_dryer'] as bool?,
      hasHandWashingSink: json['has_hand_washing_sink'] as bool?,
      hasTumbleDryer: json['has_tumble_dryer'] as bool?,
      hasIndividualPowerplug: json['has_individual_powerplug'] as bool?,
      hasPrivateLockers: json['has_private_lockers'] as bool?,
      hasCurtains: json['has_curtains'] as bool?,
      hasOven: json['has_oven'] as bool?,
      hasVendingMachine: json['has_vending_machine'] as bool?,
      hasFullLaundryService: json['has_full_laundry_service'] as bool?,
      hasFridge: json['has_fridge'] as bool?,
      hasLunch: json['has_lunch'] as bool?,
      hasVegetarianOption: json['has_vegetarian_option'] as bool?,
      hasSwimmingPool: json['has_swimming_pool'] as bool?,
      hasDonativoBreakfast: json['has_donativo_breakfast'] as bool?,
      hasCubeBeds: json['has_cube_beds'] as bool?,
      hasCommunityLunch: json['has_community_lunch'] as bool?,
      isVegetarian: json['is_vegetarian'] as bool?,
      isVegan: json['is_vegan'] as bool?,
      isOrganic: json['is_organic'] as bool?,
      petsAllowed: json['pets_allowed'] as bool?,
      hasVeganOption: json['has_vegan_option'] as bool?,
      hasCottonSheets: json['has_cotton_sheets'] as bool?,
      isDinnerIncluded: json['is_dinner_included'] as bool?,
    );

Map<String, dynamic> _$FacilityResponseToJson(FacilityResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'has_kitchen': _boolToInt(instance.hasKitchen),
      'has_cooktops': _boolToInt(instance.hasCooktops),
      'has_microwave': _boolToInt(instance.hasMicrowave),
      'has_water_boiler': _boolToInt(instance.hasWaterBoiler),
      'has_plates_utensils': _boolToInt(instance.hasPlatesUtensils),
      'has_cooking_pots': _boolToInt(instance.hasCookingPots),
      'has_breakfast': _boolToInt(instance.hasBreakfast),
      'is_breakfast_included': _boolToInt(instance.isBreakfastIncluded),
      'has_clothes_line': _boolToInt(instance.hasClothesLine),
      'has_wifi': _boolToInt(instance.hasWifi),
      'has_tv': _boolToInt(instance.hasTv),
      'has_restaurant': _boolToInt(instance.hasRestaurant),
      'has_community_dinner': _boolToInt(instance.hasCommunityDinner),
      'has_dinner': _boolToInt(instance.hasDinner),
      'has_washing_machine': _boolToInt(instance.hasWashingMachine),
      'has_spin_dryer': _boolToInt(instance.hasSpinDryer),
      'has_hand_washing_sink': _boolToInt(instance.hasHandWashingSink),
      'has_tumble_dryer': _boolToInt(instance.hasTumbleDryer),
      'has_individual_powerplug': _boolToInt(instance.hasIndividualPowerplug),
      'has_private_lockers': _boolToInt(instance.hasPrivateLockers),
      'has_curtains': _boolToInt(instance.hasCurtains),
      'has_oven': _boolToInt(instance.hasOven),
      'has_vending_machine': _boolToInt(instance.hasVendingMachine),
      'has_full_laundry_service': _boolToInt(instance.hasFullLaundryService),
      'has_fridge': _boolToInt(instance.hasFridge),
      'has_lunch': _boolToInt(instance.hasLunch),
      'has_vegetarian_option': _boolToInt(instance.hasVegetarianOption),
      'has_swimming_pool': _boolToInt(instance.hasSwimmingPool),
      'has_donativo_breakfast': _boolToInt(instance.hasDonativoBreakfast),
      'has_cube_beds': _boolToInt(instance.hasCubeBeds),
      'has_community_lunch': _boolToInt(instance.hasCommunityLunch),
      'is_vegetarian': _boolToInt(instance.isVegetarian),
      'is_vegan': _boolToInt(instance.isVegan),
      'is_organic': _boolToInt(instance.isOrganic),
      'pets_allowed': _boolToInt(instance.petsAllowed),
      'albergue_id': instance.albergueId,
      'has_vegan_option': _boolToInt(instance.hasVeganOption),
      'has_cotton_sheets': _boolToInt(instance.hasCottonSheets),
      'is_dinner_included': _boolToInt(instance.isDinnerIncluded),
    };

OperatingHoursResponse _$OperatingHoursResponseFromJson(
        Map<String, dynamic> json) =>
    OperatingHoursResponse(
      albergueId: (json['albergue_id'] as num).toInt(),
      id: (json['id'] as num).toInt(),
      checkinTime: json['checkin_time'] as String?,
      checkoutTime: json['checkout_time'] as String?,
      closeTime: json['close_time'] as String?,
      openFrom: json['open_from'] as String?,
      openFromEx: json['open_from_ex'] as String?,
      openFromEx2: json['open_from_ex2'] as String?,
      openTo: json['open_to'] as String?,
      openToEx: json['open_to_ex'] as String?,
      openToEx2: json['open_to_ex2'] as String?,
      opens: json['opens'] as String?,
      openAdditionalInformation:
          json['open_additional_information'] as Map<String, dynamic>?,
      unknownOpenSeason: json['unknown_open_season'] as bool?,
      opensAllYear: json['opens_all_year'] as bool?,
    );

Map<String, dynamic> _$OperatingHoursResponseToJson(
        OperatingHoursResponse instance) =>
    <String, dynamic>{
      'albergue_id': instance.albergueId,
      'id': instance.id,
      'checkin_time': instance.checkinTime,
      'checkout_time': instance.checkoutTime,
      'close_time': instance.closeTime,
      'open_from': instance.openFrom,
      'open_from_ex': instance.openFromEx,
      'open_from_ex2': instance.openFromEx2,
      'open_to': instance.openTo,
      'open_to_ex': instance.openToEx,
      'open_to_ex2': instance.openToEx2,
      'opens': instance.opens,
      'open_additional_information': instance.openAdditionalInformation,
      'unknown_open_season': _boolToInt(instance.unknownOpenSeason),
      'opens_all_year': _boolToInt(instance.opensAllYear),
    };

PriceResponse _$PriceResponseFromJson(Map<String, dynamic> json) =>
    PriceResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      priceFromDormitory: (json['price_from_dormitory'] as num?)?.toDouble(),
      priceFromDoubleroom: (json['price_from_double_room'] as num?)?.toDouble(),
      priceFromSingleroom: (json['price_from_single_room'] as num?)?.toDouble(),
      priceFromBedSharedRoom:
          (json['price_from_bed_shared_room'] as num?)?.toDouble(),
      priceToDormitory: (json['price_to_dormitory'] as num?)?.toDouble(),
      priceToDoubleroom: (json['price_to_double_room'] as num?)?.toDouble(),
      priceToSingleroom: (json['price_to_single_room'] as num?)?.toDouble(),
      priceToQuatroroom: (json['price_to_quatro_room'] as num?)?.toDouble(),
      priceFromApartment: (json['price_from_apartment'] as num?)?.toDouble(),
      priceToApartment: (json['price_to_apartment'] as num?)?.toDouble(),
      priceFromTripleroom: (json['price_from_triple_room'] as num?)?.toDouble(),
      priceFromQuatroroom: (json['price_from_quatro_room'] as num?)?.toDouble(),
      priceToTripleroom: (json['price_to_triple_room'] as num?)?.toDouble(),
      priceToBedSharedRoom:
          (json['price_to_bed_shared_room'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PriceResponseToJson(PriceResponse instance) =>
    <String, dynamic>{
      'price_from_dormitory': instance.priceFromDormitory,
      'price_from_double_room': instance.priceFromDoubleroom,
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'price_from_single_room': instance.priceFromSingleroom,
      'price_from_bed_shared_room': instance.priceFromBedSharedRoom,
      'price_to_dormitory': instance.priceToDormitory,
      'price_to_double_room': instance.priceToDoubleroom,
      'price_to_single_room': instance.priceToSingleroom,
      'price_to_quatro_room': instance.priceToQuatroroom,
      'price_from_apartment': instance.priceFromApartment,
      'price_to_apartment': instance.priceToApartment,
      'price_from_triple_room': instance.priceFromTripleroom,
      'price_from_quatro_room': instance.priceFromQuatroroom,
      'price_to_triple_room': instance.priceToTripleroom,
      'price_to_bed_shared_room': instance.priceToBedSharedRoom,
    };

ReviewResponse _$ReviewResponseFromJson(Map<String, dynamic> json) =>
    ReviewResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      gRating: (json['g_rating'] as num?)?.toDouble(),
      bReviewScore: (json['b_review_score'] as num?)?.toDouble(),
      bId: json['b_id'] as String?,
    );

Map<String, dynamic> _$ReviewResponseToJson(ReviewResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'g_rating': instance.gRating,
      'b_review_score': instance.bReviewScore,
      'b_id': instance.bId,
    };

WifiResponse _$WifiResponseFromJson(Map<String, dynamic> json) => WifiResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      name: json['name'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$WifiResponseToJson(WifiResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'name': instance.name,
      'url': instance.url,
    };
