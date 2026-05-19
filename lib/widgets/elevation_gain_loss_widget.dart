import 'package:auto_size_text/auto_size_text.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class ElevationGainLossWidget extends StatelessWidget {
  const ElevationGainLossWidget({
    required this.elevationGain,
    required this.elevationLoss,
    this.isBold = false,
    this.group,
    super.key,
  });
  final String elevationGain;
  final String elevationLoss;
  final bool isBold;
  final AutoSizeGroup? group;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/ic_elev_gain.svg',
          width: 20,
        ),
        AutoSizeText(
          elevationGain,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
          group: group,
        ),
        SvgPicture.asset(
          'assets/ic_elev_loss.svg',
          width: 20,
        ),
        AutoSizeText(
          elevationLoss,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
          group: group,
        ),
      ],
    );
  }
}
