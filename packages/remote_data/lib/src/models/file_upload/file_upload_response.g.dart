// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_upload_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileUploadResponse _$FileUploadResponseFromJson(Map<String, dynamic> json) =>
    FileUploadResponse(
      data:
          FileUploadResponseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FileUploadResponseToJson(FileUploadResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

FileUploadResponseData _$FileUploadResponseDataFromJson(
        Map<String, dynamic> json) =>
    FileUploadResponseData(
      id: json['id'] as String,
      fileNameDisk: json['filename_disk'] as String,
      fileNameDownload: json['filename_download'] as String,
    );

Map<String, dynamic> _$FileUploadResponseDataToJson(
        FileUploadResponseData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'filename_disk': instance.fileNameDisk,
      'filename_download': instance.fileNameDownload,
    };
