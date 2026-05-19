import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/city_marker.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/combine_marker_data.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/junction_glow_marker.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/stage_end_marker.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/widgets/stage_start_marker.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class CombineMarker extends StatelessWidget {
  const CombineMarker({
    required this.city,
    required this.isDarkMode,
    required this.textTheme,
    required this.startText,
    required this.endText,
    super.key,
    this.startStages = const [],
    this.endStages = const [],
    this.junctionFromRouteName,
    this.junctionToRouteName,
    this.junctionGlowColor,
  });
  final CityEntity city;
  final List<CombineMarkerStageData> startStages;
  final List<CombineMarkerStageData> endStages;
  final bool isDarkMode;
  final TextTheme textTheme;
  final String startText;
  final String endText;

  /// Optional junction data. When present the marker renders
  /// a glow ring behind the city dot and a label pill below.
  final String? junctionFromRouteName;
  final String? junctionToRouteName;
  final Color? junctionGlowColor;

  bool get _hasJunction => junctionGlowColor != null;

  @override
  Widget build(BuildContext context) {
    final allStages = <CombineMarkerStageData>[
      ...startStages,
      ...endStages,
    ];
    final topStages = allStages
        .where((s) => s.side == MarkerSide.top)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final bottomStages = allStages
        .where((s) => s.side == MarkerSide.bottom)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final cityMarker = CityMarker(
      city: city,
      isDarkMode: isDarkMode,
      textTheme: textTheme,
    );

    // When the city is also a junction, layer the glow ring
    // behind the city marker using a Stack so the ring is
    // visible as a halo around the city pill.
    final centerWidget = _hasJunction
        ? _CityMarkerWithGlow(
            cityMarker: cityMarker,
            glowColor: junctionGlowColor!,
          )
        : cityMarker;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (topStages.isNotEmpty) ...[
          ...topStages.map(
            (stageData) => _StageMarkerItem(
              stageData: stageData,
              city: city,
              isDarkMode: isDarkMode,
              textTheme: textTheme,
              startText: startText,
              endText: endText,
              addBottomSpacing: true,
            ),
          ),
        ],
        centerWidget,
        if (bottomStages.isNotEmpty) ...[
          ...bottomStages.map(
            (stageData) => _StageMarkerItem(
              stageData: stageData,
              city: city,
              isDarkMode: isDarkMode,
              textTheme: textTheme,
              startText: startText,
              endText: endText,
              addBottomSpacing: false,
            ),
          ),
        ],
        if (_hasJunction) ...[
          const SizedBox(height: 4),
          JunctionLabelPill(
            fromRouteName: junctionFromRouteName!,
            toRouteName: junctionToRouteName!,
            isDark: isDarkMode,
          ),
        ],
      ],
    );
  }
}

/// Layers a [JunctionGlowRing] behind the [CityMarker] so
/// the colored ring is visible as a halo.
class _CityMarkerWithGlow extends StatelessWidget {
  const _CityMarkerWithGlow({
    required this.cityMarker,
    required this.glowColor,
  });

  final CityMarker cityMarker;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        JunctionGlowRing(glowColor: glowColor, size: 36),
        cityMarker,
      ],
    );
  }
}

/// A single stage start/end marker row used inside
/// [CombineMarker]'s top or bottom list.
class _StageMarkerItem extends StatelessWidget {
  const _StageMarkerItem({
    required this.stageData,
    required this.city,
    required this.isDarkMode,
    required this.textTheme,
    required this.startText,
    required this.endText,
    required this.addBottomSpacing,
  });

  final CombineMarkerStageData stageData;
  final CityEntity city;
  final bool isDarkMode;
  final TextTheme textTheme;
  final String startText;
  final String endText;
  final bool addBottomSpacing;

  @override
  Widget build(BuildContext context) {
    final isStart = stageData.stage.startCity?.id == city.id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!addBottomSpacing) const SizedBox(height: 4),
        if (isStart)
          StageStartMarker(
            stage: stageData.stage,
            isDarkMode: isDarkMode,
            textTheme: textTheme,
            isSelected: stageData.isSelected,
            index: stageData.index,
            startText: startText,
          )
        else
          StageEndMarker(
            stage: stageData.stage,
            isDarkMode: isDarkMode,
            textTheme: textTheme,
            isSelected: stageData.isSelected,
            index: stageData.index,
            endText: endText,
          ),
        if (addBottomSpacing) const SizedBox(height: 4),
      ],
    );
  }
}
