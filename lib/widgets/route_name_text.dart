import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RouteNameText extends StatelessWidget {
  const RouteNameText({
    required this.routeSubName,
    this.textStyle,
    this.routeName,
    this.maxLines,
    super.key,
  });
  final String? routeName;
  final String routeSubName;
  final TextStyle? textStyle;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final routeNameAvailable =
        routeName != null && routeName!.isNotEmpty;

    if (routeNameAvailable && routeSubName.isNotEmpty) {
      return _buildColumnLayout(context);
    }

    if (routeNameAvailable) {
      return Text(
        routeName!,
        style: textStyle,
        maxLines: maxLines ?? 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return _buildSubNameRichText(context, style: textStyle);
  }

  Widget _buildColumnLayout(BuildContext context) {
    final isDark = context.isDarkMode;
    final subNameStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.primary80
                  : AppColors.primary40,
            );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          routeName!,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        _buildSubNameRichText(context, style: subNameStyle),
      ],
    );
  }

  Widget _buildSubNameRichText(
    BuildContext context, {
    TextStyle? style,
  }) {
    final regex = RegExp('(-->|->|-)');
    final parts = <InlineSpan>[];

    final matches = regex.allMatches(routeSubName).toList();
    var lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        parts.add(
          TextSpan(
            text: routeSubName
                .substring(lastIndex, match.start)
                .trim(),
            style: style,
          ),
        );
      }

      parts.add(
        WidgetSpan(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: SvgPicture.asset(
              'assets/ic_arrow_left_outline.svg',
              width: 15,
              color: style?.color,
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < routeSubName.length) {
      parts.add(
        TextSpan(
          text: routeSubName.substring(lastIndex).trim(),
          style: style,
        ),
      );
    }

    return RichText(
      maxLines: maxLines ?? 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(children: parts),
    );
  }
}
