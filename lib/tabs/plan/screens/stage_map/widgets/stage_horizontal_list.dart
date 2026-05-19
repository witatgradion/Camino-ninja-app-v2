import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/stage_map/cubit/stage_map_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repository/repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class StageHorizontalList extends StatefulWidget {
  const StageHorizontalList({
    required this.stages,
    this.selectedStage,
    this.isEmbedded = false,
    super.key,
  });
  final List<StageModel> stages;
  final StageModel? selectedStage;
  final bool isEmbedded;

  @override
  State<StageHorizontalList> createState() => _StageHorizontalListState();
}

class _StageHorizontalListState extends State<StageHorizontalList> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  bool _showLeftShadow = false;
  bool _showRightShadow = false;
  bool _hasInitialScrolled = false;

  @override
  void initState() {
    super.initState();
    _itemPositionsListener.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void didUpdateWidget(covariant StageHorizontalList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedStage?.id != widget.selectedStage?.id) {
      _scrollToSelectedStage();
    }
  }

  void _onPositionsChanged() {
    _updateShadows();

    // Handle initial scroll once positions are available
    if (!_hasInitialScrolled) {
      _hasInitialScrolled = true;
      // Defer to next frame to ensure all positions are populated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedStage();
      });
    }
  }

  bool _allItemsFitInViewport() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return false;

    final minIndex =
        positions.map((p) => p.index).reduce((a, b) => a < b ? a : b);
    final maxIndex =
        positions.map((p) => p.index).reduce((a, b) => a > b ? a : b);

    // All items fit if first (0) and last (length-1) are both visible
    return minIndex == 0 && maxIndex >= widget.stages.length - 1;
  }

  void _scrollToSelectedStage() {
    if (widget.selectedStage == null) return;
    if (!_itemScrollController.isAttached) return;

    // If all items fit in viewport, no scrolling needed
    if (_allItemsFitInViewport()) return;

    final index = widget.stages.indexWhere(
      (stage) => stage.id == widget.selectedStage!.id,
    );
    if (index == -1) return;

    final positions = _itemPositionsListener.itemPositions.value;
    final alreadyVisible = positions.any(
      (p) =>
          p.index == index && p.itemLeadingEdge >= 0 && p.itemTrailingEdge <= 1,
    );
    if (alreadyVisible) return;

    _itemScrollController.scrollTo(
      index: index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  void _updateShadows() {
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final minIndex = positions
        .map((position) => position.index)
        .reduce((a, b) => a < b ? a : b);
    final maxIndex = positions
        .map((position) => position.index)
        .reduce((a, b) => a > b ? a : b);

    final showLeft = minIndex > 0;
    final showRight = maxIndex < (widget.stages.length - 1);

    if (showLeft != _showLeftShadow || showRight != _showRightShadow) {
      setState(() {
        _showLeftShadow = showLeft;
        _showRightShadow = showRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = context.isDarkMode ? Colors.black : Colors.white;
    final stages = widget.stages;
    final selectedStage = widget.selectedStage;

    return Container(
      color: widget.isEmbedded
          ? Colors.transparent
          : Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (!widget.isEmbedded) ...[
            const SizedBox(width: 16),
            Text(
              AppLocalizations.of(context).stagePlural,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  height: 45,
                  child: ScrollablePositionedList.separated(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: widget.isEmbedded ? 8 : 8,
                    ),
                    itemCount: stages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = selectedStage?.id == stages[index].id;
                      final isSelectedColor = context.isDarkMode
                          ? AppColors.primary80
                          : AppColors.primary40;
                      final color =
                          isSelected ? isSelectedColor : AppColors.gray500;
                      final isTodayStage =
                          stages[index].date?.isSameDay(DateTime.now()) ??
                              false;

                      final textWidget = Text(
                        '${index + 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? (context.isDarkMode
                                      ? Colors.black
                                      : Colors.white)
                                  : color,
                              fontWeight: FontWeight.bold,
                            ),
                      );

                      return Material(
                        color: Colors.transparent,
                        child: Ink(
                          width: isTodayStage ? null : 45,
                          height: 45,
                          padding: isTodayStage
                              ? const EdgeInsets.symmetric(horizontal: 16)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                            shape: isTodayStage
                                ? BoxShape.rectangle
                                : BoxShape.circle,
                            borderRadius: isTodayStage
                                ? BorderRadius.circular(100)
                                : null,
                            color: isSelected
                                ? (context.isDarkMode
                                    ? AppColors.primary80
                                    : AppColors.primary40)
                                : widget.isEmbedded
                                    ? Colors.white
                                    : Colors.transparent,
                            border: Border.all(color: color, width: 2),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              context
                                  .read<StageMapCubit>()
                                  .onSelectStage(stages[index]);
                            },
                            child: isTodayStage
                                ? Row(
                                    children: [
                                      textWidget,
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.yellow300
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context).today,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: isSelected
                                                    ? Colors.black
                                                    : (context.isDarkMode
                                                        ? AppColors.yellow300
                                                        : AppColors.yellow400),
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(child: textWidget),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!widget.isEmbedded) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _showLeftShadow ? 1.0 : 0.0,
                        child: Container(
                          width: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                shadowColor,
                                shadowColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _showRightShadow ? 1.0 : 0.0,
                        child: Container(
                          width: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                shadowColor,
                                shadowColor.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
