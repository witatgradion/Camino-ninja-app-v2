import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyLocationButton extends StatelessWidget {
  const MyLocationButton({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        context.isDarkMode ? AppColors.primary20 : AppColors.primary40;

    return Container(
      decoration: BoxDecoration(
        // Shadow lives on this container so it won't be clipped by Material.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(4, 4),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/ic_aim.svg',
              width: 24,
              color: context.isDarkMode ? AppColors.primary80 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
