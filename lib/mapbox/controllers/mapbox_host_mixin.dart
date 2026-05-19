import 'dart:async';

import 'package:camino_ninja_flutter/utils/mapbox_map_style.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Shared style-swap + dispose discipline for controllers that own a
/// [MapboxMap] handle.
///
/// Provides:
/// - A serialised [swapStyle] that survives rapid theme/satellite toggles
///   without leaving `_currentStyleUri` and the in-flight `loadStyleURI`
///   future out of sync.
/// - A satellite toggle that routes through the same serialised path so
///   theme and satellite swaps cannot race each other.
/// - A `disposed` flag and idempotent [disposeHost] hook so subclass
///   `dispose()` paths can no-op on second invocation and bail in native
///   callbacks that fire after teardown.
mixin MapboxHostMixin {
  /// Returns the live [MapboxMap] handle, or null if the map has been
  /// disposed / not yet attached. Subclasses implement this against
  /// whichever field they use to hold the map.
  MapboxMap? get hostMap;

  /// The URI of the style currently displayed on the map. Used to
  /// short-circuit a swap when the target URI matches and to remember
  /// the theme URI underneath a temporary satellite overlay.
  String? _currentStyleUri;
  Future<void>? _styleSwap;
  bool _disposed = false;

  /// `true` while a satellite style is active. Lifted off the
  /// `SatelliteToggleButton` widget so theme changes can fall through
  /// cleanly and the toggle state remains a single source of truth.
  bool _isSatelliteView = false;

  /// The URI to restore when satellite is toggled off. Remembered when
  /// satellite is enabled, cleared on disable.
  String? _preSatelliteStyleUri;

  String? get currentStyleUri => _currentStyleUri;
  bool get isSatelliteView => _isSatelliteView;
  bool get disposed => _disposed;

  /// Initialises the tracked style URI. Call from `onMapCreated` once
  /// the initial style is known.
  // ignore: use_setters_to_change_properties
  void setInitialStyleUri(String uri) {
    _currentStyleUri = uri;
  }

  /// Single-flight wrapper around `loadStyleURI`. Serialises rapid
  /// successive style swaps (theme toggle, satellite toggle) so we never
  /// have two style swaps racing — the recreated annotation managers and
  /// the in-flight style would otherwise mismatch.
  ///
  /// The implementation is careful with four invariants:
  /// 1. `_currentStyleUri` only mutates AFTER `loadStyleURI` resolves so
  ///    a second caller racing in mid-swap doesn't see the new URI and
  ///    drop itself via the equality short-circuit.
  /// 2. We chain off the *captured* in-flight swap, not the field, so a
  ///    later overwrite doesn't strand earlier waiters.
  /// 3. The tail only nulls `_styleSwap` if it still points at the
  ///    future this call installed — otherwise we'd null a NEWER
  ///    caller's in-flight future.
  /// 4. Our completer-backed future is installed into `_styleSwap`
  ///    *synchronously* — before any await — so a third caller arriving
  ///    while we're queued chains on US, not on the previous swap. Two
  ///    callers awaiting the same `previousSwap` would otherwise both
  ///    wake up, both pass the URI re-check, and both fire
  ///    `loadStyleURI` against the native side.
  Future<void> swapStyle(String newUri) async {
    if (_disposed) return;
    if (newUri == _currentStyleUri) return;
    final previousSwap = _styleSwap;
    final completer = Completer<void>();
    final swap = completer.future;
    _styleSwap = swap;
    try {
      await previousSwap;
      if (_disposed) return;
      if (newUri == _currentStyleUri) return;
      final map = hostMap;
      if (map == null) return;
      await map.loadStyleURI(newUri);
      if (_disposed) return;
      _currentStyleUri = newUri;
    } finally {
      completer.complete();
      if (identical(_styleSwap, swap)) {
        _styleSwap = null;
      }
    }
  }

  /// Toggles the satellite style on or off, routing through [swapStyle]
  /// so the swap is serialised against in-flight theme changes. When
  /// switching back from satellite, restores the theme URI that was
  /// active when satellite was enabled.
  ///
  /// [themeUri] is the theme-resolved URI (light/dark) the caller wants
  /// to fall back to when satellite is disabled. It is also used to
  /// recover from a missing remembered URI.
  Future<void> toggleSatellite({required String themeUri}) async {
    if (_disposed) return;
    if (_isSatelliteView) {
      _isSatelliteView = false;
      final restore = _preSatelliteStyleUri ?? themeUri;
      _preSatelliteStyleUri = null;
      await swapStyle(restore);
    } else {
      _preSatelliteStyleUri = _currentStyleUri;
      _isSatelliteView = true;
      await swapStyle(MapboxMapStyle.satellite);
    }
  }

  /// Updates the URI the mixin will restore when satellite is toggled
  /// off. Called by hosts on a theme change so a satellite-on user
  /// returns to the new theme (rather than the pre-change one) when
  /// they disable satellite.
  void updatePreSatelliteThemeUri(String themeUri) {
    if (!_isSatelliteView) return;
    _preSatelliteStyleUri = themeUri;
  }

  /// Marks the host disposed and clears the in-flight style swap so a
  /// late `loadStyleURI` completion can't reach into a torn-down
  /// controller. Subclasses call this from their own `dispose()` to
  /// participate in idempotent teardown.
  void disposeHost() {
    if (_disposed) return;
    _disposed = true;
    _styleSwap = null;
  }
}
