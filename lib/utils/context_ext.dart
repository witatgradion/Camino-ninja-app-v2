import 'dart:io';

import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  /// Returns true if current theme is dark.
  /// Uses Theme.of(context) which subscribes to theme changes,
  /// ensuring widgets rebuild when theme changes.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  double getBottomPadding(BuildContext context, {double additionalPadding = 0}) {
    final mq = MediaQuery.of(context);
    if (mq.viewInsets.bottom > 0) return mq.viewInsets.bottom;

    if (Platform.isAndroid) return mq.viewPadding.bottom + additionalPadding;

    return mq.viewPadding.bottom;
  }
}
