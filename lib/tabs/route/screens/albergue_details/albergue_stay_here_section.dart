import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';

class AlbergueStayHereSection extends StatelessWidget {
  const AlbergueStayHereSection({
    required this.isSelected,
    required this.onSelectedAlbergueChanged,
    super.key,
  });
  final bool isSelected;
  final VoidCallback onSelectedAlbergueChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(
        left: 8,
        right: 24,
        top: 8,
        bottom: 16,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onSelectedAlbergueChanged,
            borderRadius: BorderRadius.circular(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onSelectedAlbergueChanged(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Text(
                  AppLocalizations.of(context).iWillStayHere,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode
                        ? AppColors.primary80
                        : AppColors.primary40,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
