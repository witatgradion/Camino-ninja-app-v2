import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/app_urls.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/safe_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class BuyMeACoffeeBanner extends StatelessWidget {
  const BuyMeACoffeeBanner({super.key});

  static const String _brandName = 'Ninja';

  Future<void> _onTap(BuildContext context) async {
    GetIt.instance<IAnalyticsService>().track(BuyMeACoffeeTappedEvent());
    await launchUrlSafely(
      AppUrls.buyMeACoffee,
      context: context,
      trackEvent: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final isDarkMode = context.isDarkMode;
    final l10n = AppLocalizations.of(context);
    final borderRadius = BorderRadius.circular(16);

    final cardColor =
        isDarkMode ? const Color(0xFF1F2A37) : const Color(0xFF006781);
    const titleColor = Colors.white;

    final titleText = l10n.buyNinjaACoffee(_brandName);
    final brandIndex = titleText.indexOf(_brandName);
    final List<InlineSpan> spans;
    if (brandIndex == -1) {
      spans = [TextSpan(text: titleText)];
    } else {
      spans = [
        if (brandIndex > 0)
          TextSpan(text: titleText.substring(0, brandIndex)),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: SvgPicture.asset(
            'assets/ninja_wordmark.svg',
            height: 16,
          ),
        ),
        if (brandIndex + _brandName.length < titleText.length)
          TextSpan(
            text: titleText.substring(brandIndex + _brandName.length),
          ),
      ];
    }

    return Center(
      child: SizedBox(
        width: 278,
        child: Material(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: const BorderSide(),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _onTap(context),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 96),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: spans,
                              style: textTheme.titleSmall?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          SvgPicture.asset(
                            'assets/bmc_button.svg',
                            height: 38,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x66FFD24A),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Lottie.asset(
                          'assets/lottie/coffee.json',
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
