
import 'package:auto_size_text/auto_size_text.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_date/cubit/stage_select_date_cubit.dart';
import 'package:camino_ninja_flutter/tabs/plan/widgets/stage_card.dart';
import 'package:camino_ninja_flutter/utils/animated_mixin.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:repository/repository.dart';
import 'package:table_calendar/table_calendar.dart';

class StageSelectDateScreenArguments {
  const StageSelectDateScreenArguments({this.stage, this.stagePlanId});
  final StageModel? stage;
  final int? stagePlanId;
}

class StageSelectDateScreen extends StatefulWidget {
  const StageSelectDateScreen({
    this.arguments,
    super.key,
  });
  final StageSelectDateScreenArguments? arguments;

  @override
  State<StageSelectDateScreen> createState() => _StageSelectDateScreenState();
}

class _StageSelectDateScreenState extends State<StageSelectDateScreen>
    with TickerProviderStateMixin, AnimatedListMixin<StageSelectDateScreen> {
  final _cubit = StageSelectDateCubit();
  DateTime _focusedDay = DateTime.now();

  late AnimationController _calendarAnimationController;
  late AnimationController _warningBannerAnimationController;
  late Animation<double> _calendarAnimation;
  late Animation<double> _warningBannerAnimation;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.arguments?.stage?.date ?? DateTime.now();
    _cubit.init(widget.arguments?.stage, widget.arguments?.stagePlanId);
    _calendarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _warningBannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _calendarAnimation = CurvedAnimation(
      parent: _calendarAnimationController,
      curve: Curves.easeOutCubic,
    );
    _warningBannerAnimation = CurvedAnimation(
      parent: _warningBannerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _warningBannerAnimationController.forward();
    _calendarAnimationController.forward();
  }

  @override
  void dispose() {
    _calendarAnimationController.dispose();
    _warningBannerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.1),
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocListener<StageSelectDateCubit, StageSelectDateState>(
          listener: (context, state) {
            final shouldShowWarningBanner =
                state.hasConflictingStage || state.isPastDate;
            if (shouldShowWarningBanner &&
                !_warningBannerAnimationController.isCompleted) {
              _warningBannerAnimationController.forward();
              return;
            }
            if (!shouldShowWarningBanner &&
                _warningBannerAnimationController.isCompleted) {
              _warningBannerAnimationController.reverse();
              return;
            }
          },
          child: BlocBuilder<StageSelectDateCubit, StageSelectDateState>(
            builder: (context, state) {
              return SizedBox.expand(
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          color:
                              (context.isDarkMode ? Colors.black : Colors.white)
                                  .withOpacity(0.5),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Header with close button
                              // Warning banner (only show if selected day has plan)
                              if (state.hasConflictingStage ||
                                  state.isPastDate) ...[
                                _buildWarningBanner(state),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        // Calendar
                        _buildCalendar(state),
                        const SizedBox(height: 8),

                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              if (state.hasConflictingStage) ...[
                                _buildPlanDetails(state),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    if (state.loadDataStatus ==
                        SelectDateLoadDataStatus.loading) ...[
                      const Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ColoredBox(
                          color: AppColors.barrierColor,
                          child: Center(child: LoadingWidget()),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner(StageSelectDateState state) {
    final text = state.conflictingStage != null
        ? '${AppLocalizations.of(context).schedulingConflict} :('
        : AppLocalizations.of(context).stageScheduledPastDate;
    return buildFadeAnimation(
      animation: _warningBannerAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.yellow300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/ic_warning.svg',
              width: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AutoSizeText(
                text,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.black,
                    ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(StageSelectDateState state) {
    return buildFadeAnimation(
      animation: _calendarAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? AppColors.gray800 : Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).selectDate,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    //  'Tue, Oct 8',
                    state.date.toHumanReadableDateWithDayOfWeek(),
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            Container(height: 0.5, color: AppColors.neutral80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TableCalendar<dynamic>(
                firstDay: DateTime.utc(1900),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(state.date, day),
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekHeight: 48,
                rowHeight: 48,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    border: Border.all(
                      color: context.isDarkMode
                          ? AppColors.primary80
                          : AppColors.primary40,
                    ),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle:
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: context.isDarkMode
                                    ? AppColors.primary80
                                    : AppColors.primary40,
                                fontWeight: FontWeight.w500,
                              ) ??
                          const TextStyle(),
                  selectedDecoration: BoxDecoration(
                    color: context.isDarkMode
                        ? AppColors.primary80
                        : AppColors.primary40,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle:
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: context.isDarkMode
                                    ? Colors.black
                                    : Colors.white,
                                fontWeight: FontWeight.w500,
                              ) ??
                          const TextStyle(),
                  defaultTextStyle:
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ) ??
                          const TextStyle(),
                  weekendTextStyle:
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ) ??
                          const TextStyle(),
                  disabledTextStyle:
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: context.isDarkMode
                                    ? AppColors.gray500
                                    : AppColors.gray500,
                                fontWeight: FontWeight.w500,
                              ) ??
                          const TextStyle(),
                  outsideDaysVisible: false,
                  cellMargin: const EdgeInsets.all(2),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) {
                    return date.getFirstLetterOfWeekday();
                  },
                  weekdayStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ) ??
                      const TextStyle(),
                  weekendStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ) ??
                      const TextStyle(),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ) ??
                          const TextStyle(),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    size: 24,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                    size: 24,
                  ),
                  headerPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _cubit.checkConflictingStage(selectedDay);
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: context.isDarkMode
                                ? AppColors.primary80
                                : AppColors.primary40,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Opacity(
                    opacity: state.hasConflictingStage ? 0.5 : 1,
                    child: TextButton(
                      onPressed: () {
                        if (state.hasConflictingStage) {
                          return;
                        }
                        Navigator.pop(context, state.date);
                      },
                      child: Text(
                        AppLocalizations.of(context).ok,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: context.isDarkMode
                                  ? AppColors.primary80
                                  : AppColors.primary40,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
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

  Widget _buildPlanDetails(StageSelectDateState state) {
    if (state.conflictingStage == null) return const SizedBox.shrink();
    return buildFadeAnimation(
      animation: _warningBannerAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StageCard(
          showTodayBadge: false,
          index: state.conflictingStageIndex ?? 0,
          backgroundColor: AppColors.yellow300,
          stageColor: AppColors.yellow300,
          firstLineColor: Colors.black,
          secondLineColor: Colors.black,
          showEditButton: false,
          stage: state.conflictingStage!,
        ),
      ),
    );
  }
}
