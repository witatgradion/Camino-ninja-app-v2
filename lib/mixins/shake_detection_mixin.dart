import 'dart:async';
import 'dart:math';

import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A mixin that provides shake detection functionality.
///
/// Usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   // ...
/// }
///
/// class _MyWidgetState extends State<MyWidget> with ShakeDetectionMixin {
///   @override
///   void onShakeDetected() {
///     // Handle shake event
///     print('Shake detected!');
///   }
///
///   @override
///   void initState() {
///     super.initState();
///     startShakeDetection();
///   }
///
///   @override
///   void dispose() {
///     stopShakeDetection();
///     super.dispose();
///   }
/// }
/// ```
mixin ShakeDetectionMixin<T extends StatefulWidget> on State<T> {
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  bool _isShaking = false;
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  DateTime _lastShakeTime = DateTime(0);

  /// Threshold for detecting shake (m/s²)
  /// Override this getter to customize sensitivity
  double get shakeThreshold => 50;

  /// Minimum time between shake detections (milliseconds)
  /// Override this getter to customize timing
  int get shakeResetTimeMs => 1000;

  /// Sampling period for accelerometer
  /// Override this getter to customize sensitivity
  Duration get samplingPeriod => SensorInterval.gameInterval;

  /// Called when a shake is detected
  /// Override this method to handle shake events
  void onShakeDetected();

  /// Optional callback for when shaking starts
  /// Override this method if you need to handle shake start
  void onShakeStarted() {}

  /// Optional callback for when shaking stops
  /// Override this method if you need to handle shake stop
  void onShakeStopped() {}

  /// Optional callback for shake detection errors
  /// Override this method to handle sensor errors
  void onShakeDetectionError(Object error) {
    AppLogger.e('Shake detection error', tag: 'ShakeDetection', error: error);
  }

  /// Start listening for shake gestures
  void startShakeDetection() {
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: samplingPeriod,
    ).listen(
      _handleAccelerometerEvent,
      onError: (Object error) {
        onShakeDetectionError(error);
      },
      cancelOnError: false,
    );
  }

  /// Stop listening for shake gestures
  void stopShakeDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _resetShakeState();
  }

  /// Check if shake detection is currently active
  bool get isShakeDetectionActive => _accelerometerSubscription != null;

  /// Reset the shake detection state
  void _resetShakeState() {
    _isShaking = false;
    _lastX = 0;
    _lastY = 0;
    _lastZ = 0;
    _lastShakeTime = DateTime(0);
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    final now = DateTime.now();

    // Calculate the difference from the last reading
    final deltaX = (event.x - _lastX).abs();
    final deltaY = (event.y - _lastY).abs();
    final deltaZ = (event.z - _lastZ).abs();

    // Calculate the acceleration change magnitude (without gravity)
    final acceleration =
        sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);

    // Update last values
    _lastX = event.x;
    _lastY = event.y;
    _lastZ = event.z;

    // Check if shake threshold is exceeded and enough time has passed since last shake
    if (acceleration > shakeThreshold &&
        now.difference(_lastShakeTime).inMilliseconds > shakeResetTimeMs) {
      if (!_isShaking) {
        _isShaking = true;
        _lastShakeTime = now;

        // Trigger callbacks
        onShakeStarted();
        onShakeDetected();
      }
    } else if (_isShaking && acceleration < shakeThreshold * 0.5) {
      // Reset shake state when movement calms down
      _isShaking = false;
      onShakeStopped();
    }
  }
}
