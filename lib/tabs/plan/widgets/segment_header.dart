import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

/// A non-tappable section header for a route segment in
/// grouped city lists. Shows a colored left border, a
/// small colored circle, and the route name in bold.
class SegmentHeader extends StatelessWidget {
  const SegmentHeader({
    required this.segment,
    super.key,
  });

  final TrailSegment segment;

  @override
  Widget build(BuildContext context) {
    final color = Color(segment.colorValue);
    final isDark = context.isDarkMode;
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: isDark ? AppColors.gray800 : AppColors.gray100,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pill-shaped accent stripe, inset from top
            // and bottom so it floats as a marker on the
            // left edge.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  12, 12, 16, 12,
                ),
                child: Text(
                  segment.routeName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.gray800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
