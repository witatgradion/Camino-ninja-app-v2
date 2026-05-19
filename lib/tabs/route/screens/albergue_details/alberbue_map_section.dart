import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_albergues_map.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class AlbergueMapSection extends StatelessWidget {
  const AlbergueMapSection(
      {required this.state,
      required this.cityId,
      required this.routeId,
      required this.albergueId,
      required this.navScope,
      super.key,});
  final AlbergueDetailsState state;
  final int? cityId;
  final int? routeId;
  final int albergueId;
  final AlbergueDetailsNavScope navScope;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 393 / 218,
      child: InkWell(
        onTap: () {
          context.push(
            navScope.fullMapPath(
              albergueId: albergueId,
              cityId: cityId,
              routeId: routeId,
            ),
          );
        },
        child: Stack(
          children: [
            CityAlberguesMap(
              city: state.city,
              locations: [
                AlbergueLocation(
                  name: state.albergue!.name,
                  latLng: LatLng(
                    state.albergue!.latitude!,
                    state.albergue!.longitude!,
                  ),
                  albergue: state.albergue,
                ),
              ],
              routePoints: state.routePoints,
              altRoutePoints: state.altRoutePoints,
              zoom: 14,
              mapToolbarEnabled: false,
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
