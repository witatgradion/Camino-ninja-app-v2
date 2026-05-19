import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:remote_data/remote_data.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;

  @GET(
    '/api/v1/routes',
  )
  Future<List<RouteResponse>> getRoutesOnly();

  @GET(
    '/api/v1/route_points',
  )
  Future<List<RoutePointResponse>> getRoutePoints();

  @GET('/api/v1/cities')
  Future<List<CityResponse>> getCities();

  @GET(
    '/api/v1/albergues',
  )
  Future<List<AlbergueResponse>> getAlbergues();

  @GET('/api/v1/alt_route_points')
  Future<List<AltRoutePointResponse>> getAltRoutePoints();

  @GET('/api/v1/albergues/user_images')
  Future<List<AlbergueImageResponse>> getAlbergueUserImages();

  @PUT('/api/v1/albergues/{id}/user_images')
  @MultiPart()
  Future<dynamic> uploadAlbergueImage(
    @CancelRequest() CancelToken? cancelToken,
    @Path() int id,
    @Part(name: 'images', contentType: 'image/jpeg') List<File> files,
  );

  @PUT('/api/v1/albergues/{id}/user_reviews')
  @MultiPart()
  Future<dynamic> createAlbergueReview({
    @Path() required int id,
    @Part(name: 'user_rating') required int userRating,
    @Part(name: 'user_comment') required String userComment,
    @Part(name: 'images', contentType: 'image/jpeg') List<File>? images,
    @Part(name: 'email') String? email,
    @Part(name: 'name') String? name,
  });

  @PUT('/api/v1/albergues/{id}/user_feedbacks')
  @MultiPart()
  Future<dynamic> createAlbergueFeedback({
    @Path() required int id,
    @Part(name: 'feedback') required String feedback,
    @Part(name: 'images', contentType: 'image/jpeg') List<File>? images,
    @Part(name: 'email') String? email,
    @Part(name: 'name') String? name,
  });

  @GET('/api/v1/latest_updated')
  Future<LatestDataUpdateResponse> getLatestDataUpdate();

  @GET('/api/v1/albergues/{id}/user_reviews')
  Future<AlbergueReviewResponse> getAlbergueReviews({
    @Path() required int id,
    @Query('page') required int page,
    @Query('limit') required int perPage,
  });

  @POST('/api/v1/missing_albergues')
  @MultiPart()
  Future<dynamic> reportMissingAlbergue({
    @Part(name: 'city_id') required int cityId,
    @Part(name: 'report_details') required String reportDetails,
    @Part(name: 'images', contentType: 'image/jpeg') List<File>? images,
    @Part(name: 'lon') double? lon,
    @Part(name: 'lat') double? lat,
    @Part(name: 'email') String? email,
    @Part(name: 'name') String? name,
    @Part(name: 'address') String? address,
  });

  @GET(
    '/api/v1/albergues/user_ratings',
  )
  Future<List<AlbergueRatingResponse>> getAllAlberguesRating();

  @POST(
    '/api/v1/mobile_login',
  )
  Future<LoginResponse> login(@Body() LoginRequest request);

  @POST('/api/v1/device_tokens')
  Future<void> registerDeviceToken(@Body() DeviceTokenRequest request);

  @DELETE('/api/v1/device_tokens')
  Future<void> removeDeviceToken(@Body() RemoveDeviceTokenRequest request);

  @POST(
    '/api/v1/refresh',
  )
  Future<LoginResponse> refreshToken(
    @Header('Authorization') String authorization,
  );

  // Protobuf functions
  @GET(
    '/api/v2/routes',
  )
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getRoutesOnlyProto();

  @GET(
    '/api/v2/route_points',
  )
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getRoutePointsProto();

  @GET('/api/v2/cities')
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getCitiesProto();

  @GET(
    '/api/v2/albergues',
  )
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getAlberguesProto();

  @GET('/api/v2/alt_route_points')
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getAltRoutePointsProto();

  @GET('/api/v2/albergues/user_images')
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getAlbergueUserImagesProto();

  @GET('/api/v2/latest_updated')
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getLatestDataUpdateProto();

  @GET('/api/v2/albergues/{id}/user_reviews')
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getAlbergueReviewsProto({
    @Path() required int id,
    @Query('page') int? page,
    @Query('limit') int? perPage,
  });

  @GET(
    '/api/v2/albergues/user_ratings',
  )
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getAllAlberguesRatingProto();

  @POST('/api/v1/bug_reports')
  @MultiPart()
  Future<dynamic> createBugReport({
    @Part(name: 'text') required String text,
    @Part(name: 'images', contentType: 'image/jpeg') List<File>? images,
    @Part(name: 'email') String? email,
    @Part(name: 'db_dump', contentType: 'application/zip') File? dbDump,
    @Part(name: 'client_context', contentType: 'application/json')
    String? clientContext,
  });

  @GET(
    '/api/v2/albergues/{id}/user_ratings',
  )
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getAlbergueRatingProto({
    @Path() required int id,
  });

  @DELETE('/api/v1/users/account')
  @Headers({'Accept': 'application/json'})
  Future<dynamic> deleteAccount();

  @POST('/api/v1/stage_planner/sync')
  Future<SyncStagePlannerResponse> syncStagePlanner(
    @Header('X-Device-ID') String deviceId,
    @Header('X-Device-Name') String? deviceName,
    @Body() SyncStagePlannerRequest request,
  );

  @POST('/api/v1/saved_accommodations/sync')
  Future<SyncSavedAccommodationsResponse>
      syncSavedAccommodations(
    @Body() SyncSavedAccommodationsRequest request,
  );
  
  @POST('/api/v1/stage_planner/{uuid}/share')
  Future<PlanShareLinkResponse> sharePlan(@Path() String uuid);

  @GET('/api/v1/stage_planner/shared/{code}')
  Future<SharedPlanResponse> getSharedPlan(@Path() String code);

  @GET('/api/v1/announcements')
  Future<List<AnnouncementResponse>> getAnnouncements();

  @GET('/api/v1/announcements/{id}')
  Future<AnnouncementResponse> getAnnouncementById({
    @Path() required int id,
  });

  @GET('/api/v2/albergues/my-reviews')
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getMyReviewsProto({
    @Query('page') int? page,
    @Query('limit') int? perPage,
  });

  @GET('/api/v1/user_notifications')
  Future<UserNotificationsPageResponse> getUserNotifications({
    @Query('limit') int? limit,
    @Query('offset') int? offset,
  });

  @GET('/api/v1/user_notifications/unread_count')
  Future<UserNotificationsUnreadCountResponse>
      getUserNotificationsUnreadCount();

  @PUT('/api/v1/user_notifications/{id}/read')
  Future<void> markUserNotificationRead(@Path('id') int id);

  @PUT('/api/v1/user_notifications/read_all')
  Future<void> markAllUserNotificationsRead();

  @DELETE('/api/v1/user_notifications/{id}')
  Future<void> deleteUserNotification(@Path('id') int id);

  @GET('/api/v1/users/me')
  Future<UserSettingsResponse> getUserSettings();

  @PUT('/api/v1/users/me')
  Future<UserSettingsResponse> updateUserSettings(
    @Body() UserSettingsResponse settings,
  );

  @GET(
    '/api/v2/city_pairs/start/{id}',
  )
  @DioResponseType(ResponseType.bytes)
  @Headers({'Accept': 'application/x-protobuf'})
  Future<List<int>> getCityPairsProto({
    @Path() required int id,
  });
}
