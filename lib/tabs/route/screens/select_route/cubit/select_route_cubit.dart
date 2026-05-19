import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/widgets/select_route_actions.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'select_route_state.dart';

class SelectRouteCubit extends Cubit<SelectRouteState> with SafeEmitMixin {
  SelectRouteCubit() : super(const SelectRouteState());

  final Repository _repository = GetIt.instance<Repository>();
  List<RouteDistanceElevation> _allRoutes = [];
  Timer? _searchDebounce;

  Stream<int?> get selectedIndexStream =>
      stream.map((s) => s.selectedIndex).distinct();

  Future<void> fetchRoutes(int? selectedRouteId) async {
    safeEmit(state.copyWith(initStatus: SelectRouteInitStatus.loading));
    try {
      final result = await _repository.getRoutesFromDb();
      final pointsByRouteId = <int, List<RoutePointEntity>>{};
      final data = await Future.wait(
        result.map((route) async {
          final routePoints = await _repository.getRoutePointsByRouteIdFromDb(
            routeId: route.id,
          );
          pointsByRouteId[route.id] = routePoints;
          return route.calculateRouteStatistics(
            currentRoutePoints: routePoints,
          );
        }).toList(),
      );

      _allRoutes = data;

      final selectedIndex = data.indexWhere(
        (route) => route.routeId == selectedRouteId,
      );

      safeEmit(
        state.copyWith(
          filteredRoutes: data,
          routePointsByRouteId: pointsByRouteId,
          selectedRouteId: selectedRouteId,
          initStatus: SelectRouteInitStatus.success,
        ),
      );

      if (selectedIndex != -1) {
        Future.delayed(const Duration(milliseconds: 100), () {
          safeEmit(state.copyWith(selectedIndex: selectedIndex));
        });
      }
    } catch (_) {
      safeEmit(state.copyWith(initStatus: SelectRouteInitStatus.failure));
    }
  }

  void searchRoutes(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      _applySearch(query);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _applySearch(query);
    });
  }

  void _applySearch(String query) {
    if (query.trim().isEmpty) {
      safeEmit(
        state.copyWith(
          filteredRoutes: _allRoutes,
          selectedRouteId: state.selectedRouteId,
          filteringStatus: SelectRouteFilteringStatus.success,
          isSearchActive: false,
        ),
      );
      return;
    }

    final filteredRoutes = _allRoutes.where((route) {
      final searchLower = query.toLowerCase();
      final isMatchedRouteName =
          route.routeName.normalize()?.toLowerCase().contains(searchLower);
      final isMatchedRouteSubName =
          route.routeSubName?.normalize()?.toLowerCase().contains(searchLower);
      return (isMatchedRouteName ?? false) || (isMatchedRouteSubName ?? false);
    }).toList();

    safeEmit(
      state.copyWith(
        filteredRoutes: filteredRoutes,
        selectedRouteId: state.selectedRouteId,
        filteringStatus: SelectRouteFilteringStatus.success,
        isSearchActive: true,
      ),
    );
  }

  void changeMode(SelectRouteMode mode) {
    safeEmit(state.copyWith(selectedMode: mode));
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
