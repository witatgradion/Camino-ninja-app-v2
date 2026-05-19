import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingProgressWidget extends StatelessWidget {
  const LoadingProgressWidget({
    required this.loadingProgress,
    required this.loadingTotal,
    this.size,
    super.key,
  });
  final int loadingProgress;
  final int loadingTotal;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size ?? 90,
            height: size ?? 90,
            child: Lottie.asset('assets/ninja_loading.json'),
          ),
          SizedBox(
            width: size != null ? size! - 10 : 80,
            height: size != null ? size! - 10 : 80,
            child: CircularProgressIndicator(
              value: loadingTotal > 0 ? loadingProgress / loadingTotal : null,
              backgroundColor: const Color(0x38B5B5B5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFFD231),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    this.size,
    super.key,
  });

  final double? size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size ?? 90,
          height: size ?? 90,
          child: Lottie.asset('assets/ninja_loading.json'),
        ),
        SizedBox(
          width: calculateCircularProgressIndicatorSize(size ?? 90),
          height: calculateCircularProgressIndicatorSize(size ?? 90),
          child: const CircularProgressIndicator(
            backgroundColor: Color(0x38B5B5B5),
            valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFFFFD231),
            ),
          ),
        ),
      ],
    );
  }

  double calculateCircularProgressIndicatorSize(double d) {
    return (0.8 * d) + 8;
  }
}

class LoadingFullScreen extends StatelessWidget {
  const LoadingFullScreen({
    this.backgroundColor,
    this.loadingSize,
    super.key,
  });

  final Color? backgroundColor;
  final double? loadingSize;

  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {Color? backgroundColor}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => LoadingFullScreen(backgroundColor: backgroundColor),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static bool get isShowing => _overlayEntry != null;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
        child: const Center(
          child: LoadingWidget(),
        ),
      ),
    );
  }
}
