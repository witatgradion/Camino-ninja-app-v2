//
//  Generated code. Do not modify.
//  source: route_points.proto
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

class RoutePoints extends $pb.GeneratedMessage {
  factory RoutePoints({
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

  RoutePoints._();

  factory RoutePoints.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RoutePoints.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RoutePoints', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'routeId', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'orderKey', $pb.PbFieldType.O3)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'elevation', $pb.PbFieldType.OD)
    ..aOM<$0.GeoPoint>(5, _omitFieldNames ? '' : 'geoPoint', subBuilder: $0.GeoPoint.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutePoints clone() => RoutePoints()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutePoints copyWith(void Function(RoutePoints) updates) => super.copyWith((message) => updates(message as RoutePoints)) as RoutePoints;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RoutePoints create() => RoutePoints._();
  @$core.override
  RoutePoints createEmptyInstance() => create();
  static $pb.PbList<RoutePoints> createRepeated() => $pb.PbList<RoutePoints>();
  @$core.pragma('dart2js:noInline')
  static RoutePoints getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoutePoints>(create);
  static RoutePoints? _defaultInstance;

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

  @$pb.TagNumber(5)
  $0.GeoPoint get geoPoint => $_getN(4);
  @$pb.TagNumber(5)
  set geoPoint($0.GeoPoint value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasGeoPoint() => $_has(4);
  @$pb.TagNumber(5)
  void clearGeoPoint() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.GeoPoint ensureGeoPoint() => $_ensure(4);
}

class RoutePointsListResponse extends $pb.GeneratedMessage {
  factory RoutePointsListResponse({
    $core.Iterable<RoutePoints>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  RoutePointsListResponse._();

  factory RoutePointsListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RoutePointsListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RoutePointsListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<RoutePoints>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: RoutePoints.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutePointsListResponse clone() => RoutePointsListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RoutePointsListResponse copyWith(void Function(RoutePointsListResponse) updates) => super.copyWith((message) => updates(message as RoutePointsListResponse)) as RoutePointsListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RoutePointsListResponse create() => RoutePointsListResponse._();
  @$core.override
  RoutePointsListResponse createEmptyInstance() => create();
  static $pb.PbList<RoutePointsListResponse> createRepeated() => $pb.PbList<RoutePointsListResponse>();
  @$core.pragma('dart2js:noInline')
  static RoutePointsListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RoutePointsListResponse>(create);
  static RoutePointsListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RoutePoints> get items => $_getList(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
