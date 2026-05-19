import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class GestureDelegate {
  const GestureDelegate({
    this.scrollEnabled = true,
    this.pinchToZoomEnabled = true,
    this.doubleTapToZoomInEnabled = true,
    this.mapToolbarEnabled = false,
    this.locationEnabled = true,
    this.locationPulsingEnabled = false,
  });

  final bool scrollEnabled;
  final bool pinchToZoomEnabled;
  final bool doubleTapToZoomInEnabled;
  final bool mapToolbarEnabled;
  final bool locationEnabled;
  final bool locationPulsingEnabled;

  Future<void> apply(MapboxMap map) async {
    await map.gestures.updateSettings(
      GesturesSettings(
        rotateEnabled: false,
        pitchEnabled: false,
        scrollEnabled: scrollEnabled,
        pinchToZoomEnabled: pinchToZoomEnabled,
        doubleTapToZoomInEnabled: doubleTapToZoomInEnabled,
      ),
    );
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await map.compass.updateSettings(CompassSettings(enabled: false));
    await map.attribution.updateSettings(
      AttributionSettings(enabled: mapToolbarEnabled),
    );
    await map.location.updateSettings(
      LocationComponentSettings(
        enabled: locationEnabled,
        pulsingEnabled: locationPulsingEnabled,
      ),
    );
  }
}
