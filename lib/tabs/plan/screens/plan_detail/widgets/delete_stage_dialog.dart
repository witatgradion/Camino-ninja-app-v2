import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

class DeleteStageDialog extends StatelessWidget {
  const DeleteStageDialog({required this.stage, super.key});
  final StageModel stage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.isDarkMode ? AppColors.gray800 : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).confirmDeleteStage,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 48),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${AppLocalizations.of(context).stageToDeleteDetails} ',
                    style: context.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: stage.date?.toHumanReadableDate() ?? '',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' ${AppLocalizations.of(context).from} ',
                    style: context.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: stage.startCity?.name ?? '',
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' ${AppLocalizations.of(context).to} ',
                    style: context.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: stage.endCity?.name ?? '',
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' ${AppLocalizations.of(context).willBeDeleted}.',
                    style: context.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              backgroundColor: AppColors.error40,
              textColor: Colors.white,
              text: AppLocalizations.of(context).deleteThisStage,
              onTap: () {
                Navigator.of(context).pop(true);
              },
            ),
            const SizedBox(height: 8),
            CustomOutlineButton(
              text: AppLocalizations.of(context).cancel,
              onTap: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
