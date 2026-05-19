import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

class AlbergueListPrice extends StatelessWidget {
  const AlbergueListPrice({
    required this.price,
    this.isDormitoryClosed = false,
    this.showLabel = false,
    super.key,
  });

  final PriceEntity price;
  final bool isDormitoryClosed;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;

    if (showLabel) {
      // Calculate the maximum label width for alignment
      final labels = _getLabels(context);
      double maxLabelWidth = 0;

      for (final label in labels) {
        if (label != null) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          maxLabelWidth = maxLabelWidth > textPainter.width
              ? maxLabelWidth
              : textPainter.width;
        }
      }

      maxLabelWidth += 20;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildList(
            isDarkMode: isDarkMode,
            context: context,
            center: showLabel,
            maxLabelWidth: maxLabelWidth,
          ),
        ],
      );
    }
    return Wrap(
      spacing: 8,
      children: _buildList(
        isDarkMode: isDarkMode,
        context: context,
        center: showLabel,
      ),
    );
  }

  List<String?> _getLabels(BuildContext context) {
    final labels = <String?>[];
    if (price.priceFromDormitory != null || price.priceToDormitory != null) {
      labels.add(AppLocalizations.of(context).bunkBed);
    }
    if (price.priceFromBedSharedRoom != null ||
        price.priceToBedSharedRoom != null) {
      labels.add(AppLocalizations.of(context).bedSharedRoom);
    }
    if (price.priceFromSingleroom != null || price.priceToSingleroom != null) {
      labels.add(AppLocalizations.of(context).singleRoom);
    }
    if (price.priceFromDoubleroom != null || price.priceToDoubleroom != null) {
      labels.add(AppLocalizations.of(context).doubleRoom);
    }
    if (price.priceFromTripleroom != null || price.priceToTripleroom != null) {
      labels.add(AppLocalizations.of(context).tripleRoom);
    }
    if (price.priceFromQuatroroom != null || price.priceToQuatroroom != null) {
      labels.add(AppLocalizations.of(context).quadrupleRoom);
    }
    if (price.priceFromApartment != null || price.priceToApartment != null) {
      labels.add(AppLocalizations.of(context).apartment);
    }
    return labels;
  }

  List<Widget> _buildList({
    required bool isDarkMode,
    required BuildContext context,
    required bool center,
    double? maxLabelWidth,
  }) {
    final list = <Widget>[];
    if (price.priceFromDormitory != null || price.priceToDormitory != null) {
      list.add(
        PriceRow(
          icon: CommunityMaterialIcons.bunk_bed,
          fromPrice: price.priceFromDormitory,
          toPrice: price.priceToDormitory,
          isClosed: isDormitoryClosed,
          isDarkMode: isDarkMode,
          label: showLabel ? AppLocalizations.of(context).bunkBed : null,
          center: center,
          maxLabelWidth: maxLabelWidth,
        ),
      );
    }
    if (price.priceFromBedSharedRoom != null ||
        price.priceToBedSharedRoom != null) {
      list.add(
        PriceRow(
          icon: Icons.bed,
          fromPrice: price.priceFromBedSharedRoom,
          toPrice: price.priceToBedSharedRoom,
          isDarkMode: isDarkMode,
          label: showLabel ? AppLocalizations.of(context).bedSharedRoom : null,
          center: center,
          maxLabelWidth: maxLabelWidth,
        ),
      );
    }
    if (price.priceFromSingleroom != null || price.priceToSingleroom != null) {
      list.add(
        PriceRow(
          icon: Icons.person,
          fromPrice: price.priceFromSingleroom,
          toPrice: price.priceToSingleroom,
          isDarkMode: isDarkMode,
          label: showLabel ? AppLocalizations.of(context).singleRoom : null,
          center: center,
          maxLabelWidth: maxLabelWidth,
        ),
      );
    }
    if (price.priceFromDoubleroom != null || price.priceToDoubleroom != null) {
      list.add(
        PriceRow(
          icon: Icons.people,
          fromPrice: price.priceFromDoubleroom,
          toPrice: price.priceToDoubleroom,
          isDarkMode: isDarkMode,
          label: showLabel ? AppLocalizations.of(context).doubleRoom : null,
          center: center,
          maxLabelWidth: maxLabelWidth,
        ),
      );
    }
    if (price.priceFromTripleroom != null || price.priceToTripleroom != null) {
      list.add(
        PriceRow(
          icon: Icons.groups,
          fromPrice: price.priceFromTripleroom,
          toPrice: price.priceToTripleroom,
          isDarkMode: isDarkMode,
          label: showLabel ? AppLocalizations.of(context).tripleRoom : null,
          center: center,
          maxLabelWidth: maxLabelWidth,
        ),
      );
    }
    if (price.priceFromQuatroroom != null || price.priceToQuatroroom != null) {
      list.add(
        PriceRow(
          icon: Icons.hotel,
          fromPrice: price.priceFromQuatroroom,
          toPrice: price.priceToQuatroroom,
          isDarkMode: isDarkMode,
          label: showLabel ? AppLocalizations.of(context).quadrupleRoom : null,
          center: center,
          maxLabelWidth: maxLabelWidth,
        ),
      );
    }
    if (price.priceFromApartment != null || price.priceToApartment != null) {
      list.add(
        PriceRow(
          icon: Icons.apartment,
          fromPrice: price.priceFromApartment,
          toPrice: price.priceToApartment,
          isDarkMode: isDarkMode,
          label: showLabel ? AppLocalizations.of(context).apartment : null,
          center: center,
          maxLabelWidth: maxLabelWidth,
        ),
      );
    }
    return list;
  }
}

class PriceRow extends StatelessWidget {
  const PriceRow({
    required this.icon,
    required this.isDarkMode,
    required this.center,
    this.fromPrice,
    this.toPrice,
    this.isClosed = false,
    this.label,
    this.maxLabelWidth,
    super.key,
  });

  final IconData icon;
  final double? fromPrice;
  final double? toPrice;
  final bool isClosed;
  final bool isDarkMode;
  final String? label;
  final bool center;
  final double? maxLabelWidth;

  @override
  Widget build(BuildContext context) {
    final fromPriceNum = fromPrice;
    final toPriceNum = toPrice;

    if (maxLabelWidth != null && label != null) {
      // When we have maxLabelWidth, use a structured layout for alignment
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with fixed padding
          Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              icon,
              size: 20,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          // Label with fixed width based on maxLabelWidth + 16px spacing
          SizedBox(
            width: maxLabelWidth! + 16,
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Price section
          ..._buildPriceWidgets(fromPriceNum, toPriceNum),
        ],
      );
    }

    // Original layout for when showLabel is false
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            icon,
            size: 20,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(label!),
        ],
        ..._buildPriceWidgets(fromPriceNum, toPriceNum),
      ],
    );
  }

  List<Widget> _buildPriceWidgets(double? fromPriceNum, double? toPriceNum) {
    return [
      if (fromPriceNum != null)
        PriceText(
          text:
              fromPriceNum == 0 ? 'Donativo' : fromPriceNum.toInt().toStringAsFixed(0),
          isClosed: isClosed,
          isDarkMode: isDarkMode,
        ),
      if (fromPriceNum != null && toPriceNum != null) ...[
        PriceText(
          text: '-',
          isClosed: isClosed,
          isDarkMode: isDarkMode,
        ),
      ],
      if (toPriceNum != null)
        PriceText(
          text: toPriceNum.toStringAsFixed(0),
          isClosed: isClosed,
          isDarkMode: isDarkMode,
        ),
      if (fromPriceNum == null && toPriceNum != null)
        PriceText(
          text: '€+',
          isClosed: isClosed,
          isDarkMode: isDarkMode,
        )
      else if ((fromPriceNum != null && fromPriceNum != 0) ||
          (toPriceNum != null && fromPriceNum == null))
        PriceText(
          text: '€',
          isClosed: isClosed,
          isDarkMode: isDarkMode,
        ),
    ];
  }
}

class PriceText extends StatelessWidget {
  const PriceText({
    required this.text,
    required this.isDarkMode,
    this.isClosed = false,
    super.key,
  });

  final String text;
  final bool isDarkMode;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            decoration:
                isClosed ? TextDecoration.lineThrough : TextDecoration.none,
          ),
    );
  }
}
