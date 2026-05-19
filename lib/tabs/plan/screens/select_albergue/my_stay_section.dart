import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';

class MyStaySection extends StatelessWidget {
  const MyStaySection({
    required this.notes,
    required this.onEditTap,
    required this.onRemoveTap,
    super.key,
  });
  final String notes;
  final VoidCallback onEditTap;
  final VoidCallback onRemoveTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('custom_notes'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? AppColors.gray800 : AppColors.primary30,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? AppColors.gray600 : AppColors.primary80,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.houseboat_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).myStay,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.isDarkMode
                        ? AppColors.primary100
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notes,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.isDarkMode
                        ? AppColors.primary100
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.gray600
                    : AppColors.primary80,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: onEditTap,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.gray600
                    : AppColors.primary80,
                shape: BoxShape.circle,
              ),
              child: InkWell(
                onTap: onRemoveTap,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
