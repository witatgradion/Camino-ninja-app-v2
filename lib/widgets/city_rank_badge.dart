import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_destination/cubit/select_destination_cubit.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/widgets/positioned_info_tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CityRankBadge extends StatefulWidget {
  const CityRankBadge({
    required this.cityPairRank,
    required this.percentage,
    required this.startCityName,
    required this.endCityName,
    super.key,
  });
  final CityPairRank cityPairRank;
  final double percentage;
  final String startCityName;
  final String endCityName;

  @override
  State<CityRankBadge> createState() => _CityRankBadgeState();
}

class _CityRankBadgeState extends State<CityRankBadge> {
  final _tooltipWidth = 300.0;
  final _arrowLength = 8.0;
  final _arrowTipDistance = 16.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: widget.cityPairRank.bgColor(context),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              widget.cityPairRank.name(context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        _buildInfoIcon(),
      ],
    );
  }

  Widget _buildInfoIcon() {
    const tooltipItemHeight = 16.0;
    const tooltipItemSpacing = 8.0;
    const tooltipItemCount = 3;
    final isDarkMode = context.isDarkMode;
    return PositionedInfoTooltip(
      tooltipWidth: _tooltipWidth,
      tooltipContentHeight:
          tooltipItemCount * tooltipItemHeight +
              (tooltipItemCount - 1) * tooltipItemSpacing,
      arrowLength: _arrowLength,
      arrowTipDistance: _arrowTipDistance,
      content: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(4),
        ),
        width: _tooltipWidth,
        child: Text(
          AppLocalizations.of(context).travelerStats(
            widget.endCityName,
            '${widget.percentage.toStringAsFixed(0)}%',
            widget.startCityName,
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      icon: SvgPicture.asset(
        'assets/ic_info.svg',
        width: 24,
        colorFilter:
            ColorFilter.mode(widget.cityPairRank.bgColor(context), BlendMode.srcIn),
      ),
    );
  }
}
