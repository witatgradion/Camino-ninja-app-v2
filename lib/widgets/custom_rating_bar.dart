import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';

class CustomRatingBar extends StatelessWidget {
  const CustomRatingBar(
      {required this.initialRating,
      this.onRatingUpdate,
      this.inputRatingScale = 5,
      this.allowHalfRating = false,
      this.enable = true,
      this.size = 16,
      this.itemPadding,
      this.errorText,
      this.isDark = false,
      super.key,});
  final double initialRating;
  final ValueChanged<double>? onRatingUpdate;
  final int inputRatingScale;
  final bool allowHalfRating;
  final bool enable;
  final double size;
  final EdgeInsets? itemPadding;
  final String? errorText;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final normalizedRating = (initialRating / inputRatingScale) * 5;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IgnorePointer(
          ignoring: !enable,
          child: RatingBar(
            initialRating: normalizedRating,
            allowHalfRating: allowHalfRating,
            maxRating: 5,
            itemSize: size,
            itemPadding: itemPadding ?? EdgeInsets.zero,
            ratingWidget: RatingWidget(
              full: SvgPicture.asset('assets/ic_star_full.svg'),
              half: SvgPicture.asset(
                isDark
                    ? 'assets/ic_dark_star_half.svg'
                    : 'assets/ic_light_star_half.svg',
              ),
              empty: SvgPicture.asset(
                isDark
                    ? 'assets/ic_dark_star_empty.svg'
                    : 'assets/ic_light_star_empty.svg',
              ),
            ),
            onRatingUpdate: (value) {
              onRatingUpdate?.call(value);
            },
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.error60,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
