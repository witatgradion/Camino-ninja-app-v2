part of 'distance_cubit.dart';

class DistanceState extends Equatable {
  const DistanceState({
    this.nextCity,
    this.distanceToNextCity,
    this.distanceFromRoute,
    this.destinationCity,
    this.distanceToDestination,
    this.routeName,
    this.isLoading = false,
    this.isTooFar = false,
    this.errorMessage,
    this.permissionDenied = false,
    this.permanentlyDenied = false,
    this.accuracyDenied = false,
  });

  final String? nextCity;
  final String? distanceToNextCity;
  final String? distanceFromRoute;
  final String? destinationCity;
  final String? distanceToDestination;
  final String? routeName;
  final bool isLoading;
  final bool isTooFar;
  final String? errorMessage;
  final bool permissionDenied;
  final bool permanentlyDenied;
  final bool accuracyDenied;

  DistanceState copyWith({
    String? nextCity,
    String? distanceToNextCity,
    String? distanceFromRoute,
    String? destinationCity,
    String? distanceToDestination,
    String? routeName,
    bool? isLoading,
    bool? isTooFar,
    String? errorMessage,
    bool? permissionDenied,
    bool? permanentlyDenied,
    bool? accuracyDenied,
  }) {
    return DistanceState(
      nextCity: nextCity ?? this.nextCity,
      distanceToNextCity: distanceToNextCity ?? this.distanceToNextCity,
      distanceFromRoute: distanceFromRoute ?? this.distanceFromRoute,
      destinationCity: destinationCity ?? this.destinationCity,
      distanceToDestination:
          distanceToDestination ?? this.distanceToDestination,
      routeName: routeName ?? this.routeName,
      isLoading: isLoading ?? this.isLoading,
      isTooFar: isTooFar ?? this.isTooFar,
      errorMessage: errorMessage ?? this.errorMessage,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      permanentlyDenied: permanentlyDenied ?? this.permanentlyDenied,
      accuracyDenied: accuracyDenied ?? this.accuracyDenied,
    );
  }

  @override
  List<Object?> get props => [
        nextCity,
        distanceToNextCity,
        distanceFromRoute,
        destinationCity,
        distanceToDestination,
        routeName,
        isLoading,
        isTooFar,
        errorMessage,
        permissionDenied,
        permanentlyDenied,
        accuracyDenied,
      ];
}
