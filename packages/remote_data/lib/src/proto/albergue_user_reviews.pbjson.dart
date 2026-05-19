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

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use albergueUserReviewsImagesDescriptor instead')
const AlbergueUserReviewsImages$json = {
  '1': 'AlbergueUserReviewsImages',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_user_reviews_id', '3': 2, '4': 1, '5': 5, '10': 'albergueUserReviewsId'},
    {'1': 'file_key', '3': 3, '4': 1, '5': 9, '10': 'fileKey'},
    {'1': 'status', '3': 4, '4': 1, '5': 8, '10': 'status'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 6, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
};

/// Descriptor for `AlbergueUserReviewsImages`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueUserReviewsImagesDescriptor = $convert.base64Decode(
    'ChlBbGJlcmd1ZVVzZXJSZXZpZXdzSW1hZ2VzEg4KAmlkGAEgASgFUgJpZBI3ChhhbGJlcmd1ZV'
    '91c2VyX3Jldmlld3NfaWQYAiABKAVSFWFsYmVyZ3VlVXNlclJldmlld3NJZBIZCghmaWxlX2tl'
    'eRgDIAEoCVIHZmlsZUtleRIWCgZzdGF0dXMYBCABKAhSBnN0YXR1cxIdCgpjcmVhdGVkX2F0GA'
    'UgASgJUgljcmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgGIAEoCVIJdXBkYXRlZEF0');

@$core.Deprecated('Use albergueUserReviewsDescriptor instead')
const AlbergueUserReviews$json = {
  '1': 'AlbergueUserReviews',
  '2': [
    {'1': 'albergue_id', '3': 1, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'status', '3': 2, '4': 1, '5': 8, '10': 'status'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '10': 'email'},
    {'1': 'user_comment', '3': 5, '4': 1, '5': 9, '10': 'userComment'},
    {'1': 'user_rating', '3': 6, '4': 1, '5': 1, '10': 'userRating'},
    {'1': 'images', '3': 7, '4': 3, '5': 11, '6': '.pb.AlbergueUserReviewsImages', '10': 'images'},
    {'1': 'id', '3': 12, '4': 1, '5': 5, '10': 'id'},
    {'1': 'source_lang', '3': 8, '4': 1, '5': 9, '9': 0, '10': 'sourceLang', '17': true},
    {'1': 'translated_comment', '3': 9, '4': 1, '5': 9, '9': 1, '10': 'translatedComment', '17': true},
    {'1': 'display_lang', '3': 10, '4': 1, '5': 9, '9': 2, '10': 'displayLang', '17': true},
    {'1': 'is_translated', '3': 11, '4': 1, '5': 8, '10': 'isTranslated'},
    {'1': 'created_at', '3': 28, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 29, '4': 1, '5': 9, '10': 'updatedAt'},
  ],
  '8': [
    {'1': '_source_lang'},
    {'1': '_translated_comment'},
    {'1': '_display_lang'},
  ],
};

/// Descriptor for `AlbergueUserReviews`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueUserReviewsDescriptor = $convert.base64Decode(
    'ChNBbGJlcmd1ZVVzZXJSZXZpZXdzEh8KC2FsYmVyZ3VlX2lkGAEgASgFUgphbGJlcmd1ZUlkEh'
    'YKBnN0YXR1cxgCIAEoCFIGc3RhdHVzEhIKBG5hbWUYAyABKAlSBG5hbWUSFAoFZW1haWwYBCAB'
    'KAlSBWVtYWlsEiEKDHVzZXJfY29tbWVudBgFIAEoCVILdXNlckNvbW1lbnQSHwoLdXNlcl9yYX'
    'RpbmcYBiABKAFSCnVzZXJSYXRpbmcSNQoGaW1hZ2VzGAcgAygLMh0ucGIuQWxiZXJndWVVc2Vy'
    'UmV2aWV3c0ltYWdlc1IGaW1hZ2VzEg4KAmlkGAwgASgFUgJpZBIkCgtzb3VyY2VfbGFuZxgIIA'
    'EoCUgAUgpzb3VyY2VMYW5niAEBEjIKEnRyYW5zbGF0ZWRfY29tbWVudBgJIAEoCUgBUhF0cmFu'
    'c2xhdGVkQ29tbWVudIgBARImCgxkaXNwbGF5X2xhbmcYCiABKAlIAlILZGlzcGxheUxhbmeIAQ'
    'ESIwoNaXNfdHJhbnNsYXRlZBgLIAEoCFIMaXNUcmFuc2xhdGVkEh0KCmNyZWF0ZWRfYXQYHCAB'
    'KAlSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GB0gASgJUgl1cGRhdGVkQXRCDgoMX3NvdXJjZV'
    '9sYW5nQhUKE190cmFuc2xhdGVkX2NvbW1lbnRCDwoNX2Rpc3BsYXlfbGFuZw==');

@$core.Deprecated('Use albergueUserReviewsByAlbergueIdDescriptor instead')
const AlbergueUserReviewsByAlbergueId$json = {
  '1': 'AlbergueUserReviewsByAlbergueId',
  '2': [
    {'1': 'total', '3': 1, '4': 1, '5': 3, '10': 'total'},
    {'1': 'albergue_user_reviews', '3': 2, '4': 3, '5': 11, '6': '.pb.AlbergueUserReviews', '10': 'albergueUserReviews'},
  ],
};

/// Descriptor for `AlbergueUserReviewsByAlbergueId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueUserReviewsByAlbergueIdDescriptor = $convert.base64Decode(
    'Ch9BbGJlcmd1ZVVzZXJSZXZpZXdzQnlBbGJlcmd1ZUlkEhQKBXRvdGFsGAEgASgDUgV0b3RhbB'
    'JLChVhbGJlcmd1ZV91c2VyX3Jldmlld3MYAiADKAsyFy5wYi5BbGJlcmd1ZVVzZXJSZXZpZXdz'
    'UhNhbGJlcmd1ZVVzZXJSZXZpZXdz');

@$core.Deprecated('Use albergueUserReviewsListResponseDescriptor instead')
const AlbergueUserReviewsListResponse$json = {
  '1': 'AlbergueUserReviewsListResponse',
  '2': [
    {'1': 'albergue_user_reviews', '3': 1, '4': 3, '5': 11, '6': '.pb.AlbergueUserReviews', '10': 'albergueUserReviews'},
  ],
};

/// Descriptor for `AlbergueUserReviewsListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueUserReviewsListResponseDescriptor = $convert.base64Decode(
    'Ch9BbGJlcmd1ZVVzZXJSZXZpZXdzTGlzdFJlc3BvbnNlEksKFWFsYmVyZ3VlX3VzZXJfcmV2aW'
    'V3cxgBIAMoCzIXLnBiLkFsYmVyZ3VlVXNlclJldmlld3NSE2FsYmVyZ3VlVXNlclJldmlld3M=');

