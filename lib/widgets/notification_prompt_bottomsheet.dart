import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/services/notification_service.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

Future<bool?> showNotificationPromptBottomsheet(
  BuildContext context,
) {
  return showModalBottomSheet<bool?>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) =>
        const NotificationPromptBottomsheet(),
  );
}

class NotificationPromptBottomsheet extends StatelessWidget {
  const NotificationPromptBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = context.isDarkMode;
    final iconBgColor =
        isDark ? AppColors.primary80 : AppColors.primary40;
    final iconColor = isDark ? AppColors.primary20 : Colors.white;

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: context.getBottomPadding(context, additionalPadding: 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.stayInTheLoop,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationPromptDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: l10n.enableNotifications,
                onTap: () async {
                  final isLoggedIn =
                      context.read<AppCubit>().state.isLoggedIn;
                  final notificationService =
                      GetIt.instance<NotificationService>();
                  await notificationService
                      .requestPermissionAndSubscribe(
                    isLoggedIn: isLoggedIn,
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.notNow,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: isDark
                          ? Colors.white70
                          : Colors.black54,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
