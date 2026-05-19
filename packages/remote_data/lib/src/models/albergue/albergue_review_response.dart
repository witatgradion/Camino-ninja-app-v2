import 'package:json_annotation/json_annotation.dart';

part 'albergue_review_response.g.dart';

@JsonSerializable()
class AlbergueReviewResponse {
  AlbergueReviewResponse({
    this.total = 0,
    this.albergueUserReviews = const [],
  });

  factory AlbergueReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueReviewResponseFromJson(json);
  @JsonKey(name: 'total')
  final int? total;
  @JsonKey(name: 'albergue_user_reviews')
  final List<AlbergueUserReviewResponse>? albergueUserReviews;

  Map<String, dynamic> toJson() => _$AlbergueReviewResponseToJson(this);
}

@JsonSerializable()
class AlbergueUserReviewResponse {
  AlbergueUserReviewResponse({
    this.id,
    this.albergueId,
    this.name,
    this.email,
    this.userComment,
    this.userRating,
    this.createdAt,
    this.updatedAt,
    this.images,
    this.translatedComment,
    this.displayLang,
    this.sourceLang,
    this.isTranslated,
    this.status,
  });

  factory AlbergueUserReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueUserReviewResponseFromJson(json);
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'name')
  final String? name;
  @JsonKey(name: 'email')
  final String? email;
  @JsonKey(name: 'user_comment')
  final String? userComment;
  @JsonKey(name: 'user_rating')
  final int? userRating;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'images')
  final List<AlbergueImageReviewResponse>? images;
  @JsonKey(name: 'translated_comment')
  final String? translatedComment;
  @JsonKey(name: 'display_lang')
  final String? displayLang;
  @JsonKey(name: 'source_lang')
  final String? sourceLang;
  @JsonKey(name: 'is_translated')
  final bool? isTranslated;
  @JsonKey(name: 'status')
  final bool? status;

  Map<String, dynamic> toJson() => _$AlbergueUserReviewResponseToJson(this);
}

@JsonSerializable()
class AlbergueImageReviewResponse {
  AlbergueImageReviewResponse({
    this.id,
    this.albergueUserReviewsId,
    this.fileKey,
    this.createdAt,
    this.updatedAt,
  });

  factory AlbergueImageReviewResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueImageReviewResponseFromJson(json);
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'albergue_user_reviews_id')
  final int? albergueUserReviewsId;
  @JsonKey(name: 'file_key')
  final String? fileKey;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => _$AlbergueImageReviewResponseToJson(this);
}
