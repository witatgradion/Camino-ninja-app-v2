import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/favorite_button/cubit/favorite_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/saved_accommodations/cubit/saved_accommodations_cubit.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SavedAccommodationsScreen extends StatelessWidget {
  const SavedAccommodationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedAccommodationsCubit(
        onSyncComplete: () {
          context.read<FavoritesCubit>().loadAllFavorites();
        },
      )..init(),
      child: BlocBuilder<SavedAccommodationsCubit, SavedAccommodationsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CaminoNinjaAppBar(
              title: AppLocalizations.of(context).savedAccommodations,
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SearchField(
                  onChanged: (value) {
                    context
                        .read<SavedAccommodationsCubit>()
                        .filterAlbergues(value);
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.albergues?.isEmpty ?? true) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 24,
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)
                                  .noSavedAccommodationYet,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (state.filteredAlbergues?.isEmpty ?? true) {
                        return const EmplyStateWidget();
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                        ),
                        itemCount: state.filteredAlbergues?.length ?? 0,
                        itemBuilder: (context, index) {
                          final albergue = state.filteredAlbergues![index];
                          return AccommodationListItem(
                            cityId: albergue.externalCityId ?? 0,
                            routeId: albergue.externalRouteId ?? 0,
                            albergue: albergue,
                            onFavoriteChanged: (value) {
                              if (!value) {
                                context
                                    .read<SavedAccommodationsCubit>()
                                    .removeAlbergue(
                                        state.filteredAlbergues![index],);
                              }
                            },
                            onClick: () {
                              context
                                  .push(
                                '/more/albergue-details',
                                extra: AlbergueDetailsScreenArguments(
                                  albergueId: albergue.id,
                                  cityId: albergue.externalCityId ?? 0,
                                  routeId: albergue.externalRouteId ?? 0,
                                  navScope: AlbergueDetailsNavScope.moreTab,
                                ),
                              )
                                  .then(
                                (value) {
                                  if (context.mounted) {
                                    context
                                        .read<SavedAccommodationsCubit>()
                                        .refresh();
                                  }
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
