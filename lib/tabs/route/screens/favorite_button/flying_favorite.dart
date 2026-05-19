import 'dart:ui';

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FlyingFavoriteWidget extends StatefulWidget {
  const FlyingFavoriteWidget({
    required this.startPosition,
    required this.endPosition,
    required this.onComplete,
    super.key,
  });
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback onComplete;

  @override
  State<FlyingFavoriteWidget> createState() => _FlyingHeartState();
}

class _FlyingHeartState extends State<FlyingFavoriteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ),);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.4), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.4), weight: 85),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1, curve: Curves.easeOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx - 24,
          top: _positionAnimation.value.dy - 24,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SvgWithFlutterShadow(
                    src: 'assets/ic_bookmark_filled.svg',
                    color:
                        context.isDarkMode ? Colors.white : AppColors.primary40,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SvgWithFlutterShadow extends StatelessWidget {
  const SvgWithFlutterShadow({
    required this.color, required this.size, required this.src, super.key,
  });
  final Color color;
  final double size;
  final String src;

  @override
  Widget build(BuildContext context) {
    // --- Configuration for the shadow ---
    const blurRadius = 10.0;
    const offset = Offset.zero;

    return Stack(
      children: [
        // 1. The Shadow Layer (bottom)
        Transform.translate(
          offset: offset,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: blurRadius,
              sigmaY: blurRadius,
            ),
            child: SvgPicture.asset(
              src,
              width: size,
              height: size,
              color: color.withOpacity(0.3),
            ),
          ),
        ),

        // 2. The Original Icon Layer (top)
        SvgPicture.asset(
          src,
          width: size,
          height: size,
          color: color,
        ),
      ],
    );
  }
}
