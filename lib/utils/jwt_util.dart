import 'dart:convert';

import 'package:camino_ninja_flutter/utils/app_logger.dart';

class JwtUtil {
  /// Extract expiration time from JWT token
  static DateTime? getTokenExpiration(String token) {
    try {
      // JWT has 3 parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      final payload = parts[1];

      // Add padding if needed for base64 decoding
      final paddedPayload = _addPadding(payload);

      // Decode base64
      final decodedBytes = base64Url.decode(paddedPayload);
      final decodedString = utf8.decode(decodedBytes);

      // Parse JSON
      final dynamic decodedJson = json.decode(decodedString);
      final payloadMap = Map<String, dynamic>.from(decodedJson as Map);

      // Extract expiration time
      final exp = payloadMap['exp'];
      if (exp is int) {
        // Convert Unix timestamp to DateTime
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }

      return null;
    } catch (e) {
      AppLogger.e('Error extracting token expiration', error: e);
      return null;
    }
  }

  /// Add padding to base64 string if needed
  static String _addPadding(String base64String) {
    final remainder = base64String.length % 4;
    if (remainder == 0) return base64String;

    final padding = 4 - remainder;
    return base64String + '=' * padding;
  }
}
