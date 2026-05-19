part of 'login_cubit.dart';

enum LoginType {
  google,
  apple,
}

enum LoginState {
  initial,
  loading,
  success,
  successWithGuest,
  error,
}
