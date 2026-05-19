// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albergue_rating_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbergueRatingResponse _$AlbergueRatingResponseFromJson(
        Map<String, dynamic> json) =>
    AlbergueRatingResponse(
      albergueId: (json['albergue_id'] as num?)?.toInt(),
      rating: (json['rating'] as num?)?.toDouble(),
      totalApprovedReviews: (json['total_approved_reviews'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AlbergueRatingResponseToJson(
        AlbergueRatingResponse instance) =>
    <String, dynamic>{
      'albergue_id': instance.albergueId,
      'rating': instance.rating,
      'total_approved_reviews': instance.totalApprovedReviews,
    };
