import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/cubit/select_starting_point_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_starting_point/cubit/use_my_location_container.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_accuracy_dialog.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_service_dialog.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const maxAllowedDistance = 5000;

class SelectStartingPointScreen extends StatelessWidget {
  const SelectStartingPointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return BlocProvider(
          create: (context) => SelectStartingPointCubit(
            selectedRoute: appState.selectedRoute!,
            selectedStartingPoint: appState.selectedStartingPoint,
          )..filterCities(),
          child: _SelectStartingPointBody(appState: appState),
        );
      },
    );
  }
}

class _SelectStartingPointBody extends StatefulWidget {
  const _SelectStartingPointBody({required this.appState});

  final AppState appState;

  @override
  State<_SelectStartingPointBody> createState() =>
      __SelectStartingPointBodyState();
}

class __SelectStartingPointBodyState extends State<_SelectStartingPointBody> {
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  StreamSubscription<int?>? _nearestCitySubscription;

  @override
  void initState() {
    super.initState();
    _nearestCitySubscription = context
        .read<SelectStartingPointCubit>()
        .nearestCityIndexStream
        .listen((index) {
      if (index != null && index >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final positions =
              _itemPositionsListener.itemPositions.value;
          final alreadyVisible = positions.any(
            (p) =>
                p.index == index &&
                p.itemLeadingEdge >= 0 &&
                p.itemTrailingEdge <= 1,
          );
          if (alreadyVisible) return;
          _itemScrollController.scrollTo(
            index: index,
            duration: Durations.medium2,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _nearestCitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _showAccuracyDialog(
    BuildContext mainContext, {
    bool isSelectCurrentLocation = false,
  }) async {
    if (!mounted) return;

    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return LocationAccuracyDialog(
          onAllow:
              mainContext.read<SelectStartingPointCubit>().selectNearestCity,
          onDeny: (permanentlyDenied) async {
            await GetIt.instance<Repository>()
                .setLocationAccuracyDenied(permanentlyDenied);
            late final bool result;
            if (permanentlyDenied) {
              result = await mainContext
                  .read<SelectStartingPointCubit>()
                  .selectNearestCity();
            } else {
              result = await mainContext
                  .read<SelectStartingPointCubit>()
                  .selectNearestCity(
                    locationAccuracyOff: true,
                  );
            }
            if (result && isSelectCurrentLocation) {
              await _onUseCurrentLocation();
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectStartingPointCubit, SelectStartingPointState>(
      listener: (context, state) async {
        if (state.accuracyDenied) {
          await _showAccuracyDialog(
            context,
            isSelectCurrentLocation: state.isSelectCurrentLocation,
          );
        } else {
          if (state.isSelectCurrentLocation) {
            await _onUseCurrentLocation();
          }
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Scaffold(
              appBar: CaminoNinjaAppBar(
                titleWidget: StepTitle(
                  step: 2,
                  title: AppLocalizations.of(context).startHereToday,
                ),
              ),
              body: Column(
                children: [
                  UseMyLocationContainer(onTap: _onUseCurrentLocation),
                  SearchField(
                    onChanged: (value) {
                      context
                          .read<SelectStartingPointCubit>()
                          .searchCities(value);
                    },
                  ),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (state.filteredCities.isEmpty) {
                          return const EmplyStateWidget();
                        }

                        return ScrollablePositionedList.builder(
                          padding: const EdgeInsets.only(
                            bottom: 24,
                          ),
                          itemScrollController: _itemScrollController,
                          itemPositionsListener: _itemPositionsListener,
                          itemCount: state.filteredCities.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                StartingPointListItem(
                                  isSelected: state.selectedStartingPoint?.id ==
                                      state.filteredCities[index].id,
                                  name: state.filteredCities[index].name,
                                  onClick: () {
                                    context
                                        .read<AppCubit>()
                                        .onSelectStartingPoint(
                                          cityId:
                                              state.filteredCities[index].id,
                                        );
                                    context.pop();
                                  },
                                ),
                                const Divider(
                                  height: 1,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (state.initStatus == SelectStartingPointInitStatus.loading)
              const ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: LoadingWidget(),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _onUseCurrentLocation() async {
    final cubit = context.read<SelectStartingPointCubit>();
    final state = cubit.state;

    if (!mounted) return;

    if (state.nearestCity == null || state.nearestCityDistance == null) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const LocationServiceDialog(
            shouldShowDoNotShowAgain: false,
          );
        },
      );
      return;
    }

    if (state.nearestCityDistance! > maxAllowedDistance) {
      // 50km in meters
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${AppLocalizations.of(context).youAreTooFar}...',
                style: context.textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context).youAreDistanceFromCity(
                        state.nearestCity!.name,
                        (state.nearestCityDistance! / 1000).toStringAsFixed(2),
                      ),
                      style: context.textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: widget.appState.selectedRoute!.routeName,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppLocalizations.of(context).appNotBelieveYouAreOnRoute(
                  widget.appState.selectedRoute!.routeName,
                ),
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            CustomButton(
              text: AppLocalizations.of(context).returnToAllLocations,
              onTap: () => context.pop(),
            ),
          ],
        ),
      );
      return;
    }

    await context.read<AppCubit>().onSelectStartingPoint(
          cityId: state.nearestCity!.id,
        );
    if (!mounted) return;
    context.pop();
  }
}

class StartingPointListItem extends StatelessWidget {
  const StartingPointListItem({
    required this.name,
    required this.onClick,
    this.isSelected = false,
    super.key,
  });

  final String name;
  final VoidCallback onClick;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.primary80 : AppColors.primary40,
                    ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/ic_check_circle.svg',
                width: 24,
                color: isDark ? AppColors.primary80 : AppColors.primary40,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
