import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';

class CustomTabBar<T> extends StatelessWidget {
  const CustomTabBar({
    required this.items,
    required this.onTap,
    required this.label,
    required this.isSelected,
    this.prefixIcon,
    super.key,
  });
  final List<T> items;
  final ValueChanged<T> onTap;
  final String Function(T) label;
  final bool Function(T) isSelected;
  /// Return null to omit the prefix and the trailing gap before the label.
  final Widget? Function(T)? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.neutral20 : AppColors.neutral95,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.neutral80 : AppColors.neutral40)
                  .withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            ...items.map(
              (item) => Expanded(
                child: _TabButton(
                  label: label(item),
                  isSelected: isSelected(item),
                  onTap: () => onTap(item),
                  prefixIcon: prefixIcon?.call(item),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.prefixIcon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            children: [
              if (prefixIcon != null) ...[
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: prefixIcon!,
                ),
                const WidgetSpan(child: SizedBox(width: 2.5)),
              ],
              TextSpan(
                text: label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : (isDark ? AppColors.neutral80 : AppColors.neutral40),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
