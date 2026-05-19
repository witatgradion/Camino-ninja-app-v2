// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneEntity _$PhoneEntityFromJson(Map<String, dynamic> json) => PhoneEntity(
      id: (json['phone_id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      phoneNumber: json['phone_number'] as String,
      whatsapp: intToBool((json['whatsapp'] as num?)?.toInt()),
      private: intToBool((json['private'] as num?)?.toInt()),
      signal: intToBool((json['signal'] as num?)?.toInt()),
    );

Map<String, dynamic> _$PhoneEntityToJson(PhoneEntity instance) =>
    <String, dynamic>{
      'phone_id': instance.id,
      'albergue_id': instance.albergueId,
      'phone_number': instance.phoneNumber,
      'whatsapp': instance.whatsapp,
      'private': instance.private,
      'signal': instance.signal,
    };
