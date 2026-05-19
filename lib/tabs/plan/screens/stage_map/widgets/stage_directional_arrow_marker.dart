import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StageDirectionalArrowMarker extends StatelessWidget {
  const StageDirectionalArrowMarker({required this.isDarkMode, super.key});
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.primary80 : AppColors.primary40,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SvgPicture.asset(
        'assets/ic_arrow_left_outline.svg',
        width: 14,
        color: isDarkMode ? Colors.black : Colors.white,
      ),
    );
  }
}
