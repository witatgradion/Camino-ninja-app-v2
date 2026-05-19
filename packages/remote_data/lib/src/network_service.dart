import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:remote_data/remote_data.dart';
import 'package:remote_data/src/proto/proto.dart' as proto;

enum ApiType {
  restful,
  protobuf,
}

/// NetworkService handles all API calls and returns the response as an [ApiResult].
class NetworkService {
  /// Creates a new instance of [NetworkService].
  NetworkService(Dio dio) : _apiClient = ApiClient(dio);

  final ApiClient _apiClient;

  /// Fetches all routes from the API.
  Future<ApiResult<List<RouteResponse>>> getRoutesOnly({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getRoutesOnlyProto();
        final protoResponse = proto.RouteListResponse.fromBuffer(protoBytes);
        final routes = ProtoConverter.routeListFromProto(protoResponse);
        return ApiSuccess(routes);
      }

      final response = await _apiClient.getRoutesOnly();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Fetch all route points from the API.
  Future<ApiResult<List<RoutePointResponse>>> getRoutePoints({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getRoutePointsProto();
        final protoResponse =
            proto.RoutePointsListResponse.fromBuffer(protoBytes);
        final routePoints =
            ProtoConverter.routePointListFromProto(protoResponse);
        return ApiSuccess(routePoints);
      }

      final response = await _apiClient.getRoutePoints();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Fetch all cities from the API.
  Future<ApiResult<List<CityResponse>>> getCities({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getCitiesProto();
        final protoResponse = proto.CityListResponse.fromBuffer(protoBytes);
        final cities = ProtoConverter.cityListFromProto(protoResponse);
        return ApiSuccess(cities);
      }

      final response = await _apiClient.getCities();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<Uint8List>> getRoutesOnlyProtoBytes() async {
    try {
      final list = await _apiClient.getRoutesOnlyProto();
      return ApiSuccess(Uint8List.fromList(list));
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<Uint8List>> getRoutePointsProtoBytes() async {
    try {
      final list = await _apiClient.getRoutePointsProto();
      return ApiSuccess(Uint8List.fromList(list));
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<Uint8List>> getCitiesProtoBytes() async {
    try {
      final list = await _apiClient.getCitiesProto();
      return ApiSuccess(Uint8List.fromList(list));
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<Uint8List>> getAltRoutePointsProtoBytes() async {
    try {
      final list = await _apiClient.getAltRoutePointsProto();
      return ApiSuccess(Uint8List.fromList(list));
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<Uint8List>> getAlbergueUserImagesProtoBytes() async {
    try {
      final list = await _apiClient.getAlbergueUserImagesProto();
      return ApiSuccess(Uint8List.fromList(list));
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<Uint8List>> getAlberguesProtoBytes() async {
    try {
      final list = await _apiClient.getAlberguesProto();
      return ApiSuccess(Uint8List.fromList(list));
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Fetch all albergue user images from the API.
  Future<ApiResult<List<AlbergueImageResponse>>> getAlbergueUserImages({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getAlbergueUserImagesProto();
        final protoResponse =
            proto.AlbergueUserImagesListResponse.fromBuffer(protoBytes);
        final albergueUserImages =
            ProtoConverter.albergueUserImageListFromProto(protoResponse);
        return ApiSuccess(albergueUserImages);
      }

      final response = await _apiClient.getAlbergueUserImages();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Fetches all albergues from the API.
  Future<ApiResult<List<AlbergueResponse>>> getAlbergues({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getAlberguesProto();
        final protoResponse = proto.AlbergueListResponse.fromBuffer(protoBytes);
        final albergues = ProtoConverter.albergueListFromProto(protoResponse);
        return ApiSuccess(albergues);
      }

      final response = await _apiClient.getAlbergues();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e, stackTrace) {
      AppLogger.e('Error fetching albergues',
          tag: 'NetworkService', error: e, stackTrace: stackTrace);
      return ApiFailure(e.toString());
    }
  }

  /// Fetch all alt_route_points from the API.
  Future<ApiResult<List<AltRoutePointResponse>>> getAltRoutePoints({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getAltRoutePointsProto();
        final protoResponse =
            proto.AltRoutePointsListResponse.fromBuffer(protoBytes);
        final altRoutePoints =
            ProtoConverter.altRoutePointListFromProto(protoResponse);
        return ApiSuccess(altRoutePoints);
      }

      final response = await _apiClient.getAltRoutePoints();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Upload albergue image with file id
  Future<ApiResult<dynamic>> uploadAlbergueImage({
    required int albergueId,
    required List<File> images,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _apiClient.uploadAlbergueImage(
        cancelToken,
        albergueId,
        images,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return const ApiFailure('Upload was unsuccessful due to cancellation.');
      }
      return ApiFailure(e.toString());
    } catch (e, stackTrace) {
      AppLogger.e('Error uploading albergue image',
          tag: 'NetworkService', error: e, stackTrace: stackTrace);
      return ApiFailure(e.toString());
    }
  }

  /// Get latest data update
  Future<ApiResult<LatestDataUpdateResponse>> getLatestDataUpdate({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getLatestDataUpdateProto();
        final protoResponse = proto.LatestUpdated.fromBuffer(protoBytes);
        final latestDataUpdate =
            ProtoConverter.latestDataUpdateFromProto(protoResponse);
        return ApiSuccess(latestDataUpdate);
      }

      final response = await _apiClient.getLatestDataUpdate();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Create albergue review
  Future<ApiResult<dynamic>> createAlbergueReview({
    required int albergueId,
    required String userComment,
    required int userRating,
    String? email,
    String? name,
    List<File>? images,
  }) async {
    try {
      final response = await _apiClient.createAlbergueReview(
        id: albergueId,
        images: images,
        email: email,
        name: name,
        userRating: userRating,
        userComment: userComment,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Create albergue review
  Future<ApiResult<dynamic>> createAlbergueFeedback({
    required int albergueId,
    required String feedback,
    List<File>? images,
    String? email,
    String? name,
  }) async {
    try {
      final response = await _apiClient.createAlbergueFeedback(
        id: albergueId,
        images: images,
        email: email,
        name: name,
        feedback: feedback,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Get albergue reviews
  Future<ApiResult<AlbergueReviewResponse>> getAlbergueReviews({
    required int albergueId,
    int? page,
    int? perPage,
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getAlbergueReviewsProto(
          id: albergueId,
          page: page,
          perPage: perPage,
        );
        final protoResponse =
            proto.AlbergueUserReviewsByAlbergueId.fromBuffer(protoBytes);
        final albergueReviews =
            ProtoConverter.albergueUserReviewListFromProto(protoResponse);
        return ApiSuccess(albergueReviews);
      }

      final response = await _apiClient.getAlbergueReviews(
        id: albergueId,
        page: page ?? 1,
        perPage: perPage ?? 10,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Report missing albergue
  Future<ApiResult<dynamic>> reportMissingAlbergue({
    required int cityId,
    required String reportDetails,
    List<File>? images,
    double? lon,
    double? lat,
    String? email,
    String? name,
    String? address,
  }) async {
    try {
      final response = await _apiClient.reportMissingAlbergue(
        cityId: cityId,
        images: images,
        email: email,
        name: name,
        reportDetails: reportDetails,
        lon: lon,
        lat: lat,
        address: address,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return const ApiFailure('Upload was unsuccessful due to cancellation.');
      }
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Fetch all albergues rating from the API.
  Future<ApiResult<List<AlbergueRatingResponse>>> getAllAlberguesRating({
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      if (apiType == ApiType.protobuf) {
        final protoBytes = await _apiClient.getAllAlberguesRatingProto();
        final protoResponse =
            proto.AlbergueUserRatingsListResponse.fromBuffer(protoBytes);
        final albergueRatings =
            ProtoConverter.albergueUserRatingListFromProto(protoResponse);
        return ApiSuccess(albergueRatings);
      }

      final response = await _apiClient.getAllAlberguesRating();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Report bugs
  ///
  /// [dbDump] is an optional zip archive produced by the in-app
  /// DB exporter (Phase 3a). When present, it is uploaded as the
  /// `db_dump` multipart part so the server can store it alongside
  /// the bug report for later analysis. Default is null so existing
  /// callers are unaffected.
  ///
  /// [clientContext] is an optional JSON-encoded blob describing
  /// the app/build/platform/OS/device the report originated from.
  /// When present, it is uploaded as the `client_context` multipart
  /// part so triage can correlate reports without the user filling
  /// in version fields. Default is null so existing callers are
  /// unaffected; production callers should always populate it.
  Future<ApiResult<dynamic>> createBugReport({
    required String text,
    List<File>? images,
    String? email,
    File? dbDump,
    String? clientContext,
  }) async {
    try {
      final response = await _apiClient.createBugReport(
        images: images,
        email: email,
        text: text,
        dbDump: dbDump,
        clientContext: clientContext,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return const ApiFailure('Upload was unsuccessful due to cancellation.');
      }
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<AlbergueRatingResponse>> getAlbergueRating({
    required int id,
    ApiType apiType = ApiType.protobuf,
  }) async {
    try {
      final protoBytes = await _apiClient.getAlbergueRatingProto(id: id);
      final protoResponse = proto.AlbergueUserRatings.fromBuffer(protoBytes);
      final albergueRatings =
          ProtoConverter.albergueUserRatingFromProto(protoResponse);
      return ApiSuccess(albergueRatings);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Login
  Future<ApiResult<LoginResponse>> login({
    required String token,
    required String loginType,
    String? name,
  }) async {
    try {
      final response = await _apiClient.login(
        LoginRequest(
          token: token,
          loginType: loginType,
          name: name,
        ),
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Register FCM device token for push notifications
  Future<ApiResult<void>> registerDeviceToken({
    required String deviceId,
    required String platform,
    required String token,
  }) async {
    try {
      await _apiClient.registerDeviceToken(
        DeviceTokenRequest(
          deviceId: deviceId,
          platform: platform,
          token: token,
        ),
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      AppLogger.w('Failed to register device token',
          tag: 'NetworkService');
      return ApiFailure(e.toString());
    } catch (e) {
      AppLogger.w('Failed to register device token',
          tag: 'NetworkService');
      return ApiFailure(e.toString());
    }
  }

  /// Remove FCM device token (call on logout)
  Future<ApiResult<void>> removeDeviceToken({required String token}) async {
    try {
      await _apiClient.removeDeviceToken(
        RemoveDeviceTokenRequest(token: token),
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      AppLogger.w('Failed to remove device token',
          tag: 'NetworkService');
      return ApiFailure(e.toString());
    } catch (e) {
      AppLogger.w('Failed to remove device token',
          tag: 'NetworkService');
      return ApiFailure(e.toString());
    }
  }

  /// Refresh token
  Future<ApiResult<LoginResponse>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiClient.refreshToken('Bearer $refreshToken');
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Sync stage planner data
  Future<ApiResult<SyncStagePlannerResponse>> syncStagePlanner({
    required String deviceId,
    required SyncStagePlannerRequest request,
    String? deviceName,
  }) async {
    try {
      final response = await _apiClient.syncStagePlanner(
        deviceId,
        deviceName,
        request,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Sync saved accommodations
  Future<ApiResult<SyncSavedAccommodationsResponse>> syncSavedAccommodations({
    required SyncSavedAccommodationsRequest request,
  }) async {
    try {
      final response = await _apiClient.syncSavedAccommodations(request);
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<PlanShareLinkResponse>> sharePlan({
    required String uuid,
  }) async {
    try {
      final response = await _apiClient.sharePlan(uuid);
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<SharedPlanResponse>> getSharedPlan({
    required String code,
  }) async {
    try {
      final response = await _apiClient.getSharedPlan(code);
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<dynamic>> deleteAccount() async {
    try {
      final response = await _apiClient.deleteAccount();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Fetches all announcements from the API.
  Future<ApiResult<List<AnnouncementResponse>>> getAnnouncements() async {
    try {
      final response = await _apiClient.getAnnouncements();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Fetches a single announcement by its ID.
  Future<ApiResult<AnnouncementResponse>> getAnnouncementById({
    required int id,
  }) async {
    try {
      final response = await _apiClient.getAnnouncementById(id: id);
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<UserNotificationsPageResponse>> getUserNotifications({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _apiClient.getUserNotifications(
        limit: limit,
        offset: offset,
      );
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<UserNotificationsUnreadCountResponse>>
      getUserNotificationsUnreadCount() async {
    try {
      final response = await _apiClient.getUserNotificationsUnreadCount();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<void>> markUserNotificationRead({required int id}) async {
    try {
      await _apiClient.markUserNotificationRead(id);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<void>> markAllUserNotificationsRead() async {
    try {
      await _apiClient.markAllUserNotificationsRead();
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<void>> deleteUserNotification({required int id}) async {
    try {
      await _apiClient.deleteUserNotification(id);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<UserSettingsResponse>> getUserSettings() async {
    try {
      final response = await _apiClient.getUserSettings();
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  Future<ApiResult<UserSettingsResponse>> updateUserSettings(
    UserSettingsResponse settings,
  ) async {
    try {
      final response = await _apiClient.updateUserSettings(settings);
      return ApiSuccess(response);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Get albergue reviews
  Future<ApiResult<List<AlbergueUserReviewResponse>>> getMyReviews({
    int? page,
    int? perPage,
  }) async {
    try {
      final protoBytes = await _apiClient.getMyReviewsProto(
        page: page,
        perPage: perPage,
      );
      final protoResponse =
          proto.AlbergueUserReviewsListResponse.fromBuffer(protoBytes);
      final albergueReviews =
          ProtoConverter.albergueUserReviewListFromJson(protoResponse);
      return ApiSuccess(albergueReviews);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

   /// Fetches city pairs export by start city id.
  Future<ApiResult<CityPairsForStartCityResponse>> getCityPairs({
    required int startCityId,
  }) async {
    try {
      final protoBytes = await _apiClient.getCityPairsProto(id: startCityId);
      final protoResponse = proto.CityPairsForStartCity.fromBuffer(protoBytes);
      final cityPairs =
          ProtoConverter.cityPairsForStartCityFromProto(protoResponse);
      return ApiSuccess(cityPairs);
    } on DioException catch (e) {
      return ApiFailure(e.toString());
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

// ApiResult<T> _handleDioException<T>(DioException e) {
//   switch (e.type) {
//     case DioExceptionType.connectionTimeout:
//     case DioExceptionType.sendTimeout:
//     case DioExceptionType.receiveTimeout:
//     case DioExceptionType.connectionError:
//       return NetworkFailure(e);
//     case DioExceptionType.badResponse:
//       final statusCode = e.response?.statusCode;
//       if (statusCode == 401) {
//         return const UnauthorizedFailure();
//       } else if (statusCode == 404) {
//         return const NotFoundFailure();
//       } else {
//         return ServerFailure(statusCode: statusCode);
//       }
//     case DioExceptionType.cancel:
//       return const UnknownFailure(message: 'Request was cancelled');
//     case DioExceptionType.unknown:
//     case DioExceptionType.badCertificate:
//       return const UnknownFailure();
//   }
// }
}
