import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/camino_util.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:repository/repository.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> with SafeEmitMixin {
  LoginCubit() : super(LoginState.initial);

  final Repository _repository = GetIt.instance<Repository>();

  Future<void> signInWithGoogle() async {
    try {
      safeEmit(LoginState.initial);

      await GoogleSignIn.instance.signOut();
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        GetIt.instance<IAnalyticsService>().track(
          SignInFailEvent(
            type: 'Google',
            error: 'Google sign in failed: idToken is null or empty',
          ),
        );
        safeEmit(LoginState.error);
        return;
      }

      safeEmit(LoginState.loading);
      final result = await _repository.login(
        token: idToken,
        loginType: LoginType.google.name,
      );
      await _registerFcmToken();

      final analytics = GetIt.instance<IAnalyticsService>();
      analytics.setUserId(userId: result.user?.id?.toString());
      _setUserProperties('Google');
      analytics.track(
        SignInSuccessEvent(type: 'Google'),
      );
      safeEmit(LoginState.success);
    } catch (e) {
      GetIt.instance<IAnalyticsService>().track(
        SignInFailEvent(
          type: 'Google',
          error: e.toString(),
        ),
      );
      safeEmit(LoginState.error);
    }
  }

  Future<void> signInWithApple() async {
    try {
      safeEmit(LoginState.initial);

      final rawNonce = CaminoUtil.generateNonce();
      final hashedNonce = CaminoUtil.sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      final fullName = [credential.givenName, credential.familyName]
          .where((e) => e != null && e.isNotEmpty)
          .join(' ');

      if (idToken == null || idToken.isEmpty) {
        GetIt.instance<IAnalyticsService>().track(
          SignInFailEvent(
            type: 'Apple',
            error: 'Apple sign in failed: idToken is null or empty',
          ),
        );
        safeEmit(LoginState.error);
        return;
      }

      safeEmit(LoginState.loading);
      final result = await _repository.login(
        token: idToken,
        loginType: LoginType.apple.name,
        name: fullName,
      );
      await _registerFcmToken();

      final analytics = GetIt.instance<IAnalyticsService>();
      analytics.setUserId(userId: result.user?.id?.toString());
      _setUserProperties('Apple');
      analytics.track(
        SignInSuccessEvent(type: 'Apple'),
      );
      safeEmit(LoginState.success);
    } catch (e) {
      GetIt.instance<IAnalyticsService>().track(
        SignInFailEvent(
          type: 'Apple',
          error: e.toString(),
        ),
      );
      safeEmit(LoginState.error);
    }
  }

  void _setUserProperties(String authProvider) {
    GetIt.instance<IAnalyticsService>().setUserProperties({
      'auth_provider': authProvider,
      'is_authenticated': true,
    });
  }

  Future<void> _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _repository.registerDeviceToken(token);
      }
    } catch (_) {}
  }

  Future<void> proceedAsGuest() async {
    try {
      safeEmit(LoginState.loading);
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await _repository.setProceedAsGuest(true);
      GetIt.instance<IAnalyticsService>().track(
        ProceedAsGuestEvent(),
      );
      safeEmit(LoginState.successWithGuest);
    } catch (e) {
      safeEmit(LoginState.error);
    }
  }
}
