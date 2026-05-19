import 'dart:io';

import 'package:analytics_services/analytics_services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/distance/cubit/distance_cubit.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/location_service.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/dialogs/location_accuracy_dialog.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/location_permission_guide.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';
import 'package:url_launcher/url_launcher.dart';

class DistanceScreenArguments {
  const DistanceScreenArguments({
    required this.routeId,
    required this.destinationCity,
    required this.unit,
    required this.title,
  });
  final int routeId;
  final CityEntity destinationCity;
  final UnitEnum unit;
  final String title;
}

class DistanceScreen extends StatefulWidget {
  const DistanceScreen({
    required this.arguments,
    super.key,
  });
  final DistanceScreenArguments arguments;

  @override
  State<DistanceScreen> createState() => _DistanceScreenState();
}

class _DistanceScreenState extends State<DistanceScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    final l10n = AppLocalizations.of(context);
    return BlocProvider(
      create: (context) => DistanceCubit(
        selectedRouteId: widget.arguments.routeId,
        destinationCity: widget.arguments.destinationCity,
        unit: widget.arguments.unit,
      )..checkLocationAndCalculateDistances(),
      child: BlocConsumer<DistanceCubit, DistanceState>(
        listener: (context, state) {
          if (state.accuracyDenied) {
            _showAccuracyDialog(context);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CaminoNinjaAppBar(
              title: widget.arguments.title,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.isLoading)
                      const Center(
                        child: LoadingWidget(),
                      ),
                    if (!state.isLoading && state.permissionDenied)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LocationPermissionGuide(),
                          const SizedBox(height: 24),
                          if (!state.permanentlyDenied && Platform.isAndroid)
                            ElevatedButton(
                              onPressed: () async {
                                await AppSettings.openAppSettings(
                                  type: AppSettingsType.location,
                                );

                                if (context.mounted) {
                                  await context
                                      .read<DistanceCubit>()
                                      .checkLocationAndCalculateDistances();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? const Color(0xFF333333)
                                    : Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Text(l10n.openSettings),
                            ),
                          if (state.permanentlyDenied)
                            ElevatedButton(
                              onPressed: () async {
                                await LocationService.openLocationSettings();
                                if (context.mounted) {
                                  await context
                                      .read<DistanceCubit>()
                                      .checkLocationAndCalculateDistances();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? const Color(0xFF333333)
                                    : Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                              ),
                              child: Text(l10n.openSettings),
                            ),
                        ],
                      ),
                    if (!state.isTooFar &&
                        !state.isLoading &&
                        !state.permissionDenied)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${AppLocalizations.of(context).nextCity}:'
                            '\n${state.nextCity ?? ''}'
                            '\n${state.distanceToNextCity ?? ''}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${AppLocalizations.of(context).destination}:'
                            '\n${state.destinationCity ?? ''}'
                            '\n${state.distanceToDestination ?? ''}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${AppLocalizations.of(context).distanceFromRoute}:'
                            '\n${state.distanceFromRoute ?? ''}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<DistanceCubit>()
                                  .checkLocationAndCalculateDistances();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? const Color(0xFF333333)
                                  : Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CommunityMaterialIcons.refresh,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).update_360,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    if (!state.isLoading &&
                        state.isTooFar &&
                        !state.permissionDenied)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context).distanceFromCity(
                              state.nextCity ?? '',
                              state.distanceToNextCity ?? '',
                              state.routeName ?? '',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)
                                .notOnRouteName(state.routeName ?? ''),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<DistanceCubit>()
                                  .checkLocationAndCalculateDistances();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? const Color(0xFF333333)
                                  : Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CommunityMaterialIcons.refresh,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context).update_360,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              GetIt.instance<IAnalyticsService>().track(
                                FindTransportationClickedEvent(
                                  routeId: widget.arguments.routeId,
                                ),
                              );
                              launchUrlSafely(
                                'https://www.omio.com/apps',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode
                                  ? const Color(0xFF333333)
                                  : Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  CommunityMaterialIcons.airplane_takeoff,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)
                                      .findTransportation,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAccuracyDialog(BuildContext mainContext) async {
    if (!mounted) return;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return LocationAccuracyDialog(
          onAllow: mainContext
              .read<DistanceCubit>()
              .checkLocationAndCalculateDistances,
          onDeny: (permanentlyDenied) async {
            await GetIt.instance<Repository>()
                .setLocationAccuracyDenied(permanentlyDenied);
            if (!mainContext.mounted) return;
            if (permanentlyDenied) {
              await mainContext
                  .read<DistanceCubit>()
                  .checkLocationAndCalculateDistances();
            } else {
              await mainContext
                  .read<DistanceCubit>()
                  .checkLocationAndCalculateDistances(
                    locationAccuracyOff: true,
                  );
            }
          },
        );
      },
    );
  }

  // A function to manually open the app's settings on iOS
  Future<void> openAppSettingsManually() async {
    // This is the specific URL scheme for opening an app's settings on iOS.
    final url = Uri.parse('app-settings:');

    // Check if the device can handle this URL scheme.
    if (await canLaunchUrl(url)) {
      // If it can, launch the URL.
      await launchUrl(url);
    } else {
      // If it cannot, show an error (this should not happen on a real iOS device).
      throw 'Could not launch $url';
    }
  }
}
