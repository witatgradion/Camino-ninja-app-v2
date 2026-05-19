import 'package:flutter/material.dart';

mixin AnimatedListMixin<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  late final AnimationController listAnimationController;

  void initListAnimation(
      {Duration duration = const Duration(milliseconds: 800),}) {
    listAnimationController = AnimationController(
      vsync: this,
      duration: duration,
    );
  }

  void disposeListAnimation() {
    listAnimationController.dispose();
  }

  Widget buildAnimatedListItem({
    required Widget child,
    required int index,
    double delay = 0.1,
    double itemDuration = 0.4,
  }) {
    return _AnimatedListItem(
      animation: listAnimationController,
      index: index,
      delay: delay,
      itemDuration: itemDuration,
      child: child,
    );
  }

  Widget buildFadeAnimation({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _AnimatedListItem extends StatefulWidget {
  const _AnimatedListItem({
    required this.animation,
    required this.index,
    required this.delay,
    required this.itemDuration,
    required this.child,
  });

  final Animation<double> animation;
  final int index;
  final double delay;
  final double itemDuration;
  final Widget child;

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem> {
  late final CurvedAnimation _curvedAnimation;
  late final Animation<Offset> _slideAnimation;
  static final _slideTween = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  );

  @override
  void initState() {
    super.initState();
    final start = (widget.delay * widget.index).clamp(0.0, 1.0);
    final end = (start + widget.itemDuration).clamp(0.0, 1.0);
    final interval = Interval(start, end, curve: Curves.easeOutCubic);

    _curvedAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: interval,
    );
    _slideAnimation = _slideTween.animate(_curvedAnimation);
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curvedAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
