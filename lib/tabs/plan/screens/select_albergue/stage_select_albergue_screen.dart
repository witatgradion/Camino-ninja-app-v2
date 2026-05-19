import 'dart:async';

import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_albergue/manual_add_stay_dialog.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_albergue/my_stay_section.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_albergue/selected_albergue_section.dart';
import 'package:camino_ninja_flutter/tabs/plan/screens/select_albergue/stage_albergue_widget.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_nav_scope.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/albergue_details_screen.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/city_information_card.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/city_details/cubit/city_details_cubit.dart';
import 'package:camino_ninja_flutter/utils/animated_mixin.dart';
import 'package:camino_ninja_flutter/utils/router_locations.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/custom_outline_button.dart';
import 'package:camino_ninja_flutter/widgets/emply_state_widget.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/widgets/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:storage/storage.dart';

class StageSelectAlbergueScreenArguments {
  const StageSelectAlbergueScreenArguments({
    required this.title,
    required this.city,
    required this.route,
    this.selectedAlbergue,
    this.compareDate,
    this.customNotes,
    this.onSelectedAlbergueChanged,
  });
  final String title;
  final CityEntity city;
  final RouteEntity route;
  final AlbergueEntity? selectedAlbergue;
  final DateTime? compareDate;
  final String? customNotes;
  final void Function(AlbergueEntity?, String?)? onSelectedAlbergueChanged;
}

class StageSelectAlbergueScreen extends StatefulWidget {
  const StageSelectAlbergueScreen({required this.arguments, super.key});
  final StageSelectAlbergueScreenArguments arguments;

  @override
  State<StageSelectAlbergueScreen> createState() =>
      _StageSelectAlbergueScreenState();
}

class _StageSelectAlbergueScreenState extends State<StageSelectAlbergueScreen>
    with
        TickerProviderStateMixin,
        AnimatedListMixin<StageSelectAlbergueScreen> {
  // Flag to enable/disable animations
  static const bool _enableAnimations = false;

  late CityDetailsCubit _cubit;
  late AnimationController _fadeAnimationController;
  late AnimationController _emptyAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _infoCardAnimation;
  late Animation<double> _emptyAnimation;
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  StreamSubscription<int?>? _selectedAlbergueSubscription;
  String? _customNotes;
  AlbergueEntity? _selectedAlbergue;

  @override
  void initState() {
    super.initState();
    _customNotes = widget.arguments.customNotes;
    _selectedAlbergue = widget.arguments.selectedAlbergue;
    _cubit = CityDetailsCubit(
      cityId: widget.arguments.city.id,
      routeId: widget.arguments.route.id,
      selectedAlbergue: widget.arguments.selectedAlbergue,
    )..init();
    _selectedAlbergueSubscription = _cubit.selectedIndexStream.listen((index) {
      if (index != null && index >= 0) {
        const delay =
            _enableAnimations ? Duration(milliseconds: 800) : Duration.zero;
        Future.delayed(delay, () {
          if (mounted) {
            final positions = _itemPositionsListener.itemPositions.value;
            final alreadyVisible = positions.any(
              (p) =>
                  p.index == index &&
                  p.itemLeadingEdge >= 0 &&
                  p.itemTrailingEdge <= 1,
            );
            if (alreadyVisible) return;
            _itemScrollController.scrollTo(
              index: index,
              duration: Durations.medium2,
            );
          }
        });
      }
    });
    _setupAnimations();
  }

  void _setupAnimations() {
    const duration =
        _enableAnimations ? Duration(milliseconds: 800) : Duration.zero;
    const emptyDuration =
        _enableAnimations ? Duration(milliseconds: 400) : Duration.zero;

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: duration,
    );
    _emptyAnimationController = AnimationController(
      vsync: this,
      duration: emptyDuration,
    );
    _searchAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: _enableAnimations
          ? const Interval(0.3, 0.6, curve: Curves.easeOutCubic)
          : const Interval(0, 1),
    );
    _buttonAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: _enableAnimations
          ? const Interval(0.4, 0.8, curve: Curves.easeOutCubic)
          : const Interval(0, 1),
    );
    _infoCardAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: _enableAnimations
          ? const Interval(0.6, 1, curve: Curves.easeOutCubic)
          : const Interval(0, 1),
    );
    _emptyAnimation = CurvedAnimation(
      parent: _emptyAnimationController,
      curve: _enableAnimations
          ? const Interval(0.3, 1, curve: Curves.easeOutCubic)
          : const Interval(0, 1),
    );
    initListAnimation(
      duration:
          _enableAnimations ? const Duration(milliseconds: 800) : Duration.zero,
    );

    // If animations disabled, immediately complete them
    if (!_enableAnimations) {
      _fadeAnimationController.value = 1.0;
      _emptyAnimationController.value = 1.0;
      listAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _fadeAnimationController.dispose();
    _emptyAnimationController.dispose();
    _selectedAlbergueSubscription?.cancel();
    disposeListAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar(
        title: widget.arguments.title,
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => _cubit,
          child: BlocListener<CityDetailsCubit, CityDetailsState>(
            listenWhen: (previous, current) =>
                previous.status != current.status ||
                previous.filteringStatus != current.filteringStatus,
            listener: (context, state) {
              if (state.status == CityDetailsStatus.loaded) {
                if (_enableAnimations) {
                  _fadeAnimationController.forward();
                } else {
                  _fadeAnimationController.value = 1.0;
                }
              }
              if (state.filteringStatus == CityDetailsFilteringStatus.success &&
                  state.filteredAlbergues.isEmpty) {
                if (_enableAnimations) {
                  _emptyAnimationController
                    ..reset()
                    ..forward();
                } else {
                  _emptyAnimationController.value = 1.0;
                }
              } else {
                if (_enableAnimations) {
                  listAnimationController
                    ..reset()
                    ..forward();
                } else {
                  listAnimationController.value = 1.0;
                }
              }
            },
            child: BlocBuilder<CityDetailsCubit, CityDetailsState>(
              builder: (context, state) {
                if (state.status == CityDetailsStatus.loading) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                }

                return _buildBody(state);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(CityDetailsState state) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (_, appState) {
        return Column(
          children: [
            buildFadeAnimation(
              animation: _searchAnimation,
              child: SearchField(
                enableDebouncer: true,
                onChanged: (value) {
                  _cubit.searchAlbergues(value);
                },
              ),
            ),
            buildFadeAnimation(
              animation: _buttonAnimation,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStayInformationSection(),
              ),
            ),
            const SizedBox(height: 16),
            buildFadeAnimation(
              animation: _infoCardAnimation,
              child: CityInformationCard(
                city: state.city,
                services: state.services,
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.filteredAlbergues.isEmpty) {
                    return buildFadeAnimation(
                      animation: _emptyAnimation,
                      child: const EmplyStateWidget(),
                    );
                  }

                  return ScrollablePositionedList.builder(
                    itemScrollController: _itemScrollController,
                    itemPositionsListener: _itemPositionsListener,
                    padding: const EdgeInsets.only(
                      bottom: 24,
                    ),
                    itemCount: state.filteredAlbergues.length,
                    itemBuilder: (context, index) {
                      final albergue = state.filteredAlbergues[index];
                      return buildAnimatedListItem(
                        index: index,
                        delay: _enableAnimations ? index * 0.1 : 0.0,
                        itemDuration: _enableAnimations ? 0.6 : 1.0,
                        child: StageAlbergueWidget(
                          compareDate: widget.arguments.compareDate,
                          albergue: state.filteredAlbergues[index],
                          routeId: widget.arguments.route.id,
                          isBookmarked:
                              _cubit.isAlbergueBookmarked(albergue.id),
                          isExpanded: _cubit.isAlbergueExpanded(albergue.id),
                          onViewDetailTap: () {
                            context.push(
                              RouterLocations.stageAlbergueDetails(
                                albergueId: albergue.id,
                                routeId: widget.arguments.route.id,
                                cityId: widget.arguments.city.id,
                              ),
                              extra: AlbergueDetailsScreenArguments(
                                albergueId: albergue.id,
                                cityId: widget.arguments.city.id,
                                routeId: widget.arguments.route.id,
                                navScope: AlbergueDetailsNavScope.planTab,
                                isStagePlannerFlow: true,
                                compareDate: widget.arguments.compareDate,
                                isSelected:
                                    _selectedAlbergue?.id == albergue.id,
                                onSelectedAlbergueChanged: () {
                                  _toggleSelectedAlbergue(
                                    albergue,
                                  );
                                },
                              ),
                            );
                          },
                          onStayHereTap: () {
                            _toggleSelectedAlbergue(albergue);
                          },
                          onTap: () {
                            _cubit.setExpandedAlbergue(albergue.id);
                          },
                          isSelected: _selectedAlbergue?.id == albergue.id,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleSelectedAlbergue(AlbergueEntity albergue,
      {bool forcePop = false}) {
    if (_selectedAlbergue?.id == albergue.id) {
      _selectedAlbergue = null;
    } else {
      _selectedAlbergue = albergue;
    }
    _customNotes = null;
    widget.arguments.onSelectedAlbergueChanged
        ?.call(_selectedAlbergue, _customNotes);
    if (_selectedAlbergue != null || forcePop) {
      Navigator.pop(context);
      return;
    }
    setState(() {});
  }

  Future<void> _showManualAddStayDialog() async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => ManualAddStayDialog(
        initialValue: _customNotes,
      ),
    );
    if (result != null && mounted) {
      _customNotes = result;
      _selectedAlbergue = null;
      widget.arguments.onSelectedAlbergueChanged
          ?.call(_selectedAlbergue, _customNotes);
      Navigator.pop(context);
    }
  }

  Widget? _buildStayInformationSection() {
    return AnimatedSwitcher(
      duration: Durations.medium2,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: _buildStaySelectionChild(),
    );
  }

  Widget _buildStaySelectionChild() {
    if (_customNotes != null && _customNotes!.isNotEmpty) {
      return MyStaySection(
        notes: _customNotes!,
        onEditTap: _showManualAddStayDialog,
        onRemoveTap: () {
          _selectedAlbergue = null;
          _customNotes = null;
          widget.arguments.onSelectedAlbergueChanged
              ?.call(_selectedAlbergue, _customNotes);
          setState(() {});
        },
      );
    }
    if (_selectedAlbergue != null) {
      return SelectedAlbergueSection(
        albergue: _selectedAlbergue!,
        onRemoveTap: () {
          _selectedAlbergue = null;
          _customNotes = null;
          widget.arguments.onSelectedAlbergueChanged
              ?.call(_selectedAlbergue, _customNotes);
          setState(() {});
        },
      );
    }
    return CustomOutlineButton(
      key: const ValueKey('manual_add_stay_button'),
      text: AppLocalizations.of(context).manuallyAddStay,
      prefixIcon: (color) => SvgPicture.asset(
        'assets/ic_plus.svg',
        color: color,
        width: 18,
      ),
      onTap: _showManualAddStayDialog,
    );
  }
}
