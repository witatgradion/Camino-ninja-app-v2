//
//  Generated code. Do not modify.
//  source: alt_route_points.proto
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

@$core.Deprecated('Use altRoutePointsDescriptor instead')
const AltRoutePoints$json = {
  '1': 'AltRoutePoints',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'order_key', '3': 2, '4': 1, '5': 5, '10': 'orderKey'},
    {'1': 'color', '3': 3, '4': 1, '5': 9, '10': 'color'},
    {'1': 'dotted', '3': 4, '4': 1, '5': 8, '10': 'dotted'},
    {'1': 'route_id', '3': 7, '4': 1, '5': 5, '10': 'routeId'},
    {'1': 'alt_route_points_values', '3': 8, '4': 3, '5': 11, '6': '.pb.AltRoutePointsValues', '10': 'altRoutePointsValues'},
    {'1': 'created_at', '3': 28, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 29, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 30, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `AltRoutePoints`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List altRoutePointsDescriptor = $convert.base64Decode(
    'Cg5BbHRSb3V0ZVBvaW50cxIOCgJpZBgBIAEoBVICaWQSGwoJb3JkZXJfa2V5GAIgASgFUghvcm'
    'RlcktleRIUCgVjb2xvchgDIAEoCVIFY29sb3ISFgoGZG90dGVkGAQgASgIUgZkb3R0ZWQSGQoI'
    'cm91dGVfaWQYByABKAVSB3JvdXRlSWQSTwoXYWx0X3JvdXRlX3BvaW50c192YWx1ZXMYCCADKA'
    'syGC5wYi5BbHRSb3V0ZVBvaW50c1ZhbHVlc1IUYWx0Um91dGVQb2ludHNWYWx1ZXMSHQoKY3Jl'
    'YXRlZF9hdBgcIAEoCVIJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYHSABKAlSCXVwZGF0ZWRBdB'
    'IdCgpkZWxldGVkX2F0GB4gASgJUglkZWxldGVkQXQ=');

@$core.Deprecated('Use altRoutePointsValuesDescriptor instead')
const AltRoutePointsValues$json = {
  '1': 'AltRoutePointsValues',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'alt_route_points_id', '3': 2, '4': 1, '5': 5, '10': 'altRoutePointsId'},
    {'1': 'order_key', '3': 3, '4': 1, '5': 5, '10': 'orderKey'},
    {'1': 'geo_point', '3': 5, '4': 1, '5': 11, '6': '.common.GeoPoint', '10': 'geoPoint'},
    {'1': 'created_at', '3': 28, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 29, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 30, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `AltRoutePointsValues`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List altRoutePointsValuesDescriptor = $convert.base64Decode(
    'ChRBbHRSb3V0ZVBvaW50c1ZhbHVlcxIOCgJpZBgBIAEoBVICaWQSLQoTYWx0X3JvdXRlX3BvaW'
    '50c19pZBgCIAEoBVIQYWx0Um91dGVQb2ludHNJZBIbCglvcmRlcl9rZXkYAyABKAVSCG9yZGVy'
    'S2V5Ei0KCWdlb19wb2ludBgFIAEoCzIQLmNvbW1vbi5HZW9Qb2ludFIIZ2VvUG9pbnQSHQoKY3'
    'JlYXRlZF9hdBgcIAEoCVIJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYHSABKAlSCXVwZGF0ZWRB'
    'dBIdCgpkZWxldGVkX2F0GB4gASgJUglkZWxldGVkQXQ=');

@$core.Deprecated('Use altRoutePointsListResponseDescriptor instead')
const AltRoutePointsListResponse$json = {
  '1': 'AltRoutePointsListResponse',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.pb.AltRoutePoints', '10': 'items'},
  ],
};

/// Descriptor for `AltRoutePointsListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List altRoutePointsListResponseDescriptor = $convert.base64Decode(
    'ChpBbHRSb3V0ZVBvaW50c0xpc3RSZXNwb25zZRIoCgVpdGVtcxgBIAMoCzISLnBiLkFsdFJvdX'
    'RlUG9pbnRzUgVpdGVtcw==');

