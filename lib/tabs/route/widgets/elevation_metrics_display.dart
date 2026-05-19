import 'package:auto_size_text/auto_size_text.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/distance_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/elevation_screen.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';

import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ElevationMetricsDisplay extends StatefulWidget {
  const ElevationMetricsDisplay({required this.state, super.key});
  final AppState state;

  @override
  State<ElevationMetricsDisplay> createState() =>
      _ElevationMetricsDisplayState();
}

class _ElevationMetricsDisplayState extends State<ElevationMetricsDisplay> {
  final _groupKey = AutoSizeGroup();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final distance = UnitConverter.displayDistance(
          kilometers: widget.state.routeStats?.distance ?? 0,
          unit: state.unit,
        );

        final minElevation = UnitConverter.displayElevation(
          meters: widget.state.routeStats?.minElevation.toDouble() ?? 0.0,
          unit: state.unit,
        );

        final maxElevation = UnitConverter.displayElevation(
          meters: widget.state.routeStats?.maxElevation.toDouble() ?? 0.0,
          unit: state.unit,
        );

        final elevationGain = UnitConverter.displayElevation(
          meters: widget.state.routeStats?.elevationGain.toDouble() ?? 0.0,
          unit: state.unit,
        );

        final elevationLoss = UnitConverter.displayElevation(
          meters: widget.state.routeStats?.elevationLoss.toDouble() ?? 0.0,
          unit: state.unit,
        );

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: isDarkMode ? const Color(0xFF1F2A37) : const Color(0xFFE5E7EB),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      group: _groupKey,
                      '${AppLocalizations.of(context).distance_344}: $distance',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      minFontSize: 8,
                    ),
                    AutoSizeText(
                      group: _groupKey,
                      '${AppLocalizations.of(context).minMaxElevRouteScreen}: $minElevation/$maxElevation',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      minFontSize: 8,
                    ),
                    AutoSizeText(
                      group: _groupKey,
                      '${AppLocalizations.of(context).elevationGainLossRouteScreen}: $elevationGain/-$elevationLoss',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      minFontSize: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildButton(
                context,
                AppLocalizations.of(context).distance,
                onTap: () {
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
                },
              ),
              const SizedBox(width: 8),
              _buildButton(
                context,
                AppLocalizations.of(context).elevation,
                onTap: () {
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
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    String label, {
    VoidCallback? onTap,
    bool isDarkMode = false,
  }) {
    return Material(
      color: isDarkMode ? const Color(0xFF003544) : const Color(0xFF009DC3),
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9.5, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? const Color(0xFF003544) : Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}
