import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/widgets/qrcode_version_warning.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrcodeWidget extends StatelessWidget {
  const QrcodeWidget({required this.qrSize, required this.qrData, super.key});
  final double qrSize;
  final String qrData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${AppLocalizations.of(context).planFor} ',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                child: Image.asset(
                  context.isDarkMode
                      ? 'assets/bg_camino_ninja_banner_dark.png'
                      : 'assets/bg_camino_ninja_banner_light.png',
                  height: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const QrcodeVersionWarning(),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).appRestrictionNote,
          textAlign: TextAlign.center,
          style: context.textTheme.bodySmall,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: SizedBox()),
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: qrSize,
                height: qrSize,
                child: PrettyQrView.data(
                  data: qrData,
                  errorCorrectLevel: QrErrorCorrectLevel.M,
                  decoration: const PrettyQrDecoration(
                    // shape: PrettyQrCircleFinderSymbol(
                    //   finderInnerColor: AppColors.primary80,
                    //   alignmentInnerColor: AppColors.primary80,
                    // ),
                    image: PrettyQrDecorationImage(
                      image: AssetImage('assets/camino_logo_no_padding.png'),
                      clipShape: PrettyQrDecorationImageClipShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/ic_arrow_down_curved.svg',
                    width: 40,
                    colorFilter: ColorFilter.mode(
                      context.isDarkMode ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
