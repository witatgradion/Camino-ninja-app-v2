enum Flavor {
  development,
  staging,
  production,
}

class AppConfig {
  static Flavor _currentFlavor = Flavor.development;

  static void setFlavor(Flavor flavor) {
    _currentFlavor = flavor;
  }

  static Flavor get flavor => _currentFlavor;

  static String get seedDatabasePath {
    return switch (_currentFlavor) {
      Flavor.production => 'assets/camino_database.db',
      _ => 'assets/_dev_camino_database.db',
    };
  }
}
