// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_phone_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlberguePhoneResponse _$AlberguePhoneResponseFromJson(
        Map<String, dynamic> json) =>
    AlberguePhoneResponse(
      id: (json['id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num).toInt(),
      phoneNumber: json['phone_number'] as String,
      whatsapp: json['whatsapp'] as bool? ?? false,
      signal: json['signal'] as bool? ?? false,
      private: json['private'] as bool? ?? false,
    );

Map<String, dynamic> _$AlberguePhoneResponseToJson(
        AlberguePhoneResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'phone_number': instance.phoneNumber,
      'whatsapp': _boolToInt(instance.whatsapp),
      'signal': _boolToInt(instance.signal),
      'private': _boolToInt(instance.private),
    };
