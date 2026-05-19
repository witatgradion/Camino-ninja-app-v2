import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stage_entity.g.dart';

DateTime _dateFromJson(String json) {
  final parts = json.split(RegExp(r'[T ]'));
  final dateParts = parts[0].split('-');
  return DateTime(
    int.parse(dateParts[0]),
    int.parse(dateParts[1]),
    int.parse(dateParts[2]),
  );
}

String _dateToJson(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

DateTime? _nullableDateFromJson(String? json) {
  if (json == null) return null;
  return _dateFromJson(json);
}

String? _nullableDateToJson(DateTime? date) {
  if (date == null) return null;
  return _dateToJson(date);
}

@JsonSerializable()
class StageEntity extends Equatable {
  const StageEntity({
    required this.id,
    required this.stagePlanId,
    required this.routeId,
    this.stageUuid,
    required this.startCityId,
    required this.endCityId,
    this.date,
    this.startAlbergueId,
    this.endAlbergueId,
    this.customStartNotes,
    this.customEndNotes,
    this.stageNotes,
    this.createdAt,
    this.updatedAt,
    this.stageNumber,
    this.daysToStay = 1,
  });

  final int id;
  @JsonKey(name: 'stage_plan_id')
  final int stagePlanId;
  @JsonKey(name: 'route_id')
  final int routeId;
  @JsonKey(name: 'stage_uuid', includeIfNull: false)
  final String? stageUuid;
  @JsonKey(fromJson: _nullableDateFromJson, toJson: _nullableDateToJson)
  final DateTime? date;
  @JsonKey(name: 'start_city_id')
  final int startCityId;
  @JsonKey(name: 'end_city_id')
  final int endCityId;
  @JsonKey(name: 'start_albergue_id')
  final int? startAlbergueId;
  @JsonKey(name: 'end_albergue_id')
  final int? endAlbergueId;
  @JsonKey(name: 'custom_start_notes')
  final String? customStartNotes;
  @JsonKey(name: 'custom_end_notes')
  final String? customEndNotes;
  @JsonKey(name: 'stage_notes')
  final String? stageNotes;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'stage_number')
  final int? stageNumber;
  @JsonKey(name: 'days_to_stay', defaultValue: 1)
  final int daysToStay;

  @override
  List<Object?> get props => [
        id,
        stagePlanId,
        routeId,
        stageUuid,
        date,
        startCityId,
        endCityId,
        startAlbergueId,
        endAlbergueId,
        customStartNotes,
        customEndNotes,
        stageNotes,
        createdAt,
        updatedAt,
        stageNumber,
        daysToStay,
      ];

  factory StageEntity.fromJson(Map<String, dynamic> json) =>
      _$StageEntityFromJson(json);

  Map<String, dynamic> toJson() => _$StageEntityToJson(this);

  /// Returns a copy of this entity with the given fields replaced.
  ///
  /// Convention for nullable fields: pass `_undefined` (the default) to keep
  /// the existing value, or pass an explicit value (including `null`) to
  /// override. This lets callers explicitly nullify a field — something
  /// `?? this.field` cannot express.
  StageEntity copyWith({
    int? id,
    int? stagePlanId,
    int? routeId,
    Object? stageUuid = _undefined,
    Object? date = _undefined,
    int? startCityId,
    int? endCityId,
    Object? startAlbergueId = _undefined,
    Object? endAlbergueId = _undefined,
    Object? customStartNotes = _undefined,
    Object? customEndNotes = _undefined,
    Object? stageNotes = _undefined,
    Object? createdAt = _undefined,
    Object? updatedAt = _undefined,
    Object? stageNumber = _undefined,
    int? daysToStay,
  }) {
    return StageEntity(
      id: id ?? this.id,
      stagePlanId: stagePlanId ?? this.stagePlanId,
      routeId: routeId ?? this.routeId,
      stageUuid: identical(stageUuid, _undefined)
          ? this.stageUuid
          : stageUuid as String?,
      date: identical(date, _undefined) ? this.date : date as DateTime?,
      startCityId: startCityId ?? this.startCityId,
      endCityId: endCityId ?? this.endCityId,
      startAlbergueId: identical(startAlbergueId, _undefined)
          ? this.startAlbergueId
          : startAlbergueId as int?,
      endAlbergueId: identical(endAlbergueId, _undefined)
          ? this.endAlbergueId
          : endAlbergueId as int?,
      customStartNotes: identical(customStartNotes, _undefined)
          ? this.customStartNotes
          : customStartNotes as String?,
      customEndNotes: identical(customEndNotes, _undefined)
          ? this.customEndNotes
          : customEndNotes as String?,
      stageNotes: identical(stageNotes, _undefined)
          ? this.stageNotes
          : stageNotes as String?,
      createdAt: identical(createdAt, _undefined)
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: identical(updatedAt, _undefined)
          ? this.updatedAt
          : updatedAt as DateTime?,
      stageNumber: identical(stageNumber, _undefined)
          ? this.stageNumber
          : stageNumber as int?,
      daysToStay: daysToStay ?? this.daysToStay,
    );
  }
}

/// Sentinel for [StageEntity.copyWith] / [StagePlanEntity.copyWith] to
/// distinguish "argument not provided" from "argument provided as null".
const Object _undefined = Object();
