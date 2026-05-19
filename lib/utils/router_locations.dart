/// Builds locations for [appRouter] using query parameters (deep links / BE).
abstract final class RouterLocations {
  static String _query(Map<String, String> params) =>
      Uri(queryParameters: params).query;

  static String cityDetails({required int cityId}) =>
      '/city-details?${_query({'cityId': '$cityId'})}';

  /// [albergueId] is required; [routeId] and [cityId] are optional (omit or
  /// resolve from local DB).
  static String albergueDetails({
    required int albergueId,
    int? routeId,
    int? cityId,
    int? reviewId,
  }) {
    final params = <String, String>{'albergueId': '$albergueId'};
    if (cityId != null && cityId > 0) params['cityId'] = '$cityId';
    if (routeId != null && routeId > 0) params['routeId'] = '$routeId';
    if (reviewId != null && reviewId > 0) params['reviewId'] = '$reviewId';
    return '/albergue-details?${_query(params)}';
  }

  static String fullMap({
    required int albergueId,
    int? routeId,
    int? cityId,
  }) {
    final params = <String, String>{'albergueId': '$albergueId'};
    if (cityId != null && cityId > 0) params['cityId'] = '$cityId';
    if (routeId != null && routeId > 0) params['routeId'] = '$routeId';
    return '/full-map?${_query(params)}';
  }

  static String elevation({
    required int routeId,
    required int startingCityId,
    required int destCityId,
  }) =>
      '/elevation?${_query({
        'routeId': '$routeId',
        'startingCityId': '$startingCityId',
        'destCityId': '$destCityId',
      })}';

  static String distance({
    required int routeId,
    required int destinationCityId,
  }) =>
      '/distance?${_query({
        'routeId': '$routeId',
        'destinationCityId': '$destinationCityId',
      })}';

  static String cityFullMap({
    required int routeId,
    required int cityId,
  }) =>
      '/city-full-map?${_query({
        'routeId': '$routeId',
        'cityId': '$cityId',
      })}';

  static String planDetail({
    required int planId,
    int? scrollToStageId,
  }) {
    final params = <String, String>{'planId': '$planId'};
    if (scrollToStageId != null && scrollToStageId != 0) {
      params['scrollToStageId'] = '$scrollToStageId';
    }
    return '/plan/plan-detail?${_query(params)}';
  }

  static String stageDistance({
    required int routeId,
    required int destinationCityId,
  }) =>
      '/plan/stage-distance?${_query({
        'routeId': '$routeId',
        'destinationCityId': '$destinationCityId',
      })}';

  static String stageElevation({
    required int routeId,
    required int startingCityId,
    required int destCityId,
  }) =>
      '/plan/stage-elevation?${_query({
        'routeId': '$routeId',
        'startingCityId': '$startingCityId',
        'destCityId': '$destCityId',
      })}';

  static String stageAlbergueDetails({
    required int albergueId,
    int? routeId,
    int? cityId,
    int? reviewId,
  }) {
    final params = <String, String>{'albergueId': '$albergueId'};
    if (cityId != null && cityId > 0) params['cityId'] = '$cityId';
    if (routeId != null && routeId > 0) params['routeId'] = '$routeId';
    if (reviewId != null && reviewId > 0) params['reviewId'] = '$reviewId';
    return '/plan/stage-albergue-details?${_query(params)}';
  }

  /// Matches [GoRoute] `announcements` → child `:id` in [app.dart].
  static String announcementDetail({required int id}) => '/announcements/$id';
}
