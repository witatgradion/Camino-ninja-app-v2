import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/widgets/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:storage/storage.dart';

class AlbergueClusterItem {
  AlbergueClusterItem({required this.albergue}) {
    // Validate coordinates during construction
    if (albergue.latitude == null || albergue.longitude == null) {
      throw ArgumentError(
        'AlbergueClusterItem requires valid latitude and '
        'longitude. Albergue ${albergue.id} '
        '(${albergue.name}) has null coordinates: '
        'lat=${albergue.latitude}, lng=${albergue.longitude}',
      );
    }

    // Validate coordinate ranges
    if (albergue.latitude! < -90 || albergue.latitude! > 90) {
      throw ArgumentError(
        'Invalid latitude ${albergue.latitude} for albergue '
        '${albergue.id} (${albergue.name}). '
        'Must be between -90 and 90.',
      );
    }

    if (albergue.longitude! < -180 ||
        albergue.longitude! > 180) {
      throw ArgumentError(
        'Invalid longitude ${albergue.longitude} for '
        'albergue ${albergue.id} (${albergue.name}). '
        'Must be between -180 and 180.',
      );
    }
    _location = LatLng(albergue.latitude!, albergue.longitude!);
  }

  final AlbergueEntity albergue;
  late final LatLng _location;

  LatLng get location => _location;

  @override
  String toString() =>
      'AlbergueClusterItem(${albergue.id}: '
      '${albergue.name} at $location)';
}

class AlbergueMarkerHelper {
  // Memory management constants
  static const int _maxBitmapWidth = 400;
  static const int _maxBitmapHeight = 200;
  static const int _maxBitmapSizeBytes = 1024 * 1024;
  static const double _maxPixelRatio = 2;

  // Cache for bitmap bytes to avoid recreation
  static final Map<String, Uint8List> _bitmapCache = {};
  static const int _maxCacheSize = 100;

  // Track memory usage
  static int _currentCacheMemoryBytes = 0;
  static const int _maxCacheMemoryBytes = 10 * 1024 * 1024;

  static Future<Uint8List> createAlbergueImage({
    required AlbergueEntity albergue,
    required bool isDark,
    required bool isFullScreen,
  }) async {
    return _createMarkerBitmap(albergue, isDark, isFullScreen);
  }

  static Future<Uint8List> _createMarkerBitmap(
    AlbergueEntity albergue,
    bool isDark,
    bool isFullScreen,
  ) async {
    // Create cache key
    final cacheKey =
        'marker_${albergue.id}_${isDark}_$isFullScreen';

    // Return cached bitmap if available
    if (_bitmapCache.containsKey(cacheKey)) {
      return _bitmapCache[cacheKey]!;
    }

    // Check cache memory limits
    if (_currentCacheMemoryBytes > _maxCacheMemoryBytes ||
        _bitmapCache.length > _maxCacheSize) {
      _clearBitmapCache();
    }

    BuildOwner? buildOwner;
    PipelineOwner? pipelineOwner;

    try {
      final widget = OptimizedCustomMarkerWidget(
        isDark: isDark,
        albergue: albergue,
        isFullScreen: isFullScreen,
      );

      final repaintBoundary = RenderRepaintBoundary();

      final renderView = RenderView(
        view: WidgetsBinding
            .instance.platformDispatcher.views.first,
        child: RenderPositionedBox(
          child: repaintBoundary,
        ),
        configuration: ViewConfiguration.fromView(
          WidgetsBinding
              .instance.platformDispatcher.views.first,
        ),
      );

      pipelineOwner = PipelineOwner();
      buildOwner = BuildOwner(focusManager: FocusManager());

      pipelineOwner.rootNode = renderView;
      renderView.prepareInitialFrame();

      final rootElement =
          RenderObjectToWidgetAdapter<RenderBox>(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            type: MaterialType.transparency,
            child: widget,
          ),
        ),
      ).attachToRenderTree(buildOwner);

      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      // Validate dimensions and apply limits
      final size = repaintBoundary.size;
      if (size.width <= 0 || size.height <= 0) {
        throw Exception(
          'Invalid marker dimensions: '
          '${size.width}x${size.height}',
        );
      }

      // Apply size limits to prevent memory issues
      final constrainedWidth =
          size.width.clamp(1.0, _maxBitmapWidth.toDouble());
      final constrainedHeight =
          size.height.clamp(1.0, _maxBitmapHeight.toDouble());

      // Calculate safe pixel ratio based on size
      final pixelRatio = _calculateSafePixelRatio(
        constrainedWidth,
        constrainedHeight,
      );

      // Wait for any pending operations to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Create image with memory safety
      final image =
          await repaintBoundary.toImage(pixelRatio: pixelRatio);

      // Validate image size before proceeding
      final expectedSizeBytes = (constrainedWidth *
              constrainedHeight *
              pixelRatio *
              pixelRatio *
              4)
          .toInt();
      if (expectedSizeBytes > _maxBitmapSizeBytes) {
        throw Exception(
          'Bitmap size exceeds memory limit: '
          '$expectedSizeBytes bytes > '
          '$_maxBitmapSizeBytes bytes',
        );
      }

      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception(
          'Failed to convert image to byte data',
        );
      }

      final uint8List = byteData.buffer.asUint8List();

      // Validate actual byte size
      if (uint8List.length > _maxBitmapSizeBytes) {
        throw Exception(
          'Generated bitmap exceeds memory limit: '
          '${uint8List.length} bytes',
        );
      }

      // Cache the result with memory tracking
      _bitmapCache[cacheKey] = uint8List;
      _currentCacheMemoryBytes += uint8List.length;

      return uint8List;
    } catch (e) {
      // Log error for debugging but don't crash the app
      AppLogger.e(
        'Error creating marker bitmap',
        tag: 'AlbergueMarkerHelper',
        error: e,
      );

      // Return empty marker as fallback
      return Uint8List(0);
    } finally {
      // Clean up resources
      try {
        buildOwner?.finalizeTree();
        pipelineOwner?.rootNode = null;
      } catch (e) {
        AppLogger.e(
          'Error disposing marker bitmap resources',
          tag: 'AlbergueMarkerHelper',
          error: e,
        );
      }
    }
  }

  /// Calculate safe pixel ratio based on widget size to
  /// prevent memory issues
  static double _calculateSafePixelRatio(
    double width,
    double height,
  ) {
    final maxPixels =
        width * height * _maxPixelRatio * _maxPixelRatio;
    const maxAllowedPixels = _maxBitmapSizeBytes / 4;

    if (maxPixels > maxAllowedPixels) {
      final safePixelRatio =
          math.sqrt(maxAllowedPixels / (width * height));
      return safePixelRatio.clamp(1.0, _maxPixelRatio);
    }

    return _maxPixelRatio;
  }

  /// Clear bitmap cache to free memory
  static void _clearBitmapCache() {
    _bitmapCache.clear();
    _currentCacheMemoryBytes = 0;
    AppLogger.d(
      'Bitmap cache cleared to free memory',
      tag: 'AlbergueMarkerHelper',
    );
  }

  /// Public method to clear cache when needed
  static void clearCache() {
    _clearBitmapCache();
  }

  /// Get current cache statistics for debugging
  static Map<String, dynamic> getCacheStats() {
    return {
      'cached_items': _bitmapCache.length,
      'memory_bytes': _currentCacheMemoryBytes,
      'memory_mb':
          (_currentCacheMemoryBytes / (1024 * 1024))
              .toStringAsFixed(2),
    };
  }
}

class OptimizedCustomMarkerWidget extends StatelessWidget {
  const OptimizedCustomMarkerWidget({
    required this.albergue,
    required this.isFullScreen,
    super.key,
    this.isDark = false,
  });
  final AlbergueEntity albergue;
  final bool isDark;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    var rating = albergue.reviews.firstOrNull?.bReviewScore;
    if (rating != null && rating > 0) {
      rating = (rating / 10) * 5;
    } else {
      rating = albergue.ninjaRating;
    }

    if (!isFullScreen) {
      // Simple icon-only marker for non-fullscreen
      return SizedBox(
        width: 48,
        height: 48,
        child: SvgPicture.asset(
          'assets/ic_albergue_marker.svg',
          width: 48,
          height: 48,
        ),
      );
    }

    return SizedBox(
      width: 220,
      height: 80,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SvgPicture.asset(
            'assets/ic_albergue_marker.svg',
            width: 48,
            height: 48,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    albergue.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Visibility(
                    visible: rating != null,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 120,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF5D553D)
                            : const Color(0xFFFFF6DD),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: CustomRatingBar(
                        isDark: isDark,
                        initialRating: rating ?? 0,
                        allowHalfRating: true,
                        enable: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
