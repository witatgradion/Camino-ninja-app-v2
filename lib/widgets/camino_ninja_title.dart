import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CaminoNinjaAppBar extends StatelessWidget implements PreferredSizeWidget {

  const CaminoNinjaAppBar({
    super.key,
    this.showLeading = true,
    this.automaticallyImplyLeading = true,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleTextStyle,
    this.titleWidget,
    this.centerTitle = true,
    this.leadingWidth,
    this.useDynamicHeight = false,
    this.maxTitleLines,
    this.dynamicHeightPadding = const EdgeInsets.symmetric(vertical: 12),
    this.onBackTap,
  });
  factory CaminoNinjaAppBar.main({List<Widget>? actions}) {
    return CaminoNinjaAppBar(
      leadingWidth: 46 + 24,
      automaticallyImplyLeading: false,
      leading: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Image.asset(
            'assets/camino_logo_no_padding.png',
            width: 46,
          ),
        ],
      ),
      titleWidget: Builder(
        builder: (context) {
          return Image.asset(
            context.isDarkMode
                ? 'assets/bg_camino_ninja_banner_dark.png'
                : 'assets/bg_camino_ninja_banner_light.png',
            height: 16,
          );
        },
      ),
      centerTitle: false,
      actions: actions,
    );
  }

  final bool showLeading;
  final bool automaticallyImplyLeading;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final TextStyle? titleTextStyle;
  final Widget? titleWidget;
  final bool centerTitle;
  final double? leadingWidth;
  final bool useDynamicHeight;
  final int? maxTitleLines;
  final EdgeInsets dynamicHeightPadding;
  final VoidCallback? onBackTap;

  static const double height = 56;
  static const double minDynamicHeight = 72;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (useDynamicHeight) {
      return _buildDynamicAppBar(context, theme);
    }

    return AppBar(
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      foregroundColor: foregroundColor ?? Colors.transparent,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: height,
      leadingWidth: leadingWidth,
      leading: _buildLeading(context),
      title: _buildStaticTitle(context, theme),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  Widget _buildDynamicAppBar(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).colorScheme.surface,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation,
                  offset: Offset(0, elevation / 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: IntrinsicHeight(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: minDynamicHeight,
            ),
            padding: dynamicHeightPadding,
            child: Row(
              children: [
                if (showLeading) ...[
                  SizedBox(
                    width: leadingWidth ?? 56,
                    child: _buildLeading(context),
                  ),
                ],
                Expanded(
                  child: Align(
                    alignment: centerTitle
                        ? Alignment.center
                        : AlignmentDirectional.centerStart,
                    child: _buildDynamicTitle(context, theme),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!showLeading) return null;

    final leadingWidget = leading ??
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.isDarkMode
                  ? AppColors.primary80
                  : AppColors.primary40,
            ),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/ic_chervon_left.svg',
            width: 24,
            color:
                context.isDarkMode ? AppColors.primary80 : AppColors.primary40,
          ),
        );

    if (!automaticallyImplyLeading) {
      return Center(child: leadingWidget);
    }

    return Center(
      child: InkWell(
        onTap: onBackTap ?? () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(100),
        child: leadingWidget,
      ),
    );
  }

  Widget? _buildDynamicTitle(BuildContext context, ThemeData theme) {
    if (titleWidget != null) {
      return titleWidget!;
    }

    if (title != null) {
      return Text(
        title!,
        style: titleTextStyle ??
            theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
        maxLines: maxTitleLines,
        overflow: maxTitleLines != null ? TextOverflow.ellipsis : null,
      );
    }

    return null;
  }

  Widget? _buildStaticTitle(BuildContext context, ThemeData theme) {
    if (titleWidget != null) {
      return titleWidget!;
    }

    if (title != null) {
      return Text(
        title!,
        style: titleTextStyle ??
            theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      );
    }

    return null;
  }

  @override
  Size get preferredSize {
    if (useDynamicHeight) {
      // Return a large enough size to accommodate any content
      // The IntrinsicHeight will size it correctly
      return const Size.fromHeight(200);
    }
    return const Size.fromHeight(height);
  }
}

class StepTitle extends StatelessWidget {
  const StepTitle({required this.step, required this.title, super.key});
  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppColors.tertiary90,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$step',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 32),
      ],
    );
  }
}
