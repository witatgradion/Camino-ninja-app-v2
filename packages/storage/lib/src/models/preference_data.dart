import 'package:equatable/equatable.dart';

class PreferenceData extends Equatable {
  const PreferenceData({
    this.selectedRouteId,
    this.selectedStartCityId,
    this.selectedEndCityId,
    this.language,
    required this.darkModeEnabled,
    this.unit,
    this.theme,
  });

  final int? selectedRouteId;
  final int? selectedStartCityId;
  final int? selectedEndCityId;
  final bool darkModeEnabled;
  final String? language;
  final String? unit;
  final String? theme;

  @override
  List<Object?> get props => [
        selectedRouteId,
        selectedStartCityId,
        selectedEndCityId,
        darkModeEnabled,
        language,
        unit,
        theme,
      ];
}
