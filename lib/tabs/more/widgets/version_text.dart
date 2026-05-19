import 'package:analytics_services/analytics_services.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatelessWidget {
  const VersionText({
    required this.packageInfoFuture,
    super.key,
    this.onSecretTap,
  });

  final Future<PackageInfo> packageInfoFuture;

  /// Optional secondary tap callback fired on every tap of the version
  /// text. Used by the More screen's hidden DB-export easter egg
  /// (non-production flavors only). The primary copy-to-clipboard
  /// behavior always runs regardless.
  final void Function(PackageInfo info)? onSecretTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: packageInfoFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final info = snapshot.data!;
        final versionColor =
            context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                onSecretTap?.call(info);
                await Clipboard.setData(
                  ClipboardData(text: info.version),
                );
                GetIt.instance<IAnalyticsService>().track(
                  VersionCopiedEvent(version: info.version),
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context).versionCopied,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: context.textTheme.bodySmall,
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context).currentVersion,
                    ),
                    TextSpan(
                      text: ' ${info.version}',
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: versionColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
