import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/main_option_selector.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/stage_overview_card.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/add_edit_stage/widgets/sub_option_selector.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/utils/string_ext.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

enum StageDetailCardType {
  startCity,
  endCity,
  startAlbergue,
  endAlbergue,
}

class StageDetailCard extends StatelessWidget {
  const StageDetailCard({
    required this.stage,
    required this.index,
    required this.onDeleteTap,
    required this.onEditTap,
    required this.onMapTap,
    this.plan,
    this.onReviewTap,
    this.routeAccentColor,
    this.onDaysToStayChanged,
    this.onNoteTap,
    super.key,
  });
  final StageModel stage;
  final StagePlanModel? plan;
  final int index;
  final VoidCallback onDeleteTap;
  final ValueChanged<StageDetailCardType> onEditTap;
  final VoidCallback onMapTap;
  final ValueChanged<AlbergueEntity>? onReviewTap;


  /// Optional accent color for multi-route plans.
  /// When set, overrides the default header background color.
  final Color? routeAccentColor;
  final ValueChanged<int>? onDaysToStayChanged;
  final VoidCallback? onNoteTap;
  @override
  Widget build(BuildContext context) {
    final computedDate = plan?.computeStageDate(index);
    final isPast = computedDate?.isPastDate() ?? false;
    final shouldShowReviewStart = isPast && stage.startAlbergue != null;
    final shouldShowReviewEnd = isPast && stage.endAlbergue != null;

    final startAlbergueText =
        stage.customStartNotes ?? stage.startAlbergue?.name;
    final endAlbergueText = stage.customEndNotes ?? stage.endAlbergue?.name;
    return Stack(
      children: [
        Container(
          height: 62,
          decoration: BoxDecoration(
            color: routeAccentColor ?? AppColors.primary80,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 11,
                left: 16,
                child: Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context).stageSingular}'
                      ' ${index + 1}',
                      style:
                          context.textTheme.bodyMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (computedDate != null) ...[
                      Text(
                        ' · ${computedDate.toHumanReadableDate()}',
                        style:
                            context.textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: 16,
                child: InkWell(
                  onTap: onDeleteTap,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE02424),
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/ic_trash_outline.svg',
                      width: 18.5,
                      color: const Color(0xFFE02424),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 43),
          decoration: BoxDecoration(
            color: context.isDarkMode ? AppColors.gray800 : AppColors.primary95,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StageMainOptionSelector(
                index: 1,
                title: AppLocalizations.of(context).startOfStage,
                value: stage.startCity?.name,
                placeholder:
                    AppLocalizations.of(context).selectStartingCity,
                onTap: () =>
                    onEditTap(StageDetailCardType.startCity),
              ),
              StageSubOptionSelector(
                title: startAlbergueText.isNotNullOrEmpty
                    ? AppLocalizations.of(context).iWillStayHere
                    : AppLocalizations.of(context).iWillStayHereOptional,
                value: startAlbergueText,
                placeholder:
                    AppLocalizations.of(context).selectOrSpecify,
                onTap: () =>
                    onEditTap(StageDetailCardType.startAlbergue),
                subItem: shouldShowReviewStart
                    ? _buildReviewButton(
                        context,
                        stage.startAlbergue!,
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              StageMainOptionSelector(
                index: 2,
                title: AppLocalizations.of(context).endOfStage,
                value: stage.endCity?.name,
                placeholder:
                    AppLocalizations.of(context)
                        .selectDestinationCity,
                onTap: () =>
                    onEditTap(StageDetailCardType.endCity),
              ),
              const SizedBox(height: 8),
              StageSubOptionSelector(
                title: endAlbergueText.isNotNullOrEmpty
                    ? AppLocalizations.of(context).iWillStayHere
                    : AppLocalizations.of(context).iWillStayHereOptional,
                value: endAlbergueText,
                placeholder:
                    AppLocalizations.of(context).selectOrSpecify,
                onTap: () =>
                    onEditTap(StageDetailCardType.endAlbergue),
                subItem: shouldShowReviewEnd
                    ? _buildReviewButton(
                        context,
                        stage.endAlbergue!,
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              _buildDaysToStayStepper(context),
              const SizedBox(height: 8),
              StageOverviewCard(stage: stage, onMapTap: onMapTap),
              const SizedBox(height: 8),
              _StageNoteCard(
                note: stage.stageNotes,
                onTap: onNoteTap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaysToStayStepper(BuildContext context) {
    final primaryColor = context.isDarkMode
        ? AppColors.primary80
        : AppColors.primary40;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.nights_stay_outlined,
            size: 18,
            color: primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context).nightsAtStop(stage.daysToStay),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.isDarkMode
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          _buildStepperButton(
            icon: Icons.remove,
            onTap: stage.daysToStay > 1
                ? () => onDaysToStayChanged
                    ?.call(stage.daysToStay - 1)
                : null,
            context: context,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${stage.daysToStay}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.isDarkMode
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          _buildStepperButton(
            icon: Icons.add,
            onTap: stage.daysToStay < 30
                ? () => onDaysToStayChanged
                    ?.call(stage.daysToStay + 1)
                : null,
            context: context,
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback? onTap,
    required BuildContext context,
  }) {
    final primaryColor = context.isDarkMode
        ? AppColors.primary80
        : AppColors.primary40;
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDisabled
              ? (context.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade300)
              : primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDisabled
              ? Colors.grey
              : (context.isDarkMode ? Colors.black : Colors.white),
        ),
      ),
    );
  }

  Widget _buildReviewButton(
    BuildContext context,
    AlbergueEntity startAlbergue,
  ) {
    return CustomOutlineButton(
      height: 31,
      text: AppLocalizations.of(context).howWasYourStay,
      onTap: () => onReviewTap?.call(startAlbergue),
    );
  }
}

class _StageNoteCard extends StatelessWidget {
  const _StageNoteCard({required this.note, this.onTap});

  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final primaryColor = isDark ? AppColors.primary80 : AppColors.primary40;
    final hasNote = note?.isNotEmpty ?? false;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.edit,
              size: 18,
              color: primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).notes,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasNote
                        ? note!
                        : AppLocalizations.of(context).addANote,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: hasNote
                          ? (isDark ? Colors.white70 : Colors.black87)
                          : (isDark ? Colors.white38 : Colors.black38),
                      fontStyle: hasNote
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
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
