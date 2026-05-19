import 'package:auto_size_text/auto_size_text.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/stage_map.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/distance_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/elevation_screen.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:repository/repository.dart';

class StageOverviewCard extends StatefulWidget {
  const StageOverviewCard({
    required this.stage,
    required this.onMapTap,
    super.key,
  });
  final StageModel stage;
  final VoidCallback onMapTap;

  @override
  State<StageOverviewCard> createState() => _StageOverviewCardState();
}

class _StageOverviewCardState extends State<StageOverviewCard> {
  final _groupKey = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.unit != current.unit,
      builder: (_, appState) {
        final distance = UnitConverter.displayDistance(
          kilometers: widget.stage.distance ?? 0,
          unit: appState.unit,
        );

        final minElevation = UnitConverter.displayElevation(
          meters: widget.stage.minElevation?.toDouble() ?? 0.0,
          unit: appState.unit,
        );

        final maxElevation = UnitConverter.displayElevation(
          meters: widget.stage.maxElevation?.toDouble() ?? 0.0,
          unit: appState.unit,
        );

        final elevationGain = UnitConverter.displayElevation(
          meters: widget.stage.elevationGain?.toDouble() ?? 0.0,
          unit: appState.unit,
        );

        final elevationLoss = UnitConverter.displayElevation(
          meters: widget.stage.elevationLoss?.toDouble() ?? 0.0,
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
                    bottom: 8,
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
                      firstLabel: AppLocalizations.of(context).distance_344,
                      firstText: distance,
                      icon: 'assets/ic_walk.svg',
                      onTap: () => _onDistanceTap(context, appState),
                    ),
                  ),
                ),
                Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: context.isDarkMode ? Colors.black : Colors.white,
                  child: InkWell(
                    onTap: () => _onElevationTap(context, appState),
                    child: _buildInfoRow(
                      context,
                      firstLabel:
                          AppLocalizations.of(context).minMaxElevRouteScreen,
                      firstText: '$minElevation / $maxElevation',
                      secondLabel: AppLocalizations.of(context)
                          .elevationGainLossRouteScreen,
                      secondText: '$elevationGain / -$elevationLoss',
                      icon: 'assets/ic_mountain.svg',
                      onTap: () => _onElevationTap(context, appState),
                    ),
                  ),
                ),
                Ink(
                  padding: const EdgeInsets.only(
                    top: 8,
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
                            onTap: widget.onMapTap,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.all(1),
                              clipBehavior: Clip.hardEdge,
                              child: IgnorePointer(
                                child: StageSmallMap(
                                  isDarkMode: context.isDarkMode,
                                  selectedRoutePoints: widget.stage.selectedRoutePoints
                                          ?.map((e) =>
                                              LatLng(e.latitude, e.longitude),)
                                          .toList() ??
                                      [],
                                  routePoints: widget.stage.points
                                          ?.map((e) =>
                                              LatLng(e.latitude, e.longitude),)
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
                            child: _buildArrowCircle(
                              context,
                              widget.onMapTap,
                              showShadow: true,
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
    required String firstText,
    required String icon,
    required VoidCallback onTap,
    String? secondLabel,
    String? secondText,
  }) {
    return Row(
      children: [
        SvgPicture.asset(icon,
            width: 24, color: context.isDarkMode ? Colors.white : Colors.black,),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AutoSizeText.rich(
                group: _groupKey,
                TextSpan(
                  children: [
                    TextSpan(
                        text: '$firstLabel ',
                        style: context.textTheme.bodyMedium,),
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
                          style: context.textTheme.bodyMedium,),
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

  Widget _buildArrowCircle(
    BuildContext context,
    VoidCallback onTap, {
    bool showShadow = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
          boxShadow: [
            if (showShadow) ...[
              BoxShadow(
                color: Colors.black.withOpacity(0.47),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ],
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
    final destinationCity = widget.stage.endCity;
    final routeId = widget.stage.routeId;
    if (destinationCity == null) {
      return;
    }
    context.push(
      RouterLocations.stageDistance(
        routeId: routeId,
        destinationCityId: destinationCity.id,
      ),
      extra: DistanceScreenArguments(
        routeId: routeId,
        destinationCity: destinationCity,
        unit: appState.unit,
        title: AppLocalizations.of(context).stageDistance,
      ),
    );
  }

  void _onElevationTap(BuildContext context, AppState appState) {
    final routeId = widget.stage.routeId;
    final startingCityId = widget.stage.startCity?.id;
    final destCityId = widget.stage.endCity?.id;
    if (startingCityId == null || destCityId == null) {
      return;
    }
    context.push(
      RouterLocations.stageElevation(
        routeId: routeId,
        startingCityId: startingCityId,
        destCityId: destCityId,
      ),
      extra: ElevationScreenArguments(
        routeId: routeId,
        startingCityId: startingCityId,
        destCityId: destCityId,
        title: AppLocalizations.of(context).stageElevation,
      ),
    );
  }
}
