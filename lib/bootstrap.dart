import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:camino_ninja_flutter/utils/timeago_setup.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    AppLogger.d('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    AppLogger.e(
      'onError(${bloc.runtimeType})',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    AppLogger.e(
      details.exceptionAsString(),
      stackTrace: details.stack,
    );
  };

  // Bloc.observer = const AppBlocObserver();

  registerAppTimeagoLocales();

  runApp(await builder());
}
