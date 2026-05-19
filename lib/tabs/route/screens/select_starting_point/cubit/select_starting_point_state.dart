part of 'select_starting_point_cubit.dart';

enum SelectStartingPointInitStatus {
  initial,
  loading,
  success,
}

enum SelectStartingPointFilteringStatus {
  initial,
  loading,
  success,
}

class SelectStartingPointState extends Equatable {
  const SelectStartingPointState({
    this.cities = const [],
    this.filteredCities = const [],
    this.error,
    this.selectedStartingPoint,
    this.initStatus = SelectStartingPointInitStatus.initial,
    this.filteringStatus = SelectStartingPointFilteringStatus.initial,
    this.autoScrollCityIndex,
    this.nearestCity,
    this.nearestCityDistance,
    this.autoScroll = false,
    this.accuracyDenied = false,
    this.isSelectCurrentLocation = false,
  });

  final SelectStartingPointInitStatus initStatus;
  final SelectStartingPointFilteringStatus filteringStatus;
  final List<CityEntity> cities;
  final List<CityEntity> filteredCities;
  final CityEntity? selectedStartingPoint;
  final String? error;
  final int? autoScrollCityIndex;
  final CityEntity? nearestCity;
  final double? nearestCityDistance;
  final bool autoScroll;
  final bool accuracyDenied;
  final bool isSelectCurrentLocation;

  SelectStartingPointState copyWith({
    List<CityEntity>? cities,
    List<CityEntity>? filteredCities,
    String? error,
    CityEntity? selectedStartingPoint,
    SelectStartingPointInitStatus? initStatus,
    SelectStartingPointFilteringStatus? filteringStatus,
    int? autoScrollCityIndex,
    CityEntity? nearestCity,
    double? nearestCityDistance,
    bool? autoScroll,
    bool? accuracyDenied,
    bool? isSelectCurrentLocation,
  }) {
    return SelectStartingPointState(
        cities: cities ?? this.cities,
        filteredCities: filteredCities ?? this.filteredCities,
        error: error ?? this.error,
        selectedStartingPoint:
            selectedStartingPoint ?? this.selectedStartingPoint,
        initStatus: initStatus ?? this.initStatus,
        filteringStatus: filteringStatus ?? this.filteringStatus,
        autoScrollCityIndex: autoScrollCityIndex ?? this.autoScrollCityIndex,
        nearestCity: nearestCity ?? this.nearestCity,
        nearestCityDistance: nearestCityDistance ?? this.nearestCityDistance,
        autoScroll: autoScroll ?? this.autoScroll,
        accuracyDenied: accuracyDenied ?? this.accuracyDenied,
        isSelectCurrentLocation:
            isSelectCurrentLocation ?? this.isSelectCurrentLocation,);
  }

  @override
  List<Object?> get props => [
        cities,
        filteredCities,
        error,
        selectedStartingPoint,
        initStatus,
        filteringStatus,
        autoScrollCityIndex,
        selectedStartingPoint,
        nearestCity,
        nearestCityDistance,
        autoScroll,
        accuracyDenied,
        isSelectCurrentLocation,
      ];
}
