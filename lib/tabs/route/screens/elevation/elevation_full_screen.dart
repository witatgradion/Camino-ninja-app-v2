import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/elevation_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/elevation_chart_v2.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:camino_ninja_flutter/utils/location_tracker.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_accuracy_dialog.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';

class ElevationFullScreen extends StatefulWidget {
  const ElevationFullScreen({super.key});

  @override
  State<ElevationFullScreen> createState() => _ElevationFullScreenState();
}

class _ElevationFullScreenState extends State<ElevationFullScreen> {
  StreamSubscription<Position>? _positionStreamSubscription;
  LocationTracker? _locationTracker;

  @override
  void initState() {
    super.initState();
    // Force landscape orientation for this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _initializeLocation(BuildContext context) async {
    try {
      final hasPermission = await LocationService.checkLocationPermission();
      if (!hasPermission) {
        // _showLocationDialog();
        return;
      }
      if (context.mounted) {
        await _startLocationTracking(context);
      }
    } catch (e) {
      AppLogger.e(
        'Location initialization error',
        tag: 'ElevationFullScreen',
        error: e,
      );
    }
  }

  Future<void> _startLocationTracking(
    BuildContext context, {
    bool locationAccuracyOff = false,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await _positionStreamSubscription?.cancel();
    _locationTracker ??= LocationTracker();

    Position? currentPosition;
    try {
      currentPosition = await _locationTracker!.getCurrentPosition(
        locationAccuracyOff: locationAccuracyOff,
      );
    } on LocationServiceDisabledException {
      await _showAccuracyDialog(context);
      return;
    }
    if (currentPosition != null) {
      context
          .read<ElevationCubit>()
          .updateCurrentLocationOnChart(currentPosition);
    }
    _positionStreamSubscription = _locationTracker?.locationStream
        .listen(context.read<ElevationCubit>().updateCurrentLocationOnChart);
  }

  Future<void> _showAccuracyDialog(BuildContext context) async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext buildContext) {
        return LocationAccuracyDialog(
          onAllow: () {
            _startLocationTracking(context);
          },
          onDeny: (permanentlyDenied) async {
            await GetIt.instance<Repository>()
                .setLocationAccuracyDenied(permanentlyDenied);
            if (permanentlyDenied) {
              await _startLocationTracking(context);
            } else {
              await _startLocationTracking(context, locationAccuracyOff: true);
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationTracker?.dispose();
    // Restore portrait orientation when leaving this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return BlocProvider(
          create: (context) => ElevationCubit(
            routeId: appState.selectedRoute?.id ?? 0,
            startingCityId: appState.selectedStartingPoint?.id,
            destCityId: appState.selectedDestination?.id,
          )..getRoutePoints(),
          child: BlocBuilder<ElevationCubit, ElevationState>(
            builder: (context, state) {
              if (state.routePoints != null && state.cities != null) {
                _initializeLocation(context);
              }

              return SafeArea(
                child: Scaffold(
                  backgroundColor:
                      isDarkMode ? const Color(0xFF141218) : AppColors.gray200,
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: context.isDarkMode
                                  ? AppColors.primary20
                                  : AppColors.primary40,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100),
                              onTap: () {
                                context.pop();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture.asset(
                                  'assets/ic_chervon_left.svg',
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  body: (state.routePoints != null &&
                          state.cities != null &&
                          state.routePoints!.isNotEmpty &&
                          state.cities!.isNotEmpty)
                      ? ElevationChartV2(
                          routePoints: state.routePoints!,
                          cities: state.cities!,
                          currentPosition: state.currentPosition,
                          unit: appState.unit,
                          isFullScreen: true,
                        )
                      : const Center(
                          child: LoadingWidget(),
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
