import 'dart:typed_data';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';

import 'aws_manager.dart';

class FilesDataModel {
  String? name;
  String? tempId;
  int? size;
  String? url;
  Uint8List? bytes;
  RxBool? isUploaded = false.obs;
  RxBool? canCompress = true.obs;
  String? thumbnail;
  String? extension;
  String? path;
  String? uploadedDate;
  String? uploadedBy;
  Map<String, dynamic>? old;

  FilesDataModel({
    this.name,
    this.size,
    this.tempId,
    this.url,
    this.thumbnail,
    this.bytes,
    this.isUploaded,
    this.canCompress,
    this.extension,
    this.path,
    this.uploadedDate,
    this.uploadedBy,
    this.old,
  });

  FilesDataModel.fromJson(Map<String, dynamic>? json) {
    name = json?['name'];
    if (json?['bytes'] != null) {
      bytes = Uint8List.fromList(List<int>.from(json?['bytes']));
    }
    tempId = json?['tempId'];
    size = json?['size'];
    url = (json ?? {})['url'].toString().isNotNullOrEmpty ? '${AwsManager.s3Endpoint}${json?['url'].toString().replaceAll(AwsManager.s3Endpoint, '')}' : json?['url'];
    thumbnail = json?['thumbnail'] ?? '';
    extension = json?['extension'];
    path = json?['path'];
    uploadedDate = json?['uploadeddate'];
    uploadedBy = json?['uploadedby'];
    old = json?['old'] == null ? null : Map<String, dynamic>.from(json?['old'] ?? {});
    isUploaded?.value = json?['isUploaded'] ?? false;
    canCompress?.value = json?['canCompress'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name ?? '';
    data['size'] = size ?? 0;
    data['bytes'] = bytes;
    data['tempId'] = tempId ?? '';
    data['url'] = (url ?? '').replaceAll(AwsManager.s3Endpoint, '');
    data['thumbnail'] = thumbnail ?? '';
    data['extension'] = extension ?? '';
    data['path'] = path ?? '';
    data['uploadeddate'] = uploadedDate ?? '';
    data['uploadedby'] = uploadedBy ?? '';
    data['isUploaded'] = isUploaded?.value;
    data['canCompress'] = canCompress?.value;
    data['old'] = old;
    return data;
  }

  List<FilesDataModel> fromJsonList(List<Map<String, dynamic>> json) {
    return List<FilesDataModel>.from(json.map((e) => FilesDataModel.fromJson(e)).toList());
  }

  List<Map<String, dynamic>> toJsonList(List<FilesDataModel> json) {
    return json.map((e) => e.toJson()).toList();
  }
}
