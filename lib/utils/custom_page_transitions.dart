import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transition utilities for GoRouter
class CustomPageTransitions {
  
  /// Slide transition from right to left
  static Page<T> slideTransition<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(name),
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );
      },
    );
  }

  /// Fade transition
  static Page<T> fadeTransition<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(name),
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale transition
  static Page<T> scaleTransition<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(name),
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0, end: 1).chain(
              CurveTween(curve: Curves.elasticOut),
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Shared axis transition (from animations package)
  static Page<T> sharedAxisTransition<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(name),
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }

  /// Hero transition for shared elements
  static Page<T> heroTransition<T extends Object?>({
    required Widget child,
    required String heroTag, String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(name),
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return Hero(
          tag: heroTag,
          child: child,
        );
      },
    );
  }

  /// Custom rotation transition
  static Page<T> rotationTransition<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(name),
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return RotationTransition(
          turns: animation.drive(
            Tween<double>(begin: 0, end: 1).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Combined slide and fade transition
  static Page<T> slideFadeTransition<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(name),
      child: child,
      name: name,
      arguments: arguments,
      transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}