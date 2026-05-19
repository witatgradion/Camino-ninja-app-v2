import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_saved_accommodations_response.g.dart';

@JsonSerializable()
class SyncSavedAccommodationsResponse extends Equatable {
  const SyncSavedAccommodationsResponse({
    required this.items,
  });

  factory SyncSavedAccommodationsResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SyncSavedAccommodationsResponseFromJson(json);

  final List<SyncSavedAccommodationResponseItem> items;

  Map<String, dynamic> toJson() =>
      _$SyncSavedAccommodationsResponseToJson(this);

  @override
  List<Object?> get props => [items];
}

@JsonSerializable()
class SyncSavedAccommodationResponseItem extends Equatable {
  const SyncSavedAccommodationResponseItem({
    required this.albergueId,
    required this.updatedAt,
  });

  factory SyncSavedAccommodationResponseItem.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$SyncSavedAccommodationResponseItemFromJson(json);

  @JsonKey(name: 'albergue_id')
  final int albergueId;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  Map<String, dynamic> toJson() =>
      _$SyncSavedAccommodationResponseItemToJson(this);

  @override
  List<Object?> get props => [albergueId, updatedAt];
}
