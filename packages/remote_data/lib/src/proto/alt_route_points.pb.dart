//
//  Generated code. Do not modify.
//  source: alt_route_points.proto
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

class AltRoutePoints extends $pb.GeneratedMessage {
  factory AltRoutePoints({
    $core.int? id,
    $core.int? orderKey,
    $core.String? color,
    $core.bool? dotted,
    $core.int? routeId,
    $core.Iterable<AltRoutePointsValues>? altRoutePointsValues,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (orderKey != null) result.orderKey = orderKey;
    if (color != null) result.color = color;
    if (dotted != null) result.dotted = dotted;
    if (routeId != null) result.routeId = routeId;
    if (altRoutePointsValues != null) result.altRoutePointsValues.addAll(altRoutePointsValues);
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AltRoutePoints._();

  factory AltRoutePoints.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AltRoutePoints.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AltRoutePoints', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'orderKey', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'color')
    ..aOB(4, _omitFieldNames ? '' : 'dotted')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'routeId', $pb.PbFieldType.O3)
    ..pc<AltRoutePointsValues>(8, _omitFieldNames ? '' : 'altRoutePointsValues', $pb.PbFieldType.PM, subBuilder: AltRoutePointsValues.create)
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(30, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AltRoutePoints clone() => AltRoutePoints()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AltRoutePoints copyWith(void Function(AltRoutePoints) updates) => super.copyWith((message) => updates(message as AltRoutePoints)) as AltRoutePoints;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AltRoutePoints create() => AltRoutePoints._();
  @$core.override
  AltRoutePoints createEmptyInstance() => create();
  static $pb.PbList<AltRoutePoints> createRepeated() => $pb.PbList<AltRoutePoints>();
  @$core.pragma('dart2js:noInline')
  static AltRoutePoints getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AltRoutePoints>(create);
  static AltRoutePoints? _defaultInstance;

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
  $core.String get color => $_getSZ(2);
  @$pb.TagNumber(3)
  set color($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasColor() => $_has(2);
  @$pb.TagNumber(3)
  void clearColor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get dotted => $_getBF(3);
  @$pb.TagNumber(4)
  set dotted($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDotted() => $_has(3);
  @$pb.TagNumber(4)
  void clearDotted() => $_clearField(4);

  @$pb.TagNumber(7)
  $core.int get routeId => $_getIZ(4);
  @$pb.TagNumber(7)
  set routeId($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(7)
  $core.bool hasRouteId() => $_has(4);
  @$pb.TagNumber(7)
  void clearRouteId() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<AltRoutePointsValues> get altRoutePointsValues => $_getList(5);

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

  @$pb.TagNumber(30)
  $core.String get deletedAt => $_getSZ(8);
  @$pb.TagNumber(30)
  set deletedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(30)
  $core.bool hasDeletedAt() => $_has(8);
  @$pb.TagNumber(30)
  void clearDeletedAt() => $_clearField(30);
}

class AltRoutePointsValues extends $pb.GeneratedMessage {
  factory AltRoutePointsValues({
    $core.int? id,
    $core.int? altRoutePointsId,
    $core.int? orderKey,
    $0.GeoPoint? geoPoint,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (altRoutePointsId != null) result.altRoutePointsId = altRoutePointsId;
    if (orderKey != null) result.orderKey = orderKey;
    if (geoPoint != null) result.geoPoint = geoPoint;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  AltRoutePointsValues._();

  factory AltRoutePointsValues.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AltRoutePointsValues.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AltRoutePointsValues', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'altRoutePointsId', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'orderKey', $pb.PbFieldType.O3)
    ..aOM<$0.GeoPoint>(5, _omitFieldNames ? '' : 'geoPoint', subBuilder: $0.GeoPoint.create)
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(30, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AltRoutePointsValues clone() => AltRoutePointsValues()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AltRoutePointsValues copyWith(void Function(AltRoutePointsValues) updates) => super.copyWith((message) => updates(message as AltRoutePointsValues)) as AltRoutePointsValues;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AltRoutePointsValues create() => AltRoutePointsValues._();
  @$core.override
  AltRoutePointsValues createEmptyInstance() => create();
  static $pb.PbList<AltRoutePointsValues> createRepeated() => $pb.PbList<AltRoutePointsValues>();
  @$core.pragma('dart2js:noInline')
  static AltRoutePointsValues getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AltRoutePointsValues>(create);
  static AltRoutePointsValues? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get altRoutePointsId => $_getIZ(1);
  @$pb.TagNumber(2)
  set altRoutePointsId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAltRoutePointsId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAltRoutePointsId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get orderKey => $_getIZ(2);
  @$pb.TagNumber(3)
  set orderKey($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOrderKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrderKey() => $_clearField(3);

  @$pb.TagNumber(5)
  $0.GeoPoint get geoPoint => $_getN(3);
  @$pb.TagNumber(5)
  set geoPoint($0.GeoPoint value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasGeoPoint() => $_has(3);
  @$pb.TagNumber(5)
  void clearGeoPoint() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.GeoPoint ensureGeoPoint() => $_ensure(3);

  @$pb.TagNumber(28)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(28)
  set createdAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(28)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(28)
  void clearCreatedAt() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get updatedAt => $_getSZ(5);
  @$pb.TagNumber(29)
  set updatedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(29)
  $core.bool hasUpdatedAt() => $_has(5);
  @$pb.TagNumber(29)
  void clearUpdatedAt() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.String get deletedAt => $_getSZ(6);
  @$pb.TagNumber(30)
  set deletedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(30)
  $core.bool hasDeletedAt() => $_has(6);
  @$pb.TagNumber(30)
  void clearDeletedAt() => $_clearField(30);
}

class AltRoutePointsListResponse extends $pb.GeneratedMessage {
  factory AltRoutePointsListResponse({
    $core.Iterable<AltRoutePoints>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  AltRoutePointsListResponse._();

  factory AltRoutePointsListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AltRoutePointsListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AltRoutePointsListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<AltRoutePoints>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: AltRoutePoints.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AltRoutePointsListResponse clone() => AltRoutePointsListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AltRoutePointsListResponse copyWith(void Function(AltRoutePointsListResponse) updates) => super.copyWith((message) => updates(message as AltRoutePointsListResponse)) as AltRoutePointsListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AltRoutePointsListResponse create() => AltRoutePointsListResponse._();
  @$core.override
  AltRoutePointsListResponse createEmptyInstance() => create();
  static $pb.PbList<AltRoutePointsListResponse> createRepeated() => $pb.PbList<AltRoutePointsListResponse>();
  @$core.pragma('dart2js:noInline')
  static AltRoutePointsListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AltRoutePointsListResponse>(create);
  static AltRoutePointsListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AltRoutePoints> get items => $_getList(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
