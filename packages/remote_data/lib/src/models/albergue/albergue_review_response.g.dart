// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_review_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueReviewResponse _$AlbergueReviewResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueReviewResponse(
      total: (json['total'] as num?)?.toInt() ?? 0,
      albergueUserReviews: (json['albergue_user_reviews'] as List<dynamic>?)
              ?.map((e) => AlbergueUserReviewResponse.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$AlbergueReviewResponseToJson(
        AlbergueReviewResponse instance) =>
    <String, dynamic>{
      'total': instance.total,
      'albergue_user_reviews': instance.albergueUserReviews,
    };

AlbergueUserReviewResponse _$AlbergueUserReviewResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueUserReviewResponse(
      id: (json['id'] as num?)?.toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      userComment: json['user_comment'] as String?,
      userRating: (json['user_rating'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) =>
              AlbergueImageReviewResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      translatedComment: json['translated_comment'] as String?,
      displayLang: json['display_lang'] as String?,
      sourceLang: json['source_lang'] as String?,
      isTranslated: json['is_translated'] as bool?,
      status: json['status'] as bool?,
    );

Map<String, dynamic> _$AlbergueUserReviewResponseToJson(
        AlbergueUserReviewResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_id': instance.albergueId,
      'name': instance.name,
      'email': instance.email,
      'user_comment': instance.userComment,
      'user_rating': instance.userRating,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'images': instance.images,
      'translated_comment': instance.translatedComment,
      'display_lang': instance.displayLang,
      'source_lang': instance.sourceLang,
      'is_translated': instance.isTranslated,
      'status': instance.status,
    };

AlbergueImageReviewResponse _$AlbergueImageReviewResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueImageReviewResponse(
      id: (json['id'] as num?)?.toInt(),
      albergueUserReviewsId:
          (json['albergue_user_reviews_id'] as num?)?.toInt(),
      fileKey: json['file_key'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AlbergueImageReviewResponseToJson(
        AlbergueImageReviewResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'albergue_user_reviews_id': instance.albergueUserReviewsId,
      'file_key': instance.fileKey,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
