// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettingsResponse _$UserSettingsResponseFromJson(
        Map<String, dynamic> json) =>
    UserSettingsResponse(
      theme: json['theme'] as String?,
      preferredLanguage: json['preferred_language'] as String?,
      distanceUnit: json['distance_unit'] as String?,
      notifyReviewReminders: json['notify_review_reminders'] as bool?,
    );

Map<String, dynamic> _$UserSettingsResponseToJson(
        UserSettingsResponse instance) =>
    <String, dynamic>{
      if (instance.theme case final value?) 'theme': value,
      if (instance.preferredLanguage case final value?)
        'preferred_language': value,
      if (instance.distanceUnit case final value?) 'distance_unit': value,
      if (instance.notifyReviewReminders case final value?)
        'notify_review_reminders': value,
    };
