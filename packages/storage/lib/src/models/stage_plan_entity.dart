import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:storage/src/models/stage_entity.dart';

part 'stage_plan_entity.g.dart';

@JsonSerializable()
class StagePlanEntity extends Equatable {
  const StagePlanEntity({
    required this.id,
    required this.routeId,
    required this.createdAt,
    this.updatedAt,
    this.stages = const [],
    this.isImported = false,
    this.name,
    this.uuid,
    this.planUuid,
    this.deletedAt,
    this.trailRouteIds,
    this.startingDate,
  });

  final int id;
  @JsonKey(name: 'route_id')
  final int routeId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<StageEntity> stages;
  @JsonKey(name: 'is_imported', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool isImported;
  final String? name;
  final String? uuid;
  @JsonKey(name: 'plan_uuid')
  final String? planUuid;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;
  @JsonKey(name: 'trail_route_ids')
  final String? trailRouteIds;
  @JsonKey(name: 'starting_date')
  final String? startingDate;

  static bool _boolFromInt(dynamic value) => value == 1 || value == true;
  static int _boolToInt(bool value) => value ? 1 : 0;

  @override
  List<Object?> get props => [
        id,
        routeId,
        createdAt,
        updatedAt,
        stages,
        isImported,
        name,
        uuid,
        planUuid,
        deletedAt,
        trailRouteIds,
        startingDate,
      ];

  factory StagePlanEntity.fromJson(Map<String, dynamic> json) =>
      _$StagePlanEntityFromJson(json);

  Map<String, dynamic> toJson() => _$StagePlanEntityToJson(this);

  /// Returns a copy with the given fields replaced.
  ///
  /// Nullable fields use a sentinel (`_undefined`) so callers can
  /// explicitly nullify them — `?? this.field` cannot express that.
  StagePlanEntity copyWith({
    int? id,
    int? routeId,
    DateTime? createdAt,
    Object? updatedAt = _undefined,
    List<StageEntity>? stages,
    bool? isImported,
    Object? name = _undefined,
    Object? uuid = _undefined,
    Object? planUuid = _undefined,
    Object? deletedAt = _undefined,
    Object? startingDate = _undefined,
  }) {
    return StagePlanEntity(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: identical(updatedAt, _undefined)
          ? this.updatedAt
          : updatedAt as DateTime?,
      stages: stages ?? this.stages,
      isImported: isImported ?? this.isImported,
      name: identical(name, _undefined) ? this.name : name as String?,
      uuid: identical(uuid, _undefined) ? this.uuid : uuid as String?,
      planUuid: identical(planUuid, _undefined)
          ? this.planUuid
          : planUuid as String?,
      deletedAt: identical(deletedAt, _undefined)
          ? this.deletedAt
          : deletedAt as String?,
      startingDate: identical(startingDate, _undefined)
          ? this.startingDate
          : startingDate as String?,
    );
  }
}

/// Sentinel for [StagePlanEntity.copyWith] to distinguish "not provided"
/// from "explicit null".
const Object _undefined = Object();
