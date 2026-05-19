import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GeneralSaveChangeDialog extends StatelessWidget {
  const GeneralSaveChangeDialog({super.key});

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
              AppLocalizations.of(context).confirmSaveChange,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: AppLocalizations.of(context).saveChange,
                    onTap: () {
                      context.pop(true);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomOutlineButton(
                    text: AppLocalizations.of(context).cancel,
                    onTap: () {
                      context.pop(false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
