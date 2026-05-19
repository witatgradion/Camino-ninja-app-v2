//
//  Generated code. Do not modify.
//  source: city.proto
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

@$core.Deprecated('Use cityRoutesDescriptor instead')
const CityRoutes$json = {
  '1': 'CityRoutes',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'order_key', '3': 2, '4': 1, '5': 5, '10': 'orderKey'},
    {'1': 'route_name', '3': 3, '4': 1, '5': 9, '10': 'routeName'},
    {'1': 'route_sub_name', '3': 4, '4': 1, '5': 9, '10': 'routeSubName'},
    {'1': 'legend_color', '3': 5, '4': 1, '5': 9, '10': 'legendColor'},
    {'1': 'status', '3': 6, '4': 1, '5': 8, '10': 'status'},
    {'1': 'created_at', '3': 28, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 29, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `CityRoutes`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityRoutesDescriptor = $convert.base64Decode(
    'CgpDaXR5Um91dGVzEg4KAmlkGAEgASgFUgJpZBIbCglvcmRlcl9rZXkYAiABKAVSCG9yZGVyS2'
    'V5Eh0KCnJvdXRlX25hbWUYAyABKAlSCXJvdXRlTmFtZRIkCg5yb3V0ZV9zdWJfbmFtZRgEIAEo'
    'CVIMcm91dGVTdWJOYW1lEiEKDGxlZ2VuZF9jb2xvchgFIAEoCVILbGVnZW5kQ29sb3ISFgoGc3'
    'RhdHVzGAYgASgIUgZzdGF0dXMSHQoKY3JlYXRlZF9hdBgcIAEoCVIJY3JlYXRlZEF0Eh0KCnVw'
    'ZGF0ZWRfYXQYHSABKAlSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use cityRoutePointsDescriptor instead')
const CityRoutePoints$json = {
  '1': 'CityRoutePoints',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'route_id', '3': 2, '4': 1, '5': 5, '10': 'routeId'},
    {'1': 'order_key', '3': 3, '4': 1, '5': 5, '10': 'orderKey'},
    {'1': 'elevation', '3': 4, '4': 1, '5': 1, '10': 'elevation'},
    {'1': 'geo_point', '3': 7, '4': 1, '5': 11, '6': '.common.GeoPoint', '10': 'geoPoint'},
  ],
};

/// Descriptor for `CityRoutePoints`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityRoutePointsDescriptor = $convert.base64Decode(
    'Cg9DaXR5Um91dGVQb2ludHMSDgoCaWQYASABKAVSAmlkEhkKCHJvdXRlX2lkGAIgASgFUgdyb3'
    'V0ZUlkEhsKCW9yZGVyX2tleRgDIAEoBVIIb3JkZXJLZXkSHAoJZWxldmF0aW9uGAQgASgBUgll'
    'bGV2YXRpb24SLQoJZ2VvX3BvaW50GAcgASgLMhAuY29tbW9uLkdlb1BvaW50UghnZW9Qb2ludA'
    '==');

@$core.Deprecated('Use cityDescriptor instead')
const City$json = {
  '1': 'City',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'country', '3': 3, '4': 1, '5': 9, '10': 'country'},
    {'1': 'region', '3': 4, '4': 1, '5': 9, '10': 'region'},
    {'1': 'province', '3': 5, '4': 1, '5': 9, '10': 'province'},
    {'1': 'slug', '3': 6, '4': 1, '5': 9, '10': 'slug'},
    {'1': 'km', '3': 7, '4': 1, '5': 5, '10': 'km'},
    {'1': 'has_atm', '3': 8, '4': 1, '5': 8, '10': 'hasAtm'},
    {'1': 'has_bar_cafe', '3': 9, '4': 1, '5': 8, '10': 'hasBarCafe'},
    {'1': 'has_restaurant', '3': 10, '4': 1, '5': 8, '10': 'hasRestaurant'},
    {'1': 'has_shop', '3': 11, '4': 1, '5': 8, '10': 'hasShop'},
    {'1': 'has_med_clinic', '3': 12, '4': 1, '5': 8, '10': 'hasMedClinic'},
    {'1': 'has_pharmacy', '3': 13, '4': 1, '5': 8, '10': 'hasPharmacy'},
    {'1': 'has_fountain', '3': 14, '4': 1, '5': 8, '10': 'hasFountain'},
    {'1': 'has_post_office', '3': 15, '4': 1, '5': 8, '10': 'hasPostOffice'},
    {'1': 'has_bus_station', '3': 16, '4': 1, '5': 8, '10': 'hasBusStation'},
    {'1': 'has_train_station', '3': 17, '4': 1, '5': 8, '10': 'hasTrainStation'},
    {'1': 'etape_city', '3': 18, '4': 1, '5': 8, '10': 'etapeCity'},
    {'1': 'has_tobacco_store', '3': 19, '4': 1, '5': 8, '10': 'hasTobaccoStore'},
    {'1': 'has_airport', '3': 20, '4': 1, '5': 8, '10': 'hasAirport'},
    {'1': 'share_url', '3': 21, '4': 1, '5': 9, '10': 'shareUrl'},
    {'1': 'search', '3': 22, '4': 1, '5': 9, '10': 'search'},
    {'1': 'geo_point', '3': 23, '4': 1, '5': 11, '6': '.common.GeoPoint', '10': 'geoPoint'},
    {'1': 'routes', '3': 24, '4': 3, '5': 11, '6': '.pb.CityRoutes', '10': 'routes'},
    {'1': 'route_points', '3': 25, '4': 3, '5': 11, '6': '.pb.CityRoutePoints', '10': 'routePoints'},
    {'1': 'created_at', '3': 28, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 29, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 30, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `City`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityDescriptor = $convert.base64Decode(
    'CgRDaXR5Eg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhgKB2NvdW50cnkYAy'
    'ABKAlSB2NvdW50cnkSFgoGcmVnaW9uGAQgASgJUgZyZWdpb24SGgoIcHJvdmluY2UYBSABKAlS'
    'CHByb3ZpbmNlEhIKBHNsdWcYBiABKAlSBHNsdWcSDgoCa20YByABKAVSAmttEhcKB2hhc19hdG'
    '0YCCABKAhSBmhhc0F0bRIgCgxoYXNfYmFyX2NhZmUYCSABKAhSCmhhc0JhckNhZmUSJQoOaGFz'
    'X3Jlc3RhdXJhbnQYCiABKAhSDWhhc1Jlc3RhdXJhbnQSGQoIaGFzX3Nob3AYCyABKAhSB2hhc1'
    'Nob3ASJAoOaGFzX21lZF9jbGluaWMYDCABKAhSDGhhc01lZENsaW5pYxIhCgxoYXNfcGhhcm1h'
    'Y3kYDSABKAhSC2hhc1BoYXJtYWN5EiEKDGhhc19mb3VudGFpbhgOIAEoCFILaGFzRm91bnRhaW'
    '4SJgoPaGFzX3Bvc3Rfb2ZmaWNlGA8gASgIUg1oYXNQb3N0T2ZmaWNlEiYKD2hhc19idXNfc3Rh'
    'dGlvbhgQIAEoCFINaGFzQnVzU3RhdGlvbhIqChFoYXNfdHJhaW5fc3RhdGlvbhgRIAEoCFIPaG'
    'FzVHJhaW5TdGF0aW9uEh0KCmV0YXBlX2NpdHkYEiABKAhSCWV0YXBlQ2l0eRIqChFoYXNfdG9i'
    'YWNjb19zdG9yZRgTIAEoCFIPaGFzVG9iYWNjb1N0b3JlEh8KC2hhc19haXJwb3J0GBQgASgIUg'
    'poYXNBaXJwb3J0EhsKCXNoYXJlX3VybBgVIAEoCVIIc2hhcmVVcmwSFgoGc2VhcmNoGBYgASgJ'
    'UgZzZWFyY2gSLQoJZ2VvX3BvaW50GBcgASgLMhAuY29tbW9uLkdlb1BvaW50UghnZW9Qb2ludB'
    'ImCgZyb3V0ZXMYGCADKAsyDi5wYi5DaXR5Um91dGVzUgZyb3V0ZXMSNgoMcm91dGVfcG9pbnRz'
    'GBkgAygLMhMucGIuQ2l0eVJvdXRlUG9pbnRzUgtyb3V0ZVBvaW50cxIdCgpjcmVhdGVkX2F0GB'
    'wgASgJUgljcmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgdIAEoCVIJdXBkYXRlZEF0Eh0KCmRlbGV0'
    'ZWRfYXQYHiABKAlSCWRlbGV0ZWRBdA==');

@$core.Deprecated('Use cityListResponseDescriptor instead')
const CityListResponse$json = {
  '1': 'CityListResponse',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.pb.City', '10': 'items'},
  ],
};

/// Descriptor for `CityListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cityListResponseDescriptor = $convert.base64Decode(
    'ChBDaXR5TGlzdFJlc3BvbnNlEh4KBWl0ZW1zGAEgAygLMggucGIuQ2l0eVIFaXRlbXM=');

