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

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use routeDescriptor instead')
const Route$json = {
  '1': 'Route',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'order_key', '3': 2, '4': 1, '5': 5, '10': 'orderKey'},
    {'1': 'route_name', '3': 3, '4': 1, '5': 9, '10': 'routeName'},
    {'1': 'route_sub_name', '3': 4, '4': 1, '5': 9, '10': 'routeSubName'},
    {'1': 'legend_color', '3': 5, '4': 1, '5': 9, '10': 'legendColor'},
    {'1': 'status', '3': 6, '4': 1, '5': 8, '10': 'status'},
    {'1': 'light_legend_color', '3': 7, '4': 1, '5': 9, '10': 'lightLegendColor'},
    {'1': 'dark_legend_color', '3': 8, '4': 1, '5': 9, '10': 'darkLegendColor'},
    {'1': 'short_name', '3': 9, '4': 1, '5': 9, '10': 'shortName'},
    {'1': 'created_at', '3': 28, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 29, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 30, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `Route`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routeDescriptor = $convert.base64Decode(
    'CgVSb3V0ZRIOCgJpZBgBIAEoBVICaWQSGwoJb3JkZXJfa2V5GAIgASgFUghvcmRlcktleRIdCg'
    'pyb3V0ZV9uYW1lGAMgASgJUglyb3V0ZU5hbWUSJAoOcm91dGVfc3ViX25hbWUYBCABKAlSDHJv'
    'dXRlU3ViTmFtZRIhCgxsZWdlbmRfY29sb3IYBSABKAlSC2xlZ2VuZENvbG9yEhYKBnN0YXR1cx'
    'gGIAEoCFIGc3RhdHVzEiwKEmxpZ2h0X2xlZ2VuZF9jb2xvchgHIAEoCVIQbGlnaHRMZWdlbmRD'
    'b2xvchIqChFkYXJrX2xlZ2VuZF9jb2xvchgIIAEoCVIPZGFya0xlZ2VuZENvbG9yEh0KCnNob3'
    'J0X25hbWUYCSABKAlSCXNob3J0TmFtZRIdCgpjcmVhdGVkX2F0GBwgASgJUgljcmVhdGVkQXQS'
    'HQoKdXBkYXRlZF9hdBgdIAEoCVIJdXBkYXRlZEF0Eh0KCmRlbGV0ZWRfYXQYHiABKAlSCWRlbG'
    'V0ZWRBdA==');

@$core.Deprecated('Use routeListResponseDescriptor instead')
const RouteListResponse$json = {
  '1': 'RouteListResponse',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.pb.Route', '10': 'items'},
  ],
};

/// Descriptor for `RouteListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List routeListResponseDescriptor = $convert.base64Decode(
    'ChFSb3V0ZUxpc3RSZXNwb25zZRIfCgVpdGVtcxgBIAMoCzIJLnBiLlJvdXRlUgVpdGVtcw==');

