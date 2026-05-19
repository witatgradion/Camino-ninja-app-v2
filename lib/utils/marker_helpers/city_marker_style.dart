// =============================================================================
// CITY MARKER STYLING SYSTEM
// =============================================================================

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

CityMarkerStyle mapScreenCityMarkerStyle(BuildContext context) =>
    CityMarkerStyle(
      fontFamily: appFontFamily,
      fontSize: 18,
      textColor: context.isDarkMode ? Colors.black : Colors.white,
      backgroundColor:
          context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
      backgroundOpacity: 1,
      borderColor: Colors.transparent,
      borderWidth: 0,
      borderRadius: 6,
      paddingHorizontal: 4,
      paddingVertical: 2,
    );

CityMarkerStyle defaultCityMarkerStyle(BuildContext context) => CityMarkerStyle(
      fontFamily: appFontFamily,
      fontSize: 16,
      textColor: context.isDarkMode ? Colors.black : Colors.white,
      backgroundColor:
          context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
      backgroundOpacity: 1,
      borderColor: Colors.transparent,
      borderWidth: 0, // Reduced from 3 for less visual bulk
      borderRadius: 6,
      paddingHorizontal: 4, // Reduced from 16 for smaller width
      paddingVertical: 2, // Reduced from 4 for smaller height
    );

/// Configuration class for city marker styling
///
///
class CityMarkerStyle extends Equatable {
  const CityMarkerStyle({
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    this.fontSize = 36.0,
    this.fontWeight = FontWeight.bold,
    this.fontFamily,
    this.backgroundOpacity = 0.6,
    this.borderOpacity = 0.3,
    this.borderWidth = 1.5,
    this.borderRadius = 64.0,
    this.paddingHorizontal = 24.0,
    this.paddingVertical = 16.0,
    this.enableAntiAliasing = true,
  });
  final double fontSize;
  final FontWeight fontWeight;
  final String? fontFamily;
  final Color textColor;
  final Color backgroundColor;
  final double backgroundOpacity;
  final Color borderColor;
  final double borderOpacity;
  final double borderWidth;
  final double borderRadius;
  final double paddingHorizontal;
  final double paddingVertical;
  final bool enableAntiAliasing;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CityMarkerStyle &&
          runtimeType == other.runtimeType &&
          fontSize == other.fontSize &&
          fontWeight == other.fontWeight &&
          fontFamily == other.fontFamily &&
          textColor == other.textColor &&
          backgroundColor == other.backgroundColor &&
          backgroundOpacity == other.backgroundOpacity &&
          borderColor == other.borderColor &&
          borderOpacity == other.borderOpacity &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          paddingHorizontal == other.paddingHorizontal &&
          paddingVertical == other.paddingVertical &&
          enableAntiAliasing == other.enableAntiAliasing;

  @override
  int get hashCode =>
      fontSize.hashCode ^
      fontWeight.hashCode ^
      fontFamily.hashCode ^
      textColor.hashCode ^
      backgroundColor.hashCode ^
      backgroundOpacity.hashCode ^
      borderColor.hashCode ^
      borderOpacity.hashCode ^
      borderWidth.hashCode ^
      borderRadius.hashCode ^
      paddingHorizontal.hashCode ^
      paddingVertical.hashCode ^
      enableAntiAliasing.hashCode;

  @override
  List<Object?> get props => [
        textColor,
        backgroundColor,
        borderColor,
        fontSize,
        fontWeight,
        fontFamily,
        backgroundOpacity,
        borderOpacity,
        borderWidth,
        borderRadius,
        paddingHorizontal,
        paddingVertical,
        enableAntiAliasing,
      ];
}
