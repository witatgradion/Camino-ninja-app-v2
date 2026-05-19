import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

extension StagePlanModelExtension on StagePlanModel {
  String getPlanSubtitle(BuildContext context, StagePlanModel plan) {
    final totalStages = plan.stages.length;
    final stageUnit = totalStages > 1
        ? AppLocalizations.of(context).stagePlural
        : AppLocalizations.of(context).stageSingular;
    final stagesText = '$totalStages $stageUnit';

    final startDate = plan.computeStageDate(0);
    final endDate = plan.planEndDate;
    if (startDate == null) return stagesText;
    final datesText = endDate != null
        ? '${startDate.toSlashDate()} - ${endDate.toSlashDate()}'
        : startDate.toSlashDate();
    return '$stagesText  $datesText';
  }
}
