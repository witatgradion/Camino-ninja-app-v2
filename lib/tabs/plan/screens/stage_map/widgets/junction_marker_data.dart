import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

class JunctionMarkerData extends Equatable {
  const JunctionMarkerData({
    required this.city,
    required this.fromRouteName,
    required this.toRouteName,
    required this.glowColorValue,
  });

  final CityEntity city;
  final String fromRouteName;
  final String toRouteName;
  final int glowColorValue;

  @override
  List<Object?> get props => [
        city,
        fromRouteName,
        toRouteName,
        glowColorValue,
      ];
}
