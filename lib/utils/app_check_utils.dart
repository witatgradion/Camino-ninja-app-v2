import 'package:firebase_core/firebase_core.dart';

/// Returns `true` when [error] originates from Firebase
/// App Check / Play Integrity background token refresh.
bool isAppCheckError(Object error) {
  // Check by type first (most reliable)
  if (error is FirebaseException &&
      error.plugin == 'firebase_app_check') {
    return true;
  }
  // Fallback: string matching for errors that don't use
  // FirebaseException
  final errorString = error.toString().toLowerCase();
  return errorString.contains('appcheck') ||
      errorString.contains('app_check') ||
      errorString.contains('playintegrity') ||
      errorString.contains('play integrity') ||
      errorString.contains('integrityserviceexception');
}
