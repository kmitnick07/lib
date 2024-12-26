import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/json/approval_json.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';

import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../routes/route_generator.dart';
import '../../routes/route_name.dart';
import '../../style/string_const.dart';
import '../../utils/aws_service/file_data_model.dart';

class ApprovalMasterController extends GetxController {
  RxString pageName = ''.obs;
  RxString formName = ''.obs;
  RxString message = ''.obs;
  RxString searchText = ''.obs;
  RxString templateParentId = ''.obs;
  RxString templateParentName = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  RxMap dialogBoxData = {}.obs;
  Map validator = {};
  Map<int, FocusNode> focusNodes = {};
  RxMap<String, dynamic> uploadedFile = <String, dynamic>{}.obs;
  // RxMap<String, dynamic> tempApprovalDataMap
  RxMap<String, dynamic> locallyMasterFormData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> locallyStoreListOfEntries = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> reqLocalListOfEntries = <String, dynamic>{}.obs;
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
  RxBool masterFormLoadingData = false.obs;
  RxBool addButtonLoading = false.obs;
  TextEditingController searchController = TextEditingController();
  ScrollController horizontalController = ScrollController();

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
                  getList(appendData: true);
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

    dialogBoxData.value = ApprovalJson.designationFormFields(pageName.value) ?? {};
    formName.value = dialogBoxData['formname'] ?? "Approvals Tracker";
    setPageTitle('${formName.value} | PRENEW', Get.context!);
    isAddButtonVisible.value = IISMethods().hasAddRight(alias: pageName.value);
    formName.refresh();
    await getList();
    setFilterData();
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<ApprovalMasterController>();
    super.dispose();
  }

  Future<void> getList({bool appendData = false, String fromdate = "", String todate = "", int filterduration = 1, Map? approvalsFilter}) async {
    devPrint("9641635416534163: 'getList'");

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
    filter.addAll(approvalsFilter ?? {});
    for (var entry in setDefaultData.filterData.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.toString().isNotNullOrEmpty) {
        filter[key] = value;
      }
    }

    final searchtext = searchText.value;

    filter.remove('searchtext');

    final reqBody = {
      'searchtext': searchtext,
      'paginationinfo': {
        'pageno': setDefaultData.pageNo.value,
        'pagelimit': setDefaultData.pageLimit,
        'filter': filter,
        // 'projection': {'approvals': 0},
        'sort': setDefaultData.sortData,
      },
    };
    var resBody = await IISMethods().listData(
      url: url,
      reqBody: reqBody,
      userAction: userAction,
      pageName: pageName.value,
    );

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

  getMasterFormData({String? parentId, String? pagename, int assignedproject = 0}) async {
    var projection = {};

    if (pagename == StringConst.kApprovals || getCurrentPageName() == StringConst.kDashboard) {
      projection = {
        'documents': 1,
        'constructionstage': 1,
        'approvalcategory': 1,
        'subapprovalcategory': 1,
        'governmentauthority': 1,
        'frequency': 1,
        'frequencyunitid': 1,
        'frequencyunit': 1
      };
    }

    if (assignedproject == 0 && (pagename == StringConst.kTemplateAssignment || pagename == StringConst.kApprovalTemplate)) {
      projection = {'approvals': 1, "approvaltemplate": 1, "project": 1, "building": 1, "name": 1};
    }

    if (assignedproject == 1) {
      projection = {'approvals': 0};
    }

    var reqBody = assignedproject == 1
        ? {
            "paginationinfo": {
              "pageno": 1,
              "pagelimit": 99999999999,
              "filter": {"approvaltemplateid": parentId, "assignedproject": assignedproject},
              'projection': projection,
              "sort": {}
            }
          }
        : {
            "paginationinfo": {
              "pageno": 1,
              "pagelimit": 99999999999,
              "filter": {"_id": parentId},
              'projection': projection,
              "sort": {}
            }
          };
    devPrint("9846512786458465   " + pagename.toString());
    var response = await IISMethods().listData(
        userAction: 'list${getCurrentPageName() == StringConst.kDashboard ? 'approvals' : pageName.value.toString()}',
        pageName: getCurrentPageName() == StringConst.kDashboard ? 'approvals' : pageName.value.toString(),
        url: '${Config.weburl}${pagename.toString()}',
        reqBody: reqBody);
    setDefaultData.masterData[pagename.toString()] = response['data'];
    setDefaultData.masterFieldOrder.value = List<Map<String, dynamic>>.from(response['fieldorder']['fields'] ?? []);
  }

  Future deleteMasterData({reqData, pageName}) async {
    String url = pageName == StringConst.kApprovals ? '${Config.weburl + pageName}/deletedocument' : '${Config.weburl + pageName}/approvaldelete';

    String userAction = "deleteproject";

    var resBody = await IISMethods().deleteData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName);
    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody['message'];
      getMasterFormData(parentId: reqData['_id'], pagename: pageName);
      Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody['message'];
      Get.back();
      showError(message.value);
    }
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
      if (pageName.value == RouteNames.kUsers.split('/').last && fieldObj['field'] == 'team') {
        filter['userid'] = setDefaultData.formData['_id'] ?? '';
      }
      if (pageName.value == RouteNames.kTeam.split('/').last && fieldObj['field'] == 'teammember') {
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

        devPrint("986457465316365   ${pageName.value}");

        var resBody = await IISMethods().listData(
            url: url,
            reqBody: reqBody,
            userAction: userAction,
            pageName: getCurrentPageName() == StringConst.kDashboard ? StringConst.kApprovals : pageName.value,
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

  Future setMasterFormData({String? id, String? parentId, String? parentNameString, String? projectid, int? editeDataIndex, bool? clone, String? page}) async {
    dialogBoxData.value = ApprovalJson.designationFormFields(page.toString());
    masterFormLoadingData.value = true;
    initialStateData['lastEditedDataIndex'] = editeDataIndex;
    setDefaultData.masterFormData.value = {};
    updateObj.value = false;
    uploadedFile.value = {};
    var tempFormData = {};
    if (id != null) {
      tempFormData = await IISMethods().getObjectFromArray(setDefaultData.masterData[page.toString()], '_id', id);
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
            case HtmlControls.kAvatarPicker:
            case HtmlControls.kImagePicker:
            case HtmlControls.kFilePicker:
              tempFormData[fields["field"]] = FilesDataModel().toJson();
              break;
            case HtmlControls.kTable:
              tempFormData[fields["field"]] = <Map<String, dynamic>>[];
              break;
            default:
              tempFormData[fields["field"]] = fields["defaultvalue"] ?? '';
              break;
          }
        });
      }
    }

    setDefaultData.masterFormData.value = Map<String, dynamic>.from(tempFormData);
    setDefaultData.masterFormData['_id'] = parentId;
    if (parentNameString.isNotNullOrEmpty) {
      setDefaultData.masterFormData['approvaltemplate'] = parentNameString;
      setDefaultData.masterFormData['approvaltemplateid'] = parentId;
    }
    if (projectid.isNotNullOrEmpty) {
      setDefaultData.masterFormData['projectid'] = projectid;
    }

    ///comment temp
    for (var data in dialogBoxData["formfields"]) {
      for (var fields in data["formFields"]) {
        devPrint("9786451233584    $fields");
        if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
          var isTrue = fields.containsKey("masterdatadependancy");
          if (isTrue) {
            isTrue = fields["masterdatadependancy"];
          }
          if (isTrue ||
              !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) ||
              fields["isselfrefernce"] == null ||
              fields["setvaluefromlogininfo"] == null) {
            await getMasterData(pageNo: 1, fieldObj: fields, formData: setDefaultData.masterFormData);
            var masterDataKey = fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"];
            if (setDefaultData.masterData[masterDataKey] != null && setDefaultData.masterData[masterDataKey].isNotEmpty && autoFilling) {
              await handleMasterFormData(
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
    jsonPrint(tag: "9785451245   ", setDefaultData.masterFormData);
    masterFormLoadingData.value = false;
    update();
  }

  Future handleMasterFormData({
    type,
    key,
    value,
    fieldType,
    fieldKey,
    fieldValue,
    frequencydays,
    onChangeFill = true,
  }) async {
    switch (type) {
      case HtmlControls.kNumberInput:
        if (value.toString().contains(".")) {
          setDefaultData.masterFormData[key] = double.tryParse(value?.toString() ?? '0');
        } else {
          setDefaultData.masterFormData[key] = int.tryParse(value?.toString() ?? '0');
        }
        break;
      case HtmlControls.kMultiSelectDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        try {
          if (fieldObj.containsKey("masterdataarray")) {
            try {
              for (var e in value) {
                setDefaultData.masterFormData[key].add({
                  "${fieldObj["field"]}id": e,
                  "${fieldObj["field"]}": e,
                });
              }
            } catch (e) {
              setDefaultData.masterFormData[key] = [];
            }
          } else {
            setDefaultData.masterFormData[key] = [];
            for (var e in value) {
              var masterDataKey = fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"];
              var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[masterDataKey], "_id", e);

              setDefaultData.masterFormData[key].add({
                "${fieldObj["field"]}id": e,
                "${fieldObj["field"]}": res[fieldObj["masterdatafield"]],
              });
              // if (key == 'clustermanager') {
              //   setDefaultData.masterFormData[key].last["name"] = res['name'] ?? '';
              //   setDefaultData.masterFormData[key].last["email"] = res['email'] ?? '';
              //   setDefaultData.masterFormData[key].last["userrole"] = res['userrole'] ?? '';
              //   setDefaultData.masterFormData[key].last["userroleid"] = res['userroleid'] ?? '';
              // }
            }
          }
        } catch (e) {
          setDefaultData.masterFormData[key] = [];
        }
        break;
      case HtmlControls.kFilePicker:
      case HtmlControls.kImagePicker:
      case HtmlControls.kAvatarPicker:
        {
          value as List<FilesDataModel>;
          value = List<FilesDataModel>.from(await IISMethods().uploadFiles(value));
          if (value.isNotEmpty) {
            Map oldData = IISMethods().encryptDecryptObj(setDefaultData.masterFormData[key]);
            setDefaultData.masterFormData[key] = value.first.toJson();
            if (oldData['old'] == null) {
              setDefaultData.masterFormData[key]['old'] = IISMethods().encryptDecryptObj(oldData);
            } else {
              setDefaultData.masterFormData[key]['old'] = IISMethods().encryptDecryptObj(oldData['old']);
            }
          }
        }
        break;

      case HtmlControls.kDatePicker:
        setDefaultData.masterFormData[key] = value ?? '';
        devPrint("6874516416341654");
        devPrint(key);
        devPrint(value);
        final currentDate = DateTime.parse(setDefaultData.masterFormData[key] ?? DateTime.now().toString());
        String nextDate = currentDate.add(Duration(days: frequencydays)).toString();
        devPrint("next date from ${setDefaultData.masterFormData[key]} : $nextDate");
        if (key == "date") {
          await handleMasterFormData(
            key: "expirydate",
            value: nextDate,
            type: HtmlControls.kDatePicker,
          );
        }
        // dialogBoxData.refresh();
        break;

      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        if (fieldObj["masterdataarray"] != null) {
          setDefaultData.masterFormData[key] = value ?? '';
        } else {
          var res = await IISMethods()
              .getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
          setDefaultData.masterFormData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
          setDefaultData.masterFormData[key] = res?["_id"];
          // if (key == 'pincodeid') {
          //   setDefaultData.masterFormData["area"] = res['area'];
          //   setDefaultData.masterFormData["city"] = res['city'];
          // }
          if (key == 'subapprovalcategoryid') {
            devPrint("465321896541652   ${res['frequencyduration']}");
            setDefaultData.masterFormData['frequencyduration'] = res['frequencyduration'] ?? '';
            setDefaultData.masterFormData['frequency'] = res['frequency'] ?? '';
            setDefaultData.masterFormData['frequencyunit'] = res['frequencyunit'] ?? '';
            setDefaultData.masterFormData['frequencyunitid'] = res['frequencyunitid'] ?? '';
          }
          // if (key == 'projectmanagerid' && value != null) {
          //   setDefaultData.masterFormData["name"] = res['name'] ?? '';
          //   setDefaultData.masterFormData["email"] = res['email'] ?? '';
          //   setDefaultData.masterFormData["userrole"] = res['userrole'] ?? '';
          //   setDefaultData.masterFormData["userroleid"] = res['userroleid'] ?? '';
          // }
          // devPrint(setDefaultData.masterFormData.toJson() + "    12784565");
        }

        break;
      case HtmlControls.kCheckBox:
        setDefaultData.masterFormData[key] = value ? 1 : 0;
      default:
        setDefaultData.masterFormData[key] = value;
    }
    // if(dialogBoxData['pagename'] == 'managerassign'){
    //   setDefaultData.masterFormData['managerassign'] = (setDefaultData.masterFormData['managerassign'] as List).map((e) => )
    // }

    var obj = getObjectFromFormData(dialogBoxData["formfields"], key);

    if (obj["onchangefill"] != null && onChangeFill) {
      for (var field in obj["onchangefill"]) {
        var obj2 = getObjectFromFormData(dialogBoxData["formfields"], field);
        if (obj2["type"] == HtmlControls.kDropDown) {
          await handleFormData(type: obj2['type'], key: obj2["field"], value: '');
        } else if (obj2["type"] == HtmlControls.kMultiSelectDropDown) {
          setDefaultData.masterFormData[field] = [];
        }
        await getMasterData(pageNo: 1, fieldObj: obj2, formData: setDefaultData.masterFormData);
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

    // setManagerAssignData();

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
            case HtmlControls.kTable:
              tempFormData[fields['field']] = [];
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
        devPrint("13256633656   $fields");
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
      case HtmlControls.kDatePicker:
        setDefaultData.formData[key] = value ?? '';
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
          devPrint("4653214556453465896541652   $res");
          devPrint("4653214556453465896541652   $key");
          if (key == 'subapprovalcategoryid') {
            devPrint('HELLO');
            jsonPrint("${res?['frequencyduration']}", tag: '465321896541652 ');
            setDefaultData.formData['frequencyduration'] = res?['frequencyduration'] ?? '';
            setDefaultData.formData['frequency'] = res?['frequency'] ?? '';
            setDefaultData.formData['frequencyunit'] = res?['frequencyunit'] ?? '';
            setDefaultData.formData['frequencyunitid'] = res?['frequencyunitid'] ?? '';
          }
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
    update();
  }

  handleGridChange({required int index, required String field, required String type, dynamic value}) async {
    switch (type) {
      case HtmlControls.kStatus:
        setDefaultData.data[index][field] = value ? 1 : 0;
        if (await updateData(reqData: setDefaultData.data[index], editeDataIndex: index)) {
          Get.back();
        }
      case HtmlControls.kSwitch:
        setDefaultData.data[index][field] = value ? 1 : 0;
        updateData(reqData: setDefaultData.data[index], editeDataIndex: index);
    }
  }

  handleAddButtonClick({String? pagename, bool isGetBack = true}) async {
    if (setDefaultData.formData.containsKey('_id')) {
      if (await updateData(reqData: setDefaultData.formData)) {
        Get.back();
      }
    } else {
      devPrint("8653418654163");
      if (await addData(reqData: setDefaultData.formData)) {
        if (isGetBack) {
          Get.back();
        }
      }
    }
  }

  handleMasterAddButtonClick({String? pagename, bool isGetBack = true}) async {
    if (pagename == "${StringConst.kApprovalTemplate}/add" ||
        pagename == "${StringConst.kTemplateAssignment}/approvaladd" ||
        pagename == "${StringConst.kApprovals}/uploaddocument" ||
        getCurrentPageName() == StringConst.kDashboard) {
      var url = getCurrentPageName() == StringConst.kDashboard ? pagename = "${Config.weburl}${StringConst.kApprovals}/uploaddocument " : pagename = '${Config.weburl}$pagename';
      var userAction = "add$pageName";
      jsonPrint(tag: "89652565656456456456", reqLocalListOfEntries);
      devPrint("8965256565654456456456  $url");
      // var resBody = await IISMethods().addData(url: url, reqBody: setDefaultData.masterFormData, userAction: userAction, pageName: getCurrentPageName() == StringConst.kDashboard ? StringConst.kApprovals : pageName.value);
      var resBody = await IISMethods().addData(
          url: url, reqBody: reqLocalListOfEntries, userAction: userAction, pageName: getCurrentPageName() == StringConst.kDashboard ? StringConst.kApprovals : pageName.value);

      statusCode.value = resBody["status"];
      if (resBody["status"] == 200) {
        message.value = resBody["message"];

        // getMasterFormData(
        //     parentId: resBody['data']['_id'] ?? "",
        //     pagename: getCurrentPageName() == StringConst.kDashboard ? StringConst.kApprovals : pageName.value);
        getList();

        // await getList();
        isGetBack ? Get.back() : null;
        // await setMasterFormData(page: pagename, parentId: setDefaultData.masterFormData['approvaltemplateid'], parentNameString: setDefaultData.masterFormData['approvaltemplate']);
        showSuccess(message.value);
      } else {
        message.value = resBody["message"];
        showError(message.value);
      }
    } else if (pagename == "projectassign") {
      var url = '${Config.weburl}${StringConst.kTemplateAssignment}/add';
      var userAction = "add$pageName";

      var resBody = await IISMethods().addData(url: url, reqBody: setDefaultData.masterFormData, userAction: userAction, pageName: pageName.value);

      statusCode.value = resBody["status"];
      if (resBody["status"] == 200) {
        message.value = resBody["message"];
        isGetBack ? Get.back() : null;
        showSuccess(message.value);
      } else {
        message.value = resBody["message"];
        showError(message.value);
      }
    } else if (setDefaultData.masterFormData.containsKey('_id')) {
      updateMasterData(reqData: setDefaultData.masterFormData, pagename: pagename);
    } else {
      addMasterData(reqData: setDefaultData.masterFormData, pageName: pagename);
    }
    update();
  }

  handleTableAddButtonClick({bool isMasterData = false, var field}) async {
    field = getObjectFromFormData(dialogBoxData["formfields"], field['field']);

    Map<String, dynamic> formData = IISMethods().encryptDecryptObj(isMasterData ? setDefaultData.masterFormData : setDefaultData.formData);

    // 4556565

    if (formData[field['field']] == null) {
      formData[field['field']] = [];
    }
    jsonPrint(tag: "8654653465134", formData);

    Map<String, dynamic> rowData = {};
    for (var fieldOrder in field['fieldorder']) {
      if (fieldOrder['field'].toString().isNotNullOrEmpty) {
        rowData[fieldOrder['field']] = IISMethods().encryptDecryptObj(formData[fieldOrder['field']]);
      }
    }

    jsonPrint(rowData, tag: "   123456563541");
    jsonPrint(formData, tag: "   1234565635415464");

    bool isDuplicate = (formData[field['field']] as List).any((existingRow) {
      return existingRow['constructionstageid'] == rowData['constructionstageid'] &&
          existingRow['approvalcategoryid'] == rowData['approvalcategoryid'] &&
          existingRow['subapprovalcategoryid'] == rowData['subapprovalcategoryid'] &&
          existingRow['governmentauthorityid'] == rowData['governmentauthorityid'] &&
          existingRow['frequencyunitid'] == rowData['frequencyunitid'] &&
          existingRow['frequency'] == rowData['frequency'];
    });

    if (!isDuplicate) {
      // Reset the form fields
      for (var fieldOrder in field['fieldorder']) {
        formData[fieldOrder['field']] = '';
      }
      (formData[field['field']] as List).add(rowData);

      if (isMasterData) {
        setDefaultData.masterFormData.value = IISMethods().encryptDecryptObj(formData);
      } else {
        setDefaultData.formData.value = IISMethods().encryptDecryptObj(formData);
      }

      jsonPrint(formData, tag: "   8645165354563541");
    } else {
      devPrint("8645165354563541 Duplicate entry detected, not adding to list");
      showError("Duplicate entry not allowed");
    }
  }

  Future updateMasterData({
    required Map reqData,
    String? pagename,
    int? editeDataIndex = -1,
  }) async {
    var url = '${Config.weburl}${pagename.toString()}/update';

    var userAction = "updatetenantproject";

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: userAction, pageName: 'tenantproject');

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = await resBody["message"];
      var updatedDataIndex = editeDataIndex! > -1 ? editeDataIndex : initialStateData["lastEditedDataIndex"] ?? -1;

      getMasterFormData(parentId: reqData['_id'], pagename: pagename);
      showSuccess(message.value);

      Get.back();
    } else {
      message.value = resBody['message'];
      showError(message.value);
    }
    update();
  }

  Future addMasterData({reqData, pageName}) async {
    var url = '${Config.weburl}$pageName/add';

    var userAction = "addtenantproject";

    var resBody = await IISMethods().addData(url: url, reqBody: reqData, userAction: userAction, pageName: 'tenantproject');

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody["message"];
      getMasterFormData(parentId: reqData['_id'], pagename: pageName);
      Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody["message"];
      showError(message.value);
    }
  }

  Future<bool> addData({
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
      // Get.back();
      devPrint("resBody['_id']:    ${(resBody['data']['_id']).toString()}");
      devPrint("resBody['name']:    ${(resBody['data']['name']).toString()}");
      templateParentId.value = resBody['data']['_id'] ?? "";
      templateParentName.value = resBody['data']['name'] ?? "";
      showSuccess(message.value);
    } else {
      message.value = resBody["message"];
      showError(message.value);
    }
    return resBody["status"] == 200;
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

  Future setFilterData({String? id, int? editeDataIndex, bool? clone}) async {
    formLoadingData.value = true;
    initialStateData['lastEditedDataIndex'] = editeDataIndex;
    setDefaultData.formData.value = {};
    updateObj.value = false;
    Map<String, dynamic> tempFormData = {};
    if (setDefaultData.filterData.keys.isNotEmpty) {
      tempFormData = setDefaultData.filterData.value;
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
            case HtmlControls.kMultiSelectDropDown:
              tempFormData[fields["filterfield"]] = [];
              break;
            default:
              tempFormData[fields["filterfield"]] = fields['defaultvalue'] ?? '';
              break;
          }
        }
      }
    }

    setDefaultData.filterData.value = Map<String, dynamic>.from(tempFormData);
    setDefaultData.oldFilterData.value = IISMethods().encryptDecryptObj(setDefaultData.filterData.value);

    for (var fields in setDefaultData.fieldOrder) {
      devPrint("646781376841   $fields");
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
          if (setDefaultData.masterData[masterDataKey] != null && setDefaultData.masterData[masterDataKey].isNotEmpty && false) {
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
