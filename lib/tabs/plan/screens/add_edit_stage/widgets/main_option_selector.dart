import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StageMainOptionSelector extends StatelessWidget {
  const StageMainOptionSelector({
    required this.index,
    required this.title,
    required this.placeholder,
    required this.onTap,
    super.key,
    this.value,
  });
  final int index;
  final String title;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          height: 34,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? AppColors.tertiary90
                        : AppColors.yellow300,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    index.toString(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (value != null && value!.isNotEmpty) ...[
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      'assets/ic_check.svg',
                      width: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color:
                              context.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (value ?? '').isNotEmpty ? value! : placeholder,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: (value ?? '').isNotEmpty
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: context.isDarkMode
                              ? AppColors.primary80
                              : AppColors.primary40,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 32,
                  color:
                      context.isDarkMode ? Colors.white : AppColors.primary40,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
