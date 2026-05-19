import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HowToNinjaScreen extends StatefulWidget {
  const HowToNinjaScreen({super.key});

  @override
  State<HowToNinjaScreen> createState() => _HowToNinjaScreenState();
}

class _HowToNinjaScreenState extends State<HowToNinjaScreen>
    with TickerProviderStateMixin {
  // --- STATE VARIABLES ---

  late final AnimationController _controller;

  // Updated list of all animation assets, including intro and outro.
  final List<String> _lottieAssets = [
    'assets/lottie/intro.json', // 0
    'assets/lottie/walk.json', // 1 (Idle State)
    'assets/lottie/eat.json', // 2
    'assets/lottie/sleep.json', // 3
    'assets/lottie/coffee.json', // 4
    'assets/lottie/happy.json', // 5
    'assets/lottie/ninja.json', // 6
    'assets/lottie/buen_camino.json', // 7
    'assets/lottie/outro.json', // 8
  ];

  // Updated list of labels for the buttons.
  List<String> _buttonLabels = [];

  // The index of the default "idle" animation (Walk).
  static const int _idleAnimationIndex = 1;

  // The index of the outro animation.
  static const int _outroAnimationIndex = 8;

  // The index of the currently selected animation. Starts with Intro (0).
  int _selectedIndex = 0;
  int? _pendingAnimationIndex;
  bool _isExiting = false;

  // --- LIFECYCLE METHODS ---

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller
      ..addStatusListener(_onAnimationStatusChanged)
      ..addListener(_updateUIForProgressBar);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buttonLabels = [
      'Intro',
      'Walk',
      'Eat',
      'Sleep',
      'Coffee',
      'Happy',
      'Ninja',
      'Buen Camino',
      'Outro',
    ];
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatusChanged);
    _controller.removeListener(_updateUIForProgressBar);
    _controller.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  void _updateUIForProgressBar() {
    setState(() {});
  }

  /// Handles button presses for animations 1 through 7.
  void _onButtonPressed(int index) {
    if (index == _selectedIndex || _isExiting) {
      return;
    }
    if (_controller.isAnimating) {
      setState(() => _pendingAnimationIndex = index);
    } else {
      setState(() {
        _selectedIndex = index;
        _pendingAnimationIndex = null;
      });
    }
  }

  /// Handles the press of the dedicated Exit button.
  void _onExitPressed() {
    if (_isExiting) return;

    setState(() => _isExiting = true);

    if (_controller.isAnimating) {
      _pendingAnimationIndex = _outroAnimationIndex;
    } else {
      setState(() => _selectedIndex = _outroAnimationIndex);
    }
  }

  /// Manages the complex state transitions when an animation completes.
  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Priority 1: If the outro just finished, pop the screen.
      if (_selectedIndex == _outroAnimationIndex) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }

      // Priority 2: A new animation is pending from a button press.
      if (_pendingAnimationIndex != null) {
        setState(() {
          _selectedIndex = _pendingAnimationIndex!;
          _pendingAnimationIndex = null;
        });
      }
      // Priority 3: The idle animation (Walk) just finished, so loop it.
      else if (_selectedIndex == _idleAnimationIndex) {
        _controller.forward(from: 0);
      }
      // Priority 4: Any other animation finished (including Intro),
      // so switch to the idle animation (Walk).
      else {
        setState(() {
          _selectedIndex = _idleAnimationIndex;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoNinjaAppBar.main(),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ProgressButton(
            onPressed: _isExiting ? null : () => _onButtonPressed(1),
            isSelected: _selectedIndex == 1,
            isPending: _pendingAnimationIndex == 1,
            controller: _controller,
            label: _buttonLabels[1],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProgressButton(
                onPressed: _isExiting ? null : () => _onButtonPressed(2),
                isSelected: _selectedIndex == 2,
                isPending: _pendingAnimationIndex == 2,
                controller: _controller,
                label: _buttonLabels[2],
              ),
              const SizedBox(width: 8),
              ProgressButton(
                onPressed: _isExiting ? null : () => _onButtonPressed(3),
                isSelected: _selectedIndex == 3,
                isPending: _pendingAnimationIndex == 3,
                controller: _controller,
                label: _buttonLabels[3],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          Expanded(
            child: Center(
              child: Lottie.asset(
                _lottieAssets[_selectedIndex],
                key: ValueKey(_lottieAssets[_selectedIndex]),
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..reset()
                    ..forward();
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    'Failed to load asset:\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              // Generate buttons only for indices 1 through 7.
              children: List.generate(4, (i) {
                final index = i + 4; // Map button index to asset index
                final isSelected = index == _selectedIndex;
                final isPending = index == _pendingAnimationIndex;

                return ProgressButton(
                  onPressed: _isExiting ? null : () => _onButtonPressed(index),
                  isSelected: isSelected,
                  isPending: isPending,
                  controller: _controller,
                  label: _buttonLabels[index],
                );
              }),
            ),
          ),
          // 3. Exit Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isExiting ? null : _onExitPressed,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  // Use zero padding for custom child.
                  backgroundColor: AppColors.yellow300,
                  disabledBackgroundColor: Theme.of(context).disabledColor,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress bar for the exit animation
                      if (_isExiting && _selectedIndex == 8)
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _controller.value,
                            child: Container(color: AppColors.yellow300),
                          ),
                        ),
                      // Button label and icon
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.exit_to_app,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isExiting ? 'Exiting' : 'Exit',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class ProgressButton extends StatelessWidget {
  const ProgressButton({
    required this.isSelected, required this.isPending, required this.controller, required this.label, this.onPressed,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isPending;
  final AnimationController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 150,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isSelected
              ? AppColors.primary40
              : (isPending ? AppColors.primary40 : Colors.grey[400]),
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          disabledBackgroundColor: Theme.of(context).disabledColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (isSelected)
                Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: controller.value,
                    child: Container(color: AppColors.yellow300),
                  ),
                ),
              Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
