part of 'in_app_review_cubit.dart';

class InAppReviewState extends Equatable {
  const InAppReviewState({
    this.doNotAskAgain = false,
    this.showTimes = 0,
  });

  final bool doNotAskAgain;
  final int showTimes;

  @override
  List<Object?> get props => [doNotAskAgain, showTimes];

  InAppReviewState copyWith({
    bool? doNotAskAgain,
    int? showTimes,
  }) {
    return InAppReviewState(
      doNotAskAgain: doNotAskAgain ?? this.doNotAskAgain,
      showTimes: showTimes ?? this.showTimes,
    );
  }
}
