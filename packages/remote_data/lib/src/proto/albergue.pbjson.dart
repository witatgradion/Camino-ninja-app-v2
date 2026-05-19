//
//  Generated code. Do not modify.
//  source: albergue.proto
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

@$core.Deprecated('Use albergueDescriptor instead')
const Albergue$json = {
  '1': 'Albergue',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'slug', '3': 3, '4': 1, '5': 9, '10': 'slug'},
    {'1': 'order_key', '3': 4, '4': 1, '5': 5, '10': 'orderKey'},
    {'1': 'status', '3': 5, '4': 1, '5': 5, '10': 'status'},
    {'1': 'is_active', '3': 6, '4': 1, '5': 8, '10': 'isActive'},
    {'1': 'geo_point', '3': 7, '4': 1, '5': 11, '6': '.common.GeoPoint', '10': 'geoPoint'},
    {'1': 'is_municipal', '3': 8, '4': 1, '5': 8, '10': 'isMunicipal'},
    {'1': 'is_albergue', '3': 9, '4': 1, '5': 8, '10': 'isAlbergue'},
    {'1': 'city_name', '3': 10, '4': 1, '5': 9, '10': 'cityName'},
    {'1': 'address', '3': 11, '4': 1, '5': 9, '10': 'address'},
    {'1': 'postal_code', '3': 12, '4': 1, '5': 9, '10': 'postalCode'},
    {'1': 'province', '3': 13, '4': 1, '5': 9, '10': 'province'},
    {'1': 'region', '3': 14, '4': 1, '5': 9, '10': 'region'},
    {'1': 'country', '3': 15, '4': 1, '5': 9, '10': 'country'},
    {'1': 'share_url', '3': 16, '4': 1, '5': 9, '10': 'shareUrl'},
    {'1': 'web', '3': 17, '4': 1, '5': 9, '10': 'web'},
    {'1': 'reservation_translation_id', '3': 18, '4': 1, '5': 5, '10': 'reservationTranslationId'},
    {'1': 'open_season_translation_id', '3': 19, '4': 1, '5': 5, '10': 'openSeasonTranslationId'},
    {'1': 'places_in_dormitory', '3': 20, '4': 1, '5': 5, '10': 'placesInDormitory'},
    {'1': 'number_of_dormitories', '3': 21, '4': 1, '5': 5, '10': 'numberOfDormitories'},
    {'1': 'city_id', '3': 22, '4': 1, '5': 5, '10': 'cityId'},
    {'1': 'booking_com_url', '3': 24, '4': 1, '5': 9, '10': 'bookingComUrl'},
    {'1': 'dist_costa', '3': 25, '4': 1, '5': 5, '10': 'distCosta'},
    {'1': 'dist_litoral', '3': 26, '4': 1, '5': 5, '10': 'distLitoral'},
    {'1': 'reserver_url', '3': 27, '4': 1, '5': 9, '10': 'reserverUrl'},
    {'1': 'created_at', '3': 28, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 29, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 30, '4': 1, '5': 9, '10': 'deletedAt'},
    {'1': 'emails', '3': 31, '4': 3, '5': 11, '6': '.pb.AlbergueEmail', '10': 'emails'},
    {'1': 'phones', '3': 32, '4': 3, '5': 11, '6': '.pb.AlberguePhone', '10': 'phones'},
    {'1': 'albergue_images', '3': 33, '4': 3, '5': 11, '6': '.pb.AlbergueImage', '10': 'albergueImages'},
    {'1': 'booking_price', '3': 40, '4': 1, '5': 1, '10': 'bookingPrice'},
    {'1': 'booking_price_updated_at', '3': 41, '4': 1, '5': 9, '10': 'bookingPriceUpdatedAt'},
    {'1': 'facilities', '3': 34, '4': 1, '5': 11, '6': '.pb.AlbergueFacilities', '10': 'facilities'},
    {'1': 'operating_hours', '3': 35, '4': 1, '5': 11, '6': '.pb.AlbergueOperatingHours', '10': 'operatingHours'},
    {'1': 'prices', '3': 36, '4': 1, '5': 11, '6': '.pb.AlberguePrices', '10': 'prices'},
    {'1': 'reviews', '3': 37, '4': 1, '5': 11, '6': '.pb.AlbergueReviews', '10': 'reviews'},
    {'1': 'social_media', '3': 38, '4': 1, '5': 11, '6': '.pb.AlbergueSocialMedia', '10': 'socialMedia'},
    {'1': 'wifis', '3': 39, '4': 3, '5': 11, '6': '.pb.AlbergueWifi', '10': 'wifis'},
  ],
};

/// Descriptor for `Albergue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueDescriptor = $convert.base64Decode(
    'CghBbGJlcmd1ZRIOCgJpZBgBIAEoBVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRISCgRzbHVnGA'
    'MgASgJUgRzbHVnEhsKCW9yZGVyX2tleRgEIAEoBVIIb3JkZXJLZXkSFgoGc3RhdHVzGAUgASgF'
    'UgZzdGF0dXMSGwoJaXNfYWN0aXZlGAYgASgIUghpc0FjdGl2ZRItCglnZW9fcG9pbnQYByABKA'
    'syEC5jb21tb24uR2VvUG9pbnRSCGdlb1BvaW50EiEKDGlzX211bmljaXBhbBgIIAEoCFILaXNN'
    'dW5pY2lwYWwSHwoLaXNfYWxiZXJndWUYCSABKAhSCmlzQWxiZXJndWUSGwoJY2l0eV9uYW1lGA'
    'ogASgJUghjaXR5TmFtZRIYCgdhZGRyZXNzGAsgASgJUgdhZGRyZXNzEh8KC3Bvc3RhbF9jb2Rl'
    'GAwgASgJUgpwb3N0YWxDb2RlEhoKCHByb3ZpbmNlGA0gASgJUghwcm92aW5jZRIWCgZyZWdpb2'
    '4YDiABKAlSBnJlZ2lvbhIYCgdjb3VudHJ5GA8gASgJUgdjb3VudHJ5EhsKCXNoYXJlX3VybBgQ'
    'IAEoCVIIc2hhcmVVcmwSEAoDd2ViGBEgASgJUgN3ZWISPAoacmVzZXJ2YXRpb25fdHJhbnNsYX'
    'Rpb25faWQYEiABKAVSGHJlc2VydmF0aW9uVHJhbnNsYXRpb25JZBI7ChpvcGVuX3NlYXNvbl90'
    'cmFuc2xhdGlvbl9pZBgTIAEoBVIXb3BlblNlYXNvblRyYW5zbGF0aW9uSWQSLgoTcGxhY2VzX2'
    'luX2Rvcm1pdG9yeRgUIAEoBVIRcGxhY2VzSW5Eb3JtaXRvcnkSMgoVbnVtYmVyX29mX2Rvcm1p'
    'dG9yaWVzGBUgASgFUhNudW1iZXJPZkRvcm1pdG9yaWVzEhcKB2NpdHlfaWQYFiABKAVSBmNpdH'
    'lJZBImCg9ib29raW5nX2NvbV91cmwYGCABKAlSDWJvb2tpbmdDb21VcmwSHQoKZGlzdF9jb3N0'
    'YRgZIAEoBVIJZGlzdENvc3RhEiEKDGRpc3RfbGl0b3JhbBgaIAEoBVILZGlzdExpdG9yYWwSIQ'
    'oMcmVzZXJ2ZXJfdXJsGBsgASgJUgtyZXNlcnZlclVybBIdCgpjcmVhdGVkX2F0GBwgASgJUglj'
    'cmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgdIAEoCVIJdXBkYXRlZEF0Eh0KCmRlbGV0ZWRfYXQYHi'
    'ABKAlSCWRlbGV0ZWRBdBIpCgZlbWFpbHMYHyADKAsyES5wYi5BbGJlcmd1ZUVtYWlsUgZlbWFp'
    'bHMSKQoGcGhvbmVzGCAgAygLMhEucGIuQWxiZXJndWVQaG9uZVIGcGhvbmVzEjoKD2FsYmVyZ3'
    'VlX2ltYWdlcxghIAMoCzIRLnBiLkFsYmVyZ3VlSW1hZ2VSDmFsYmVyZ3VlSW1hZ2VzEiMKDWJv'
    'b2tpbmdfcHJpY2UYKCABKAFSDGJvb2tpbmdQcmljZRI3Chhib29raW5nX3ByaWNlX3VwZGF0ZW'
    'RfYXQYKSABKAlSFWJvb2tpbmdQcmljZVVwZGF0ZWRBdBI2CgpmYWNpbGl0aWVzGCIgASgLMhYu'
    'cGIuQWxiZXJndWVGYWNpbGl0aWVzUgpmYWNpbGl0aWVzEkMKD29wZXJhdGluZ19ob3VycxgjIA'
    'EoCzIaLnBiLkFsYmVyZ3VlT3BlcmF0aW5nSG91cnNSDm9wZXJhdGluZ0hvdXJzEioKBnByaWNl'
    'cxgkIAEoCzISLnBiLkFsYmVyZ3VlUHJpY2VzUgZwcmljZXMSLQoHcmV2aWV3cxglIAEoCzITLn'
    'BiLkFsYmVyZ3VlUmV2aWV3c1IHcmV2aWV3cxI6Cgxzb2NpYWxfbWVkaWEYJiABKAsyFy5wYi5B'
    'bGJlcmd1ZVNvY2lhbE1lZGlhUgtzb2NpYWxNZWRpYRImCgV3aWZpcxgnIAMoCzIQLnBiLkFsYm'
    'VyZ3VlV2lmaVIFd2lmaXM=');

@$core.Deprecated('Use albergueFacilitiesDescriptor instead')
const AlbergueFacilities$json = {
  '1': 'AlbergueFacilities',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'has_kitchen', '3': 3, '4': 1, '5': 8, '9': 0, '10': 'hasKitchen', '17': true},
    {'1': 'has_cooktops', '3': 4, '4': 1, '5': 8, '9': 1, '10': 'hasCooktops', '17': true},
    {'1': 'has_microwave', '3': 5, '4': 1, '5': 8, '9': 2, '10': 'hasMicrowave', '17': true},
    {'1': 'has_water_boiler', '3': 6, '4': 1, '5': 8, '9': 3, '10': 'hasWaterBoiler', '17': true},
    {'1': 'has_plates_utensils', '3': 7, '4': 1, '5': 8, '9': 4, '10': 'hasPlatesUtensils', '17': true},
    {'1': 'has_cooking_pots', '3': 8, '4': 1, '5': 8, '9': 5, '10': 'hasCookingPots', '17': true},
    {'1': 'has_breakfast', '3': 9, '4': 1, '5': 8, '9': 6, '10': 'hasBreakfast', '17': true},
    {'1': 'is_breakfast_included', '3': 10, '4': 1, '5': 8, '9': 7, '10': 'isBreakfastIncluded', '17': true},
    {'1': 'has_clothes_line', '3': 11, '4': 1, '5': 8, '9': 8, '10': 'hasClothesLine', '17': true},
    {'1': 'has_wifi', '3': 12, '4': 1, '5': 8, '9': 9, '10': 'hasWifi', '17': true},
    {'1': 'has_tv', '3': 13, '4': 1, '5': 8, '9': 10, '10': 'hasTv', '17': true},
    {'1': 'has_restaurant', '3': 14, '4': 1, '5': 8, '9': 11, '10': 'hasRestaurant', '17': true},
    {'1': 'has_community_dinner', '3': 15, '4': 1, '5': 8, '9': 12, '10': 'hasCommunityDinner', '17': true},
    {'1': 'has_dinner', '3': 16, '4': 1, '5': 8, '9': 13, '10': 'hasDinner', '17': true},
    {'1': 'has_washing_machine', '3': 17, '4': 1, '5': 8, '9': 14, '10': 'hasWashingMachine', '17': true},
    {'1': 'has_spin_dryer', '3': 18, '4': 1, '5': 8, '9': 15, '10': 'hasSpinDryer', '17': true},
    {'1': 'has_hand_washing_sink', '3': 19, '4': 1, '5': 8, '9': 16, '10': 'hasHandWashingSink', '17': true},
    {'1': 'has_tumble_dryer', '3': 20, '4': 1, '5': 8, '9': 17, '10': 'hasTumbleDryer', '17': true},
    {'1': 'has_individual_powerplug', '3': 21, '4': 1, '5': 8, '9': 18, '10': 'hasIndividualPowerplug', '17': true},
    {'1': 'has_private_lockers', '3': 22, '4': 1, '5': 8, '9': 19, '10': 'hasPrivateLockers', '17': true},
    {'1': 'has_curtains', '3': 23, '4': 1, '5': 8, '9': 20, '10': 'hasCurtains', '17': true},
    {'1': 'has_oven', '3': 24, '4': 1, '5': 8, '9': 21, '10': 'hasOven', '17': true},
    {'1': 'has_vending_machine', '3': 25, '4': 1, '5': 8, '9': 22, '10': 'hasVendingMachine', '17': true},
    {'1': 'has_full_laundry_service', '3': 26, '4': 1, '5': 8, '9': 23, '10': 'hasFullLaundryService', '17': true},
    {'1': 'has_fridge', '3': 27, '4': 1, '5': 8, '9': 24, '10': 'hasFridge', '17': true},
    {'1': 'has_lunch', '3': 28, '4': 1, '5': 8, '9': 25, '10': 'hasLunch', '17': true},
    {'1': 'has_vegetarian_option', '3': 29, '4': 1, '5': 8, '9': 26, '10': 'hasVegetarianOption', '17': true},
    {'1': 'has_vegan_option', '3': 30, '4': 1, '5': 8, '9': 27, '10': 'hasVeganOption', '17': true},
    {'1': 'has_swimming_pool', '3': 31, '4': 1, '5': 8, '9': 28, '10': 'hasSwimmingPool', '17': true},
    {'1': 'has_donativo_breakfast', '3': 32, '4': 1, '5': 8, '9': 29, '10': 'hasDonativoBreakfast', '17': true},
    {'1': 'has_cube_beds', '3': 33, '4': 1, '5': 8, '9': 30, '10': 'hasCubeBeds', '17': true},
    {'1': 'has_community_lunch', '3': 34, '4': 1, '5': 8, '9': 31, '10': 'hasCommunityLunch', '17': true},
    {'1': 'is_vegetarian', '3': 35, '4': 1, '5': 8, '9': 32, '10': 'isVegetarian', '17': true},
    {'1': 'is_vegan', '3': 36, '4': 1, '5': 8, '9': 33, '10': 'isVegan', '17': true},
    {'1': 'is_organic', '3': 37, '4': 1, '5': 8, '9': 34, '10': 'isOrganic', '17': true},
    {'1': 'pets_allowed', '3': 38, '4': 1, '5': 8, '9': 35, '10': 'petsAllowed', '17': true},
    {'1': 'has_cotton_sheets', '3': 39, '4': 1, '5': 8, '9': 36, '10': 'hasCottonSheets', '17': true},
    {'1': 'is_dinner_included', '3': 40, '4': 1, '5': 8, '9': 37, '10': 'isDinnerIncluded', '17': true},
    {'1': 'created_at', '3': 41, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 42, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 43, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
  '8': [
    {'1': '_has_kitchen'},
    {'1': '_has_cooktops'},
    {'1': '_has_microwave'},
    {'1': '_has_water_boiler'},
    {'1': '_has_plates_utensils'},
    {'1': '_has_cooking_pots'},
    {'1': '_has_breakfast'},
    {'1': '_is_breakfast_included'},
    {'1': '_has_clothes_line'},
    {'1': '_has_wifi'},
    {'1': '_has_tv'},
    {'1': '_has_restaurant'},
    {'1': '_has_community_dinner'},
    {'1': '_has_dinner'},
    {'1': '_has_washing_machine'},
    {'1': '_has_spin_dryer'},
    {'1': '_has_hand_washing_sink'},
    {'1': '_has_tumble_dryer'},
    {'1': '_has_individual_powerplug'},
    {'1': '_has_private_lockers'},
    {'1': '_has_curtains'},
    {'1': '_has_oven'},
    {'1': '_has_vending_machine'},
    {'1': '_has_full_laundry_service'},
    {'1': '_has_fridge'},
    {'1': '_has_lunch'},
    {'1': '_has_vegetarian_option'},
    {'1': '_has_vegan_option'},
    {'1': '_has_swimming_pool'},
    {'1': '_has_donativo_breakfast'},
    {'1': '_has_cube_beds'},
    {'1': '_has_community_lunch'},
    {'1': '_is_vegetarian'},
    {'1': '_is_vegan'},
    {'1': '_is_organic'},
    {'1': '_pets_allowed'},
    {'1': '_has_cotton_sheets'},
    {'1': '_is_dinner_included'},
  ],
};

/// Descriptor for `AlbergueFacilities`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueFacilitiesDescriptor = $convert.base64Decode(
    'ChJBbGJlcmd1ZUZhY2lsaXRpZXMSDgoCaWQYASABKAVSAmlkEh8KC2FsYmVyZ3VlX2lkGAIgAS'
    'gFUgphbGJlcmd1ZUlkEiQKC2hhc19raXRjaGVuGAMgASgISABSCmhhc0tpdGNoZW6IAQESJgoM'
    'aGFzX2Nvb2t0b3BzGAQgASgISAFSC2hhc0Nvb2t0b3BziAEBEigKDWhhc19taWNyb3dhdmUYBS'
    'ABKAhIAlIMaGFzTWljcm93YXZliAEBEi0KEGhhc193YXRlcl9ib2lsZXIYBiABKAhIA1IOaGFz'
    'V2F0ZXJCb2lsZXKIAQESMwoTaGFzX3BsYXRlc191dGVuc2lscxgHIAEoCEgEUhFoYXNQbGF0ZX'
    'NVdGVuc2lsc4gBARItChBoYXNfY29va2luZ19wb3RzGAggASgISAVSDmhhc0Nvb2tpbmdQb3Rz'
    'iAEBEigKDWhhc19icmVha2Zhc3QYCSABKAhIBlIMaGFzQnJlYWtmYXN0iAEBEjcKFWlzX2JyZW'
    'FrZmFzdF9pbmNsdWRlZBgKIAEoCEgHUhNpc0JyZWFrZmFzdEluY2x1ZGVkiAEBEi0KEGhhc19j'
    'bG90aGVzX2xpbmUYCyABKAhICFIOaGFzQ2xvdGhlc0xpbmWIAQESHgoIaGFzX3dpZmkYDCABKA'
    'hICVIHaGFzV2lmaYgBARIaCgZoYXNfdHYYDSABKAhIClIFaGFzVHaIAQESKgoOaGFzX3Jlc3Rh'
    'dXJhbnQYDiABKAhIC1INaGFzUmVzdGF1cmFudIgBARI1ChRoYXNfY29tbXVuaXR5X2Rpbm5lch'
    'gPIAEoCEgMUhJoYXNDb21tdW5pdHlEaW5uZXKIAQESIgoKaGFzX2Rpbm5lchgQIAEoCEgNUglo'
    'YXNEaW5uZXKIAQESMwoTaGFzX3dhc2hpbmdfbWFjaGluZRgRIAEoCEgOUhFoYXNXYXNoaW5nTW'
    'FjaGluZYgBARIpCg5oYXNfc3Bpbl9kcnllchgSIAEoCEgPUgxoYXNTcGluRHJ5ZXKIAQESNgoV'
    'aGFzX2hhbmRfd2FzaGluZ19zaW5rGBMgASgISBBSEmhhc0hhbmRXYXNoaW5nU2lua4gBARItCh'
    'BoYXNfdHVtYmxlX2RyeWVyGBQgASgISBFSDmhhc1R1bWJsZURyeWVyiAEBEj0KGGhhc19pbmRp'
    'dmlkdWFsX3Bvd2VycGx1ZxgVIAEoCEgSUhZoYXNJbmRpdmlkdWFsUG93ZXJwbHVniAEBEjMKE2'
    'hhc19wcml2YXRlX2xvY2tlcnMYFiABKAhIE1IRaGFzUHJpdmF0ZUxvY2tlcnOIAQESJgoMaGFz'
    'X2N1cnRhaW5zGBcgASgISBRSC2hhc0N1cnRhaW5ziAEBEh4KCGhhc19vdmVuGBggASgISBVSB2'
    'hhc092ZW6IAQESMwoTaGFzX3ZlbmRpbmdfbWFjaGluZRgZIAEoCEgWUhFoYXNWZW5kaW5nTWFj'
    'aGluZYgBARI8ChhoYXNfZnVsbF9sYXVuZHJ5X3NlcnZpY2UYGiABKAhIF1IVaGFzRnVsbExhdW'
    '5kcnlTZXJ2aWNliAEBEiIKCmhhc19mcmlkZ2UYGyABKAhIGFIJaGFzRnJpZGdliAEBEiAKCWhh'
    'c19sdW5jaBgcIAEoCEgZUghoYXNMdW5jaIgBARI3ChVoYXNfdmVnZXRhcmlhbl9vcHRpb24YHS'
    'ABKAhIGlITaGFzVmVnZXRhcmlhbk9wdGlvbogBARItChBoYXNfdmVnYW5fb3B0aW9uGB4gASgI'
    'SBtSDmhhc1ZlZ2FuT3B0aW9uiAEBEi8KEWhhc19zd2ltbWluZ19wb29sGB8gASgISBxSD2hhc1'
    'N3aW1taW5nUG9vbIgBARI5ChZoYXNfZG9uYXRpdm9fYnJlYWtmYXN0GCAgASgISB1SFGhhc0Rv'
    'bmF0aXZvQnJlYWtmYXN0iAEBEicKDWhhc19jdWJlX2JlZHMYISABKAhIHlILaGFzQ3ViZUJlZH'
    'OIAQESMwoTaGFzX2NvbW11bml0eV9sdW5jaBgiIAEoCEgfUhFoYXNDb21tdW5pdHlMdW5jaIgB'
    'ARIoCg1pc192ZWdldGFyaWFuGCMgASgISCBSDGlzVmVnZXRhcmlhbogBARIeCghpc192ZWdhbh'
    'gkIAEoCEghUgdpc1ZlZ2FuiAEBEiIKCmlzX29yZ2FuaWMYJSABKAhIIlIJaXNPcmdhbmljiAEB'
    'EiYKDHBldHNfYWxsb3dlZBgmIAEoCEgjUgtwZXRzQWxsb3dlZIgBARIvChFoYXNfY290dG9uX3'
    'NoZWV0cxgnIAEoCEgkUg9oYXNDb3R0b25TaGVldHOIAQESMQoSaXNfZGlubmVyX2luY2x1ZGVk'
    'GCggASgISCVSEGlzRGlubmVySW5jbHVkZWSIAQESHQoKY3JlYXRlZF9hdBgpIAEoCVIJY3JlYX'
    'RlZEF0Eh0KCnVwZGF0ZWRfYXQYKiABKAlSCXVwZGF0ZWRBdBIdCgpkZWxldGVkX2F0GCsgASgJ'
    'UglkZWxldGVkQXRCDgoMX2hhc19raXRjaGVuQg8KDV9oYXNfY29va3RvcHNCEAoOX2hhc19taW'
    'Nyb3dhdmVCEwoRX2hhc193YXRlcl9ib2lsZXJCFgoUX2hhc19wbGF0ZXNfdXRlbnNpbHNCEwoR'
    'X2hhc19jb29raW5nX3BvdHNCEAoOX2hhc19icmVha2Zhc3RCGAoWX2lzX2JyZWFrZmFzdF9pbm'
    'NsdWRlZEITChFfaGFzX2Nsb3RoZXNfbGluZUILCglfaGFzX3dpZmlCCQoHX2hhc190dkIRCg9f'
    'aGFzX3Jlc3RhdXJhbnRCFwoVX2hhc19jb21tdW5pdHlfZGlubmVyQg0KC19oYXNfZGlubmVyQh'
    'YKFF9oYXNfd2FzaGluZ19tYWNoaW5lQhEKD19oYXNfc3Bpbl9kcnllckIYChZfaGFzX2hhbmRf'
    'd2FzaGluZ19zaW5rQhMKEV9oYXNfdHVtYmxlX2RyeWVyQhsKGV9oYXNfaW5kaXZpZHVhbF9wb3'
    'dlcnBsdWdCFgoUX2hhc19wcml2YXRlX2xvY2tlcnNCDwoNX2hhc19jdXJ0YWluc0ILCglfaGFz'
    'X292ZW5CFgoUX2hhc192ZW5kaW5nX21hY2hpbmVCGwoZX2hhc19mdWxsX2xhdW5kcnlfc2Vydm'
    'ljZUINCgtfaGFzX2ZyaWRnZUIMCgpfaGFzX2x1bmNoQhgKFl9oYXNfdmVnZXRhcmlhbl9vcHRp'
    'b25CEwoRX2hhc192ZWdhbl9vcHRpb25CFAoSX2hhc19zd2ltbWluZ19wb29sQhkKF19oYXNfZG'
    '9uYXRpdm9fYnJlYWtmYXN0QhAKDl9oYXNfY3ViZV9iZWRzQhYKFF9oYXNfY29tbXVuaXR5X2x1'
    'bmNoQhAKDl9pc192ZWdldGFyaWFuQgsKCV9pc192ZWdhbkINCgtfaXNfb3JnYW5pY0IPCg1fcG'
    'V0c19hbGxvd2VkQhQKEl9oYXNfY290dG9uX3NoZWV0c0IVChNfaXNfZGlubmVyX2luY2x1ZGVk');

@$core.Deprecated('Use albergueOperatingHoursDescriptor instead')
const AlbergueOperatingHours$json = {
  '1': 'AlbergueOperatingHours',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'checkin_time', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'checkinTime', '17': true},
    {'1': 'checkout_time', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'checkoutTime', '17': true},
    {'1': 'close_time', '3': 5, '4': 1, '5': 9, '9': 2, '10': 'closeTime', '17': true},
    {'1': 'open_from', '3': 6, '4': 1, '5': 9, '9': 3, '10': 'openFrom', '17': true},
    {'1': 'open_to', '3': 7, '4': 1, '5': 9, '9': 4, '10': 'openTo', '17': true},
    {'1': 'open_from_ex', '3': 8, '4': 1, '5': 9, '9': 5, '10': 'openFromEx', '17': true},
    {'1': 'open_to_ex', '3': 9, '4': 1, '5': 9, '9': 6, '10': 'openToEx', '17': true},
    {'1': 'open_from_ex2', '3': 10, '4': 1, '5': 9, '9': 7, '10': 'openFromEx2', '17': true},
    {'1': 'open_to_ex2', '3': 11, '4': 1, '5': 9, '9': 8, '10': 'openToEx2', '17': true},
    {'1': 'opens', '3': 12, '4': 1, '5': 9, '9': 9, '10': 'opens', '17': true},
    {'1': 'created_at', '3': 13, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 14, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 15, '4': 1, '5': 9, '10': 'deletedAt'},
    {'1': 'open_additional_information', '3': 16, '4': 3, '5': 11, '6': '.pb.AlbergueOperatingHours.OpenAdditionalInformationEntry', '10': 'openAdditionalInformation'},
    {'1': 'unknown_open_season', '3': 17, '4': 1, '5': 8, '10': 'unknownOpenSeason'},
    {'1': 'opens_all_year', '3': 18, '4': 1, '5': 8, '10': 'opensAllYear'},
  ],
  '3': [AlbergueOperatingHours_OpenAdditionalInformationEntry$json],
  '8': [
    {'1': '_checkin_time'},
    {'1': '_checkout_time'},
    {'1': '_close_time'},
    {'1': '_open_from'},
    {'1': '_open_to'},
    {'1': '_open_from_ex'},
    {'1': '_open_to_ex'},
    {'1': '_open_from_ex2'},
    {'1': '_open_to_ex2'},
    {'1': '_opens'},
  ],
};

@$core.Deprecated('Use albergueOperatingHoursDescriptor instead')
const AlbergueOperatingHours_OpenAdditionalInformationEntry$json = {
  '1': 'OpenAdditionalInformationEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `AlbergueOperatingHours`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueOperatingHoursDescriptor = $convert.base64Decode(
    'ChZBbGJlcmd1ZU9wZXJhdGluZ0hvdXJzEg4KAmlkGAEgASgFUgJpZBIfCgthbGJlcmd1ZV9pZB'
    'gCIAEoBVIKYWxiZXJndWVJZBImCgxjaGVja2luX3RpbWUYAyABKAlIAFILY2hlY2tpblRpbWWI'
    'AQESKAoNY2hlY2tvdXRfdGltZRgEIAEoCUgBUgxjaGVja291dFRpbWWIAQESIgoKY2xvc2VfdG'
    'ltZRgFIAEoCUgCUgljbG9zZVRpbWWIAQESIAoJb3Blbl9mcm9tGAYgASgJSANSCG9wZW5Gcm9t'
    'iAEBEhwKB29wZW5fdG8YByABKAlIBFIGb3BlblRviAEBEiUKDG9wZW5fZnJvbV9leBgIIAEoCU'
    'gFUgpvcGVuRnJvbUV4iAEBEiEKCm9wZW5fdG9fZXgYCSABKAlIBlIIb3BlblRvRXiIAQESJwoN'
    'b3Blbl9mcm9tX2V4MhgKIAEoCUgHUgtvcGVuRnJvbUV4MogBARIjCgtvcGVuX3RvX2V4MhgLIA'
    'EoCUgIUglvcGVuVG9FeDKIAQESGQoFb3BlbnMYDCABKAlICVIFb3BlbnOIAQESHQoKY3JlYXRl'
    'ZF9hdBgNIAEoCVIJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYDiABKAlSCXVwZGF0ZWRBdBIdCg'
    'pkZWxldGVkX2F0GA8gASgJUglkZWxldGVkQXQSeQobb3Blbl9hZGRpdGlvbmFsX2luZm9ybWF0'
    'aW9uGBAgAygLMjkucGIuQWxiZXJndWVPcGVyYXRpbmdIb3Vycy5PcGVuQWRkaXRpb25hbEluZm'
    '9ybWF0aW9uRW50cnlSGW9wZW5BZGRpdGlvbmFsSW5mb3JtYXRpb24SLgoTdW5rbm93bl9vcGVu'
    'X3NlYXNvbhgRIAEoCFIRdW5rbm93bk9wZW5TZWFzb24SJAoOb3BlbnNfYWxsX3llYXIYEiABKA'
    'hSDG9wZW5zQWxsWWVhchpMCh5PcGVuQWRkaXRpb25hbEluZm9ybWF0aW9uRW50cnkSEAoDa2V5'
    'GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AUIPCg1fY2hlY2tpbl90aW1lQh'
    'AKDl9jaGVja291dF90aW1lQg0KC19jbG9zZV90aW1lQgwKCl9vcGVuX2Zyb21CCgoIX29wZW5f'
    'dG9CDwoNX29wZW5fZnJvbV9leEINCgtfb3Blbl90b19leEIQCg5fb3Blbl9mcm9tX2V4MkIOCg'
    'xfb3Blbl90b19leDJCCAoGX29wZW5z');

@$core.Deprecated('Use alberguePricesDescriptor instead')
const AlberguePrices$json = {
  '1': 'AlberguePrices',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'price_from_dormitory', '3': 3, '4': 1, '5': 2, '9': 0, '10': 'priceFromDormitory', '17': true},
    {'1': 'price_to_dormitory', '3': 4, '4': 1, '5': 2, '9': 1, '10': 'priceToDormitory', '17': true},
    {'1': 'price_from_double_room', '3': 5, '4': 1, '5': 2, '9': 2, '10': 'priceFromDoubleRoom', '17': true},
    {'1': 'price_to_double_room', '3': 6, '4': 1, '5': 2, '9': 3, '10': 'priceToDoubleRoom', '17': true},
    {'1': 'price_from_single_room', '3': 7, '4': 1, '5': 2, '9': 4, '10': 'priceFromSingleRoom', '17': true},
    {'1': 'price_to_single_room', '3': 8, '4': 1, '5': 2, '9': 5, '10': 'priceToSingleRoom', '17': true},
    {'1': 'price_from_bed_shared_room', '3': 9, '4': 1, '5': 2, '9': 6, '10': 'priceFromBedSharedRoom', '17': true},
    {'1': 'price_to_bed_shared_room', '3': 10, '4': 1, '5': 2, '9': 7, '10': 'priceToBedSharedRoom', '17': true},
    {'1': 'price_from_quatro_room', '3': 11, '4': 1, '5': 2, '9': 8, '10': 'priceFromQuatroRoom', '17': true},
    {'1': 'price_to_quatro_room', '3': 12, '4': 1, '5': 2, '9': 9, '10': 'priceToQuatroRoom', '17': true},
    {'1': 'price_from_apartament', '3': 13, '4': 1, '5': 2, '9': 10, '10': 'priceFromApartament', '17': true},
    {'1': 'price_to_apartament', '3': 14, '4': 1, '5': 2, '9': 11, '10': 'priceToApartament', '17': true},
    {'1': 'price_from_triple_room', '3': 15, '4': 1, '5': 2, '9': 12, '10': 'priceFromTripleRoom', '17': true},
    {'1': 'price_to_triple_room', '3': 16, '4': 1, '5': 2, '9': 13, '10': 'priceToTripleRoom', '17': true},
    {'1': 'created_at', '3': 17, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 18, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 19, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
  '8': [
    {'1': '_price_from_dormitory'},
    {'1': '_price_to_dormitory'},
    {'1': '_price_from_double_room'},
    {'1': '_price_to_double_room'},
    {'1': '_price_from_single_room'},
    {'1': '_price_to_single_room'},
    {'1': '_price_from_bed_shared_room'},
    {'1': '_price_to_bed_shared_room'},
    {'1': '_price_from_quatro_room'},
    {'1': '_price_to_quatro_room'},
    {'1': '_price_from_apartament'},
    {'1': '_price_to_apartament'},
    {'1': '_price_from_triple_room'},
    {'1': '_price_to_triple_room'},
  ],
};

/// Descriptor for `AlberguePrices`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List alberguePricesDescriptor = $convert.base64Decode(
    'Cg5BbGJlcmd1ZVByaWNlcxIOCgJpZBgBIAEoBVICaWQSHwoLYWxiZXJndWVfaWQYAiABKAVSCm'
    'FsYmVyZ3VlSWQSNQoUcHJpY2VfZnJvbV9kb3JtaXRvcnkYAyABKAJIAFIScHJpY2VGcm9tRG9y'
    'bWl0b3J5iAEBEjEKEnByaWNlX3RvX2Rvcm1pdG9yeRgEIAEoAkgBUhBwcmljZVRvRG9ybWl0b3'
    'J5iAEBEjgKFnByaWNlX2Zyb21fZG91YmxlX3Jvb20YBSABKAJIAlITcHJpY2VGcm9tRG91Ymxl'
    'Um9vbYgBARI0ChRwcmljZV90b19kb3VibGVfcm9vbRgGIAEoAkgDUhFwcmljZVRvRG91YmxlUm'
    '9vbYgBARI4ChZwcmljZV9mcm9tX3NpbmdsZV9yb29tGAcgASgCSARSE3ByaWNlRnJvbVNpbmds'
    'ZVJvb22IAQESNAoUcHJpY2VfdG9fc2luZ2xlX3Jvb20YCCABKAJIBVIRcHJpY2VUb1NpbmdsZV'
    'Jvb22IAQESPwoacHJpY2VfZnJvbV9iZWRfc2hhcmVkX3Jvb20YCSABKAJIBlIWcHJpY2VGcm9t'
    'QmVkU2hhcmVkUm9vbYgBARI7ChhwcmljZV90b19iZWRfc2hhcmVkX3Jvb20YCiABKAJIB1IUcH'
    'JpY2VUb0JlZFNoYXJlZFJvb22IAQESOAoWcHJpY2VfZnJvbV9xdWF0cm9fcm9vbRgLIAEoAkgI'
    'UhNwcmljZUZyb21RdWF0cm9Sb29tiAEBEjQKFHByaWNlX3RvX3F1YXRyb19yb29tGAwgASgCSA'
    'lSEXByaWNlVG9RdWF0cm9Sb29tiAEBEjcKFXByaWNlX2Zyb21fYXBhcnRhbWVudBgNIAEoAkgK'
    'UhNwcmljZUZyb21BcGFydGFtZW50iAEBEjMKE3ByaWNlX3RvX2FwYXJ0YW1lbnQYDiABKAJIC1'
    'IRcHJpY2VUb0FwYXJ0YW1lbnSIAQESOAoWcHJpY2VfZnJvbV90cmlwbGVfcm9vbRgPIAEoAkgM'
    'UhNwcmljZUZyb21UcmlwbGVSb29tiAEBEjQKFHByaWNlX3RvX3RyaXBsZV9yb29tGBAgASgCSA'
    '1SEXByaWNlVG9UcmlwbGVSb29tiAEBEh0KCmNyZWF0ZWRfYXQYESABKAlSCWNyZWF0ZWRBdBId'
    'Cgp1cGRhdGVkX2F0GBIgASgJUgl1cGRhdGVkQXQSHQoKZGVsZXRlZF9hdBgTIAEoCVIJZGVsZX'
    'RlZEF0QhcKFV9wcmljZV9mcm9tX2Rvcm1pdG9yeUIVChNfcHJpY2VfdG9fZG9ybWl0b3J5QhkK'
    'F19wcmljZV9mcm9tX2RvdWJsZV9yb29tQhcKFV9wcmljZV90b19kb3VibGVfcm9vbUIZChdfcH'
    'JpY2VfZnJvbV9zaW5nbGVfcm9vbUIXChVfcHJpY2VfdG9fc2luZ2xlX3Jvb21CHQobX3ByaWNl'
    'X2Zyb21fYmVkX3NoYXJlZF9yb29tQhsKGV9wcmljZV90b19iZWRfc2hhcmVkX3Jvb21CGQoXX3'
    'ByaWNlX2Zyb21fcXVhdHJvX3Jvb21CFwoVX3ByaWNlX3RvX3F1YXRyb19yb29tQhgKFl9wcmlj'
    'ZV9mcm9tX2FwYXJ0YW1lbnRCFgoUX3ByaWNlX3RvX2FwYXJ0YW1lbnRCGQoXX3ByaWNlX2Zyb2'
    '1fdHJpcGxlX3Jvb21CFwoVX3ByaWNlX3RvX3RyaXBsZV9yb29t');

@$core.Deprecated('Use albergueReviewsDescriptor instead')
const AlbergueReviews$json = {
  '1': 'AlbergueReviews',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'g_rating', '3': 3, '4': 1, '5': 2, '10': 'gRating'},
    {'1': 'b_review_score', '3': 4, '4': 1, '5': 2, '10': 'bReviewScore'},
    {'1': 'b_id', '3': 5, '4': 1, '5': 9, '10': 'bId'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 7, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 8, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `AlbergueReviews`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueReviewsDescriptor = $convert.base64Decode(
    'Cg9BbGJlcmd1ZVJldmlld3MSDgoCaWQYASABKAVSAmlkEh8KC2FsYmVyZ3VlX2lkGAIgASgFUg'
    'phbGJlcmd1ZUlkEhkKCGdfcmF0aW5nGAMgASgCUgdnUmF0aW5nEiQKDmJfcmV2aWV3X3Njb3Jl'
    'GAQgASgCUgxiUmV2aWV3U2NvcmUSEQoEYl9pZBgFIAEoCVIDYklkEh0KCmNyZWF0ZWRfYXQYBi'
    'ABKAlSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GAcgASgJUgl1cGRhdGVkQXQSHQoKZGVsZXRl'
    'ZF9hdBgIIAEoCVIJZGVsZXRlZEF0');

@$core.Deprecated('Use albergueSocialMediaDescriptor instead')
const AlbergueSocialMedia$json = {
  '1': 'AlbergueSocialMedia',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'facebook_url', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'facebookUrl', '17': true},
    {'1': 'facebook_id', '3': 4, '4': 1, '5': 9, '9': 1, '10': 'facebookId', '17': true},
    {'1': 'instagram_handle', '3': 5, '4': 1, '5': 9, '9': 2, '10': 'instagramHandle', '17': true},
    {'1': 'messenger', '3': 6, '4': 1, '5': 9, '9': 3, '10': 'messenger', '17': true},
    {'1': 'created_at', '3': 7, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 8, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 9, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
  '8': [
    {'1': '_facebook_url'},
    {'1': '_facebook_id'},
    {'1': '_instagram_handle'},
    {'1': '_messenger'},
  ],
};

/// Descriptor for `AlbergueSocialMedia`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueSocialMediaDescriptor = $convert.base64Decode(
    'ChNBbGJlcmd1ZVNvY2lhbE1lZGlhEg4KAmlkGAEgASgFUgJpZBIfCgthbGJlcmd1ZV9pZBgCIA'
    'EoBVIKYWxiZXJndWVJZBImCgxmYWNlYm9va191cmwYAyABKAlIAFILZmFjZWJvb2tVcmyIAQES'
    'JAoLZmFjZWJvb2tfaWQYBCABKAlIAVIKZmFjZWJvb2tJZIgBARIuChBpbnN0YWdyYW1faGFuZG'
    'xlGAUgASgJSAJSD2luc3RhZ3JhbUhhbmRsZYgBARIhCgltZXNzZW5nZXIYBiABKAlIA1IJbWVz'
    'c2VuZ2VyiAEBEh0KCmNyZWF0ZWRfYXQYByABKAlSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GA'
    'ggASgJUgl1cGRhdGVkQXQSHQoKZGVsZXRlZF9hdBgJIAEoCVIJZGVsZXRlZEF0Qg8KDV9mYWNl'
    'Ym9va191cmxCDgoMX2ZhY2Vib29rX2lkQhMKEV9pbnN0YWdyYW1faGFuZGxlQgwKCl9tZXNzZW'
    '5nZXI=');

@$core.Deprecated('Use albergueWifiDescriptor instead')
const AlbergueWifi$json = {
  '1': 'AlbergueWifi',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'url', '3': 3, '4': 1, '5': 9, '10': 'url'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 5, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 6, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `AlbergueWifi`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueWifiDescriptor = $convert.base64Decode(
    'CgxBbGJlcmd1ZVdpZmkSDgoCaWQYASABKAVSAmlkEh8KC2FsYmVyZ3VlX2lkGAIgASgFUgphbG'
    'Jlcmd1ZUlkEhAKA3VybBgDIAEoCVIDdXJsEh0KCmNyZWF0ZWRfYXQYBCABKAlSCWNyZWF0ZWRB'
    'dBIdCgp1cGRhdGVkX2F0GAUgASgJUgl1cGRhdGVkQXQSHQoKZGVsZXRlZF9hdBgGIAEoCVIJZG'
    'VsZXRlZEF0');

@$core.Deprecated('Use albergueEmailDescriptor instead')
const AlbergueEmail$json = {
  '1': 'AlbergueEmail',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'email_address', '3': 3, '4': 1, '5': 9, '10': 'emailAddress'},
    {'1': 'created_at', '3': 4, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 5, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 6, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `AlbergueEmail`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueEmailDescriptor = $convert.base64Decode(
    'Cg1BbGJlcmd1ZUVtYWlsEg4KAmlkGAEgASgFUgJpZBIfCgthbGJlcmd1ZV9pZBgCIAEoBVIKYW'
    'xiZXJndWVJZBIjCg1lbWFpbF9hZGRyZXNzGAMgASgJUgxlbWFpbEFkZHJlc3MSHQoKY3JlYXRl'
    'ZF9hdBgEIAEoCVIJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYBSABKAlSCXVwZGF0ZWRBdBIdCg'
    'pkZWxldGVkX2F0GAYgASgJUglkZWxldGVkQXQ=');

@$core.Deprecated('Use alberguePhoneDescriptor instead')
const AlberguePhone$json = {
  '1': 'AlberguePhone',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'phone_number', '3': 3, '4': 1, '5': 9, '9': 0, '10': 'phoneNumber', '17': true},
    {'1': 'whatsapp', '3': 4, '4': 1, '5': 8, '9': 1, '10': 'whatsapp', '17': true},
    {'1': 'private', '3': 5, '4': 1, '5': 8, '9': 2, '10': 'private', '17': true},
    {'1': 'signal', '3': 6, '4': 1, '5': 8, '9': 3, '10': 'signal', '17': true},
    {'1': 'created_at', '3': 7, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 8, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 9, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
  '8': [
    {'1': '_phone_number'},
    {'1': '_whatsapp'},
    {'1': '_private'},
    {'1': '_signal'},
  ],
};

/// Descriptor for `AlberguePhone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List alberguePhoneDescriptor = $convert.base64Decode(
    'Cg1BbGJlcmd1ZVBob25lEg4KAmlkGAEgASgFUgJpZBIfCgthbGJlcmd1ZV9pZBgCIAEoBVIKYW'
    'xiZXJndWVJZBImCgxwaG9uZV9udW1iZXIYAyABKAlIAFILcGhvbmVOdW1iZXKIAQESHwoId2hh'
    'dHNhcHAYBCABKAhIAVIId2hhdHNhcHCIAQESHQoHcHJpdmF0ZRgFIAEoCEgCUgdwcml2YXRliA'
    'EBEhsKBnNpZ25hbBgGIAEoCEgDUgZzaWduYWyIAQESHQoKY3JlYXRlZF9hdBgHIAEoCVIJY3Jl'
    'YXRlZEF0Eh0KCnVwZGF0ZWRfYXQYCCABKAlSCXVwZGF0ZWRBdBIdCgpkZWxldGVkX2F0GAkgAS'
    'gJUglkZWxldGVkQXRCDwoNX3Bob25lX251bWJlckILCglfd2hhdHNhcHBCCgoIX3ByaXZhdGVC'
    'CQoHX3NpZ25hbA==');

@$core.Deprecated('Use albergueImageDescriptor instead')
const AlbergueImage$json = {
  '1': 'AlbergueImage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'file_key', '3': 3, '4': 1, '5': 9, '10': 'fileKey'},
    {'1': 'status', '3': 4, '4': 1, '5': 8, '10': 'status'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 6, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 7, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `AlbergueImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueImageDescriptor = $convert.base64Decode(
    'Cg1BbGJlcmd1ZUltYWdlEg4KAmlkGAEgASgFUgJpZBIfCgthbGJlcmd1ZV9pZBgCIAEoBVIKYW'
    'xiZXJndWVJZBIZCghmaWxlX2tleRgDIAEoCVIHZmlsZUtleRIWCgZzdGF0dXMYBCABKAhSBnN0'
    'YXR1cxIdCgpjcmVhdGVkX2F0GAUgASgJUgljcmVhdGVkQXQSHQoKdXBkYXRlZF9hdBgGIAEoCV'
    'IJdXBkYXRlZEF0Eh0KCmRlbGV0ZWRfYXQYByABKAlSCWRlbGV0ZWRBdA==');

@$core.Deprecated('Use albergueListResponseDescriptor instead')
const AlbergueListResponse$json = {
  '1': 'AlbergueListResponse',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.pb.Albergue', '10': 'items'},
  ],
};

/// Descriptor for `AlbergueListResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueListResponseDescriptor = $convert.base64Decode(
    'ChRBbGJlcmd1ZUxpc3RSZXNwb25zZRIiCgVpdGVtcxgBIAMoCzIMLnBiLkFsYmVyZ3VlUgVpdG'
    'Vtcw==');

@$core.Deprecated('Use albergueUserImageDescriptor instead')
const AlbergueUserImage$json = {
  '1': 'AlbergueUserImage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'albergue_id', '3': 2, '4': 1, '5': 5, '10': 'albergueId'},
    {'1': 'file_key', '3': 3, '4': 1, '5': 9, '10': 'fileKey'},
    {'1': 'status', '3': 4, '4': 1, '5': 8, '10': 'status'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 9, '10': 'createdAt'},
    {'1': 'updated_at', '3': 6, '4': 1, '5': 9, '10': 'updatedAt'},
    {'1': 'deleted_at', '3': 7, '4': 1, '5': 9, '10': 'deletedAt'},
  ],
};

/// Descriptor for `AlbergueUserImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List albergueUserImageDescriptor = $convert.base64Decode(
    'ChFBbGJlcmd1ZVVzZXJJbWFnZRIOCgJpZBgBIAEoBVICaWQSHwoLYWxiZXJndWVfaWQYAiABKA'
    'VSCmFsYmVyZ3VlSWQSGQoIZmlsZV9rZXkYAyABKAlSB2ZpbGVLZXkSFgoGc3RhdHVzGAQgASgI'
    'UgZzdGF0dXMSHQoKY3JlYXRlZF9hdBgFIAEoCVIJY3JlYXRlZEF0Eh0KCnVwZGF0ZWRfYXQYBi'
    'ABKAlSCXVwZGF0ZWRBdBIdCgpkZWxldGVkX2F0GAcgASgJUglkZWxldGVkQXQ=');

