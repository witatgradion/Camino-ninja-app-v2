import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'full_map_state.dart';

class FullMapCubit extends Cubit<FullMapState> with SafeEmitMixin {
  FullMapCubit({
    required this.albergueId,
    int? cityId,
    int? routeId,
  })  : _inputCityId = _normalizeNavId(cityId),
        _inputRouteId = _normalizeNavId(routeId),
        super(const FullMapState());

  final int albergueId;
  final int? _inputCityId;
  final int? _inputRouteId;

  final Repository _repository = GetIt.instance<Repository>();

  static int? _normalizeNavId(int? id) =>
      (id != null && id > 0) ? id : null;

  Future<void> loadMap() async {
    try {
      final ids = await _repository.resolveAlbergueNavigationIds(
        albergueId: albergueId,
        cityId: _inputCityId,
        routeId: _inputRouteId,
      );
      final result = await _repository.getAlberguesWithNestedObjectsFromDb(
        albergueId: albergueId,
      );
      final albergue = result.first;
      final city = await _repository.tryGetCityByIdFromDb(ids.cityId);
      var points = <LatLng>[];
      var alt = <AltRoutePointEntity>[];
      final rid = ids.routeId;
      if (rid != null && rid > 0) {
        final rps = await _repository.getRoutePointsByRouteIdFromDb(
          routeId: rid,
        );
        points = rps
            .map(
              (point) => LatLng(
                point.latitude,
                point.longitude,
              ),
            )
            .toList();
        alt = await _repository.getAltRoutePointsWithValueByRouteId(
          routeId: rid,
        );
      }
      safeEmit(
        FullMapState(
          mapReady: true,
          albergue: albergue,
          city: city,
          routePoints: points,
          altRoutePoints: alt,
        ),
      );
    } catch (e) {
      safeEmit(const FullMapState(mapReady: true));
    }
  }
}
