import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_list_icon_full.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/albergue_list_price.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_information_card.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_map.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/cubit/city_details_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/favorite_button/favorite_button.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_bottomsheet.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_type.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/booking_com_button.dart';
import 'package:camino_ninja_flutter/widgets/booking_com_rating.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/ninja_rating.dart';
import 'package:camino_ninja_flutter/widgets/reserve_button.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:storage/storage.dart';

class CityDetailsScreen extends StatefulWidget {
  const CityDetailsScreen({
    required this.cityId,
    super.key,
  });

  final int cityId;

  @override
  State<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends State<CityDetailsScreen> {
  late TopNotificationController _topNotificationController;
  bool _viewTracked = false;

  @override
  void initState() {
    super.initState();
    _topNotificationController = TopNotificationController();
  }

  void _maybeTrackViewed(CityDetailsState state, int? routeId) {
    if (_viewTracked) return;
    if (state.status != CityDetailsStatus.loaded) return;
    final city = state.city;
    if (city == null) return;
    _viewTracked = true;

    GetIt.instance<IAnalyticsService>().track(
      CityDetailsViewedEvent(
        cityId: city.id,
        cityName: city.name,
        routeId: routeId,
        numAccommodations: state.albergues.length,
      ),
    );
  }

  @override
  void dispose() {
    _topNotificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return BlocProvider(
          create: (context) => CityDetailsCubit(
            cityId: widget.cityId,
            routeId: appState.selectedRoute!.id,
          )..init(),
          child: BlocConsumer<CityDetailsCubit, CityDetailsState>(
            listener: (context, state) {
              _maybeTrackViewed(state, appState.selectedRoute?.id);
            },
            builder: (context, state) {
              if (state.status == CityDetailsStatus.loading ||
                  state.status == CityDetailsStatus.initial) {
                return Scaffold(
                  appBar: CaminoNinjaAppBar(
                    title: AppLocalizations.of(context).accommodations,
                  ),
                  body: const Center(
                    child: LoadingWidget(),
                  ),
                );
              }

              LatLng? fallbackTarget;
              if (state.city?.latitude != null &&
                  state.city?.longitude != null) {
                fallbackTarget = LatLng(
                  state.city!.latitude,
                  state.city!.longitude,
                );
              }

              return Scaffold(
                appBar: CaminoNinjaAppBar(
                  title: AppLocalizations.of(context).accommodations,
                ),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        SearchField(
                          onChanged: (value) {
                            context
                                .read<CityDetailsCubit>()
                                .searchAlbergues(value);
                          },
                        ),
                        CityInformationCard(
                          city: state.city,
                          services: state.services,
                        ),
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 24,
                                    top: 16,
                                    bottom: 12,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).accommodations,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
                              if (state.albergues.isEmpty) ...[
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 32,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .thereIsNoAccommodationInThisLocation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                              if (state.filteredAlbergues.isEmpty &&
                                  state.albergues.isNotEmpty) ...[
                                const SliverToBoxAdapter(
                                  child: EmplyStateWidget(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 32,
                                    ),
                                  ),
                                ),
                              ],
                              if (state.filteredAlbergues.isNotEmpty)
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      return AccommodationListItem(
                                        albergue:
                                            state.filteredAlbergues[index],
                                        cityId: widget.cityId,
                                        routeId: appState.selectedRoute!.id,
                                        onClick: () {
                                          context.push(
                                            '/albergue-details',
                                            extra:
                                                AlbergueDetailsScreenArguments(
                                              albergueId: state
                                                  .filteredAlbergues[index].id,
                                              routeId:
                                                  appState.selectedRoute!.id,
                                              cityId: widget.cityId,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: state.filteredAlbergues.length,
                                  ),
                                ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    top: 16,
                                  ),
                                  child: CustomButton(
                                    text: AppLocalizations.of(context)
                                        .reportMissingAccommodation,
                                    onTap: () =>
                                        _showReportBottomsheet(context),
                                  ),
                                ),
                              ),
                              if (state.status == CityDetailsStatus.loaded)
                                SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      if (state.albergues.isNotEmpty) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .seeThemOnTheMap,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      RepaintBoundary(
                                        child: CityMap(
                                          state: state,
                                          routeId: appState.selectedRoute!.id,
                                          fallbackTarget: fallbackTarget,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        const LoadingWidget(),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppLocalizations.of(context)
                                              .fetchingRoutesAndMarkers,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    TopNotificationOverlay(
                      controller: _topNotificationController,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showReportBottomsheet(BuildContext context) async {
    final result = await showReviewFeedbackBottomSheet(
      context,
      type: ReviewFeedbackType.missingAccommodation,
      cityId: widget.cityId,
    );
    if (!context.mounted) {
      return;
    }
    if (result != null) {
      if (result) {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.reportSuccess,
        );
      } else {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.reportError,
        );
      }
    }
  }
}

class AccommodationListItem extends StatelessWidget {
  const AccommodationListItem({
    required this.albergue,
    required this.onClick,
    required this.cityId,
    required this.routeId,
    this.onFavoriteChanged,
    super.key,
  });

  final AlbergueEntity albergue;
  final int cityId;
  final int routeId;
  final VoidCallback onClick;
  final ValueChanged<bool>? onFavoriteChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bookingComUrl = albergue.bookingComUrl ?? '';
    final reserveUrl = albergue.reserveUrl ?? '';

    final bookingRating = albergue.reviews.firstOrNull?.bReviewScore ?? 0;
    final ninjaRating = albergue.ninjaRating ?? 0;

    final isBookingComUrlValid = isLaunchableUrl(bookingComUrl);

    return Ink(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.gray800 : AppColors.gray200,
          ),
        ),
      ),
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 24),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 44),
                    child: Text(
                      albergue.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.primary80
                                : AppColors.primary40,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 44),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        StatusIndicator.buildIndicator(
                          context,
                          isUnknownOpenSeason: albergue.operatingHours
                                  .firstOrNull?.unknownOpenSeason ??
                              false,
                          opensAllYear: albergue
                                  .operatingHours.firstOrNull?.opensAllYear ??
                              false,
                          isWithinOpenSeason: albergue.isWithinOpenSeason(),
                          status: albergue.status,
                          opensDate: (albergue
                                          .operatingHours.firstOrNull?.opens !=
                                      null &&
                                  albergue.operatingHours.firstOrNull?.opens !=
                                      '')
                              ? DateTime.parse(
                                  albergue.operatingHours.first.opens!,
                                )
                              : null,
                        ),
                        if (ninjaRating != 0) ...[
                          NinjaRating(
                            rating: ninjaRating,
                            showInisdeRating: true,
                          ),
                        ],
                        if (isBookingComUrlValid && bookingRating != 0) ...[
                          BookingComRating(
                            rating: bookingRating,
                            albergue: albergue,
                            routeId: routeId,
                            showInisdeRating: true,
                            surface: BookingEntrySurface.routeBrowse,
                            clickWidget:
                                BookingClickWidget.cityDetailsRatingChip,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (albergue.prices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AlbergueListPrice(price: albergue.prices.first),
                  ],
                  if (albergue.facilities.firstOrNull != null) ...[
                    const SizedBox(height: 8),
                    AlbergueListIconsFull(
                      albergue: albergue,
                    ),
                  ],
                  if (bookingComUrl.isNotEmpty || reserveUrl.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      runSpacing: 8,
                      spacing: 8,
                      children: [
                        if (isBookingComUrlValid) ...[
                          BookingComButton(
                            albergue: albergue,
                            routeId: routeId,
                            surface: BookingEntrySurface.routeBrowse,
                            clickWidget: BookingClickWidget.cityDetailsButton,
                          ),
                        ],
                        if (reserveUrl.isNotEmpty) ...[
                          ReserveButton(
                            reserveUrl: reserveUrl,
                            source: 'route',
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: FavoriteButton(
                  albergue: albergue,
                  cityId: cityId,
                  routeId: routeId,
                  onFavoriteChanged: onFavoriteChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum IndicatorStatus {
  red,
  orange,
  yellow,
  green,
  none;

  String title(BuildContext context) {
    return switch (this) {
      IndicatorStatus.red => AppLocalizations.of(context).closed,
      IndicatorStatus.green => AppLocalizations.of(context).open,
      IndicatorStatus.yellow => AppLocalizations.of(context).openSeasonUnknown,
      _ => '',
    };
  }
}

class StatusIndicator {
  // Helper method to determine indicator status
  static IndicatorStatus getIndicatorStatus({
    required int? status,
    bool? isWithinOpenSeason,
    bool opensAllYear = false,
    bool? isUnknownOpenSeason,
    DateTime? opensDate,
    DateTime? compareDate,
  }) {
    if (opensAllYear) {
      return IndicatorStatus.green;
    }
    if (isUnknownOpenSeason ?? false) {
      return IndicatorStatus.yellow;
    }
    final currentDate = compareDate ?? DateTime.now();
    // Case 1: Red indicator conditions
    if (isWithinOpenSeason == false ||
        status == 3 ||
        status == 2 ||
        status == 6 ||
        status == 8) {
      return IndicatorStatus.red;
    }

    // Case 2: Orange indicator conditions
    if (opensDate != null && opensDate.isAfter(currentDate)) {
      return IndicatorStatus.orange;
    }

    // Case 3: Green indicator conditions
    if (isWithinOpenSeason ?? false) {
      return IndicatorStatus.green;
    }

    // Default case: no indicator
    return IndicatorStatus.none;
  }

  // Helper method to get color based on status
  static Color getIndicatorColor(BuildContext context, IndicatorStatus status) {
    switch (status) {
      case IndicatorStatus.red:
        return Colors.red;
      case IndicatorStatus.orange:
        return Colors.orange;
      case IndicatorStatus.yellow:
        return context.isDarkMode ? AppColors.yellow300 : AppColors.yellow400;
      case IndicatorStatus.green:
        return Colors.green;
      case IndicatorStatus.none:
        return Colors.transparent;
    }
  }

  // Build the indicator widget
  static Widget buildIndicator(
    BuildContext context, {
    required int? status,
    bool? isWithinOpenSeason,
    bool? isUnknownOpenSeason,
    DateTime? opensDate,
    String? distanceInfo,
    bool opensAllYear = false,
    DateTime? compareDate,
  }) {
    final indicatorStatus = getIndicatorStatus(
      isUnknownOpenSeason: isUnknownOpenSeason,
      opensAllYear: opensAllYear,
      isWithinOpenSeason: isWithinOpenSeason,
      status: status,
      opensDate: opensDate,
      compareDate: compareDate,
    );
    if (indicatorStatus == IndicatorStatus.none ||
        indicatorStatus == IndicatorStatus.orange) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          color: getIndicatorColor(context, indicatorStatus),
          size: 10,
        ),
        const SizedBox(width: 5),
        Text(
          indicatorStatus.title(context),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: getIndicatorColor(context, indicatorStatus),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
