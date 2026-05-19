import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/services/sync_indicator_status.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';

class SyncIndicatorPill extends StatefulWidget {
  const SyncIndicatorPill({required this.statusNotifier, super.key});

  final ValueNotifier<SyncIndicatorStatus> statusNotifier;

  @override
  State<SyncIndicatorPill> createState() => _SyncIndicatorPillState();
}

class _SyncIndicatorPillState extends State<SyncIndicatorPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  SyncIndicatorStatus _displayedStatus = SyncIndicatorStatus.idle;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    widget.statusNotifier.addListener(_onStatusChanged);
  }

  @override
  void dispose() {
    widget.statusNotifier.removeListener(_onStatusChanged);
    _slideController.dispose();
    super.dispose();
  }

  void _onStatusChanged() {
    final newStatus = widget.statusNotifier.value;
    if (newStatus != SyncIndicatorStatus.idle) {
      setState(() => _displayedStatus = newStatus);
      if (!_slideController.isCompleted) {
        _slideController.forward();
      }
    } else {
      _slideController.reverse().then((_) {
        if (mounted) {
          setState(() => _displayedStatus = SyncIndicatorStatus.idle);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedStatus == SyncIndicatorStatus.idle &&
        !_slideController.isAnimating) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Center(child: _buildPillContent(context)),
    );
  }

  Widget _buildPillContent(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = AppLocalizations.of(context);

    final Widget icon;
    final String label;
    final Color bgColor;
    final Color contentColor;

    switch (_displayedStatus) {
      case SyncIndicatorStatus.syncing:
        contentColor = isDark ? Colors.white : AppColors.primary10;
        icon = SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: contentColor,
          ),
        );
        label = l10n.syncing;
        bgColor = isDark ? AppColors.primary30 : AppColors.primary90;
      case SyncIndicatorStatus.success:
        contentColor = isDark ? AppColors.primary80 : AppColors.primary20;
        icon = Icon(
          Icons.check_circle_outline,
          size: 16,
          color: contentColor,
        );
        label = l10n.synced;
        bgColor = isDark ? AppColors.primary30 : AppColors.primary90;
      case SyncIndicatorStatus.failure:
        contentColor = isDark ? AppColors.error80 : AppColors.error40;
        icon = Icon(Icons.error_outline, size: 16, color: contentColor);
        label = l10n.syncFailed;
        bgColor = isDark ? AppColors.error30 : AppColors.error90;
      case SyncIndicatorStatus.idle:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
