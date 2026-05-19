import 'package:json_annotation/json_annotation.dart';

part 'file_upload_response.g.dart';

@JsonSerializable()
class FileUploadResponse {
  FileUploadResponse({
    required this.data,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseFromJson(json);

  final FileUploadResponseData data;

  Map<String, dynamic> toJson() => _$FileUploadResponseToJson(this);
}

@JsonSerializable()
class FileUploadResponseData {
  FileUploadResponseData({
    required this.id,
    required this.fileNameDisk,
    required this.fileNameDownload,
  });

  factory FileUploadResponseData.fromJson(Map<String, dynamic> json) =>
      _$FileUploadResponseDataFromJson(json);

  final String id;
  @JsonKey(name: 'filename_disk')
  final String fileNameDisk;
  @JsonKey(name: 'filename_download')
  final String fileNameDownload;

  Map<String, dynamic> toJson() => _$FileUploadResponseDataToJson(this);
}
