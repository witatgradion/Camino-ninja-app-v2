import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StageSubOptionSelector extends StatelessWidget {
  const StageSubOptionSelector({
    required this.title,
    required this.placeholder,
    required this.onTap,
    super.key,
    this.value,
    this.subItem,
  });
  final String title;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final Widget? subItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 6),
          child: Image.asset(
            'assets/ic_l_dotted.webp',
            width: 16,
            color:
                context.isDarkMode ? AppColors.tertiary90 : AppColors.yellow300,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? AppColors.tertiary90
                            : AppColors.yellow300,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/ic_bed.svg',
                        width: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value ?? placeholder,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: (value ?? '').isNotEmpty
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: context.isDarkMode
                                ? AppColors.primary80
                                : AppColors.primary40,
                          ),
                        ),
                        if (subItem != null) ...[
                          const SizedBox(height: 8),
                          subItem!,
                        ],
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
        ),
      ],
    );
  }
}
