import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_settings_response.g.dart';

@JsonSerializable(includeIfNull: false)
class UserSettingsResponse extends Equatable {
  const UserSettingsResponse({
    this.theme,
    this.preferredLanguage,
    this.distanceUnit,
    this.notifyReviewReminders,
  });

  factory UserSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsResponseFromJson(json);

  final String? theme;
  @JsonKey(name: 'preferred_language')
  final String? preferredLanguage;
  @JsonKey(name: 'distance_unit')
  final String? distanceUnit;
  @JsonKey(name: 'notify_review_reminders')
  final bool? notifyReviewReminders;

  Map<String, dynamic> toJson() => _$UserSettingsResponseToJson(this);

  UserSettingsResponse copyWith({
    String? theme,
    String? preferredLanguage,
    String? distanceUnit,
    bool? notifyReviewReminders,
  }) {
    return UserSettingsResponse(
      theme: theme ?? this.theme,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      notifyReviewReminders:
          notifyReviewReminders ?? this.notifyReviewReminders,
    );
  }

  @override
  List<Object?> get props => [
        theme,
        preferredLanguage,
        distanceUnit,
        notifyReviewReminders,
      ];
}
