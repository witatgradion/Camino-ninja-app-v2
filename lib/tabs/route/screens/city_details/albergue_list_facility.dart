import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class AlbergueListFacility extends StatelessWidget {
  const AlbergueListFacility({
    required this.facility,
    this.review,
    super.key,
  });

  final FacilityEntity facility;
  final ReviewEntity? review;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (review?.bReviewScore != null && review?.bReviewScore != 0)
          FacilityRatingBox(
            rating: review!.bReviewScore!,
            isDarkMode: isDarkMode,
          ),
        if (review?.bReviewScore == null && review?.gRating != null)
          FacilityRatingBox(
            rating: review!.gRating!,
            isDarkMode: isDarkMode,
          ),
        if (facility.hasKitchen ?? false)
          FacilityIcon(
            assetPath:
                isDarkMode ? 'assets/cauldron-dark.png' : 'assets/cauldron.png',
          ),
        if (facility.hasCommunityDinner ?? false)
          Icon(
            Icons.local_dining,
            size: 20,
            color: isDarkMode ? Colors.grey[300] : Colors.black,
          ),
        if ((facility.isVegetarian ?? false) ||
            (facility.hasVeganOption ?? false) ||
            (facility.isVegan ?? false))
          FacilityIcon(
            assetPath: isDarkMode
                ? 'assets/vegetarian-dark.png'
                : 'assets/vegetarian.png',
          ),
      ],
    );
  }
}

class FacilityRatingBox extends StatelessWidget {
  const FacilityRatingBox({
    required this.rating,
    required this.isDarkMode,
    super.key,
  });

  final double rating;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[300] : Colors.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
        border: Border.all(
          color: isDarkMode ? Colors.grey[300]! : Colors.black,
        ),
      ),
      child: Text(
        rating.toStringAsFixed(1),
        style: TextStyle(
          color: isDarkMode ? Colors.black : Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

class FacilityIcon extends StatelessWidget {
  const FacilityIcon({required this.assetPath, super.key});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: 20,
      height: 20,
    );
  }
}
