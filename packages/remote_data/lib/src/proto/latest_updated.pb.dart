//
//  Generated code. Do not modify.
//  source: latest_updated.proto
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

class LatestUpdated extends $pb.GeneratedMessage {
  factory LatestUpdated({
    $core.String? routesUpdatedAt,
    $core.String? routePointsUpdatedAt,
    $core.String? altRoutePointsUpdatedAt,
    $core.String? alberguesUpdatedAt,
    $core.String? citiesUpdatedAt,
    $core.String? albergueUserImagesUpdatedAt,
    $core.String? albergueUserReviewsUpdatedAt,
  }) {
    final result = create();
    if (routesUpdatedAt != null) result.routesUpdatedAt = routesUpdatedAt;
    if (routePointsUpdatedAt != null) result.routePointsUpdatedAt = routePointsUpdatedAt;
    if (altRoutePointsUpdatedAt != null) result.altRoutePointsUpdatedAt = altRoutePointsUpdatedAt;
    if (alberguesUpdatedAt != null) result.alberguesUpdatedAt = alberguesUpdatedAt;
    if (citiesUpdatedAt != null) result.citiesUpdatedAt = citiesUpdatedAt;
    if (albergueUserImagesUpdatedAt != null) result.albergueUserImagesUpdatedAt = albergueUserImagesUpdatedAt;
    if (albergueUserReviewsUpdatedAt != null) result.albergueUserReviewsUpdatedAt = albergueUserReviewsUpdatedAt;
    return result;
  }

  LatestUpdated._();

  factory LatestUpdated.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory LatestUpdated.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LatestUpdated', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'routesUpdatedAt')
    ..aOS(2, _omitFieldNames ? '' : 'routePointsUpdatedAt')
    ..aOS(3, _omitFieldNames ? '' : 'altRoutePointsUpdatedAt')
    ..aOS(4, _omitFieldNames ? '' : 'alberguesUpdatedAt')
    ..aOS(5, _omitFieldNames ? '' : 'citiesUpdatedAt')
    ..aOS(6, _omitFieldNames ? '' : 'albergueUserImagesUpdatedAt')
    ..aOS(7, _omitFieldNames ? '' : 'albergueUserReviewsUpdatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LatestUpdated clone() => LatestUpdated()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LatestUpdated copyWith(void Function(LatestUpdated) updates) => super.copyWith((message) => updates(message as LatestUpdated)) as LatestUpdated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LatestUpdated create() => LatestUpdated._();
  @$core.override
  LatestUpdated createEmptyInstance() => create();
  static $pb.PbList<LatestUpdated> createRepeated() => $pb.PbList<LatestUpdated>();
  @$core.pragma('dart2js:noInline')
  static LatestUpdated getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LatestUpdated>(create);
  static LatestUpdated? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get routesUpdatedAt => $_getSZ(0);
  @$pb.TagNumber(1)
  set routesUpdatedAt($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoutesUpdatedAt() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoutesUpdatedAt() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get routePointsUpdatedAt => $_getSZ(1);
  @$pb.TagNumber(2)
  set routePointsUpdatedAt($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRoutePointsUpdatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearRoutePointsUpdatedAt() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get altRoutePointsUpdatedAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set altRoutePointsUpdatedAt($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAltRoutePointsUpdatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearAltRoutePointsUpdatedAt() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get alberguesUpdatedAt => $_getSZ(3);
  @$pb.TagNumber(4)
  set alberguesUpdatedAt($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAlberguesUpdatedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlberguesUpdatedAt() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get citiesUpdatedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set citiesUpdatedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCitiesUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCitiesUpdatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get albergueUserImagesUpdatedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set albergueUserImagesUpdatedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAlbergueUserImagesUpdatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlbergueUserImagesUpdatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get albergueUserReviewsUpdatedAt => $_getSZ(6);
  @$pb.TagNumber(7)
  set albergueUserReviewsUpdatedAt($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAlbergueUserReviewsUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearAlbergueUserReviewsUpdatedAt() => $_clearField(7);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
