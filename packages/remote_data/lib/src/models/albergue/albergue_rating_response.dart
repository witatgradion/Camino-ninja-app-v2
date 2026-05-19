import 'package:json_annotation/json_annotation.dart';

part 'albergue_rating_response.g.dart';

@JsonSerializable()
class AlbergueRatingResponse {
  const AlbergueRatingResponse({
    required this.albergueId,
    required this.rating,
    required this.totalApprovedReviews,
  });

  factory AlbergueRatingResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueRatingResponseFromJson(json);

  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'rating')
  final double? rating;
  @JsonKey(name: 'total_approved_reviews')
  final int? totalApprovedReviews;

  Map<String, dynamic> toJson() => _$AlbergueRatingResponseToJson(this);
}
