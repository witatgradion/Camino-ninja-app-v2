import 'dart:io';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/navigation_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    required this.currentIndex,
    required this.isDarkMode,
    required this.onTap,
    required this.shouldShowNewLabelOnPlanTab,
    super.key,
  });

  final int currentIndex;
  final bool isDarkMode;
  final ValueChanged<int> onTap;
  final bool shouldShowNewLabelOnPlanTab;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = NavigationBarHelper.getBottomSafeAreaPadding();
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -5),
            blurRadius: 15,
          ),
        ],
      ),
      child: Container(
        height: NavigationBarHelper.getTotalNavigationBarHeight(),
        padding: EdgeInsets.only(bottom: bottomPadding),
        color: isDarkMode ? const Color(0xFF333333) : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomNavItem(
              index: 0,
              iconPath: 'assets/ic_nav_route.svg',
              label: AppLocalizations.of(context).route,
              isSelected: currentIndex == 0,
              isDarkMode: isDarkMode,
              onTap: onTap,
            ),
            CustomNavItem(
              index: 1,
              iconPath: 'assets/ic_nav_map.svg',
              label: AppLocalizations.of(context).map,
              isSelected: currentIndex == 1,
              isDarkMode: isDarkMode,
              onTap: onTap,
            ),
            CustomNavItem(
              index: 2,
              iconPath: 'assets/ic_nav_stage_planner.svg',
              label: AppLocalizations.of(context).plan,
              isSelected: currentIndex == 2,
              isDarkMode: isDarkMode,
              onTap: onTap,
              shouldShowNewLabel: shouldShowNewLabelOnPlanTab,
            ),
            CustomNavItem(
              index: 3,
              iconPath: 'assets/ic_nav_more.svg',
              label: AppLocalizations.of(context).more,
              isSelected: currentIndex == 3,
              isDarkMode: isDarkMode,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNavItem extends StatefulWidget {
  const CustomNavItem({
    required this.index,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
    this.shouldShowNewLabel = false,
    super.key,
  });

  final int index;
  final String iconPath;
  final String label;
  final bool isSelected;
  final bool isDarkMode;
  final void Function(int) onTap;
  final bool shouldShowNewLabel;

  @override
  State<CustomNavItem> createState() => _CustomNavItemState();
}

class _CustomNavItemState extends State<CustomNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: () => widget.onTap(widget.index),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      splashColor: Colors.grey.withOpacity(0.2),
                      highlightColor: Colors.grey.withOpacity(0.1),
                      customBorder: const CircleBorder(),
                      onTap: () => widget.onTap(widget.index),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: Platform.isIOS ? 0 : 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                color: widget.isSelected
                                    ? (widget.isDarkMode
                                        ? AppColors.primary20
                                        : AppColors.primary40)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: SvgPicture.asset(
                                widget.iconPath,
                                color: widget.isSelected
                                    ? (widget.isDarkMode
                                        ? AppColors.primary80
                                        : Colors.white)
                                    : (widget.isDarkMode
                                        ? AppColors.gray400
                                        : AppColors.primary40),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: widget.isDarkMode
                                        ? (widget.isSelected
                                            ? AppColors.primary80
                                            : AppColors.gray400)
                                        : AppColors.primary40,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.shouldShowNewLabel)
          Positioned(
            right: 0,
            top: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.yellow300,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.24),
                    offset: const Offset(-8, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'New',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
