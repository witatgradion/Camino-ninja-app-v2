// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewEntity _$ReviewEntityFromJson(Map<String, dynamic> json) => ReviewEntity(
      id: (json['review_id'] as num).toInt(),
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      gRating: (json['g_rating'] as num?)?.toDouble(),
      bReviewScore: (json['b_review_score'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReviewEntityToJson(ReviewEntity instance) =>
    <String, dynamic>{
      'review_id': instance.id,
      'albergue_id': instance.albergueId,
      'g_rating': instance.gRating,
      'b_review_score': instance.bReviewScore,
    };
