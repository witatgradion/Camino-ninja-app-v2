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

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use albergueUserRatingsDescriptor instead')
const AlbergueUserRatings$json = {
  '1': 'AlbergueUserRatings',
  '2': [
    {'1': 'albergue_id', '3': 1, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'rating', '3': 2, '4': 1, '5': 2, '10': 'rating'},
    {'1': 'total_approved_reviews', '3': 3, '4': 1, '5': 5, '10': 'totalApprovedReviews'},
  ],
};

/// Descriptor for `AlbergueUserRatings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueUserRatingsDescriptor = $convert.base64Decode(
    'ChNBbGJlcmd1ZVVzZXJSYXRpbmdzEh8KC2FsYmVyZ3VlX2lkGAEgASgFUgphbGJlcmd1ZUlkEh'
    'YKBnJhdGluZxgCIAEoAlIGcmF0aW5nEjQKFnRvdGFsX2FwcHJvdmVkX3Jldmlld3MYAyABKAVS'
    'FHRvdGFsQXBwcm92ZWRSZXZpZXdz');

@$core.Deprecated('Use albergueUserRatingsListResponseDescriptor instead')
const AlbergueUserRatingsListResponse$json = {
  '1': 'AlbergueUserRatingsListResponse',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.pb.AlbergueUserRatings', '10': 'items'},
  ],
};

/// Descriptor for `AlbergueUserRatingsListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueUserRatingsListResponseDescriptor = $convert.base64Decode(
    'Ch9BbGJlcmd1ZVVzZXJSYXRpbmdzTGlzdFJlc3BvbnNlEi0KBWl0ZW1zGAEgAygLMhcucGIuQW'
    'xiZXJndWVVc2VyUmF0aW5nc1IFaXRlbXM=');

