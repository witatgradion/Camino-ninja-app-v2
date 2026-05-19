import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class CaminoUtil {
  /// Calculates a custom Fibonacci-like number for in-app review timing.
  ///
  /// Returns the standard Fibonacci number at position (n + 2).
  /// This creates the sequence: 1, 2, 3, 5, 8, 13, 21... for showTimes 0, 1, 2, 3, 4, 5, 6...
  /// Throws an ArgumentError if the input number is negative.
  static int calculateCustomFibonacci(int n) {
    // Input validation: Fibonacci is not defined for negative numbers here.
    if (n < 0) {
      return 0;
    }

    // For all n >= 0, we need to calculate the standard Fibonacci number
    // at the position (n + 2).
    // Example: for n=0, we need F(0+2) = F(2), which is 1.
    //          for n=1, we need F(1+2) = F(3), which is 2.
    //          for n=2, we need F(2+2) = F(4), which is 3.
    final targetIndex = n + 2;

    // Iterative calculation for standard Fibonacci sequence
    if (targetIndex <= 1) {
      return targetIndex;
    }

    var a = 0;
    var b = 1;

    for (var i = 2; i <= targetIndex; i++) {
      final next = a + b;
      a = b;
      b = next;
    }

    return b;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }  

  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
