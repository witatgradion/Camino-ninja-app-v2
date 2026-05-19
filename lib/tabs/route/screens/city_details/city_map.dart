import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_albergues_map.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_full_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/cubit/city_details_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class CityMap extends StatelessWidget {
  const CityMap({
    required this.state,
    required this.routeId,
    this.fallbackTarget,
    super.key,
  });
  final CityDetailsState state;
  final int routeId;
  final LatLng? fallbackTarget;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 393 / 292,
      child: InkWell(
        onTap: () {
          context.push(
            RouterLocations.cityFullMap(
              routeId: routeId,
              cityId: state.city?.id ?? 0,
            ),
            extra: CityFullMapScreenArguments(
              city: state.city,
              fallbackTarget: fallbackTarget,
              routePoints: state.routePoints,
              albergues: state.albergues,
              altRoutePoints: state.altRoutePoints,
              routeId: routeId,
            ),
          );
        },
        child: Stack(
          children: [
            CityAlberguesMap(
              isFullScreen: false,
              city: state.city,
              fallbackTarget: fallbackTarget,
              routePoints: state.routePoints,
              altRoutePoints: state.altRoutePoints,
              locations: state.albergues
                  .map(
                    (albergue) => AlbergueLocation(
                      name: albergue.name,
                      albergueId: albergue.id,
                      latLng: LatLng(
                        albergue.latitude!,
                        albergue.longitude!,
                      ),
                      albergue: albergue,
                    ),
                  )
                  .toList(),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? AppColors.primary80
                          : AppColors.primary40,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: -3,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 5.5,),
                    child: Text(
                      AppLocalizations.of(context).tapToSeeTheMap,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.isDarkMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
