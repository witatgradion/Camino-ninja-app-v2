import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_helper.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequiredUpgradeDialog extends StatelessWidget {
  const RequiredUpgradeDialog({super.key});

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
              AppLocalizations.of(context).updateTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).updateDescription,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: AppLocalizations.of(context)
                  .updateNow
                  .capitalizeAllFirstLetter(),
              onTap: () async {
                await AppHelper.openStore();
                if (!context.mounted) return;
                context.pop(true);
              },
            ),
            const SizedBox(height: 8),
            CustomOutlineButton(
              text: AppLocalizations.of(context)
                  .remindMeLater
                  .capitalizeAllFirstLetter(),
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
