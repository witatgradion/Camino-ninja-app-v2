part of 'my_reviews_cubit.dart';

enum LoadMyReviewsStatus {
  initial,
  loading,
  loaded,
  error,
}

enum MyReviewsTabMode {
  approved,
  pending;

  String label(BuildContext context) => switch (this) {
        approved => AppLocalizations.of(context).approved,
        pending => AppLocalizations.of(context).pending,
      };
}

class MyReviewsState extends Equatable {
  const MyReviewsState({
    this.reviews = const [],
    this.loadMyReviewsStatus = LoadMyReviewsStatus.initial,
    this.tabMode = MyReviewsTabMode.approved,
  });

  final List<AlbergueReviewModel> reviews;
  final LoadMyReviewsStatus loadMyReviewsStatus;
  final MyReviewsTabMode tabMode;

  MyReviewsState copyWith({
    List<AlbergueReviewModel>? reviews,
    LoadMyReviewsStatus? loadMyReviewsStatus,
    MyReviewsTabMode? tabMode,
  }) {
    return MyReviewsState(
      reviews: reviews ?? this.reviews,
      loadMyReviewsStatus: loadMyReviewsStatus ?? this.loadMyReviewsStatus,
      tabMode: tabMode ?? this.tabMode,
    );
  }

  @override
  List<Object?> get props => [reviews, loadMyReviewsStatus, tabMode];
}
