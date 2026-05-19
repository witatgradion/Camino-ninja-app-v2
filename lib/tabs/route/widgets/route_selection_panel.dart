import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class RouteSelectionPanel extends StatelessWidget {
  const RouteSelectionPanel({required this.state, super.key});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFE08B),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                    ),
                    if (_shouldShowCheck(index))
                      Positioned(
                        bottom: 8,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            'assets/ic_check.svg',
                            width: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 2,
                      height: 12,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE08B),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              );
            },
            itemCount: 3,
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _buildRouteInfo(
                context,
                label: AppLocalizations.of(context).route,
                title: _getRouteName(context),
                subtitleWidget: state.selectedRoute?.routeSubName == null
                    ? null
                    : RouteNameText(
                        routeSubName: state.selectedRoute?.routeSubName ?? '',
                        maxLines: 1,
                        textStyle:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: context.isDarkMode
                                      ? AppColors.primary80
                                      : AppColors.primary40,
                                ),
                      ),
                onTap: () {
                  context.push('/select-route');
                },
              ),
              _buildRouteInfo(
                context,
                label: AppLocalizations.of(context).startHereToday,
                title: state.selectedStartingPoint?.name ??
                    AppLocalizations.of(context).selectLocation,
                onTap: () {
                  if (state.selectedRoute != null) {
                    context.push('/select-starting-point');
                  }
                },
              ),
              _buildRouteInfo(
                context,
                label: AppLocalizations.of(context).goToHereToday,
                title: state.selectedDestination?.name ??
                    AppLocalizations.of(context).selectLocation,
                onTap: () {
                  if (state.selectedStartingPoint != null) {
                    context.push('/select-destination');
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteInfo(
    BuildContext context, {
    required String label,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    Widget? subtitleWidget,
  }) {
    final isDark = context.isDarkMode;
    final subNameAvailable =
        (subtitle != null && subtitle.isNotEmpty) || subtitleWidget != null;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.primary80
                              : AppColors.primary40,
                        ),
                    maxLines: !subNameAvailable ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.primary80
                                : AppColors.primary40,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (subtitleWidget != null) subtitleWidget,
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }

  String _getRouteName(BuildContext context) {
    if (state.selectedRoute != null) {
      return state.selectedRoute!.routeName;
    }
    return AppLocalizations.of(context).selectRoute_431;
  }

  bool _shouldShowCheck(int index) {
    if (index == 0) {
      return state.selectedRoute != null;
    }
    if (index == 1) {
      return state.selectedStartingPoint != null;
    }
    if (index == 2) {
      return state.selectedDestination != null;
    }
    return false;
  }
}
