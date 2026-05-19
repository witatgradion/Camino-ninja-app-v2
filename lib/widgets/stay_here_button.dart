import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StayHereButton extends StatelessWidget {
  const StayHereButton({
    required this.isSelected,
    required this.onTap,
    super.key,
  });
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      text: isSelected
          ? AppLocalizations.of(context).removeStay
          : AppLocalizations.of(context).iWillStayHere,
      onTap: onTap,
      backgroundColor: isSelected
          ? (context.isDarkMode ? AppColors.error80 : AppColors.error40)
          : null,
      prefixIcon: (color) {
        return SvgPicture.asset(
          isSelected
              ? 'assets/ic_close.svg'
              : 'assets/ic_check_circle_outline.svg',
          width: isSelected ? 20 : 24,
          color: color,
        );
      },
    );
  }
}
