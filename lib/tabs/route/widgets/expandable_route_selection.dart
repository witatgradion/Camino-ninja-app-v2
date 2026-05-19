import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/widgets/route_overview_card.dart';
import 'package:camino_ninja_flutter/tabs/route/widgets/route_selection_panel.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ExpandableRouteSelection extends StatelessWidget {
  const ExpandableRouteSelection({
    required this.state,
    this.isExpanded,
    this.onToggleExpandTap,
    this.enableAnimation = true,
    super.key,
  });

  final AppState state;

  /// When provided, the widget becomes a "controlled" widget and will use this
  /// value instead of its own internal state.
  final bool? isExpanded;

  /// Called whenever the expanded state is toggled by the user.
  final VoidCallback? onToggleExpandTap;

  // When true, the widget will animate when the expanded state is toggled.
  final bool enableAnimation;

  @override
  Widget build(BuildContext context) {
    final startCity = state.selectedStartingPoint;
    final destination = state.selectedDestination;
    final route = state.selectedRoute;
    final isRouteSelected = route != null;
    final isStartEndSelected = startCity != null && destination != null;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleExpandTap,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? AppColors.gray800
                      : AppColors.gray200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).routeSummary,
                            style: context.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedSwitcher(
                          duration: Durations.medium2,
                          child: Text(
                            isExpanded ?? true
                                ? AppLocalizations.of(context).hide
                                : AppLocalizations.of(context).show,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.isDarkMode
                                  ? AppColors.primary80
                                  : AppColors.primary40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: context.isDarkMode
                                ? AppColors.primary80
                                : AppColors.primary40,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: Durations.medium2,
                            child: isExpanded ?? true
                                ? SvgPicture.asset(
                                    'assets/ic_collapse_route_overview.svg',
                                    width: 16,
                                    color: context.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : SvgPicture.asset(
                                    'assets/ic_expand_route_overview.svg',
                                    width: 16,
                                    color: context.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    Builder(
                      builder: (context) {
                        final child = Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!(isExpanded ?? true) && isRouteSelected) ...[
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    'assets/ic_shellfish.svg',
                                    width: 20,
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: RouteNameText(
                                      routeName: route.routeName,
                                      routeSubName: route.routeSubName ?? '',
                                      maxLines: 2,
                                      textStyle: context.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: context.isDarkMode
                                            ? AppColors.primary80
                                            : AppColors.primary40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isStartEndSelected) ...[
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: startCity.name,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: context.isDarkMode
                                              ? AppColors.primary80
                                              : AppColors.primary40,
                                        ),
                                      ),
                                      WidgetSpan(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2,),
                                          child: SvgPicture.asset(
                                            'assets/ic_arrow_left_outline.svg',
                                            width: 16,
                                            color: context.isDarkMode
                                                ? AppColors.primary80
                                                : AppColors.primary40,
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                        text: destination.name,
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: context.isDarkMode
                                              ? AppColors.primary80
                                              : AppColors.primary40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                            if (isExpanded ?? true) ...[
                              RouteSelectionPanel(
                                state: state,
                              ),
                              if (isRouteSelected) ...[
                                RouteOverviewCard(state: state),
                              ],
                            ],
                          ],
                        );
                        if (enableAnimation) {
                          return AnimatedSize(
                            duration: Durations.medium2,
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment.topCenter,
                            child: child,
                          );
                        }
                        return child;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 4,
                  width: 70,
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? const Color(0xFF48454E)
                        : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
