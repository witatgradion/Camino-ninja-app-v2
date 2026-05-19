import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:storage/storage.dart';

/// A segment of cities the user traverses between two
/// junctions (or from route start to first junction, or
/// from last junction to route end).
class PathSegment extends Equatable {
  const PathSegment({
    required this.routeId,
    required this.routeName,
    required this.routeColor,
    required this.cities,
    this.routeSubName,
  });

  final int routeId;
  final String routeName;
  final String? routeSubName;
  final Color routeColor;
  final List<CityEntity> cities;

  @override
  List<Object?> get props => [routeId, cities];
}

/// A fork in the road — the user must choose which route
/// to continue on.
class JunctionChoice extends Equatable {
  const JunctionChoice({
    required this.junctionCity,
    required this.branches,
  });

  final CityEntity junctionCity;
  final List<BranchOption> branches;

  @override
  List<Object?> get props => [junctionCity, branches];
}

/// One possible branch the user can take at a junction.
class BranchOption extends Equatable {
  const BranchOption({
    required this.routeId,
    required this.routeName,
    required this.routeColor,
    required this.isContinuation,
    required this.citiesAhead,
    this.routeSubName,
  });

  final int routeId;
  final String routeName;
  final String? routeSubName;
  final Color routeColor;

  /// True if this is "keep going on the current route".
  final bool isContinuation;

  /// Number of cities remaining on this route after the
  /// junction (until end of route).
  final int citiesAhead;

  @override
  List<Object?> get props => [routeId, isContinuation];
}

/// A junction the user has already resolved by picking a branch.
class ResolvedJunction extends Equatable {
  const ResolvedJunction({
    required this.junction,
    required this.chosenBranch,
  });

  final JunctionChoice junction;
  final BranchOption chosenBranch;

  @override
  List<Object?> get props => [junction, chosenBranch];
}
