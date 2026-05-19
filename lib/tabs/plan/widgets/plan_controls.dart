import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PlanControls extends StatelessWidget {
  const PlanControls({
    super.key,
    this.onImport,
    this.onCreate,
    this.onShare,
    this.onSync,
    this.isSyncing = false,
  });
  final VoidCallback? onShare;
  final VoidCallback? onImport;
  final VoidCallback? onCreate;
  final VoidCallback? onSync;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            context.isDarkMode
                ? 'assets/bg_stage_planner_controls.webp'
                : 'assets/bg_stage_planner_controls_light.webp',
          ),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          if (onCreate != null) ...[
            _buildButton(
              context,
              text: AppLocalizations.of(context).create,
              icon: 'assets/ic_plus.svg',
              onTap: onCreate,
              isFilled: true,
            ),
          ],
          if (onImport != null) ...[
            _buildButton(
              context,
              text: AppLocalizations.of(context).import,
              icon: 'assets/ic_import.svg',
              onTap: onImport,
            ),
          ],
          if (onShare != null) ...[
            _buildButton(
              context,
              text: AppLocalizations.of(context).share,
              icon: 'assets/ic_share_outline.svg',
              onTap: onShare,
            ),
          ],
          if (onSync != null) ...[
            _buildSyncButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    final borderColor =
        context.isDarkMode ? AppColors.primary80 : Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: isSyncing ? null : onSync,
              customBorder: const CircleBorder(),
              child: Center(
                child: isSyncing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: borderColor,
                        ),
                      )
                    : Icon(
                        Icons.sync,
                        size: 20,
                        color: borderColor,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).sync,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String text,
    required String icon,
    VoidCallback? onTap,
    bool isFilled = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: isFilled
                  ? (context.isDarkMode ? AppColors.primary80 : Colors.white)
                  : Colors.transparent,
              border: Border.all(
                color: !isFilled
                    ? (context.isDarkMode ? AppColors.primary80 : Colors.white)
                    : Colors.transparent,
              ),
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 20,
                  color: isFilled
                      ? (context.isDarkMode
                          ? Colors.black
                          : AppColors.primary40)
                      : (context.isDarkMode
                          ? AppColors.primary80
                          : Colors.white),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
