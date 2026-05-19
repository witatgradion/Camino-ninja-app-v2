import 'package:json_annotation/json_annotation.dart';

part 'review_entity.g.dart';

@JsonSerializable()
class ReviewEntity {
  const ReviewEntity({
    required this.id,
    required this.albergueId,
    this.gRating,
    this.bReviewScore,
  });

  @JsonKey(name: 'review_id')
  final int id;
  @JsonKey(name: 'albergue_id')
  final int? albergueId;
  @JsonKey(name: 'g_rating')
  final double? gRating;
  @JsonKey(name: 'b_review_score')
  final double? bReviewScore;

  factory ReviewEntity.fromJson(Map<String, dynamic> json) =>
      _$ReviewEntityFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewEntityToJson(this);
}
