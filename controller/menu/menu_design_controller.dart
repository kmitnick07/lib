import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/json/menu_assign_json.dart';

import '../../../config/config.dart';
import '../../components/funtions.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../routes/route_generator.dart';

class MenuDesignController extends GetxController {
  String pageName = "";
  RxString message = "".obs;
  RxBool hasError = false.obs;
  RxInt statusCode = 0.obs;
  RxBool loadingData = false.obs;
  RxBool loadingMenuData = true.obs;
  RxMap uploadedFile = {}.obs;
  RxMap dialogBoxData = {}.obs;

  final formKey = GlobalKey<FormState>();
  RxBool isAddVisible = true.obs;
  Map validation = {};
  RxBool validateForm = false.obs;

  @override
  Future<void> onInit() async {
    await clearData();
    dialogBoxData.value = await MenuAssignJson.designationFormFields("menudesign");
    setDefaultData["pagename"] = "menudesign";
    pageName = "menudesign";
    await fetch();
    setPageTitle('Menu Design | PRENEW', Get.context!);

    isAddVisible.value = true;

    super.onInit();
  }


  @override
  void dispose() {
    Get.delete<MenuDesignController>();
    super.dispose();
  }

  Future clearData() async {
    setDefaultData.value = <String, dynamic>{
      "fieldOrder": [],
      "newFieldOrder": [],
      "nextpage": 0,
      "pageNo": 1,
      "pagelimit": 20,
      "pageName": '',
      "sortData": {},
      "formData": {},
      "filterData": {},
      "oldFilterData": {},
      "modal": {},
      "masterData": {},
      "masterDataList": {},
    };
    update();
  }

  RxMap<String, dynamic> setDefaultData = <String, dynamic>{
    "fieldOrder": [],
    "newFieldOrder": [],
    "nextpage": 0,
    "pageNo": 1,
    "pagelimit": 2000,
    "pageName": '',
    "sortData": {},
    "formData": {},
    "filterData": {},
    "oldFilterData": {},
    "modal": {},
    "masterData": {},
    "masterDataList": {},
  }.obs;

  Future getList() async {
    loadingMenuData.value = true;
    var url = Config.weburl + pageName;
    var userAction = 'list${pageName}data';
    var filter = {};
    for (var entry in setDefaultData["filterData"].entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is num) {
        if (value == 1) {
          filter[key] = value;
        }
      } else {
        filter[key] = value;
      }
    }
    var resBody = await IISMethods()
        .listData(url: url, reqBody: {"userid": Settings.uid, "moduletypeid": setDefaultData['formData']['moduletypeid']}, userAction: userAction, pageName: pageName);
    if (resBody["status"] == 200) {
      setDefaultData["data"] = resBody["data"];
    } else {}
    loadingMenuData.value = false;
  }

  Future handleTreeData(tree) async {
    setDefaultData["data"] = List<dynamic>.from(tree);
  }

  String printSelectPicker(data, fieldObj) {
    if (fieldObj["masterdata"] == 'icon') {
      return data[fieldObj["masterdatafield"]].toString();
    } else if (fieldObj["masterdata"] == 'employee') {
      return data[fieldObj["masterdata"]].toString();
    } else if (fieldObj["masterdata"] == 'state' || fieldObj["masterdata"] == 'country') {
      return data[fieldObj["masterdata"]].toString();
    } else {
      return "${data[fieldObj["masterdatafield"]]}";
    }
  }

  fetch() async {
    loadingData.value = true;
    for (var data in dialogBoxData["formfields"]) {
      for (var fields in data["formFields"]) {
        if (fields.containsKey("masterdata") && !setDefaultData["masterData"].containsKey(fields["masterdata"]) && !fields.containsKey("masterdataarray")) {
          await getMasterData(pageNo: 1, fieldObj: fields, formData: setDefaultData["formData"]);
          if (setDefaultData["masterData"][fields["masterdata"]].length >= 1) {
            setDefaultData["formData"][fields["field"]] = setDefaultData["masterData"][fields["masterdata"]]?[0]["value"];
            setDefaultData["formData"][fields["masterdata"]] = setDefaultData["masterData"][fields["masterdata"]]?[0]["label"];
          }
        } else if (fields.containsKey("masterdata") &&
            fields.containsKey("masterdataarray") &&
            !setDefaultData["masterData"].containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
          var array = [];
          for (var object in fields["masterdataarray"]) {
            if (object.runtimeType == Object) {
              array.add(object);
            } else {
              array.add({"label": object, "value": object});
            }
          }
          setDefaultData["masterData"][fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]] = array;
          setDefaultData["masterData"] = Map<String, dynamic>.from(setDefaultData["masterData"]);
        }
      }
    }

    await getList();
    loadingData.value = false;
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
      var isTrue = fieldObj.containsKey("masterdatadependancy");
      if (isTrue) {
        isTrue = fieldObj["masterdatadependancy"];
      }
      if (!isTrue || isDepend == 1) {
        var url = Config.weburl + fieldObj["masterdata"];
        var userAction = 'list${fieldObj["masterdata"]}data';

        filter = {
          ...Map<String, dynamic>.from(fieldObj["filter"] ?? {}),
          ...filter,
        };
        var reqBody = {
          "paginationinfo": {"pageno": pageNo, "pagelimit": 500000000000, "filter": filter, "projection": projection, "sort": {}}
        };

        var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName, masterlisting: true);
        if (resBody["status"] == 200) {
          setDefaultData["masterData"] = Map<String, dynamic>.from(setDefaultData["masterData"]);
          setDefaultData["masterDataList"] = Map<String, dynamic>.from(setDefaultData["masterDataList"]);
          if (pageNo == 1) {
            setDefaultData["masterData"][masterDataKey] = [];
            setDefaultData["masterDataList"][masterDataKey] = [];
          }
          for (var data in resBody["data"]) {
            setDefaultData["masterData"][masterDataKey].add({"label": printSelectPicker(data, fieldObj), "value": data["_id"].toString()});
          }

          setDefaultData["masterDataList"][masterDataKey] = [...setDefaultData["masterDataList"][masterDataKey], ...resBody["data"]];

          setDefaultData['masterData'] = Map<String, dynamic>.from(setDefaultData['masterData']);
          setDefaultData['masterDataList'] = Map<String, dynamic>.from(setDefaultData['masterDataList']);

          if (resBody["nextpage"] == 1) {
            await getMasterData(pageNo: pageNo + 1, fieldObj: fieldObj, formData: formData, storeMasterDataByField: storeMasterDataByField);
          }
        }
      } else {
        setDefaultData["masterData"][masterDataKey] = [];
        setDefaultData["masterDataList"][masterDataKey] = [];
        setDefaultData['masterData'] = Map<String, dynamic>.from(setDefaultData['masterData']);
        setDefaultData['masterDataList'] = Map<String, dynamic>.from(setDefaultData['masterDataList']);
      }
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
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
    if (type == HtmlControls.kCheckBox) {
      setDefaultData["formData"][key] = (value ? 1 : 0);
    } else if (type == HtmlControls.kNumberInput) {
      if (value.toString().contains(".")) {
        setDefaultData["formData"][key] = double.parse(value?.toString() ?? '0');
      } else {
        setDefaultData["formData"][key] = int.parse(value?.toString() ?? '0');
      }
    } else if (type == HtmlControls.kTimePicker) {
      setDefaultData["formData"][key] = value ?? '';
    }
    /*else if (type == Config.htmlcontorls['image'] || type == Config.htmlcontorls['file']) {
      if (value is String) {
        setDefaultData["formData"][key] = value;
      } else {
        var obj = getObjectFromFormData(dialogBoxData['formfields'], key);
        if (!await IISMethods().checkFiletype(file: value, allowedFiles: obj['filetypes'])) {
          showError(Config.errmsg['invalidfile']!);
          uploadedFile[obj["field"]] = '';
          return;
        }
        
        if (url != null) {
          setDefaultData["formData"][key] = url;
        } else {
          uploadedFile[obj["field"]] = '';
        }
      }
    } */
    else if (type == HtmlControls.kDateRangePicker) {
      setDefaultData["formData"][key] = (value.isNotEmpty ? value : []);
    } else if (type == HtmlControls.kDropDown) {
      var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
      if (fieldObj["masterdataarray"] != null) {
        setDefaultData["formData"][key] = value ?? '';
      } else {
        try {
          var res = await IISMethods()
              .getObjectFromArray(setDefaultData["masterDataList"][fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
          setDefaultData["formData"][fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
          setDefaultData["formData"][key] = res?["_id"];
          if (key == 'moduletypeid') {
            await getList();
          }
        } catch (e) {
          debugPrint(e.toString());
          setDefaultData["formData"].remove(fieldObj["formdatafield"]);
          setDefaultData["formData"].remove(key);
        }
      }
    } else if (type == HtmlControls.kMultiSelectDropDown) {
      var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
      try {
        setDefaultData["formData"][key] = [];
        for (var e in value) {
          var obj = await IISMethods().getObjectFromArray(setDefaultData["masterDataList"][key], "_id", e);
          setDefaultData["formData"][key].add({
            "${fieldObj["field"]}id": e,
            "${fieldObj["field"]}": obj[fieldObj["formdatafield"]],
          });
        }
      } catch (e) {
        setDefaultData["formData"][key] = [];
      }
    } else {
      setDefaultData["formData"][key] = value;
      if (key == "bankname") {
        setDefaultData["formData"]["personname"] = value;
      }
    }

    var obj = getObjectFromFormData(dialogBoxData["formfields"], key);

    if (obj["onchangefill"] != null && onChangeFill) {
      for (var field in obj["onchangefill"]) {
        var obj2 = getObjectFromFormData(dialogBoxData["formfields"], field);
        if (obj2["type"] == HtmlControls.kDropDown) {
          await handleFormData(type: obj2['type'], key: obj2["field"], value: '');
        } else if (obj2["type"] == HtmlControls.kMultiSelectDropDown || obj2["type"] == HtmlControls.kDateRangePicker || obj2["type"] == HtmlControls.kTable) {
          setDefaultData["formData"][field] = [];
        }
        await getMasterData(pageNo: 1, fieldObj: obj2, formData: setDefaultData["formData"]);
        var masterDataKey = obj2["storemasterdatabyfield"] == true ? obj2["field"] : obj2["masterdata"];
        if (setDefaultData['masterData'][masterDataKey]?.length >= 1) {
          await handleFormData(
            key: obj2["field"],
            value: setDefaultData['masterData'][masterDataKey]?.first['value'],
            type: obj2['type'],
          );
        }
      }
    }

    update();
  }

  Future<Map<String, dynamic>> setMenuData(data, parentid) async {
    data["parentid"] = parentid;

    if (!data?.containsKey("menuid")) {
      data?["menuid"] = data?["moduleid"];
    }

    return data;
  }

  Future handleSaveButtonClick() async {
    var tempDataObj = setDefaultData["data"];
    tempDataObj.forEach((data) {
      data["parentid"] = !data.containsKey("menuid") ? data["moduleid"] : data["menuid"];
      data["isparent"] = 1 /*data["children"] != null && data["children"].isNotEmpty ? 1 : 0*/;

      if (!data.containsKey("menuid")) {
        data["menuid"] = data["moduleid"];
      }

      if (data["children"] == "undefined") {
        data["children"] = [];
      }

      data.remove("title");

      data["children"].forEach((primaryparent) {
        primaryparent["isparent"] = primaryparent.containsKey("children") && primaryparent["children"] != null && primaryparent["children"].isNotEmpty ? 1 : 0;
        primaryparent["parentid"] = data['menuid'];
        primaryparent["moduleid"] = data["moduleid"];

        primaryparent.remove("title");
      });
    });

    var reqe = {"userid": Settings.uid, "moduletypeid": setDefaultData['formData']['moduletypeid'], "menudesigndata": tempDataObj};
    await updateData(reqe);
  }

  Future updateData(reqData) async {
    var url = '${Config.weburl}$pageName/update';
    var userAction = 'update${pageName}data';

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName);

    if (resBody["status"] == 200) {
      setDefaultData["menuData"] = setDefaultData["data"];
      setDefaultData["data"] = [];
      await getList();
    }
  }

  Future handleApplyToAllButtonClick() async {
    var url = '${Config.weburl}$pageName/applyall';
    var userAction = 'update$pageName';
    var filter = {};
    for (var entry in setDefaultData["filterData"].entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is num) {
        if (value == 1) {
          filter[key] = value;
        }
      } else {
        filter[key] = value;
      }
    }

    var tempDataObj = setDefaultData["data"];
    tempDataObj.forEach((data) {
      data["parentid"] = !data.containsKey("menuid") ? data["moduleid"] : data["menuid"];
      data["isparent"] = data["children"] != null && data["children"].isNotEmpty ? 1 : 0;

      if (!data.containsKey("menuid")) {
        data["menuid"] = data["moduleid"];
      }

      if (data["children"] == "undefined") {
        data["children"] = [];
      }

      data.remove("title");

      data["children"].forEach((primaryparent) {
        primaryparent["isparent"] = primaryparent.containsKey("children") && primaryparent["children"] != null && primaryparent["children"].isNotEmpty ? 1 : 0;
        primaryparent["parentid"] = data['menuid'];
        primaryparent["moduleid"] = data["moduleid"];

        primaryparent.remove("title");
      });
    });

    var reqe = {"userid": Settings.uid, "moduletypeid": setDefaultData['formData']['moduletypeid'], "menudesigndata": tempDataObj};
    var resBody = await IISMethods().listData(url: url, reqBody: reqe, userAction: userAction, pageName: pageName);

    if (resBody["status"] == 200) {
      message.value = resBody["message"];
    } else {}
  }
}
