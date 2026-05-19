part of 'app_cubit.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppSelectRoute extends AppEvent {
  const AppSelectRoute(this.routeId);

  final int routeId;

  @override
  List<Object> get props => [routeId];
}

class AppSelectStartingPoint extends AppEvent {
  const AppSelectStartingPoint(this.cityId);

  final int cityId;

  @override
  List<Object> get props => [cityId];
}

class AppSelectDestination extends AppEvent {
  const AppSelectDestination(this.cityId);

  final int cityId;

  @override
  List<Object> get props => [cityId];
}

class AppLoadCachedData extends AppEvent {
  const AppLoadCachedData();
}

class AppFetchRoutes extends AppEvent {
  const AppFetchRoutes();
}

class AppChangeLanguage extends AppEvent {
  const AppChangeLanguage(this.language);

  final String language;

  @override
  List<Object> get props => [language];
}
