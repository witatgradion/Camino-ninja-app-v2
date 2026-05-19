import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/alberbue_map_section.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_address_section.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_images.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_main_section.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_setting_section.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_top_controls.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/cubit/albergue_details_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/map_options_bottom_sheet.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/reviews_section.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_bottomsheet.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_type.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/geo_link_generator.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/required_upgrade_dialog.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/login_required_bottomsheet.dart';
import 'package:camino_ninja_flutter/widgets/photo_picker.dart';
import 'package:camino_ninja_flutter/widgets/stay_here_button.dart';
import 'package:camino_ninja_flutter/widgets/top_notification_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:share_plus/share_plus.dart';
import 'package:storage/storage.dart';

class AlbergueDetailsScreenArguments {
  const AlbergueDetailsScreenArguments({
    required this.albergueId,
    this.cityId,
    this.routeId,
    this.scrollToReviewId,
    this.isStagePlannerFlow = false,
    this.compareDate,
    this.isSelected = false,
    this.requestReview = false,
    this.onSelectedAlbergueChanged,
    this.navScope = AlbergueDetailsNavScope.routeTab,
  });
  final int albergueId;
  final int? cityId;
  final int? routeId;

  /// After reviews load, scroll to this review (e.g. push approval deep link).
  final int? scrollToReviewId;
  final bool isStagePlannerFlow;
  final DateTime? compareDate;
  final bool isSelected;
  final bool requestReview;
  final VoidCallback? onSelectedAlbergueChanged;
  final AlbergueDetailsNavScope navScope;
}

class AlbergueDetailsScreen extends StatefulWidget {
  const AlbergueDetailsScreen({
    required this.arguments,
    super.key,
  });

  final AlbergueDetailsScreenArguments arguments;

  @override
  State<AlbergueDetailsScreen> createState() => _AlbergueDetailsScreenState();
}

class _AlbergueDetailsScreenState extends State<AlbergueDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AlbergueDetailsCubit _albergueDetailsCubit;
  late ScrollController _scrollController;
  late TopNotificationController _topNotificationController;
  final GlobalKey _reviewScrollTargetKey = GlobalKey();
  bool _isShowingPhotoPreview = false;
  String? _lastLanguageForReviews;
  bool _didScrollToTargetReview = false;
  bool _suppressReviewAnchor = false;
  int _reviewScrollAutoLoadAttempts = 0;
  late AnimationController _reviewHighlightController;
  late Animation<double> _reviewHighlightAnimation;
  bool _viewTracked = false;
  bool _didRequestReview = false;

  String get _source =>
      widget.arguments.isStagePlannerFlow ? 'stage_planner' : 'route';

  BookingEntrySurface get _bookingSurface => widget.arguments.isStagePlannerFlow
      ? BookingEntrySurface.stagePlanner
      : BookingEntrySurface.routeBrowse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastLanguageForReviews ??= context.read<AppCubit>().state.language;
  }

  @override
  void initState() {
    super.initState();
    _topNotificationController = TopNotificationController();
    _albergueDetailsCubit = AlbergueDetailsCubit(
      albergueId: widget.arguments.albergueId,
      cityId: widget.arguments.cityId,
      routeId: widget.arguments.routeId,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _reviewHighlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _reviewHighlightAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _reviewHighlightController,
        curve: Curves.easeInOut,
      ),
    );
    _reviewHighlightController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _suppressReviewAnchor = true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _reviewHighlightController.dispose();
    _topNotificationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // TODO: disable load more reviews now. We'll load all reviews at a time
    // Will enable it in feature if the reviews increase significantly.
    // if (!_scrollController.hasClients) return;

    // final context = this.context;
    // if (!context.mounted) return;

    // final state = _albergueDetailsCubit.state;

    // // Don't proceed if we can't load more or are already loading
    // if (!state.canLoadMoreReviews ||
    //     state.loadMoreReviewsStatus == LoadMoreReviewsStatus.loading) {
    //   return;
    // }

    // final position = _scrollController.position;
    // final maxScroll = position.maxScrollExtent;
    // final currentScroll = position.pixels;
    // final isScrollingUp =
    //     position.userScrollDirection == ScrollDirection.forward;

    // // Calculate if we're in the reviews area (last 50% of content)
    // final reviewsThreshold = maxScroll * 0.5;
    // final isInReviewsArea = currentScroll >= reviewsThreshold;

    // // Load more when:
    // // 1. We're in the reviews area (last 50% of content) AND scrolling up
    // // OR
    // // 2. We're very close to the bottom (within 100px) regardless of scroll direction
    // if ((isInReviewsArea && isScrollingUp) ||
    //     (currentScroll >= maxScroll - 100)) {
    //   _albergueDetailsCubit.loadMoreReviews();
    // }
  }

  void _maybeTrackViewed(AlbergueDetailsState state) {
    if (_viewTracked) return;
    final albergue = state.albergue;
    if (albergue == null) return;
    _viewTracked = true;

    final bookingRating = albergue.reviews.firstOrNull?.bReviewScore ?? 0.0;
    final ninjaRating = albergue.ninjaRating ?? 0.0;
    final resolvedCityId = state.resolvedCityId ?? albergue.cityId;

    GetIt.instance<IAnalyticsService>().track(
      AlbergueDetailsViewedEvent(
        albergueId: albergue.id,
        albergueName: albergue.name,
        cityId: resolvedCityId,
        cityName: albergue.cityName,
        routeId: state.resolvedRouteId,
        entrySurface: _bookingSurface,
        hasBookingComUrl: isLaunchableUrl(albergue.bookingComUrl),
        hasBookingPrice: (albergue.bookingPrice ?? 0) > 0,
        bookingRating: bookingRating,
        ninjaRating: ninjaRating,
      ),
    );
  }

  void _maybeRequestReview(
    BuildContext context,
    AlbergueDetailsState state,
  ) {
    if (!widget.arguments.requestReview || _didRequestReview) return;
    if (widget.arguments.scrollToReviewId != null) return;
    if (state.loading || state.albergue == null) return;
    // Flip before scheduling; otherwise repeated emissions could double-fire.
    _didRequestReview = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onRateAccommodationClick(state);
    });
  }

  void _maybeScrollToApprovedReview(
    BuildContext context,
    AlbergueDetailsState state,
  ) {
    final targetId = widget.arguments.scrollToReviewId;
    if (targetId == null || _didScrollToTargetReview) return;

    switch (state.loadReviewsStatus) {
      case LoadReviewsStatus.loading:
      case LoadReviewsStatus.initial:
        return;
      case LoadReviewsStatus.error:
      case LoadReviewsStatus.offline:
        _didScrollToTargetReview = true;
        return;
      case LoadReviewsStatus.loaded:
        break;
    }

    if (state.loadMoreReviewsStatus == LoadMoreReviewsStatus.loading) {
      return;
    }
    if (state.loadMoreReviewsStatus == LoadMoreReviewsStatus.error) {
      _didScrollToTargetReview = true;
      return;
    }

    final idx = state.reviews.indexWhere((r) => r.id == targetId);
    if (idx >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final targetContext = _reviewScrollTargetKey.currentContext;
          if (targetContext != null) {
            // Reviews are inside [SingleChildScrollView]; avoid nested
            // [ListView] so [Scrollable.ensureVisible] hits this scrollable.
            Scrollable.ensureVisible(
              targetContext,
              alignment: 0.12,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOut,
            );
            if (mounted) {
              setState(() => _didScrollToTargetReview = true);
            }
            Future<void>.delayed(const Duration(milliseconds: 450), () {
              if (!mounted) return;
              _reviewHighlightController.forward(from: 0);
            });
            return;
          }
          // Target item is not laid out yet (e.g. after list mutation). Retry.
          if (!_didScrollToTargetReview) {
            _maybeScrollToApprovedReview(context, state);
          }
        });
      });
      return;
    }

    if (!state.canLoadMoreReviews) {
      _didScrollToTargetReview = true;
      return;
    }

    if (_reviewScrollAutoLoadAttempts >= 25) {
      _didScrollToTargetReview = true;
      return;
    }

    _reviewScrollAutoLoadAttempts++;
    context.read<AlbergueDetailsCubit>().loadMoreReviews();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final dividerColor = isDark ? const Color(0xFF48454E) : AppColors.gray200;
    return BlocProvider(
      create: (context) => _albergueDetailsCubit
        ..getAlbergue()
        ..getAlbergueImages()
        ..getRoutePoints()
        ..loadReviews()
        ..loadInstalledMaps()
        ..setAlbergueSelected(widget.arguments.isSelected),
      child: BlocListener<AppCubit, AppState>(
        listener: (context, appState) {
          if (appState.language != _lastLanguageForReviews &&
              _albergueDetailsCubit.state.loadReviewsStatus ==
                  LoadReviewsStatus.loaded) {
            _lastLanguageForReviews = appState.language;
            _albergueDetailsCubit.reloadReviewsForNewLocale();
          }
        },
        child: BlocListener<AlbergueDetailsCubit, AlbergueDetailsState>(
          listener: (context, state) {
            _maybeTrackViewed(state);
            _maybeRequestReview(context, state);
            _maybeScrollToApprovedReview(context, state);
            if (state.uploadError != null) {
              if (_isShowingPhotoPreview) {
                context.pop();
                _isShowingPhotoPreview = false;
              }
              if (state.uploadError?.contains('cancellation') ?? false) {
                _topNotificationController.changeNotificationType(
                  TopNotificationBarType.uploadCancel,
                );
              } else {
                _topNotificationController.changeNotificationType(
                  TopNotificationBarType.uploadError,
                );
              }
            }
            if (state.photoUploaded ?? false) {
              if (_isShowingPhotoPreview) {
                context.pop();
                _isShowingPhotoPreview = false;
              }
              _topNotificationController.changeNotificationType(
                TopNotificationBarType.uploadSuccess,
              );
            }
          },
          child: BlocBuilder<AlbergueDetailsCubit, AlbergueDetailsState>(
            builder: (context, state) {
              if (state.loading) {
                return Scaffold(
                  appBar: _buildAppBar(context, null),
                  body: const Center(
                    child: LoadingWidget(),
                  ),
                );
              }

              final albergue = state.albergue;
              if (albergue == null) {
                return Scaffold(
                  appBar: _buildAppBar(context, albergue),
                );
              }

              return Scaffold(
                appBar: _buildAppBar(context, albergue),
                body: Stack(
                  children: [
                    Column(
                      children: [
                        if (widget.arguments.isStagePlannerFlow) ...[
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              StayHereButton(
                                isSelected: state.isSelected,
                                onTap: () {
                                  final newValue = !state.isSelected;
                                  widget.arguments.onSelectedAlbergueChanged
                                      ?.call();
                                  if (newValue) {
                                    Navigator.pop(context);
                                    return;
                                  }
                                  _albergueDetailsCubit
                                      .setAlbergueSelected(newValue);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        AlbergueTopControls(
                          albergue: state.albergue!,
                          cityId:
                              state.resolvedCityId ?? state.albergue!.cityId,
                          routeId: state.resolvedRouteId,
                          surface: _bookingSurface,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AlbergueMainSection(
                                  albergue: state.albergue!,
                                  surface: _bookingSurface,
                                  routeId: state.resolvedRouteId,
                                ),
                                if (state.routePoints != null) ...[
                                  AlbergueMapSection(
                                    state: state,
                                    albergueId: widget.arguments.albergueId,
                                    cityId: state.resolvedCityId,
                                    routeId: state.resolvedRouteId,
                                    navScope: widget.arguments.navScope,
                                  ),
                                ],
                                if (state.albergue!.address != null) ...[
                                  AlbergueAddressSection(
                                    albergue: state.albergue!,
                                  ),
                                ],
                                if (state.albergueImages.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  Text(
                                    AppLocalizations.of(context).gallery,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  AlbergueImages(
                                    images: state.albergueImages,
                                    navScope: widget.arguments.navScope,
                                  ),
                                  const SizedBox(height: 32),
                                ],
                                AlbergueSettingSection(
                                  albergue: state.albergue!,
                                  supportedMaps: state.supportedMaps,
                                  onRateAccommodationClick: () =>
                                      _onRateAccommodationClick(state),
                                  onUploadPhotosClick: () =>
                                      _onClickUploadPhoto(state),
                                  onHelpUsImproveCaminoNinjaClick: () {
                                    GetIt.instance<IAnalyticsService>().track(
                                      OpenFeedbackEvent(
                                        albergueId: widget.arguments.albergueId,
                                        albergueName: state.albergue!.name,
                                        source: _source,
                                      ),
                                    );
                                    _showFeedbackBottomSheet(context);
                                  },
                                  onTellYourFriendAboutThisPlaceClick: () {
                                    GetIt.instance<IAnalyticsService>().track(
                                      ShareAlbergueEvent(
                                        albergueId: widget.arguments.albergueId,
                                        albergueName: state.albergue!.name,
                                        shareUrl:
                                            state.albergue!.shareUrl ?? '',
                                        source: _source,
                                      ),
                                    );
                                    Share.share(state.albergue!.shareUrl ?? '');
                                  },
                                  onLocateOnOtherMapsClick: () =>
                                      _openMapsBottomSheet(
                                    context,
                                    state.supportedMaps,
                                    state.albergue,
                                  ),
                                  onViewOnMapClick: () {
                                    context.push(
                                      widget.arguments.navScope.fullMapPath(
                                        albergueId: widget.arguments.albergueId,
                                        cityId: widget.arguments.cityId,
                                        routeId: widget.arguments.routeId,
                                      ),
                                    );
                                  },
                                ),
                                Divider(color: dividerColor),
                                ReviewsSection(
                                  reviews: state.reviews,
                                  totalReviews: state.reviewTotal,
                                  isLoadingMore: state.loadMoreReviewsStatus ==
                                      LoadMoreReviewsStatus.loading,
                                  isLoading: state.loadReviewsStatus ==
                                      LoadReviewsStatus.loading,
                                  appLocale:
                                      context.read<AppCubit>().state.language ??
                                          Localizations.localeOf(context)
                                              .languageCode,
                                  scrollToReviewId:
                                      widget.arguments.scrollToReviewId !=
                                                  null &&
                                              !_suppressReviewAnchor
                                          ? widget.arguments.scrollToReviewId
                                          : null,
                                  reviewScrollTargetKey: _reviewScrollTargetKey,
                                  reviewHighlightAnimation:
                                      widget.arguments.scrollToReviewId !=
                                                  null &&
                                              !_suppressReviewAnchor
                                          ? _reviewHighlightAnimation
                                          : null,
                                  navScope: widget.arguments.navScope,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
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
        ),
      ),
    );
  }

  Future<void> _showFeedbackBottomSheet(
    BuildContext context,
  ) async {
    final result = await showReviewFeedbackBottomSheet(
      context,
      type: ReviewFeedbackType.feedbackAlbergue,
      albergueId: widget.arguments.albergueId,
      galleryRoutePath: widget.arguments.navScope.galleryPath,
    );
    if (!context.mounted) {
      return;
    }
    if (result != null) {
      if (result) {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.feedbackSuccess,
        );
      } else {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.feedbackError,
        );
      }
    }
  }

  Future<void> _showAlertDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    final Widget okButton = TextButton(
      child: Text(AppLocalizations.of(context).ok),
      onPressed: () {
        context.pop();
      },
    );

    // set up the AlertDialog
    final alert = AlertDialog(
      title: Text(
        'Please install MAPS.ME application.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      content: Text(
        body,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        okButton,
      ],
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _showReviewBottomSheet(
    BuildContext context,
    AlbergueDetailsState state,
  ) async {
    GetIt.instance<IAnalyticsService>().track(
      OpenReviewEvent(
        albergueId: widget.arguments.albergueId,
        albergueName: state.albergue!.name,
        source: _source,
      ),
    );

    final result = await showReviewFeedbackBottomSheet(
      context,
      type: ReviewFeedbackType.reviewAlbergue,
      albergueId: widget.arguments.albergueId,
      galleryRoutePath: widget.arguments.navScope.galleryPath,
    );
    if (!context.mounted) {
      return;
    }
    if (result != null) {
      if (result) {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.reviewSuccess,
        );
      } else {
        _topNotificationController.changeNotificationType(
          TopNotificationBarType.reviewError,
        );
      }
    }
  }

  void _openMapsBottomSheet(
    BuildContext context,
    List<SupportedMaps> supportedMaps,
    AlbergueEntity? albergue,
  ) {
    showMapOptionsBottomSheet(
      context,
      supportedMaps: supportedMaps,
      onMapSelected: (map) {
        context.pop();
        _openMap(context, map, albergue);
      },
    );
  }

  void _openMap(
    BuildContext context,
    SupportedMaps map,
    AlbergueEntity? albergue,
  ) {
    if (map == SupportedMaps.mapsMe) {
      _openMapsMe(context, albergue);
    } else if (map == SupportedMaps.google) {
      _openGoogleMaps(context, albergue);
    } else if (map == SupportedMaps.apple) {
      _openAppleMaps(context, albergue);
    }
  }

  Future<void> _openMapsMe(
    BuildContext context,
    AlbergueEntity? albergue,
  ) async {
    if (albergue?.latitude != null) {
      GetIt.instance<IAnalyticsService>().track(
        OpenMapsMeEvent(
          albergueId: widget.arguments.albergueId,
          albergueName: albergue!.name,
          source: _source,
        ),
      );
      await launchUrlSafely(
        generateMapsMeLink(
          lat: albergue.latitude!,
          lon: albergue.longitude!,
          zoom: 10,
          name: albergue.name,
          shareUrl: albergue.shareUrl ?? '',
        ),
        onError: ({Object? error}) async {
          GetIt.instance<IAnalyticsService>().track(
            OpenMapsMeErrorEvent(
              albergueId: widget.arguments.albergueId,
              albergueName: albergue.name,
              source: _source,
            ),
          );
          if (!context.mounted) return;
          await _showAlertDialog(
            context,
            'Please install MAPS.ME application.',
            'You can download it from the Google '
                'Play Store or the Apple App Store.',
          );
        },
      );
    }
  }

  void _openGoogleMaps(BuildContext context, AlbergueEntity? albergue) {
    if (albergue?.latitude != null && albergue?.longitude != null) {
      map_launcher.MapLauncher.showMarker(
        mapType: map_launcher.MapType.google,
        coords: map_launcher.Coords(
          albergue!.latitude!,
          albergue.longitude!,
        ),
        title: albergue.name,
      );
    }
  }

  void _openAppleMaps(BuildContext context, AlbergueEntity? albergue) {
    if (albergue?.latitude != null && albergue?.longitude != null) {
      map_launcher.MapLauncher.showMarker(
        mapType: map_launcher.MapType.apple,
        coords: map_launcher.Coords(
          albergue!.latitude!,
          albergue.longitude!,
        ),
        title: albergue.name,
      );
    }
  }

  Future<void> _onClickUploadPhoto(AlbergueDetailsState state) async {
    var isLoggedIn = await _albergueDetailsCubit.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      return _showUploadPhotoBottomSheet(state);
    }

    final shouldUpgrade =
        await _albergueDetailsCubit.shouldUpgradeToUseFeature();
    if (!mounted) return;
    if (shouldUpgrade) {
      return showDialog(
        context: context,
        builder: (context) => const RequiredUpgradeDialog(),
      );
    }

    isLoggedIn = (await showLoginRequiredBottomsheet(
          context,
          title: AppLocalizations.of(context).registerForPhotos,
          description: AppLocalizations.of(context).qualityReasonPhotos,
        )) ??
        false;

    if (isLoggedIn) {
      return _showUploadPhotoBottomSheet(state);
    }
  }

  Future<void> _showUploadPhotoBottomSheet(AlbergueDetailsState state) async {
    GetIt.instance<IAnalyticsService>().track(
      UploadAlberguePhotoEvent(
        albergueId: widget.arguments.albergueId,
        albergueName: state.albergue!.name,
        source: _source,
      ),
    );

    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 100,
      maxWidth: 1920,
    );
    if (images.isEmpty || !mounted) {
      return;
    }
    _isShowingPhotoPreview = true;
    await showPhotoPreviewBottomSheet(
      context,
      images: images,
      galleryRoutePath: widget.arguments.navScope.galleryPath,
      uploadingStream: _albergueDetailsCubit.uploadingStream,
      onConfirm: (images) {
        _albergueDetailsCubit.uploadAlberguePhoto(images);
      },
      onCancel: () {
        _albergueDetailsCubit.cancelUpload();
      },
    );
    _isShowingPhotoPreview = false;
    if (_albergueDetailsCubit.state.uploadingPhotos) {
      _albergueDetailsCubit.cancelUpload();
    }
  }

  Future<void> _onRateAccommodationClick(AlbergueDetailsState state) async {
    var isLoggedIn = await _albergueDetailsCubit.isLoggedIn();
    if (!mounted) return;

    if (isLoggedIn) {
      return _showReviewBottomSheet(context, state);
    }

    final shouldUpgrade =
        await _albergueDetailsCubit.shouldUpgradeToUseFeature();
    if (!mounted) return;
    if (shouldUpgrade) {
      return showDialog(
        context: context,
        builder: (context) => const RequiredUpgradeDialog(),
      );
    }

    isLoggedIn = (await showLoginRequiredBottomsheet(
          context,
          title: AppLocalizations.of(context).registerForReview,
          description: AppLocalizations.of(context).qualityReasonReviews,
        )) ??
        false;

    if (isLoggedIn) {
      await Future<void>.delayed(Durations.medium1);
      if (!mounted) return;
      return _showReviewBottomSheet(context, state);
    }
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AlbergueEntity? albergue,
  ) {
    return CaminoNinjaAppBar(
      centerTitle: false,
      useDynamicHeight: true,
      titleWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            albergue?.name ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.isDarkMode ? Colors.white : Colors.black,
                ),
          ),
          if (albergue != null) ...[
            StatusIndicator.buildIndicator(
              context,
              isUnknownOpenSeason:
                  albergue.operatingHours.firstOrNull?.unknownOpenSeason ??
                      false,
              isWithinOpenSeason: albergue.isWithinOpenSeason(
                    compareDate: widget.arguments.compareDate,
                  ) ??
                  false,
              compareDate: widget.arguments.compareDate,
              status: albergue.status ?? 0,
              opensAllYear:
                  albergue.operatingHours.firstOrNull?.opensAllYear ?? false,
            ),
          ],
        ],
      ),
    );
  }
}
