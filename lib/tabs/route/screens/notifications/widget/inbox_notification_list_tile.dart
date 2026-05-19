import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:flutter/material.dart';
import 'package:remote_data/remote_data.dart';

class InboxNotificationListTile extends StatelessWidget {
  const InboxNotificationListTile({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final UserNotificationResponse notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = formatIsoDateAsTimeAgo(
      notification.createdAt,
      Localizations.localeOf(context).languageCode,
    );
    final isRead = notification.isRead;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.type == NotificationType.albergueReviewRequest) ...[
            Container(
              margin: const EdgeInsets.only(left: 18),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.primary10
                    : AppColors.primary40,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AppLocalizations.of(context).awaitingYourReview,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.isDarkMode
                          ? AppColors.primary80
                          : Colors.white,
                    ),
              ),
            ),
          ],
          Row(
            children: [
              if (!isRead) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.red700,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  notification.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.body.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  notification.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            Text(
              dateStr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.isDarkMode
                        ? AppColors.gray400
                        : AppColors.gray600,
                  ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
