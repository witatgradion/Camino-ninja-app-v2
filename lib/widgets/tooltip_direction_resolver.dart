import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

TooltipDirection? resolveTooltipDirection({
  required BuildContext context,
  required GlobalKey anchorKey,
  required double tooltipWidth,
  required double arrowLength,
  required double arrowTipDistance,
  required double tooltipContentHeight,
}) {
  final renderBox = anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) {
    return null;
  }

  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;
  final screenSize = MediaQuery.of(context).size;

  final distanceToRight = screenSize.width - (position.dx + size.width);
  final distanceToBottom = screenSize.height - (position.dy + size.height);

  final tooltipTotalWidth = tooltipWidth + arrowTipDistance + arrowLength;

  if (distanceToRight > tooltipTotalWidth) {
    return TooltipDirection.right;
  }

  if (distanceToBottom > tooltipContentHeight) {
    return TooltipDirection.down;
  }

  return TooltipDirection.up;
}
