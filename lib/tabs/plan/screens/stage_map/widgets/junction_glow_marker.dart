import 'package:flutter/material.dart';

class JunctionGlowMarker extends StatelessWidget {
  const JunctionGlowMarker({
    required this.fromRouteName,
    required this.toRouteName,
    required this.glowColor,
    required this.isDark,
    super.key,
  });

  final String fromRouteName;
  final String toRouteName;
  final Color glowColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        JunctionLabelPill(
          fromRouteName: fromRouteName,
          toRouteName: toRouteName,
          isDark: isDark,
        ),
        const SizedBox(height: 4),
        JunctionGlowRing(glowColor: glowColor),
      ],
    );
  }
}

/// Pill showing the from/to route names at a junction.
///
/// Extracted as a public widget so it can be reused inside
/// combine markers for composite junction + stage markers.
class JunctionLabelPill extends StatelessWidget {
  const JunctionLabelPill({
    required this.fromRouteName,
    required this.toRouteName,
    required this.isDark,
    super.key,
  });

  final String fromRouteName;
  final String toRouteName;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RouteNameText(
              name: fromRouteName,
              isDark: isDark,
              isMuted: true,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '\u2193',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? Colors.white.withAlpha(120)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            _RouteNameText(
              name: toRouteName,
              isDark: isDark,
              isMuted: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteNameText extends StatelessWidget {
  const _RouteNameText({
    required this.name,
    required this.isDark,
    required this.isMuted,
  });

  final String name;
  final bool isDark;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final color = isMuted
        ? (isDark
            ? Colors.white.withAlpha(160)
            : const Color(0xFF6B7280))
        : (isDark
            ? Colors.white.withAlpha(230)
            : const Color(0xFF1D4ED8));
    final fontWeight =
        isMuted ? FontWeight.w400 : FontWeight.w600;

    return Text(
      name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

/// Colored glow ring used at junction cities.
///
/// Extracted as a public widget so it can be layered behind
/// the city marker inside a combine marker when the city is
/// both a stage boundary and a junction.
class JunctionGlowRing extends StatelessWidget {
  const JunctionGlowRing({
    required this.glowColor,
    this.size = 28,
    super.key,
  });

  final Color glowColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF808080),
        border: Border.all(color: glowColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: glowColor.withAlpha(100),
            blurRadius: 12,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}
