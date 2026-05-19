import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    required this.badgeCount,
    required this.child,
    super.key,
    this.badgeColor,
  });
  final int badgeCount;
  final Widget child;
  final Color? badgeColor;

  String get _badgeLabel {
    if (badgeCount >= 100) return '99+';
    return '$badgeCount';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (badgeCount > 0)
          Positioned(
            top: -5,
            right: -5,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Container(
                key: ValueKey(_badgeLabel),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.error40,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 17,
                  minHeight: 17,
                ),
                child: Text(
                  _badgeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
