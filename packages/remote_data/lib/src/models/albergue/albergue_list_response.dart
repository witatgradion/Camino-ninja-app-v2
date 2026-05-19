import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:remote_data/src/models/albergue/albergue_response.dart';

part 'albergue_list_response.g.dart';

@JsonSerializable()
class AlbergueListResponse extends Equatable {

  const AlbergueListResponse({
    required this.data,
  });

  factory AlbergueListResponse.fromJson(Map<String, dynamic> json) =>
      _$AlbergueListResponseFromJson(json);
  final List<AlbergueResponse> data;

  Map<String, dynamic> toJson() => _$AlbergueListResponseToJson(this);

  @override
  List<Object> get props => [data];
}
