import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SequentialLottie extends StatefulWidget {
  const SequentialLottie({
    required this.firstLottie,
    required this.secondLottie,
    super.key,
    this.width,
    this.height,
    this.fit,
  });
  final String firstLottie;
  final String secondLottie;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  State<SequentialLottie> createState() => _SequentialLottieState();
}

class _SequentialLottieState extends State<SequentialLottie>
    with TickerProviderStateMixin {
  late final AnimationController _firstController;
  bool _showFirstLottie = true;

  @override
  void initState() {
    super.initState();
    _firstController = AnimationController(vsync: this);

    // Add a listener to the controller to know when the first animation completes.
    _firstController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // When completed, update the state to show the second Lottie.
        // Using setState will trigger a rebuild of the widget.
        setState(() {
          _showFirstLottie = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // It's crucial to dispose of the controller to avoid memory leaks.
    _firstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We keep *both* Lotties in the tree and just toggle their visibility.
    // This way the second Lottie is already loaded by the time we switch,
    // avoiding a blank frame / flicker during the transition.
    return Stack(
      alignment: Alignment.center,
      children: [
        // First (non‑looping) Lottie – fades out after it completes.
        Opacity(
          opacity: _showFirstLottie ? 1 : 0,
          child: Lottie.asset(
            widget.firstLottie,
            controller: _firstController,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            onLoaded: (composition) {
              _firstController
                ..duration = composition.duration
                ..forward(); // Plays the animation once.
            },
          ),
        ),
        // Second (looping) Lottie – is preloaded underneath and revealed
        // once the first animation is done, so there’s no visual gap.
        Opacity(
          opacity: _showFirstLottie ? 0 : 1,
          child: Lottie.asset(
            widget.secondLottie,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            repeat: true,
          ),
        ),
      ],
    );
  }
}
