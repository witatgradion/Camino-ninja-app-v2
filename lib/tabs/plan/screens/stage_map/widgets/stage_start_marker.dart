import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repository/repository.dart';

class StageStartMarker extends StatelessWidget {
  const StageStartMarker({
    required this.stage,
    required this.startText,
    this.isSelected = false,
    this.index = 0,
    this.isDarkMode = false,
    this.textTheme = appTextTheme,
    super.key,
  });
  final StageModel stage;
  final int index;
  final bool isSelected;
  final bool isDarkMode;
  final TextTheme textTheme;
  final String startText;

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
          width: 32,
          height: 32,
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
            children: [
              SvgPicture.asset(
                'assets/ic_walk.svg',
                width: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startText,
                    style: textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: (textTheme.bodySmall?.fontSize ?? 14) + 2,
                    ),
                  ),
                  if (stage.date != null)
                    Text(
                      stage.date.toHumanReadableDate(),
                      style: textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: (textTheme.bodySmall?.fontSize ?? 14) + 2,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
