import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/service_extension.dart';
import 'package:camino_ninja_flutter/widgets/service_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:storage/storage.dart';
import 'package:super_tooltip/super_tooltip.dart';

class CityInformationCard extends StatefulWidget {
  const CityInformationCard({this.services = const [], this.city, super.key});
  final CityEntity? city;
  final List<AvailableService> services;

  @override
  State<CityInformationCard> createState() => _CityInformationCardState();
}

class _CityInformationCardState extends State<CityInformationCard> {
  final _controller = SuperTooltipController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: context.isDarkMode ? AppColors.gray700 : AppColors.gray200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.city?.name ?? 'City',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (widget.services.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              children: [
                ...widget.services.map(
                  (serviceType) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ServiceIcon(
                      serviceType: serviceType,
                      size: 20,
                    ),
                  ),
                ),
                _buildInfoIcon(widget.services),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoIcon(List<AvailableService> services) {
    final isDarkMode = context.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: SuperTooltip(
        showBarrier: true,
        barrierColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.15),
        shadowOffset: const Offset(0, 4),
        shadowBlurRadius: 10,
        shadowSpreadRadius: 0,
        backgroundColor:
            isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        borderColor: Colors.transparent,
        arrowTipRadius: 4,
        arrowLength: 8,
        borderRadius: 4,
        arrowTipDistance: 16,
        minimumOutsideMargin: 0,
        hideTooltipOnTap: true,
        controller: _controller,
        bubbleDimensions: EdgeInsets.zero,
        overlayDimensions: EdgeInsets.zero,
        content: SizedBox(
          width: 130,
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            itemCount: services.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final service = services[index];
              return Row(
                children: [
                  ServiceIcon(
                    serviceType: service,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
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
        child: GestureDetector(
          onTap: _controller.showTooltip,
          child: SvgPicture.asset(
            'assets/ic_info.svg',
            width: 20,
          ),
        ),
      ),
    );
  }
}
