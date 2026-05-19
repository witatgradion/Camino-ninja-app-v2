import 'package:camino_ninja_flutter/tabs/map/widgets/embedded_stage_map.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:repository/repository.dart';

class StageMapScreenArguments {
  const StageMapScreenArguments({
    required this.selectedStage,
    required this.routeId,
    this.stagePlanId,
  });
  final StageModel selectedStage;
  final int? stagePlanId;
  final int routeId;
}

class StageMapScreen extends StatefulWidget {
  const StageMapScreen({required this.arguments, super.key});
  final StageMapScreenArguments arguments;

  @override
  State<StageMapScreen> createState() => _StageMapScreenState();
}

class _StageMapScreenState extends State<StageMapScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: EmbeddedStageMap(
          selectedStage: widget.arguments.selectedStage,
          routeId: widget.arguments.routeId,
          stagePlanId: widget.arguments.stagePlanId,
        ),
      ),
    );
  }
}
