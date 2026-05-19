import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_full_map_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/cubit/city_details_cubit.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

class CityFullMapRouteScreen extends StatelessWidget {
  const CityFullMapRouteScreen({
    required this.routeId,
    required this.cityId,
    super.key,
  });

  final int routeId;
  final int cityId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CityDetailsCubit(
        cityId: cityId,
        routeId: routeId,
      )..init(),
      child: BlocBuilder<CityDetailsCubit, CityDetailsState>(
        builder: (context, state) {
          if (state.status == CityDetailsStatus.loading ||
              state.status == CityDetailsStatus.initial) {
            return Scaffold(
              appBar: CaminoNinjaAppBar(
                title: AppLocalizations.of(context).accommodations,
              ),
              body: const Center(child: LoadingWidget()),
            );
          }
          LatLng? fallbackTarget;
          if (state.city?.latitude != null && state.city?.longitude != null) {
            fallbackTarget = LatLng(
              state.city!.latitude,
              state.city!.longitude,
            );
          }
          return CityFullMapScreen(
            arguments: CityFullMapScreenArguments(
              city: state.city,
              fallbackTarget: fallbackTarget,
              routePoints: state.routePoints,
              albergues: state.albergues,
              altRoutePoints: state.altRoutePoints,
              routeId: routeId,
            ),
          );
        },
      ),
    );
  }
}
