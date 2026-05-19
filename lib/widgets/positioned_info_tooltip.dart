import 'package:camino_ninja_flutter/widgets/tooltip_direction_resolver.dart';
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class PositionedInfoTooltip extends StatefulWidget {
  const PositionedInfoTooltip({
    required this.tooltipWidth,
    required this.tooltipContentHeight,
    required this.content,
    required this.icon,
    super.key,
    this.arrowLength = 8,
    this.arrowTipDistance = 16,
  });

  final double tooltipWidth;
  final double tooltipContentHeight;
  final double arrowLength;
  final double arrowTipDistance;
  final Widget content;
  final Widget icon;

  @override
  State<PositionedInfoTooltip> createState() => _PositionedInfoTooltipState();
}

class _PositionedInfoTooltipState extends State<PositionedInfoTooltip> {
  final _controller = SuperTooltipController();
  final _iconKey = GlobalKey();
  var _tooltipDirection = TooltipDirection.right;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showTooltip() {
    final tooltipDirection = resolveTooltipDirection(
      context: context,
      anchorKey: _iconKey,
      tooltipWidth: widget.tooltipWidth,
      arrowLength: widget.arrowLength,
      arrowTipDistance: widget.arrowTipDistance,
      tooltipContentHeight: widget.tooltipContentHeight,
    );
    if (tooltipDirection == null) {
      return;
    }

    _tooltipDirection = tooltipDirection;
    setState(() {});
    Future.delayed(
      const Duration(milliseconds: 250),
      _controller.showTooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tooltipColor =
        isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB);

    return SuperTooltip(
      popupDirection: _tooltipDirection,
      showBarrier: true,
      barrierColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.15),
      shadowOffset: const Offset(0, 4),
      shadowBlurRadius: 10,
      shadowSpreadRadius: 0,
      backgroundColor: tooltipColor,
      borderColor: Colors.transparent,
      arrowTipRadius: 4,
      arrowLength: widget.arrowLength,
      borderRadius: 4,
      arrowTipDistance: widget.arrowTipDistance,
      minimumOutsideMargin: 0,
      hideTooltipOnTap: true,
      controller: _controller,
      bubbleDimensions: EdgeInsets.zero,
      overlayDimensions: EdgeInsets.zero,
      content: widget.content,
      child: GestureDetector(
        onTap: _showTooltip,
        child: KeyedSubtree(
          key: _iconKey,
          child: widget.icon,
        ),
      ),
    );
  }
}
