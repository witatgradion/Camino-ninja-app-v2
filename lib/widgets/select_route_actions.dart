import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum SelectRouteMode {
  list,
  map;

  String get icon {
    return switch (this) {
      SelectRouteMode.list => 'assets/ic_list.svg',
      SelectRouteMode.map => 'assets/ic_map.svg',
    };
  }

  String reverseLabel(BuildContext context) {
    return switch (this) {
      SelectRouteMode.list => AppLocalizations.of(context).map,
      SelectRouteMode.map => AppLocalizations.of(context).list,
    };
  }

  SelectRouteMode get toggled =>
      this == SelectRouteMode.list ? SelectRouteMode.map : SelectRouteMode.list;
}

class SelectRouteModeFab extends StatefulWidget {
  const SelectRouteModeFab({
    required this.currentMode,
    required this.onToggle,
    super.key,
  });

  final SelectRouteMode currentMode;
  final VoidCallback onToggle;

  @override
  State<SelectRouteModeFab> createState() => _SelectRouteModeFabState();
}

class _SelectRouteModeFabState extends State<SelectRouteModeFab>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1), weight: 20),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(SelectRouteModeFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMode != widget.currentMode) {
      if (widget.currentMode == SelectRouteMode.map) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final targetMode = widget.currentMode.toggled;

    return ScaleTransition(
      scale: _scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          RotationTransition(
            turns: _rotation,
            child: FloatingActionButton.small(
              onPressed: widget.onToggle,
              backgroundColor:
                  isDark ? AppColors.primary80 : AppColors.primary40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: SvgPicture.asset(
                  targetMode.icon,
                  key: ValueKey(targetMode),
                  width: 20,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.black : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.yellow300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.currentMode.reverseLabel(context),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
