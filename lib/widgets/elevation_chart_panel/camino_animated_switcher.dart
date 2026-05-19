import 'package:flutter/cupertino.dart';

typedef CaminoTransitionBuilder = Widget Function(Widget, Animation<double>);
typedef CaminoSwitcherLayoutBuilder = Widget Function(
  Widget? currentChild,
  List<Widget> previousChildren,
);

class CaminoAnimatedSwitcher extends StatelessWidget {
  const CaminoAnimatedSwitcher({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder,
    this.layoutBuilder,
    this.switchInCurve = Curves.easeInCubic,
    this.switchOutCurve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final Duration duration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final CaminoTransitionBuilder? transitionBuilder;
  final CaminoSwitcherLayoutBuilder? layoutBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder ??
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      layoutBuilder: layoutBuilder ?? AnimatedSwitcher.defaultLayoutBuilder,
      child: child,
    );
  }
}
