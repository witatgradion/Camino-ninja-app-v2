part of 'favorite_cubit.dart';

class FavoritesState extends Equatable {
  const FavoritesState({
    this.favorites = const {},
    this.loading = const {},
    this.errors = const {},
    this.latestFlyingOffset,
  });

  final Map<int, bool> favorites; // albergueId -> isFavorite
  final Set<int> loading; // albergueIds currently loading
  final Map<int, String> errors; // albergueId -> error message
  final Offset? latestFlyingOffset;

  FavoritesState copyWith({
    Map<int, bool>? favorites,
    Set<int>? loading,
    Map<int, String>? errors,
    Offset? latestFlyingOffset,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      loading: loading ?? this.loading,
      errors: errors ?? this.errors,
      latestFlyingOffset: latestFlyingOffset,
    );
  }

  @override
  List<Object?> get props => [favorites, loading, errors, latestFlyingOffset];
}
