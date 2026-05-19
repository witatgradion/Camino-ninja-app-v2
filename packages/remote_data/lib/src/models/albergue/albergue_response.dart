import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/remote_data.dart';

part 'albergue_response.g.dart';

@JsonSerializable()
class AlbergueResponse {
  AlbergueResponse({
    required this.id,
    required this.name, required this.cityId, required this.facilities, required this.prices, this.orderKey,
    this.slug,
    this.citySlug,
    this.geom,
    this.address,
    this.postalCode,
    this.province,
    this.region,
    this.country,
    this.shareUrl,
    this.numberOfDormitories,
    this.placesInDormitory,
    this.cityName,
    this.images = const [],
    this.operatingHours,
    this.wifis = const [],
    this.reviews,
    this.socialMedias,
    this.phones = const [],
    this.emails = const [],
    this.status,
    this.isMunicipal,
    this.isAlbergue,
    this.reservationTranslationId,
    this.openSeasonTranslationId,
    this.web,
    this.bookingComUrl,
    this.distCosta,
    this.distLitoral,
    this.reserveUrl,
    this.bookingPrice,
    this.bookingPriceUpdatedAt,
  })  : latitude = geom?.lat,
        longitude = geom?.lon;

  factory AlbergueResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueResponseFromJson(json);
  final int id;
  @JsonKey(name: 'order_key')
  final int? orderKey;
  final String name;
  final String? slug;
  @JsonKey(name: 'city_slug')
  final String? citySlug;
  final int? status;
  @JsonKey(name: 'is_municipal', toJson: _boolToInt)
  final bool? isMunicipal;
  @JsonKey(name: 'is_albergue', toJson: _boolToInt)
  final bool? isAlbergue;
  @JsonKey(name: 'geo_point', includeToJson: false)
  final GeometryResponse? geom;
  final String? address;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final String? province;
  final String? region;
  final String? country;
  @JsonKey(name: 'share_url')
  final String? shareUrl;
  @JsonKey(name: 'reservation_translation_id')
  final int? reservationTranslationId;
  @JsonKey(name: 'open_season_translation_id')
  final int? openSeasonTranslationId;
  @JsonKey(name: 'city_id')
  final int cityId;
  @JsonKey(name: 'city_name')
  final String? cityName;
  final String? web;
  @JsonKey(name: 'booking_com_url')
  final String? bookingComUrl;
  @JsonKey(name: 'dist_costa')
  final double? distCosta;
  @JsonKey(name: 'dist_litoral')
  final double? distLitoral;
  @JsonKey(name: 'reserve_url')
  final String? reserveUrl;
  @JsonKey(name: 'places_in_dormitory')
  final int? placesInDormitory;
  @JsonKey(name: 'number_of_dormitories')
  final int? numberOfDormitories;
  @JsonKey(includeToJson: false)
  final FacilityResponse facilities;
  @JsonKey(name: 'albergue_images', includeToJson: false)
  final List<AlbergueImageResponse> images;
  @JsonKey(name: 'operating_hours', includeToJson: false)
  final OperatingHoursResponse? operatingHours;
  @JsonKey(includeToJson: false)
  final PriceResponse prices;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<WifiResponse> wifis;
  @JsonKey(includeToJson: false)
  final ReviewResponse? reviews;
  @JsonKey(includeToJson: false)
  final List<AlberguePhoneResponse> phones;
  @JsonKey(includeToJson: false)
  final List<AlbergueEmailResponse> emails;
  @JsonKey(name: 'social_media', includeToJson: false)
  final AlbergueSocialMediaResponse? socialMedias;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double? latitude;
  @JsonKey(includeFromJson: false, includeToJson: true)
  final double? longitude;
  @JsonKey(name: 'booking_price')
  final double? bookingPrice;
  @JsonKey(name: 'booking_price_updated_at')
  final String? bookingPriceUpdatedAt;

  Map<String, dynamic> toJson() => _$AlbergueResponseToJson(this);

  bool? isWithinOpenSeason() {
    if (operatingHours == null) {
      return null;
    }
    var item = operatingHours!;
    final now = DateTime.now();
    final currentDate = DateFormat('yyyy-MM-dd').format(now);

    String updateYear(String? dateString) {
      if (dateString == null || dateString.length != 10) {
        return dateString ?? '';
      }
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd')
          .format(DateTime(now.year, date.month, date.day));
    }

    item = OperatingHoursResponse(
      albergueId: item.albergueId,
      id: item.id,
      checkinTime: item.checkinTime,
      checkoutTime: item.checkoutTime,
      closeTime: item.closeTime,
      openFrom: updateYear(item.openFrom),
      openTo: updateYear(item.openTo),
      openFromEx: updateYear(item.openFromEx),
      openToEx: updateYear(item.openToEx),
      openFromEx2: updateYear(item.openFromEx2),
      openToEx2: updateYear(item.openToEx2),
      opens: item.opens,
    );

    if (item.openFrom != null && item.openTo != null) {
      if (currentDate.compareTo(item.openFrom!) >= 0 &&
          currentDate.compareTo(item.openTo!) <= 0) {
        if (item.openFromEx != null &&
            item.openToEx != null &&
            currentDate.compareTo(item.openFromEx!) >= 0 &&
            currentDate.compareTo(item.openToEx!) <= 0) {
          return false;
        }
        if (item.openFromEx2 != null &&
            item.openToEx2 != null &&
            currentDate.compareTo(item.openFromEx2!) >= 0 &&
            currentDate.compareTo(item.openToEx2!) <= 0) {
          return false;
        }
        return true;
      } else {
        return false;
      }
    }

    return null;
  }
}

@JsonSerializable()
class FacilityResponse {
  FacilityResponse({
    required this.id,
    required this.albergueId,
    this.hasKitchen,
    this.hasCooktops,
    this.hasMicrowave,
    this.hasWaterBoiler,
    this.hasPlatesUtensils,
    this.hasCookingPots,
    this.hasBreakfast,
    this.isBreakfastIncluded,
    this.hasClothesLine,
    this.hasWifi,
    this.hasTv,
    this.hasRestaurant,
    this.hasCommunityDinner,
    this.hasDinner,
    this.hasWashingMachine,
    this.hasSpinDryer,
    this.hasHandWashingSink,
    this.hasTumbleDryer,
    this.hasIndividualPowerplug,
    this.hasPrivateLockers,
    this.hasCurtains,
    this.hasOven,
    this.hasVendingMachine,
    this.hasFullLaundryService,
    this.hasFridge,
    this.hasLunch,
    this.hasVegetarianOption,
    this.hasSwimmingPool,
    this.hasDonativoBreakfast,
    this.hasCubeBeds,
    this.hasCommunityLunch,
    this.isVegetarian,
    this.isVegan,
    this.isOrganic,
    this.petsAllowed,
    this.hasVeganOption,
    this.hasCottonSheets,
    this.isDinnerIncluded,
  });

  factory FacilityResponse.fromJson(Map<String, dynamic> json) =>
      _$FacilityResponseFromJson(json);
  final int id;
  @JsonKey(name: 'has_kitchen', toJson: _boolToInt)
  final bool? hasKitchen;
  @JsonKey(name: 'has_cooktops', toJson: _boolToInt)
  final bool? hasCooktops;
  @JsonKey(name: 'has_microwave', toJson: _boolToInt)
  final bool? hasMicrowave;
  @JsonKey(name: 'has_water_boiler', toJson: _boolToInt)
  final bool? hasWaterBoiler;
  @JsonKey(name: 'has_plates_utensils', toJson: _boolToInt)
  final bool? hasPlatesUtensils;
  @JsonKey(name: 'has_cooking_pots', toJson: _boolToInt)
  final bool? hasCookingPots;
  @JsonKey(name: 'has_breakfast', toJson: _boolToInt)
  final bool? hasBreakfast;
  @JsonKey(name: 'is_breakfast_included', toJson: _boolToInt)
  final bool? isBreakfastIncluded;
  @JsonKey(name: 'has_clothes_line', toJson: _boolToInt)
  final bool? hasClothesLine;
  @JsonKey(name: 'has_wifi', toJson: _boolToInt)
  final bool? hasWifi;
  @JsonKey(name: 'has_tv', toJson: _boolToInt)
  final bool? hasTv;
  @JsonKey(name: 'has_restaurant', toJson: _boolToInt)
  final bool? hasRestaurant;
  @JsonKey(name: 'has_community_dinner', toJson: _boolToInt)
  final bool? hasCommunityDinner;
  @JsonKey(name: 'has_dinner', toJson: _boolToInt)
  final bool? hasDinner;
  @JsonKey(name: 'has_washing_machine', toJson: _boolToInt)
  final bool? hasWashingMachine;
  @JsonKey(name: 'has_spin_dryer', toJson: _boolToInt)
  final bool? hasSpinDryer;
  @JsonKey(name: 'has_hand_washing_sink', toJson: _boolToInt)
  final bool? hasHandWashingSink;
  @JsonKey(name: 'has_tumble_dryer', toJson: _boolToInt)
  final bool? hasTumbleDryer;
  @JsonKey(name: 'has_individual_powerplug', toJson: _boolToInt)
  final bool? hasIndividualPowerplug;
  @JsonKey(name: 'has_private_lockers', toJson: _boolToInt)
  final bool? hasPrivateLockers;
  @JsonKey(name: 'has_curtains', toJson: _boolToInt)
  final bool? hasCurtains;
  @JsonKey(name: 'has_oven', toJson: _boolToInt)
  final bool? hasOven;
  @JsonKey(name: 'has_vending_machine', toJson: _boolToInt)
  final bool? hasVendingMachine;
  @JsonKey(name: 'has_full_laundry_service', toJson: _boolToInt)
  final bool? hasFullLaundryService;
  @JsonKey(name: 'has_fridge', toJson: _boolToInt)
  final bool? hasFridge;
  @JsonKey(name: 'has_lunch', toJson: _boolToInt)
  final bool? hasLunch;
  @JsonKey(name: 'has_vegetarian_option', toJson: _boolToInt)
  final bool? hasVegetarianOption;
  @JsonKey(name: 'has_swimming_pool', toJson: _boolToInt)
  final bool? hasSwimmingPool;
  @JsonKey(name: 'has_donativo_breakfast', toJson: _boolToInt)
  final bool? hasDonativoBreakfast;
  @JsonKey(name: 'has_cube_beds', toJson: _boolToInt)
  final bool? hasCubeBeds;
  @JsonKey(name: 'has_community_lunch', toJson: _boolToInt)
  final bool? hasCommunityLunch;
  @JsonKey(name: 'is_vegetarian', toJson: _boolToInt)
  final bool? isVegetarian;
  @JsonKey(name: 'is_vegan', toJson: _boolToInt)
  final bool? isVegan;
  @JsonKey(name: 'is_organic', toJson: _boolToInt)
  final bool? isOrganic;
  @JsonKey(name: 'pets_allowed', toJson: _boolToInt)
  final bool? petsAllowed;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'has_vegan_option', toJson: _boolToInt)
  final bool? hasVeganOption;
  @JsonKey(name: 'has_cotton_sheets', toJson: _boolToInt)
  final bool? hasCottonSheets;
  @JsonKey(name: 'is_dinner_included', toJson: _boolToInt)
  final bool? isDinnerIncluded;

  Map<String, dynamic> toJson() => _$FacilityResponseToJson(this);
}

@JsonSerializable()
class OperatingHoursResponse {
  OperatingHoursResponse({
    required this.albergueId,
    required this.id,
    this.checkinTime,
    this.checkoutTime,
    this.closeTime,
    this.openFrom,
    this.openFromEx,
    this.openFromEx2,
    this.openTo,
    this.openToEx,
    this.openToEx2,
    this.opens,
    this.openAdditionalInformation,
    this.unknownOpenSeason,
    this.opensAllYear,
  });

  factory OperatingHoursResponse.fromJson(Map<String, dynamic> json) =>
      _$OperatingHoursResponseFromJson(json);
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  final int id;
  @JsonKey(name: 'checkin_time')
  final String? checkinTime;
  @JsonKey(name: 'checkout_time')
  final String? checkoutTime;
  @JsonKey(name: 'close_time')
  final String? closeTime;
  @JsonKey(name: 'open_from')
  final String? openFrom;
  @JsonKey(name: 'open_from_ex')
  final String? openFromEx;
  @JsonKey(name: 'open_from_ex2')
  final String? openFromEx2;
  @JsonKey(name: 'open_to')
  final String? openTo;
  @JsonKey(name: 'open_to_ex')
  final String? openToEx;
  @JsonKey(name: 'open_to_ex2')
  final String? openToEx2;
  final String? opens;
  @JsonKey(name: 'open_additional_information')
  final Map<String, dynamic>? openAdditionalInformation;
  @JsonKey(name: 'unknown_open_season', toJson: _boolToInt)
  final bool? unknownOpenSeason;
   @JsonKey(name: 'opens_all_year', toJson: _boolToInt)
  final bool? opensAllYear;

  Map<String, dynamic> toJson() => _$OperatingHoursResponseToJson(this);
}

extension OperatingHoursResponseToDatabaseExtension on OperatingHoursResponse {
  Map<String, dynamic> toDatabaseJson() {
    final dbJson = toJson()
      ..remove('open_additional_information')
      ..putIfAbsent(
          'open_additional_information',
          () => openAdditionalInformation != null
              ? jsonEncode(openAdditionalInformation)
              : null,);
    return dbJson;
  }
}

@JsonSerializable()
class PriceResponse {
  PriceResponse({
    required this.id,
    required this.albergueId,
    this.priceFromDormitory,
    this.priceFromDoubleroom,
    this.priceFromSingleroom,
    this.priceFromBedSharedRoom,
    this.priceToDormitory,
    this.priceToDoubleroom,
    this.priceToSingleroom,
    this.priceToQuatroroom,
    this.priceFromApartment,
    this.priceToApartment,
    this.priceFromTripleroom,
    this.priceFromQuatroroom,
    this.priceToTripleroom,
    this.priceToBedSharedRoom,
  });

  factory PriceResponse.fromJson(Map<String, dynamic> json) =>
      _$PriceResponseFromJson(json);

  @JsonKey(name: 'price_from_dormitory')
  final double? priceFromDormitory;
  @JsonKey(name: 'price_from_double_room')
  final double? priceFromDoubleroom;
  final int id;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'price_from_single_room')
  final double? priceFromSingleroom;
  @JsonKey(name: 'price_from_bed_shared_room')
  final double? priceFromBedSharedRoom;
  @JsonKey(name: 'price_to_dormitory')
  final double? priceToDormitory;
  @JsonKey(name: 'price_to_double_room')
  final double? priceToDoubleroom;
  @JsonKey(name: 'price_to_single_room')
  final double? priceToSingleroom;
  @JsonKey(name: 'price_to_quatro_room')
  final double? priceToQuatroroom;
  @JsonKey(name: 'price_from_apartment')
  final double? priceFromApartment;
  @JsonKey(name: 'price_to_apartment')
  final double? priceToApartment;
  @JsonKey(name: 'price_from_triple_room')
  final double? priceFromTripleroom;
  @JsonKey(name: 'price_from_quatro_room')
  final double? priceFromQuatroroom;
  @JsonKey(name: 'price_to_triple_room')
  final double? priceToTripleroom;
  @JsonKey(name: 'price_to_bed_shared_room')
  final double? priceToBedSharedRoom;

  Map<String, dynamic> toJson() => _$PriceResponseToJson(this);
}

@JsonSerializable()
class ReviewResponse {
  ReviewResponse({
    required this.id,
    required this.albergueId,
    this.gRating,
    this.bReviewScore,
    this.bId,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$ReviewResponseFromJson(json);
  final int id;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'g_rating')
  final double? gRating;
  @JsonKey(name: 'b_review_score')
  final double? bReviewScore;
  @JsonKey(name: 'b_id')
  final String? bId;

  Map<String, dynamic> toJson() => _$ReviewResponseToJson(this);
}

@JsonSerializable()
class WifiResponse {
  WifiResponse({
    required this.id,
    required this.albergueId,
    required this.name,
    required this.url,
  });

  factory WifiResponse.fromJson(Map<String, dynamic> json) =>
      _$WifiResponseFromJson(json);
  final int id;
  @JsonKey(name: 'albergue_id')
  final int albergueId;
  final String? name;
  final String? url;

  Map<String, dynamic> toJson() => _$WifiResponseToJson(this);
}

int? _boolToInt(bool? value) => value == null ? null : (value ? 1 : 0);
