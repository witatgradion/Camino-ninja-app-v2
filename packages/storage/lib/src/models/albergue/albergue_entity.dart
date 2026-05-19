import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/models/albergue/email_entity.dart';
import 'package:storage/src/models/albergue/facility_entity.dart';
import 'package:storage/src/models/albergue/image_entity.dart';
import 'package:storage/src/models/albergue/operating_hours_entity.dart';
import 'package:storage/src/models/albergue/phone_entity.dart';
import 'package:storage/src/models/albergue/price_entity.dart';
import 'package:storage/src/models/albergue/review_entity.dart';
import 'package:storage/src/models/albergue/social_media_entity.dart';
import 'package:storage/src/models/bool_mapper.dart';

part 'albergue_entity.g.dart';

@JsonSerializable()
class AlbergueEntity {
  AlbergueEntity({
    required this.id,
    this.orderKey,
    required this.name,
    this.slug,
    this.citySlug,
    this.status,
    this.isMunicipal,
    this.isAlbergue,
    this.address,
    this.postalCode,
    this.province,
    this.region,
    this.country,
    this.shareUrl,
    this.reservationTranslationId,
    this.openSeasonTranslationId,
    required this.cityId,
    this.cityName,
    this.web,
    this.bookingComUrl,
    this.distCosta,
    this.distLitoral,
    this.reserveUrl,
    this.placesInDormitory,
    this.numberOfDormitories,
    this.latitude,
    this.longitude,
    this.bookingPrice,
    this.bookingPriceUpdatedAt,
    List<FacilityEntity>? facilities,
    List<PriceEntity>? prices,
    List<OperatingHoursEntity>? operatingHours,
    List<ReviewEntity>? reviews,
    List<PhoneEntity>? phones,
    List<EmailEntity>? emails,
    List<SocialMediaEntity>? socialMedias,
    List<ImageEntity>? images,
  })  : facilities = facilities ?? [],
        operatingHours = operatingHours ?? [],
        reviews = reviews ?? [],
        prices = prices ?? [],
        phones = phones ?? [],
        emails = emails ?? [],
        socialMedias = socialMedias ?? [];

  final int id;
  @JsonKey(name: 'order_key')
  final int? orderKey;
  final String name;
  final String? slug;
  @JsonKey(name: 'city_slug')
  final String? citySlug;
  final int? status;
  @JsonKey(name: 'is_municipal', fromJson: intToBool)
  final bool? isMunicipal;
  @JsonKey(name: 'is_albergue', fromJson: intToBool)
  final bool? isAlbergue;
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
  final double? latitude;
  final double? longitude;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<FacilityEntity> facilities;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<PriceEntity> prices;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<OperatingHoursEntity> operatingHours;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ReviewEntity> reviews;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<PhoneEntity> phones;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<EmailEntity> emails;
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<SocialMediaEntity> socialMedias;
  @JsonKey(includeFromJson: false, includeToJson: false)
  int? externalCityId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  int? externalRouteId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  int? numberOfReviews;
  @JsonKey(includeFromJson: false, includeToJson: false)
  double? ninjaRating;
  @JsonKey(name: 'booking_price')
  final double? bookingPrice;
  @JsonKey(name: 'booking_price_updated_at')
  final String? bookingPriceUpdatedAt;

  factory AlbergueEntity.fromJson(Map<String, dynamic> json) =>
      _$AlbergueEntityFromJson(json);

  Map<String, dynamic> toJson() => _$AlbergueEntityToJson(this);

  bool? isWithinOpenSeason({DateTime? compareDate}) {
    if (operatingHours.isEmpty) return null;
    final item = operatingHours.first;
    // Get current date (without time)
    final now = compareDate ?? DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);

    // Helper function to parse date string to DateTime
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.length != 10) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    // Helper function to update year for dates
    DateTime updateYear(DateTime date) {
      var year = now.year;
      return DateTime(year, date.month, date.day);
    }

    // Parse all dates
    DateTime? openFromDate = parseDate(item.openFrom);
    DateTime? openToDate = parseDate(item.openTo);
    DateTime? openFromExDate = parseDate(item.openFromEx);
    DateTime? openToExDate = parseDate(item.openToEx);
    DateTime? openFromEx2Date = parseDate(item.openFromEx2);
    DateTime? openToEx2Date = parseDate(item.openToEx2);

    // Update years for all valid dates
    if (openFromDate != null) openFromDate = updateYear(openFromDate);
    if (openToDate != null) openToDate = updateYear(openToDate);
    if (openFromExDate != null) openFromExDate = updateYear(openFromExDate);
    if (openToExDate != null) openToExDate = updateYear(openToExDate);
    if (openFromEx2Date != null) openFromEx2Date = updateYear(openFromEx2Date);
    if (openToEx2Date != null) openToEx2Date = updateYear(openToEx2Date);

    // If main open period is not defined, return null
    if (openFromDate == null || openToDate == null) {
      return null;
    }

    // Check if current date is within main open period
    if (!currentDate.isBefore(openFromDate) &&
        !currentDate.isAfter(openToDate)) {
      // Check exclusion period 1
      if (openFromExDate != null &&
          openToExDate != null &&
          !currentDate.isBefore(openFromExDate) &&
          !currentDate.isAfter(openToExDate)) {
        return false;
      }

      // Check exclusion period 2
      if (openFromEx2Date != null &&
          openToEx2Date != null &&
          !currentDate.isBefore(openFromEx2Date) &&
          !currentDate.isAfter(openToEx2Date)) {
        return false;
      }
      return true;
    }
    return false;
  }

  String? getFallbackOpenSeason(String languageCode) {
    try {
      final startDate =
          DateTime.tryParse(operatingHours.firstOrNull?.openFrom ?? '');
      final endDate =
          DateTime.tryParse(operatingHours.firstOrNull?.openTo ?? '');
      if (startDate == null || endDate == null) return null;
      final formatter = DateFormat('MMMM d', languageCode);
      return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
    } catch (e) {
      return null;
    }
  }

  String? additionalInformation(String languageCode) {
    try {
      return operatingHours
          .firstOrNull?.openAdditionalInformation?[languageCode];
    } catch (e) {
      return null;
    }
  }
}
