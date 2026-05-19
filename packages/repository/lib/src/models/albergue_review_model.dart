import 'package:equatable/equatable.dart';
import 'package:storage/storage.dart';

class AlbergueReviewListModel extends Equatable {
  const AlbergueReviewListModel({
    this.total,
    this.albergueUserReviews,
  });

  final int? total;
  final List<AlbergueReviewModel>? albergueUserReviews;

  @override
  List<Object?> get props => [total, albergueUserReviews];
}

class AlbergueReviewModel extends Equatable {
  const AlbergueReviewModel({
    this.id,
    this.albergueId,
    this.name,
    this.email,
    this.userComment,
    this.userRating,
    this.createdAt,
    this.updatedAt,
    this.images,
    this.translatedComment,
    this.displayLang,
    this.sourceLang,
    this.isTranslated,
    this.status,
    this.albergue,
  });

  final int? id;
  final int? albergueId;
  final String? name;
  final String? email;
  final String? userComment;
  final int? userRating;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<AlbergueImageReviewModel>? images;
  final String? translatedComment;
  final String? displayLang;
  final String? sourceLang;
  final bool? isTranslated;
  final bool? status;
  final AlbergueEntity? albergue;

  AlbergueReviewModel copyWith({
    AlbergueEntity? albergue,
    int? id,
    int? albergueId,
    String? name,
    String? email,
    String? userComment,
    int? userRating,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AlbergueImageReviewModel>? images,
    String? translatedComment,
    String? displayLang,
    String? sourceLang,
    bool? isTranslated,
    bool? status,
  }) {
    return AlbergueReviewModel(
      id: id ?? this.id,
      albergueId: albergueId ?? this.albergueId,
      name: name ?? this.name,
      email: email ?? this.email,
      userComment: userComment ?? this.userComment,
      userRating: userRating ?? this.userRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      translatedComment: translatedComment ?? this.translatedComment,
      displayLang: displayLang ?? this.displayLang,
      sourceLang: sourceLang ?? this.sourceLang,
      isTranslated: isTranslated ?? this.isTranslated,
      status: status ?? this.status,
      albergue: albergue ?? this.albergue,
    );
  }

  @override
  List<Object?> get props => [
        id,
        albergueId,
        name,
        email,
        userComment,
        userRating,
        createdAt,
        updatedAt,
        images,
        translatedComment,
        displayLang,
        sourceLang,
        isTranslated,
        status,
        albergue,
      ];
}

class AlbergueImageReviewModel extends Equatable {
  const AlbergueImageReviewModel({
    this.id,
    this.albergueUserReviewsId,
    this.fileKey,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? albergueUserReviewsId;
  final String? fileKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props =>
      [id, albergueUserReviewsId, fileKey, createdAt, updatedAt];
}
