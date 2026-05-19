part of 'announcements_cubit.dart';

enum AnnouncementsStatus { initial, loading, success, failure }

class AnnouncementsState extends Equatable {
  const AnnouncementsState({
    this.status = AnnouncementsStatus.initial,
    this.announcements = const [],
    this.readAnnouncementIds = const {},
    this.unreadCount = 0,
  });

  final AnnouncementsStatus status;
  final List<AnnouncementResponse> announcements;
  final Set<int> readAnnouncementIds;
  final int unreadCount;

  AnnouncementsState copyWith({
    AnnouncementsStatus? status,
    List<AnnouncementResponse>? announcements,
    Set<int>? readAnnouncementIds,
    int? unreadCount,
  }) {
    return AnnouncementsState(
      status: status ?? this.status,
      announcements: announcements ?? this.announcements,
      readAnnouncementIds:
          readAnnouncementIds ?? this.readAnnouncementIds,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props =>
      [status, announcements, readAnnouncementIds, unreadCount];
}
