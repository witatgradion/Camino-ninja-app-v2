import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/elevation_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/elevation_chart_v2.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:camino_ninja_flutter/utils/location_tracker.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_accuracy_dialog.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';

class ElevationScreenArguments {
  const ElevationScreenArguments({
    required this.routeId,
    required this.startingCityId,
    required this.destCityId,
    required this.title,
  });
  final int routeId;
  final int startingCityId;
  final int destCityId;
  final String title;
}

class ElevationScreen extends StatefulWidget {
  const ElevationScreen({
    required this.arguments,
    super.key,
  });
  final ElevationScreenArguments arguments;

  @override
  State<ElevationScreen> createState() => _ElevationScreenState();
}

class _ElevationScreenState extends State<ElevationScreen> {
  LocationTracker? _locationTracker;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
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
      AppLogger.e('Location initialization error', tag: 'ElevationScreen', error: e);
    }
  }

  Future<void> _startLocationTracking(
    BuildContext context, {
    bool locationAccuracyOff = false,
  }) async {
    AppLogger.d('Starting location tracking...', tag: 'ElevationScreen');
    WidgetsFlutterBinding.ensureInitialized();
    await _positionStreamSubscription?.cancel();
    if (!context.mounted) return;

    // Create a new location tracker if needed
    _locationTracker ??= LocationTracker();
    Position? currentPosition;
    try {
      currentPosition = await _locationTracker!.getCurrentPosition(
        locationAccuracyOff: locationAccuracyOff,
      );
    } on LocationServiceDisabledException {
      if (!context.mounted) return;
      await _showAccuracyDialog(context);
      return;
    }
    if (currentPosition != null && context.mounted) {
      context
          .read<ElevationCubit>()
          .updateCurrentLocationOnChart(currentPosition);
    }
    if (!context.mounted) return;
    _positionStreamSubscription = _locationTracker!.locationStream
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
            if (!context.mounted) return;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return BlocProvider(
          create: (context) => ElevationCubit(
            routeId: widget.arguments.routeId,
            startingCityId: widget.arguments.startingCityId,
            destCityId: widget.arguments.destCityId,
          )..getRoutePoints(),
          child: BlocBuilder<ElevationCubit, ElevationState>(
            builder: (context, state) {
              if (state.routePoints != null && state.cities != null) {
                _initializeLocation(context);
              }

              return Scaffold(
                backgroundColor:
                    isDarkMode ? const Color(0xFF141218) : AppColors.gray200,
                appBar: CaminoNinjaAppBar(
                  title: widget.arguments.title,
                ),
                body: (state.routePoints != null &&
                        state.cities != null &&
                        state.routePoints!.isNotEmpty &&
                        state.cities!.isNotEmpty)
                    ? Stack(
                        children: [
                          ElevationChartV2(
                            routePoints: state.routePoints!,
                            cities: state.cities!,
                            currentPosition: state.currentPosition,
                            unit: appState.unit,
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Material(
                              color: Colors.transparent,
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: context.isDarkMode
                                      ? AppColors.primary20
                                      : AppColors.primary40,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  onTap: () {
                                    context.push('/elevation-full-screen');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.fullscreen,
                                      size: 18,
                                      color: context.isDarkMode
                                          ? AppColors.primary80
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: LoadingWidget(),
                      ),
              );
            },
          ),
        );
      },
    );
  }
}
