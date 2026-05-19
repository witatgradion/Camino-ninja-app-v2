import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

class Destination extends Equatable {
  Destination({
    required this.id,
    required this.name,
    required this.distanceFromPrevious,
    required this.totalDistance,
    required this.availableServices,
    required this.etapeCity,
    required this.city,
  });

  final int id;
  final String name;
  final double distanceFromPrevious;
  final double totalDistance;
  final List<AvailableService> availableServices;
  final bool etapeCity;
  final CityEntity city;

  @override
  List<Object> get props => [
        id,
        name,
        distanceFromPrevious,
        totalDistance,
        availableServices,
        etapeCity,
        city,
      ];
}
