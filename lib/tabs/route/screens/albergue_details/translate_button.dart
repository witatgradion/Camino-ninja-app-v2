import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TranslateButton extends StatelessWidget {
  const TranslateButton({
    required this.onTap,
    super.key,
    this.isTranslated = false,
  });
  final bool isTranslated;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          isTranslated
              ? AppLocalizations.of(context).translated
              : AppLocalizations.of(context).original,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: context.isDarkMode
                ? Colors.white.withOpacity(0.5)
                : Colors.black.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            children: [
              Text(
                isTranslated
                    ? AppLocalizations.of(context).showOriginal
                    : AppLocalizations.of(context).showTranslated,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.isDarkMode
                      ? AppColors.primary80
                      : AppColors.primary40,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                'assets/ic_translate.svg',
                color: context.isDarkMode
                    ? AppColors.primary80
                    : AppColors.primary40,
                width: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
