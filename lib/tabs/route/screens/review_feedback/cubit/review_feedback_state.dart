part of 'review_feedback_cubit.dart';

enum SubmitReviewFeedbackStatus {
  initial,
  submitting,
  submitted,
  error,
}

class ReviewFeedbackState extends Equatable {
  const ReviewFeedbackState({
    this.albergueId,
    this.cityId,
    this.attachments,
    this.name,
    this.email,
    this.feedback = '',
    this.address = '',
    this.rating = 0,
    this.error,
    this.isFeedbackEmpty = false,
    this.isAddressEmpty = false,
    this.isNameEmpty = false,
    this.ratingInvalid = false,
    this.isEmailInvalid = false,
    this.type = ReviewFeedbackType.reviewAlbergue,
    this.submitStatus = SubmitReviewFeedbackStatus.initial,
    this.isLoggedIn = false,
    this.includeDbDump = false,
  });

  final int? albergueId;
  final int? cityId;
  final List<File>? attachments;
  final String? name;
  final String? email;
  final String address;
  final String feedback;
  final double rating;
  final String? error;
  final bool isFeedbackEmpty;
  final bool isAddressEmpty;
  final bool isNameEmpty;
  final bool isEmailInvalid;
  final bool ratingInvalid;
  final bool isLoggedIn;
  final ReviewFeedbackType type;
  final SubmitReviewFeedbackStatus submitStatus;

  /// Whether the bug-report flow should attach the in-app DB
  /// export. Defaults to `false` — the user must explicitly opt
  /// in via the checkbox. Only meaningful for bug-report types
  /// (see [ReviewFeedbackType.showIncludeDbDump]).
  final bool includeDbDump;

  ReviewFeedbackState copyWith({
    ReviewFeedbackType? type,
    SubmitReviewFeedbackStatus? submitStatus,
    int? albergueId,
    int? cityId,
    List<File>? attachments,
    String? name,
    String? email,
    String? feedback,
    String? address,
    double? rating,
    String? error,
    bool? isFeedbackEmpty,
    bool? ratingInvalid,
    bool? isEmailInvalid,
    bool? isAddressEmpty,
    bool? isNameEmpty,
    bool? isLoggedIn,
    bool? includeDbDump,
  }) {
    return ReviewFeedbackState(
      type: type ?? this.type,
      albergueId: albergueId ?? this.albergueId,
      cityId: cityId ?? this.cityId,
      attachments: attachments ?? this.attachments,
      name: name ?? this.name,
      email: email ?? this.email,
      feedback: feedback ?? this.feedback,
      rating: rating ?? this.rating,
      submitStatus: submitStatus ?? this.submitStatus,
      error: error,
      isFeedbackEmpty: isFeedbackEmpty ?? this.isFeedbackEmpty,
      ratingInvalid: ratingInvalid ?? this.ratingInvalid,
      isEmailInvalid: isEmailInvalid ?? this.isEmailInvalid,
      isAddressEmpty: isAddressEmpty ?? this.isAddressEmpty,
      isNameEmpty: isNameEmpty ?? this.isNameEmpty,
      address: address ?? this.address,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      includeDbDump: includeDbDump ?? this.includeDbDump,
    );
  }

  @override
  List<Object?> get props => [
        type,
        albergueId,
        cityId,
        attachments,
        name,
        email,
        feedback,
        rating,
        address,
        submitStatus,
        error,
        isFeedbackEmpty,
        ratingInvalid,
        isEmailInvalid,
        isAddressEmpty,
        isNameEmpty,
        isLoggedIn,
        includeDbDump,
      ];
}
