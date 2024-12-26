import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as pw;
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/helper/offline_data.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/models/Menu/menu_model.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';

import '../components/customs/custom_button.dart';
import '../components/customs/custom_drag_file_area.dart';
import '../style/theme_const.dart';
import '../utils/aws_service/aws_manager.dart';
import '../utils/aws_service/file_data_model.dart';
import '../view/CommonWidgets/common_table.dart';
import 'api_constant.dart';
import 'api_provider.dart';
import 'config.dart';
// import 'dart:html' as html;

var inputTextRegx = FilteringTextInputFormatter.deny(RegExp("[+.,;:!#\$%^&*=_/<>?~]"));
var inputTextEmailRegx = FilteringTextInputFormatter.allow(RegExp(r"[a-zA-z0-9.@]"));

const pageLimit = [
  {
    "label": 5,
    "value": 5,
  },
  {
    "label": 10,
    "value": 10,
  },
  {
    "label": 20,
    "value": 20,
  },
  {
    "label": 50,
    "value": 50,
  },
  {
    "label": 100,
    "value": 100,
  },
  {
    "label": 500,
    "value": 500,
  },
  {
    "label": 1000,
    "value": 1000,
  }
];

class IISMethods {
  UserRight? getPageRights({required String alias}) {
    List<UserRight>? rights = Settings.loginData.userrights;
    if (rights != null) {
      for (UserRight element in rights) {
        if (element.alias == alias) return element;
      }
    }
    return null;
  }

  bool hasAddRight({required String alias}) {
    List<UserRight>? rights = Settings.loginData.userrights;
    if (rights != null) {
      for (UserRight element in rights) {
        devPrint(element.alias);
        if (element.alias == alias) {
          return element.selfaddright == 1 || element.alladdright == 1;
        }
      }
    }
    return false;
  }

  bool hasImportExportRight({required String alias}) {
    List<UserRight>? rights = Settings.loginData.userrights;
    if (rights != null) {
      for (UserRight element in rights) {
        if (element.alias == alias) {
          return element.allimportdata == 1 || element.allexportdata == 1;
        }
      }
    }
    return false;
  }

  bool hasImportRight({required String alias}) {
    List<UserRight>? rights = Settings.loginData.userrights;
    if (rights != null) {
      for (UserRight element in rights) {
        if (element.alias == alias) {
          return element.allimportdata == 1;
        }
      }
    }
    return false;
  }

  bool hasExportRight({required String alias}) {
    List<UserRight>? rights = Settings.loginData.userrights;
    if (rights != null) {
      for (UserRight element in rights) {
        if (element.alias == alias) {
          return element.allexportdata == 1;
        }
      }
    }
    return false;
  }

  getObjectFromArray(arr, key, value) async {
    try {
      var firstObj = List.from(arr ?? []).firstWhere(
        (element) => element[key] == value,
        orElse: () {
          return {};
        },
      );
      return firstObj.isEmpty ? null : IISMethods().encryptDecryptObj(firstObj);
    } catch (e) {
      devPrint('ERROR-->$e');
      return null;
    }
  }

  encryptDecryptObj(obj) {
    if (obj == null) return obj;
    return jsonDecode(jsonEncode(obj));
  }

  getCopy(element) {
    // arrange json for form
    try {
      if (element is List<dynamic>) {
        return (element).map((o) => Map<String, dynamic>.from(o)).toList();
      } else {
        return Map<String, dynamic>.from(element ?? {});
      }
    } catch (e) {
      debugPrint(e.toString());
      return Map<String, dynamic>.from(element ?? {});
    }
  }

  decimalPointRgex(int? decimalPoint) {
    switch (decimalPoint) {
      case 2:
        return FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,2})'));
      case 3:
        return FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,3})'));
      case 4:
        return FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,4})'));
      case 5:
        return FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,5})'));
      case 6:
        return FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,6})'));
      case 8:
        return FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d{0,8})'));
      default:
        return FilteringTextInputFormatter.digitsOnly;
    }
  }

  checkFiletype({file, allowedFiles}) async {
    try {
      var fileName = await getFileName(file);
      List checkExt = allowedFiles.map((e) => fileName.contains(e)).toList();
      if (checkExt.contains(true)) {
        return true;
      } else {
        return false;
      }
// var fileExtension = await getFileExtention(fileName);
// var regex = RegExp("${"([a-zA-Z0-9\s_\\.\-:])+(" + allowedFiles.join('|')})\$");
// return !regex.hasMatch(fileExtension.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  getFileName(files) async {
    String filename = '';
    try {
      if (files is String) {
        return files;
      }
      files.files.forEach((file) {
        if (file is String) {
          filename = file.substring(file.lastIndexOf('/'), file.length);
        } else {
          filename = file.name;
        }
      });
    } catch (e) {
      devPrint(e);
    }

    return filename;
  }

  Future<List<FilesDataModel>> uploadFiles(List<FilesDataModel> uploadedFile) async {
    if (!isoffline.value) {
      for (var i = 0; i < uploadedFile.length; i++) {
        try {
          if (!(uploadedFile[i].isUploaded?.value == true) && uploadedFile[i].url.isNullOrEmpty) {
            // if (uploadedFile[i].bytes.isNullOrEmpty) {
            //   continue;
            // }
            Map<String, dynamic> fileStatus = await AwsManager().uploadChatMedia(uploadedFile[i]);
            // devPrint(uploadedFile[i].toJson());
            // devPrint(fileStatus);
            FilesDataModel filesDataModel = FilesDataModel.fromJson(fileStatus);
            int index = uploadedFile.indexWhere((element) => element.tempId == filesDataModel.tempId);
            if (filesDataModel.url != null) {
              uploadedFile[index] = filesDataModel;
            } else {
              uploadedFile.removeAt(i);
            }
          }
        } catch (e) {
          devPrint(e);
        }
      }
    }
    return uploadedFile;
  }

  getIndexFromArray(arr, key, value) {
    try {
      return arr.indexWhere((element) => element[key] == value);
    } catch (e) {
      return -1;
    }
  }

  Future<FilesDataModel> compressImage(FilesDataModel file) async {
    Uint8List? bytes = file.bytes;
    String? path = file.path;
    String? newPath;
    String? fileType = (file.extension ?? '').toLowerCase();
    if (!(file.canCompress?.value ?? true)) {
      return file;
    }

    try {
      if (fileType == 'jpg' || fileType == 'png' || fileType == 'jpeg' || fileType == 'webp' || fileType == 'gif') {
        if (kIsWeb) {
          // Compress the image
          Uint8List new1 = await compressImageForWeb(bytes!);
          int i = 1;
          while (bytes.length > 500000 && i < 3) {
            new1 = await compressImageForWeb(new1);
            i++;
          }

          devPrint('Input size = ${bytes.length}');
          devPrint('Output size = ${new1.length}');
          file.path = newPath;
          file.bytes = new1;
        } else if (path != null) {
          newPath = await compressAndGetFilePath(path);
          file.path = newPath;
          file.bytes = await File(newPath).readAsBytes();
        }
      }
    } catch (e) {
      devPrint(e.toString());
    }

    return file;
  }

  Future<Uint8List> compressImageForWeb(Uint8List imageFile) async {
    Uint8List compressedImage = await FlutterImageCompress.compressWithList(
      imageFile,
      quality: 50,
    ).onError((error, stackTrace) {
      devPrint(error.toString());
      return imageFile;
    });
    return compressedImage;
  }

  Future<String> compressAndGetFilePath(String filepath) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/compressed_image${DateTime.now().toString()}.jpg';
    File compressedImageFile = File(tempFilePath);
    int i = 1;
    do {
      final compressedImageBytes = await FlutterImageCompress.compressWithFile(
        i == 1 ? filepath : tempFilePath,
        quality: 10,
      );
      await compressedImageFile.writeAsBytes(compressedImageBytes as List<int>);
      i++;
    } while (await compressedImageFile.length() > 500000 && i < 3);
    devPrint("${await File(compressedImageFile.path).length()}   1231231232222");
    devPrint("${await File(filepath).length()}   1231231232222");
    return compressedImageFile.path;
  }

  Future<String> compressAndGetFilePathForWeb(String filepath) async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = '${tempDir.path}/compressed_image${DateTime.now().toString()}.jpg';
    File compressedImageFile = File(tempFilePath);
    int i = 1;
    do {
      final compressedImageBytes = await FlutterImageCompress.compressWithFile(
        i == 1 ? filepath : tempFilePath,
        quality: 10,
      );
      await compressedImageFile.writeAsBytes(compressedImageBytes as List<int>);
      i++;
    } while (await compressedImageFile.length() > 500000 && i < 3);
    devPrint("${await File(compressedImageFile.path).length()}   1231231232222");
    devPrint("${await File(filepath).length()}   1231231232222");
    return compressedImageFile.path;
  }

  Future<List<FilesDataModel>> pickSingleFile({List? fileType, bool canCompress = true}) async {
    List<FilesDataModel> fileModelList = [];
    int pickType = -1;

    if (!kIsWeb && fileType != null && (fileType.contains("jpg") || fileType.contains("jpeg") || fileType.contains('png'))) {
      await Get.bottomSheet(CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
          child: const TextWidget(
            text: 'Cancel',
          ),
          onPressed: () {
            pickType = 0;
            Get.back();
          },
        ),
        actions: [
          CupertinoActionSheetAction(
            child: const TextWidget(
              text: 'Camera',
            ),
            onPressed: () async {
              pickType = 1;
              Get.back();

              // pickImage(1);
            },
          ),
          CupertinoActionSheetAction(
            child: const TextWidget(
              text: 'Files',
            ),
            onPressed: () {
              pickType = 2;
              Get.back();
              // pickImage(2);
            },
          )
        ],
      ));
    } else {
      pickType = 2;
    }

    if (pickType == 0) {
      return fileModelList;
    } else if (pickType == 1) {
      // if(await Permission.camera.isDenied){
      //   Permission.
      // }
      final XFile? file = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (file?.path.isNullOrEmpty ?? true) {
        return fileModelList;
      }
      var uuid = const Uuid();

      fileModelList.add(await compressImage(FilesDataModel(
          name: 'Prenew -${DateTime.now().toIso8601String()}${const Uuid().v4()}',
          bytes: await file?.readAsBytes(),
          extension: file?.mimeType ?? file?.name.split('.').last,
          path: !kIsWeb ? file?.path : null,
          size: (await file?.readAsBytes())?.length,
          tempId: uuid.v4(),
          canCompress: canCompress.obs)));
    } else if (pickType == 2) {
      FilePickerResult? files = await FilePicker.platform.pickFiles(
        type: fileType != null ? FileType.custom : FileType.any,
        allowedExtensions: [...fileType ?? []],
      );
      for (PlatformFile file in (files?.files ?? [])) {
        var uuid = const Uuid();
        if (fileType.isNullOrEmpty || fileType!.contains(file.name.split('.').last)) {
          fileModelList.add(await compressImage(FilesDataModel(name: file.name, bytes: file.bytes, extension: file.extension, path: !kIsWeb ? file.path : null, size: file.size, tempId: uuid.v4(), canCompress: canCompress.obs)));
        } else {
          showError('Only ${fileType.join(', ')} Supported');
        }
      }
    }
    devPrint(fileModelList.first.toJson());
    return fileModelList;
  }

  Future<List<FilesDataModel>> pickMultipleFiles({List? fileType, bool canCompress = true}) async {
    List<FilesDataModel> fileModelList = [];
    int pickType = -1;

    if (!kIsWeb && fileType != null && (fileType.contains("jpg") || fileType.contains("jpeg") || fileType.contains('png'))) {
      await Get.bottomSheet(CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
          child: const TextWidget(
            text: 'Cancel',
          ),
          onPressed: () {
            pickType = 0;
            Get.back();
          },
        ),
        actions: [
          CupertinoActionSheetAction(
            child: const TextWidget(
              text: 'Camera',
            ),
            onPressed: () async {
              pickType = 1;
              Get.back();

              // pickImage(1);
            },
          ),
          CupertinoActionSheetAction(
            child: const TextWidget(
              text: 'Files',
            ),
            onPressed: () {
              pickType = 2;
              Get.back();
              // pickImage(2);
            },
          )
        ],
      ));
    } else {
      pickType = 2;
    }

    if (pickType == 0) {
      return fileModelList;
    } else if (pickType == 1) {
      final XFile? file = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      var uuid = const Uuid();
      if (file?.path.isNullOrEmpty ?? true) {
        return fileModelList;
      }
      fileModelList.add(await compressImage(FilesDataModel(
          name: 'Prenew -${DateTime.now().millisecondsSinceEpoch}',
          bytes: await file?.readAsBytes(),
          extension: file?.mimeType,
          path: !kIsWeb ? file?.path : null,
          size: (await file?.readAsBytes())?.length,
          tempId: uuid.v4(),
          canCompress: canCompress.obs)));
    } else if (pickType == 2) {
      FilePickerResult? files = await FilePicker.platform.pickFiles(
        type: fileType != null ? FileType.custom : FileType.any,
        allowedExtensions: [...fileType ?? []],
        allowMultiple: true,
      );
      for (PlatformFile file in (files?.files ?? [])) {
        var uuid = const Uuid();
        if (fileType.isNullOrEmpty || fileType!.contains(file.name.split('.').last)) {
          fileModelList.add(await compressImage(FilesDataModel(name: file.name, bytes: file.bytes, extension: file.extension, path: !kIsWeb ? file.path : null, size: file.size, tempId: uuid.v4(), canCompress: canCompress.obs)));
        } else {
          showError('Only ${fileType.join(', ')} Supported');
        }
      }
    }
    return fileModelList;
  }

  // Future<List<FilesDataModel>> pickMultipleFiles({List? fileType}) async {
  //   List<FilesDataModel> fileModelList = [];
  //   FilePickerResult? files = await FilePicker.platform.pickFiles(
  //     type: fileType != null ? FileType.custom : FileType.any,
  //     allowedExtensions: [...fileType ?? []],
  //     allowMultiple: true,
  //   );
  //   for (PlatformFile file in (files?.files ?? [])) {
  //     var uuid = const Uuid();
  //     fileModelList.add(FilesDataModel(
  //       name: file.name,
  //       bytes: file.bytes,
  //       extension: file.extension,
  //       path: !kIsWeb ? file.path : null,
  //       size: file.size,
  //       tempId: uuid.v4(),
  //     ));
  //   }
  //   return fileModelList;
  // }

  Future<void> saveFileFromBytes({required Uint8List file, required String filename}) async {
    var directory = await getDownloadsDirectory();
    if (Platform.isAndroid) {
      devPrint(directory?.path);
      // File savedFile = File('/storage/emulated/0/Download/Prenew/$pagename-${DateTime.now()}.xlsx');
      File savedFile = File('${directory?.path}/$filename-${DateTime.now()}.xlsx');
      await savedFile.writeAsBytes(file);
      // ..createSync(recursive: true)
      // ..writeAsBytesSync(fileBytes!);
      devPrint("=============> ${savedFile.path}");
      final String filePath = savedFile.absolute.path;
      OpenFile.open(savedFile.path);
    }
  }

//   Future<bool> checkSessionTimeOut() async {
//     if (kDebugMode) {
//       int logoutInMin = 30;
//       if (Settings.isUserLogin) {
//         final lastInteractionTime = Settings.logoutTime;
//         final currentTime = DateTime.now();
//         final idleDuration = currentTime.difference(lastInteractionTime);
// // devPrint('${Settings.logoutTime.toIso8601String()} ----> ${DateTime.now()} ---->$idleDuration');
//
//         if (idleDuration.inMinutes >= logoutInMin) {
//           devPrint('\n\nLOGOUT\n\n');
// // isSessionTimeOut.value = true;
//           return true;
//         }
//       }
//       return false;
//     } else {
//       int logoutInHours = 2;
//       if (Settings.isUserLogin) {
//         final lastInteractionTime = Settings.logoutTime;
//         final currentTime = DateTime.now();
//         final idleDuration = currentTime.difference(lastInteractionTime);
// // devPrint('${Settings.logoutTime.toIso8601String()} ----> ${DateTime.now()} ---->$idleDuration');
//
//         if (idleDuration.inHours >= logoutInHours) {
//           devPrint('\n\nLOGOUT\n\n');
// // isSessionTimeOut.value = true;
//           return true;
//         }
//       }
//       return false;
//     }
//   }

  // static String platform = "1";

  static String platform = kIsWeb
      ? "1" // Web
      : Platform.isAndroid
          ? "2"
          : "3"; // Android

  Map<String, String> defaultHeaders({
    required String userAction,
    required String pageName,
    bool? masterListing,
  }) {
    Map<String, String> headers = <String, String>{
      'issuer': HeaderConstant.issuer,
      'pagename': pageName,
      'platform': platform,
      'useraction': userAction,
      'version': '1',
    };
    if (masterListing != null) {
      headers['masterlisting'] = masterListing.toString();
    }
    if (Settings.authToken.isNotEmpty) {
      headers['token'] = Settings.authToken;
    }
    if (Settings.unqKey.isNotEmpty) {
      headers['unqkey'] = Settings.unqKey;
    }
    if (Settings.uid.isNotEmpty) {
      headers['uid'] = Settings.uid;
    }
    if (Settings.userRoleId.isNotEmpty) {
      headers['userroleid'] = Settings.userRoleId; // backend team need this for "Tenants Project" listing
    }
    if (Settings.userName.isNotEmpty) {
      headers['username'] = Settings.userName;
    }
    return headers;
  }

  Future listData({
    required String userAction,
    required String pageName,
    bool? masterlisting = false,
    required url,
    required reqBody,
    headerData,
  }) async {
    Map<String, String> reqHeaders = defaultHeaders(
      userAction: userAction,
      pageName: pageName,
      masterListing: masterlisting ?? false,
    );

    if (headerData != null) {
      reqHeaders.addAll(Map<String, String>.from(headerData));
    }

    final response = await ApiProvider().httpMethod(
      url: url,
      requestBody: reqBody,
      method: "POST",
      headers: reqHeaders,
    );
    if (response?['status'] == 200) {
      return response;
      // resHeaders = response["headers"] ?? {};
    } else {
      showError(response['message'] ?? "");
      sessionExpiry(response);
      return response;
    }
  }

  //call update data request
  Future updateData({
    required url,
    required reqBody,
    userAction,
    showResponseMessage = true,
    required String pageName,
    showMessageOnError = false,
  }) async {
    Map<String, String> reqHeaders = defaultHeaders(
      userAction: userAction,
      pageName: pageName,
    );
    final response = await ApiProvider().httpMethod(
      url: url,
      requestBody: reqBody,
      method: "POST",
      headers: reqHeaders,
      showSuccessToast: true,
    );
    if (response['status'] == 200) {
      return response;
    } else {
      sessionExpiry(response);
      return response;
    }
  }

  //call add data request
  Future addData({
    required url,
    required reqBody,
    required userAction,
    showResponseMessage = true,
    required String pageName,
    showMessageOnError = false,
  }) async {
    // const loginInfo = this.getCookiesData("loginInfo")

    Map<String, String> reqHeaders = defaultHeaders(
      userAction: userAction,
      pageName: pageName,
    );
    devPrint(reqHeaders);
    devPrint(reqBody);
    devPrint(url);
    final response = await ApiProvider().httpMethod(
      url: url,
      requestBody: reqBody,
      method: "POST",
      headers: reqHeaders,
      showSuccessToast: true,
    );

    if (response['status'] == 200) {
      return response;
    } else {
      sessionExpiry(response);
      return response;
    }
  }

  //handle delete data button request
  Future deleteData({
    required url,
    required reqBody,
    userAction,
    showResponseMessage = true,
    required String pageName,
    showMessageOnError = false,
  }) async {
    Map<String, String> reqHeaders = defaultHeaders(
      userAction: userAction,
      pageName: pageName,
    );

    final response = await ApiProvider().httpMethod(
      url: url,
      requestBody: reqBody,
      method: "DELETE",
      headers: reqHeaders,
      showSuccessToast: true,
    );

    if (response['status'] == 200) {
      return response;
    } else {
      sessionExpiry(response);
      return response;
    }
  }

  sessionExpiry(resBody) async {
    // devPrint('SESSION EXPIRY CHECK STATED');
    // devPrint('SESSION 1 --->${resBody["status"] == 401}');
    // devPrint('SESSION 2 --->${resBody["message"] == ('Invalid token.' ?? Config.errmsg['invalidtoken'])}');
    // if (resBody["status"] == 401 && resBody["message"] == ('Invalid token.' ?? Config.errmsg['invalidtoken'])) {
    //   devPrint('SESSION TOKEN EXPIRY ---> TRUE');
    //   // await AuthRepo().onLogOut();
    // } else {
    //   devPrint('SESSION TOKEN EXPIRY ---> FALSE');
    // }
  }

  Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
    if (!kIsWeb) {
      String? path;
      final io.Directory directory = await getApplicationSupportDirectory();
      path = directory.path;
      final io.File file = io.File(io.Platform.isWindows ? '$path\\$fileName' : '$path/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await open_file.OpenFile.open('$path/$fileName');
    }
  }

  String getMimeTypeString(String filepath) {
    // debugger();
    String mimeType = "";
    try {
      mimeType = mime(filepath)!;
    } catch (e) {
      devPrint(e);
    }
    return mimeType;
  }

  convertHtmlToPdf({String? htmlBodyContent, String? htmlHeaderContent, String? htmlFooterContent, bool returnfile = false}) async {
    final newpdf = pw.Document();
    var widgetshead = htmlHeaderContent.isNullOrEmpty ? null : await pw.HTMLToPdf().convert(htmlHeaderContent ?? "");
    var widgets = htmlBodyContent.isNullOrEmpty ? null : await pw.HTMLToPdf().convert(htmlBodyContent ?? "");
    var widgetsFooter = htmlFooterContent.isNullOrEmpty ? null : await pw.HTMLToPdf().convert(htmlFooterContent ?? "");
    newpdf.addPage(
      pw.MultiPage(
        maxPages: 10000000000,
        margin: const pw.EdgeInsets.fromLTRB(1, 2, 2, 10),
        pageFormat: pw.PdfPageFormat.letter,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        orientation: pw.PageOrientation.landscape,
        header: htmlHeaderContent.isNullOrEmpty
            ? null
            : (context) {
                return pw.Column(children: [...widgetshead ?? []]);
              },
        build: (context) {
          return widgets ?? [];
        },
        footer: htmlFooterContent.isNullOrEmpty
            ? null
            : (context) {
                return pw.Column(children: [...widgetsFooter ?? []]);
              },
      ),
    );

    saveAndLaunchFile(List.from(await newpdf.save()), "new123");
  }

  String convertToCamelCase(String text) {
    return text.capitalize ?? '';
    if (text.isNullOrEmpty) {
      return text;
    }
    List<String> words = text.split(" ");
    devPrint(words);
    return words.map((word) => word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase()).join(" ");
  }

  Future<void> getDocumentHistory({
    required String tenantId,
    required String documentType,
    required String pagename,
  }) async {
    devPrint("\n\n ---> IIS Method <--- \n\n");
    Rx<FilesDataModel> selectedFile = FilesDataModel().obs;
    // FormDataModel setDefaultData1 = FormDataModel();
    // setDefaultData1.fieldOrder = [
    //   {
    //     "field": "uploaddate",
    //     "text": "Uploaded Date",
    //     "type": "time",
    //     "freeze": 1,
    //     "active": 1,
    //     "filter": 1,
    //     "filterfieldtype": "input-text",
    //     "defaultvalue": "",
    //     "tblsize": 18,
    //   },
    //   {
    //     "field": "uploadby",
    //     "text": "Uploaded By",
    //     "type": "text",
    //     "freeze": 1,
    //     "active": 1,
    //     "filter": 1,
    //     "filterfieldtype": "input-text",
    //     "defaultvalue": "",
    //     "tblsize": 18,
    //   },
    //   {
    //     "field": "name",
    //     "text": "File Name",
    //     "type": "text",
    //     "freeze": 1,
    //     "active": 1,
    //     "filter": 1,
    //     "filterfieldtype": "input-text",
    //     "defaultvalue": "",
    //     "tblsize": 18,
    //   },
    //   {
    //     "field": "eye",
    //     "text": "Document",
    //     "type": "eye",
    //     "freeze": 1,
    //     "active": 1,
    //     "filter": 1,
    //     "filterfieldtype": "input-text",
    //     "defaultvalue": "",
    //     "tblsize": 10,
    //   },
    //   {
    //     "field": "delete",
    //     "text": "Delete",
    //     "type": "delete-table-doc",
    //     "freeze": 1,
    //     "active": 1,
    //     // "sorttable": 1,
    //     "filter": 1,
    //     "filterfieldtype": "input-text",
    //     "defaultvalue": "",
    //     "tblsize": 10,
    //   },
    // ].obs;
    Map<String, dynamic> body = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 999999999999999,
        "filter": {
          'tbldocumentid': tenantId,
          'documenttype': documentType,
          'pagename': pagename,
        },
        "sort": {}
      }
    };
    var response = await IISMethods().listData(userAction: 'documenthistory', pageName: 'documenthistory', url: "${Config.weburl}documenthistory", reqBody: body, masterlisting: true);
    if (response["status"] == 200) {
      CommonDataTableWidget.showDocumentHistory(RxList<Map<String, dynamic>>.from(response['data']), RxList<Map<String, dynamic>>.from(response['fieldorder']['fields']), documentType, () async {
        Get.dialog(
          barrierDismissible: false,
          ResponsiveBuilder(builder: (context, sizingInformation) {
            return Dialog(
              shadowColor: ColorTheme.kBlack,
              backgroundColor: ColorTheme.kWhite,
              surfaceTintColor: ColorTheme.kWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              insetPadding: sizingInformation.isMobile ? EdgeInsets.zero : const EdgeInsets.all(12),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 600,
                height: 400,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TextWidget(
                            text: 'Add New Document',
                            fontSize: 16,
                            fontWeight: FontTheme.notoSemiBold,
                            color: ColorTheme.kPrimaryColor,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorTheme.kBlack.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              splashColor: ColorTheme.kWhite,
                              hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                              splashRadius: 20,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close),
                            ).paddingAll(2),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomFileDragArea(
                        fileTypes: FileTypes.pdfAndImage,
                        disableMultipleFiles: true,
                        child: DottedBorder(
                          borderType: BorderType.Rect,
                          color: ColorTheme.kBorderColor,
                          dashPattern: const [8, 8, 1, 1],
                          child: Container(
                            height: 200,
                            width: 550,
                            color: ColorTheme.kWhite,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Obx(() {
                                          return Visibility(
                                            visible: selectedFile.value.bytes != null,
                                            replacement: const Icon(
                                              size: 40,
                                              Icons.upload_file_outlined,
                                              color: ColorTheme.kPrimaryColor,
                                            ),
                                            child: const Icon(
                                              size: 40,
                                              Icons.description_outlined,
                                              color: ColorTheme.kPrimaryColor,
                                            ),
                                          );
                                        }),
                                        Obx(() {
                                          return TextWidget(
                                            text: selectedFile.value.bytes == null ? 'Please Select or Drop File Here' : selectedFile.value.name ?? '',
                                            fontSize: 16,
                                            color: ColorTheme.kPrimaryColor,
                                            fontWeight: FontTheme.notoSemiBold,
                                          );
                                        }),
                                        Obx(() {
                                          return Visibility(
                                            visible: selectedFile.value.bytes == null,
                                            child: const TextWidget(
                                              text: "(Only PDF, JPG, JPEG, PNG] file supported)",
                                              fontSize: 12,
                                              color: ColorTheme.kPrimaryColor,
                                              fontWeight: FontTheme.notoSemiBold,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        onFilePicked: (files) async {
                          files = await IISMethods().uploadFiles(files);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      onTap: () async {
                        // await handleFormData(
                        //   key: res["field"],
                        //   value: fileModelList,
                        //   type: res["type"],
                        // );
                      },
                      fontSize: 13,
                      borderRadius: 4,
                      height: 40,
                      title: 'Upload',
                    ).paddingSymmetric(horizontal: 22)
                  ],
                ),
              ),
            );
          }),
        );
      });
    }
  }
}

// addbulk() async {
//   String constructionstage = "Pre - Construction";
//   String approvalcategoryid = "66434f85ce5952f702469ec7";
//   String approvalcategory = "Obtaining Iod";
//   String constructionstageid = xxxx.lastWhere((element) => element['name'] == constructionstage)['_id'];

//   Map<String, String> reqHeaders = defaultHeaders(
//     userAction: "addsubapprovalcategory",
//     pageName: "subapprovalcategory",
//   );
//   Map<String, dynamic> reqBody = {
//     "constructionstageid": constructionstageid,
//     "constructionstage": constructionstage,
//     "approvalcategoryid": approvalcategoryid,
//     "approvalcategory": approvalcategory,
//     "userrole": [
//       {"userroleid": "65e05c56845991ec691c5135", "userrole": "BusinessAdmin"}
//     ],
//     "name": "",
//     "frequency": 1,
//     "frequencyunitid": "6632067f7cd88ca6f3b44464",
//     "frequencyunit": "Year",
//     "status": 1
//   };

//   String url = "https://devapi.prenew.in/v1/subapprovalcategory/add";

//   List data = ["Naval /Defence/ Jail/  SNGP/ Forest", "MONO/ METRO/RAILWAY"];

//   for (var i = 0; i < data.length; i++) {
//     reqBody['name'] = data[i];
//     final response = await ApiProvider().httpMethod(
//       url: url,
//       requestBody: reqBody,
//       method: "POST",
//       headers: reqHeaders,
//       showSuccessToast: true,
//     );
//     devPrint("object222555" + response.toString());
//   }
// }

// Map<String, String> defaultHeaders({
//   required String userAction,
//   required String pageName,
//   bool? masterListing,
// }) {
//   Map<String, String> headers = <String, String>{
//     'issuer': HeaderConstant.issuer,
//     'pagename': pageName,
//     'platform': "1",
//     'useraction': userAction,
//     'version': '1',
//   };
//   if (masterListing != null) {
//     headers['masterlisting'] = masterListing.toString();
//   }
//   if (Settings.authToken.isNotEmpty) {
//     headers['token'] = Settings.authToken;
//   }
//   if (Settings.unqKey.isNotEmpty) {
//     headers['unqkey'] = Settings.unqKey;
//   }
//   if (Settings.uid.isNotEmpty) {
//     headers['uid'] = Settings.uid;
//   }
//   if (Settings.userRoleId.isNotEmpty) {
//     headers['userroleid'] = Settings.userRoleId; // backend team need this for "Tenants Project" listing
//   }
//   if (Settings.userName.isNotEmpty) {
//     headers['username'] = Settings.userName;
//   }
//   return headers;
// }

// List xcx = [
//   {
//     "_id": "66434f21ce5952f702469e28",
//     "name": "Getting The Plot Area Defined",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:46:41.569Z", "timestamp": 1715687201569, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f11ce5952f702469e0a",
//     "name": "Annexure Ii",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:46:25.802Z", "timestamp": 1715687185802, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434ed2ce5952f702469de1",
//     "name": "After Ioa",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:45:22.418Z", "timestamp": 1715687122418, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "6642f75b93a8075850d1dca3",
//     "name": "Amenity Use",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T05:32:11.867Z", "timestamp": 1715664731867, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "6642f74a93a8075850d1dc8e",
//     "name": "Change Of Land Use",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T05:31:54.527Z", "timestamp": 1715664714527, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "663cb30ffcb60f40ed68ab87",
//     "name": "Not Approval",
//     "status": 1,
//     "recordinfo": {
//       "entryuid": "65d6fafbbec9d6aa4a72cc8d",
//       "entryby": "PRENEW Admin",
//       "entrydate": "2024-05-09T11:27:11.844Z",
//       "timestamp": 1715254031844,
//       "isactive": 1,
//       "updateuid": "65d6fafbbec9d6aa4a72cc8d",
//       "updateby": "PRENEW Admin",
//       "updatedate": "2024-05-09T11:31:31.210Z"
//     },
//     "__v": 0
//   },
//   {
//     "_id": "663cb307fcb60f40ed68ab76",
//     "name": "Approval",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-09T11:27:03.162Z", "timestamp": 1715254023162, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66435228f9ad77fb2660ac33",
//     "name": "Amalgamation Subdivision",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:59:36.773Z", "timestamp": 1715687976773, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66435099ce5952f70246a243",
//     "name": "Handing Over Of Reservation",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:52:57.626Z", "timestamp": 1715687577626, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f94ce5952f702469edc",
//     "name": "Obtaining Oc",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:48:36.183Z", "timestamp": 1715687316183, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f85ce5952f702469ec7",
//     "name": "Obtaining Iod",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:48:21.257Z", "timestamp": 1715687301257, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f7ace5952f702469eb2",
//     "name": "Obtaining Ioa",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:48:10.834Z", "timestamp": 1715687290834, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f69ce5952f702469e9d",
//     "name": "Obtaining Cc-plinth",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:47:53.603Z", "timestamp": 1715687273603, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f61ce5952f702469e88",
//     "name": "Obtaining Cc-further",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:47:45.299Z", "timestamp": 1715687265299, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f5ace5952f702469e6b",
//     "name": "Obtaining Bcc",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:47:38.662Z", "timestamp": 1715687258662, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f53ce5952f702469e56",
//     "name": "Layout Approval",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:47:31.518Z", "timestamp": 1715687251518, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "66434f44ce5952f702469e41",
//     "name": "Loi",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:47:16.907Z", "timestamp": 1715687236907, "isactive": 1},
//     "__v": 0
//   }
// ];
// List xxxx = [
//   {
//     "_id": "66435021ce5952f70246a07e",
//     "name": "On Going",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "PRENEW Admin", "entrydate": "2024-05-14T11:50:57.554Z", "timestamp": 1715687457554, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "663cab9818d20c978b8fbfc8",
//     "name": "Old Construction",
//     "status": 0,
//     "recordinfo": {
//       "entryuid": "65d6fafbbec9d6aa4a72cc8d",
//       "entryby": "PRENEW Admin",
//       "entrydate": "2024-05-09T10:55:20.929Z",
//       "timestamp": 1715252120929,
//       "isactive": 1,
//       "updateuid": "65d6fafbbec9d6aa4a72cc8d",
//       "updateby": "PRENEW Admin",
//       "updatedate": "2024-05-14T05:32:40.207Z"
//     },
//     "__v": 0
//   },
//   {
//     "_id": "663cab5518d20c978b8fbf9f",
//     "name": "New Construction",
//     "status": 0,
//     "recordinfo": {
//       "entryuid": "65d6fafbbec9d6aa4a72cc8d",
//       "entryby": "PRENEW Admin",
//       "entrydate": "2024-05-09T10:54:13.593Z",
//       "timestamp": 1715252053593,
//       "isactive": 1,
//       "updateuid": "65d6fafbbec9d6aa4a72cc8d",
//       "updateby": "PRENEW Admin",
//       "updatedate": "2024-05-09T11:31:16.333Z"
//     },
//     "__v": 0
//   },
//   {
//     "_id": "663cab5018d20c978b8fbf8a",
//     "name": "Construction",
//     "status": 0,
//     "recordinfo": {
//       "entryuid": "65d6fafbbec9d6aa4a72cc8d",
//       "entryby": "PRENEW Admin",
//       "entrydate": "2024-05-09T10:54:08.400Z",
//       "timestamp": 1715252048400,
//       "isactive": 1,
//       "updateuid": "65d6fafbbec9d6aa4a72cc8d",
//       "updateby": "PRENEW Admin",
//       "updatedate": "2024-05-09T11:31:18.334Z"
//     },
//     "__v": 0
//   },
//   {
//     "_id": "66028c912abc6fb9bf869031",
//     "name": "Post Construction",
//     "status": 1,
//     "recordinfo": {"entryuid": "65d6fafbbec9d6aa4a72cc8d", "entryby": "Admin", "entrydate": "2024-03-26T08:51:28.979Z", "timestamp": 1711443088979, "isactive": 1},
//     "__v": 0
//   },
//   {
//     "_id": "65dee5a2aedb1a2a6aaba39a",
//     "name": "During Construction",
//     "status": 1,
//     "recordinfo": {
//       "entryuid": "65d6fafbbec9d6aa4a72cc8d",
//       "entryby": "sanjay rajodiya",
//       "entrydate": "2024-02-28T07:49:54.478Z",
//       "timestamp": 1709106594478,
//       "isactive": 1,
//       "updateuid": "65d6fafbbec9d6aa4a72cc8d",
//       "updateby": "PRENEW Admin",
//       "updatedate": "2024-05-09T10:58:27.456Z"
//     },
//     "__v": 0
//   },
//   {
//     "_id": "65dee437aedb1a2a6aaba354",
//     "name": "Pre - Construction",
//     "status": 1,
//     "recordinfo": {
//       "entryuid": "65d6fafbbec9d6aa4a72cc8d",
//       "entryby": "Admin",
//       "entrydate": "2024-02-28T07:43:50.996Z",
//       "timestamp": 1709106230996,
//       "isactive": 1,
//       "updateuid": "65d6fafbbec9d6aa4a72cc8d",
//       "updateby": "sanjay rajodiya",
//       "updatedate": "2024-02-28T07:49:47.662Z"
//     },
//     "__v": 0
//   }
// ];
