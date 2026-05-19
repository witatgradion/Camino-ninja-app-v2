//
//  Generated code. Do not modify.
//  source: route.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Route extends $pb.GeneratedMessage {
  factory Route({
    $core.int? id,
    $core.int? orderKey,
    $core.String? routeName,
    $core.String? routeSubName,
    $core.String? legendColor,
    $core.bool? status,
    $core.String? lightLegendColor,
    $core.String? darkLegendColor,
    $core.String? shortName,
    $core.String? createdAt,
    $core.String? updatedAt,
    $core.String? deletedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (orderKey != null) result.orderKey = orderKey;
    if (routeName != null) result.routeName = routeName;
    if (routeSubName != null) result.routeSubName = routeSubName;
    if (legendColor != null) result.legendColor = legendColor;
    if (status != null) result.status = status;
    if (lightLegendColor != null) result.lightLegendColor = lightLegendColor;
    if (darkLegendColor != null) result.darkLegendColor = darkLegendColor;
    if (shortName != null) result.shortName = shortName;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (deletedAt != null) result.deletedAt = deletedAt;
    return result;
  }

  Route._();

  factory Route.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory Route.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Route', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'orderKey', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'routeName')
    ..aOS(4, _omitFieldNames ? '' : 'routeSubName')
    ..aOS(5, _omitFieldNames ? '' : 'legendColor')
    ..aOB(6, _omitFieldNames ? '' : 'status')
    ..aOS(7, _omitFieldNames ? '' : 'lightLegendColor')
    ..aOS(8, _omitFieldNames ? '' : 'darkLegendColor')
    ..aOS(9, _omitFieldNames ? '' : 'shortName')
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(30, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Route clone() => Route()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Route copyWith(void Function(Route) updates) => super.copyWith((message) => updates(message as Route)) as Route;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Route create() => Route._();
  @$core.override
  Route createEmptyInstance() => create();
  static $pb.PbList<Route> createRepeated() => $pb.PbList<Route>();
  @$core.pragma('dart2js:noInline')
  static Route getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Route>(create);
  static Route? _defaultInstance;

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

  @$pb.TagNumber(7)
  $core.String get lightLegendColor => $_getSZ(6);
  @$pb.TagNumber(7)
  set lightLegendColor($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLightLegendColor() => $_has(6);
  @$pb.TagNumber(7)
  void clearLightLegendColor() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get darkLegendColor => $_getSZ(7);
  @$pb.TagNumber(8)
  set darkLegendColor($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDarkLegendColor() => $_has(7);
  @$pb.TagNumber(8)
  void clearDarkLegendColor() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get shortName => $_getSZ(8);
  @$pb.TagNumber(9)
  set shortName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasShortName() => $_has(8);
  @$pb.TagNumber(9)
  void clearShortName() => $_clearField(9);

  @$pb.TagNumber(28)
  $core.String get createdAt => $_getSZ(9);
  @$pb.TagNumber(28)
  set createdAt($core.String value) => $_setString(9, value);
  @$pb.TagNumber(28)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(28)
  void clearCreatedAt() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get updatedAt => $_getSZ(10);
  @$pb.TagNumber(29)
  set updatedAt($core.String value) => $_setString(10, value);
  @$pb.TagNumber(29)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(29)
  void clearUpdatedAt() => $_clearField(29);

  @$pb.TagNumber(30)
  $core.String get deletedAt => $_getSZ(11);
  @$pb.TagNumber(30)
  set deletedAt($core.String value) => $_setString(11, value);
  @$pb.TagNumber(30)
  $core.bool hasDeletedAt() => $_has(11);
  @$pb.TagNumber(30)
  void clearDeletedAt() => $_clearField(30);
}

class RouteListResponse extends $pb.GeneratedMessage {
  factory RouteListResponse({
    $core.Iterable<Route>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  RouteListResponse._();

  factory RouteListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory RouteListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RouteListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<Route>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: Route.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouteListResponse clone() => RouteListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RouteListResponse copyWith(void Function(RouteListResponse) updates) => super.copyWith((message) => updates(message as RouteListResponse)) as RouteListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RouteListResponse create() => RouteListResponse._();
  @$core.override
  RouteListResponse createEmptyInstance() => create();
  static $pb.PbList<RouteListResponse> createRepeated() => $pb.PbList<RouteListResponse>();
  @$core.pragma('dart2js:noInline')
  static RouteListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RouteListResponse>(create);
  static RouteListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Route> get items => $_getList(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
