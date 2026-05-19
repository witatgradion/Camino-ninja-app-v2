import 'package:equatable/equatable.dart';

class ClosestCity extends Equatable {
  const ClosestCity({
    required this.cityId,
    required this.cityName,
    required this.cityIndex,
    this.routePointId,
    this.distance,
  });

  final int cityId;
  final String cityName;
  final int? routePointId;
  final double? distance;
  final int cityIndex;

  @override
  List<Object?> get props => [
        cityId,
        cityName,
        routePointId,
        distance,
        cityIndex,
      ];
}
