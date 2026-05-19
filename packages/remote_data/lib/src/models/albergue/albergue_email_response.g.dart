// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_email_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueEmailResponse _$AlbergueEmailResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueEmailResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      emailAddress: json['email_address'] as String,
    );

Map<String, dynamic> _$AlbergueEmailResponseToJson(
        AlbergueEmailResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'email_address': instance.emailAddress,
    };
