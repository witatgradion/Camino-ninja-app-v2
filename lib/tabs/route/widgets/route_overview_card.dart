import 'package:auto_size_text/auto_size_text.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/map/cubit/map_tab_cubit.dart';
import 'package:camino_ninja_flutter/tabs/map/map_screen.dart';
import 'package:camino_ninja_flutter/tabs/map/map_tab_screen.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/stage_map.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/distance_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/elevation_screen.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/elevation_gain_loss_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class RouteOverviewCard extends StatefulWidget {
  const RouteOverviewCard({
    required this.state,
    super.key,
  });
  final AppState state;

  @override
  State<RouteOverviewCard> createState() => _RouteOverviewCardState();
}

class _RouteOverviewCardState extends State<RouteOverviewCard> {
  final _groupKey = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (_, appState) {
        final distance = UnitConverter.displayDistance(
          kilometers: widget.state.routeStats?.distance ?? 0,
          unit: appState.unit,
        );
        final elevationGain = UnitConverter.displayElevation(
          meters: widget.state.routeStats?.elevationGain.toDouble() ?? 0.0,
          unit: appState.unit,
        );

        final elevationLoss = UnitConverter.displayElevation(
          meters: widget.state.routeStats?.elevationLoss.toDouble() ?? 0.0,
          unit: appState.unit,
        );

        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Ink(
                  padding: const EdgeInsets.only(
                    top: 16,
                    right: 16,
                    left: 16,
                    bottom: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: context.isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: InkWell(
                    onTap: () => _onDistanceTap(context, appState),
                    child: _buildInfoRow(
                      context,
                      firstLabel:
                          '${AppLocalizations.of(context).stageDistance.toLowerCase().capitalizeFirstLetter()}:',
                      firstText: distance,
                      icon: 'assets/ic_walk.svg',
                      onTap: () => _onDistanceTap(context, appState),
                    ),
                  ),
                ),
                Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  color: context.isDarkMode ? Colors.black : Colors.white,
                  child: InkWell(
                    onTap: () => _onElevationTap(context, appState),
                    child: _buildInfoRow(
                      context,
                      firstLabel:
                          '${AppLocalizations.of(context).elevationGainLossRouteScreen.capitalizeFirstLetter()}:',
                      firstTextWidget: ElevationGainLossWidget(
                        elevationGain: elevationGain,
                        elevationLoss: elevationLoss,
                        group: _groupKey,
                        isBold: true,
                      ),
                      icon: 'assets/ic_mountain.svg',
                      onTap: () => _onElevationTap(context, appState),
                    ),
                  ),
                ),
                Ink(
                  padding: const EdgeInsets.only(
                    top: 4,
                    right: 16,
                    left: 16,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    color: context.isDarkMode ? Colors.black : Colors.white,
                  ),
                  child: AspectRatio(
                    aspectRatio: 297 / 80,
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          child: GestureDetector(
                            onTap: () => _onMapTap(context),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.all(1),
                              clipBehavior: Clip.hardEdge,
                              child: IgnorePointer(
                                child: StageSmallMap(
                                  isDarkMode: context.isDarkMode,
                                  routeColor: Colors.red,
                                  selectedRoutePoints:
                                      widget.state.selectedRoutePoints
                                              ?.map(
                                                (e) => LatLng(
                                                  e.latitude,
                                                  e.longitude,
                                                ),
                                              )
                                              .toList() ??
                                          [],
                                  routePoints: widget.state.routePoints
                                          ?.map(
                                            (e) => LatLng(
                                              e.latitude,
                                              e.longitude,
                                            ),
                                          )
                                          .toList() ??
                                      [],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () => _onMapTap(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.isDarkMode
                                      ? AppColors.primary80
                                      : AppColors.primary40,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.47),
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6.5,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/ic_nav_map.svg',
                                      width: 18,
                                      color: context.isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      AppLocalizations.of(context).map,
                                      style:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: context.isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: context.isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String firstLabel,
    required String icon,
    required VoidCallback onTap,
    String? firstText,
    String? secondLabel,
    String? secondText,
    Widget? firstTextWidget,
  }) {
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: 24,
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (firstTextWidget != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '$firstLabel ',
                      group: _groupKey,
                      style: context.textTheme.bodyMedium,
                    ),
                    firstTextWidget,
                  ],
                )
              else
                AutoSizeText.rich(
                  group: _groupKey,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$firstLabel ',
                        style: context.textTheme.bodyMedium,
                      ),
                      if (firstText != null)
                        TextSpan(
                          text: firstText,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              if (secondLabel != null && secondText != null) ...[
                const SizedBox(height: 2),
                AutoSizeText.rich(
                  group: _groupKey,
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$secondLabel ',
                        style: context.textTheme.bodyMedium,
                      ),
                      TextSpan(
                        text: secondText,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildArrowCircle(context, onTap),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildArrowCircle(BuildContext context, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: context.isDarkMode ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  void _onDistanceTap(BuildContext context, AppState appState) {
    if (widget.state.selectedRoute != null &&
        widget.state.selectedStartingPoint != null &&
        widget.state.selectedDestination != null) {
      context.push(
        RouterLocations.distance(
          routeId: widget.state.selectedRoute!.id,
          destinationCityId: widget.state.selectedDestination!.id,
        ),
        extra: DistanceScreenArguments(
          routeId: widget.state.selectedRoute!.id,
          destinationCity: widget.state.selectedDestination!,
          unit: widget.state.unit,
          title: AppLocalizations.of(context).distance_344,
        ),
      );
    }
  }

  void _onElevationTap(BuildContext context, AppState appState) {
    if (widget.state.selectedRoute != null &&
        widget.state.selectedStartingPoint != null &&
        widget.state.selectedDestination != null) {
      context.push(
        RouterLocations.elevation(
          routeId: widget.state.selectedRoute!.id,
          startingCityId: widget.state.selectedStartingPoint!.id,
          destCityId: widget.state.selectedDestination!.id,
        ),
        extra: ElevationScreenArguments(
          routeId: widget.state.selectedRoute!.id,
          startingCityId: widget.state.selectedStartingPoint!.id,
          destCityId: widget.state.selectedDestination!.id,
          title: AppLocalizations.of(context).elevation_342,
        ),
      );
    }
  }

  void _onMapTap(BuildContext context) {
    if (widget.state.selectedRoute != null) {
      context.goNamed(
        'map',
        extra: MapTabPageArguments(
          routeArguments: MapScreenArguments(
            title: AppLocalizations.of(context).map,
            routeId: widget.state.selectedRoute!.id,
            startingCityId: widget.state.selectedStartingPoint?.id,
            destCityId: widget.state.selectedDestination?.id,
            routePoints: widget.state.routePoints ?? [],
            altRoutePoints: widget.state.altRoutePoints ?? [],
          ),
          initialMode: MapTabMode.route,
        ),
      );
    }
  }
}
