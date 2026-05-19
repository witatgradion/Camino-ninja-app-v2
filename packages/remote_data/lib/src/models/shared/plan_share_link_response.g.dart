// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_share_link_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlanShareLinkResponse _$PlanShareLinkResponseFromJson(
        Map<String, dynamic> json) =>
    PlanShareLinkResponse(
      createdAt: json['created_at'] as String,
      shortCode: json['short_code'] as String,
      shortUrl: json['short_url'] as String,
    );

Map<String, dynamic> _$PlanShareLinkResponseToJson(
        PlanShareLinkResponse instance) =>
    <String, dynamic>{
      'created_at': instance.createdAt,
      'short_code': instance.shortCode,
      'short_url': instance.shortUrl,
    };
