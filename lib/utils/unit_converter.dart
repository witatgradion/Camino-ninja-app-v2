import 'package:core/core.dart';

enum UnitEnum {
  metric,
  imperial;

  String get title => switch (this) {
        metric => 'Metric (km)',
        imperial => 'Imperial (miles)',
      };

  String get distanceUnit => switch (this) {
        metric => 'km',
        imperial => 'mi',
      };

  String get elevationUnit => switch (this) {
        metric => 'm',
        imperial => 'ft',
      };

  static UnitEnum fromString(String? value) {
    return switch (value) {
      'metric' => metric,
      'imperial' => imperial,
      _ => metric,
    };
  }
}

class UnitConverter {
  static String displayElevation(
      {required double meters, required UnitEnum unit, bool space = true,}) {
    if (unit == UnitEnum.metric) {
      return '${meters.toStringAsFixed(0)}${space ? ' m' : 'm'}';
    } else {
      return '${convertElevation(meters: meters, unit: unit).toStringAsFixed(0)}${space ? ' ft' : 'ft'}';
    }
  }

  // Convert distance to km before passing to this function
  static String displayDistance({
    required double kilometers,
    required UnitEnum unit,
    int fractionDigits = 1,
    bool space = true,
  }) {
    if (unit == UnitEnum.metric) {
      return '${kilometers.toStringAsFixed(fractionDigits)}${space ? ' km' : 'km'}';
    } else {
      return '${convertDistance(kilometers: kilometers, unit: unit).toStringAsFixed(fractionDigits)}${space ? ' mi' : 'mi'}';
    }
  }

  // Convert distance to m before passing to this function
  static int convertElevation({required double meters, required UnitEnum unit}) {
    if (unit == UnitEnum.metric) {
      return meters.toInt();
    }
    return (meters * UnitConversions.metersToFeet).toInt();
  }

  // Convert distance to km before passing to this function
  static double convertDistance({
    required double kilometers,
    required UnitEnum unit,
  }) {
    if (unit == UnitEnum.metric) {
      return kilometers;
    }
    return kilometers * UnitConversions.kmToMiles;
  }
}
