// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailEntity _$EmailEntityFromJson(Map<String, dynamic> json) => EmailEntity(
      id: (json['email_id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      emailAddress: json['email_address'] as String,
    );

Map<String, dynamic> _$EmailEntityToJson(EmailEntity instance) =>
    <String, dynamic>{
      'email_id': instance.id,
      'albergue_id': instance.albergueId,
      'email_address': instance.emailAddress,
    };
