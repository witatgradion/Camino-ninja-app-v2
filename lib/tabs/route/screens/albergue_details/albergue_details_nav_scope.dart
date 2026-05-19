enum AlbergueDetailsNavScope {
  routeTab,
  moreTab,
  planTab,
}

extension AlbergueDetailsNavScopeX on AlbergueDetailsNavScope {
  String get galleryPath => switch (this) {
        AlbergueDetailsNavScope.routeTab => '/gallery',
        AlbergueDetailsNavScope.moreTab => '/more/gallery',
        AlbergueDetailsNavScope.planTab => '/plan/gallery',
      };

  String fullMapPath({
    required int albergueId,
    int? cityId,
    int? routeId,
  }) {
    final params = <String, String>{'albergueId': '$albergueId'};
    if (cityId != null && cityId > 0) params['cityId'] = '$cityId';
    if (routeId != null && routeId > 0) params['routeId'] = '$routeId';
    final q = Uri(queryParameters: params).query;
    return switch (this) {
      AlbergueDetailsNavScope.routeTab => '/full-map?$q',
      AlbergueDetailsNavScope.moreTab => '/more/full-map?$q',
      AlbergueDetailsNavScope.planTab => '/plan/full-map?$q',
    };
  }
}
