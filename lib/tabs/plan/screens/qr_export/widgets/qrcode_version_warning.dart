import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:flutter/material.dart';

// TODO: upgrade this to the right number when release chottulink qrcode version to store
const kChottulinkQrcodeVersion = '2.2.390';

class QrcodeVersionWarning extends StatelessWidget {
  const QrcodeVersionWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.tertiary60.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tertiary70),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning,
            color: AppColors.tertiary60,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              AppLocalizations.of(context)
                  .scanWithVersion(kChottulinkQrcodeVersion),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.tertiary60,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
