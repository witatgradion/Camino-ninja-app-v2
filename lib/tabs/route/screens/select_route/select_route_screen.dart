import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_route/cubit/select_route_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_route/widgets/select_route_map_widget.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:camino_ninja_flutter/widgets/select_route_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storage/storage.dart';

class SelectRouteScreen extends StatefulWidget {
  const SelectRouteScreen({super.key});

  @override
  State<SelectRouteScreen> createState() => _SelectRouteScreenState();
}

class _SelectRouteScreenState extends State<SelectRouteScreen> {
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (_, appState) {
        return BlocProvider(
          create: (context) =>
              SelectRouteCubit()..fetchRoutes(appState.selectedRoute?.id),
          child: Scaffold(
            appBar: CaminoNinjaAppBar(
              titleWidget: StepTitle(
                step: 1,
                title: AppLocalizations.of(context).selectRoute,
              ),
            ),
            body: BlocListener<SelectRouteCubit, SelectRouteState>(
              listenWhen: (previous, current) =>
                  previous.selectedIndex != current.selectedIndex,
              listener: (context, state) {
                if (state.selectedIndex != null && state.selectedIndex! >= 0) {
                  final targetIndex = state.selectedIndex ?? 0;
                  final positions =
                      _itemPositionsListener.itemPositions.value;
                  final alreadyVisible = positions.any(
                    (p) =>
                        p.index == targetIndex &&
                        p.itemLeadingEdge >= 0 &&
                        p.itemTrailingEdge <= 1,
                  );
                  if (alreadyVisible) return;
                  _itemScrollController.scrollTo(
                    index: targetIndex,
                    duration: Durations.medium2,
                  );
                }
              },
              child: BlocBuilder<SelectRouteCubit, SelectRouteState>(
                builder: (context, state) {
                  if (state.initStatus == SelectRouteInitStatus.loading) {
                    return const Center(
                      child: LoadingWidget(),
                    );
                  }
                  if (state.initStatus == SelectRouteInitStatus.success) {
                    return Column(
                      children: [
                        SearchField(
                          onChanged: (value) {
                            context
                                .read<SelectRouteCubit>()
                                .searchRoutes(value);
                          },
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              Builder(
                                builder: (context) {
                                  if (state.filteredRoutes.isEmpty) {
                                    return const EmplyStateWidget();
                                  }
                                  final selectedRouteIdForUi =
                                      appState.selectedRoute?.id ??
                                          state.selectedRouteId;
                                  return IndexedStack(
                                    index: state.selectedMode.index,
                                    children: [
                                      ScrollablePositionedList.builder(
                                        itemScrollController:
                                            _itemScrollController,
                                        itemPositionsListener:
                                            _itemPositionsListener,
                                        padding: const EdgeInsets.only(
                                          bottom: 24,
                                        ),
                                        itemCount:
                                            state.filteredRoutes.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              RouteListItem(
                                                isSelected:
                                                    selectedRouteIdForUi ==
                                                    state.filteredRoutes[index]
                                                        .routeId,
                                                unit: appState.unit,
                                                travelRouteData: state
                                                    .filteredRoutes[index],
                                                onClick: () {
                                                  context
                                                      .read<AppCubit>()
                                                      .onSelectRoute(
                                                        routeId: state
                                                            .filteredRoutes[
                                                                index]
                                                            .routeId,
                                                      );
                                                  context.pop();
                                                },
                                              ),
                                              const Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                      SelectRouteMapWidget(
                                        filteredRoutes:
                                            state.filteredRoutes,
                                        routePointsByRouteId:
                                            state.routePointsByRouteId,
                                        selectedRouteId:
                                            selectedRouteIdForUi,
                                        isSearchActive:
                                            state.isSearchActive,
                                        isDarkMode: context.isDarkMode,
                                        unit: appState.unit,
                                        onRouteSelected: (routeId) {
                                          context
                                              .read<AppCubit>()
                                              .onSelectRoute(
                                                routeId: routeId,
                                              );
                                          context.pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              if (state.filteredRoutes.isNotEmpty)
                                Positioned(
                                  top: 8,
                                  right: 16,
                                  child: SelectRouteModeFab(
                                    currentMode: state.selectedMode,
                                    onToggle: () {
                                      context
                                          .read<SelectRouteCubit>()
                                          .changeMode(
                                            state.selectedMode.toggled,
                                          );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Text(AppLocalizations.of(context).error);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class RouteListItem extends StatelessWidget {
  const RouteListItem({
    required this.travelRouteData,
    required this.onClick,
    required this.unit,
    this.isSelected = false,
    super.key,
  });

  final RouteDistanceElevation travelRouteData;
  final VoidCallback onClick;
  final UnitEnum unit;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final distance = UnitConverter.displayDistance(
      kilometers: travelRouteData.distance,
      unit: unit,
    );

    final minElevation = UnitConverter.displayElevation(
      meters: travelRouteData.minElevation.toDouble(),
      unit: unit,
    );
    final maxElevation = UnitConverter.displayElevation(
      meters: travelRouteData.maxElevation.toDouble(),
      unit: unit,
    );
    final elevationGain = UnitConverter.displayElevation(
      meters: travelRouteData.elevationGain.toDouble(),
      unit: unit,
    );
    final elevationLoss = UnitConverter.displayElevation(
      meters: travelRouteData.elevationLoss.toDouble(),
      unit: unit,
    );

    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    travelRouteData.routeName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.primary80
                              : AppColors.primary40,
                        ),
                    textAlign: TextAlign.left,
                  ),
                  if (travelRouteData.routeSubName?.isNotEmpty ?? false)
                    RouteNameText(
                      routeSubName: travelRouteData.routeSubName!,
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.primary80
                                    : AppColors.primary40,
                              ),
                    ),
                  Text(
                    '${AppLocalizations.of(context).distance_344}: $distance',
                  ),
                  Text(
                    '${AppLocalizations.of(context).minMaxElevRouteScreen}: $minElevation/$maxElevation',
                  ),
                  Text(
                    '${AppLocalizations.of(context).elevationGainLossRouteScreen}: $elevationGain/-$elevationLoss',
                  ),
                ],
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
