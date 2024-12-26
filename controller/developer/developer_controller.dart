import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/json/developer_json.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';

import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../routes/route_generator.dart';
import '../../routes/route_name.dart';
import '../../utils/aws_service/file_data_model.dart';

class DeveloperController extends GetxController {
  RxString pageName = ''.obs;
  RxString formName = ''.obs;
  RxString message = ''.obs;
  RxString searchText = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  RxMap dialogBoxData = {}.obs;
  Map validator = {};
  Map<int, FocusNode> focusNodes = {};
  RxMap<String, dynamic> uploadedFile = <String, dynamic>{}.obs;
  RxInt statusCode = 0.obs;
  RxInt uploadDocCount = 0.obs;
  RxBool loadingData = false.obs;
  RxBool loadingPaginationData = false.obs;
  RxBool formLoadingData = false.obs;
  RxBool updateObj = false.obs;
  final formKey0 = GlobalKey<FormState>();
  int cursorPos = 0;
  RxBool validateForm = false.obs;
  bool autoFilling = false;
  RxBool isAddButtonVisible = false.obs;
  RxBool addButtonLoading = false.obs;
  TextEditingController searchController = TextEditingController();

  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};

  ScrollController tableScrollController = ScrollController();

  Future<void> onInitl() async {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        tableScrollController.addListener(() {
          if (tableScrollController.position.atEdge) {
            bool isTop = tableScrollController.position.pixels == 0;

            if (isTop) {
              devPrint('🍺 At the top');
            } else {
              devPrint('🍺 At the bottom');
              if (setDefaultData.nextPage == 1) {
                setDefaultData.pageNo.value = setDefaultData.pageNo.value + 1;
                if (!loadingPaginationData.value) {
                  getList(true);
                }
              }
            }
          }
        });
      }
    }
    if (Get.arguments is Map) {
      pageName.value = Get.arguments['pagename'] ?? "";
    } else {
      pageName.value = getCurrentPageName();
    }
    devPrint(pageName);

    dialogBoxData.value = DeveloperJson.designationFormFields(pageName.value);
    formName.value = dialogBoxData['formname'] ?? "";
    setPageTitle('${formName.value} | PRENEW', Get.context!);
    isAddButtonVisible.value = IISMethods().hasAddRight(alias: pageName.value);
    formName.refresh();
    await getList();
    super.onInit();
  }


  @override
  void dispose() {
    Get.delete<DeveloperController>();
    super.dispose();
  }

  Future<void> getList([bool appendData = false]) async {
    setDefaultData.data.value == [];
    if (!appendData) {
      loadingData.value = true;
    } else {
      loadingPaginationData.value = true;
    }
    setDefaultData.data.refresh();
    update();
    final url = Config.weburl + pageName.value;
    final userAction = "list$pageName";
    var filter = {};

    final searchtext = searchText.value;

    filter.remove('searchtext');
    final reqBody = {
      'searchtext': searchtext,
      'paginationinfo': {
        'pageno': setDefaultData.pageNo.value,
        'pagelimit': setDefaultData.pageLimit,
        'filter': filter,
        'sort': setDefaultData.sortData,
      },
    };
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;
    devLog(jsonEncode(resBody));
    if (resBody["status"] == 200) {
      setDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"]);

      if (!appendData) {
        setDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data']);
      } else {
        setDefaultData.data.addAll(List<Map<String, dynamic>>.from(resBody['data']));
      }
      setDefaultData.nextPage = resBody['nextpage'];
      setDefaultData.pageName = resBody['pagename'];
      setDefaultData.contentLength = resBody['totaldocs'] ?? 0;
      setDefaultData.noOfPages.value = (setDefaultData.contentLength / setDefaultData.pageLimit).ceil();
      for (var field in setDefaultData.fieldOrder) {
        if (field['masterdata'] != null && field['masterdataarray'] != null && field['masterdatadependancy'] != null) {
          if (field['masterdata'] &&
              !field['masterdataarray'] &&
              !field['masterdatadependancy'] &&
              !setDefaultData.masterData[field['storemasterdatabyfield'] == true ? field['field'] : field['masterdata']]) {
            await getMasterData(
              pageNo: 1,
              fieldObj: field,
            );
          } else if (field['masterdata'] &&
              field['masterdataarray'] &&
              !setDefaultData.masterData[field['storemasterdatabyfield'] == true ? field['field'] : field['masterdata']]) {
            var array = [];
            for (var object in field['masterdataarray']) {
              if (object is Map<String, dynamic>) {
                array.add(object);
              } else {
                array.add({'label': object, 'value': object});
              }
            }
            setDefaultData.masterData[field['storemasterdatabyfield'] == true ? field['field'] : field['masterdata']] = array;
          }
        }
      }
    }

    loadingData.value = false;
    loadingPaginationData.value = false;
    loadingData.refresh();
    setDefaultData.fieldOrder.refresh();
    setDefaultData.data.refresh();
    update();
  }

  Future getMasterData({
    required int pageNo,
    required Map<String, dynamic> fieldObj,
    Map? formData,
    bool? storeMasterDataByField = false,
  }) async {
    try {
      var filter = {};
      var isDepend = 0;

      if (fieldObj['dependentfilter'] != null) {
        fieldObj['dependentfilter'].keys.forEach((key) {
          final value = formData![fieldObj['dependentfilter'][key]];
          if (value != null) {
            isDepend = 1;
            filter[key] = value;
          }
        });
      }
      if (fieldObj['staticfilter'] != null) {
        filter = {...filter, ...fieldObj['staticfilter']};
      }
      if (pageName.value == RouteNames.kUsers
          .split('/')
          .last && fieldObj['field'] == 'team') {
        filter['userid'] = setDefaultData.formData['_id'] ?? '';
      }
      if (pageName.value == RouteNames.kTeam
          .split('/')
          .last && fieldObj['field'] == 'teammember') {
        filter['teamid'] = setDefaultData.formData['_id'] ?? '';
      }
      var projection = {};

      if (fieldObj["projection"] != null) {
        projection = {...fieldObj["projection"]};
      }
      var masterDataKey = fieldObj["storemasterdatabyfield"] == true || storeMasterDataByField! ? fieldObj["field"] : fieldObj["masterdata"];

      var isTrue = fieldObj.containsKey("masterdatadependancy");
      if (isTrue) {
        isTrue = fieldObj["masterdatadependancy"];
      }
      if (!isTrue || isDepend == 1) {
        var url = Config.weburl + fieldObj["masterdata"];
        var userAction = 'list${fieldObj["masterdata"]}data';

        var reqBody = {
          "paginationinfo": {"pageno": pageNo, "pagelimit": 500000000000, "filter": filter, "projection": projection, "sort": {}}
        };

        var resBody = await IISMethods().listData(url: url,
            reqBody: reqBody,
            userAction: userAction,
            pageName: pageName.value,
            masterlisting: true);
        if (resBody["status"] == 200) {
          if (pageNo == 1) {
            setDefaultData.masterData[masterDataKey] = [];
            setDefaultData.masterDataList[masterDataKey] = [];
          }
          for (var data in resBody["data"]) {
            setDefaultData.masterData[masterDataKey].add({"label": data[fieldObj["masterdatafield"]], "value": data["_id"].toString()});
          }

          setDefaultData.masterDataList[masterDataKey] = [...setDefaultData.masterDataList[masterDataKey], ...resBody["data"]];

          if (resBody["nextpage"] == 1) {
            await getMasterData(pageNo: pageNo + 1, fieldObj: fieldObj, formData: formData, storeMasterDataByField: storeMasterDataByField);
          }
        }
      } else {
        setDefaultData.masterData[masterDataKey] = [];
        setDefaultData.masterDataList[masterDataKey] = [];
      }
    } catch (err) {
      devPrint(err.toString());
      rethrow;
    }
    update();
  }

  Future setFormData({String? id, int? editeDataIndex, bool? clone}) async {
    validateForm.value = false;
    formLoadingData.value = true;
    initialStateData['lastEditedDataIndex'] = editeDataIndex;
    setDefaultData.formData.value = {};
    updateObj.value = false;
    uploadedFile.value = {};
    var tempFormData = {};
    if (id != null) {
      tempFormData = await IISMethods().getObjectFromArray(setDefaultData.data, '_id', id);
      updateObj.value = true;
    } else {
      for (var data in dialogBoxData["formfields"]) {
        data["formFields"].forEach((fields) {
          switch (fields['type']) {
            case HtmlControls.kDropDown:
            case HtmlControls.kMultiSelectDropDown:
              if (fields["masterdataarray"] != null) {
                tempFormData[fields["field"]] = fields["defaultvalue"];
                tempFormData[fields["formdatafield"]] = fields["defaultvalue"];
              } else {
                tempFormData[fields["field"]] = null;
                tempFormData[fields["formdatafield"]] = null;
              }
              break;
            case HtmlControls.kCheckBox:
              tempFormData[fields["field"]] = fields["defaultvalue"] ?? 0;
              break;
            case HtmlControls.kImagePicker:
            case HtmlControls.kFilePicker:
            case HtmlControls.kAvatarPicker:
              tempFormData[fields["field"]] = FilesDataModel().toJson();
              break;
            default:
              tempFormData[fields["field"]] = fields["defaultvalue"] ?? '';
              break;
          }
        });
      }
    }

    setDefaultData.formData.value = Map<String, dynamic>.from(tempFormData);

    for (var data in dialogBoxData["formfields"]) {
      for (var fields in data["formFields"]) {
        devPrint(fields);
        if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
          var isTrue = fields.containsKey("masterdatadependancy");
          if (isTrue) {
            isTrue = fields["masterdatadependancy"];
          }
          if (isTrue ||
              !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) ||
              fields["isselfrefernce"] == null ||
              fields["setvaluefromlogininfo"] == null) {
            await getMasterData(pageNo: 1, fieldObj: fields, formData: setDefaultData.formData);
            var masterDataKey = fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"];
            if (setDefaultData.masterData[masterDataKey] != null && setDefaultData.masterData[masterDataKey].isNotEmpty && autoFilling) {
              await handleFormData(
                key: fields["field"],
                value: setDefaultData.masterData[masterDataKey]?.first['value'],
                type: fields['type'],
                onChangeFill: false,
              );
            }
          }
        } else if (fields["masterdata"] != null &&
            fields.containsKey("masterdataarray") &&
            !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
          var array = [];
          for (var object in fields["masterdataarray"]) {
            if (object is Map<String, dynamic>) {
              array.add(object);
            } else {
              array.add({"label": object, "value": object});
            }
          }
          setDefaultData.masterData[fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]] = array;
        }
      }
    }
    formLoadingData.value = false;
    update();
  }

  Future handleFormData({
    type,
    key,
    value,
    fieldType,
    fieldKey,
    fieldValue,
    onChangeFill = true,
  }) async {
    switch (type) {
      case HtmlControls.kNumberInput:
        if (value.toString().contains(".")) {
          setDefaultData.formData[key] = double.tryParse(value?.toString() ?? '0');
        } else {
          setDefaultData.formData[key] = int.tryParse(value?.toString() ?? '0');
        }
        break;
      case HtmlControls.kMultiSelectDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        try {
          if (fieldObj.containsKey("masterdataarray")) {
            try {
              for (var e in value) {
                setDefaultData.formData[key].add({
                  "${fieldObj["field"]}id": e,
                  "${fieldObj["field"]}": e,
                });
              }
            } catch (e) {
              setDefaultData.formData[key] = [];
            }
          } else {
            setDefaultData.formData[key] = [];
            for (var e in value) {
              var masterDataKey = fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"];
              var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[masterDataKey], "_id", e);

              setDefaultData.formData[key].add({
                "${fieldObj["field"]}id": e,
                "${fieldObj["field"]}": res[fieldObj["formdatafield"]],
              });
            }
          }
        } catch (e) {
          setDefaultData.formData[key] = [];
        }
        break;
      case HtmlControls.kFilePicker:
      case HtmlControls.kAvatarPicker:
      case HtmlControls.kImagePicker:
        {
          value as List<FilesDataModel>;
          value = List<FilesDataModel>.from(await IISMethods().uploadFiles(value));
          if (value.isNotEmpty) {
            setDefaultData.formData[key] = value.first.toJson();
          } else {
            setDefaultData.formData[key] = FilesDataModel().toJson();
          }
        }
        break;
      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        if (fieldObj["masterdataarray"] != null) {
          setDefaultData.formData[key] = value ?? '';
        } else {
          var res = await IISMethods()
              .getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
          setDefaultData.formData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
          setDefaultData.formData[key] = res?["_id"];
        }
        break;
      case HtmlControls.kCheckBox:
        setDefaultData.formData[key] = value ? 1 : 0;
      default:
        setDefaultData.formData[key] = value;
    }

    var obj = getObjectFromFormData(dialogBoxData["formfields"], key);

    if (obj["onchangefill"] != null && onChangeFill) {
      for (var field in obj["onchangefill"]) {
        var obj2 = getObjectFromFormData(dialogBoxData["formfields"], field);
        if (obj2["type"] == HtmlControls.kDropDown) {
          await handleFormData(type: obj2['type'], key: obj2["field"], value: '');
        } else if (obj2["type"] == HtmlControls.kMultiSelectDropDown) {
          setDefaultData.formData[field] = [];
        }
        await getMasterData(pageNo: 1, fieldObj: obj2, formData: setDefaultData.formData);
        var masterDataKey = obj2["storemasterdatabyfield"] == true ? obj2["field"] : obj2["masterdata"];
        if (setDefaultData.masterData[masterDataKey]?.length >= 1 && autoFilling) {
          await handleFormData(
            key: obj2["field"],
            value: setDefaultData.masterData[masterDataKey]?.first['value'],
            type: obj2['type'],
          );
        }
      }
    }
    devPrint(setDefaultData.formData);
    update();
  }

  handleGridChange({required int index, required String field, required String type, dynamic value}) async {
    switch (type) {
      case HtmlControls.kStatus:
        setDefaultData.data[index][field] = value ? 1 : 0;
        updateData(reqData: setDefaultData.data[index], editeDataIndex: index);


      case HtmlControls.kSwitch:
        setDefaultData.data[index][field] = value ? 1 : 0;
        updateData(reqData: setDefaultData.data[index], editeDataIndex: index);
    }
  }

  handleAddButtonClick() async {
    if (setDefaultData.formData.containsKey('_id')) {
      if (await updateData(reqData: setDefaultData.formData)) {
        Get.back();
      }
    } else {
      await addData(reqData: setDefaultData.formData);
    }
  }

  Future addData({
    reqData,
  }) async {
    var url = '${Config.weburl}${pageName.value}/add';

    var userAction = "add$pageName";

    var resBody = await IISMethods().addData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody["message"];
      setDefaultData.pageNo = 1.obs;
      setDefaultData.data.value = [];
      await getList();
      Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody["message"];
      showError(message.value);
    }
  }

  Future<bool> updateData({
    required Map reqData,
    int? editeDataIndex = -1,
  }) async {
    var url = '${Config.weburl + pageName.value}/update';

    var userAction = "update$pageName";

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = await resBody["message"];
      var updatedDataIndex = editeDataIndex! > -1 ? editeDataIndex : initialStateData["lastEditedDataIndex"] ?? -1;
      try {
        if (updatedDataIndex != null && updatedDataIndex > -1 && resBody.containsKey('data')) {
          Map<String, dynamic> updatedResData = Map<String, dynamic>.from(resBody["data"]);
          setDefaultData.data[updatedDataIndex] = updatedResData;
          setDefaultData.data.refresh();
          showSuccess(message.value);
        } else {
          await getList();
          showSuccess(message.value);
        }
      } catch (e) {
        await getList();
        showSuccess(message.value);
      }
    } else {
      message.value = resBody['message'];
      showError(message.value);
    }
    update();
    return resBody["status"] == 200;
  }

  Future deleteData(reqData) async {
    String url = '${Config.weburl + pageName.value}/delete';

    String userAction = "delete$pageName";

    var resBody = await IISMethods().deleteData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName.value);
    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody['message'];
      setDefaultData.data.removeWhere((element) => element["_id"] == reqData['_id']);
      setDefaultData.contentLength--;
      Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody['message'];
      Get.back();
      showError(message.value);
    }
  }
}

Map<String, dynamic> x = {
  "_id": "1",
  "developername": "Prestige Worli Pvt. Ltd.",
  "address": "Dr. Annie Dev Das Road",
  "gst": "27ABCDE1234F1GH",
  "pan": "ABCDE1234F",
  "contact": "7894561",
  "email": "worli@Prestige.com",
  "status": "2bb150",
};
