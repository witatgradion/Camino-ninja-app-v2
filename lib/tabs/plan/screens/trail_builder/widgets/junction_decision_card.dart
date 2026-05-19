import 'package:camino_ninja_flutter/tabs/plan/screens/trail_builder/cubit/trail_builder_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/hex_color.dart';
import 'package:flutter/material.dart';

/// Displays action cards for the junction decision:
/// continue, switch to a branch route, or end the trail.
///
/// Uses theme-aware colours so the cards adapt to light
/// and dark mode.
class JunctionDecisionCard extends StatelessWidget {
  const JunctionDecisionCard({
    required this.junctionInfo,
    required this.onContinue,
    required this.onSwitchToRoute,
    required this.onEndTrail,
    super.key,
  });

  final JunctionInfo junctionInfo;
  final VoidCallback onContinue;
  final void Function(int routeId) onSwitchToRoute;
  final VoidCallback onEndTrail;

  static const _accentColor = Color(0xFF26C6DA);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = context.isDarkMode;

    final titleColor = isDark
        ? AppColors.primary90
        : AppColors.primary10;
    final subtitleColor = colorScheme.onSurfaceVariant;
    final chevronColor = colorScheme.onSurfaceVariant;
    final cardColor =
        colorScheme.surfaceContainerHigh;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Continue on current route
          _ActionCard(
            icon: Icons.arrow_forward_rounded,
            iconBackgroundColor: AppColors.primary40,
            // TODO(l10n): continue on route
            title: 'Continue on '
                '${junctionInfo.currentRoute.routeName}',
            subtitle: junctionInfo.routeEndCity != null
                // TODO(l10n): finishes at
                ? 'Finishes at '
                    '${junctionInfo.routeEndCity}'
                : null,
            routeColor: parseRouteColor(
              junctionInfo.currentRoute,
              isDark: isDark,
            ),
            onTap: onContinue,
            cardColor: cardColor,
            titleColor: titleColor,
            subtitleColor: subtitleColor,
            chevronColor: chevronColor,
          ),

          // Branch routes section
          if (junctionInfo.branchRoutes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              // TODO(l10n): switch to label
              'At ${junctionInfo.city.name}, '
              'you can switch to',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            ...junctionInfo.branchRoutes.map(
              (route) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: _ActionCard(
                  icon: Icons.shuffle_rounded,
                  iconBackgroundColor: AppColors.primary40,
                  // TODO(l10n): switch to route
                  title: 'Switch to '
                      '${route.routeName}',
                  subtitle: route.routeSubName,
                  routeColor: parseRouteColor(
                    route,
                    isDark: isDark,
                  ),
                  onTap: () => onSwitchToRoute(route.id),
                  cardColor: cardColor,
                  titleColor: titleColor,
                  subtitleColor: subtitleColor,
                  chevronColor: chevronColor,
                ),
              ),
            ),
          ],

          // End trail card
          const SizedBox(height: 8),
          _EndTrailCard(
            cityName: junctionInfo.city.name,
            onTap: onEndTrail,
            borderColor: _accentColor,
            iconBgColor: const Color(0xFF4FC3F7),
            textColor: _accentColor,
            chevronColor: chevronColor,
          ),
        ],
      ),
    );
  }
}

/// A filled action card with icon circle, title, and
/// optional subtitle. Colours are passed explicitly so this
/// widget is theme-independent.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.onTap,
    required this.cardColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.chevronColor,
    this.subtitle,
    this.routeColor,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String? subtitle;
  final Color? routeColor;
  final VoidCallback onTap;
  final Color cardColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color chevronColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _IconCircle(
                icon: icon,
                backgroundColor: iconBackgroundColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (routeColor != null) ...[
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: routeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style:
                                textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: chevronColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Outlined card for ending the trail at the junction
/// city. Colours are passed explicitly for
/// theme-independent rendering.
class _EndTrailCard extends StatelessWidget {
  const _EndTrailCard({
    required this.cityName,
    required this.onTap,
    required this.borderColor,
    required this.iconBgColor,
    required this.textColor,
    required this.chevronColor,
  });

  final String cityName;
  final VoidCallback onTap;
  final Color borderColor;
  final Color iconBgColor;
  final Color textColor;
  final Color chevronColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _IconCircle(
                icon: Icons.directions_walk_rounded,
                backgroundColor: iconBgColor,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  // TODO(l10n): end trail at city
                  'End trail at $cityName',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: chevronColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 44x44 circle containing a white icon.
class _IconCircle extends StatelessWidget {
  const _IconCircle({
    required this.icon,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}
