// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_saved_accommodations_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncSavedAccommodationsResponse _$SyncSavedAccommodationsResponseFromJson(
        Map<String, dynamic> json) =>
    SyncSavedAccommodationsResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => SyncSavedAccommodationResponseItem.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncSavedAccommodationsResponseToJson(
        SyncSavedAccommodationsResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

SyncSavedAccommodationResponseItem _$SyncSavedAccommodationResponseItemFromJson(
        Map<String, dynamic> json) =>
    SyncSavedAccommodationResponseItem(
      albergueId: (json['albergue_id'] as num).toInt(),
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$SyncSavedAccommodationResponseItemToJson(
        SyncSavedAccommodationResponseItem instance) =>
    <String, dynamic>{
      'albergue_id': instance.albergueId,
      'updated_at': instance.updatedAt,
    };
