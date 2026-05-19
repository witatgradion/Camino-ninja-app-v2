import 'dart:io';

import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:flutter/material.dart';

/// Helper class for calculating navigation bar heights and providing
/// consistent spacing across different screens.
class NavigationBarHelper {
  /// Base height of the navigation bar content without safe area padding
  static double baseNavigationBarHeight = Platform.isIOS ? 60.0 : 68.0;

  /// Stores the original bottom safe area padding before it gets consumed by Scaffold
  static double? _originalBottomPadding;

  /// Set the original bottom padding (should be called from root screen)
  // ignore: use_setters_to_change_properties
  static void setOriginalBottomPadding(double padding) {
    _originalBottomPadding = padding;
  }

  /// Get the original bottom safe area padding of the device
  static double getOriginalBottomPadding() {
    return _originalBottomPadding ?? 0.0;
  }

  /// Calculate the total navigation bar height including device bottom safe area
  static double getTotalNavigationBarHeight([BuildContext? context]) {
    // Use stored padding if available, otherwise try to get from context
    final bottomPadding = _originalBottomPadding ??
        (context != null ? MediaQuery.of(context).viewPadding.bottom : 0.0);
    AppLogger.d('bottomPadding: $bottomPadding', tag: 'NavigationBarHelper');
    return baseNavigationBarHeight + bottomPadding;
  }

  /// Get the device's bottom safe area padding (works even when consumed by Scaffold)
  static double getBottomSafeAreaPadding([BuildContext? context]) {
    // Return stored padding if available, otherwise try context
    return _originalBottomPadding ??
        (context != null ? MediaQuery.of(context).viewPadding.bottom : 0.0);
  }

  /// Check if the original bottom padding has been initialized
  static bool get isInitialized => _originalBottomPadding != null;
}
