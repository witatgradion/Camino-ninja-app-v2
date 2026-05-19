import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/app_helper.dart';
import 'package:camino_ninja_flutter/utils/network_util.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:remote_data/remote_data.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'albergue_details_state.dart';

const reviewsPerPage = 10;

class AlbergueDetailsCubit extends Cubit<AlbergueDetailsState>
    with SafeEmitMixin {
  AlbergueDetailsCubit({
    required this.albergueId,
    int? cityId,
    int? routeId,
  })  : _inputCityId = _normalizeNavId(cityId),
        _inputRouteId = _normalizeNavId(routeId),
        super(const AlbergueDetailsState());

  final int albergueId;
  final int? _inputCityId;
  final int? _inputRouteId;

  final Repository _repository = GetIt.instance<Repository>();
  final CancelToken _cancelToken = CancelToken();

  Future<void>? _navigationResolveFuture;
  int? _resolvedCityId;
  int? _resolvedRouteId;

  static int? _normalizeNavId(int? id) =>
      (id != null && id > 0) ? id : null;

  Future<void> _ensureNavigationResolved() async {
    _navigationResolveFuture ??= _resolveNavigation();
    await _navigationResolveFuture;
  }

  Future<void> _resolveNavigation() async {
    final ids = await _repository.resolveAlbergueNavigationIds(
      albergueId: albergueId,
      cityId: _inputCityId,
      routeId: _inputRouteId,
    );
    _resolvedCityId = ids.cityId;
    _resolvedRouteId = ids.routeId;
  }

  Stream<bool> get uploadingStream =>
      stream.map((s) => s.uploadingPhotos).distinct();

  Future<void> getAlbergue() async {
    try {
      await _ensureNavigationResolved();
      safeEmit(
        state.copyWith(
          loading: true,
          resolvedCityId: _resolvedCityId,
          resolvedRouteId: _resolvedRouteId,
        ),
      );

      final isNetworkConnected = NetworkUtil().isConnected;
      if (isNetworkConnected) {
        await _repository.fetchAndSaveAlbergueRating(
          id: albergueId,
        );
      }

      final updatedAlbergue =
          await _repository.getAlberguesWithNestedObjectsFromDb(
        albergueId: albergueId,
      );
      final city =
          await _repository.tryGetCityByIdFromDb(_resolvedCityId);
      safeEmit(
        state.copyWith(
          albergue: updatedAlbergue.first,
          city: city,
          loading: false,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          loading: false,
        ),
      );
    }
  }

  Future<void> getAlbergueImages() async {
    try {
      final result = await _repository.getAlbergueImagesByAlbergueId(
        albergueId,
      );
      safeEmit(state.copyWith(albergueImages: result));
    } catch (e) {
      safeEmit(state.copyWith(albergueImages: []));
    }
  }

  Future<void> getRoutePoints() async {
    try {
      await _ensureNavigationResolved();
      final routeId = _resolvedRouteId;
      if (routeId == null || routeId <= 0) {
        safeEmit(
          state.copyWith(
            resolvedCityId: _resolvedCityId,
            resolvedRouteId: _resolvedRouteId,
            routePoints: [],
            altRoutePoints: [],
          ),
        );
        return;
      }
      final result = await _repository.getRoutePointsByRouteIdFromDb(
        routeId: routeId,
      );
      final altRoutePoints =
          await _repository.getAltRoutePointsWithValueByRouteId(
        routeId: routeId,
      );
      safeEmit(
        state.copyWith(
          resolvedCityId: _resolvedCityId,
          resolvedRouteId: _resolvedRouteId,
          routePoints: result.map((point) {
            return LatLng(
              point.latitude,
              point.longitude,
            );
          }).toList(),
          altRoutePoints: altRoutePoints,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(
          resolvedCityId: _resolvedCityId,
          resolvedRouteId: _resolvedRouteId,
          routePoints: [],
          altRoutePoints: [],
        ),
      );
    }
  }

  Future<void> uploadAlberguePhoto(List<File> images) async {
    try {
      safeEmit(state.copyWith(uploadingPhotos: true));
      if (images.isNotEmpty) {
        final result = await _repository.uploadAlbergueImage(
          images: images,
          albergueId: albergueId,
          cancelToken: _cancelToken,
        );

        switch (result) {
          case ApiSuccess():
            safeEmit(
              state.copyWith(uploadingPhotos: false, photoUploaded: true),
            );
          case ApiFailure(message: final error):
            safeEmit(
              state.copyWith(uploadingPhotos: false, uploadError: error),
            );
        }
      } else {
        safeEmit(
          state.copyWith(
            uploadingPhotos: false,
            uploadError: 'Error uploading image',
          ),
        );
      }
    } catch (e) {
      safeEmit(state.copyWith(uploadingPhotos: false));
    }
  }

  void closeTopNotificationBar() {
    safeEmit(state.copyWith());
  }

  Future<void> loadReviews() async {
    try {
      safeEmit(state.copyWith(loadReviewsStatus: LoadReviewsStatus.loading));
      final connectivityResult = await Connectivity().checkConnectivity();

      final isOffline = !connectivityResult.contains(ConnectivityResult.wifi) &&
          !connectivityResult.contains(ConnectivityResult.mobile);
      if (isOffline) {
        safeEmit(state.copyWith(loadReviewsStatus: LoadReviewsStatus.offline));
        return;
      }

      final result = await _repository.getAlbergueReviews(
        albergueId: albergueId,
      );
      final reviews = result.albergueUserReviews ?? [];
      final total = result.total ?? 0;
      safeEmit(
        state.copyWith(
          loadReviewsStatus: LoadReviewsStatus.loaded,
          reviews: reviews,
          reviewTotal: total,
          reviewPage: 1,
          canLoadMoreReviews: reviews.isNotEmpty && reviews.length < total,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(loadReviewsStatus: LoadReviewsStatus.error));
    }
  }

  /// Resets reviews to page 1 and fetches page 1 only (e.g. after app language change).
  Future<void> reloadReviewsForNewLocale() async {
    try {
      safeEmit(
        state.copyWith(
          reviews: [],
          reviewPage: 1,
          canLoadMoreReviews: true,
          loadMoreReviewsStatus: LoadMoreReviewsStatus.initial,
          loadReviewsStatus: LoadReviewsStatus.loading,
        ),
      );
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOffline = !connectivityResult.contains(ConnectivityResult.wifi) &&
          !connectivityResult.contains(ConnectivityResult.mobile);
      if (isOffline) {
        safeEmit(state.copyWith(loadReviewsStatus: LoadReviewsStatus.offline));
        return;
      }
      final result = await _repository.getAlbergueReviews(
        albergueId: albergueId,
      );
      final reviews = result.albergueUserReviews ?? [];
      final total = result.total ?? 0;
      safeEmit(
        state.copyWith(
          loadReviewsStatus: LoadReviewsStatus.loaded,
          reviews: reviews,
          reviewTotal: total,
          reviewPage: 1,
          canLoadMoreReviews: reviews.isNotEmpty && reviews.length < total,
        ),
      );
    } catch (e) {
      safeEmit(state.copyWith(loadReviewsStatus: LoadReviewsStatus.error));
    }
  }

  Future<void> loadMoreReviews() async {
    final isLoadingMore =
        state.loadMoreReviewsStatus == LoadMoreReviewsStatus.loading;
    if (isLoadingMore || !state.canLoadMoreReviews) return;

    try {
      safeEmit(
        state.copyWith(loadMoreReviewsStatus: LoadMoreReviewsStatus.loading),
      );
      final newPage = state.reviewPage + 1;
      final result = await _repository.getAlbergueReviews(
        albergueId: albergueId,
      );
      final reviews = result.albergueUserReviews ?? [];
      final total = result.total ?? 0;
      final allReviews = [...state.reviews, ...reviews];
      safeEmit(
        state.copyWith(
          loadMoreReviewsStatus: LoadMoreReviewsStatus.loaded,
          reviews: allReviews,
          reviewTotal: total,
          reviewPage: newPage,
          canLoadMoreReviews:
              allReviews.isNotEmpty && allReviews.length < total,
        ),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(loadMoreReviewsStatus: LoadMoreReviewsStatus.error),
      );
    }
  }

  Future<void> loadInstalledMaps() async {
    final isGoogleMapInstalled = await map_launcher.MapLauncher.isMapAvailable(
      map_launcher.MapType.google,
    );
    bool? isAppleMapInstalled;
    if (Platform.isIOS) {
      isAppleMapInstalled = await map_launcher.MapLauncher.isMapAvailable(
        map_launcher.MapType.apple,
      );
    }
    final supportedMaps = <SupportedMaps>[SupportedMaps.mapsMe];
    if (isGoogleMapInstalled == true) {
      supportedMaps.add(SupportedMaps.google);
    }
    if (isAppleMapInstalled ?? false) {
      supportedMaps.add(SupportedMaps.apple);
    }
    safeEmit(
      state.copyWith(
        supportedMaps: supportedMaps,
      ),
    );
  }

  void cancelUpload() {
    _cancelToken.cancel();
  }

  Future<bool> isLoggedIn() async {
    final userrCredential = await _repository.getCredential();
    return userrCredential.isLoggedIn;
  }

  Future<bool> shouldUpgradeToUseFeature() async {
    final optionalUpgradeMinBuild =
        await _repository.getOptionalUpgradeMinBuild();
    if (optionalUpgradeMinBuild == null) {
      return false;
    }
    return AppHelper.shouldUpgradeToUseFeature(optionalUpgradeMinBuild);
  }

  void setAlbergueSelected(bool isSelected) {
    safeEmit(state.copyWith(isSelected: isSelected));
  }
}
