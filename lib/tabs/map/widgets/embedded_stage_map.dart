import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/tabs/map/map_tab_screen.dart';
import 'package:camino_ninja_flutter/tabs/map/widgets/mapbox/embedded_stage_map_controller.dart';
import 'package:camino_ninja_flutter/tabs/map/widgets/my_location_button.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/cubit/stage_map_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/stage_horizontal_list.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/satellite_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:repository/repository.dart';

class EmbeddedStageMap extends StatefulWidget {
  const EmbeddedStageMap({
    required this.selectedStage,
    required this.routeId,
    this.stagePlanId,
    this.isEmbedded = false,
    super.key,
  });

  final StageModel selectedStage;
  final int routeId;
  final int? stagePlanId;
  final bool isEmbedded;

  @override
  State<EmbeddedStageMap> createState() => _EmbeddedStageMapState();
}

class _EmbeddedStageMapState extends State<EmbeddedStageMap> {
  late final EmbeddedStageMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmbeddedStageMapController(
      selectedStage: widget.selectedStage,
      routeId: widget.routeId,
      stagePlanId: widget.stagePlanId,
      onLocationStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didUpdateWidget(EmbeddedStageMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeId != widget.routeId) {
      _controller.updateRouteId(widget.routeId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return BlocProvider.value(
      value: _controller.cubit,
      child: BlocListener<AppCubit, AppState>(
        listenWhen: (previous, current) => previous.theme != current.theme,
        listener: (context, state) {
          unawaited(
            _controller.onAppThemeChanged(
              context,
              isDark: state.theme.isDarkMode,
            ),
          );
        },
        child: BlocListener<StageMapCubit, StageMapState>(
          listenWhen: (previous, current) =>
              previous.initStatus != current.initStatus ||
              previous.selectedStage?.id != current.selectedStage?.id,
          listener: _controller.onCubitStateChanged,
          child: Stack(
            children: [
              BlocBuilder<StageMapCubit, StageMapState>(
                builder: (context, state) {
                  if (state.initStatus == StageMapInitStatus.loading) {
                    return const Center(
                      child: LoadingWidget(),
                    );
                  }

                  final stages = state.allStages;
                  return Stack(
                    children: [
                      MapWidget(
                        styleUri: context.isDarkMode
                            ? MapboxMapStyle.dark
                            : MapboxMapStyle.light,
                        cameraOptions: CameraOptions(
                          center: Point(
                            coordinates: Position(
                              -8.5396835,
                              42.8760274,
                            ),
                          ),
                          zoom: 14.4746,
                        ),
                        onMapCreated: (MapboxMap mapboxMap) =>
                            _controller.onMapCreated(context, mapboxMap),
                        onStyleLoadedListener: (StyleLoadedEventData _) =>
                            _controller.onStyleLoaded(context),
                      ),
                      Positioned(
                        top: widget.isEmbedded
                            ? statusBarHeight + kMapModeBarHeight
                            : statusBarHeight,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            if (!widget.isEmbedded) ...[
                              const SizedBox(width: 16),
                              _FloatingBackButton(isDark: context.isDarkMode),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: StageHorizontalList(
                                stages: stages,
                                selectedStage: state.selectedStage,
                                isEmbedded: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Column(
                          children: [
                            MyLocationButton(
                              onTap: _controller.onMyLocationTap,
                            ),
                            const SizedBox(height: 8),
                            SatelliteToggleButton(
                              isActive: _controller.isSatelliteView,
                              onToggle: () async {
                                await _controller.toggleSatelliteView(
                                  isDark: context.isDarkMode,
                                );
                                if (mounted) setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              Offstage(
                child: Row(
                  children: [
                    SvgPicture.asset('assets/ic_flag.svg'),
                    SvgPicture.asset(
                      'assets/ic_flag_light.svg',
                    ),
                    SvgPicture.asset('assets/ic_walk.svg'),
                    SvgPicture.asset(
                      'assets/ic_arrow_left_outline.svg',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? AppColors.primary20 : AppColors.primary40;
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
              colorFilter: ColorFilter.mode(
                iconColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
