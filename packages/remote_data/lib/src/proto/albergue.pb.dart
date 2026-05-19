//
//  Generated code. Do not modify.
//  source: albergue.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Albergue extends $pb.GeneratedMessage {
  factory Albergue({
    $core.int? id,
    $core.String? name,
    $core.String? slug,
    $core.int? orderKey,
    $core.int? status,
    $core.bool? isActive,
    $0.GeoPoint? geoPoint,
    $core.bool? isMunicipal,
    $core.bool? isAlbergue,
    $core.String? cityName,
    $core.String? address,
    $core.String? postalCode,
    $core.String? province,
    $core.String? region,
    $core.String? country,
    $core.String? shareUrl,
    $core.String? web,
    $core.int? reservationTranslationId,
    $core.int? openSeasonTranslationId,
    $core.int? placesInDormitory,
    $core.int? numberOfDormitories,
    $core.int? cityId,
    $core.String? bookingComUrl,
    $core.int? distCosta,
    $core.int? distLitoral,
    $core.String? reserverUrl,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
    $core.Iterable<AlbergueEmail>? emails,
    $core.Iterable<AlberguePhone>? phones,
    $core.Iterable<AlbergueImage>? albergueImages,
    AlbergueFacilities? facilities,
    AlbergueOperatingHours? operatingHours,
    AlberguePrices? prices,
    AlbergueReviews? reviews,
    AlbergueSocialMedia? socialMedia,
    $core.Iterable<AlbergueWifi>? wifis,
    $core.double? bookingPrice,
    $core.String? bookingPriceUpdatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    if (orderKey != null) result.orderKey = orderKey;
    if (status != null) result.status = status;
    if (isActive != null) result.isActive = isActive;
    if (geoPoint != null) result.geoPoint = geoPoint;
    if (isMunicipal != null) result.isMunicipal = isMunicipal;
    if (isAlbergue != null) result.isAlbergue = isAlbergue;
    if (cityName != null) result.cityName = cityName;
    if (address != null) result.address = address;
    if (postalCode != null) result.postalCode = postalCode;
    if (province != null) result.province = province;
    if (region != null) result.region = region;
    if (country != null) result.country = country;
    if (shareUrl != null) result.shareUrl = shareUrl;
    if (web != null) result.web = web;
    if (reservationTranslationId != null) result.reservationTranslationId = reservationTranslationId;
    if (openSeasonTranslationId != null) result.openSeasonTranslationId = openSeasonTranslationId;
    if (placesInDormitory != null) result.placesInDormitory = placesInDormitory;
    if (numberOfDormitories != null) result.numberOfDormitories = numberOfDormitories;
    if (cityId != null) result.cityId = cityId;
    if (bookingComUrl != null) result.bookingComUrl = bookingComUrl;
    if (distCosta != null) result.distCosta = distCosta;
    if (distLitoral != null) result.distLitoral = distLitoral;
    if (reserverUrl != null) result.reserverUrl = reserverUrl;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (emails != null) result.emails.addAll(emails);
    if (phones != null) result.phones.addAll(phones);
    if (albergueImages != null) result.albergueImages.addAll(albergueImages);
    if (facilities != null) result.facilities = facilities;
    if (operatingHours != null) result.operatingHours = operatingHours;
    if (prices != null) result.prices = prices;
    if (reviews != null) result.reviews = reviews;
    if (socialMedia != null) result.socialMedia = socialMedia;
    if (wifis != null) result.wifis.addAll(wifis);
    if (bookingPrice != null) result.bookingPrice = bookingPrice;
    if (bookingPriceUpdatedAt != null) result.bookingPriceUpdatedAt = bookingPriceUpdatedAt;
    return result;
  }

  Albergue._();

  factory Albergue.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Albergue.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Albergue', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'slug')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'orderKey', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'status', $pb.PbFieldType.O3)
    ..aOB(6, _omitFieldNames ? '' : 'isActive')
    ..aOM<$0.GeoPoint>(7, _omitFieldNames ? '' : 'geoPoint', subBuilder: $0.GeoPoint.create)
    ..aOB(8, _omitFieldNames ? '' : 'isMunicipal')
    ..aOB(9, _omitFieldNames ? '' : 'isAlbergue')
    ..aOS(10, _omitFieldNames ? '' : 'cityName')
    ..aOS(11, _omitFieldNames ? '' : 'address')
    ..aOS(12, _omitFieldNames ? '' : 'postalCode')
    ..aOS(13, _omitFieldNames ? '' : 'province')
    ..aOS(14, _omitFieldNames ? '' : 'region')
    ..aOS(15, _omitFieldNames ? '' : 'country')
    ..aOS(16, _omitFieldNames ? '' : 'shareUrl')
    ..aOS(17, _omitFieldNames ? '' : 'web')
    ..a<$core.int>(18, _omitFieldNames ? '' : 'reservationTranslationId', $pb.PbFieldType.O3)
    ..a<$core.int>(19, _omitFieldNames ? '' : 'openSeasonTranslationId', $pb.PbFieldType.O3)
    ..a<$core.int>(20, _omitFieldNames ? '' : 'placesInDormitory', $pb.PbFieldType.O3)
    ..a<$core.int>(21, _omitFieldNames ? '' : 'numberOfDormitories', $pb.PbFieldType.O3)
    ..a<$core.int>(22, _omitFieldNames ? '' : 'cityId', $pb.PbFieldType.O3)
    ..aOS(24, _omitFieldNames ? '' : 'bookingComUrl')
    ..a<$core.int>(25, _omitFieldNames ? '' : 'distCosta', $pb.PbFieldType.O3)
    ..a<$core.int>(26, _omitFieldNames ? '' : 'distLitoral', $pb.PbFieldType.O3)
    ..aOS(27, _omitFieldNames ? '' : 'reserverUrl')
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(30, _omitFieldNames ? '' : 'deletedAt')
    ..pc<AlbergueEmail>(31, _omitFieldNames ? '' : 'emails', $pb.PbFieldType.PM, subBuilder: AlbergueEmail.create)
    ..pc<AlberguePhone>(32, _omitFieldNames ? '' : 'phones', $pb.PbFieldType.PM, subBuilder: AlberguePhone.create)
    ..pc<AlbergueImage>(33, _omitFieldNames ? '' : 'albergueImages', $pb.PbFieldType.PM, subBuilder: AlbergueImage.create)
    ..aOM<AlbergueFacilities>(34, _omitFieldNames ? '' : 'facilities', subBuilder: AlbergueFacilities.create)
    ..aOM<AlbergueOperatingHours>(35, _omitFieldNames ? '' : 'operatingHours', subBuilder: AlbergueOperatingHours.create)
    ..aOM<AlberguePrices>(36, _omitFieldNames ? '' : 'prices', subBuilder: AlberguePrices.create)
    ..aOM<AlbergueReviews>(37, _omitFieldNames ? '' : 'reviews', subBuilder: AlbergueReviews.create)
    ..aOM<AlbergueSocialMedia>(38, _omitFieldNames ? '' : 'socialMedia', subBuilder: AlbergueSocialMedia.create)
    ..pc<AlbergueWifi>(39, _omitFieldNames ? '' : 'wifis', $pb.PbFieldType.PM, subBuilder: AlbergueWifi.create)
    ..a<$core.double>(40, _omitFieldNames ? '' : 'bookingPrice', $pb.PbFieldType.OD)
    ..aOS(41, _omitFieldNames ? '' : 'bookingPriceUpdatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Albergue clone() => Albergue()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Albergue copyWith(void Function(Albergue) updates) => super.copyWith((message) => updates(message as Albergue)) as Albergue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Albergue create() => Albergue._();
  @$core.override
  Albergue createEmptyInstance() => create();
  static $pb.PbList<Albergue> createRepeated() => $pb.PbList<Albergue>();
  @$core.pragma('dart2js:noInline')
  static Albergue getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Albergue>(create);
  static Albergue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get slug => $_getSZ(2);
  @$pb.TagNumber(3)
  set slug($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlug() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlug() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get orderKey => $_getIZ(3);
  @$pb.TagNumber(4)
  set orderKey($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOrderKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearOrderKey() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get status => $_getIZ(4);
  @$pb.TagNumber(5)
  set status($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isActive => $_getBF(5);
  @$pb.TagNumber(6)
  set isActive($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsActive() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsActive() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.GeoPoint get geoPoint => $_getN(6);
  @$pb.TagNumber(7)
  set geoPoint($0.GeoPoint value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasGeoPoint() => $_has(6);
  @$pb.TagNumber(7)
  void clearGeoPoint() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.GeoPoint ensureGeoPoint() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.bool get isMunicipal => $_getBF(7);
  @$pb.TagNumber(8)
  set isMunicipal($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsMunicipal() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsMunicipal() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get isAlbergue => $_getBF(8);
  @$pb.TagNumber(9)
  set isAlbergue($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsAlbergue() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsAlbergue() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get cityName => $_getSZ(9);
  @$pb.TagNumber(10)
  set cityName($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCityName() => $_has(9);
  @$pb.TagNumber(10)
  void clearCityName() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get address => $_getSZ(10);
  @$pb.TagNumber(11)
  set address($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAddress() => $_has(10);
  @$pb.TagNumber(11)
  void clearAddress() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get postalCode => $_getSZ(11);
  @$pb.TagNumber(12)
  set postalCode($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPostalCode() => $_has(11);
  @$pb.TagNumber(12)
  void clearPostalCode() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get province => $_getSZ(12);
  @$pb.TagNumber(13)
  set province($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasProvince() => $_has(12);
  @$pb.TagNumber(13)
  void clearProvince() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get region => $_getSZ(13);
  @$pb.TagNumber(14)
  set region($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRegion() => $_has(13);
  @$pb.TagNumber(14)
  void clearRegion() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get country => $_getSZ(14);
  @$pb.TagNumber(15)
  set country($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCountry() => $_has(14);
  @$pb.TagNumber(15)
  void clearCountry() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get shareUrl => $_getSZ(15);
  @$pb.TagNumber(16)
  set shareUrl($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasShareUrl() => $_has(15);
  @$pb.TagNumber(16)
  void clearShareUrl() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get web => $_getSZ(16);
  @$pb.TagNumber(17)
  set web($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasWeb() => $_has(16);
  @$pb.TagNumber(17)
  void clearWeb() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get reservationTranslationId => $_getIZ(17);
  @$pb.TagNumber(18)
  set reservationTranslationId($core.int value) => $_setSignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasReservationTranslationId() => $_has(17);
  @$pb.TagNumber(18)
  void clearReservationTranslationId() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get openSeasonTranslationId => $_getIZ(18);
  @$pb.TagNumber(19)
  set openSeasonTranslationId($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasOpenSeasonTranslationId() => $_has(18);
  @$pb.TagNumber(19)
  void clearOpenSeasonTranslationId() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.int get placesInDormitory => $_getIZ(19);
  @$pb.TagNumber(20)
  set placesInDormitory($core.int value) => $_setSignedInt32(19, value);
  @$pb.TagNumber(20)
  $core.bool hasPlacesInDormitory() => $_has(19);
  @$pb.TagNumber(20)
  void clearPlacesInDormitory() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.int get numberOfDormitories => $_getIZ(20);
  @$pb.TagNumber(21)
  set numberOfDormitories($core.int value) => $_setSignedInt32(20, value);
  @$pb.TagNumber(21)
  $core.bool hasNumberOfDormitories() => $_has(20);
  @$pb.TagNumber(21)
  void clearNumberOfDormitories() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.int get cityId => $_getIZ(21);
  @$pb.TagNumber(22)
  set cityId($core.int value) => $_setSignedInt32(21, value);
  @$pb.TagNumber(22)
  $core.bool hasCityId() => $_has(21);
  @$pb.TagNumber(22)
  void clearCityId() => $_clearField(22);

  @$pb.TagNumber(24)
  $core.String get bookingComUrl => $_getSZ(22);
  @$pb.TagNumber(24)
  set bookingComUrl($core.String value) => $_setString(22, value);
  @$pb.TagNumber(24)
  $core.bool hasBookingComUrl() => $_has(22);
  @$pb.TagNumber(24)
  void clearBookingComUrl() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.int get distCosta => $_getIZ(23);
  @$pb.TagNumber(25)
  set distCosta($core.int value) => $_setSignedInt32(23, value);
  @$pb.TagNumber(25)
  $core.bool hasDistCosta() => $_has(23);
  @$pb.TagNumber(25)
  void clearDistCosta() => $_clearField(25);

  @$pb.TagNumber(26)
  $core.int get distLitoral => $_getIZ(24);
  @$pb.TagNumber(26)
  set distLitoral($core.int value) => $_setSignedInt32(24, value);
  @$pb.TagNumber(26)
  $core.bool hasDistLitoral() => $_has(24);
  @$pb.TagNumber(26)
  void clearDistLitoral() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.String get reserverUrl => $_getSZ(25);
  @$pb.TagNumber(27)
  set reserverUrl($core.String value) => $_setString(25, value);
  @$pb.TagNumber(27)
  $core.bool hasReserverUrl() => $_has(25);
  @$pb.TagNumber(27)
  void clearReserverUrl() => $_clearField(27);

  @$pb.TagNumber(28)
  $core.String get createdAt => $_getSZ(26);
  @$pb.TagNumber(28)
  set createdAt($core.String value) => $_setString(26, value);
  @$pb.TagNumber(28)
  $core.bool hasCreatedAt() => $_has(26);
  @$pb.TagNumber(28)
  void clearCreatedAt() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get updatedAt => $_getSZ(27);
  @$pb.TagNumber(29)
  set updatedAt($core.String value) => $_setString(27, value);
  @$pb.TagNumber(29)
  $core.bool hasUpdatedAt() => $_has(27);
  @$pb.TagNumber(29)
  void clearUpdatedAt() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.String get deletedAt => $_getSZ(28);
  @$pb.TagNumber(30)
  set deletedAt($core.String value) => $_setString(28, value);
  @$pb.TagNumber(30)
  $core.bool hasDeletedAt() => $_has(28);
  @$pb.TagNumber(30)
  void clearDeletedAt() => $_clearField(30);

  @$pb.TagNumber(31)
  $pb.PbList<AlbergueEmail> get emails => $_getList(29);

  @$pb.TagNumber(32)
  $pb.PbList<AlberguePhone> get phones => $_getList(30);

  @$pb.TagNumber(33)
  $pb.PbList<AlbergueImage> get albergueImages => $_getList(31);

  @$pb.TagNumber(34)
  AlbergueFacilities get facilities => $_getN(32);
  @$pb.TagNumber(34)
  set facilities(AlbergueFacilities value) => $_setField(34, value);
  @$pb.TagNumber(34)
  $core.bool hasFacilities() => $_has(32);
  @$pb.TagNumber(34)
  void clearFacilities() => $_clearField(34);
  @$pb.TagNumber(34)
  AlbergueFacilities ensureFacilities() => $_ensure(32);

  @$pb.TagNumber(35)
  AlbergueOperatingHours get operatingHours => $_getN(33);
  @$pb.TagNumber(35)
  set operatingHours(AlbergueOperatingHours value) => $_setField(35, value);
  @$pb.TagNumber(35)
  $core.bool hasOperatingHours() => $_has(33);
  @$pb.TagNumber(35)
  void clearOperatingHours() => $_clearField(35);
  @$pb.TagNumber(35)
  AlbergueOperatingHours ensureOperatingHours() => $_ensure(33);

  @$pb.TagNumber(36)
  AlberguePrices get prices => $_getN(34);
  @$pb.TagNumber(36)
  set prices(AlberguePrices value) => $_setField(36, value);
  @$pb.TagNumber(36)
  $core.bool hasPrices() => $_has(34);
  @$pb.TagNumber(36)
  void clearPrices() => $_clearField(36);
  @$pb.TagNumber(36)
  AlberguePrices ensurePrices() => $_ensure(34);

  @$pb.TagNumber(37)
  AlbergueReviews get reviews => $_getN(35);
  @$pb.TagNumber(37)
  set reviews(AlbergueReviews value) => $_setField(37, value);
  @$pb.TagNumber(37)
  $core.bool hasReviews() => $_has(35);
  @$pb.TagNumber(37)
  void clearReviews() => $_clearField(37);
  @$pb.TagNumber(37)
  AlbergueReviews ensureReviews() => $_ensure(35);

  @$pb.TagNumber(38)
  AlbergueSocialMedia get socialMedia => $_getN(36);
  @$pb.TagNumber(38)
  set socialMedia(AlbergueSocialMedia value) => $_setField(38, value);
  @$pb.TagNumber(38)
  $core.bool hasSocialMedia() => $_has(36);
  @$pb.TagNumber(38)
  void clearSocialMedia() => $_clearField(38);
  @$pb.TagNumber(38)
  AlbergueSocialMedia ensureSocialMedia() => $_ensure(36);

  @$pb.TagNumber(39)
  $pb.PbList<AlbergueWifi> get wifis => $_getList(37);

  @$pb.TagNumber(40)
  $core.double get bookingPrice => $_getN(38);
  @$pb.TagNumber(40)
  set bookingPrice($core.double value) => $_setDouble(38, value);
  @$pb.TagNumber(40)
  $core.bool hasBookingPrice() => $_has(38);
  @$pb.TagNumber(40)
  void clearBookingPrice() => $_clearField(40);

  @$pb.TagNumber(41)
  $core.String get bookingPriceUpdatedAt => $_getSZ(39);
  @$pb.TagNumber(41)
  set bookingPriceUpdatedAt($core.String value) => $_setString(39, value);
  @$pb.TagNumber(41)
  $core.bool hasBookingPriceUpdatedAt() => $_has(39);
  @$pb.TagNumber(41)
  void clearBookingPriceUpdatedAt() => $_clearField(41);
}

class AlbergueFacilities extends $pb.GeneratedMessage {
  factory AlbergueFacilities({
    $core.int? id,
    $core.int? albergueId,
    $core.bool? hasKitchen,
    $core.bool? hasCooktops,
    $core.bool? hasMicrowave,
    $core.bool? hasWaterBoiler,
    $core.bool? hasPlatesUtensils,
    $core.bool? hasCookingPots,
    $core.bool? hasBreakfast,
    $core.bool? isBreakfastIncluded,
    $core.bool? hasClothesLine,
    $core.bool? hasWifi,
    $core.bool? hasTv,
    $core.bool? hasRestaurant,
    $core.bool? hasCommunityDinner,
    $core.bool? hasDinner,
    $core.bool? hasWashingMachine,
    $core.bool? hasSpinDryer,
    $core.bool? hasHandWashingSink,
    $core.bool? hasTumbleDryer,
    $core.bool? hasIndividualPowerplug,
    $core.bool? hasPrivateLockers,
    $core.bool? hasCurtains,
    $core.bool? hasOven,
    $core.bool? hasVendingMachine,
    $core.bool? hasFullLaundryService,
    $core.bool? hasFridge,
    $core.bool? hasLunch,
    $core.bool? hasVegetarianOption,
    $core.bool? hasVeganOption,
    $core.bool? hasSwimmingPool,
    $core.bool? hasDonativoBreakfast,
    $core.bool? hasCubeBeds,
    $core.bool? hasCommunityLunch,
    $core.bool? isVegetarian,
    $core.bool? isVegan,
    $core.bool? isOrganic,
    $core.bool? petsAllowed,
    $core.bool? hasCottonSheets,
    $core.bool? isDinnerIncluded,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (hasKitchen != null) result.hasKitchen = hasKitchen;
    if (hasCooktops != null) result.hasCooktops = hasCooktops;
    if (hasMicrowave != null) result.hasMicrowave = hasMicrowave;
    if (hasWaterBoiler != null) result.hasWaterBoiler = hasWaterBoiler;
    if (hasPlatesUtensils != null) result.hasPlatesUtensils = hasPlatesUtensils;
    if (hasCookingPots != null) result.hasCookingPots = hasCookingPots;
    if (hasBreakfast != null) result.hasBreakfast = hasBreakfast;
    if (isBreakfastIncluded != null) result.isBreakfastIncluded = isBreakfastIncluded;
    if (hasClothesLine != null) result.hasClothesLine = hasClothesLine;
    if (hasWifi != null) result.hasWifi = hasWifi;
    if (hasTv != null) result.hasTv = hasTv;
    if (hasRestaurant != null) result.hasRestaurant = hasRestaurant;
    if (hasCommunityDinner != null) result.hasCommunityDinner = hasCommunityDinner;
    if (hasDinner != null) result.hasDinner = hasDinner;
    if (hasWashingMachine != null) result.hasWashingMachine = hasWashingMachine;
    if (hasSpinDryer != null) result.hasSpinDryer = hasSpinDryer;
    if (hasHandWashingSink != null) result.hasHandWashingSink = hasHandWashingSink;
    if (hasTumbleDryer != null) result.hasTumbleDryer = hasTumbleDryer;
    if (hasIndividualPowerplug != null) result.hasIndividualPowerplug = hasIndividualPowerplug;
    if (hasPrivateLockers != null) result.hasPrivateLockers = hasPrivateLockers;
    if (hasCurtains != null) result.hasCurtains = hasCurtains;
    if (hasOven != null) result.hasOven = hasOven;
    if (hasVendingMachine != null) result.hasVendingMachine = hasVendingMachine;
    if (hasFullLaundryService != null) result.hasFullLaundryService = hasFullLaundryService;
    if (hasFridge != null) result.hasFridge = hasFridge;
    if (hasLunch != null) result.hasLunch = hasLunch;
    if (hasVegetarianOption != null) result.hasVegetarianOption = hasVegetarianOption;
    if (hasVeganOption != null) result.hasVeganOption = hasVeganOption;
    if (hasSwimmingPool != null) result.hasSwimmingPool = hasSwimmingPool;
    if (hasDonativoBreakfast != null) result.hasDonativoBreakfast = hasDonativoBreakfast;
    if (hasCubeBeds != null) result.hasCubeBeds = hasCubeBeds;
    if (hasCommunityLunch != null) result.hasCommunityLunch = hasCommunityLunch;
    if (isVegetarian != null) result.isVegetarian = isVegetarian;
    if (isVegan != null) result.isVegan = isVegan;
    if (isOrganic != null) result.isOrganic = isOrganic;
    if (petsAllowed != null) result.petsAllowed = petsAllowed;
    if (hasCottonSheets != null) result.hasCottonSheets = hasCottonSheets;
    if (isDinnerIncluded != null) result.isDinnerIncluded = isDinnerIncluded;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlbergueFacilities._();

  factory AlbergueFacilities.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueFacilities.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueFacilities', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOB(3, _omitFieldNames ? '' : 'hasKitchen')
    ..aOB(4, _omitFieldNames ? '' : 'hasCooktops')
    ..aOB(5, _omitFieldNames ? '' : 'hasMicrowave')
    ..aOB(6, _omitFieldNames ? '' : 'hasWaterBoiler')
    ..aOB(7, _omitFieldNames ? '' : 'hasPlatesUtensils')
    ..aOB(8, _omitFieldNames ? '' : 'hasCookingPots')
    ..aOB(9, _omitFieldNames ? '' : 'hasBreakfast')
    ..aOB(10, _omitFieldNames ? '' : 'isBreakfastIncluded')
    ..aOB(11, _omitFieldNames ? '' : 'hasClothesLine')
    ..aOB(12, _omitFieldNames ? '' : 'hasWifi')
    ..aOB(13, _omitFieldNames ? '' : 'hasTv')
    ..aOB(14, _omitFieldNames ? '' : 'hasRestaurant')
    ..aOB(15, _omitFieldNames ? '' : 'hasCommunityDinner')
    ..aOB(16, _omitFieldNames ? '' : 'hasDinner')
    ..aOB(17, _omitFieldNames ? '' : 'hasWashingMachine')
    ..aOB(18, _omitFieldNames ? '' : 'hasSpinDryer')
    ..aOB(19, _omitFieldNames ? '' : 'hasHandWashingSink')
    ..aOB(20, _omitFieldNames ? '' : 'hasTumbleDryer')
    ..aOB(21, _omitFieldNames ? '' : 'hasIndividualPowerplug')
    ..aOB(22, _omitFieldNames ? '' : 'hasPrivateLockers')
    ..aOB(23, _omitFieldNames ? '' : 'hasCurtains')
    ..aOB(24, _omitFieldNames ? '' : 'hasOven')
    ..aOB(25, _omitFieldNames ? '' : 'hasVendingMachine')
    ..aOB(26, _omitFieldNames ? '' : 'hasFullLaundryService')
    ..aOB(27, _omitFieldNames ? '' : 'hasFridge')
    ..aOB(28, _omitFieldNames ? '' : 'hasLunch')
    ..aOB(29, _omitFieldNames ? '' : 'hasVegetarianOption')
    ..aOB(30, _omitFieldNames ? '' : 'hasVeganOption')
    ..aOB(31, _omitFieldNames ? '' : 'hasSwimmingPool')
    ..aOB(32, _omitFieldNames ? '' : 'hasDonativoBreakfast')
    ..aOB(33, _omitFieldNames ? '' : 'hasCubeBeds')
    ..aOB(34, _omitFieldNames ? '' : 'hasCommunityLunch')
    ..aOB(35, _omitFieldNames ? '' : 'isVegetarian')
    ..aOB(36, _omitFieldNames ? '' : 'isVegan')
    ..aOB(37, _omitFieldNames ? '' : 'isOrganic')
    ..aOB(38, _omitFieldNames ? '' : 'petsAllowed')
    ..aOB(39, _omitFieldNames ? '' : 'hasCottonSheets')
    ..aOB(40, _omitFieldNames ? '' : 'isDinnerIncluded')
    ..aOS(41, _omitFieldNames ? '' : 'createdAt')
    ..aOS(42, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(43, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueFacilities clone() => AlbergueFacilities()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueFacilities copyWith(void Function(AlbergueFacilities) updates) => super.copyWith((message) => updates(message as AlbergueFacilities)) as AlbergueFacilities;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueFacilities create() => AlbergueFacilities._();
  @$core.override
  AlbergueFacilities createEmptyInstance() => create();
  static $pb.PbList<AlbergueFacilities> createRepeated() => $pb.PbList<AlbergueFacilities>();
  @$core.pragma('dart2js:noInline')
  static AlbergueFacilities getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueFacilities>(create);
  static AlbergueFacilities? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasKitchen => $_getBF(2);
  @$pb.TagNumber(3)
  set hasKitchen($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasKitchen() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasKitchen() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get hasCooktops => $_getBF(3);
  @$pb.TagNumber(4)
  set hasCooktops($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasCooktops() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasCooktops() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasMicrowave => $_getBF(4);
  @$pb.TagNumber(5)
  set hasMicrowave($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHasMicrowave() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasMicrowave() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get hasWaterBoiler => $_getBF(5);
  @$pb.TagNumber(6)
  set hasWaterBoiler($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHasWaterBoiler() => $_has(5);
  @$pb.TagNumber(6)
  void clearHasWaterBoiler() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get hasPlatesUtensils => $_getBF(6);
  @$pb.TagNumber(7)
  set hasPlatesUtensils($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHasPlatesUtensils() => $_has(6);
  @$pb.TagNumber(7)
  void clearHasPlatesUtensils() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get hasCookingPots => $_getBF(7);
  @$pb.TagNumber(8)
  set hasCookingPots($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHasCookingPots() => $_has(7);
  @$pb.TagNumber(8)
  void clearHasCookingPots() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get hasBreakfast => $_getBF(8);
  @$pb.TagNumber(9)
  set hasBreakfast($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHasBreakfast() => $_has(8);
  @$pb.TagNumber(9)
  void clearHasBreakfast() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isBreakfastIncluded => $_getBF(9);
  @$pb.TagNumber(10)
  set isBreakfastIncluded($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsBreakfastIncluded() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsBreakfastIncluded() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get hasClothesLine => $_getBF(10);
  @$pb.TagNumber(11)
  set hasClothesLine($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHasClothesLine() => $_has(10);
  @$pb.TagNumber(11)
  void clearHasClothesLine() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasWifi => $_getBF(11);
  @$pb.TagNumber(12)
  set hasWifi($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHasWifi() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasWifi() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get hasTv => $_getBF(12);
  @$pb.TagNumber(13)
  set hasTv($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasHasTv() => $_has(12);
  @$pb.TagNumber(13)
  void clearHasTv() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get hasRestaurant => $_getBF(13);
  @$pb.TagNumber(14)
  set hasRestaurant($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasHasRestaurant() => $_has(13);
  @$pb.TagNumber(14)
  void clearHasRestaurant() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get hasCommunityDinner => $_getBF(14);
  @$pb.TagNumber(15)
  set hasCommunityDinner($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasHasCommunityDinner() => $_has(14);
  @$pb.TagNumber(15)
  void clearHasCommunityDinner() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get hasDinner => $_getBF(15);
  @$pb.TagNumber(16)
  set hasDinner($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasHasDinner() => $_has(15);
  @$pb.TagNumber(16)
  void clearHasDinner() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get hasWashingMachine => $_getBF(16);
  @$pb.TagNumber(17)
  set hasWashingMachine($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasHasWashingMachine() => $_has(16);
  @$pb.TagNumber(17)
  void clearHasWashingMachine() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get hasSpinDryer => $_getBF(17);
  @$pb.TagNumber(18)
  set hasSpinDryer($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasHasSpinDryer() => $_has(17);
  @$pb.TagNumber(18)
  void clearHasSpinDryer() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.bool get hasHandWashingSink => $_getBF(18);
  @$pb.TagNumber(19)
  set hasHandWashingSink($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasHasHandWashingSink() => $_has(18);
  @$pb.TagNumber(19)
  void clearHasHandWashingSink() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.bool get hasTumbleDryer => $_getBF(19);
  @$pb.TagNumber(20)
  set hasTumbleDryer($core.bool value) => $_setBool(19, value);
  @$pb.TagNumber(20)
  $core.bool hasHasTumbleDryer() => $_has(19);
  @$pb.TagNumber(20)
  void clearHasTumbleDryer() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.bool get hasIndividualPowerplug => $_getBF(20);
  @$pb.TagNumber(21)
  set hasIndividualPowerplug($core.bool value) => $_setBool(20, value);
  @$pb.TagNumber(21)
  $core.bool hasHasIndividualPowerplug() => $_has(20);
  @$pb.TagNumber(21)
  void clearHasIndividualPowerplug() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.bool get hasPrivateLockers => $_getBF(21);
  @$pb.TagNumber(22)
  set hasPrivateLockers($core.bool value) => $_setBool(21, value);
  @$pb.TagNumber(22)
  $core.bool hasHasPrivateLockers() => $_has(21);
  @$pb.TagNumber(22)
  void clearHasPrivateLockers() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.bool get hasCurtains => $_getBF(22);
  @$pb.TagNumber(23)
  set hasCurtains($core.bool value) => $_setBool(22, value);
  @$pb.TagNumber(23)
  $core.bool hasHasCurtains() => $_has(22);
  @$pb.TagNumber(23)
  void clearHasCurtains() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.bool get hasOven => $_getBF(23);
  @$pb.TagNumber(24)
  set hasOven($core.bool value) => $_setBool(23, value);
  @$pb.TagNumber(24)
  $core.bool hasHasOven() => $_has(23);
  @$pb.TagNumber(24)
  void clearHasOven() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.bool get hasVendingMachine => $_getBF(24);
  @$pb.TagNumber(25)
  set hasVendingMachine($core.bool value) => $_setBool(24, value);
  @$pb.TagNumber(25)
  $core.bool hasHasVendingMachine() => $_has(24);
  @$pb.TagNumber(25)
  void clearHasVendingMachine() => $_clearField(25);

  @$pb.TagNumber(26)
  $core.bool get hasFullLaundryService => $_getBF(25);
  @$pb.TagNumber(26)
  set hasFullLaundryService($core.bool value) => $_setBool(25, value);
  @$pb.TagNumber(26)
  $core.bool hasHasFullLaundryService() => $_has(25);
  @$pb.TagNumber(26)
  void clearHasFullLaundryService() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.bool get hasFridge => $_getBF(26);
  @$pb.TagNumber(27)
  set hasFridge($core.bool value) => $_setBool(26, value);
  @$pb.TagNumber(27)
  $core.bool hasHasFridge() => $_has(26);
  @$pb.TagNumber(27)
  void clearHasFridge() => $_clearField(27);

  @$pb.TagNumber(28)
  $core.bool get hasLunch => $_getBF(27);
  @$pb.TagNumber(28)
  set hasLunch($core.bool value) => $_setBool(27, value);
  @$pb.TagNumber(28)
  $core.bool hasHasLunch() => $_has(27);
  @$pb.TagNumber(28)
  void clearHasLunch() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.bool get hasVegetarianOption => $_getBF(28);
  @$pb.TagNumber(29)
  set hasVegetarianOption($core.bool value) => $_setBool(28, value);
  @$pb.TagNumber(29)
  $core.bool hasHasVegetarianOption() => $_has(28);
  @$pb.TagNumber(29)
  void clearHasVegetarianOption() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.bool get hasVeganOption => $_getBF(29);
  @$pb.TagNumber(30)
  set hasVeganOption($core.bool value) => $_setBool(29, value);
  @$pb.TagNumber(30)
  $core.bool hasHasVeganOption() => $_has(29);
  @$pb.TagNumber(30)
  void clearHasVeganOption() => $_clearField(30);

  @$pb.TagNumber(31)
  $core.bool get hasSwimmingPool => $_getBF(30);
  @$pb.TagNumber(31)
  set hasSwimmingPool($core.bool value) => $_setBool(30, value);
  @$pb.TagNumber(31)
  $core.bool hasHasSwimmingPool() => $_has(30);
  @$pb.TagNumber(31)
  void clearHasSwimmingPool() => $_clearField(31);

  @$pb.TagNumber(32)
  $core.bool get hasDonativoBreakfast => $_getBF(31);
  @$pb.TagNumber(32)
  set hasDonativoBreakfast($core.bool value) => $_setBool(31, value);
  @$pb.TagNumber(32)
  $core.bool hasHasDonativoBreakfast() => $_has(31);
  @$pb.TagNumber(32)
  void clearHasDonativoBreakfast() => $_clearField(32);

  @$pb.TagNumber(33)
  $core.bool get hasCubeBeds => $_getBF(32);
  @$pb.TagNumber(33)
  set hasCubeBeds($core.bool value) => $_setBool(32, value);
  @$pb.TagNumber(33)
  $core.bool hasHasCubeBeds() => $_has(32);
  @$pb.TagNumber(33)
  void clearHasCubeBeds() => $_clearField(33);

  @$pb.TagNumber(34)
  $core.bool get hasCommunityLunch => $_getBF(33);
  @$pb.TagNumber(34)
  set hasCommunityLunch($core.bool value) => $_setBool(33, value);
  @$pb.TagNumber(34)
  $core.bool hasHasCommunityLunch() => $_has(33);
  @$pb.TagNumber(34)
  void clearHasCommunityLunch() => $_clearField(34);

  @$pb.TagNumber(35)
  $core.bool get isVegetarian => $_getBF(34);
  @$pb.TagNumber(35)
  set isVegetarian($core.bool value) => $_setBool(34, value);
  @$pb.TagNumber(35)
  $core.bool hasIsVegetarian() => $_has(34);
  @$pb.TagNumber(35)
  void clearIsVegetarian() => $_clearField(35);

  @$pb.TagNumber(36)
  $core.bool get isVegan => $_getBF(35);
  @$pb.TagNumber(36)
  set isVegan($core.bool value) => $_setBool(35, value);
  @$pb.TagNumber(36)
  $core.bool hasIsVegan() => $_has(35);
  @$pb.TagNumber(36)
  void clearIsVegan() => $_clearField(36);

  @$pb.TagNumber(37)
  $core.bool get isOrganic => $_getBF(36);
  @$pb.TagNumber(37)
  set isOrganic($core.bool value) => $_setBool(36, value);
  @$pb.TagNumber(37)
  $core.bool hasIsOrganic() => $_has(36);
  @$pb.TagNumber(37)
  void clearIsOrganic() => $_clearField(37);

  @$pb.TagNumber(38)
  $core.bool get petsAllowed => $_getBF(37);
  @$pb.TagNumber(38)
  set petsAllowed($core.bool value) => $_setBool(37, value);
  @$pb.TagNumber(38)
  $core.bool hasPetsAllowed() => $_has(37);
  @$pb.TagNumber(38)
  void clearPetsAllowed() => $_clearField(38);

  @$pb.TagNumber(39)
  $core.bool get hasCottonSheets => $_getBF(38);
  @$pb.TagNumber(39)
  set hasCottonSheets($core.bool value) => $_setBool(38, value);
  @$pb.TagNumber(39)
  $core.bool hasHasCottonSheets() => $_has(38);
  @$pb.TagNumber(39)
  void clearHasCottonSheets() => $_clearField(39);

  @$pb.TagNumber(40)
  $core.bool get isDinnerIncluded => $_getBF(39);
  @$pb.TagNumber(40)
  set isDinnerIncluded($core.bool value) => $_setBool(39, value);
  @$pb.TagNumber(40)
  $core.bool hasIsDinnerIncluded() => $_has(39);
  @$pb.TagNumber(40)
  void clearIsDinnerIncluded() => $_clearField(40);

  @$pb.TagNumber(41)
  $core.String get createdAt => $_getSZ(40);
  @$pb.TagNumber(41)
  set createdAt($core.String value) => $_setString(40, value);
  @$pb.TagNumber(41)
  $core.bool hasCreatedAt() => $_has(40);
  @$pb.TagNumber(41)
  void clearCreatedAt() => $_clearField(41);

  @$pb.TagNumber(42)
  $core.String get updatedAt => $_getSZ(41);
  @$pb.TagNumber(42)
  set updatedAt($core.String value) => $_setString(41, value);
  @$pb.TagNumber(42)
  $core.bool hasUpdatedAt() => $_has(41);
  @$pb.TagNumber(42)
  void clearUpdatedAt() => $_clearField(42);

  @$pb.TagNumber(43)
  $core.String get deletedAt => $_getSZ(42);
  @$pb.TagNumber(43)
  set deletedAt($core.String value) => $_setString(42, value);
  @$pb.TagNumber(43)
  $core.bool hasDeletedAt() => $_has(42);
  @$pb.TagNumber(43)
  void clearDeletedAt() => $_clearField(43);
}

class AlbergueOperatingHours extends $pb.GeneratedMessage {
  factory AlbergueOperatingHours({
    $core.int? id,
    $core.int? albergueId,
    $core.String? checkinTime,
    $core.String? checkoutTime,
    $core.String? closeTime,
    $core.String? openFrom,
    $core.String? openTo,
    $core.String? openFromEx,
    $core.String? openToEx,
    $core.String? openFromEx2,
    $core.String? openToEx2,
    $core.String? opens,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? openAdditionalInformation,
    $core.bool? unknownOpenSeason,
    $core.bool? opensAllYear,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (checkinTime != null) result.checkinTime = checkinTime;
    if (checkoutTime != null) result.checkoutTime = checkoutTime;
    if (closeTime != null) result.closeTime = closeTime;
    if (openFrom != null) result.openFrom = openFrom;
    if (openTo != null) result.openTo = openTo;
    if (openFromEx != null) result.openFromEx = openFromEx;
    if (openToEx != null) result.openToEx = openToEx;
    if (openFromEx2 != null) result.openFromEx2 = openFromEx2;
    if (openToEx2 != null) result.openToEx2 = openToEx2;
    if (opens != null) result.opens = opens;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    if (openAdditionalInformation != null) result.openAdditionalInformation.addEntries(openAdditionalInformation);
    if (unknownOpenSeason != null) result.unknownOpenSeason = unknownOpenSeason;
    if (opensAllYear != null) result.opensAllYear = opensAllYear;
    return result;
  }

  AlbergueOperatingHours._();

  factory AlbergueOperatingHours.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueOperatingHours.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueOperatingHours', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'checkinTime')
    ..aOS(4, _omitFieldNames ? '' : 'checkoutTime')
    ..aOS(5, _omitFieldNames ? '' : 'closeTime')
    ..aOS(6, _omitFieldNames ? '' : 'openFrom')
    ..aOS(7, _omitFieldNames ? '' : 'openTo')
    ..aOS(8, _omitFieldNames ? '' : 'openFromEx')
    ..aOS(9, _omitFieldNames ? '' : 'openToEx')
    ..aOS(10, _omitFieldNames ? '' : 'openFromEx2')
    ..aOS(11, _omitFieldNames ? '' : 'openToEx2')
    ..aOS(12, _omitFieldNames ? '' : 'opens')
    ..aOS(13, _omitFieldNames ? '' : 'createdAt')
    ..aOS(14, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(15, _omitFieldNames ? '' : 'deletedAt')
    ..m<$core.String, $core.String>(16, _omitFieldNames ? '' : 'openAdditionalInformation', entryClassName: 'AlbergueOperatingHours.OpenAdditionalInformationEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('pb'))
    ..aOB(17, _omitFieldNames ? '' : 'unknownOpenSeason')
    ..aOB(18, _omitFieldNames ? '' : 'opensAllYear')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueOperatingHours clone() => AlbergueOperatingHours()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueOperatingHours copyWith(void Function(AlbergueOperatingHours) updates) => super.copyWith((message) => updates(message as AlbergueOperatingHours)) as AlbergueOperatingHours;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueOperatingHours create() => AlbergueOperatingHours._();
  @$core.override
  AlbergueOperatingHours createEmptyInstance() => create();
  static $pb.PbList<AlbergueOperatingHours> createRepeated() => $pb.PbList<AlbergueOperatingHours>();
  @$core.pragma('dart2js:noInline')
  static AlbergueOperatingHours getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueOperatingHours>(create);
  static AlbergueOperatingHours? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get checkinTime => $_getSZ(2);
  @$pb.TagNumber(3)
  set checkinTime($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCheckinTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearCheckinTime() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get checkoutTime => $_getSZ(3);
  @$pb.TagNumber(4)
  set checkoutTime($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCheckoutTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCheckoutTime() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get closeTime => $_getSZ(4);
  @$pb.TagNumber(5)
  set closeTime($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCloseTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearCloseTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get openFrom => $_getSZ(5);
  @$pb.TagNumber(6)
  set openFrom($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOpenFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearOpenFrom() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get openTo => $_getSZ(6);
  @$pb.TagNumber(7)
  set openTo($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOpenTo() => $_has(6);
  @$pb.TagNumber(7)
  void clearOpenTo() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get openFromEx => $_getSZ(7);
  @$pb.TagNumber(8)
  set openFromEx($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOpenFromEx() => $_has(7);
  @$pb.TagNumber(8)
  void clearOpenFromEx() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get openToEx => $_getSZ(8);
  @$pb.TagNumber(9)
  set openToEx($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOpenToEx() => $_has(8);
  @$pb.TagNumber(9)
  void clearOpenToEx() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get openFromEx2 => $_getSZ(9);
  @$pb.TagNumber(10)
  set openFromEx2($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOpenFromEx2() => $_has(9);
  @$pb.TagNumber(10)
  void clearOpenFromEx2() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get openToEx2 => $_getSZ(10);
  @$pb.TagNumber(11)
  set openToEx2($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasOpenToEx2() => $_has(10);
  @$pb.TagNumber(11)
  void clearOpenToEx2() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get opens => $_getSZ(11);
  @$pb.TagNumber(12)
  set opens($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasOpens() => $_has(11);
  @$pb.TagNumber(12)
  void clearOpens() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get createdAt => $_getSZ(12);
  @$pb.TagNumber(13)
  set createdAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get updatedAt => $_getSZ(13);
  @$pb.TagNumber(14)
  set updatedAt($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasUpdatedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearUpdatedAt() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get deletedAt => $_getSZ(14);
  @$pb.TagNumber(15)
  set deletedAt($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDeletedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearDeletedAt() => $_clearField(15);

  @$pb.TagNumber(16)
  $pb.PbMap<$core.String, $core.String> get openAdditionalInformation => $_getMap(15);

  @$pb.TagNumber(17)
  $core.bool get unknownOpenSeason => $_getBF(16);
  @$pb.TagNumber(17)
  set unknownOpenSeason($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasUnknownOpenSeason() => $_has(16);
  @$pb.TagNumber(17)
  void clearUnknownOpenSeason() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get opensAllYear => $_getBF(17);
  @$pb.TagNumber(18)
  set opensAllYear($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasOpensAllYear() => $_has(17);
  @$pb.TagNumber(18)
  void clearOpensAllYear() => $_clearField(18);
}

class AlberguePrices extends $pb.GeneratedMessage {
  factory AlberguePrices({
    $core.int? id,
    $core.int? albergueId,
    $core.double? priceFromDormitory,
    $core.double? priceToDormitory,
    $core.double? priceFromDoubleRoom,
    $core.double? priceToDoubleRoom,
    $core.double? priceFromSingleRoom,
    $core.double? priceToSingleRoom,
    $core.double? priceFromBedSharedRoom,
    $core.double? priceToBedSharedRoom,
    $core.double? priceFromQuatroRoom,
    $core.double? priceToQuatroRoom,
    $core.double? priceFromApartament,
    $core.double? priceToApartament,
    $core.double? priceFromTripleRoom,
    $core.double? priceToTripleRoom,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (priceFromDormitory != null) result.priceFromDormitory = priceFromDormitory;
    if (priceToDormitory != null) result.priceToDormitory = priceToDormitory;
    if (priceFromDoubleRoom != null) result.priceFromDoubleRoom = priceFromDoubleRoom;
    if (priceToDoubleRoom != null) result.priceToDoubleRoom = priceToDoubleRoom;
    if (priceFromSingleRoom != null) result.priceFromSingleRoom = priceFromSingleRoom;
    if (priceToSingleRoom != null) result.priceToSingleRoom = priceToSingleRoom;
    if (priceFromBedSharedRoom != null) result.priceFromBedSharedRoom = priceFromBedSharedRoom;
    if (priceToBedSharedRoom != null) result.priceToBedSharedRoom = priceToBedSharedRoom;
    if (priceFromQuatroRoom != null) result.priceFromQuatroRoom = priceFromQuatroRoom;
    if (priceToQuatroRoom != null) result.priceToQuatroRoom = priceToQuatroRoom;
    if (priceFromApartament != null) result.priceFromApartament = priceFromApartament;
    if (priceToApartament != null) result.priceToApartament = priceToApartament;
    if (priceFromTripleRoom != null) result.priceFromTripleRoom = priceFromTripleRoom;
    if (priceToTripleRoom != null) result.priceToTripleRoom = priceToTripleRoom;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlberguePrices._();

  factory AlberguePrices.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlberguePrices.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlberguePrices', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'priceFromDormitory', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'priceToDormitory', $pb.PbFieldType.OF)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'priceFromDoubleRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(6, _omitFieldNames ? '' : 'priceToDoubleRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(7, _omitFieldNames ? '' : 'priceFromSingleRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(8, _omitFieldNames ? '' : 'priceToSingleRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(9, _omitFieldNames ? '' : 'priceFromBedSharedRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(10, _omitFieldNames ? '' : 'priceToBedSharedRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(11, _omitFieldNames ? '' : 'priceFromQuatroRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(12, _omitFieldNames ? '' : 'priceToQuatroRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(13, _omitFieldNames ? '' : 'priceFromApartament', $pb.PbFieldType.OF)
    ..a<$core.double>(14, _omitFieldNames ? '' : 'priceToApartament', $pb.PbFieldType.OF)
    ..a<$core.double>(15, _omitFieldNames ? '' : 'priceFromTripleRoom', $pb.PbFieldType.OF)
    ..a<$core.double>(16, _omitFieldNames ? '' : 'priceToTripleRoom', $pb.PbFieldType.OF)
    ..aOS(17, _omitFieldNames ? '' : 'createdAt')
    ..aOS(18, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(19, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlberguePrices clone() => AlberguePrices()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlberguePrices copyWith(void Function(AlberguePrices) updates) => super.copyWith((message) => updates(message as AlberguePrices)) as AlberguePrices;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlberguePrices create() => AlberguePrices._();
  @$core.override
  AlberguePrices createEmptyInstance() => create();
  static $pb.PbList<AlberguePrices> createRepeated() => $pb.PbList<AlberguePrices>();
  @$core.pragma('dart2js:noInline')
  static AlberguePrices getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlberguePrices>(create);
  static AlberguePrices? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get priceFromDormitory => $_getN(2);
  @$pb.TagNumber(3)
  set priceFromDormitory($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPriceFromDormitory() => $_has(2);
  @$pb.TagNumber(3)
  void clearPriceFromDormitory() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get priceToDormitory => $_getN(3);
  @$pb.TagNumber(4)
  set priceToDormitory($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPriceToDormitory() => $_has(3);
  @$pb.TagNumber(4)
  void clearPriceToDormitory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get priceFromDoubleRoom => $_getN(4);
  @$pb.TagNumber(5)
  set priceFromDoubleRoom($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPriceFromDoubleRoom() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriceFromDoubleRoom() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get priceToDoubleRoom => $_getN(5);
  @$pb.TagNumber(6)
  set priceToDoubleRoom($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPriceToDoubleRoom() => $_has(5);
  @$pb.TagNumber(6)
  void clearPriceToDoubleRoom() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get priceFromSingleRoom => $_getN(6);
  @$pb.TagNumber(7)
  set priceFromSingleRoom($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPriceFromSingleRoom() => $_has(6);
  @$pb.TagNumber(7)
  void clearPriceFromSingleRoom() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get priceToSingleRoom => $_getN(7);
  @$pb.TagNumber(8)
  set priceToSingleRoom($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPriceToSingleRoom() => $_has(7);
  @$pb.TagNumber(8)
  void clearPriceToSingleRoom() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get priceFromBedSharedRoom => $_getN(8);
  @$pb.TagNumber(9)
  set priceFromBedSharedRoom($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPriceFromBedSharedRoom() => $_has(8);
  @$pb.TagNumber(9)
  void clearPriceFromBedSharedRoom() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get priceToBedSharedRoom => $_getN(9);
  @$pb.TagNumber(10)
  set priceToBedSharedRoom($core.double value) => $_setFloat(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPriceToBedSharedRoom() => $_has(9);
  @$pb.TagNumber(10)
  void clearPriceToBedSharedRoom() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get priceFromQuatroRoom => $_getN(10);
  @$pb.TagNumber(11)
  set priceFromQuatroRoom($core.double value) => $_setFloat(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPriceFromQuatroRoom() => $_has(10);
  @$pb.TagNumber(11)
  void clearPriceFromQuatroRoom() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get priceToQuatroRoom => $_getN(11);
  @$pb.TagNumber(12)
  set priceToQuatroRoom($core.double value) => $_setFloat(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPriceToQuatroRoom() => $_has(11);
  @$pb.TagNumber(12)
  void clearPriceToQuatroRoom() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get priceFromApartament => $_getN(12);
  @$pb.TagNumber(13)
  set priceFromApartament($core.double value) => $_setFloat(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPriceFromApartament() => $_has(12);
  @$pb.TagNumber(13)
  void clearPriceFromApartament() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get priceToApartament => $_getN(13);
  @$pb.TagNumber(14)
  set priceToApartament($core.double value) => $_setFloat(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPriceToApartament() => $_has(13);
  @$pb.TagNumber(14)
  void clearPriceToApartament() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get priceFromTripleRoom => $_getN(14);
  @$pb.TagNumber(15)
  set priceFromTripleRoom($core.double value) => $_setFloat(14, value);
  @$pb.TagNumber(15)
  $core.bool hasPriceFromTripleRoom() => $_has(14);
  @$pb.TagNumber(15)
  void clearPriceFromTripleRoom() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get priceToTripleRoom => $_getN(15);
  @$pb.TagNumber(16)
  set priceToTripleRoom($core.double value) => $_setFloat(15, value);
  @$pb.TagNumber(16)
  $core.bool hasPriceToTripleRoom() => $_has(15);
  @$pb.TagNumber(16)
  void clearPriceToTripleRoom() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get createdAt => $_getSZ(16);
  @$pb.TagNumber(17)
  set createdAt($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasCreatedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearCreatedAt() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get updatedAt => $_getSZ(17);
  @$pb.TagNumber(18)
  set updatedAt($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasUpdatedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearUpdatedAt() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get deletedAt => $_getSZ(18);
  @$pb.TagNumber(19)
  set deletedAt($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasDeletedAt() => $_has(18);
  @$pb.TagNumber(19)
  void clearDeletedAt() => $_clearField(19);
}

class AlbergueReviews extends $pb.GeneratedMessage {
  factory AlbergueReviews({
    $core.int? id,
    $core.int? albergueId,
    $core.double? gRating,
    $core.double? bReviewScore,
    $core.String? bId,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (gRating != null) result.gRating = gRating;
    if (bReviewScore != null) result.bReviewScore = bReviewScore;
    if (bId != null) result.bId = bId;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlbergueReviews._();

  factory AlbergueReviews.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueReviews.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueReviews', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'gRating', $pb.PbFieldType.OF)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'bReviewScore', $pb.PbFieldType.OF)
    ..aOS(5, _omitFieldNames ? '' : 'bId')
    ..aOS(6, _omitFieldNames ? '' : 'createdAt')
    ..aOS(7, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(8, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueReviews clone() => AlbergueReviews()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueReviews copyWith(void Function(AlbergueReviews) updates) => super.copyWith((message) => updates(message as AlbergueReviews)) as AlbergueReviews;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueReviews create() => AlbergueReviews._();
  @$core.override
  AlbergueReviews createEmptyInstance() => create();
  static $pb.PbList<AlbergueReviews> createRepeated() => $pb.PbList<AlbergueReviews>();
  @$core.pragma('dart2js:noInline')
  static AlbergueReviews getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueReviews>(create);
  static AlbergueReviews? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get gRating => $_getN(2);
  @$pb.TagNumber(3)
  set gRating($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGRating() => $_has(2);
  @$pb.TagNumber(3)
  void clearGRating() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get bReviewScore => $_getN(3);
  @$pb.TagNumber(4)
  set bReviewScore($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBReviewScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearBReviewScore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get bId => $_getSZ(4);
  @$pb.TagNumber(5)
  set bId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get createdAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get updatedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set updatedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get deletedAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set deletedAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDeletedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearDeletedAt() => $_clearField(8);
}

class AlbergueSocialMedia extends $pb.GeneratedMessage {
  factory AlbergueSocialMedia({
    $core.int? id,
    $core.int? albergueId,
    $core.String? facebookUrl,
    $core.String? facebookId,
    $core.String? instagramHandle,
    $core.String? messenger,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (facebookUrl != null) result.facebookUrl = facebookUrl;
    if (facebookId != null) result.facebookId = facebookId;
    if (instagramHandle != null) result.instagramHandle = instagramHandle;
    if (messenger != null) result.messenger = messenger;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlbergueSocialMedia._();

  factory AlbergueSocialMedia.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueSocialMedia.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueSocialMedia', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'facebookUrl')
    ..aOS(4, _omitFieldNames ? '' : 'facebookId')
    ..aOS(5, _omitFieldNames ? '' : 'instagramHandle')
    ..aOS(6, _omitFieldNames ? '' : 'messenger')
    ..aOS(7, _omitFieldNames ? '' : 'createdAt')
    ..aOS(8, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(9, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueSocialMedia clone() => AlbergueSocialMedia()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueSocialMedia copyWith(void Function(AlbergueSocialMedia) updates) => super.copyWith((message) => updates(message as AlbergueSocialMedia)) as AlbergueSocialMedia;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueSocialMedia create() => AlbergueSocialMedia._();
  @$core.override
  AlbergueSocialMedia createEmptyInstance() => create();
  static $pb.PbList<AlbergueSocialMedia> createRepeated() => $pb.PbList<AlbergueSocialMedia>();
  @$core.pragma('dart2js:noInline')
  static AlbergueSocialMedia getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueSocialMedia>(create);
  static AlbergueSocialMedia? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get facebookUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set facebookUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFacebookUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearFacebookUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get facebookId => $_getSZ(3);
  @$pb.TagNumber(4)
  set facebookId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFacebookId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFacebookId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get instagramHandle => $_getSZ(4);
  @$pb.TagNumber(5)
  set instagramHandle($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasInstagramHandle() => $_has(4);
  @$pb.TagNumber(5)
  void clearInstagramHandle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get messenger => $_getSZ(5);
  @$pb.TagNumber(6)
  set messenger($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessenger() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessenger() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get createdAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set createdAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get updatedAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set updatedAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get deletedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set deletedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDeletedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearDeletedAt() => $_clearField(9);
}

class AlbergueWifi extends $pb.GeneratedMessage {
  factory AlbergueWifi({
    $core.int? id,
    $core.int? albergueId,
    $core.String? url,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (url != null) result.url = url;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlbergueWifi._();

  factory AlbergueWifi.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueWifi.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueWifi', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'createdAt')
    ..aOS(5, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(6, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueWifi clone() => AlbergueWifi()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueWifi copyWith(void Function(AlbergueWifi) updates) => super.copyWith((message) => updates(message as AlbergueWifi)) as AlbergueWifi;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueWifi create() => AlbergueWifi._();
  @$core.override
  AlbergueWifi createEmptyInstance() => create();
  static $pb.PbList<AlbergueWifi> createRepeated() => $pb.PbList<AlbergueWifi>();
  @$core.pragma('dart2js:noInline')
  static AlbergueWifi getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueWifi>(create);
  static AlbergueWifi? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get createdAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set createdAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get updatedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set updatedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get deletedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set deletedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDeletedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeletedAt() => $_clearField(6);
}

class AlbergueEmail extends $pb.GeneratedMessage {
  factory AlbergueEmail({
    $core.int? id,
    $core.int? albergueId,
    $core.String? emailAddress,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (emailAddress != null) result.emailAddress = emailAddress;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlbergueEmail._();

  factory AlbergueEmail.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueEmail.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueEmail', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'emailAddress')
    ..aOS(4, _omitFieldNames ? '' : 'createdAt')
    ..aOS(5, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(6, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueEmail clone() => AlbergueEmail()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueEmail copyWith(void Function(AlbergueEmail) updates) => super.copyWith((message) => updates(message as AlbergueEmail)) as AlbergueEmail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueEmail create() => AlbergueEmail._();
  @$core.override
  AlbergueEmail createEmptyInstance() => create();
  static $pb.PbList<AlbergueEmail> createRepeated() => $pb.PbList<AlbergueEmail>();
  @$core.pragma('dart2js:noInline')
  static AlbergueEmail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueEmail>(create);
  static AlbergueEmail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get emailAddress => $_getSZ(2);
  @$pb.TagNumber(3)
  set emailAddress($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmailAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmailAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get createdAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set createdAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCreatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreatedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get updatedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set updatedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get deletedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set deletedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDeletedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeletedAt() => $_clearField(6);
}

class AlberguePhone extends $pb.GeneratedMessage {
  factory AlberguePhone({
    $core.int? id,
    $core.int? albergueId,
    $core.String? phoneNumber,
    $core.bool? whatsapp,
    $core.bool? private,
    $core.bool? signal,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (phoneNumber != null) result.phoneNumber = phoneNumber;
    if (whatsapp != null) result.whatsapp = whatsapp;
    if (private != null) result.private = private;
    if (signal != null) result.signal = signal;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlberguePhone._();

  factory AlberguePhone.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlberguePhone.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlberguePhone', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'phoneNumber')
    ..aOB(4, _omitFieldNames ? '' : 'whatsapp')
    ..aOB(5, _omitFieldNames ? '' : 'private')
    ..aOB(6, _omitFieldNames ? '' : 'signal')
    ..aOS(7, _omitFieldNames ? '' : 'createdAt')
    ..aOS(8, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(9, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlberguePhone clone() => AlberguePhone()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlberguePhone copyWith(void Function(AlberguePhone) updates) => super.copyWith((message) => updates(message as AlberguePhone)) as AlberguePhone;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlberguePhone create() => AlberguePhone._();
  @$core.override
  AlberguePhone createEmptyInstance() => create();
  static $pb.PbList<AlberguePhone> createRepeated() => $pb.PbList<AlberguePhone>();
  @$core.pragma('dart2js:noInline')
  static AlberguePhone getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlberguePhone>(create);
  static AlberguePhone? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get phoneNumber => $_getSZ(2);
  @$pb.TagNumber(3)
  set phoneNumber($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhoneNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhoneNumber() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get whatsapp => $_getBF(3);
  @$pb.TagNumber(4)
  set whatsapp($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWhatsapp() => $_has(3);
  @$pb.TagNumber(4)
  void clearWhatsapp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get private => $_getBF(4);
  @$pb.TagNumber(5)
  set private($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPrivate() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrivate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get signal => $_getBF(5);
  @$pb.TagNumber(6)
  set signal($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSignal() => $_has(5);
  @$pb.TagNumber(6)
  void clearSignal() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get createdAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set createdAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get updatedAt => $_getSZ(7);
  @$pb.TagNumber(8)
  set updatedAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearUpdatedAt() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get deletedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set deletedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDeletedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearDeletedAt() => $_clearField(9);
}

class AlbergueImage extends $pb.GeneratedMessage {
  factory AlbergueImage({
    $core.int? id,
    $core.int? albergueId,
    $core.String? fileKey,
    $core.bool? status,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (fileKey != null) result.fileKey = fileKey;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlbergueImage._();

  factory AlbergueImage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueImage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueImage', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'fileKey')
    ..aOB(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(7, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueImage clone() => AlbergueImage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueImage copyWith(void Function(AlbergueImage) updates) => super.copyWith((message) => updates(message as AlbergueImage)) as AlbergueImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueImage create() => AlbergueImage._();
  @$core.override
  AlbergueImage createEmptyInstance() => create();
  static $pb.PbList<AlbergueImage> createRepeated() => $pb.PbList<AlbergueImage>();
  @$core.pragma('dart2js:noInline')
  static AlbergueImage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueImage>(create);
  static AlbergueImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get status => $_getBF(3);
  @$pb.TagNumber(4)
  set status($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get updatedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set updatedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get deletedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set deletedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDeletedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeletedAt() => $_clearField(7);
}

class AlbergueListResponse extends $pb.GeneratedMessage {
  factory AlbergueListResponse({
    $core.Iterable<Albergue>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  AlbergueListResponse._();

  factory AlbergueListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<Albergue>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: Albergue.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueListResponse clone() => AlbergueListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueListResponse copyWith(void Function(AlbergueListResponse) updates) => super.copyWith((message) => updates(message as AlbergueListResponse)) as AlbergueListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueListResponse create() => AlbergueListResponse._();
  @$core.override
  AlbergueListResponse createEmptyInstance() => create();
  static $pb.PbList<AlbergueListResponse> createRepeated() => $pb.PbList<AlbergueListResponse>();
  @$core.pragma('dart2js:noInline')
  static AlbergueListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueListResponse>(create);
  static AlbergueListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Albergue> get items => $_getList(0);
}

class AlbergueUserImage extends $pb.GeneratedMessage {
  factory AlbergueUserImage({
    $core.int? id,
    $core.int? albergueId,
    $core.String? fileKey,
    $core.bool? status,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueId != null) result.albergueId = albergueId;
    if (fileKey != null) result.fileKey = fileKey;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AlbergueUserImage._();

  factory AlbergueUserImage.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserImage.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserImage', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'fileKey')
    ..aOB(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(7, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserImage clone() => AlbergueUserImage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserImage copyWith(void Function(AlbergueUserImage) updates) => super.copyWith((message) => updates(message as AlbergueUserImage)) as AlbergueUserImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserImage create() => AlbergueUserImage._();
  @$core.override
  AlbergueUserImage createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserImage> createRepeated() => $pb.PbList<AlbergueUserImage>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserImage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserImage>(create);
  static AlbergueUserImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get status => $_getBF(3);
  @$pb.TagNumber(4)
  set status($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get updatedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set updatedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get deletedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set deletedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDeletedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeletedAt() => $_clearField(7);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
