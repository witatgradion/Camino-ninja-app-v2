import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plan_share_link_response.g.dart';

@JsonSerializable()
class PlanShareLinkResponse extends Equatable {
  const PlanShareLinkResponse({
    required this.createdAt,
    required this.shortCode,
    required this.shortUrl,
  });

  factory PlanShareLinkResponse.fromJson(Map<String, dynamic> json) =>
      _$PlanShareLinkResponseFromJson(json);

  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'short_code')
  final String shortCode;
  @JsonKey(name: 'short_url')
  final String shortUrl;

  Map<String, dynamic> toJson() => _$PlanShareLinkResponseToJson(this);

  @override
  List<Object?> get props => [createdAt, shortCode, shortUrl];
}
