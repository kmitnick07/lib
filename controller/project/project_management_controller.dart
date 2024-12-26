import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/funtions.dart';
import '../../components/json/project_management_json.dart';
import '../../config/config.dart';
import '../../routes/route_generator.dart';
import '../../utils/aws_service/file_data_model.dart';

///projects
class ProjectManagementController extends GetxController {
  RxString pageName = ''.obs;
  RxString formName = ''.obs;
  RxString message = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  RxMap dialogBoxData = {}.obs;
  Map validator = {};
  Map<int, FocusNode> focusNodes = {};
  RxInt statusCode = 0.obs;
  RxBool loadingData = false.obs;
  RxBool formLoadingData = false.obs;
  RxBool updateObj = false.obs;
  final formKey0 = GlobalKey<FormState>();
  int cursorPos = 0;
  RxBool addButtonLoading = false.obs;
  RxBool addMultipleButtonLoading = false.obs;

  TextEditingController searchController = TextEditingController();

  RxBool validateForm = false.obs;
  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};
  RxString searchText = ''.obs;
  bool autoFilling = false;
  RxBool isAddButtonVisible = false.obs;

  ScrollController tableScrollController = ScrollController();
  RxBool loadingPaginationData = false.obs;

  @override
  Future<void> onInit() async {
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
    pageName.value = getCurrentPageName();
    devPrint(pageName.value);
    dialogBoxData.value = ProjectManagementJson.designationFormFields(pageName.value);

    formName.value = dialogBoxData['formname'];
    formName.refresh();
    setPageTitle('${formName.value} | PRENEW', Get.context!);

    isAddButtonVisible.value = IISMethods().hasAddRight(alias: pageName.value);
    await getList();
    await setFilterData();
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<ProjectManagementController>();
    super.dispose();
  }

  Future<void> getList([bool appendData = false]) async {
    if (!appendData) {
      setDefaultData.data.value = [];
      loadingData.value = true;
    } else {
      loadingPaginationData.value = true;
    }
    final url = Config.weburl + pageName.value;
    final userAction = "list$pageName";
    var filter = {};
    for (var entry in setDefaultData.filterData.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.toString().isNotNullOrEmpty) {
        filter[key] = value;
      }
    }
    if (setDefaultData.data == []) {
      setDefaultData.pageNo = 1.obs;
    }
    filter.remove('searchtext');
    devPrint(searchText.value);
    final reqBody = {
      'searchtext': searchText.value,
      'paginationinfo': {
        'pageno': setDefaultData.pageNo.value,
        'pagelimit': setDefaultData.pageLimit,
        'filter': filter,
        'sort': setDefaultData.sortData,
      },
    };
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;
    setDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"]);

    if (resBody["status"] == 200) {
      if (!appendData) {
        setDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data']);
      } else {
        setDefaultData.data.addAll(List<Map<String, dynamic>>.from(resBody['data']));
      }

      setDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"]);
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
          } else if (field['masterdata'] && field['masterdataarray'] && !setDefaultData.masterData[field['storemasterdatabyfield'] == true ? field['field'] : field['masterdata']]) {
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
    } else {
      showError(resBody['message']);
    }

    loadingData.value = false;
    loadingPaginationData.value = false;
    setDefaultData.fieldOrder.refresh();
    setDefaultData.data.refresh();
    update();
  }

  //call request for fields meta data
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
      if (pageName.value == RouteNames.kProject.split('/').last && fieldObj['field'] == 'tenantprojectid') {
        filter['unassigned'] = setDefaultData.formData['_id'].toString().isNullOrEmpty ? 1 : 2;
        filter['projectid'] = setDefaultData.formData['_id'] ?? '';
      }
      var projection = {};

      if (fieldObj["projection"] != null) {
        projection = {...fieldObj["projection"]};
      }
      var masterDataKey = fieldObj["storemasterdatabyfield"] == true || storeMasterDataByField! ? fieldObj["field"] : fieldObj["masterdata"];

      // if (setDefaultData.masterDataList.containsKey(masterDataKey) && !fieldObj.containsKey('dependentfilter')) {
      //   return;
      // }

      var isTrue = fieldObj.containsKey("masterdatadependancy");
      if (isTrue) {
        isTrue = fieldObj["masterdatadependancy"];
      }
      if (!isTrue || isDepend == 1) {
        var url = Config.weburl + fieldObj["masterdata"];
        var userAction = 'list${fieldObj["masterdata"]}data';

        // filter = {
        //   ...fieldObj["filter"],
        //   ...filter,
        // };
        var reqBody = {
          "paginationinfo": {"pageno": pageNo, "pagelimit": 500000000000, "filter": filter, "projection": projection, "sort": {}}
        };

        var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value, masterlisting: true);
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
    var tempFormData = {};
    if (id != null) {
      tempFormData = await IISMethods().getObjectFromArray(setDefaultData.data, '_id', id);
      updateObj.value = true;
    } else {
      for (var data in dialogBoxData["formfields"]) {
        data["formFields"].forEach((fields) {
          switch (fields['type']) {
            case HtmlControls.kDropDown:
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
              tempFormData[fields["field"]] = {};
              break;
            default:
              tempFormData[fields["field"]] = fields["defaultvalue"] ?? '';
              break;
          }
        });
      }
    }

    setDefaultData.formData.value = Map<String, dynamic>.from(tempFormData);
    setDefaultData.formData['pincodeNewEntry'] = 0;

    ///comment temp
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

  Future setFilterData({String? id, int? editeDataIndex, bool? clone}) async {
    formLoadingData.value = true;
    initialStateData['lastEditedDataIndex'] = editeDataIndex;
    setDefaultData.formData.value = {};
    updateObj.value = false;
    Map<String, dynamic> tempFormData = {};
    if (setDefaultData.filterData.keys.isNotEmpty) {
      tempFormData = setDefaultData.filterData.value;
      setDefaultData.oldFilterData.value = IISMethods().encryptDecryptObj(setDefaultData.filterData.value);
    } else {
      for (Map<String, dynamic> fields in setDefaultData.fieldOrder) {
        {
          if (fields['filter'] != 1) {
            continue;
          }
          switch (fields['filterfieldtype']) {
            case HtmlControls.kDropDown:
              tempFormData[fields["filterfield"]] = null;
              tempFormData['${fields["filterfield"]}id'] = null;

              break;
            case HtmlControls.kCheckBox:
              tempFormData[fields["filterfield"]] = fields['defaultvalue'] ?? 0;
              break;
            default:
              tempFormData[fields["filterfield"]] = fields['defaultvalue'] ?? '';
              break;
          }
        }
      }
    }

    setDefaultData.filterData.value = Map<String, dynamic>.from(tempFormData);
    // setDefaultData.oldFilterData.value = IISMethods().encryptDecryptObj(setDefaultData.filterData.value);

    ///comment temp

    for (var fields in setDefaultData.fieldOrder) {
      devPrint(fields);
      if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
        var isTrue = fields.containsKey("masterdatadependancy");
        if (isTrue) {
          isTrue = fields["masterdatadependancy"];
        }
        if (isTrue ||
            !setDefaultData.masterData.containsKey(fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) ||
            fields["isselfrefernce"] == null ||
            fields["setvaluefromlogininfo"] == null) {
          await getMasterData(
            pageNo: 1,
            fieldObj: fields,
            formData: setDefaultData.filterData,
          );
          var masterDataKey = fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"];
          if (setDefaultData.masterData[masterDataKey] != null && setDefaultData.masterData[masterDataKey].isNotEmpty && autoFilling) {
            await handleFormData(
              key: fields["filterfield"],
              value: setDefaultData.masterData[masterDataKey]?.first['value'],
              type: fields['type'],
              onChangeFill: false,
            );
          }
        }
      } else if (fields["masterdata"] != null &&
          fields.containsKey("masterdataarray") &&
          !setDefaultData.masterData.containsKey(fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
        var array = [];
        for (var object in fields["masterdataarray"]) {
          if (object is Map<String, dynamic>) {
            array.add(object);
          } else {
            array.add({"label": object, "value": object});
          }
        }
        setDefaultData.masterData[fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]] = array;
      }
    }
    setDefaultData.filterData.removeNullValues();
    formLoadingData.value = false;
    update();
  }

  //handle form-field inputs
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
        if (key == 'pincode') {
          if (value.toString().length < 6) {
            setDefaultData.formData["pincodeid"] = '';
            setDefaultData.formData['area'] = '';
            setDefaultData.formData["city"] = '';
            setDefaultData.masterData['pincode'] = [];
          } else {
            var pincodeField = getObjectFromFormData(dialogBoxData["formfields"], 'pincodeid');
            await getMasterData(pageNo: 1, fieldObj: pincodeField, formData: setDefaultData.formData);
            try {
              setDefaultData.formData["city"] = (setDefaultData.masterDataList['pincode'] as List?)?.first['city'];
              setDefaultData.formData['pincodeNewEntry'] = 0;
            } catch (e) {
              setDefaultData.formData['pincodeNewEntry'] = 1;
              showError('Pincode Data not found');
            }
            // setDefaultData.formData["area"] = res['area'];
            // setDefaultData.formData["city"] = res['city'];
          }
        }
        break;
      case HtmlControls.kFilePicker:
      case HtmlControls.kImagePicker:
      case HtmlControls.kAvatarPicker:
        {
          value as List<FilesDataModel>;
          value = List<FilesDataModel>.from(await IISMethods().uploadFiles(value));
          if (value.isNotEmpty) {
            setDefaultData.formData[key] = value.first.toJson();
          }
        }
        break;
      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        if (fieldObj["masterdataarray"] != null) {
          setDefaultData.formData[key] = value ?? '';
        } else {
          var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
          setDefaultData.formData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
          setDefaultData.formData[key] = res?["_id"];
          if (pageName.value == RouteNames.kProject.split('/').last && key == 'tenantprojectid') {
            devPrint(res?['developerid']);
            setDefaultData.formData['developerid'] = res?['developerid'] ?? '';
            setDefaultData.formData['developername'] = res?['developername'] ?? '';
          }
          if (key == 'pincodeid') {
            setDefaultData.formData["area"] = res['area'];
            setDefaultData.formData["city"] = res['city'];
          }
          if (key == 'unit') {
            setDefaultData.formData["unitstatus"] = res['status'] == 1 ? "Active" : "Inactive";
          }
          devPrint(res);
        }

        break;
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
    update();
  }

  //handle filter inputs
  Future handleFilterData({
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
          setDefaultData.filterData[key] = double.tryParse(value?.toString() ?? '0');
        } else {
          setDefaultData.filterData[key] = int.tryParse(value?.toString() ?? '0');
        }
        break;
      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);

        setDefaultData.filterData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
        setDefaultData.filterData[key] = res?["_id"];
        break;
      default:
        setDefaultData.filterData[key] = value;
    }

    getList();
    update();
  }

  handleAddButtonClick({required bool saveAndAdd}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (setDefaultData.formData.containsKey('_id')) {
      await updateData(reqData: setDefaultData.formData);
    } else {
      await addData(reqData: setDefaultData.formData, saveAndAdd: saveAndAdd);
    }
  }

  handleGridChange({required int index, required String field, required String type, dynamic value, required String masterfieldname, required String name, bool isBack = true}) {
    switch (type) {
      case HtmlControls.kStatus:
      case HtmlControls.kSwitch:
        setDefaultData.data[index][field] = value ? 1 : 0;
        break;
      case HtmlControls.kDropStatus:
        setDefaultData.data[index][field] = value;
        setDefaultData.data[index][masterfieldname] = name;
    }
    updateData(reqData: setDefaultData.data[index], editeDataIndex: index, isBack: false);
  }

  //call add data request
  Future addData({reqData, required bool saveAndAdd}) async {
    var url = '${Config.weburl}${pageName.value}/add';

    var userAction = "add$pageName";

    var resBody = await IISMethods().addData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody["message"];
      setDefaultData.pageNo = 1.obs;
      setDefaultData.data.value = [];
      await getList();
      saveAndAdd ? setFormData() : Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody["message"];
      showError(message.value);
    }
  }

  Future updateData({
    required Map reqData,
    int? editeDataIndex = -1,
    bool isBack = true,
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
      isBack ? Get.back() : null;
    } else {
      message.value = resBody['message'];
      showError(message.value);
    }
    update();
  }

//handle delete data button request
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
