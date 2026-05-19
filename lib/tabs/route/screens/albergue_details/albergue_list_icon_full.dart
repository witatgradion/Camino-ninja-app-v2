import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class AlbergueListIconsFull extends StatelessWidget {
  const AlbergueListIconsFull({
    required this.albergue,
    super.key,
    this.showFull = false,
  });

  final AlbergueEntity albergue;
  final bool showFull;

  @override
  Widget build(BuildContext context) {
    final facility =
        albergue.facilities.isNotEmpty ? albergue.facilities.first : null;

    final bed = <String>[];
    final food = <String>[];
    final kitchen = <String>[];
    final washing = <String>[];
    final pets = <String>[];
    final extras = <String>[];
    final nohay = <String>[];

    // Populate lists based on facility properties
    if (facility != null) {
      if (facility.hasCottonSheets ?? false) {
        bed.add(
          AppLocalizations.of(context).cottonSheetsPillowcases,
        );
      }
      if (facility.hasCubeBeds ?? false) {
        bed.add(
          AppLocalizations.of(context).cubeBeds,
        );
      }
      if (facility.hasCurtains ?? false) {
        bed.add(
          AppLocalizations.of(context).privacyCurtains,
        );
      }
      if (facility.hasPrivateLockers ?? false) {
        bed.add(
          AppLocalizations.of(context).privateLockers,
        );
      }
      if (facility.hasIndividualPowerplug ?? false) {
        bed.add(
          AppLocalizations.of(context).individualPowerPlugs,
        );
      }

      if (facility.hasRestaurant ?? false) {
        food.add(
          AppLocalizations.of(context).restaurant,
        );
      }
      if (facility.hasCommunityLunch ?? false) {
        food.add(
          AppLocalizations.of(context).communityLunch,
        );
      }
      if (facility.hasLunch ?? false) {
        food.add(
          AppLocalizations.of(context).lunchAvailable,
        );
      }
      if (facility.hasCommunityDinner ?? false) {
        food.add(
          facility.isDinnerIncluded ?? false
              ? AppLocalizations.of(context).communityDinnerIncluded_445
              : AppLocalizations.of(context).communityDinner,
        );
      }
      if (facility.hasDinner ?? false) {
        food.add(
          facility.isDinnerIncluded ?? false
              ? AppLocalizations.of(context).dinnerIncluded_444
              : AppLocalizations.of(context).dinnerAvailable,
        );
      }
      if (facility.hasDonativoBreakfast ?? false) {
        food.add(
          AppLocalizations.of(context).donativoBreakfast,
        );
      }
      if (facility.hasBreakfast ?? false) {
        food.add(
          facility.isBreakfastIncluded ?? false
              ? AppLocalizations.of(context).breakfastIncluded
              : AppLocalizations.of(context).breakfast,
        );
      }
      if (facility.isVegan ?? false) {
        food.add(
          AppLocalizations.of(context).vegan,
        );
      }
      if (facility.isVegetarian ?? false) {
        food.add(
          AppLocalizations.of(context).vegetarian,
        );
      }
      if (facility.hasVegetarianOption ?? false) {
        food.add(
          AppLocalizations.of(context).vegetarianOption,
        );
      }
      if (facility.hasVeganOption ?? false) {
        food.add(
          AppLocalizations.of(context).veganOption,
        );
      }
      if (facility.isOrganic ?? false) {
        food.add(
          AppLocalizations.of(context).organic,
        );
      }

      if (facility.hasKitchen ?? false) {
        kitchen.add(
          AppLocalizations.of(context).kitchen,
        );
      }
      if (facility.hasFridge ?? false) {
        kitchen.add(
          AppLocalizations.of(context).refrigerator,
        );
      }
      if (facility.hasCooktops ?? false) {
        kitchen.add(
          AppLocalizations.of(context).cooktops,
        );
      }
      if (facility.hasOven ?? false) {
        kitchen.add(
          AppLocalizations.of(context).oven,
        );
      }
      if (facility.hasMicrowave ?? false) {
        kitchen.add(
          AppLocalizations.of(context).microwave,
        );
      }
      if (facility.hasWaterBoiler ?? false) {
        kitchen.add(
          AppLocalizations.of(context).waterBoiler,
        );
      }
      if (facility.hasPlatesUtensils ?? false) {
        kitchen.add(
          AppLocalizations.of(context).platesUtensils,
        );
      }
      if (facility.hasCookingPots ?? false) {
        kitchen.add(
          AppLocalizations.of(context).cookingPots,
        );
      }

      if (facility.hasFullLaundryService ?? false) {
        washing.add(
          AppLocalizations.of(context).fullLaundryService,
        );
      }
      if (facility.hasWashingMachine ?? false) {
        washing.add(AppLocalizations.of(context).washingMachine);
      }
      if (facility.hasTumbleDryer ?? false) {
        washing.add(AppLocalizations.of(context).tumbleDryer);
      }
      if (facility.hasHandWashingSink ?? false) {
        washing.add(AppLocalizations.of(context).handWashingSink);
      }
      if (facility.hasSpinDryer ?? false) {
        washing.add(AppLocalizations.of(context).spinDryer);
      }
      if (facility.hasClothesLine ?? false) {
        washing.add(AppLocalizations.of(context).clothesline);
      }

      if (facility.petsAllowed ?? false) {
        pets.add(AppLocalizations.of(context).allowsPets);
      }

      if (facility.hasWifi ?? false) {
        extras.add(AppLocalizations.of(context).wifi);
      }
      if (facility.hasTv ?? false) extras.add(AppLocalizations.of(context).tv);
      if (facility.hasSwimmingPool ?? false) {
        extras.add(AppLocalizations.of(context).swimmingPool);
      }

      // Populate nohay list
      if (facility.hasWifi != true) {
        nohay.add(AppLocalizations.of(context).wifi);
      }
    }

    final facilities = [
      ...bed,
      ...food,
      ...kitchen,
      ...washing,
      ...pets,
      ...extras,
      ...nohay,
    ];

    final isDarkMode = context.isDarkMode;

    if (showFull) {
      // Keep original logic for showFull = true
      return Wrap(
        runSpacing: 8,
        spacing: 8,
        children: facilities
            .map(
              (e) => Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.yellow100 : AppColors.yellow300,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Text(
                  e,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ),
            )
            .toList(),
      );
    } else {
      // For showFull = false, calculate items that fit in one row
      return LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          double currentWidth = 0;
          var itemsToShow = 0;
          const spacing = 2.0;
          const horizontalPadding = 6.0; // 3 * 2

          // Calculate "And more" width once
          final andMoreTextPainter = TextPainter(
            text: TextSpan(
              text: AppLocalizations.of(context).andMore,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDarkMode ? AppColors.gray400 : AppColors.gray700,
                  ),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();
          final andMoreWidth = andMoreTextPainter.size.width +
              spacing +
              5; // Include the 5-point margin

          for (var i = 0; i < facilities.length; i++) {
            final textPainter = TextPainter(
              text: TextSpan(
                text: facilities[i],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
              ),
              maxLines: 1,
              textDirection: TextDirection.ltr,
            )..layout();

            final itemWidth = textPainter.size.width + horizontalPadding;
            final nextWidth =
                currentWidth + itemWidth + (itemsToShow > 0 ? spacing : 0);

            // Check if we need to reserve space for "And more"
            final needsAndMore = i < facilities.length - 1;
            final availableWidth =
                needsAndMore ? screenWidth - andMoreWidth : screenWidth;

            if (nextWidth <= availableWidth) {
              currentWidth = nextWidth;
              itemsToShow++;
            } else {
              break;
            }
          }

          final displayItems = facilities.take(itemsToShow).toList();
          final hasMore = itemsToShow < facilities.length;

          return Wrap(
            runSpacing: 2,
            spacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...displayItems.map(
                (e) => Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white : AppColors.gray600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                  child: Text(
                    e,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                  ),
                ),
              ),
              if (hasMore)
                Container(
                  margin: const EdgeInsets.only(left: 5),
                  child: Text(
                    AppLocalizations.of(context).andMore,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDarkMode
                              ? AppColors.gray400
                              : AppColors.gray700,
                        ),
                  ),
                ),
            ],
          );
        },
      );
    }
  }
}
