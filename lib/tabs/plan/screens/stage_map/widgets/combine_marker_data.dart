import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

enum MarkerSide { top, bottom }

class CombineMarkerData {
  CombineMarkerData({
    required this.city,
    this.startStages = const [],
    this.endStages = const [],
    this.junctionFromRouteName,
    this.junctionToRouteName,
    this.junctionGlowColorValue,
  });
  final CityEntity city;
  final List<CombineMarkerStageData> startStages;
  final List<CombineMarkerStageData> endStages;

  /// When this city is also a junction, these fields carry
  /// the route transition info so the combine marker can
  /// render a glow ring and label pill.
  final String? junctionFromRouteName;
  final String? junctionToRouteName;
  final int? junctionGlowColorValue;

  bool get isJunction => junctionGlowColorValue != null;

  CombineMarkerData copyWith({
    CityEntity? city,
    List<CombineMarkerStageData>? startStages,
    List<CombineMarkerStageData>? endStages,
    String? junctionFromRouteName,
    String? junctionToRouteName,
    int? junctionGlowColorValue,
  }) {
    return CombineMarkerData(
      city: city ?? this.city,
      startStages: startStages ?? this.startStages,
      endStages: endStages ?? this.endStages,
      junctionFromRouteName:
          junctionFromRouteName ?? this.junctionFromRouteName,
      junctionToRouteName:
          junctionToRouteName ?? this.junctionToRouteName,
      junctionGlowColorValue:
          junctionGlowColorValue ?? this.junctionGlowColorValue,
    );
  }
}

class CombineMarkerStageData {
  CombineMarkerStageData({
    required this.stage,
    this.index = 0,
    this.isSelected = false,
    this.side = MarkerSide.top,
  });
  final StageModel stage;
  final int index;
  final bool isSelected;
  final MarkerSide side;

  CombineMarkerStageData copyWith({
    StageModel? stage,
    int? index,
    bool? isSelected,
    MarkerSide? side,
  }) {
    return CombineMarkerStageData(
      stage: stage ?? this.stage,
      index: index ?? this.index,
      isSelected: isSelected ?? this.isSelected,
      side: side ?? this.side,
    );
  }
}
