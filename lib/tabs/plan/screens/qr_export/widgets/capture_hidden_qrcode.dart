import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/qr_export/widgets/qrcode_version_warning.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/model_extensions.dart';
import 'package:camino_ninja_flutter/widgets/route_name_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:repository/repository.dart';

class CaptureHiddenQrcode extends StatelessWidget {
  const CaptureHiddenQrcode({
    required this.qrData,
    required this.plans,
    super.key,
  });
  final String qrData;
  final List<StagePlanModel> plans;

  @override
  Widget build(BuildContext context) {
    final arrow = SvgPicture.asset(
      'assets/ic_arrow_down_curved.svg',
      color: AppColors.primary40,
      width: 40,
    );
    return ColoredBox(
      color: Colors.black.withOpacity(0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Column(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${AppLocalizations.of(context).planFor} ',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    WidgetSpan(
                      child: Image.asset(
                        'assets/bg_camino_ninja_banner_dark.png',
                        height: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const QrcodeVersionWarning(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AspectRatio(
                  aspectRatio: 345 / 316,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final qrSize = constraints.maxHeight;
                                  return Center(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: qrSize,
                                          height: qrSize,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: SizedBox(
                                            width: qrSize - 12,
                                            height: qrSize - 12,
                                            child: PrettyQrView.data(
                                              data: qrData,
                                              errorCorrectLevel:
                                                  QrErrorCorrectLevel.M,
                                              decoration:
                                                  const PrettyQrDecoration(
                                                // shape:
                                                //     PrettyQrCircleFinderSymbol(
                                                //   finderInnerColor:
                                                //       AppColors.primary80,
                                                //   alignmentInnerColor:
                                                //       AppColors.primary80,
                                                // ),
                                                image: PrettyQrDecorationImage(
                                                  image: AssetImage(
                                                    'assets/camino_logo_no_padding.png',
                                                  ),
                                                  clipShape:
                                                      PrettyQrDecorationImageClipShape
                                                          .circle,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -25,
                                          right: -10,
                                          child: arrow,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).scanOrOpenPhoto,
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary40,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray800,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RouteNameText(
                      routeName: plan.route.routeName,
                      routeSubName: plan.route.routeSubName ?? '',
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary80,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.getPlanSubtitle(
                        context,
                        plan,
                      ),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 1,
                color: Colors.white.withOpacity(0.1),
              ),
              itemCount: plans.length,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${AppLocalizations.of(context).savedOn} ${DateTime.now().toHumanReadableDate()}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
