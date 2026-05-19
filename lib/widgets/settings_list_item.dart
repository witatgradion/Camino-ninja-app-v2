import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';

class SettingsListItem extends StatelessWidget {
  const SettingsListItem({
    required this.title,
    required this.onClick,
    this.subtitle,
    this.titleColor,
    this.trailing = const SizedBox(width: 24),
    this.decoration,
    super.key,
  });

  final Color? titleColor;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback onClick;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: InkWell(
          onTap: onClick,
          borderRadius: decoration?.borderRadius is BorderRadius
              ? decoration!.borderRadius! as BorderRadius
              : null,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 64,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: titleColor ??
                                  (isDark ? Colors.white : AppColors.primary40),
                            ),
                      ),
                      if (subtitle != null) ...[
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                trailing,
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
