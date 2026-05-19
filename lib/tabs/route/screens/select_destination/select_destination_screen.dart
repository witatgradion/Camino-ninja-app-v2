import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/tabs/route/screens/select_destination/cubit/select_destination_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/city_list_item.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class SelectDestinationScreen extends StatelessWidget {
  const SelectDestinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return BlocProvider(
          create: (context) => SelectDestinationCubit(
            selectedStartingPoint: appState.selectedStartingPoint!,
            selectedRoute: appState.selectedRoute!,
            selectedDestination: appState.selectedDestination,
          )..filterDestinations(),
          child: const SelectDestinationBody(),
        );
      },
    );
  }
}

class SelectDestinationBody extends StatefulWidget {
  const SelectDestinationBody({super.key});

  @override
  State<SelectDestinationBody> createState() => _SelectDestinationBodyState();
}

class _SelectDestinationBodyState extends State<SelectDestinationBody> {
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  StreamSubscription<int?>? _selectedDestinationSubscription;

  @override
  void initState() {
    super.initState();
    _selectedDestinationSubscription = context
        .read<SelectDestinationCubit>()
        .nearestCityIndexStream
        .listen((index) {
      if (index != null && index >= 0) {
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
      }
    });
  }

  @override
  void dispose() {
    _selectedDestinationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectDestinationCubit, SelectDestinationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CaminoNinjaAppBar(
            titleWidget: StepTitle(
              step: 3,
              title: AppLocalizations.of(context).goToHereToday,
            ),
          ),
          body: Column(
            children: [
              DestinationFilter(
                selectedValue: state.cityFilter,
                onChanged: (newValue) {
                  context.read<SelectDestinationCubit>().changeCityFilter(
                        newValue,
                      );
                },
              ),
              SearchField(
                onChanged: (value) {
                  context
                      .read<SelectDestinationCubit>()
                      .filterDestinations(query: value, isInitial: false);
                },
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isLoading = state.initStatus ==
                            SelectDestinationInitStatus.loading ||
                        state.filteringStatus ==
                            SelectDestinationFilteringStatus.loading;
                    if (isLoading) {
                      return const LoadingWidget();
                    }
                    if (state.destinationData.isEmpty) {
                      return const EmplyStateWidget();
                    }
                    return ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      padding: const EdgeInsets.only(
                        bottom: 24,
                      ),
                      itemCount: state.destinationData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            CityListItem(
                              percentage: context
                                  .read<SelectDestinationCubit>()
                                  .getPercentage(
                                      state.destinationData[index].id),
                              cityPairRank: context
                                  .read<SelectDestinationCubit>()
                                  .cityPairRankFor(
                                    state.destinationData[index].id,
                                  ),
                              startCityName: state.startCityName,
                              isSelected: state.selectedDestination?.id ==
                                  state.destinationData[index].id,
                              showTrailingIcon: false,
                              destination: state.destinationData[index],
                              onClick: () {
                                context.pop();
                                context.read<AppCubit>().onSelectDestination(
                                      cityId: state.destinationData[index].id,
                                    );
                              },
                            ),
                            const Divider(height: 1),
                          ],
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
    );
  }
}

class DestinationFilter extends StatelessWidget {
  const DestinationFilter({
    required this.selectedValue,
    required this.onChanged,
    super.key,
  });

  final CityFilter selectedValue;
  final ValueChanged<CityFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: DestinationRadioListItem(
              value: CityFilter.accommodation,
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
          ),
          Expanded(
            child: DestinationRadioListItem(
              value: CityFilter.all,
              groupValue: selectedValue,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationRadioListItem extends StatelessWidget {
  const DestinationRadioListItem({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  final CityFilter value;
  final CityFilter groupValue;
  final ValueChanged<CityFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    var color = isDarkMode ? AppColors.gray600 : AppColors.gray100;
    final isSelected = value == groupValue;
    if (isSelected) {
      color = isDarkMode ? AppColors.gray700 : AppColors.gray200;
    }
    return Ink(
      color: color,
      child: InkWell(
        onTap: () {
          onChanged(value);
        },
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.gray50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? (isDarkMode ? AppColors.primary80 : AppColors.primary40)
                      : AppColors.gray300,
                  width: isSelected ? 3.5 : 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value == CityFilter.accommodation
                    ? AppLocalizations.of(context).citiesAccommodation
                    : AppLocalizations.of(context).allCities,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
