import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:flutter/material.dart';
import 'package:remote_data/remote_data.dart';

class AnnouncementListTile extends StatelessWidget {
  const AnnouncementListTile({
    required this.announcement,
    required this.isRead,
    required this.onTap,
    super.key,
  });

  final AnnouncementResponse announcement;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = formatIsoDate(announcement.createdAt);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      title: Row(
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
              announcement.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (announcement.description?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  announcement.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Text(
              dateStr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
