// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueListResponse _$AlbergueListResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => AlbergueResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AlbergueListResponseToJson(
        AlbergueListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
