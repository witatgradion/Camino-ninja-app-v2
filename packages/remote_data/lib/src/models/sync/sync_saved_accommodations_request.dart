import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_saved_accommodations_request.g.dart';

@JsonSerializable()
class SyncSavedAccommodationsRequest extends Equatable {
  const SyncSavedAccommodationsRequest({
    required this.items,
  });

  factory SyncSavedAccommodationsRequest.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SyncSavedAccommodationsRequestFromJson(json);

  final List<SyncSavedAccommodationItem> items;

  Map<String, dynamic> toJson() =>
      _$SyncSavedAccommodationsRequestToJson(this);

  @override
  List<Object?> get props => [items];
}

@JsonSerializable()
class SyncSavedAccommodationItem extends Equatable {
  const SyncSavedAccommodationItem({
    required this.albergueId,
    required this.updatedAt,
    this.deletedAt,
  });

  factory SyncSavedAccommodationItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SyncSavedAccommodationItemFromJson(json);

  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;

  Map<String, dynamic> toJson() =>
      _$SyncSavedAccommodationItemToJson(this);

  @override
  List<Object?> get props => [albergueId, updatedAt, deletedAt];
}
