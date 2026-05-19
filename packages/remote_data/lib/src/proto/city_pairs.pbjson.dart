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

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use cityPairDetailDescriptor instead')
const CityPairDetail$json = {
  '1': 'CityPairDetail',
  '2': [
    {'1': 'end_city_id', '3': 1, '4': 1, '5': 5, '10': 'endCityId'},
    {'1': 'end_city_name', '3': 2, '4': 1, '5': 9, '10': 'endCityName'},
    {'1': 'percentage', '3': 3, '4': 1, '5': 2, '10': 'percentage'},
    {'1': 'pair_count', '3': 4, '4': 1, '5': 5, '10': 'pairCount'},
    {'1': 'distance_km', '3': 5, '4': 1, '5': 2, '10': 'distanceKm'},
  ],
};

/// Descriptor for `CityPairDetail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityPairDetailDescriptor = $convert.base64Decode(
    'Cg5DaXR5UGFpckRldGFpbBIeCgtlbmRfY2l0eV9pZBgBIAEoBVIJZW5kQ2l0eUlkEiIKDWVuZF'
    '9jaXR5X25hbWUYAiABKAlSC2VuZENpdHlOYW1lEh4KCnBlcmNlbnRhZ2UYAyABKAJSCnBlcmNl'
    'bnRhZ2USHQoKcGFpcl9jb3VudBgEIAEoBVIJcGFpckNvdW50Eh8KC2Rpc3RhbmNlX2ttGAUgAS'
    'gCUgpkaXN0YW5jZUtt');

@$core.Deprecated('Use cityPairsForStartCityDescriptor instead')
const CityPairsForStartCity$json = {
  '1': 'CityPairsForStartCity',
  '2': [
    {'1': 'start_city_id', '3': 1, '4': 1, '5': 5, '10': 'startCityId'},
    {'1': 'start_city_name', '3': 2, '4': 1, '5': 9, '10': 'startCityName'},
    {'1': 'total_plans', '3': 3, '4': 1, '5': 5, '10': 'totalPlans'},
    {'1': 'pairs', '3': 4, '4': 3, '5': 11, '6': '.pb.CityPairDetail', '10': 'pairs'},
  ],
};

/// Descriptor for `CityPairsForStartCity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityPairsForStartCityDescriptor = $convert.base64Decode(
    'ChVDaXR5UGFpcnNGb3JTdGFydENpdHkSIgoNc3RhcnRfY2l0eV9pZBgBIAEoBVILc3RhcnRDaX'
    'R5SWQSJgoPc3RhcnRfY2l0eV9uYW1lGAIgASgJUg1zdGFydENpdHlOYW1lEh8KC3RvdGFsX3Bs'
    'YW5zGAMgASgFUgp0b3RhbFBsYW5zEigKBXBhaXJzGAQgAygLMhIucGIuQ2l0eVBhaXJEZXRhaW'
    'xSBXBhaXJz');

@$core.Deprecated('Use cityPairsExportDescriptor instead')
const CityPairsExport$json = {
  '1': 'CityPairsExport',
  '2': [
    {'1': 'calculated_at', '3': 1, '4': 1, '5': 3, '10': 'calculatedAt'},
    {'1': 'total_pairs', '3': 2, '4': 1, '5': 5, '10': 'totalPairs'},
    {'1': 'pairs', '3': 3, '4': 3, '5': 11, '6': '.pb.CityPairsExport.PairsEntry', '10': 'pairs'},
  ],
  '3': [CityPairsExport_PairsEntry$json],
};

@$core.Deprecated('Use cityPairsExportDescriptor instead')
const CityPairsExport_PairsEntry$json = {
  '1': 'PairsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 11, '6': '.pb.CityPairsForStartCity', '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CityPairsExport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityPairsExportDescriptor = $convert.base64Decode(
    'Cg9DaXR5UGFpcnNFeHBvcnQSIwoNY2FsY3VsYXRlZF9hdBgBIAEoA1IMY2FsY3VsYXRlZEF0Eh'
    '8KC3RvdGFsX3BhaXJzGAIgASgFUgp0b3RhbFBhaXJzEjQKBXBhaXJzGAMgAygLMh4ucGIuQ2l0'
    'eVBhaXJzRXhwb3J0LlBhaXJzRW50cnlSBXBhaXJzGlMKClBhaXJzRW50cnkSEAoDa2V5GAEgAS'
    'gJUgNrZXkSLwoFdmFsdWUYAiABKAsyGS5wYi5DaXR5UGFpcnNGb3JTdGFydENpdHlSBXZhbHVl'
    'OgI4AQ==');

