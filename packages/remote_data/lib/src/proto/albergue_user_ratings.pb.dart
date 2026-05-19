//
//  Generated code. Do not modify.
//  source: albergue_user_ratings.proto
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

class AlbergueUserRatings extends $pb.GeneratedMessage {
  factory AlbergueUserRatings({
    $core.int? albergueId,
    $core.double? rating,
    $core.int? totalApprovedReviews,
  }) {
    final result = create();
    if (albergueId != null) result.albergueId = albergueId;
    if (rating != null) result.rating = rating;
    if (totalApprovedReviews != null) result.totalApprovedReviews = totalApprovedReviews;
    return result;
  }

  AlbergueUserRatings._();

  factory AlbergueUserRatings.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserRatings.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserRatings', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'rating', $pb.PbFieldType.OF)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'totalApprovedReviews', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserRatings clone() => AlbergueUserRatings()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserRatings copyWith(void Function(AlbergueUserRatings) updates) => super.copyWith((message) => updates(message as AlbergueUserRatings)) as AlbergueUserRatings;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserRatings create() => AlbergueUserRatings._();
  @$core.override
  AlbergueUserRatings createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserRatings> createRepeated() => $pb.PbList<AlbergueUserRatings>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserRatings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserRatings>(create);
  static AlbergueUserRatings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get albergueId => $_getIZ(0);
  @$pb.TagNumber(1)
  set albergueId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAlbergueId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlbergueId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get rating => $_getN(1);
  @$pb.TagNumber(2)
  set rating($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRating() => $_has(1);
  @$pb.TagNumber(2)
  void clearRating() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalApprovedReviews => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalApprovedReviews($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalApprovedReviews() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalApprovedReviews() => $_clearField(3);
}

class AlbergueUserRatingsListResponse extends $pb.GeneratedMessage {
  factory AlbergueUserRatingsListResponse({
    $core.Iterable<AlbergueUserRatings>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  AlbergueUserRatingsListResponse._();

  factory AlbergueUserRatingsListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserRatingsListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserRatingsListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<AlbergueUserRatings>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: AlbergueUserRatings.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserRatingsListResponse clone() => AlbergueUserRatingsListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserRatingsListResponse copyWith(void Function(AlbergueUserRatingsListResponse) updates) => super.copyWith((message) => updates(message as AlbergueUserRatingsListResponse)) as AlbergueUserRatingsListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserRatingsListResponse create() => AlbergueUserRatingsListResponse._();
  @$core.override
  AlbergueUserRatingsListResponse createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserRatingsListResponse> createRepeated() => $pb.PbList<AlbergueUserRatingsListResponse>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserRatingsListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserRatingsListResponse>(create);
  static AlbergueUserRatingsListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AlbergueUserRatings> get items => $_getList(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
