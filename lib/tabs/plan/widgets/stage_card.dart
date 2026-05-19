import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/unit_converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repository/repository.dart';

class StageCard extends StatelessWidget {
  const StageCard({
    required this.stage,
    required this.index,
    this.backgroundColor,
    this.stageColor,
    this.firstLineColor,
    this.secondLineColor,
    this.showEditButton = true,
    this.onEditTap,
    this.onTap,
    this.onNoteTap,
    this.computedDate,
    this.showTodayBadge = true,
    this.routeColor,
    super.key,
  });
  final StageModel stage;
  final int index;
  final DateTime? computedDate;
  final Color? backgroundColor;
  final Color? stageColor;
  final Color? firstLineColor;
  final Color? secondLineColor;
  final bool showEditButton;
  final VoidCallback? onEditTap;
  final VoidCallback? onTap;
  final VoidCallback? onNoteTap;
  final bool showTodayBadge;

  /// When set, draws a thin colored pill on the card's
  /// left edge using the stage's route color so users can
  /// tell at a glance which route this stage belongs to.
  final Color? routeColor;

  @override
  Widget build(BuildContext context) {
    final mainColor =
        context.isDarkMode ? AppColors.primary80 : AppColors.primary40;
    final effectiveDate = computedDate ?? stage.date;
    final isToday = effectiveDate.isSameDay(DateTime.now());
    final hasNote = stage.stageNotes?.trim().isNotEmpty ?? false;
    return Row(
      children: [
        Column(
          children: [
            Text(
              AppLocalizations.of(context).stageSingular,
              style: context.textTheme.bodySmall?.copyWith(
                color: stageColor ?? mainColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: stageColor ?? mainColor,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                (index + 1).toString(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: stageColor ?? mainColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: backgroundColor ??
                  (context.isDarkMode ? AppColors.gray800 : AppColors.gray200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  routeColor != null ? 12 : 16,
                  16,
                  16,
                  16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (routeColor != null) ...[
                      Container(
                        width: 4,
                        height: 28,
                        decoration: BoxDecoration(
                          color: routeColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                  children: [
                    if (isToday && showTodayBadge) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.yellow300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              AppLocalizations.of(context).today,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: stage.startCity?.name ?? '',
                                      style:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: firstLineColor ?? mainColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    WidgetSpan(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 2,),
                                        child: SvgPicture.asset(
                                          'assets/ic_arrow_left_outline.svg',
                                          width: 15,
                                          color: firstLineColor ?? mainColor,
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: stage.endCity?.name ?? '',
                                      style:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: firstLineColor ?? mainColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              BlocBuilder<AppCubit, AppState>(
                                buildWhen: (previous, current) =>
                                    previous.unit != current.unit,
                                builder: (_, appState) {
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        if (effectiveDate != null) ...[
                                          TextSpan(
                                            text: effectiveDate
                                                .toHumanReadableDate(),
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                              color: secondLineColor ??
                                                  (context.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Container(
                                              width: 4,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color:
                                                    secondLineColor ?? mainColor,
                                                shape: BoxShape.circle,
                                              ),
                                              margin: const EdgeInsets.only(
                                                  left: 8, right: 10,),
                                            ),
                                          ),
                                        ],
                                        WidgetSpan(
                                          child: SvgPicture.asset(
                                            'assets/ic_walk.svg',
                                            width: 16,
                                            color: secondLineColor ??
                                                (context.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        const WidgetSpan(
                                          child: SizedBox(width: 4),
                                        ),
                                        TextSpan(
                                          text: UnitConverter.displayDistance(
                                            kilometers: stage.distance ?? 0,
                                            unit: appState.unit,
                                          ),
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                            color: secondLineColor ??
                                                (context.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        if (showEditButton) ...[
                          const SizedBox(width: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: onEditTap,
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: mainColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/ic_edit.svg',
                                    width: 16,
                                    color: context.isDarkMode
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              if (onNoteTap != null) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: onNoteTap,
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: mainColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      hasNote
                                          ? Icons.sticky_note_2
                                          : Icons.sticky_note_2_outlined,
                                      size: 14,
                                      color: context.isDarkMode
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                    if (hasNote) ...[
                      const SizedBox(height: 8),
                      _StageCardNotePreview(
                        note: stage.stageNotes!,
                        color: secondLineColor ??
                            (context.isDarkMode ? Colors.white : Colors.black),
                      ),
                    ],
                  ],
                ),
              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StageCardNotePreview extends StatelessWidget {
  const _StageCardNotePreview({required this.note, required this.color});

  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.sticky_note_2_outlined,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            note,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
