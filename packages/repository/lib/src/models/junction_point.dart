// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

/// A point on a route where the user can switch to another
/// route. Contains the junction city and the available
/// branching routes (excluding the current route).
class JunctionPoint extends Equatable {
  const JunctionPoint({
    required this.city,
    required this.branchRoutes,
  });

  /// The city where the junction occurs.
  final CityEntity city;

  /// Routes available to switch to at this junction,
  /// excluding the route the user is currently on.
  final List<RouteEntity> branchRoutes;

  @override
  List<Object?> get props => [city, branchRoutes];
}
