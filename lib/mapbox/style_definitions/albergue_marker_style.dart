import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class AlbergueMarkerStyle {
  AlbergueMarkerStyle._();

  // ── Icon ───────────────────────────────────────────────────
  static const String iconId = 'albergue-icon';
  static const String clusterBadgeIconId = 'albergue-cluster-badge-icon';
  static const double _logicalSize = 30;
  static const double _pixelRatio = 2;
  static const String _iconAssetPath = 'assets/ic_albergue_marker.svg';

  /// Size of the cluster-badge circle. Sized to hug the
  /// `point_count_abbreviated` text (13 pt) with ~1 px padding.
  static const double _clusterBadgeLogicalSize = 18;
  static const Color _clusterBadgeColor = Color(0xFFE53935);

  /// Rasterizes [_iconAssetPath] to an [MbxImage] for use as both the
  /// individual albergue marker and the cluster hotel icon.
  ///
  /// The SVG already bakes in the cyan fill, black border, and hotel
  /// iconography, so no additional canvas compositing is required.
  static Future<MbxImage> buildIcon() async {
    const physical = _logicalSize * _pixelRatio;
    const physicalInt = (_logicalSize * _pixelRatio) ~/ 1;

    final pictureInfo = await vg.loadPicture(
      const SvgAssetLoader(_iconAssetPath),
      null,
    );

    try {
      final recorder = ui.PictureRecorder();
      final scale = physical / pictureInfo.size.width;
      ui.Canvas(recorder)
        ..scale(scale)
        ..drawPicture(pictureInfo.picture);

      final picture = recorder.endRecording();
      try {
        final image = await picture.toImage(physicalInt, physicalInt);
        try {
          final byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          return MbxImage(
            width: physicalInt,
            height: physicalInt,
            data: byteData!.buffer.asUint8List(),
          );
        } finally {
          image.dispose();
        }
      } finally {
        picture.dispose();
      }
    } finally {
      pictureInfo.picture.dispose();
    }
  }

  /// Renders a solid filled circle used as the cluster badge background.
  /// The badge is drawn as a small overlay at the upper-right of the
  /// hotel cluster icon, with the `point_count_abbreviated` text sitting
  /// centred on top of it.
  static Future<MbxImage> buildClusterBadge() async {
    const physical = _clusterBadgeLogicalSize * _pixelRatio;

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
      ..scale(_pixelRatio)
      ..drawCircle(
        const Offset(
          _clusterBadgeLogicalSize / 2,
          _clusterBadgeLogicalSize / 2,
        ),
        _clusterBadgeLogicalSize / 2,
        Paint()
          ..color = _clusterBadgeColor
          ..style = PaintingStyle.fill,
      );

    final picture = recorder.endRecording();
    final image = await picture.toImage(physical.round(), physical.round());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return MbxImage(
      width: physical.round(),
      height: physical.round(),
      data: byteData!.buffer.asUint8List(),
    );
  }

  // ── Layer properties ───────────────────────────────────────

  /// Hotel-icon cluster layer. Draws the same hotel-circle icon used for
  /// individual markers so a cluster still reads as "a group of albergues"
  /// at a glance. The numeric badge lives on a separate overlay layer
  /// ([clusterBadgeLayerProps]) drawn above this one.
  static const Map<String, dynamic> clusterHotelLayerProps = {
    'filter': ['has', 'point_count'],
    'icon-image': iconId,
    'icon-anchor': 'bottom',
    'icon-allow-overlap': true,
    'icon-ignore-placement': true,
    'icon-size': 1.1,
  };

  /// Red-circle count badge drawn on top of [clusterHotelLayerProps].
  /// The offsets are tuned to place the badge at the upper-right corner of
  /// the hotel icon (which is anchored at `bottom`).
  ///
  /// The previous implementation used `text-offset: [1.0, -2.2]` at
  /// `text-size: 11`, which is ≈ `[11px, -24px]` from the symbol origin.
  /// We mirror that visual here: icon-offset in px = [11, -24], and
  /// text-offset in ems at text-size 13 = [11/13, -24/13] ≈ [0.85, -1.85].
  static const Map<String, dynamic> clusterBadgeLayerProps = {
    'filter': ['has', 'point_count'],
    'icon-image': clusterBadgeIconId,
    'icon-anchor': 'center',
    'icon-allow-overlap': true,
    'icon-ignore-placement': true,
    'icon-offset': [11, -24],
    'icon-size': 1.0,
    'text-field': ['get', 'point_count_abbreviated'],
    'text-size': 13,
    'text-font': ['Open Sans Bold', 'Arial Unicode MS Bold'],
    'text-color': '#ffffff',
    'text-anchor': 'center',
    'text-offset': [0.85, -1.85],
    'text-allow-overlap': true,
    'text-ignore-placement': true,
  };

  static const Map<String, dynamic> individualLayerProps = {
    'filter': ['!', ['has', 'point_count']],
    'icon-image': iconId,
    'icon-allow-overlap': false,
    'icon-ignore-placement': false,
    'icon-anchor': 'bottom',
    'icon-size': 1.0,
    'text-field': ['get', 'name'],
    'text-size': 13,
    'text-anchor': 'top',
    'text-offset': [0, 0.5],
    'text-allow-overlap': false,
    'text-optional': true,
    'text-max-width': 8,
    'text-halo-color': '#ffffff',
    'text-halo-width': 1.5,
    'symbol-sort-key': 2,
  };
}
