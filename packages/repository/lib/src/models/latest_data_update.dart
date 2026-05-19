class LatestDataUpdate {
  LatestDataUpdate({
    this.shouldUpdateRoutes = false,
    this.shouldUpdateRoutePoints = false,
    this.shouldUpdateAltRoutePoints = false,
    this.shouldUpdateCities = false,
    this.shouldUpdateAlbergues = false,
    this.shouldUpdateAlbergueUserImages = false,
  });

  final bool shouldUpdateRoutes;
  final bool shouldUpdateRoutePoints;
  final bool shouldUpdateAltRoutePoints;
  final bool shouldUpdateCities;
  final bool shouldUpdateAlbergues;
  final bool shouldUpdateAlbergueUserImages;

  @override
  String toString() {
    return 'LatestDataUpdate(shouldUpdateRoutes: $shouldUpdateRoutes, '
        'shouldUpdateRoutePoints: $shouldUpdateRoutePoints, '
        'shouldUpdateAltRoutePoints: $shouldUpdateAltRoutePoints, '
        'shouldUpdateCities: $shouldUpdateCities, '
        'shouldUpdateAlbergues: $shouldUpdateAlbergues, '
        'shouldUpdateAlbergueUserImages: $shouldUpdateAlbergueUserImages)';
  }
}
