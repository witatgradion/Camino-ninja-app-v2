part of 'repository.dart';

/// User action operations for Repository (reviews, feedback, reports)
extension RepositoryUserActions on Repository {
  /// Upload albergue images
  Future<ApiResult<dynamic>> uploadAlbergueImage({
    required List<File> images,
    required int albergueId,
    CancelToken? cancelToken,
  }) async {
    final uploadAlbergueImageResult = await _networkService.uploadAlbergueImage(
      albergueId: albergueId,
      images: images,
      cancelToken: cancelToken,
    );
    switch (uploadAlbergueImageResult) {
      case ApiSuccess(data: final response):
        return ApiSuccess(response);
      case ApiFailure(message: final errorMessage):
        return ApiFailure(errorMessage);
    }
  }

  /// Create albergue review
  Future<dynamic> createAlbergueReview({
    required String comment,
    required int rating,
    required int albergueId,
    String? email,
    String? name,
    List<File>? images,
  }) async {
    final uploadAlbergueReviewResult =
        await _networkService.createAlbergueReview(
      albergueId: albergueId,
      userRating: rating,
      userComment: comment,
      images: images,
      email: email,
      name: name,
    );
    switch (uploadAlbergueReviewResult) {
      case ApiSuccess(data: final response):
        return response;
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Create albergue feedback
  Future<dynamic> createAlbergueFeedback({
    required String feedback,
    required int albergueId,
    String? email,
    String? name,
    List<File>? images,
  }) async {
    final uploadAlbergueReviewResult =
        await _networkService.createAlbergueFeedback(
      albergueId: albergueId,
      feedback: feedback,
      images: images,
      email: email,
      name: name,
    );
    switch (uploadAlbergueReviewResult) {
      case ApiSuccess(data: final response):
        return response;
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Get albergue reviews with pagination
  Future<AlbergueReviewListModel> getAlbergueReviews({
    required int albergueId,
    int? page,
    int? perPage,
  }) async {
    final result = await _networkService.getAlbergueReviews(
      albergueId: albergueId,
      page: page,
      perPage: perPage,
    );
    switch (result) {
      case ApiSuccess(data: final response):
        return AlbergueReviewListModel(
          total: response.total,
          albergueUserReviews: response.albergueUserReviews
              ?.map(
                (e) => AlbergueReviewModel(
                  id: e.id,
                  albergueId: e.albergueId,
                  name: e.name,
                  email: e.email,
                  userComment: e.userComment,
                  userRating: e.userRating,
                  createdAt: e.createdAt,
                  updatedAt: e.updatedAt,
                  images: e.images
                      ?.map(
                        (img) => AlbergueImageReviewModel(
                          id: img.id,
                          fileKey: img.fileKey,
                          createdAt: img.createdAt,
                          updatedAt: img.updatedAt,
                        ),
                      )
                      .toList(),
                  translatedComment: e.translatedComment,
                  displayLang: e.displayLang,
                  sourceLang: e.sourceLang,
                  isTranslated: e.isTranslated,
                ),
              )
              .toList(),
        );
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Report missing albergue
  Future<dynamic> reportMissingAlbergue({
    required String reportDetails,
    required int cityId,
    double? lon,
    double? lat,
    String? email,
    String? name,
    String? address,
    List<File>? images,
  }) async {
    final uploadAlbergueReviewResult =
        await _networkService.reportMissingAlbergue(
      cityId: cityId,
      reportDetails: reportDetails,
      images: images,
      lon: lon,
      lat: lat,
      email: email,
      name: name,
      address: address,
    );
    switch (uploadAlbergueReviewResult) {
      case ApiSuccess(data: final response):
        return response;
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Create bug report
  ///
  /// [dbDump] is an optional anonymized DB export (zip) attached
  /// to the bug report as a multipart part. Default null preserves
  /// the prior call-site contract.
  ///
  /// [clientContext] is an optional JSON-encoded blob with
  /// app/build/platform/OS/device fields (see `ClientContext`).
  /// Forwarded as the `client_context` multipart part. Default null
  /// preserves the prior call-site contract.
  Future<dynamic> createBugReport({
    required String text,
    String? email,
    List<File>? images,
    File? dbDump,
    String? clientContext,
  }) async {
    final uploadAlbergueReviewResult = await _networkService.createBugReport(
      text: text,
      images: images,
      email: email,
      dbDump: dbDump,
      clientContext: clientContext,
    );
    switch (uploadAlbergueReviewResult) {
      case ApiSuccess(data: final response):
        return response;
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  Future<void> deleteAccount() async {
    final deleteAccountResult = await _networkService.deleteAccount();
    switch (deleteAccountResult) {
      case ApiSuccess(data: final _):
        return;
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }

  /// Get albergue reviews with pagination
  Future<List<AlbergueReviewModel>> getMyReviews({
    int? page,
    int? perPage,
  }) async {
    final result = await _networkService.getMyReviews(
      page: page,
      perPage: perPage,
    );
    switch (result) {
      case ApiSuccess(data: final response):
        return response
            .map(
              (e) => AlbergueReviewModel(
                id: e.id,
                status: e.status,
                albergueId: e.albergueId,
                name: e.name,
                email: e.email,
                userComment: e.userComment,
                userRating: e.userRating,
                createdAt: e.createdAt,
                updatedAt: e.updatedAt,
                images: e.images
                    ?.map(
                      (img) => AlbergueImageReviewModel(
                        id: img.id,
                        fileKey: img.fileKey,
                        createdAt: img.createdAt,
                        updatedAt: img.updatedAt,
                      ),
                    )
                    .toList(),
                translatedComment: e.translatedComment,
                displayLang: e.displayLang,
                sourceLang: e.sourceLang,
                isTranslated: e.isTranslated,
              ),
            )
            .toList();
      case ApiFailure(message: final errorMessage):
        throw Exception(errorMessage);
    }
  }
}
