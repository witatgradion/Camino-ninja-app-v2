import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';

import 'package:camino_ninja_flutter/tabs/route/screens/favorite_button/cubit/favorite_cubit.dart';
import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:storage/storage.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    required this.albergue,
    required this.cityId,
    required this.routeId,
    this.isLarge = false,
    this.onFavoriteChanged,
    super.key,
  });

  final bool isLarge;
  final AlbergueEntity albergue;
  final int cityId;
  final int routeId;
  final ValueChanged<bool>? onFavoriteChanged;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final GlobalKey _iconKey = GlobalKey();
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Trigger loading on first init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureFavoriteStatusLoaded();
    });
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getIconPosition() {
    final renderBox = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(
        Offset(
          renderBox.size.width / 2,
          renderBox.size.height / 2,
        ),
      );
    }
    return Offset.zero;
  }

  void _ensureFavoriteStatusLoaded() {
    final cubit = context.read<FavoritesCubit>();
    final state = cubit.state;

    if (!state.favorites.containsKey(widget.albergue.id) &&
        !state.loading.contains(widget.albergue.id) &&
        !state.errors.containsKey(widget.albergue.id) &&
        !_hasInitialized) {
      _hasInitialized = true;
      cubit.loadFavoriteStatus(
        widget.albergue.id,
        widget.cityId,
        widget.routeId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        // Ensure favorite status is loaded
        if (!_hasInitialized) {
          _ensureFavoriteStatusLoaded();
        }

        return _buildFavoriteButton(context, state);
      },
    );
  }

  Widget _buildFavoriteButton(BuildContext context, FavoritesState state) {
    final isDarkMode = context.isDarkMode;

    // Check if we're loading or don't have data yet
    final isLoading = state.loading.contains(widget.albergue.id);
    final hasData = state.favorites.containsKey(widget.albergue.id);

    // Show loading indicator
    if (isLoading || !hasData) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 1),
      );
    }

    // Show favorite button (only when we have data and not loading)
    final isFavorite = state.favorites[widget.albergue.id] ?? false;

    if (widget.isLarge) {
      return SizedBox(
        height: 36,
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                  color:
                      isDarkMode ? AppColors.primary80 : AppColors.primary40,),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () {
                // Only allow tap if we have valid data and not loading
                if (hasData && !isLoading) {
                  if (!isFavorite) {
                    _controller.forward().then((_) => _controller.reverse());
                  }
                  context.read<FavoritesCubit>().toggleFavorite(
                        albergueId: widget.albergue.id,
                        cityId: widget.cityId,
                        routeId: widget.routeId,
                        favoriteOffset: _getIconPosition(),
                      );
                  widget.onFavoriteChanged?.call(!isFavorite);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      key: _iconKey,
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: child,
                        );
                      },
                      child: SvgPicture.asset(
                        key: ValueKey(isFavorite),
                        isFavorite
                            ? 'assets/ic_bookmark_filled.svg'
                            : 'assets/ic_bookmark_outline.svg',
                        color: isDarkMode
                            ? AppColors.primary80
                            : AppColors.primary40,
                        width: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppLocalizations.of(context).save,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? AppColors.primary80
                                : AppColors.primary40,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: _iconKey,
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Only allow tap if we have valid data and not loading
          if (hasData && !isLoading) {
            if (!isFavorite) {
              _controller.forward().then((_) => _controller.reverse());
            }
            context.read<FavoritesCubit>().toggleFavorite(
                  albergueId: widget.albergue.id,
                  cityId: widget.cityId,
                  routeId: widget.routeId,
                  favoriteOffset: _getIconPosition(),
                );
            widget.onFavoriteChanged?.call(!isFavorite);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          child: SvgPicture.asset(
            isFavorite
                ? 'assets/ic_bookmark_filled.svg'
                : 'assets/ic_bookmark_outline.svg',
            color: isDarkMode ? AppColors.primary80 : AppColors.primary40,
            width: 28,
          ),
        ),
      ),
    );
  }
}
