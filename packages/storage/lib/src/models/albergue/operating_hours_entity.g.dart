// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operating_hours_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OperatingHoursEntity _$OperatingHoursEntityFromJson(
        Map<String, dynamic> json) =>
    OperatingHoursEntity(
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      id: (json['operating_hours_id'] as num).toInt(),
      checkinTime: json['checkin_time'] as String?,
      checkoutTime: json['checkout_time'] as String?,
      closeTime: json['close_time'] as String?,
      openFrom: json['open_from'] as String?,
      openFromEx: json['open_from_ex'] as String?,
      openFromEx2: json['open_from_ex2'] as String?,
      openTo: json['open_to'] as String?,
      openToEx: json['open_to_ex'] as String?,
      openToEx2: json['open_to_ex2'] as String?,
      opens: json['opens'] as String?,
      openAdditionalInformation: const MapStringConverter()
          .fromJson(json['open_additional_information'] as String?),
      unknownOpenSeason: json['unknown_open_season'] == null
          ? false
          : intToBool((json['unknown_open_season'] as num?)?.toInt()),
      opensAllYear: json['opens_all_year'] == null
          ? false
          : intToBool((json['opens_all_year'] as num?)?.toInt()),
    );

Map<String, dynamic> _$OperatingHoursEntityToJson(
        OperatingHoursEntity instance) =>
    <String, dynamic>{
      'albergue_id': instance.albergueId,
      'operating_hours_id': instance.id,
      'checkin_time': instance.checkinTime,
      'checkout_time': instance.checkoutTime,
      'close_time': instance.closeTime,
      'open_from': instance.openFrom,
      'open_from_ex': instance.openFromEx,
      'open_from_ex2': instance.openFromEx2,
      'open_to': instance.openTo,
      'open_to_ex': instance.openToEx,
      'open_to_ex2': instance.openToEx2,
      'opens': instance.opens,
      'open_additional_information':
          const MapStringConverter().toJson(instance.openAdditionalInformation),
      'unknown_open_season': instance.unknownOpenSeason,
      'opens_all_year': instance.opensAllYear,
    };
