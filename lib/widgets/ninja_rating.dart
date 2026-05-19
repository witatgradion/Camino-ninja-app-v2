import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NinjaRating extends StatelessWidget {
  const NinjaRating(
      {required this.rating, this.showInisdeRating = false, super.key,});
  final double rating;
  final bool showInisdeRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: showInisdeRating
                ? Colors.transparent
                : (context.isDarkMode
                    ? AppColors.primary40
                    : AppColors.primary80),
            borderRadius: BorderRadius.circular(6),
            border: !showInisdeRating
                ? null
                : Border.all(
                    color: context.isDarkMode
                        ? AppColors.primary40
                        : AppColors.primary80,
                    width: 2,
                  ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          child: Builder(
            builder: (context) {
              if (showInisdeRating) {
                return Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Image.asset(
                        'assets/logo_ninja_small.png',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: SvgPicture.asset(
                        'assets/ic_star_full.svg',
                        width: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                );
              }
              return Text(
                'Camino Ninja',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
        ),
        if (!showInisdeRating) ...[
          const SizedBox(width: 8),
          CustomRatingBar(
            initialRating: rating,
            allowHalfRating: true,
            enable: false,
          ),
        ],
      ],
    );
  }
}
