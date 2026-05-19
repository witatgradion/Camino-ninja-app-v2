import 'dart:io';
import 'dart:ui' as ui;

import 'package:camino_ninja_flutter/app/view/app.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Helper for capturing screenshots and (optionally) letting map widgets
/// register themselves.
class ImageHelper {
  static const MethodChannel _channel =
      MethodChannel('camino_ninja/screenshot');

  /// iOS: try native full-screen capture first (includes platform views).
  /// Android/others: use Flutter RepaintBoundary capture, because the native
  /// PixelCopy-based approach is unreliable on many devices (often returns
  /// blank/white frames).
  static Future<File?> captureScreenshot() async {
    try {
      if (Platform.isIOS) {
        final nativeScreenshot = await captureScreenshotNative();
        if (nativeScreenshot != null) {
          return nativeScreenshot;
        }
      }
      return await captureScreenshotFlutter();
    } catch (_) {
      return null;
    }
  }

  static Future<File?> captureScreenshotNative() async {
    try {
      final bytes = await _channel.invokeMethod<Uint8List>('captureScreen');
      if (bytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/app_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        AppLogger.d('filePath: $filePath', tag: 'ImageHelper');
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static Future<File?> captureScreenshotFlutter() async {
    try {
      // Find the RenderRepaintBoundary associated with the GlobalKey
      final boundary = appGlobalKey.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;

      // Use the device pixel ratio so the screenshot has the same sharpness
      // as what you see on screen. You can multiply this value (e.g. * 1.5)
      // for even higher-res captures at the cost of memory/CPU.
      final pixelRatio = ui.PlatformDispatcher.instance.views.isNotEmpty
          ? ui.PlatformDispatcher.instance.views.first.devicePixelRatio
          : ui.window.devicePixelRatio;

      // Capture the image from the boundary at the desired resolution
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/app_screenshot_${DateTime.now().millisecondsSinceEpoch}.png';

      // Save the image to a file
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      return file;
    } catch (_) {
      return null;
    }
  }
}
