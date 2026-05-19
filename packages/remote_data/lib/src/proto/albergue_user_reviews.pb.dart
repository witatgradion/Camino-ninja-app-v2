//
//  Generated code. Do not modify.
//  source: albergue_user_reviews.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class AlbergueUserReviewsImages extends $pb.GeneratedMessage {
  factory AlbergueUserReviewsImages({
    $core.int? id,
    $core.int? albergueUserReviewsId,
    $core.String? fileKey,
    $core.bool? status,
    $core.String? createdAt,
    $core.String? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (albergueUserReviewsId != null) result.albergueUserReviewsId = albergueUserReviewsId;
    if (fileKey != null) result.fileKey = fileKey;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  AlbergueUserReviewsImages._();

  factory AlbergueUserReviewsImages.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserReviewsImages.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserReviewsImages', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueUserReviewsId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'fileKey')
    ..aOB(4, _omitFieldNames ? '' : 'status')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviewsImages clone() => AlbergueUserReviewsImages()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviewsImages copyWith(void Function(AlbergueUserReviewsImages) updates) => super.copyWith((message) => updates(message as AlbergueUserReviewsImages)) as AlbergueUserReviewsImages;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviewsImages create() => AlbergueUserReviewsImages._();
  @$core.override
  AlbergueUserReviewsImages createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserReviewsImages> createRepeated() => $pb.PbList<AlbergueUserReviewsImages>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviewsImages getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserReviewsImages>(create);
  static AlbergueUserReviewsImages? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get albergueUserReviewsId => $_getIZ(1);
  @$pb.TagNumber(2)
  set albergueUserReviewsId($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlbergueUserReviewsId() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlbergueUserReviewsId() => $_clearField(2);

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
}

class AlbergueUserReviews extends $pb.GeneratedMessage {
  factory AlbergueUserReviews({
    $core.int? albergueId,
    $core.bool? status,
    $core.String? name,
    $core.String? email,
    $core.String? userComment,
    $core.double? userRating,
    $core.Iterable<AlbergueUserReviewsImages>? images,
    $core.String? sourceLang,
    $core.String? translatedComment,
    $core.String? displayLang,
    $core.bool? isTranslated,
    $core.int? id,
    $core.String? createdAt,
    $core.String? updatedAt,
  }) {
    final result = create();
    if (albergueId != null) result.albergueId = albergueId;
    if (status != null) result.status = status;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (userComment != null) result.userComment = userComment;
    if (userRating != null) result.userRating = userRating;
    if (images != null) result.images.addAll(images);
    if (sourceLang != null) result.sourceLang = sourceLang;
    if (translatedComment != null) result.translatedComment = translatedComment;
    if (displayLang != null) result.displayLang = displayLang;
    if (isTranslated != null) result.isTranslated = isTranslated;
    if (id != null) result.id = id;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  AlbergueUserReviews._();

  factory AlbergueUserReviews.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserReviews.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserReviews', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOB(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'userComment')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'userRating', $pb.PbFieldType.OD)
    ..pc<AlbergueUserReviewsImages>(7, _omitFieldNames ? '' : 'images', $pb.PbFieldType.PM, subBuilder: AlbergueUserReviewsImages.create)
    ..aOS(8, _omitFieldNames ? '' : 'sourceLang')
    ..aOS(9, _omitFieldNames ? '' : 'translatedComment')
    ..aOS(10, _omitFieldNames ? '' : 'displayLang')
    ..aOB(11, _omitFieldNames ? '' : 'isTranslated')
    ..a<$core.int>(12, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviews clone() => AlbergueUserReviews()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviews copyWith(void Function(AlbergueUserReviews) updates) => super.copyWith((message) => updates(message as AlbergueUserReviews)) as AlbergueUserReviews;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviews create() => AlbergueUserReviews._();
  @$core.override
  AlbergueUserReviews createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserReviews> createRepeated() => $pb.PbList<AlbergueUserReviews>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviews getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserReviews>(create);
  static AlbergueUserReviews? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get albergueId => $_getIZ(0);
  @$pb.TagNumber(1)
  set albergueId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAlbergueId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlbergueId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get status => $_getBF(1);
  @$pb.TagNumber(2)
  set status($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get userComment => $_getSZ(4);
  @$pb.TagNumber(5)
  set userComment($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUserComment() => $_has(4);
  @$pb.TagNumber(5)
  void clearUserComment() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get userRating => $_getN(5);
  @$pb.TagNumber(6)
  set userRating($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUserRating() => $_has(5);
  @$pb.TagNumber(6)
  void clearUserRating() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<AlbergueUserReviewsImages> get images => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get sourceLang => $_getSZ(7);
  @$pb.TagNumber(8)
  set sourceLang($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSourceLang() => $_has(7);
  @$pb.TagNumber(8)
  void clearSourceLang() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get translatedComment => $_getSZ(8);
  @$pb.TagNumber(9)
  set translatedComment($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTranslatedComment() => $_has(8);
  @$pb.TagNumber(9)
  void clearTranslatedComment() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get displayLang => $_getSZ(9);
  @$pb.TagNumber(10)
  set displayLang($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDisplayLang() => $_has(9);
  @$pb.TagNumber(10)
  void clearDisplayLang() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get isTranslated => $_getBF(10);
  @$pb.TagNumber(11)
  set isTranslated($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIsTranslated() => $_has(10);
  @$pb.TagNumber(11)
  void clearIsTranslated() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get id => $_getIZ(11);
  @$pb.TagNumber(12)
  set id($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasId() => $_has(11);
  @$pb.TagNumber(12)
  void clearId() => $_clearField(12);

  @$pb.TagNumber(28)
  $core.String get createdAt => $_getSZ(12);
  @$pb.TagNumber(28)
  set createdAt($core.String value) => $_setString(12, value);
  @$pb.TagNumber(28)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(28)
  void clearCreatedAt() => $_clearField(28);

  @$pb.TagNumber(29)
  $core.String get updatedAt => $_getSZ(13);
  @$pb.TagNumber(29)
  set updatedAt($core.String value) => $_setString(13, value);
  @$pb.TagNumber(29)
  $core.bool hasUpdatedAt() => $_has(13);
  @$pb.TagNumber(29)
  void clearUpdatedAt() => $_clearField(29);
}

class AlbergueUserReviewsByAlbergueId extends $pb.GeneratedMessage {
  factory AlbergueUserReviewsByAlbergueId({
    $fixnum.Int64? total,
    $core.Iterable<AlbergueUserReviews>? albergueUserReviews,
  }) {
    final result = create();
    if (total != null) result.total = total;
    if (albergueUserReviews != null) result.albergueUserReviews.addAll(albergueUserReviews);
    return result;
  }

  AlbergueUserReviewsByAlbergueId._();

  factory AlbergueUserReviewsByAlbergueId.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserReviewsByAlbergueId.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserReviewsByAlbergueId', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'total')
    ..pc<AlbergueUserReviews>(2, _omitFieldNames ? '' : 'albergueUserReviews', $pb.PbFieldType.PM, subBuilder: AlbergueUserReviews.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviewsByAlbergueId clone() => AlbergueUserReviewsByAlbergueId()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviewsByAlbergueId copyWith(void Function(AlbergueUserReviewsByAlbergueId) updates) => super.copyWith((message) => updates(message as AlbergueUserReviewsByAlbergueId)) as AlbergueUserReviewsByAlbergueId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviewsByAlbergueId create() => AlbergueUserReviewsByAlbergueId._();
  @$core.override
  AlbergueUserReviewsByAlbergueId createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserReviewsByAlbergueId> createRepeated() => $pb.PbList<AlbergueUserReviewsByAlbergueId>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviewsByAlbergueId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserReviewsByAlbergueId>(create);
  static AlbergueUserReviewsByAlbergueId? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get total => $_getI64(0);
  @$pb.TagNumber(1)
  set total($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotal() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotal() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<AlbergueUserReviews> get albergueUserReviews => $_getList(1);
}

class AlbergueUserReviewsListResponse extends $pb.GeneratedMessage {
  factory AlbergueUserReviewsListResponse({
    $core.Iterable<AlbergueUserReviews>? albergueUserReviews,
  }) {
    final result = create();
    if (albergueUserReviews != null) result.albergueUserReviews.addAll(albergueUserReviews);
    return result;
  }

  AlbergueUserReviewsListResponse._();

  factory AlbergueUserReviewsListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserReviewsListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserReviewsListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<AlbergueUserReviews>(1, _omitFieldNames ? '' : 'albergueUserReviews', $pb.PbFieldType.PM, subBuilder: AlbergueUserReviews.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviewsListResponse clone() => AlbergueUserReviewsListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserReviewsListResponse copyWith(void Function(AlbergueUserReviewsListResponse) updates) => super.copyWith((message) => updates(message as AlbergueUserReviewsListResponse)) as AlbergueUserReviewsListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviewsListResponse create() => AlbergueUserReviewsListResponse._();
  @$core.override
  AlbergueUserReviewsListResponse createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserReviewsListResponse> createRepeated() => $pb.PbList<AlbergueUserReviewsListResponse>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserReviewsListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserReviewsListResponse>(create);
  static AlbergueUserReviewsListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AlbergueUserReviews> get albergueUserReviews => $_getList(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
