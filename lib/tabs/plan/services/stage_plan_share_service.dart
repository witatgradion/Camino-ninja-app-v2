import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

/// Service for encoding/decoding stage plans for QR code sharing.
class StagePlanShareService {
  const StagePlanShareService(
    this._stageRepository,
    this._repository, {
    this.buildNumber,
    this.platform,
  });

  final StagePlanRepository _stageRepository;
  final Repository _repository;

  /// Build number for encoding. Required only for export operations.
  final int? buildNumber;

  /// Platform for encoding. Required only for export operations.
  final QrPlatform? platform;

  /// Encode a single StagePlanModel to a QR-compatible string.
  /// Requires [buildNumber] and [platform] to be set.
  String encodePlan(StagePlanModel plan) {
    return encodePlans([plan]);
  }

  /// Encode multiple StagePlanModels to a QR-compatible string.
  /// Requires [buildNumber] and [platform] to be set.
  String encodePlans(List<StagePlanModel> plans) {
    if (buildNumber == null) {
      throw const StagePlanShareException('Build number required for encoding');
    }
    if (platform == null) {
      throw const StagePlanShareException('Platform required for encoding');
    }
    if (plans.isEmpty) {
      throw const StagePlanShareException('No plans to encode');
    }

    final planDataList = plans.map((plan) {
      final stages = <StageData>[];
      for (var i = 0; i < plan.stages.length; i++) {
        final stage = plan.stages[i];
        final startCityId = stage.startCity?.id;
        final endCityId = stage.endCity?.id;

        if (startCityId == null || endCityId == null) {
          throw const StagePlanShareException(
            'All stages must have start city and end city',
          );
        }

        // Use explicit date, computed date, or sequential
        // placeholder so legacy format gets distinct dates.
        final date = stage.date ??
            plan.computeStageDate(i) ??
            DateTime(2000).add(Duration(days: i));

        stages.add(
          StageData(
            date: date,
            startCityId: startCityId,
            endCityId: endCityId,
            startAlbergueId: stage.startAlbergue?.id,
            endAlbergueId: stage.endAlbergue?.id,
          ),
        );
      }

      return StagePlanData(
        routeId: plan.route.id,
        stages: stages,
        name: plan.name,
      );
    }).toList();

    try {
      return StagePlanCodec.encodeMultiple(
        planDataList,
        buildNumber: buildNumber!,
        platform: platform!,
      );
    } on CodecException catch (e) {
      throw StagePlanShareException('Failed to encode: ${e.message}');
    }
  }

  /// Import selected stage plans to local database.
  /// Creates new plans with new IDs (ignores IDs from input models).
  /// Returns the import result with created plan IDs.
  ///
  /// [plans] - List of StagePlanModel to import (from getPlans() preview)
  Future<ImportResult> importPlans(List<StagePlanModel> plans) async {
    if (plans.isEmpty) {
      throw const StagePlanShareException('No plans to import');
    }

    final createdPlanIds = <int>[];
    var totalStages = 0;

    for (final plan in plans) {
      if (plan.stages.isEmpty) {
        continue; // Skip plans with no stages
      }

      int? stagePlanId;
      var createdStagesCount = 0;

      for (final stage in plan.stages) {
        // Skip stages without required city data
        if (stage.startCity?.id == null ||
            stage.endCity?.id == null) {
          continue;
        }

        final stageId = await _stageRepository.createStage(
          routeId: plan.route.id,
          stagePlanId: stagePlanId,
          date: stage.date,
          daysToStay: stage.daysToStay,
          startCityId: stage.startCity!.id,
          endCityId: stage.endCity!.id,
          startAlbergueId: stage.startAlbergue?.id,
          endAlbergueId: stage.endAlbergue?.id,
          isImported: true,
          planName: stagePlanId == null ? plan.name : null,
        );

        createdStagesCount++;

        // Get the stagePlanId from the first created stage
        if (stagePlanId == null) {
          final createdStage = await _stageRepository.getStageById(stageId);
          stagePlanId = createdStage?.stagePlanId;
        }
      }

      if (stagePlanId != null && createdStagesCount > 0) {
        createdPlanIds.add(stagePlanId);
        totalStages += createdStagesCount;
        final serverUuid = plan.uuid;
        if (serverUuid != null && serverUuid.isNotEmpty) {
          await _stageRepository.updateStagePlanUuids(
            stagePlanId: stagePlanId,
            uuid: serverUuid,
            planUuid: plan.planUuid,
          );
        }
        if (plan.startingDate != null) {
          await _stageRepository.updatePlanStartingDate(
            stagePlanId: stagePlanId,
            startingDate: plan.startingDate,
          );
        }
      }
    }

    if (createdPlanIds.isEmpty) {
      throw const StagePlanShareException(
        'No valid plans could be imported.',
      );
    }

    return ImportResult(
      stagePlanIds: createdPlanIds,
      planCount: createdPlanIds.length,
      stageCount: totalStages,
    );
  }

  /// Reset the isImported flags of the specified stage plans.
  /// Useful when you want to mark imported plans as local/edited.
  ///
  /// [stagePlanIds] - List of stage plan IDs to reset
  /// [isImported] - The new value for the isImported flag (default: false)
  Future<void> resetImportedFlags(
    List<int> stagePlanIds, {
    bool isImported = false,
  }) async {
    if (stagePlanIds.isEmpty) return;

    for (final planId in stagePlanIds) {
      await _stageRepository.updateStagePlanIsImported(
        stagePlanId: planId,
        isImported: isImported,
      );
    }
  }

  /// Filter stages, removing those with non-existent cities.
  Future<List<StageData>> _filterValidStages(
      List<StageData> stages, int routeId,) async {
    final validStages = <StageData>[];

    for (final stage in stages) {
      // Skip stages with non-existent cities
      final isStartCityValid = await _repository.cityExistsOnRoute(
        stage.startCityId,
        routeId,
      );
      final isEndCityValid = await _repository.cityExistsOnRoute(
        stage.endCityId,
        routeId,
      );
      if (!isStartCityValid || !isEndCityValid) {
        continue;
      }

      validStages.add(
        StageData(
          date: stage.date,
          startCityId: stage.startCityId,
          endCityId: stage.endCityId,
          startAlbergueId: stage.startAlbergueId,
          endAlbergueId: stage.endAlbergueId,
        ),
      );
    }

    return validStages;
  }

  Future<DecodeResult> decodePlan(String qrData) async {
    final DecodeResult decodeResult;
    try {
      decodeResult = StagePlanCodec.decode(qrData);
    } on CodecException catch (e) {
      throw StagePlanShareException('Invalid QR code: ${e.message}');
    }

    if (decodeResult.plans.isEmpty) {
      throw const StagePlanShareException('No plans found in QR code');
    }
    return decodeResult;
  }

  Future<List<StagePlanModel>> getPlans(List<StagePlanData> plans) async {
    final newPlans = <StagePlanModel>[];
    for (final data in plans) {
      // Skip plans with non-existent routes
      final isRouteValid = await _repository.isRouteValid(data.routeId);
      if (!isRouteValid) {
        continue;
      }

      // Filter and process stages
      final validStages = await _filterValidStages(data.stages, data.routeId);
      if (validStages.isEmpty) {
        continue; // Skip plan if no valid stages
      }

      final planId = DateTime.now().microsecondsSinceEpoch;

      // Fetch route and route points once per plan
      final route = await _repository.getRouteById(data.routeId);
      final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: data.routeId,
      );

      final stages = <StageModel>[];
      for (var i = 0; i < validStages.length; i++) {
        final stage = validStages[i];
        final stageId = DateTime.now().microsecondsSinceEpoch + i;

        final startCity =
            await _repository.getCityByIdFromDb(stage.startCityId);
        final endCity = await _repository.getCityByIdFromDb(stage.endCityId);

        // Only fetch albergue if albergueId is not null
        AlbergueEntity? startAlbergue;
        if (stage.startAlbergueId != null) {
          final albergues =
              await _repository.getAlberguesWithNestedObjectsFromDb(
            albergueId: stage.startAlbergueId,
          );
          startAlbergue = albergues.firstOrNull;
        }

        AlbergueEntity? endAlbergue;
        if (stage.endAlbergueId != null) {
          final albergues =
              await _repository.getAlberguesWithNestedObjectsFromDb(
            albergueId: stage.endAlbergueId,
          );
          endAlbergue = albergues.firstOrNull;
        }

        // Calculate selected route points between start and end cities
        final selectedRoutePoints = _getSelectedRoutePoints(
          routePoints: routePoints,
          startCity: startCity,
          endCity: endCity,
          routeId: data.routeId,
        );

        // Calculate stats from route
        final stats = route.calculateRouteStatistics(
          startingCity: startCity,
          destCity: endCity,
          currentRoutePoints: selectedRoutePoints,
        );

        stages.add(
          StageModel(
            id: stageId,
            stagePlanId: planId,
            routeId: data.routeId,
            date: stage.date,
            startCity: startCity,
            endCity: endCity,
            startAlbergue: startAlbergue,
            endAlbergue: endAlbergue,
            createdAt: DateTime.now(),
            distance: stats.distance,
            minElevation: stats.minElevation,
            maxElevation: stats.maxElevation,
            elevationGain: stats.elevationGain,
            elevationLoss: stats.elevationLoss,
            points: routePoints,
            selectedRoutePoints: selectedRoutePoints,
            stageNumber: i + 1,
          ),
        );
      }
      final newPlan = StagePlanModel(
        id: planId,
        route: route,
        stages: stages,
        createdAt: DateTime.now(),
        name: data.name,
        startingDate: stages.isNotEmpty
            ? stages.first.date
            : null,
      );

      newPlans.add(newPlan);
    }
    return newPlans;
  }

  Future<StagePlanModel> getSharedPlanFromResponse(
    SharedPlanResponse response,
  ) async {
    final routeId = response.routeId;
    if (routeId == null) {
      throw const StagePlanShareException('Shared plan has no route.');
    }

    final isRouteValid = await _repository.isRouteValid(routeId);
    if (!isRouteValid) {
      throw const StagePlanShareException(
        'Route not found. Please download route data first.',
      );
    }

    final route = await _repository.getRouteById(routeId);
    final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
      routeId: routeId,
    );

    final planId = DateTime.now().microsecondsSinceEpoch;
    final stages = <StageModel>[];

    for (var i = 0; i < response.stages.length; i++) {
      final stage = response.stages[i];

      final startCityId = stage.startCityId;
      final endCityId = stage.endCityId;
      if (startCityId == null || endCityId == null) continue;

      final isStartValid = await _repository.cityExistsOnRoute(
        startCityId,
        routeId,
      );
      final isEndValid = await _repository.cityExistsOnRoute(
        endCityId,
        routeId,
      );
      if (!isStartValid || !isEndValid) continue;

      final stageId = DateTime.now().microsecondsSinceEpoch + i;
      final startCity = await _repository.getCityByIdFromDb(startCityId);
      final endCity = await _repository.getCityByIdFromDb(endCityId);

      AlbergueEntity? startAlbergue;
      if (stage.startAlbergueId != null) {
        final albergues =
            await _repository.getAlberguesWithNestedObjectsFromDb(
          albergueId: stage.startAlbergueId,
        );
        startAlbergue = albergues.firstOrNull;
      }

      AlbergueEntity? endAlbergue;
      if (stage.endAlbergueId != null) {
        final albergues =
            await _repository.getAlberguesWithNestedObjectsFromDb(
          albergueId: stage.endAlbergueId,
        );
        endAlbergue = albergues.firstOrNull;
      }

      DateTime? date;
      if (stage.date != null) {
        date = DateTime.tryParse(stage.date!);
      }

      final selectedRoutePoints = _getSelectedRoutePoints(
        routePoints: routePoints,
        startCity: startCity,
        endCity: endCity,
        routeId: routeId,
      );

      final stats = route.calculateRouteStatistics(
        startingCity: startCity,
        destCity: endCity,
        currentRoutePoints: selectedRoutePoints,
      );

      stages.add(
        StageModel(
          id: stageId,
          stagePlanId: planId,
          routeId: routeId,
          date: date,
          startCity: startCity,
          endCity: endCity,
          startAlbergue: startAlbergue,
          endAlbergue: endAlbergue,
          customStartNotes: stage.customStartNotes,
          customEndNotes: stage.customEndNotes,
          stageNotes: stage.stageNotes,
          createdAt: DateTime.now(),
          distance: stats.distance,
          minElevation: stats.minElevation,
          maxElevation: stats.maxElevation,
          elevationGain: stats.elevationGain,
          elevationLoss: stats.elevationLoss,
          points: routePoints,
          selectedRoutePoints: selectedRoutePoints,
          stageNumber: stage.stageNumber,
          daysToStay: stage.daysToStay ?? 1,
        ),
      );
    }

    if (stages.isEmpty) {
      throw const StagePlanShareException(
        'No valid stages found in shared plan.',
      );
    }

    DateTime? startingDate;
    if (response.startingDate != null) {
      startingDate = DateTime.tryParse(response.startingDate!);
    }
    // If no plan-level startingDate, derive from first stage
    startingDate ??=
        stages.isNotEmpty ? stages.first.date : null;

    return StagePlanModel(
      id: planId,
      route: route,
      stages: stages,
      createdAt: DateTime.now(),
      name: response.name,
      uuid: response.uuid,
      planUuid: response.planUuid,
      startingDate: startingDate,
    );
  }

  /// Get selected route points between start and end city
  List<RoutePointEntity> _getSelectedRoutePoints({
    required List<RoutePointEntity> routePoints,
    required CityEntity startCity,
    required CityEntity endCity,
    required int routeId,
  }) {
    if (routePoints.isEmpty) return [];

    final startingRoutePoint = startCity.routePoints.firstWhere(
      (rp) => rp.routeId == routeId,
      orElse: () => startCity.routePoints.isNotEmpty
          ? startCity.routePoints.first
          : routePoints.first,
    );
    final destRoutePoint = endCity.routePoints.firstWhere(
      (rp) => rp.routeId == routeId,
      orElse: () => endCity.routePoints.isNotEmpty
          ? endCity.routePoints.first
          : routePoints.last,
    );

    final startIdx =
        routePoints.indexWhere((e) => e.id == startingRoutePoint.id);
    final endIdx = routePoints.indexWhere((e) => e.id == destRoutePoint.id);

    if (startIdx == -1 || endIdx == -1) return routePoints;
    if (startIdx > endIdx) return routePoints.sublist(endIdx, startIdx + 1);
    return routePoints.sublist(startIdx, endIdx + 1);
  }
}

class ImportResult {
  const ImportResult({
    required this.stagePlanIds,
    required this.planCount,
    required this.stageCount,
  });

  final List<int> stagePlanIds;
  final int planCount;
  final int stageCount;

  /// For backward compatibility - returns the first plan ID
  int get stagePlanId => stagePlanIds.first;

  /// Whether multiple plans were imported
  bool get isMultiplePlans => planCount > 1;
}

class StagePlanShareException implements Exception {
  const StagePlanShareException(this.message);
  final String message;

  @override
  String toString() => message;
}
