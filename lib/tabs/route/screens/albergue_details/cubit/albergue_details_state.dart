part of 'albergue_details_cubit.dart';

enum LoadReviewsStatus {
  initial,
  loading,
  loaded,
  error,
  offline,
}

enum LoadMoreReviewsStatus {
  initial,
  loading,
  loaded,
  error,
}

enum SupportedMaps {
  mapsMe,
  google,
  apple;

  String get label => switch (this) {
        mapsMe => 'MAPS.ME',
        google => 'Google Maps',
        apple => 'Apple Maps',
      };
}

class AlbergueDetailsState extends Equatable {
  const AlbergueDetailsState({
    this.albergue,
    this.resolvedCityId,
    this.resolvedRouteId,
    this.albergueImages = const [],
    this.routePoints,
    this.altRoutePoints,
    this.uploadingPhotos = false,
    this.uploadError,
    this.photoUploaded,
    this.reviews = const [],
    this.reviewPage = 1,
    this.reviewTotal = 0,
    this.canLoadMoreReviews = true,
    this.supportedMaps = const [],
    this.loadReviewsStatus = LoadReviewsStatus.initial,
    this.loadMoreReviewsStatus = LoadMoreReviewsStatus.initial,
    this.city,
    this.loading = false,
    this.isSelected = false,
  });

  final bool loading;
  final int? resolvedCityId;
  final int? resolvedRouteId;
  final CityEntity? city;
  final AlbergueEntity? albergue;
  final List<ImageEntity> albergueImages;
  final List<LatLng>? routePoints;
  final List<AltRoutePointEntity>? altRoutePoints;
  final bool uploadingPhotos;
  final String? uploadError;
  final bool? photoUploaded;
  final List<AlbergueReviewModel> reviews;
  final int reviewPage;
  final int reviewTotal;
  final bool canLoadMoreReviews;
  final LoadReviewsStatus loadReviewsStatus;
  final LoadMoreReviewsStatus loadMoreReviewsStatus;
  final List<SupportedMaps> supportedMaps;
  final bool isSelected;

  //copyWith
  AlbergueDetailsState copyWith({
    AlbergueEntity? albergue,
    int? resolvedCityId,
    int? resolvedRouteId,
    List<ImageEntity>? albergueImages,
    List<LatLng>? routePoints,
    bool? uploadingPhotos,
    String? uploadError,
    bool? photoUploaded,
    List<AlbergueReviewModel>? reviews,
    int? reviewPage,
    int? reviewTotal,
    bool? canLoadMoreReviews,
    LoadReviewsStatus? loadReviewsStatus,
    LoadMoreReviewsStatus? loadMoreReviewsStatus,
    List<SupportedMaps>? supportedMaps,
    List<AltRoutePointEntity>? altRoutePoints,
    CityEntity? city,
    bool? loading,
    bool? isSelected,
  }) {
    return AlbergueDetailsState(
      albergue: albergue ?? this.albergue,
      resolvedCityId: resolvedCityId ?? this.resolvedCityId,
      resolvedRouteId: resolvedRouteId ?? this.resolvedRouteId,
      albergueImages: albergueImages ?? this.albergueImages,
      routePoints: routePoints ?? this.routePoints,
      uploadingPhotos: uploadingPhotos ?? this.uploadingPhotos,
      uploadError: uploadError,
      photoUploaded: photoUploaded,
      reviews: reviews ?? this.reviews,
      reviewPage: reviewPage ?? this.reviewPage,
      reviewTotal: reviewTotal ?? this.reviewTotal,
      loadMoreReviewsStatus:
          loadMoreReviewsStatus ?? this.loadMoreReviewsStatus,
      loadReviewsStatus: loadReviewsStatus ?? this.loadReviewsStatus,
      canLoadMoreReviews: canLoadMoreReviews ?? this.canLoadMoreReviews,
      supportedMaps: supportedMaps ?? this.supportedMaps,
      altRoutePoints: altRoutePoints ?? this.altRoutePoints,
      city: city ?? this.city,
      loading: loading ?? this.loading,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object?> get props => [
        albergue,
        resolvedCityId,
        resolvedRouteId,
        albergueImages,
        routePoints,
        altRoutePoints,
        uploadingPhotos,
        uploadError,
        photoUploaded,
        reviews,
        reviewPage,
        reviewTotal,
        canLoadMoreReviews,
        loadMoreReviewsStatus,
        loadReviewsStatus,
        supportedMaps,
        city,
        loading,
        isSelected,
      ];
}
