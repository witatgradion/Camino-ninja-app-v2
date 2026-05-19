import 'package:auto_size_text/auto_size_text.dart';
import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/select_destination/cubit/select_destination_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/service_extension.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:camino_ninja_flutter/widgets/city_rank_badge.dart';
import 'package:camino_ninja_flutter/widgets/positioned_info_tooltip.dart';
import 'package:camino_ninja_flutter/widgets/service_icon.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';

class CityListItem extends StatefulWidget {
  const CityListItem({
    required this.destination,
    required this.onClick,
    super.key,
    this.isFirst = false,
    this.showInBetweenDistance = false,
    this.showFullText = true,
    this.showTrailingIcon = true,
    this.isSelected = false,
    this.distanceGroupKey,
    this.percentage,
    this.cityPairRank,
    this.startCityName,
  });

  final Destination destination;
  final bool showInBetweenDistance;
  final bool isFirst;
  final bool showFullText;
  final VoidCallback onClick;
  final bool showTrailingIcon;
  final bool isSelected;
  final AutoSizeGroup? distanceGroupKey;
  final double? percentage;
  final CityPairRank? cityPairRank;
  final String? startCityName;

  @override
  State<CityListItem> createState() => _CityListItemState();
}

class _CityListItemState extends State<CityListItem> {
  final _tooltipWidth = 130.0;
  final _arrowLength = 8.0;
  final _arrowTipDistance = 16.0;
  final _tooltipItemHeight = 16.0;
  final _tooltipItemSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    return InkWell(
      onTap: widget.onClick,
      child: Column(
        children: [
          if (!widget.isFirst && widget.showInBetweenDistance) ...[
            // A divider with text in the middle
            Stack(
              children: [
                Align(
                  child: Divider(
                    color: isDarkMode
                        ? const Color(0xFF48454E)
                        : const Color(0xFFD1D5DB),
                  ),
                ),
                Align(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF48454E)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: BlocBuilder<AppCubit, AppState>(
                      builder: (context, state) {
                        return Text(
                          UnitConverter.displayDistance(
                            kilometers: widget.destination.distanceFromPrevious,
                            unit: state.unit,
                          ),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 24),
                Container(
                  width: 50,
                  padding: const EdgeInsets.only(right: 4),
                  alignment: Alignment.topLeft,
                  child: BlocBuilder<AppCubit, AppState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            UnitConverter.convertDistance(
                              kilometers: widget.destination.totalDistance,
                              unit: state.unit,
                            ).toStringAsFixed(1),
                            group: widget.distanceGroupKey,
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                          AutoSizeText(
                            state.unit.distanceUnit,
                            group: widget.distanceGroupKey,
                            maxLines: 1,
                            minFontSize: 10,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.cityPairRank != null &&
                          widget.percentage != null) ...[
                        CityRankBadge(
                          cityPairRank: widget.cityPairRank!,
                          percentage: widget.percentage!,
                          startCityName: widget.startCityName ?? '',
                          endCityName: widget.destination.name,
                        ),
                        const SizedBox(height: 4),
                      ],
                      RichText(
                        overflow: widget.showFullText
                            ? TextOverflow.clip
                            : TextOverflow.ellipsis,
                        maxLines: widget.showFullText ? null : 2,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.destination.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? AppColors.primary80
                                        : AppColors.primary40,
                                  ),
                            ),
                            if (widget.destination.etapeCity &&
                                !widget.showInBetweenDistance)
                              const WidgetSpan(
                                alignment: PlaceholderAlignment.top,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Icon(
                                    CommunityMaterialIcons.check_outline,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.percentage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '''${widget.percentage!.toStringAsFixed(0)}% ${AppLocalizations.of(context).choseThisCity}''',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode
                                        ? AppColors.gray400
                                        : AppColors.gray900,
                                  ),
                        ),
                      ],
                      if (widget.destination.availableServices.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          children: [
                            ...widget.destination.availableServices.map(
                              (serviceType) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 1),
                                child: ServiceIcon(
                                  serviceType: serviceType,
                                  size: 20,
                                ),
                              ),
                            ),
                            // Info icon at the end
                            _buildInfoIcon(),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.showTrailingIcon) ...[
                  const Icon(
                    Icons.chevron_right,
                    size: 32,
                  ),
                ],
                if (widget.isSelected) ...[
                  const SizedBox(height: 8),
                  SvgPicture.asset(
                    'assets/ic_check_circle.svg',
                    width: 24,
                    color:
                        isDarkMode ? AppColors.primary80 : AppColors.primary40,
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIcon() {
    final tooltipContentHeight =
        widget.destination.availableServices.length * _tooltipItemHeight +
            (widget.destination.availableServices.length - 1) *
                _tooltipItemSpacing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: PositionedInfoTooltip(
        tooltipWidth: _tooltipWidth,
        tooltipContentHeight: tooltipContentHeight,
        arrowLength: _arrowLength,
        arrowTipDistance: _arrowTipDistance,
        content: SizedBox(
          width: _tooltipWidth,
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: widget.destination.availableServices.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: _tooltipItemSpacing),
            itemBuilder: (context, index) {
              final service = widget.destination.availableServices[index];
              return Row(
                children: [
                  ServiceIcon(
                    serviceType: service,
                    size: _tooltipItemHeight,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      service.getServiceName(context),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        icon: SvgPicture.asset(
          'assets/ic_info.svg',
          width: 20,
        ),
      ),
    );
  }
}
