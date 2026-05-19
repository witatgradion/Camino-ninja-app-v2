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

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use routePointsDescriptor instead')
const RoutePoints$json = {
  '1': 'RoutePoints',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'route_id', '3': 2, '4': 1, '5': 5, '10': 'routeId'},
    {'1': 'order_key', '3': 3, '4': 1, '5': 5, '10': 'orderKey'},
    {'1': 'elevation', '3': 4, '4': 1, '5': 1, '10': 'elevation'},
    {'1': 'geo_point', '3': 5, '4': 1, '5': 11, '6': '.common.GeoPoint', '10': 'geoPoint'},
  ],
};

/// Descriptor for `RoutePoints`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routePointsDescriptor = $convert.base64Decode(
    'CgtSb3V0ZVBvaW50cxIOCgJpZBgBIAEoBVICaWQSGQoIcm91dGVfaWQYAiABKAVSB3JvdXRlSW'
    'QSGwoJb3JkZXJfa2V5GAMgASgFUghvcmRlcktleRIcCgllbGV2YXRpb24YBCABKAFSCWVsZXZh'
    'dGlvbhItCglnZW9fcG9pbnQYBSABKAsyEC5jb21tb24uR2VvUG9pbnRSCGdlb1BvaW50');

@$core.Deprecated('Use routePointsListResponseDescriptor instead')
const RoutePointsListResponse$json = {
  '1': 'RoutePointsListResponse',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.pb.RoutePoints', '10': 'items'},
  ],
};

/// Descriptor for `RoutePointsListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routePointsListResponseDescriptor = $convert.base64Decode(
    'ChdSb3V0ZVBvaW50c0xpc3RSZXNwb25zZRIlCgVpdGVtcxgBIAMoCzIPLnBiLlJvdXRlUG9pbn'
    'RzUgVpdGVtcw==');

