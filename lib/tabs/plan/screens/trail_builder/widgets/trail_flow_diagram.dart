import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

/// A horizontal chip flow showing the trail built so far.
///
/// Displays route segments as colored pills connected by
/// junction dots with city names.
class TrailFlowDiagram extends StatelessWidget {
  const TrailFlowDiagram({
    required this.segments,
    this.junctionCityNames = const {},
    this.onUndo,
    super.key,
  });

  final List<TrailSegment> segments;

  /// Maps junction city IDs to display names, used to
  /// label the dots between segment chips.
  final Map<int, String> junctionCityNames;

  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(onUndo: onUndo),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildChips(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // TODO(l10n): segments count
            '${segments.length} '
            '${segments.length == 1 ? 'segment' : 'segments'}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChips() {
    final chips = <Widget>[];

    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        final junctionId = segments[i].junctionCityId;
        final name =
            junctionId != null ? junctionCityNames[junctionId] ?? '' : '';
        chips.add(_JunctionDot(cityName: name));
      }
      chips.add(_SegmentChip(segment: segments[i]));
    }

    return chips;
  }
}

class _Header extends StatelessWidget {
  const _Header({this.onUndo});

  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          // TODO(l10n): trail so far
          'Trail so far',
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        if (onUndo != null)
          TextButton(
            onPressed: onUndo,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              // TODO(l10n): undo
              'Undo',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({required this.segment});

  final TrailSegment segment;

  @override
  Widget build(BuildContext context) {
    final color = Color(segment.colorValue);
    final textTheme = context.textTheme;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        border: Border.all(
          color: color.withAlpha(102),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            segment.routeName,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.primary90 : AppColors.primary10,
            ),
          ),
        ],
      ),
    );
  }
}

class _JunctionDot extends StatelessWidget {
  const _JunctionDot({required this.cityName});

  final String cityName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = context.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: colorScheme.onSurfaceVariant,
          ),
          if (cityName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                cityName,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
