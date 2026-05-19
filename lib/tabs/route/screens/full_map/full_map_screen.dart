import 'dart:io';

import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_albergues_map.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/full_map/cubit/full_map_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';

class FullMapScreen extends StatelessWidget {
  const FullMapScreen({
    required this.albergueId,
    this.cityId,
    this.routeId,
    super.key,
  });

  final int albergueId;
  final int? cityId;
  final int? routeId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FullMapCubit(
        albergueId: albergueId,
        cityId: cityId,
        routeId: routeId,
      )..loadMap(),
      child: BlocBuilder<FullMapCubit, FullMapState>(
        builder: (context, state) {
          final isDark = context.isDarkMode;
          final topPadding =
              MediaQuery.of(context).padding.top + 16;

          if (!state.mapReady) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: const Scaffold(
                body: Center(child: LoadingWidget()),
              ),
            );
          }

          if (state.albergue == null) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: isDark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: Scaffold(
                body: Stack(
                  children: [
                    Positioned(
                      top: topPadding,
                      left: 12,
                      child: _FloatingBackButton(
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Scaffold(
              body: Stack(
                children: [
                  CityAlberguesMap(
                    city: state.city,
                    locations: [
                      AlbergueLocation(
                        albergueId: state.albergue!.id,
                        name: state.albergue!.name,
                        latLng: LatLng(
                          state.albergue!.latitude!,
                          state.albergue!.longitude!,
                        ),
                        albergue: state.albergue,
                      ),
                    ],
                    routePoints: state.routePoints,
                    altRoutePoints: state.altRoutePoints,
                    zoom: 14,
                    zoomEnabled: true,
                    scrollEnabled: true,
                    onMarkerTap: (location) {
                      navigateToGoogleMaps(
                        location.latLng.latitude,
                        location.latLng.longitude,
                      );
                    },
                  ),
                  Positioned(
                    top: topPadding,
                    left: 12,
                    child: _FloatingBackButton(
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> navigateToGoogleMaps(
    double destLat,
    double destLon,
  ) async {
    final url = Platform.isIOS
        ? 'comgooglemaps://?daddr=$destLat,$destLon&directionsmode=driving'
        : 'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLon&travelmode=walking';

    final isSuccess = await launchUrlSafely(url);
    if (!isSuccess) {
      final browserUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLon&travelmode=walking';
      await launchUrlSafely(browserUrl);
    }
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDark ? AppColors.primary20 : AppColors.primary40;
    final iconColor = isDark ? AppColors.primary80 : Colors.white;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/ic_chervon_left.svg',
              width: 24,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
