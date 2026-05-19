//
//  Generated code. Do not modify.
//  source: city_pairs.proto
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

/// CityPairDetail represents a single end city option with percentage
class CityPairDetail extends $pb.GeneratedMessage {
  factory CityPairDetail({
    $core.int? endCityId,
    $core.String? endCityName,
    $core.double? percentage,
    $core.int? pairCount,
    $core.double? distanceKm,
  }) {
    final result = create();
    if (endCityId != null) result.endCityId = endCityId;
    if (endCityName != null) result.endCityName = endCityName;
    if (percentage != null) result.percentage = percentage;
    if (pairCount != null) result.pairCount = pairCount;
    if (distanceKm != null) result.distanceKm = distanceKm;
    return result;
  }

  CityPairDetail._();

  factory CityPairDetail.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CityPairDetail.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CityPairDetail', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'endCityId', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'endCityName')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'percentage', $pb.PbFieldType.OF)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'pairCount', $pb.PbFieldType.O3)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'distanceKm', $pb.PbFieldType.OF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityPairDetail clone() => CityPairDetail()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityPairDetail copyWith(void Function(CityPairDetail) updates) => super.copyWith((message) => updates(message as CityPairDetail)) as CityPairDetail;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CityPairDetail create() => CityPairDetail._();
  @$core.override
  CityPairDetail createEmptyInstance() => create();
  static $pb.PbList<CityPairDetail> createRepeated() => $pb.PbList<CityPairDetail>();
  @$core.pragma('dart2js:noInline')
  static CityPairDetail getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CityPairDetail>(create);
  static CityPairDetail? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get endCityId => $_getIZ(0);
  @$pb.TagNumber(1)
  set endCityId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEndCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEndCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get endCityName => $_getSZ(1);
  @$pb.TagNumber(2)
  set endCityName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEndCityName() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndCityName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get percentage => $_getN(2);
  @$pb.TagNumber(3)
  set percentage($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPercentage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPercentage() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pairCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set pairCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPairCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearPairCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get distanceKm => $_getN(4);
  @$pb.TagNumber(5)
  set distanceKm($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDistanceKm() => $_has(4);
  @$pb.TagNumber(5)
  void clearDistanceKm() => $_clearField(5);
}

/// CityPairsForStartCity is the response for pairs from a start city
class CityPairsForStartCity extends $pb.GeneratedMessage {
  factory CityPairsForStartCity({
    $core.int? startCityId,
    $core.String? startCityName,
    $core.int? totalPlans,
    $core.Iterable<CityPairDetail>? pairs,
  }) {
    final result = create();
    if (startCityId != null) result.startCityId = startCityId;
    if (startCityName != null) result.startCityName = startCityName;
    if (totalPlans != null) result.totalPlans = totalPlans;
    if (pairs != null) result.pairs.addAll(pairs);
    return result;
  }

  CityPairsForStartCity._();

  factory CityPairsForStartCity.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CityPairsForStartCity.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CityPairsForStartCity', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'startCityId', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'startCityName')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'totalPlans', $pb.PbFieldType.O3)
    ..pc<CityPairDetail>(4, _omitFieldNames ? '' : 'pairs', $pb.PbFieldType.PM, subBuilder: CityPairDetail.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityPairsForStartCity clone() => CityPairsForStartCity()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityPairsForStartCity copyWith(void Function(CityPairsForStartCity) updates) => super.copyWith((message) => updates(message as CityPairsForStartCity)) as CityPairsForStartCity;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CityPairsForStartCity create() => CityPairsForStartCity._();
  @$core.override
  CityPairsForStartCity createEmptyInstance() => create();
  static $pb.PbList<CityPairsForStartCity> createRepeated() => $pb.PbList<CityPairsForStartCity>();
  @$core.pragma('dart2js:noInline')
  static CityPairsForStartCity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CityPairsForStartCity>(create);
  static CityPairsForStartCity? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get startCityId => $_getIZ(0);
  @$pb.TagNumber(1)
  set startCityId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartCityId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartCityId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get startCityName => $_getSZ(1);
  @$pb.TagNumber(2)
  set startCityName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartCityName() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartCityName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalPlans => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalPlans($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalPlans() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalPlans() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<CityPairDetail> get pairs => $_getList(3);
}

/// CityPairsExport is the full export for offline use
class CityPairsExport extends $pb.GeneratedMessage {
  factory CityPairsExport({
    $fixnum.Int64? calculatedAt,
    $core.int? totalPairs,
    $core.Iterable<$core.MapEntry<$core.String, CityPairsForStartCity>>? pairs,
  }) {
    final result = create();
    if (calculatedAt != null) result.calculatedAt = calculatedAt;
    if (totalPairs != null) result.totalPairs = totalPairs;
    if (pairs != null) result.pairs.addEntries(pairs);
    return result;
  }

  CityPairsExport._();

  factory CityPairsExport.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory CityPairsExport.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CityPairsExport', package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'calculatedAt')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalPairs', $pb.PbFieldType.O3)
    ..m<$core.String, CityPairsForStartCity>(3, _omitFieldNames ? '' : 'pairs', entryClassName: 'CityPairsExport.PairsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OM, valueCreator: CityPairsForStartCity.create, valueDefaultOrMaker: CityPairsForStartCity.getDefault, packageName: const $pb.PackageName('pb'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityPairsExport clone() => CityPairsExport()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CityPairsExport copyWith(void Function(CityPairsExport) updates) => super.copyWith((message) => updates(message as CityPairsExport)) as CityPairsExport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CityPairsExport create() => CityPairsExport._();
  @$core.override
  CityPairsExport createEmptyInstance() => create();
  static $pb.PbList<CityPairsExport> createRepeated() => $pb.PbList<CityPairsExport>();
  @$core.pragma('dart2js:noInline')
  static CityPairsExport getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CityPairsExport>(create);
  static CityPairsExport? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get calculatedAt => $_getI64(0);
  @$pb.TagNumber(1)
  set calculatedAt($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCalculatedAt() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalculatedAt() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get totalPairs => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalPairs($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalPairs() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalPairs() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbMap<$core.String, CityPairsForStartCity> get pairs => $_getMap(2);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
