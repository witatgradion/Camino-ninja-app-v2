import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:repository/repository.dart';

class IncompletePlanCard extends StatefulWidget {
  const IncompletePlanCard({
    required this.plan,
    required this.onDeleteTap,
    super.key,
  });

  final IncompletePlanInfo plan;
  final VoidCallback onDeleteTap;

  @override
  State<IncompletePlanCard> createState() => _IncompletePlanCardState();
}

class _IncompletePlanCardState extends State<IncompletePlanCard>
    with SingleTickerProviderStateMixin {
  late SlidableController _slidableController;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
  }

  @override
  void dispose() {
    _slidableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    final stageCount = widget.plan.stageCount;
    final stagesText =
        '$stageCount ${stageCount <= 1 ? AppLocalizations.of(context).stageSingular : AppLocalizations.of(context).stagePlural}';

    return Slidable(
      key: ValueKey('incomplete_plan_${widget.plan.id}'),
      controller: _slidableController,
      groupTag: 'plan_slidables',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          CustomSlidableAction(
            onPressed: (context) => widget.onDeleteTap(),
            backgroundColor: const Color(0xFFE02424),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: SvgPicture.asset(
                'assets/ic_trash_outline.svg',
                width: 32,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? AppColors.gray800 : AppColors.gray200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/ic_shellfish.svg',
                        width: 20,
                        color: context.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.plan.name ??
                                  AppLocalizations.of(context)
                                      .unnamedPlan,
                              style:
                                  context.textTheme.bodyMedium?.copyWith(
                                color: mainColor,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stagesText,
                              style:
                                  context.textTheme.bodySmall?.copyWith(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: context.isDarkMode
                                    ? AppColors.yellow300
                                        .withValues(alpha: 0.15)
                                    : AppColors.yellow300
                                        .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: context.isDarkMode
                                        ? AppColors.yellow300
                                        : AppColors.yellow300
                                            .withValues(alpha: 0.8),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .planDataIncomplete,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                        color: context.isDarkMode
                                            ? AppColors.yellow300
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
