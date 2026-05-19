//
//  Generated code. Do not modify.
//  source: city.proto
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

class CityRoutes extends $pb.GeneratedMessage {
  factory CityRoutes({
    $core.int? id,
    $core.int? orderKey,
    $core.String? routeName,
    $core.String? routeSubName,
    $core.String? legendColor,
    $core.bool? status,
    $core.String? createdAt,
    $core.String? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (orderKey != null) result.orderKey = orderKey;
    if (routeName != null) result.routeName = routeName;
    if (routeSubName != null) result.routeSubName = routeSubName;
    if (legendColor != null) result.legendColor = legendColor;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  CityRoutes._();

  factory CityRoutes.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CityRoutes.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CityRoutes', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'orderKey', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'routeName')
    ..aOS(4, _omitFieldNames ? '' : 'routeSubName')
    ..aOS(5, _omitFieldNames ? '' : 'legendColor')
    ..aOB(6, _omitFieldNames ? '' : 'status')
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityRoutes clone() => CityRoutes()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityRoutes copyWith(void Function(CityRoutes) updates) => super.copyWith((message) => updates(message as CityRoutes)) as CityRoutes;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CityRoutes create() => CityRoutes._();
  @$core.override
  CityRoutes createEmptyInstance() => create();
  static $pb.PbList<CityRoutes> createRepeated() => $pb.PbList<CityRoutes>();
  @$core.pragma('dart2js:noInline')
  static CityRoutes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CityRoutes>(create);
  static CityRoutes? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get orderKey => $_getIZ(1);
  @$pb.TagNumber(2)
  set orderKey($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrderKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrderKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get routeName => $_getSZ(2);
  @$pb.TagNumber(3)
  set routeName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRouteName() => $_has(2);
  @$pb.TagNumber(3)
  void clearRouteName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get routeSubName => $_getSZ(3);
  @$pb.TagNumber(4)
  set routeSubName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRouteSubName() => $_has(3);
  @$pb.TagNumber(4)
  void clearRouteSubName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get legendColor => $_getSZ(4);
  @$pb.TagNumber(5)
  set legendColor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLegendColor() => $_has(4);
  @$pb.TagNumber(5)
  void clearLegendColor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get status => $_getBF(5);
  @$pb.TagNumber(6)
  set status($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(28)
  $core.String get createdAt => $_getSZ(6);
  @$pb.TagNumber(28)
  set createdAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(28)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(28)
  void clearCreatedAt() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get updatedAt => $_getSZ(7);
  @$pb.TagNumber(29)
  set updatedAt($core.String value) => $_setString(7, value);
  @$pb.TagNumber(29)
  $core.bool hasUpdatedAt() => $_has(7);
  @$pb.TagNumber(29)
  void clearUpdatedAt() => $_clearField(29);
}

class CityRoutePoints extends $pb.GeneratedMessage {
  factory CityRoutePoints({
    $core.int? id,
    $core.int? routeId,
    $core.int? orderKey,
    $core.double? elevation,
    $0.GeoPoint? geoPoint,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (routeId != null) result.routeId = routeId;
    if (orderKey != null) result.orderKey = orderKey;
    if (elevation != null) result.elevation = elevation;
    if (geoPoint != null) result.geoPoint = geoPoint;
    return result;
  }

  CityRoutePoints._();

  factory CityRoutePoints.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CityRoutePoints.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CityRoutePoints', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'routeId', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'orderKey', $pb.PbFieldType.O3)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'elevation', $pb.PbFieldType.OD)
    ..aOM<$0.GeoPoint>(7, _omitFieldNames ? '' : 'geoPoint', subBuilder: $0.GeoPoint.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityRoutePoints clone() => CityRoutePoints()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityRoutePoints copyWith(void Function(CityRoutePoints) updates) => super.copyWith((message) => updates(message as CityRoutePoints)) as CityRoutePoints;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CityRoutePoints create() => CityRoutePoints._();
  @$core.override
  CityRoutePoints createEmptyInstance() => create();
  static $pb.PbList<CityRoutePoints> createRepeated() => $pb.PbList<CityRoutePoints>();
  @$core.pragma('dart2js:noInline')
  static CityRoutePoints getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CityRoutePoints>(create);
  static CityRoutePoints? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get routeId => $_getIZ(1);
  @$pb.TagNumber(2)
  set routeId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRouteId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRouteId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get orderKey => $_getIZ(2);
  @$pb.TagNumber(3)
  set orderKey($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrderKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get elevation => $_getN(3);
  @$pb.TagNumber(4)
  set elevation($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasElevation() => $_has(3);
  @$pb.TagNumber(4)
  void clearElevation() => $_clearField(4);

  @$pb.TagNumber(7)
  $0.GeoPoint get geoPoint => $_getN(4);
  @$pb.TagNumber(7)
  set geoPoint($0.GeoPoint value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasGeoPoint() => $_has(4);
  @$pb.TagNumber(7)
  void clearGeoPoint() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.GeoPoint ensureGeoPoint() => $_ensure(4);
}

class City extends $pb.GeneratedMessage {
  factory City({
    $core.int? id,
    $core.String? name,
    $core.String? country,
    $core.String? region,
    $core.String? province,
    $core.String? slug,
    $core.int? km,
    $core.bool? hasAtm,
    $core.bool? hasBarCafe,
    $core.bool? hasRestaurant,
    $core.bool? hasShop,
    $core.bool? hasMedClinic,
    $core.bool? hasPharmacy,
    $core.bool? hasFountain,
    $core.bool? hasPostOffice,
    $core.bool? hasBusStation,
    $core.bool? hasTrainStation,
    $core.bool? etapeCity,
    $core.bool? hasTobaccoStore,
    $core.bool? hasAirport,
    $core.String? shareUrl,
    $core.String? search,
    $0.GeoPoint? geoPoint,
    $core.Iterable<CityRoutes>? routes,
    $core.Iterable<CityRoutePoints>? routePoints,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (country != null) result.country = country;
    if (region != null) result.region = region;
    if (province != null) result.province = province;
    if (slug != null) result.slug = slug;
    if (km != null) result.km = km;
    if (hasAtm != null) result.hasAtm = hasAtm;
    if (hasBarCafe != null) result.hasBarCafe = hasBarCafe;
    if (hasRestaurant != null) result.hasRestaurant = hasRestaurant;
    if (hasShop != null) result.hasShop = hasShop;
    if (hasMedClinic != null) result.hasMedClinic = hasMedClinic;
    if (hasPharmacy != null) result.hasPharmacy = hasPharmacy;
    if (hasFountain != null) result.hasFountain = hasFountain;
    if (hasPostOffice != null) result.hasPostOffice = hasPostOffice;
    if (hasBusStation != null) result.hasBusStation = hasBusStation;
    if (hasTrainStation != null) result.hasTrainStation = hasTrainStation;
    if (etapeCity != null) result.etapeCity = etapeCity;
    if (hasTobaccoStore != null) result.hasTobaccoStore = hasTobaccoStore;
    if (hasAirport != null) result.hasAirport = hasAirport;
    if (shareUrl != null) result.shareUrl = shareUrl;
    if (search != null) result.search = search;
    if (geoPoint != null) result.geoPoint = geoPoint;
    if (routes != null) result.routes.addAll(routes);
    if (routePoints != null) result.routePoints.addAll(routePoints);
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  City._();

  factory City.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory City.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'City', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'country')
    ..aOS(4, _omitFieldNames ? '' : 'region')
    ..aOS(5, _omitFieldNames ? '' : 'province')
    ..aOS(6, _omitFieldNames ? '' : 'slug')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'km', $pb.PbFieldType.O3)
    ..aOB(8, _omitFieldNames ? '' : 'hasAtm')
    ..aOB(9, _omitFieldNames ? '' : 'hasBarCafe')
    ..aOB(10, _omitFieldNames ? '' : 'hasRestaurant')
    ..aOB(11, _omitFieldNames ? '' : 'hasShop')
    ..aOB(12, _omitFieldNames ? '' : 'hasMedClinic')
    ..aOB(13, _omitFieldNames ? '' : 'hasPharmacy')
    ..aOB(14, _omitFieldNames ? '' : 'hasFountain')
    ..aOB(15, _omitFieldNames ? '' : 'hasPostOffice')
    ..aOB(16, _omitFieldNames ? '' : 'hasBusStation')
    ..aOB(17, _omitFieldNames ? '' : 'hasTrainStation')
    ..aOB(18, _omitFieldNames ? '' : 'etapeCity')
    ..aOB(19, _omitFieldNames ? '' : 'hasTobaccoStore')
    ..aOB(20, _omitFieldNames ? '' : 'hasAirport')
    ..aOS(21, _omitFieldNames ? '' : 'shareUrl')
    ..aOS(22, _omitFieldNames ? '' : 'search')
    ..aOM<$0.GeoPoint>(23, _omitFieldNames ? '' : 'geoPoint', subBuilder: $0.GeoPoint.create)
    ..pc<CityRoutes>(24, _omitFieldNames ? '' : 'routes', $pb.PbFieldType.PM, subBuilder: CityRoutes.create)
    ..pc<CityRoutePoints>(25, _omitFieldNames ? '' : 'routePoints', $pb.PbFieldType.PM, subBuilder: CityRoutePoints.create)
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(30, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  City clone() => City()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  City copyWith(void Function(City) updates) => super.copyWith((message) => updates(message as City)) as City;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static City create() => City._();
  @$core.override
  City createEmptyInstance() => create();
  static $pb.PbList<City> createRepeated() => $pb.PbList<City>();
  @$core.pragma('dart2js:noInline')
  static City getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<City>(create);
  static City? _defaultInstance;

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
  $core.String get country => $_getSZ(2);
  @$pb.TagNumber(3)
  set country($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCountry() => $_has(2);
  @$pb.TagNumber(3)
  void clearCountry() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get region => $_getSZ(3);
  @$pb.TagNumber(4)
  set region($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRegion() => $_has(3);
  @$pb.TagNumber(4)
  void clearRegion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get province => $_getSZ(4);
  @$pb.TagNumber(5)
  set province($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProvince() => $_has(4);
  @$pb.TagNumber(5)
  void clearProvince() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get slug => $_getSZ(5);
  @$pb.TagNumber(6)
  set slug($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSlug() => $_has(5);
  @$pb.TagNumber(6)
  void clearSlug() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get km => $_getIZ(6);
  @$pb.TagNumber(7)
  set km($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasKm() => $_has(6);
  @$pb.TagNumber(7)
  void clearKm() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get hasAtm => $_getBF(7);
  @$pb.TagNumber(8)
  set hasAtm($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHasAtm() => $_has(7);
  @$pb.TagNumber(8)
  void clearHasAtm() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get hasBarCafe => $_getBF(8);
  @$pb.TagNumber(9)
  set hasBarCafe($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHasBarCafe() => $_has(8);
  @$pb.TagNumber(9)
  void clearHasBarCafe() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get hasRestaurant => $_getBF(9);
  @$pb.TagNumber(10)
  set hasRestaurant($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHasRestaurant() => $_has(9);
  @$pb.TagNumber(10)
  void clearHasRestaurant() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get hasShop => $_getBF(10);
  @$pb.TagNumber(11)
  set hasShop($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHasShop() => $_has(10);
  @$pb.TagNumber(11)
  void clearHasShop() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasMedClinic => $_getBF(11);
  @$pb.TagNumber(12)
  set hasMedClinic($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHasMedClinic() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasMedClinic() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get hasPharmacy => $_getBF(12);
  @$pb.TagNumber(13)
  set hasPharmacy($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasHasPharmacy() => $_has(12);
  @$pb.TagNumber(13)
  void clearHasPharmacy() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get hasFountain => $_getBF(13);
  @$pb.TagNumber(14)
  set hasFountain($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasHasFountain() => $_has(13);
  @$pb.TagNumber(14)
  void clearHasFountain() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get hasPostOffice => $_getBF(14);
  @$pb.TagNumber(15)
  set hasPostOffice($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasHasPostOffice() => $_has(14);
  @$pb.TagNumber(15)
  void clearHasPostOffice() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.bool get hasBusStation => $_getBF(15);
  @$pb.TagNumber(16)
  set hasBusStation($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasHasBusStation() => $_has(15);
  @$pb.TagNumber(16)
  void clearHasBusStation() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.bool get hasTrainStation => $_getBF(16);
  @$pb.TagNumber(17)
  set hasTrainStation($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasHasTrainStation() => $_has(16);
  @$pb.TagNumber(17)
  void clearHasTrainStation() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.bool get etapeCity => $_getBF(17);
  @$pb.TagNumber(18)
  set etapeCity($core.bool value) => $_setBool(17, value);
  @$pb.TagNumber(18)
  $core.bool hasEtapeCity() => $_has(17);
  @$pb.TagNumber(18)
  void clearEtapeCity() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.bool get hasTobaccoStore => $_getBF(18);
  @$pb.TagNumber(19)
  set hasTobaccoStore($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasHasTobaccoStore() => $_has(18);
  @$pb.TagNumber(19)
  void clearHasTobaccoStore() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.bool get hasAirport => $_getBF(19);
  @$pb.TagNumber(20)
  set hasAirport($core.bool value) => $_setBool(19, value);
  @$pb.TagNumber(20)
  $core.bool hasHasAirport() => $_has(19);
  @$pb.TagNumber(20)
  void clearHasAirport() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get shareUrl => $_getSZ(20);
  @$pb.TagNumber(21)
  set shareUrl($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasShareUrl() => $_has(20);
  @$pb.TagNumber(21)
  void clearShareUrl() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get search => $_getSZ(21);
  @$pb.TagNumber(22)
  set search($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasSearch() => $_has(21);
  @$pb.TagNumber(22)
  void clearSearch() => $_clearField(22);

  @$pb.TagNumber(23)
  $0.GeoPoint get geoPoint => $_getN(22);
  @$pb.TagNumber(23)
  set geoPoint($0.GeoPoint value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasGeoPoint() => $_has(22);
  @$pb.TagNumber(23)
  void clearGeoPoint() => $_clearField(23);
  @$pb.TagNumber(23)
  $0.GeoPoint ensureGeoPoint() => $_ensure(22);

  @$pb.TagNumber(24)
  $pb.PbList<CityRoutes> get routes => $_getList(23);

  @$pb.TagNumber(25)
  $pb.PbList<CityRoutePoints> get routePoints => $_getList(24);

  @$pb.TagNumber(28)
  $core.String get createdAt => $_getSZ(25);
  @$pb.TagNumber(28)
  set createdAt($core.String value) => $_setString(25, value);
  @$pb.TagNumber(28)
  $core.bool hasCreatedAt() => $_has(25);
  @$pb.TagNumber(28)
  void clearCreatedAt() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get updatedAt => $_getSZ(26);
  @$pb.TagNumber(29)
  set updatedAt($core.String value) => $_setString(26, value);
  @$pb.TagNumber(29)
  $core.bool hasUpdatedAt() => $_has(26);
  @$pb.TagNumber(29)
  void clearUpdatedAt() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.String get deletedAt => $_getSZ(27);
  @$pb.TagNumber(30)
  set deletedAt($core.String value) => $_setString(27, value);
  @$pb.TagNumber(30)
  $core.bool hasDeletedAt() => $_has(27);
  @$pb.TagNumber(30)
  void clearDeletedAt() => $_clearField(30);
}

class CityListResponse extends $pb.GeneratedMessage {
  factory CityListResponse({
    $core.Iterable<City>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  CityListResponse._();

  factory CityListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CityListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CityListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<City>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: City.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityListResponse clone() => CityListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityListResponse copyWith(void Function(CityListResponse) updates) => super.copyWith((message) => updates(message as CityListResponse)) as CityListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CityListResponse create() => CityListResponse._();
  @$core.override
  CityListResponse createEmptyInstance() => create();
  static $pb.PbList<CityListResponse> createRepeated() => $pb.PbList<CityListResponse>();
  @$core.pragma('dart2js:noInline')
  static CityListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CityListResponse>(create);
  static CityListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<City> get items => $_getList(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
