// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:storage/storage.dart';

class StageModel {
  final int routeId;
  final int? id;
  final int? stagePlanId;
  /// Stable client-side identifier for this stage row. Persists across
  /// SQLite [id] changes when sync replaces or re-inserts stages.
  final String? stageUuid;
  final DateTime? date;
  final CityEntity? startCity;
  final CityEntity? endCity;
  final AlbergueEntity? startAlbergue;
  final AlbergueEntity? endAlbergue;
  final String? customStartNotes;
  final String? customEndNotes;
  final String? stageNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? distance;
  final int? minElevation;
  final int? maxElevation;
  final int? elevationGain;
  final int? elevationLoss;
  final List<RoutePointEntity>? points;
  final List<RoutePointEntity>? selectedRoutePoints;
  final int? stageNumber;
  final int daysToStay;

  StageModel({
    required this.routeId,
    this.id,
    this.stagePlanId,
    this.stageUuid,
    this.createdAt,
    this.distance,
    this.minElevation,
    this.maxElevation,
    this.elevationGain,
    this.elevationLoss,
    this.points,
    this.date,
    this.startCity,
    this.endCity,
    this.startAlbergue,
    this.endAlbergue,
    this.customStartNotes,
    this.customEndNotes,
    this.stageNotes,
    this.updatedAt,
    this.selectedRoutePoints,
    this.stageNumber,
    this.daysToStay = 1,
  });

  StageModel copyWith({
    int? id,
    int? stagePlanId,
    String? stageUuid,
    int? routeId,
    DateTime? date,
    bool clearDate = false,
    CityEntity? startCity,
    CityEntity? endCity,
    AlbergueEntity? startAlbergue,
    AlbergueEntity? endAlbergue,
    String? customStartNotes,
    String? customEndNotes,
    String? stageNotes,
    bool clearStageNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? distance,
    int? minElevation,
    int? maxElevation,
    int? elevationGain,
    int? elevationLoss,
    List<RoutePointEntity>? points,
    List<RoutePointEntity>? selectedRoutePoints,
    int? stageNumber,
    int? daysToStay,
  }) {
    return StageModel(
      id: id ?? this.id,
      stagePlanId: stagePlanId ?? this.stagePlanId,
      stageUuid: stageUuid ?? this.stageUuid,
      routeId: routeId ?? this.routeId,
      date: clearDate ? null : (date ?? this.date),
      startCity: startCity ?? this.startCity,
      endCity: endCity ?? this.endCity,
      startAlbergue: startAlbergue ?? this.startAlbergue,
      endAlbergue: endAlbergue ?? this.endAlbergue,
      customStartNotes:
          customStartNotes ?? this.customStartNotes,
      customEndNotes: customEndNotes ?? this.customEndNotes,
      stageNotes: clearStageNotes ? null : (stageNotes ?? this.stageNotes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      distance: distance ?? this.distance,
      minElevation: minElevation ?? this.minElevation,
      maxElevation: maxElevation ?? this.maxElevation,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      points: points ?? this.points,
      selectedRoutePoints:
          selectedRoutePoints ?? this.selectedRoutePoints,
      stageNumber: stageNumber ?? this.stageNumber,
      daysToStay: daysToStay ?? this.daysToStay,
    );
  }

  StageModel clearEndCityAndEndAlbergues() {
    return StageModel(
      id: id,
      stagePlanId: stagePlanId,
      stageUuid: stageUuid,
      routeId: routeId,
      date: date,
      startCity: startCity,
      stageNotes: stageNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      distance: distance,
      minElevation: minElevation,
      maxElevation: maxElevation,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      points: points,
      selectedRoutePoints: selectedRoutePoints,
      stageNumber: stageNumber,
      daysToStay: daysToStay,
    );
  }

  StageModel clearStartAlbergueInfo() {
    return StageModel(
      id: id,
      stagePlanId: stagePlanId,
      stageUuid: stageUuid,
      routeId: routeId,
      date: date,
      startCity: startCity,
      endCity: endCity,
      endAlbergue: endAlbergue,
      customEndNotes: customEndNotes,
      stageNotes: stageNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      distance: distance,
      minElevation: minElevation,
      maxElevation: maxElevation,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      points: points,
      selectedRoutePoints: selectedRoutePoints,
      stageNumber: stageNumber,
      daysToStay: daysToStay,
    );
  }

  StageModel clearEndAlbergueInfo() {
    return StageModel(
      id: id,
      stagePlanId: stagePlanId,
      stageUuid: stageUuid,
      routeId: routeId,
      date: date,
      startCity: startCity,
      endCity: endCity,
      startAlbergue: startAlbergue,
      customStartNotes: customStartNotes,
      stageNotes: stageNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      distance: distance,
      minElevation: minElevation,
      maxElevation: maxElevation,
      elevationGain: elevationGain,
      elevationLoss: elevationLoss,
      points: points,
      selectedRoutePoints: selectedRoutePoints,
      stageNumber: stageNumber,
      daysToStay: daysToStay,
    );
  }

  bool overviewDataIsEmpty() {
    return distance == null ||
        minElevation == null ||
        maxElevation == null ||
        elevationGain == null ||
        elevationLoss == null ||
        endCity == null ||
        points == null ||
        points!.isEmpty ||
        selectedRoutePoints == null ||
        selectedRoutePoints!.isEmpty;
  }

  bool isValid() {
    return startCity != null &&
        endCity != null &&
        selectedRoutePoints != null &&
        selectedRoutePoints!.isNotEmpty;
  }
}
