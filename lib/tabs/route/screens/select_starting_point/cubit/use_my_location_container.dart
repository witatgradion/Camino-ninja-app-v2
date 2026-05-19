import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UseMyLocationContainer extends StatelessWidget {
  const UseMyLocationContainer({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 24,
      ),
      color: context.isDarkMode ? AppColors.gray800 : AppColors.gray200,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).selectCityCurrentLocation,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 7,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.isDarkMode
                        ? AppColors.primary20
                        : AppColors.primary40,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/ic_aim.svg',
                        width: 18,
                        color: context.isDarkMode
                            ? AppColors.primary80
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context).useMyLocation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.isDarkMode
                                  ? AppColors.primary80
                                  : Colors.white,
                            ),
                      ),
                    ],
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
