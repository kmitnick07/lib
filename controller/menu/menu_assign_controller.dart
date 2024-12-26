import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/json/menu_assign_json.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../routes/route_generator.dart';
import '../../routes/route_name.dart';

class MenuAssignController extends GetxController {
  RxString pageName = ''.obs;
  RxString formName = ''.obs;
  RxString message = ''.obs;
  RxString parentId = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  RxMap dialogBoxData = {}.obs;
  Map validator = {};
  Map<int, FocusNode> focusNodes = {};
  RxMap<String, dynamic> uploadedFile = <String, dynamic>{}.obs;
  RxInt statusCode = 0.obs;
  RxBool loadingData = true.obs;
  RxBool formLoadingData = false.obs;
  RxBool updateObj = false.obs;
  final formKey0 = GlobalKey<FormState>();
  int cursorPos = 0;
  bool validateForm = false;
  TextEditingController searchController = TextEditingController();
  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};

  @override
  Future<void> onInit() async {
    pageName.value = getCurrentPageName();
    devPrint(pageName.value);
    dialogBoxData.value = MenuAssignJson.designationFormFields(pageName.value);
    formName.value = dialogBoxData['formname'] ?? "";
    setPageTitle('${formName.value} | PRENEW', Get.context!);

    formName.refresh();

    await setFormData();
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<MenuAssignController>();
    super.dispose();
  }

  Future<void> getList({
    String? moduletypeid,
    String? moduleid,
    String? searchtext,
  }) async {
    loadingData.value = true;
    final url = Config.weburl + pageName.value;
    final userAction = "list$pageName";
    var filter = {};
    filter['moduleid'] = moduleid ?? '';
    filter['moduletypeid'] = moduletypeid ?? '';
    if (setDefaultData.data == []) {
      setDefaultData.pageNo = 1.obs;
    }
    filter.remove('searchtext');
    final reqBody = {
      'searchtext': searchtext ?? '',
      'paginationinfo': {
        'pageno': setDefaultData.pageNo.value,
        'pagelimit': setDefaultData.pageLimit,
        'filter': filter,
        'sort': setDefaultData.sortData,
      },
    };
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;

    if (resBody["status"] == 200) {
      if (setDefaultData.pageNo.value == 1) {
        setDefaultData.data.value = [];
      }
      setDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data']);
      setDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"]);

      setDefaultData.pageName = resBody['pagename'];
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

    setDefaultData.fieldOrder.refresh();
    setDefaultData.data.refresh();
    loadingData.value = false;
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
      var projection = {};

      if (fieldObj["projection"] != null) {
        projection = {...fieldObj["projection"]};
      }
      var masterDataKey = fieldObj["storemasterdatabyfield"] == true || storeMasterDataByField! ? fieldObj["field"] : fieldObj["masterdata"];

      if (setDefaultData.masterDataList.containsKey(masterDataKey) && !fieldObj.containsKey('dependentfilter')) {
        return;
      }

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
    validateForm = false;
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
            devPrint(masterDataKey);
            if (setDefaultData.masterData[masterDataKey] != null && setDefaultData.masterData[masterDataKey].isNotEmpty) {
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

  List<dynamic> primaryParentData = [];

  void setPrimaryParentData(List<dynamic> value) {
    primaryParentData = value;
  }

  List<dynamic> childrenData = [];

  void setChildrenData(List<dynamic> value) {
    childrenData = value;
  }

  List<dynamic> changedPrimaryParentData = [];

  void setChangedPrimaryParentData(List<dynamic> value) {
    changedPrimaryParentData = value;
  }

  List<dynamic> changedChildrenData = [];

  void setChangedChildrenData(List<dynamic> value) {
    changedChildrenData = value;
  }

  Map<String, dynamic> changedFormData = {};

  void setChangedFormData(Map<String, dynamic> value) {
    changedFormData = value;
  }

  Future handleResetButtonClick() async {
    setDefaultData.data.value = [];
    await getList(
      moduletypeid: setDefaultData.formData["moduletypeid"],
      moduleid: setDefaultData.formData["moduleid"],
    );
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

      case HtmlControls.kFilePicker:
      case HtmlControls.kImagePicker:
        {
          if (value is String) {
            setDefaultData.formData[key] = value;
          } else {
            var obj = getObjectFromFormData(dialogBoxData['formfields'], key);

            var url = '' /*await uploadAttachment(fileBytes: value.files.first.bytes, extension: "jpeg")*/;
            if (url != null) {
              setDefaultData.formData[key] = url;
            } else {
              uploadedFile[obj["field"]] = '';
            }
          }
          uploadedFile[key] = value.files.first.name ?? "";
        }
        break;

      case HtmlControls.kAvatarPicker:
        {
          if (value is String) {
            setDefaultData.formData[key] = value;
          } else {
            var obj = getObjectFromFormData(dialogBoxData['formfields'], key);

            var url = '' /*await uploadAttachment(fileBytes: value.files.first.bytes, extension: "jpeg")*/;
            if (url != null) {
              setDefaultData.formData[key] = url;
            } else {
              uploadedFile[obj["field"]] = '';
            }
          }
          uploadedFile[key] = value?.files.first.name ?? "";
        }
        break;
      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        var res = await IISMethods()
            .getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);

        setDefaultData.formData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
        setDefaultData.formData[key] = res?["_id"];
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
        if (setDefaultData.masterData[masterDataKey]?.length >= 1) {
          await handleFormData(
            key: obj2["field"],
            value: setDefaultData.masterData[masterDataKey]?.first['value'],
            type: obj2['type'],
          );
        }
      }
    }
    if (key == 'moduleid') {
      getList(
        moduletypeid: setDefaultData.formData['moduletypeid'],
        moduleid: setDefaultData.formData['moduleid'],
      );
    }
    update();
  }

  handleGrid({id, type, key, value, editeDataIndex}) async {
    if (type == HtmlControls.kCheckBox) {
      var object = await IISMethods().getObjectFromArray(setDefaultData.data.value, '_id', id);
      object[key] = value ? 1 : 0;
      await updateData(reqData: object, changeFormData: editeDataIndex);
      if (statusCode.value == 400) {
        object[key] = 1;
      }
    } else {}
  }

  Future handleSwitches(e, id, field) async {
    var data = await IISMethods().getObjectFromArray(setDefaultData.data, '_id', id);

    data[field] = (e ? 1 : 0);

    var index = setDefaultData.data.indexWhere((obj) => obj["_id"] == data["_id"]);

    if (field == "isparent") {
      setDefaultData.data.map((object) {
        if (object["isassigned"] == 1) {
          object["parentid"] = id;
          object["menuid"] = id;
        }
      });
    }
    setDefaultData.data[index][field] = (e ? 1 : 0);
    if (setDefaultData.formData["parentid"] != null) {
      setDefaultData.data[index]['parentid'] = id;
      setDefaultData.data[index]["menuid"] = id;
    } else {
      setDefaultData.data[index]['parentid'] = id;
      setDefaultData.data[index]['menuid'] = id;
    }

    if (field == 'isassigned' && !e) {
      setDefaultData.data[index]["parentid"] = '';
      setDefaultData.data[index]["menuid"] = '';
    }

    var tempSelectedData = [];

    for (var object in setDefaultData.data) {
      if (object["isassigned"] == 1) {
        tempSelectedData.add(object);
      }
    }

    if (setDefaultData.formData["parentid"] != null) {
      setChangedChildrenData([...tempSelectedData]);
    } else {
      setChangedPrimaryParentData([...tempSelectedData]);
    }
  }

  Future handleGridSwitches(e, id, field) async {
    devPrint('GELO');
    var data = await IISMethods().getObjectFromArray(setDefaultData.data, '_id', id);
    for (var data in setDefaultData.data) {
      data[field] = 0;
    }
    parentId.value = id;
    data['isassigned'] = (e ? 1 : 0);
    data[field] = (e ? 1 : 0);
    setDefaultData.data[setDefaultData.data.indexWhere((element) => element['_id'] == id)] = data;
    setDefaultData.data.refresh();
  }

  var array = [
    "menuname",
    "formname",
    "iconid",
    "iconstyle",
    "iconclass",
    "iconunicode",
    "alias",
    "isindividual",
    "isparent",
    "isassigned",
    "parentid",
    "containright",
    "defaultopen",
    "displayorder",
    "displayinsidebar",
    "canhavechild",
    "_id",
    "menuid"
  ];

  Future handleSaveButtonClick({e, changeFormData = false}) async {
    int count = 0;
    var reqe = {
      "moduleid": setDefaultData.formData["moduleid"],
      "module": setDefaultData.formData["module"],
      "moduletypeid": setDefaultData.formData["moduletypeid"],
      "data": await temp(setDefaultData.data, array, count),
      "removedparent": await getRemovedMenus(),
    };
    await updateData(reqData: reqe, changeFormData: changeFormData);
  }

  Future getRemovedMenus() async {
    var tempArray = [];
    for (int i = 0; i < primaryParentData.length; i++) {
      if (await IISMethods().getIndexFromArray(changedPrimaryParentData, '_id', primaryParentData[i]["_id"]) == -1) {
        tempArray.add(primaryParentData[i]["_id"]);
      }
    }

    if (setDefaultData.formData["parentid"] != null) {
      for (int i = 0; i < childrenData.length; i++) {
        if (IISMethods().getIndexFromArray(changedChildrenData, '_id', childrenData[i]["_id"]) == -1) {
          tempArray.add(childrenData[i]._id);
        }
      }
    }

    return tempArray;
  }

  Future updateData({required Map reqData, changeFormData = false}) async {
    var url = '${Config.weburl + pageName.value}/update';

    var userAction = "update$pageName";

    var resBody = await IISMethods().updateData(
      url: url,
      reqBody: reqData,
      userAction: userAction,
      pageName: pageName.value,
    );
    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody['message'];
      handleGrid(value: false, type: 'modal', key: 'savechangesmodal', editeDataIndex: 0);
      if (changeFormData) {
        setPrimaryParentData([...changedPrimaryParentData]);
        var tmpMasterData = [];
        changedPrimaryParentData.map((primaryparent) {
          if (primaryparent.containsKey("canhavechild")) {
            tmpMasterData.add({"label": primaryparent["menuname"], "value": primaryparent["_id"]});
          }
        });
        setDefaultData.masterData.value = {
          ...setDefaultData.masterData.value,
          'priparyparents': [...tmpMasterData]
        };
      }

      setDefaultData.data.value = [];
      if (changeFormData) {
        await handleFormData(type: changedFormData["type"], key: changedFormData["key"], value: changedFormData["value"]);
      } else {
        await getList(
          moduletypeid: setDefaultData.formData["moduletypeid"],
          moduleid: setDefaultData.formData["moduleid"],
        );
      }
    } else {
      message.value = resBody['message'];
    }
    update();
  }

  Future temp(data, List<String> target, count) async {
    if (parentId.value.isEmpty) {
      parentId.value = setDefaultData.data.where((e) => e['isparent'] == 1).toList().first['_id'];
    }
    var temparray = [];
    data.forEach((object) {
      if (object.keys.isNotEmpty && object['isassigned'] == 1) {
        temparray.add({});
        for (var entry in object.entries) {
          var key = entry.key;
          var value = entry.value;
          if (target.contains(key)) {
            if (key == "_id") {
              temparray[count]['menuid'] = value;
            } else {
              temparray[count][key] = value;
            }
            temparray[count]['parentid'] = parentId.value;
          }
        }
        temparray[count]['iconimage'] = object['iconimage'];
        count = count + 1;
      }
    });
    return temparray;
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
    } else {
      message.value = resBody["message"];
    }
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
