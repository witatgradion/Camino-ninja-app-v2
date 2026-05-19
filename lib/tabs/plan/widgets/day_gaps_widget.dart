import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class DayGapsWidget extends StatelessWidget {
  const DayGapsWidget({
    required this.daysDifference,
    this.showSpaceAhead = true,
    super.key,
  });
  final int daysDifference;
  final bool showSpaceAhead;

  @override
  Widget build(BuildContext context) {
    final daysGap = daysDifference - 1;
    final daysGapText =
        '$daysGap ${daysGap > 1 ? AppLocalizations.of(context).daysGap : AppLocalizations.of(context).dayGap}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpaceAhead) const SizedBox(width: 52),
            Expanded(
              child: Stack(
                children: [
                  const Center(
                    child: DottedLine(
                      dashGapLength: 8,
                      dashLength: 8,
                      dashColor: Color(0xFF48454E),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF48454E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF48454E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 20,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF48454E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            daysGapText,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.gray100,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
