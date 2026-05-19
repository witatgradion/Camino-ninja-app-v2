import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/distance_screen.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

class DistanceRouteScreen extends StatelessWidget {
  const DistanceRouteScreen({
    required this.routeId,
    required this.destinationCityId,
    super.key,
  });

  final int routeId;
  final int destinationCityId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CityEntity>(
      future: GetIt.instance<Repository>().getCityByIdFromDb(destinationCityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: LoadingWidget()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: CaminoNinjaAppBar(
              title: AppLocalizations.of(context).distance_344,
            ),
            body: Center(
              child: Text(AppLocalizations.of(context).oopsSomethingWentWrong),
            ),
          );
        }
        return DistanceScreen(
          arguments: DistanceScreenArguments(
            routeId: routeId,
            destinationCity: snapshot.data!,
            unit: context.read<AppCubit>().state.unit,
            title: AppLocalizations.of(context).distance_344,
          ),
        );
      },
    );
  }
}
