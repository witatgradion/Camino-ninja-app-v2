import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageConverter {
  // Memory safety constants
  static const int _maxFileSizeBytes = 50 * 1024 * 1024; // 50MB max file size
  static const int _maxImageDimension = 4096; // Max width/height (4K)
  static const int _maxPixels = 16 * 1024 * 1024; // 16MP max (4096x4096)
  static const int _maxMemoryUsageBytes = 100 * 1024 * 1024; // 100MB max memory
  static const int _defaultMaxWidth = 2048; // Default max width
  static const int _defaultMaxHeight = 2048; // Default max height
  static const int _minQuality = 50; // Minimum JPEG quality
  static const int _maxQuality = 95; // Maximum JPEG quality

  /// Checks if the file is a HEIC/HEIF image
  static bool isHeicImage(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return extension == '.heic' || extension == '.heif';
  }

  /// Validates file size before processing
  static Future<bool> _validateFileSize(XFile pickedImage) async {
    try {
      final fileSize = await pickedImage.length();
      if (fileSize > _maxFileSizeBytes) {
        AppLogger.w(
          'Image file too large: $fileSize bytes > $_maxFileSizeBytes bytes',
          tag: 'ImageConverter',
        );
        return false;
      }
      return true;
    } catch (e) {
      AppLogger.e('Error checking file size', tag: 'ImageConverter', error: e);
      return false;
    }
  }

  /// Estimates memory usage for an image
  static int _estimateMemoryUsage(int width, int height) {
    // RGBA = 4 bytes per pixel, plus some overhead for processing
    return width * height * 4 * 2; // 2x factor for processing overhead
  }

  /// Calculates safe dimensions to prevent memory issues
  static Map<String, int> _calculateSafeDimensions(
    int originalWidth,
    int originalHeight,
    int? maxWidth,
    int? maxHeight,
  ) {
    // Apply absolute maximum limits first
    var safeWidth = math.min(originalWidth, _maxImageDimension);
    var safeHeight = math.min(originalHeight, _maxImageDimension);

    // Check total pixels limit
    if (safeWidth * safeHeight > _maxPixels) {
      final scaleFactor = math.sqrt(_maxPixels / (safeWidth * safeHeight));
      safeWidth = (safeWidth * scaleFactor).round();
      safeHeight = (safeHeight * scaleFactor).round();
    }

    // Apply user-specified limits
    if (maxWidth != null && safeWidth > maxWidth) {
      final aspectRatio = safeHeight / safeWidth;
      safeWidth = maxWidth;
      safeHeight = (maxWidth * aspectRatio).round();
    }

    if (maxHeight != null && safeHeight > maxHeight) {
      final aspectRatio = safeWidth / safeHeight;
      safeHeight = maxHeight;
      safeWidth = (maxHeight * aspectRatio).round();
    }

    // Ensure minimum dimensions
    safeWidth = math.max(safeWidth, 1);
    safeHeight = math.max(safeHeight, 1);

    return {
      'width': safeWidth,
      'height': safeHeight,
    };
  }

  /// Progressive resize for very large images to save memory
  static img.Image _progressiveResize(
    img.Image originalImage,
    int targetWidth,
    int targetHeight,
  ) {
    var currentImage = originalImage;
    var currentWidth = originalImage.width;
    var currentHeight = originalImage.height;

    // If the reduction is more than 50%, do it in steps to save memory
    while (currentWidth > targetWidth * 2 || currentHeight > targetHeight * 2) {
      currentWidth = (currentWidth * 0.7).round();
      currentHeight = (currentHeight * 0.7).round();
      
      // Ensure we don't go below target
      currentWidth = math.max(currentWidth, targetWidth);
      currentHeight = math.max(currentHeight, targetHeight);
      
      currentImage = img.copyResize(
        currentImage,
        width: currentWidth,
        height: currentHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    // Final resize to exact target
    if (currentWidth != targetWidth || currentHeight != targetHeight) {
      currentImage = img.copyResize(
        currentImage,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );
    }

    return currentImage;
  }

  /// Converts picked image to JPEG format with comprehensive memory management
  static Future<File> convertToJpeg(
    XFile pickedImage, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
    bool maintainAspectRatio = true,
  }) async {
    // Validate input parameters
    quality = quality.clamp(_minQuality, _maxQuality);
    
    // Set default max dimensions if not provided
    maxWidth ??= _defaultMaxWidth;
    maxHeight ??= _defaultMaxHeight;

    try {
      // Step 1: Validate file size before reading
      if (!await _validateFileSize(pickedImage)) {
        throw Exception('Image file size exceeds maximum allowed size of ${_maxFileSizeBytes ~/ (1024 * 1024)}MB');
      }

      // Step 2: Read image bytes with memory monitoring
      Uint8List? imageBytes;
      try {
        imageBytes = await pickedImage.readAsBytes();
      } catch (e) {
        throw Exception('Failed to read image file: $e');
      }

      if (imageBytes.isEmpty) {
        throw Exception('Image file is empty');
      }

      // Step 3: Decode image with error handling
      img.Image? originalImage;
      try {
        originalImage = img.decodeImage(imageBytes);
      } catch (e) {
        throw Exception('Failed to decode image format: $e');
      }

      if (originalImage == null) {
        throw Exception('Unsupported image format or corrupted file');
      }

      // Step 4: Validate image dimensions
      if (originalImage.width <= 0 || originalImage.height <= 0) {
        throw Exception('Invalid image dimensions: ${originalImage.width}x${originalImage.height}');
      }

      AppLogger.d(
        'Original image: ${originalImage.width}x${originalImage.height}',
        tag: 'ImageConverter',
      );

      // Step 5: Calculate safe dimensions
      final safeDimensions = _calculateSafeDimensions(
        originalImage.width,
        originalImage.height,
        maxWidth,
        maxHeight,
      );

      final targetWidth = safeDimensions['width']!;
      final targetHeight = safeDimensions['height']!;

      AppLogger.d(
        'Target dimensions: ${targetWidth}x$targetHeight',
        tag: 'ImageConverter',
      );

      // Step 6: Validate memory usage
      final estimatedMemory = _estimateMemoryUsage(targetWidth, targetHeight);
      if (estimatedMemory > _maxMemoryUsageBytes) {
        throw Exception('Image processing would exceed memory limit: ${estimatedMemory ~/ (1024 * 1024)}MB > ${_maxMemoryUsageBytes ~/ (1024 * 1024)}MB');
      }

      // Step 7: Process image with memory-safe resizing
      img.Image processedImage;
      
      if (originalImage.width != targetWidth || originalImage.height != targetHeight) {
        // Use progressive resize for large images
        if (originalImage.width > targetWidth * 2 || originalImage.height > targetHeight * 2) {
          processedImage = _progressiveResize(originalImage, targetWidth, targetHeight);
        } else {
          processedImage = img.copyResize(
            originalImage,
            width: targetWidth,
            height: targetHeight,
            interpolation: img.Interpolation.linear,
          );
        }
      } else {
        processedImage = originalImage;
      }

      // Step 8: Encode to JPEG with quality adjustment for large images
      List<int> jpegBytes;
      try {
        // Reduce quality for very large images to save memory
        var adjustedQuality = quality;
        if (targetWidth * targetHeight > 2048 * 2048) {
          adjustedQuality = math.max(adjustedQuality - 10, _minQuality);
        }
        
        jpegBytes = img.encodeJpg(processedImage, quality: adjustedQuality);
      } catch (e) {
        throw Exception('Failed to encode image as JPEG: $e');
      }

      // Step 9: Validate output size
      if (jpegBytes.isEmpty) {
        throw Exception('JPEG encoding produced empty result');
      }

      // Warn if output is still very large
      if (jpegBytes.length > 10 * 1024 * 1024) {
        // 10MB
        AppLogger.w(
          'Large output file size: ${jpegBytes.length ~/ (1024 * 1024)}MB',
          tag: 'ImageConverter',
        );
      }

      // Step 10: Write to temporary file with error handling
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'image_${timestamp}_${targetWidth}x$targetHeight.jpg';
      final filePath = path.join(tempDir.path, filename);

      final file = File(filePath);
      try {
        await file.writeAsBytes(jpegBytes);
      } catch (e) {
        throw Exception('Failed to write processed image to file: $e');
      }

      // Step 11: Validate written file
      if (!await file.exists()) {
        throw Exception('Failed to create processed image file');
      }

      final outputSize = await file.length();
      AppLogger.d(
        'Image processing complete: ${originalImage.width}x${originalImage.height}'
        ' -> ${targetWidth}x$targetHeight,'
        ' ${imageBytes.length ~/ 1024}KB -> ${outputSize ~/ 1024}KB',
        tag: 'ImageConverter',
      );

      return file;

    } catch (e) {
      // Log error for debugging
      AppLogger.e('Image conversion error', tag: 'ImageConverter', error: e);

      // Re-throw with more context
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Unexpected error during image conversion: $e');
      }
    }
  }

  /// Utility method to get image info without full processing
  static Future<Map<String, dynamic>?> getImageInfo(XFile pickedImage) async {
    try {
      if (!await _validateFileSize(pickedImage)) {
        return null;
      }

      final imageBytes = await pickedImage.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) {
        return null;
      }

      final fileSize = await pickedImage.length();
      final estimatedMemory = _estimateMemoryUsage(originalImage.width, originalImage.height);

      return {
        'width': originalImage.width,
        'height': originalImage.height,
        'file_size_bytes': fileSize,
        'file_size_mb': (fileSize / (1024 * 1024)).toStringAsFixed(2),
        'estimated_memory_mb': (estimatedMemory / (1024 * 1024)).toStringAsFixed(2),
        'is_safe_to_process': estimatedMemory <= _maxMemoryUsageBytes,
        'needs_resizing': originalImage.width > _defaultMaxWidth || originalImage.height > _defaultMaxHeight,
      };
    } catch (e) {
      AppLogger.e('Error getting image info', tag: 'ImageConverter', error: e);
      return null;
    }
  }

  /// Clean up temporary image files (call this periodically)
  static Future<void> cleanupTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final entities = tempDir.listSync();
      
      for (final entity in entities) {
        if (entity is File && entity.path.contains('image_') && entity.path.endsWith('.jpg')) {
          try {
            // Delete files older than 1 hour
            final stat = await entity.stat();
            if (DateTime.now().difference(stat.modified).inHours > 1) {
              await entity.delete();
            }
          } catch (e) {
            AppLogger.e(
              'Error deleting temp image',
              tag: 'ImageConverter',
              error: e,
            );
          }
        }
      }
    } catch (e) {
      AppLogger.e(
        'Error cleaning up temp images',
        tag: 'ImageConverter',
        error: e,
      );
    }
  }
}
