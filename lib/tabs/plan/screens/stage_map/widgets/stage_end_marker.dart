import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repository/repository.dart';

class StageEndMarker extends StatelessWidget {
  const StageEndMarker({
    required this.stage,
    required this.endText,
    this.isSelected = false,
    this.isDarkMode = false,
    this.textTheme = appTextTheme,
    this.index = 0,
    super.key,
  });
  final StageModel stage;
  final bool isSelected;
  final bool isDarkMode;
  final int index;
  final TextTheme textTheme;
  final String endText;

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        isDarkMode ? AppColors.primary80 : AppColors.primary40;
    final unselectedColor = isDarkMode ? AppColors.gray400 : AppColors.gray500;
    final color = isSelected ? selectedColor : unselectedColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? Colors.black : Colors.white,
            border: Border.all(
              color: color,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            (index + 1).toString(),
            style: textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                isSelected ? 'assets/ic_flag.svg' : 'assets/ic_flag_light.svg',
                width: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                endText,
                style: textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: (textTheme.bodySmall?.fontSize ?? 14) + 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
