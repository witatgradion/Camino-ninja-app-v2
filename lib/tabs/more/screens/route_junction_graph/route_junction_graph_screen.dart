import 'package:camino_ninja_flutter/tabs/more/screens/route_junction_graph/cubit/route_junction_graph_cubit.dart';
import 'package:camino_ninja_flutter/tabs/more/screens/route_junction_graph/models/path_segment.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:storage/storage.dart';

class RouteJunctionGraphScreen extends StatelessWidget {
  const RouteJunctionGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteJunctionGraphCubit()..loadRoutes(),
      child: Scaffold(
        appBar: const CaminoNinjaAppBar(
          title: 'Route Junction Graph',
        ),
        body: BlocBuilder<RouteJunctionGraphCubit,
            RouteJunctionGraphState>(
          builder: (context, state) {
            if (state.status ==
                    RouteJunctionGraphStatus.loading &&
                state.routes.isEmpty) {
              return const Center(child: LoadingWidget());
            }
            if (state.status ==
                RouteJunctionGraphStatus.failure) {
              return const Center(
                child: Text('Failed to load data'),
              );
            }
            return _Body(state: state);
          },
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final RouteJunctionGraphState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _RouteDropdown(
          routes: state.routes,
          selectedRouteId: state.selectedRouteId,
        ),
        if (state.selectedRouteId == null)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('Select a route to start exploring'),
            ),
          )
        else ...[
          // Render each path segment + resolved junction.
          for (var i = 0; i < state.path.length; i++) ...[
            _SegmentHeader(segment: state.path[i]),
            _CityList(segment: state.path[i]),
            // Show resolved junction after this segment
            // (if one exists).
            if (i < state.resolvedJunctions.length)
              _ResolvedJunctionCard(
                resolved: state.resolvedJunctions[i],
                onGoBack: () => context
                    .read<RouteJunctionGraphCubit>()
                    .goBack(),
              ),
          ],

          // Loading indicator while computing next segment.
          if (state.status ==
              RouteJunctionGraphStatus.loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingWidget()),
            ),

          // Pending junction choice.
          if (state.pendingJunction != null)
            _JunctionCard(junction: state.pendingJunction!),

          // Route complete.
          if (state.isComplete)
            const _RouteEndCard(),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
// Route dropdown
// ──────────────────────────────────────────────────────────

class _RouteDropdown extends StatelessWidget {
  const _RouteDropdown({
    required this.routes,
    required this.selectedRouteId,
  });

  final List<RouteEntity> routes;
  final int? selectedRouteId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: DropdownButtonFormField<int>(
        initialValue: selectedRouteId,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Starting Route',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        items: routes
            .map(
              (r) => DropdownMenuItem<int>(
                value: r.id,
                child: Text(
                  r.routeSubName != null
                      ? '${r.routeName} (${r.routeSubName})'
                      : r.routeName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: (routeId) {
          if (routeId != null) {
            context
                .read<RouteJunctionGraphCubit>()
                .selectRoute(routeId);
          }
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Segment header — route name with colored indicator
// ──────────────────────────────────────────────────────────

class _SegmentHeader extends StatelessWidget {
  const _SegmentHeader({required this.segment});

  final PathSegment segment;

  @override
  Widget build(BuildContext context) {
    final label = segment.routeSubName != null
        ? '${segment.routeName} (${segment.routeSubName})'
        : segment.routeName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: segment.routeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: segment.routeColor,
              ),
            ),
          ),
          Text(
            '${segment.cities.length} cities',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// City list — compact vertical list with route-colored line
// ──────────────────────────────────────────────────────────

class _CityList extends StatefulWidget {
  const _CityList({required this.segment});

  final PathSegment segment;

  @override
  State<_CityList> createState() => _CityListState();
}

class _CityListState extends State<_CityList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cities = widget.segment.cities;
    final color = widget.segment.routeColor;
    final middleCount = cities.length - 2;
    // Collapsible only when there are cities between
    // the first and last.
    final collapsible = middleCount > 0;

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vertical route-colored line.
            SizedBox(
              width: 20,
              child: Center(
                child: Container(
                  width: 3,
                  color: color.withValues(alpha: 0.4),
                ),
              ),
            ),
            // City names.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // First city — always visible.
                  if (cities.isNotEmpty)
                    _CityTile(
                      city: cities.first,
                      color: color,
                      isLast: cities.length == 1,
                    ),

                  // Middle cities — collapsible.
                  if (collapsible && !_expanded)
                    _CollapsedMiddle(
                      count: middleCount,
                      color: color,
                      onTap: () => setState(() => _expanded = true),
                    )
                  else if (collapsible) ...[
                    for (final city in cities.sublist(
                      1,
                      cities.length - 1,
                    ))
                      _CityTile(
                        city: city,
                        color: color,
                        isLast: false,
                      ),
                    _CollapseTrigger(
                      color: color,
                      onTap: () =>
                          setState(() => _expanded = false),
                    ),
                  ],

                  // Last city — always visible (junction point).
                  if (cities.length >= 2)
                    _CityTile(
                      city: cities.last,
                      color: color,
                      isLast: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedMiddle extends StatelessWidget {
  const _CollapsedMiddle({
    required this.count,
    required this.color,
    required this.onTap,
  });

  final int count;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // Dots icon
            Icon(
              Icons.more_vert,
              size: 16,
              color: color.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '$count cities',
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapseTrigger extends StatelessWidget {
  const _CollapseTrigger({
    required this.color,
    required this.onTap,
  });

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.expand_less,
              size: 16,
              color: color.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              'Collapse',
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.city,
    required this.color,
    required this.isLast,
  });

  final CityEntity city;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLast ? color : color.withValues(alpha: 0.5),
              border: isLast
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              city.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isLast ? FontWeight.w600 : FontWeight.normal,
                color: isLast
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Resolved junction — shows past choice with back button
// ──────────────────────────────────────────────────────────

class _ResolvedJunctionCard extends StatelessWidget {
  const _ResolvedJunctionCard({
    required this.resolved,
    required this.onGoBack,
  });

  final ResolvedJunction resolved;
  final VoidCallback onGoBack;

  @override
  Widget build(BuildContext context) {
    final chosen = resolved.chosenBranch;
    final label = chosen.routeSubName != null
        ? '${chosen.routeName} (${chosen.routeSubName})'
        : chosen.routeName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(
                Icons.fork_right,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Junction at '
                      '${resolved.junction.junctionCity.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: chosen.routeColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            chosen.isContinuation
                                ? 'Continued: $label'
                                : 'Switched to: $label',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: chosen.routeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.undo, size: 18),
                tooltip: 'Go back',
                onPressed: onGoBack,
                visualDensity: VisualDensity.compact,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Junction choice card
// ──────────────────────────────────────────────────────────

class _JunctionCard extends StatelessWidget {
  const _JunctionCard({required this.junction});

  final JunctionChoice junction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fork_right,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Junction at ${junction.junctionCity.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Choose your path:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              for (final branch in junction.branches)
                _BranchButton(branch: branch),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchButton extends StatelessWidget {
  const _BranchButton({required this.branch});

  final BranchOption branch;

  @override
  Widget build(BuildContext context) {
    final label = branch.routeSubName != null
        ? '${branch.routeName} (${branch.routeSubName})'
        : branch.routeName;

    final subtitle = branch.isContinuation
        ? '${branch.citiesAhead} cities ahead'
        : 'Switch route';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: branch.routeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            context
                .read<RouteJunctionGraphCubit>()
                .chooseBranch(branch);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: branch.routeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.isContinuation
                            ? 'Continue: $label'
                            : label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: branch.routeColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: branch.routeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Route end indicator
// ──────────────────────────────────────────────────────────

class _RouteEndCard extends StatelessWidget {
  const _RouteEndCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 0,
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flag, size: 20),
              SizedBox(width: 8),
              Text(
                'End of route — no more junctions',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
