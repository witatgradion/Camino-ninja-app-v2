import 'dart:async';
import 'dart:io';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

/// A location tracker that screens can create to track location continuously.
/// Each screen should create its own instance and dispose it when done.
class LocationTracker {
  LocationTracker();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final _locationController = StreamController<Position>.broadcast();
  bool _isTracking = false;
  bool _useLowAccuracy = false;

  /// Current position (may be null if not yet obtained)
  Position? get currentPosition => _currentPosition;

  /// Stream of position updates
  Stream<Position> get locationStream => _locationController.stream;

  /// Whether tracking is currently active
  bool get isTracking => _isTracking;

  /// Starts tracking location.
  /// Permission must be granted before calling this method.
  /// Use [LocationService.checkLocationPermission()] first.
  Future<void> startTracking() async {
    if (_isTracking) return;

    try {
      // Check if we have permission
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return;
      }

      _isTracking = true;

      // Check if precise location is available
      final isPrecise = await LocationService.isPreciseLocationEnable();
      _useLowAccuracy = !isPrecise;

      // Use medium accuracy if precise not available to avoid prompts
      final accuracy =
          _useLowAccuracy ? LocationAccuracy.medium : LocationAccuracy.high;

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: Platform.isAndroid
            ? AndroidSettings(
                accuracy: accuracy,
                distanceFilter: 10,
                forceLocationManager: true,
                timeLimit: const Duration(seconds: 5),
              )
            : AppleSettings(
                accuracy: accuracy,
                distanceFilter: 10,
                timeLimit: const Duration(seconds: 5),
              ),
      ).listen(
        (Position position) {
          _currentPosition = position;
          if (!_locationController.isClosed) {
            _locationController.add(position);
          }
        },
        onError: (error) {
          // If error occurs, stop tracking
          stopTracking();
        },
      );
    } catch (e) {
      _isTracking = false;
    }
  }

  /// Stops tracking location.
  void stopTracking() {
    _isTracking = false;
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Gets the current position.
  /// If a recent position (< 10 seconds old) is available, returns it.
  /// Otherwise attempts to get a fresh position.
  Future<Position?> getCurrentPosition({
    bool locationAccuracyOff = false,
  }) async {
    // Return cached position if recent
    final now = DateTime.now();
    if (_currentPosition != null &&
        now.difference(_currentPosition!.timestamp).inSeconds < 10) {
      return _currentPosition;
    }

    final locationAccuracyDenied =
    await GetIt.instance<Repository>().getLocationAccuracyDenied();

    // Try to get a fresh position
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return _currentPosition;
      }

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

      _currentPosition = position;
      if (!_locationController.isClosed) {
        _locationController.add(position);
      }

      // Start tracking if not already started
      if (!_isTracking) {
        await startTracking();
      }

      return position;
    } on LocationServiceDisabledException {
      // Location Accuracy has been turned off
      AppLogger.w('Location services disabled', tag: 'LocationTracker');
      rethrow;

      // if (locationAccuracyOff || locationAccuracyDenied) rethrow;
      //
      // return getCurrentPosition(locationAccuracyOff: true);
    } catch (e) {
      return _currentPosition;
    }
  }

  /// Disposes resources. Must be called when done with this tracker.
  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
