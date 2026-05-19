part of 'saved_accommodations_cubit.dart';

class SavedAccommodationsState extends Equatable {
  const SavedAccommodationsState({
    this.albergues,
    this.filteredAlbergues,
    this.searchQuery = '',
  });

  final List<AlbergueEntity>? albergues;
  final List<AlbergueEntity>? filteredAlbergues;
  final String searchQuery;

  SavedAccommodationsState copyWith({
    List<AlbergueEntity>? albergues,
    List<AlbergueEntity>? filteredAlbergues,
    String? searchQuery,
  }) {
    return SavedAccommodationsState(
      albergues: albergues ?? this.albergues,
      filteredAlbergues: filteredAlbergues ?? this.filteredAlbergues,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [albergues, filteredAlbergues, searchQuery];
}
