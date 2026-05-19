import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/models/bool_mapper.dart';

part 'operating_hours_entity.g.dart';

class MapStringConverter
    implements JsonConverter<Map<String, dynamic>?, String?> {
  const MapStringConverter();

  @override
  Map<String, dynamic>? fromJson(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e) {
      return null;
    }
  }

  @override
  String? toJson(Map<String, dynamic>? object) {
    if (object == null) return null;
    try {
      return jsonEncode(object);
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class OperatingHoursEntity {
  const OperatingHoursEntity({
    required this.albergueId,
    required this.id,
    this.checkinTime,
    this.checkoutTime,
    this.closeTime,
    this.openFrom,
    this.openFromEx,
    this.openFromEx2,
    this.openTo,
    this.openToEx,
    this.openToEx2,
    this.opens,
    this.openAdditionalInformation,
    this.unknownOpenSeason = false,
    this.opensAllYear = false,
  });

  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'operating_hours_id')
  final int id;
  @JsonKey(name: 'checkin_time')
  final String? checkinTime;
  @JsonKey(name: 'checkout_time')
  final String? checkoutTime;
  @JsonKey(name: 'close_time')
  final String? closeTime;
  @JsonKey(name: 'open_from')
  final String? openFrom;
  @JsonKey(name: 'open_from_ex')
  final String? openFromEx;
  @JsonKey(name: 'open_from_ex2')
  final String? openFromEx2;
  @JsonKey(name: 'open_to')
  final String? openTo;
  @JsonKey(name: 'open_to_ex')
  final String? openToEx;
  @JsonKey(name: 'open_to_ex2')
  final String? openToEx2;
  final String? opens;
  @JsonKey(name: 'open_additional_information')
  @MapStringConverter()
  final Map<String, dynamic>? openAdditionalInformation;
  @JsonKey(name: 'unknown_open_season', fromJson: intToBool)
  final bool unknownOpenSeason;
  @JsonKey(name: 'opens_all_year', fromJson: intToBool)
  final bool opensAllYear;

  factory OperatingHoursEntity.fromJson(Map<String, dynamic> json) =>
      _$OperatingHoursEntityFromJson(json);

  Map<String, dynamic> toJson() => _$OperatingHoursEntityToJson(this);
}
