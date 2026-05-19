// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:repository/src/models/multi_route_trail.dart';
import 'package:repository/src/models/stage_model.dart';
import 'package:storage/storage.dart';

class StagePlanModel {
  final int id;
  final RouteEntity route;
  final List<StageModel> stages;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isExpanded;
  final bool isImported;
  final String? name;
  final String? uuid;
  final String? planUuid;
  final String? deletedAt;
  final String? trailRouteIds;
  final DateTime? startingDate;

  StagePlanModel({
    required this.id,
    required this.route,
    required this.stages,
    required this.createdAt,
    this.updatedAt,
    this.isExpanded = false,
    this.isImported = false,
    this.name,
    this.uuid,
    this.planUuid,
    this.deletedAt,
    this.trailRouteIds,
    this.startingDate,
  });

  /// Whether this plan spans more than one route, either
  /// from persisted trail route IDs or from current stages.
  bool get isMultiRoute {
    if (trailRouteIds != null && trailRouteIds!.isNotEmpty) {
      return true;
    }
    final routeIds = stages.map((s) => s.routeId).toSet();
    return routeIds.length > 1;
  }

  /// All unique route IDs across stages and persisted trail,
  /// in encounter order.
  ///
  /// Supports both the new JSON format and the legacy
  /// comma-separated format via [MultiRouteTrail.parseDescriptors].
  Set<int> get uniqueRouteIds {
    final fromStages = stages.map((s) => s.routeId).toSet();
    if (trailRouteIds != null && trailRouteIds!.isNotEmpty) {
      final descriptors = MultiRouteTrail.parseDescriptors(
        trailRouteIds,
      );
      if (descriptors != null) {
        final trailIds = descriptors.map((d) => d.routeId).toSet();
        return {...trailIds, ...fromStages};
      }
    }
    return fromStages;
  }

  StagePlanModel copyWith({
    int? id,
    RouteEntity? route,
    List<StageModel>? stages,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isExpanded,
    bool? isImported,
    String? name,
    bool clearName = false,
    String? uuid,
    String? planUuid,
    String? deletedAt,
    bool clearDeletedAt = false,
    String? trailRouteIds,
    bool clearTrailRouteIds = false,
    DateTime? startingDate,
    bool clearStartingDate = false,
  }) {
    return StagePlanModel(
      id: id ?? this.id,
      route: route ?? this.route,
      stages: stages ?? this.stages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isExpanded: isExpanded ?? this.isExpanded,
      isImported: isImported ?? this.isImported,
      name: clearName ? null : (name ?? this.name),
      uuid: uuid ?? this.uuid,
      planUuid: planUuid ?? this.planUuid,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt ?? this.deletedAt),
      trailRouteIds: clearTrailRouteIds
          ? null
          : (trailRouteIds ?? this.trailRouteIds),
      startingDate: clearStartingDate
          ? null
          : (startingDate ?? this.startingDate),
    );
  }

  /// Computes the date for a stage at [stageIndex] based
  /// on [startingDate] and cumulative [StageModel.daysToStay]
  /// of all preceding stages.
  ///
  /// Returns `null` if [startingDate] is not set or [stageIndex]
  /// is out of bounds.
  ///
  /// Passing [stageIndex] equal to [stages.length] returns the
  /// first day after the final stage finishes (the plan end date).
  DateTime? computeStageDate(int stageIndex) {
    if (startingDate == null ||
        stageIndex < 0 ||
        stageIndex > stages.length) {
      return null;
    }
    var cumulativeDays = 0;
    for (var i = 0; i < stageIndex; i++) {
      cumulativeDays += stages[i].daysToStay;
    }
    return startingDate!.add(Duration(days: cumulativeDays));
  }

  /// The last calendar day of the plan.
  ///
  /// [computeStageDate] called with `stages.length` returns the first
  /// day *after* the plan ends (the departure day). Subtracting one
  /// day gives the last day the pilgrim is still on the journey.
  DateTime? get planEndDate {
    if (stages.isEmpty) return null;
    return computeStageDate(stages.length)?.subtract(const Duration(days: 1));
  }
}
