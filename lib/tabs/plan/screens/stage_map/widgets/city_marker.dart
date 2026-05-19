import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class CityMarker extends StatelessWidget {
  const CityMarker({
    required this.city,
    required this.isDarkMode,
    required this.textTheme,
    super.key,
  });
  final CityEntity city;
  final bool isDarkMode;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primary80 : AppColors.primary40,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        city.name,
        style: textTheme.bodySmall?.copyWith(
          color: isDarkMode ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: (textTheme.bodySmall?.fontSize ?? 14) + 2,
        ),
      ),
    );
  }
}
