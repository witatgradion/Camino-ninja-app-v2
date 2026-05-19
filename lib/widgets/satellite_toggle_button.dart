import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';

/// Floating circular button that toggles between the map's theme style
/// and a satellite overlay.
///
/// The button is a dumb presentational widget — toggle state and the
/// actual style swap live on whichever map controller is hosting the
/// map. Pass [isActive] to drive the visual state and [onToggle] to
/// react to taps. Style mutation must flow through the controller's
/// serialised swap path so theme/satellite toggles cannot race.
class SatelliteToggleButton extends StatelessWidget {
  const SatelliteToggleButton({
    required this.isActive,
    required this.onToggle,
    super.key,
  });

  final bool isActive;
  final Future<void> Function() onToggle;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.isDarkMode
        ? AppColors.primary20
        : AppColors.primary40;
    final iconColor =
        context.isDarkMode ? AppColors.primary80 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: isActive ? iconColor : backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.layers,
              size: 24,
              color: isActive ? backgroundColor : iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
