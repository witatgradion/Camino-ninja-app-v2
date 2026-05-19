part of 'announcement_detail_cubit.dart';

enum AnnouncementDetailStatus { initial, loading, success, failure }

class AnnouncementDetailState extends Equatable {
  const AnnouncementDetailState({
    this.status = AnnouncementDetailStatus.initial,
    this.announcement,
  });

  final AnnouncementDetailStatus status;
  final AnnouncementResponse? announcement;

  AnnouncementDetailState copyWith({
    AnnouncementDetailStatus? status,
    AnnouncementResponse? announcement,
  }) {
    return AnnouncementDetailState(
      status: status ?? this.status,
      announcement: announcement ?? this.announcement,
    );
  }

  @override
  List<Object?> get props => [status, announcement];
}
