import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/location_tracker.dart' show LocationTracker;
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

/// Stateless utility class for location-related operations.
/// Screens that need continuous tracking should create their own [LocationTracker].

enum NinjaLocationPermission {
  allowed,
  denied,
  deniedForever,
  gpsOff,
}

class LocationService {
  LocationService._(); // Private constructor to prevent instantiation

  /// Checks location permission and requests it if needed.
  /// Returns true if permission is granted.
  static Future<bool> checkLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<NinjaLocationPermission> getLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return NinjaLocationPermission.gpsOff;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return NinjaLocationPermission.denied;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return NinjaLocationPermission.deniedForever;
    }
    return NinjaLocationPermission.allowed;
  }

  /// Gets the current position once.
  /// Returns null if permission is not granted or if an error occurs.
  static Future<Position?> getCurrentPosition(
      {bool locationAccuracyOff = false,}) async {
    try {
      final permissionAllowed = await checkLocationPermission();
      if (!permissionAllowed) {
        return null;
      }

      final locationAccuracyDenied =
      await GetIt.instance<Repository>().getLocationAccuracyDenied();

      // Use medium accuracy by default to avoid triggering accuracy prompts
      final position = await Geolocator.getCurrentPosition(
        locationSettings: Platform.isAndroid
            ? AndroidSettings(
                accuracy: LocationAccuracy.high,
                forceLocationManager: locationAccuracyOff || locationAccuracyDenied,
                timeLimit: const Duration(seconds: 5),
              )
            : AppleSettings(
                accuracy: LocationAccuracy.high,
                timeLimit: const Duration(seconds: 5),
              ),
      );

      return position;
    } on LocationServiceDisabledException {
      // Location accuracy is turned off
      AppLogger.w('Location services disabled', tag: 'LocationService');
      rethrow;
    } catch (e) {
      return null;
    }
  }

  /// Opens the location settings page.
  static Future<void> openLocationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.location);
  }

  /// Opens the app settings page.
  static Future<void> openAppSettings() async {
    await AppSettings.openAppSettings();
  }

  /// Checks if precise location is enabled.
  /// Returns true if user has granted precise location access.
  static Future<bool> isPreciseLocationEnable() async {
    try {
      final accuracyStatus = await Geolocator.getLocationAccuracy();
      AppLogger.d('Accuracy Status: $accuracyStatus', tag: 'LocationService');
      return accuracyStatus == LocationAccuracyStatus.precise;
    } catch (e) {
      // If method not supported, assume precise is available
      return true;
    }
  }

  static Future<bool> isServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }
}
