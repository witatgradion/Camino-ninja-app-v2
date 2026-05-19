import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:repository/repository.dart';

class MyReviewItemView extends StatelessWidget {
  const MyReviewItemView(
      {required this.review, required this.onSeeMyCommentTap, super.key});
  final AlbergueReviewModel review;
  final VoidCallback onSeeMyCommentTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          review.albergue?.name ?? '',
          style: context.textTheme.bodyLarge?.copyWith(
            color:
                context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? const Color(0xFF5D553D)
                    : const Color(0xFFFFF6DD),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              child: CustomRatingBar(
                initialRating: review.userRating?.toDouble() ?? 0,
                enable: false,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${AppLocalizations.of(context).postedOn}: ${review.createdAt?.toHumanReadableDate() ?? ''}',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color:
                context.isDarkMode ? AppColors.primary20 : AppColors.primary50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            review.userComment ?? '',
            style: context.textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        if (review.status == true) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              CustomOutlineButton(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                text: AppLocalizations.of(context).seeMyComment,
                onTap: onSeeMyCommentTap,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
