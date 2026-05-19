// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Lightweight descriptor for a single trail segment,
/// used for serialization and deserialization of trail
/// data without loading full city lists.
class TrailSegmentDescriptor extends Equatable {
  const TrailSegmentDescriptor({
    required this.routeId,
    this.junctionCityId,
  });

  factory TrailSegmentDescriptor.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrailSegmentDescriptor(
      routeId: json['r'] as int,
      junctionCityId: json['j'] as int?,
    );
  }

  /// The route this segment belongs to.
  final int routeId;

  /// The junction city where this segment starts from.
  /// Null for the first segment in a trail.
  final int? junctionCityId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'r': routeId};
    if (junctionCityId != null) {
      map['j'] = junctionCityId;
    }
    return map;
  }

  @override
  List<Object?> get props => [routeId, junctionCityId];
}

/// A single segment of a multi-route trail, representing a contiguous
/// portion of one route that the pilgrim walks.
class TrailSegment extends Equatable {
  const TrailSegment({
    required this.routeId,
    required this.routeName,
    required this.colorValue,
    required this.cityIds,
    this.routeSubName,
    this.junctionCityId,
  });

  /// The route this segment belongs to.
  final int routeId;

  /// Route display name.
  final String routeName;

  /// Optional route subtitle.
  final String? routeSubName;

  /// Route color stored as an int (no Flutter Color dependency).
  final int colorValue;

  /// Ordered city IDs in walking direction.
  final List<int> cityIds;

  /// The junction city where this segment starts from.
  /// Null for the first segment in a trail.
  final int? junctionCityId;

  @override
  List<Object?> get props => [
        routeId,
        routeName,
        routeSubName,
        colorValue,
        cityIds,
        junctionCityId,
      ];
}

/// A custom trail built from one or more route segments connected
/// at junction cities.
class MultiRouteTrail extends Equatable {
  const MultiRouteTrail({
    required this.segments,
  });

  /// Ordered list of trail segments in walking direction.
  final List<TrailSegment> segments;

  /// The route ID of the first segment.
  int get primaryRouteId => segments.first.routeId;

  /// Whether this trail spans more than one route.
  bool get isMultiRoute => segments.length > 1;

  /// All unique route IDs across segments.
  Set<int> get routeIds => segments.map((s) => s.routeId).toSet();

  /// Finds the last segment that contains the given [cityId],
  /// preferring later segments for junction cities that appear
  /// at segment boundaries.
  TrailSegment? segmentForCity(int cityId) {
    TrailSegment? result;
    for (final segment in segments) {
      if (segment.cityIds.contains(cityId)) {
        result = segment;
      }
    }
    return result;
  }

  /// Flat, ordered list of all city IDs across segments,
  /// deduplicated at boundaries so junction cities appear once.
  List<int> get allCityIds {
    if (segments.isEmpty) return const [];
    final result = <int>[...segments.first.cityIds];
    for (var i = 1; i < segments.length; i++) {
      final segmentCities = segments[i].cityIds;
      if (segmentCities.isEmpty) continue;
      // Skip the first city if it duplicates the last added city
      // (junction city shared between adjacent segments).
      final start =
          (result.isNotEmpty && segmentCities.first == result.last) ? 1 : 0;
      result.addAll(segmentCities.skip(start));
    }
    return result;
  }

  /// Position of [cityId] in the flat ordered city list,
  /// or null if the city is not part of this trail.
  int? cityIndexInTrail(int cityId) {
    final index = allCityIds.indexOf(cityId);
    return index == -1 ? null : index;
  }

  /// Serializes this trail to a compact JSON string for DB
  /// storage. Format: `[{"r":1},{"r":3,"j":250}]`.
  String toStorageString() {
    final descriptors = segments.map((s) {
      return TrailSegmentDescriptor(
        routeId: s.routeId,
        junctionCityId: s.junctionCityId,
      ).toJson();
    }).toList();
    return jsonEncode(descriptors);
  }

  /// Parses a storage string into segment descriptors.
  ///
  /// Supports two formats:
  /// - New JSON: `[{"r":1},{"r":3,"j":250}]`
  /// - Old comma-separated: `"1,3"` (no junction info)
  ///
  /// Returns null if the string is empty or unparseable.
  static List<TrailSegmentDescriptor>? parseDescriptors(
    String? raw,
  ) {
    if (raw == null || raw.trim().isEmpty) return null;

    final trimmed = raw.trim();

    // Try JSON format first
    if (trimmed.startsWith('[')) {
      try {
        final list = jsonDecode(trimmed) as List<dynamic>;
        return list
            .cast<Map<String, dynamic>>()
            .map(TrailSegmentDescriptor.fromJson)
            .toList();
      } catch (_) {
        return null;
      }
    }

    // Fall back to old comma-separated format
    final ids = trimmed
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    if (ids.isEmpty) return null;

    return ids
        .map(
          (id) => TrailSegmentDescriptor(routeId: id),
        )
        .toList();
  }

  /// Returns the ordered list of segment ranges needed to walk
  /// from [startCityId] to [endCityId] across segments.
  ///
  /// Returns null if either city is not in the trail or
  /// end is before start.
  List<({TrailSegment segment, int fromCityId, int toCityId})>?
      segmentsBetweenCities(int startCityId, int endCityId) {
    final cities = allCityIds;
    final startIndex = cities.indexOf(startCityId);
    final endIndex = cities.indexOf(endCityId);
    if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
      return null;
    }

    // Find the FIRST segment containing startCityId.
    final startSegment = segments.firstWhere(
      (s) => s.cityIds.contains(startCityId),
    );

    // Find the LAST segment containing endCityId.
    TrailSegment? endSegment;
    for (final segment in segments) {
      if (segment.cityIds.contains(endCityId)) {
        endSegment = segment;
      }
    }

    if (endSegment == null) return null;

    final startSegIdx = segments.indexOf(startSegment);
    final endSegIdx = segments.indexOf(endSegment);

    // Same segment — single range.
    if (startSegIdx == endSegIdx) {
      return [
        (
          segment: startSegment,
          fromCityId: startCityId,
          toCityId: endCityId,
        ),
      ];
    }

    // Multiple segments — build ordered list.
    // First: start city → end of its segment (junction).
    final result =
        <({TrailSegment segment, int fromCityId, int toCityId})>[
      (
        segment: startSegment,
        fromCityId: startCityId,
        toCityId: startSegment.cityIds.last,
      ),
    ];

    // Middle: full intermediate segments.
    for (var i = startSegIdx + 1; i < endSegIdx; i++) {
      final mid = segments[i];
      result.add(
        (
          segment: mid,
          fromCityId: mid.cityIds.first,
          toCityId: mid.cityIds.last,
        ),
      );
    }

    // Last: start of end segment (junction) → end city.
    result.add(
      (
        segment: endSegment,
        fromCityId: endSegment.cityIds.first,
        toCityId: endCityId,
      ),
    );

    return result;
  }

  @override
  List<Object?> get props => [segments];
}
