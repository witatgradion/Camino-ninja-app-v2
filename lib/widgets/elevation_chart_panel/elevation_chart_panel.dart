import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/map/cubit/map_cubit.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/elevation/cubit/chart_route_point.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/elevation_chart_panel/custom_panel.dart';
import 'package:camino_ninja_flutter/widgets/elevation_chart_panel/elevation_chart_with_indicator.dart';
import 'package:camino_ninja_flutter/widgets/elevation_gain_loss_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ElevationChartPanel extends StatefulWidget {
  const ElevationChartPanel({
    required this.body,
    required this.elevationData,
    required this.loadLocationNotifier,
    required this.parentHeight,
    required this.appState,
    super.key,
    this.onTouchDown,
    this.onTouchUp,
    this.onTouchMove,
    this.currentAltitude = 'unknown',
    this.currentDistance = 'unknown',
    this.unit = UnitEnum.metric,
  });
  final AppState appState;
  final String? currentAltitude;
  final String? currentDistance;
  final Widget Function(BuildContext) body;
  final UnitEnum unit;
  final ValueNotifier<LoadUserLocationStatus> loadLocationNotifier;
  final double parentHeight;

  /// The elevation data of the trail.
  final List<ChartRoutePoint> elevationData;

  /// Invoked when a touch down event is detected on the chart.
  final void Function(ChartRoutePoint)? onTouchDown;

  /// Invoked when a touch up event is detected on the chart.
  final VoidCallback? onTouchUp;

  /// Invoked when a touch move event is detected on the chart.
  final void Function(ChartRoutePoint)? onTouchMove;

  @override
  State<ElevationChartPanel> createState() => _ElevationChartPanelState();
}

class _ElevationChartPanelState extends State<ElevationChartPanel> {
  final _panelPositionNotifier = ValueNotifier<double>(0);
  final _chartAreaKey = GlobalKey();

  // Define panel heights as constants for easier calculation
  final double _panelMinHeight = 154;
  final double _chartHeight = 280;
  bool _isPanelDraggable = true;

  void _handleChartTouchDown(ChartRoutePoint point) {
    widget.onTouchDown?.call(point);
  }

  void _handleChartTouchMove(ChartRoutePoint point) {
    widget.onTouchMove?.call(point);
  }

  void _handleChartTouchUp() {
    widget.onTouchUp?.call();
  }

  @override
  void initState() {
    _isPanelDraggable = widget.elevationData.isNotEmpty;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ElevationChartPanel oldWidget) {
    if (oldWidget.elevationData != widget.elevationData) {
      _isPanelDraggable = widget.elevationData.isNotEmpty;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _panelPositionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate how far the panel will travel
    final panelMaxHeight = _chartHeight + _panelMinHeight;
    final panelTravelDistance = panelMaxHeight - _panelMinHeight;
    return SlidingUpPanel(
      onPanelClosed: () {
        setState(() => _isPanelDraggable = true);
      },
      isDraggable: _isPanelDraggable,
      // Don't start panel drag gestures from within the chart area.
      dragStartPredicate: _dragStartPredicate,
      onPanelSlide: (position) {
        _panelPositionNotifier.value = position;
      },
      body: ValueListenableBuilder(
        valueListenable: _panelPositionNotifier,
        builder: (context, position, child) {
          final panelVisibleHeight =
              _panelMinHeight + (position * panelTravelDistance);
          final availableHeight = widget.parentHeight - panelVisibleHeight;
          return Column(
            children: [
              SizedBox(
                height: availableHeight,
                child: widget.body(context),
              ),
            ],
          );
        },
      ),

      // (The panelBuilder code remains the same as before)
      panelBuilder: _buildPanelContent,
      minHeight: _panelMinHeight,
      maxHeight:
          widget.elevationData.isNotEmpty ? panelMaxHeight : _panelMinHeight,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    );
  }

  bool _dragStartPredicate(Offset globalPosition) {
    final context = _chartAreaKey.currentContext;
    if (context == null) return true;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) {
      return true;
    }

    final topLeft = renderObject.localToGlobal(Offset.zero);
    final rect = topLeft & renderObject.size;

    // If the drag starts inside the chart area, don't let the panel
    // handle this drag.
    if (rect.contains(globalPosition)) {
      return false;
    }

    return true;
  }

  Widget _buildPanelContent(ScrollController sc) {
    final minElevation = UnitConverter.displayElevation(
      meters: widget.appState.routeStats?.minElevation.toDouble() ?? 0.0,
      unit: widget.appState.unit,
    );

    final maxElevation = UnitConverter.displayElevation(
      meters: widget.appState.routeStats?.maxElevation.toDouble() ?? 0.0,
      unit: widget.appState.unit,
    );

    final elevationGain = UnitConverter.displayElevation(
      meters: widget.appState.routeStats?.elevationGain.toDouble() ?? 0.0,
      unit: widget.appState.unit,
    );

    final elevationLoss = UnitConverter.displayElevation(
      meters: widget.appState.routeStats?.elevationLoss.toDouble() ?? 0.0,
      unit: widget.appState.unit,
    );

    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? AppColors.gray800 : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ListView(
        controller: sc,
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: _panelMinHeight,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 135,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ValueListenableBuilder(
                  valueListenable: widget.loadLocationNotifier,
                  builder: (context, value, child) {
                    final isLoading = value == LoadUserLocationStatus.loading;
                    return _buildRouteOverviewRow(
                      context,
                      firstLabel: AppLocalizations.of(context)
                          .currentElev
                          .capitalizeFirstLetter(),
                      secondLabel: AppLocalizations.of(context)
                          .distanceFromTheTrail
                          .capitalizeFirstLetter(),
                      firstText: widget.currentAltitude,
                      secondText: widget.currentDistance,
                      isLoading: isLoading,
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildRouteOverviewRow(
                  context,
                  firstLabel: AppLocalizations.of(context)
                      .minMaxElevRouteScreen
                      .capitalizeFirstLetter(),
                  secondLabel: AppLocalizations.of(context)
                      .elevationGainLossRouteScreen
                      .capitalizeFirstLetter(),
                  firstText: '$minElevation/$maxElevation',
                  secondTextWidget: ElevationGainLossWidget(
                    elevationGain: elevationGain,
                    elevationLoss: elevationLoss,
                  ),
                ),
              ],
            ),
          ),
          if (widget.elevationData.isNotEmpty) ...[
            SizedBox(
              key: _chartAreaKey,
              height: _chartHeight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 24),
                child: ElevationChartWithIndicator(
                  unit: widget.unit,
                  profile: widget.elevationData,
                  onTouchDown: _handleChartTouchDown,
                  onTouchUp: _handleChartTouchUp,
                  onTouchMove: _handleChartTouchMove,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRouteOverviewRow(
    BuildContext context, {
    required String firstLabel,
    required String secondLabel,
    String? firstText,
    String? secondText,
    Widget? secondTextWidget,
    bool isLoading = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 24),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                firstLabel,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isLoading) ...[
                const CupertinoActivityIndicator(),
              ] else ...[
                if (firstText != null)
                  Text(
                    firstText,
                    style: context.textTheme.bodyMedium,
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                secondLabel,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              if (isLoading) ...[
                const CupertinoActivityIndicator(),
              ] else ...[
                if (secondText != null)
                  Text(
                    secondText,
                    style: context.textTheme.bodyMedium,
                  ),
                if (secondTextWidget != null) secondTextWidget,
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
