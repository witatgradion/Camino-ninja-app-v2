// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_saved_accommodations_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncSavedAccommodationsRequest _$SyncSavedAccommodationsRequestFromJson(
        Map<String, dynamic> json) =>
    SyncSavedAccommodationsRequest(
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              SyncSavedAccommodationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncSavedAccommodationsRequestToJson(
        SyncSavedAccommodationsRequest instance) =>
    <String, dynamic>{
      'items': instance.items,
    };

SyncSavedAccommodationItem _$SyncSavedAccommodationItemFromJson(
        Map<String, dynamic> json) =>
    SyncSavedAccommodationItem(
      albergueId: (json['albergue_id'] as num).toInt(),
      updatedAt: json['updated_at'] as String,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$SyncSavedAccommodationItemToJson(
        SyncSavedAccommodationItem instance) =>
    <String, dynamic>{
      'albergue_id': instance.albergueId,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };
