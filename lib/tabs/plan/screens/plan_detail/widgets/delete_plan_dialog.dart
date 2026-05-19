import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:repository/repository.dart';

class DeletePlanDialog extends StatelessWidget {
  const DeletePlanDialog({required this.plan, super.key});
  final StagePlanModel plan;

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
              AppLocalizations.of(context).confirmDeletePlannedRoute,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 48),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        '${AppLocalizations.of(context).confirmDeletePlannedRoute}: ',
                    style: context.textTheme.bodyMedium,
                  ),
                  TextSpan(
                    text: plan.route.routeName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              backgroundColor: AppColors.error40,
              textColor: Colors.white,
              text: AppLocalizations.of(context).deleteThisPlan,
              onTap: () {
                context.pop(true);
              },
            ),
            const SizedBox(height: 8),
            CustomOutlineButton(
              text: AppLocalizations.of(context).cancel,
              onTap: () {
                context.pop(false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
