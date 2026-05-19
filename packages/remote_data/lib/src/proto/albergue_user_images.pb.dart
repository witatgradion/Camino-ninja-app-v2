//
//  Generated code. Do not modify.
//  source: albergue_user_images.proto
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

class AlbergueUserImages extends $pb.GeneratedMessage {
  factory AlbergueUserImages({
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

  AlbergueUserImages._();

  factory AlbergueUserImages.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserImages.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserImages', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'albergueId', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'fileKey')
    ..aOB(4, _omitFieldNames ? '' : 'status')
    ..aOS(28, _omitFieldNames ? '' : 'createdAt')
    ..aOS(29, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(30, _omitFieldNames ? '' : 'deletedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserImages clone() => AlbergueUserImages()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserImages copyWith(void Function(AlbergueUserImages) updates) => super.copyWith((message) => updates(message as AlbergueUserImages)) as AlbergueUserImages;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserImages create() => AlbergueUserImages._();
  @$core.override
  AlbergueUserImages createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserImages> createRepeated() => $pb.PbList<AlbergueUserImages>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserImages getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserImages>(create);
  static AlbergueUserImages? _defaultInstance;

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

class AlbergueUserImagesListResponse extends $pb.GeneratedMessage {
  factory AlbergueUserImagesListResponse({
    $core.Iterable<AlbergueUserImages>? items,
  }) {
    final result = create();
    if (items != null) result.items.addAll(items);
    return result;
  }

  AlbergueUserImagesListResponse._();

  factory AlbergueUserImagesListResponse.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory AlbergueUserImagesListResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AlbergueUserImagesListResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..pc<AlbergueUserImages>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: AlbergueUserImages.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserImagesListResponse clone() => AlbergueUserImagesListResponse()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlbergueUserImagesListResponse copyWith(void Function(AlbergueUserImagesListResponse) updates) => super.copyWith((message) => updates(message as AlbergueUserImagesListResponse)) as AlbergueUserImagesListResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlbergueUserImagesListResponse create() => AlbergueUserImagesListResponse._();
  @$core.override
  AlbergueUserImagesListResponse createEmptyInstance() => create();
  static $pb.PbList<AlbergueUserImagesListResponse> createRepeated() => $pb.PbList<AlbergueUserImagesListResponse>();
  @$core.pragma('dart2js:noInline')
  static AlbergueUserImagesListResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlbergueUserImagesListResponse>(create);
  static AlbergueUserImagesListResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AlbergueUserImages> get items => $_getList(0);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
