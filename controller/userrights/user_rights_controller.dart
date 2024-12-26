import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/funtions.dart';
import 'package:prestige_prenew_frontend/components/json/master_json.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

import '../../../config/config.dart';
import '../../config/iis_method.dart';
import '../../routes/route_generator.dart';

class UserRightController extends GetxController {
  String pageName = "";
  RxMap dialogBoxData = {}.obs;
  RxString message = "".obs;
  RxBool hasError = false.obs;
  RxInt statusCode = 0.obs;
  RxBool loadingData = true.obs;
  RxMap uploadedFile = {}.obs;

  TextEditingController searchController = TextEditingController();
  ScrollController verticalScroll = ScrollController();
  ScrollController horizontalScroll = ScrollController();
  RxBool selectAll = false.obs;
  RxBool isLoading = false.obs;
  Map<int, FocusNode> focusNodes = {};
  RxBool focusAssigned = true.obs;

  RxMap<String, dynamic> setDefaultData = <String, dynamic>{
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
  }.obs;

  RxMap<String, dynamic> state = {
    'selectall': false,
    'allviewright': false,
    'selfviewright': false,
    'alladdright': false,
    'selfaddright': false,
    'alleditright': false,
    'selfeditright': false,
    'alldelright': false,
    'selfdelright': false,
    'allprintright': false,
    'selfprintright': false,
    'requestright': false,
    'changepriceright': false,
    'allfinancialdata': false,
    'selffinancialdata': false,
    'allexportdata': false,
    'selfexportdata': false,
    'allimportdata': false,
    'seldimportdata': false,
    'sort': 1,
  }.obs;

  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};

  bool addButtonDisable = false;

  @override
  Future<void> onInit() async {
    await clearData();
    pageName = Get.rootDelegate.history.last.locationString.replaceAll("/", "");
    dialogBoxData.value = await MasterJson.designationFormFields(pageName);
    setDefaultData["pagename"] = pageName;
    setPageTitle('UserRights | PRENEW', Get.context!);

    await fetchData();
    super.onInit();
  }


  @override
  void dispose() {
    Get.delete<UserRightController>();
    super.dispose();
  }

  void setaddButtonDisable(bool value) {
    addButtonDisable = value;
  }

  bool defaultsetButtonDisable = false;

  void setdefaultsetButtonDisable(bool value) {
    defaultsetButtonDisable = value;
  }

  String searchValue = '';

  void setSearchValue(String value) {
    searchValue = value;
  }

  Map<String, dynamic> copyFormData = {
    'tocompanyid': '',
    'touserroles': [],
    'topersons': [],
  };

  void setcopyFormData(Map<String, dynamic> value) {
    copyFormData = value;
  }

  RxBool showShimmer = true.obs;

  Future<void> setShowShimmer(bool value) async {
    showShimmer.value = value;
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

  printSelectPicker(data, masterdata) {
    if (masterdata == 'userrole') {
      return "${data[masterdata]}";
    } else if (masterdata == "employee") {
      return "${data['personname']}";
    } else if (masterdata == 'userrightstemplatename') {
      return "${data["position"]}";
    } else if (masterdata == 'module') {
      return "${data['module']}";
    } else {
      return "${data[masterdata + 'name']}";
    }
  }

  Future fetchData() async {
    loadingData.value = true;
    for (var data in dialogBoxData["formfields"]) {
      for (var fields in data["formFields"]) {
        if (fields.containsKey("masterdata") && !setDefaultData["masterData"].containsKey(fields["masterdata"]) && !fields.containsKey("masterdatadependancy")) {
          await getMasterData(pageNo: 1, masterdata: fields["masterdata"], filter: {}, fieldObj: fields);
          setDefaultData["formData"][fields["field"]] = setDefaultData["masterData"][fields["masterdata"]]?[0]?["value"];
          setDefaultData["formData"][fields["masterdata"]] = setDefaultData["masterData"][fields["masterdata"]]?[0]["label"];
          if (fields["field"] != 'companyid') {
            if (fields.containsKey("onchangedata")) {
              for (var field in fields["onchangefill"]) {
                var filter = {};
                if (!(fields["field"] == 'userroleid')) {
                  fields["onchangedata"].map((data) => filter[data] = setDefaultData["formData"][data]);
                }
                var obj2;
                obj2 = await IISMethods().getObjectFromArray(data["formFields"], 'field', field);
                await getMasterData(pageNo: 1, masterdata: obj2["masterdata"], filter: filter, fieldObj: obj2, formData: setDefaultData["formData"]);

                try {
                  if (setDefaultData["masterData"][obj2["masterdata"]]?.isNotEmpty) {
                    setDefaultData["formData"][obj2["masterdata"] + 'id'] = setDefaultData["masterData"][obj2["masterdata"]]?.first["value"] ?? '';
                    setDefaultData["formData"][obj2["masterdata"]] = setDefaultData["masterData"][obj2["masterdata"]]?.first["label"] ?? '';
                  }
                } catch (e) {
                  debugPrint("Error:-${e.toString()}");
                }
              }
            }
          }
        }
      }
    }
    await handleFormData(type: 'dropdown', key: 'defaultuser', value: "");
    loadingData.value = false;
    await getList(
      personid: setDefaultData["formData"]["personid"],
      moduletypeid: setDefaultData["formData"]["moduletypeid"],
      userroleid: setDefaultData["formData"]["userroleid"],
    );
  }

  Future handleSort(fieldObj) async {
    state["sort"] = state["sort"] == 1 ? -1 : 1;
    setDefaultData["data"] = IISMethods().getCopy(setDefaultData["data"].reversed);
  }

  Future handleSearch(e) async {
    setSearchValue(e);
    var result = await handleAllSelected();
    if (result[0]) {
      state["allviewright"] = true;
    } else {
      state["allviewright"] = false;
    }
    if (result[1]) {
      state["selfviewright"] = true;
    } else {
      state["selfviewright"] = false;
    }
    if (result[2]) {
      state["alladdright"] = true;
    } else {
      state["alladdright"] = false;
    }
    if (result[3]) {
      state["selfaddright"] = true;
    } else {
      state["selfaddright"] = false;
    }
    if (result[4]) {
      state["alleditright"] = true;
    } else {
      state["alleditright"] = false;
    }
    if (result[5]) {
      state["selfeditright"] = true;
    } else {
      state["selfeditright"] = false;
    }
    if (result[6]) {
      state["alldelright"] = true;
    } else {
      state["alldelright"] = false;
    }
    if (result[7]) {
      state["selfdelright"] = true;
    } else {
      state["selfdelright"] = false;
    }
    if (result[8]) {
      state["allprintright"] = true;
    } else {
      state["allprintright"] = false;
    }
    if (result[9]) {
      state["selfprintright"] = true;
    } else {
      state["selfprintright"] = false;
    }
    if (result[10]) {
      state["allfinancialdata"] = true;
    } else {
      state["allfinancialdata"] = false;
    }
    if (result[11]) {
      state["selffinancialdata"] = true;
    } else {
      state["selffinancialdata"] = false;
    }
    if (result[12]) {
      state["requestright"] = true;
    } else {
      state["requestright"] = false;
    }
    if (result[13]) {
      state["changepriceright"] = true;
    } else {
      state["changepriceright"] = false;
    }
  }

  Future getMasterData({pageNo, masterdata, filter, fieldObj, formData}) async {
    var url = Config.weburl + masterdata;
    var userAction = 'list${masterdata}data';

    if (fieldObj['dependentfilter'] != null) {
      fieldObj['dependentfilter'].keys.forEach((key) {
        final value = formData?[fieldObj['dependentfilter'][key]];
        if (value != null) {
          filter[key] = value;
        }
      });
    }

    if (fieldObj.containsKey("staticfilter")) {
      filter as Map;
      filter = {...filter, ...fieldObj["staticfilter"]};
    }

    var projection = {};

    if (fieldObj.containsKey("projection")) {
      projection = {...fieldObj["projection"]};
    }

    var reqBody = {
      "paginationinfo": {
        "pageno": pageNo,
        "pagelimit": 5000000000000,
        "filter": filter ?? {},
        "projection": projection,
        "sort": {},
      }
    };

    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName, masterlisting: false);
    if (resBody["status"] == 200) {
      var object = setDefaultData["masterData"];
      var object2 = setDefaultData["masterDataList"];

      var moduleData = [];
      var allModuleData = [];

      if (pageNo == 1) {
        object[masterdata] = [];
        object2[masterdata] = [];
      }

      {
        for (var data in resBody["data"]) {
          devPrint(fieldObj['masterdatafield']);
          object[masterdata].add({"label": data[fieldObj['masterdatafield']], "value": data["_id"]});
        }
      }

      object2[masterdata] = [...object2[masterdata], ...resBody["data"]];

      /*if (fieldObj["masterdata"] == 'module') {
        setDefaultData["masterData"] = await IISMethods().getCopy({...object, "module": moduleData});
        setDefaultData["masterDataList"] = await IISMethods().getCopy({...object2, "module": allModuleData});
      } else */
      {
        setDefaultData["masterData"] = object;
        setDefaultData["masterDataList"] = object2;
      }
    } else {}
  }

  Future getCopyFormMasterData({pageNo, masterdata, filter, fieldobj, formData}) async {
    var url = Config.weburl + masterdata;
    var useraction = '${'list' + masterdata}data';

    if (fieldobj.containsKey("dependentfilter")) {
      fieldobj["dependentfilter"].map((key) {
        var value;
        if (key == 'userrolearr') {
          var useroleid = [];
          try {
            useroleid = formData['touserroles'].map((data) => data['userroleid']);
          } catch (e) {
            useroleid = [];
          }
          value = useroleid;
        } else {
          value = formData[fieldobj.dependentfilter[key]] ?? '';
        }

        if (value) {
          filter[key] = value;
        }
      });
    }

    if (fieldobj.containsKey("staticfilter")) {
      filter as Map;
      filter = {...filter, ...fieldobj["staticfilter"]};
    }

    var reqBody = {
      "paginationinfo": {"pageno": pageNo, 'pagelimit': pageLimit[pageLimit.length - 1]["value"], "filter": filter ? filter : {}, "sort": {}}
    };

    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: useraction, pageName: pageName);

    if (resBody["status"] == 200) {
      var object = setDefaultData["masterData"];
      var object2 = setDefaultData["masterDataList"];

      var masterdatakey = fieldobj?["storemasterdatabyfield"] == true ? fieldobj["field"] : fieldobj["masterdata"];
      if (pageNo == 1) {
        object[masterdatakey] = [];
        object2[masterdatakey] = [];
      }
      if (masterdata == "userrightsemployee") {
        resBody["data"].map((data) {
          if (IISMethods().getObjectFromArray(data["userrole"], 'userroleid', Config.adminutype) == -1) {
            object[masterdatakey].add({"label": printSelectPicker(data, masterdata), 'value': data["_id"], 'branch': data["branch"], "userrole": data["userrole"]});
          }
        });
      } else if (masterdata == "userrole") {
        resBody["data"].map((data) {
          if (Config.adminutype != data["_id"]) {
            object[masterdatakey].add({"label": printSelectPicker(data, masterdata), 'value': data["_id"], 'branch': data["branch"], 'userrole': data["userrole"]});
          }
        });
      } else {
        resBody["data"].map((data) => object[masterdatakey].add({"label": printSelectPicker(data, masterdata), "value": data["_id"]}));
      }
      object2[masterdatakey] = [...object2[masterdatakey], ...resBody["data"]];

      setDefaultData["masterData"] = object;
      setDefaultData["masterDataList"] = object2;
    } else {}
  }

  Future handleFormData({type, key, value, defaultuser = false}) async {
    if (type == HtmlControls.kCheckBox || type == HtmlControls.kSwitch) {
      setDefaultData["formData"][key] = (value ? 1 : 0);
    } else if (type == HtmlControls.kTimePicker || type == HtmlControls.kDatePicker) {
      setDefaultData["formData"][key] = value;
    } else if (type == HtmlControls.kDropDown) {
      if (key == 'defaultuser') {
        setDefaultData["formData"]["defaultuser"] = value;
        setDefaultData["formData"]["moduleid"] = '*';
      } else {
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        if (fieldObj["masterdataarray"] != null) {
          setDefaultData["formData"][key] = value ?? '';
        } else {
          try {
            var res = await IISMethods().getObjectFromArray(setDefaultData["masterDataList"][fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
            setDefaultData["formData"][fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
            setDefaultData["formData"][key] = res?["_id"];
          } catch (e) {
            debugPrint(e.toString());
            setDefaultData["formData"].remove(fieldObj["formdatafield"]);
            setDefaultData["formData"].remove(key);
          }
        }
      }
    } else {
      setDefaultData["formData"][key] = value;
    }

    var obj;
    for (var data in dialogBoxData['formfields']) {
      if (obj == null) {
        obj = await IISMethods().getObjectFromArray(data["formFields"], 'field', key);
      } else {
        obj = obj;
      }
    }
    if (obj != null && obj.containsKey("onchangedata")) {
      for (var field in obj["onchangefill"]) {
        var filter = {};
        if (!(obj["field"] == 'userroleid')) {
          obj["onchangedata"].map((data) {
            if (setDefaultData["formData"][data] != '*') {
              filter[data] = setDefaultData["formData"][data];
            }
          });
        }

        var obj2;
        obj2 = await IISMethods().getObjectFromArray(dialogBoxData["formfields"]?.first["formFields"], 'field', field);

        if (key == 'userroleid' && obj2["type"] == HtmlControls.kDropDown) {
          setDefaultData["formData"][field] = '';
          setDefaultData["formData"][obj2["formdatafield"]] = '';
        } else if (obj2["type"] == HtmlControls.kMultiSelectDropDown || obj2["type"] == HtmlControls.kDateRangePicker) {
          setDefaultData["formData"][field] = [];
        }
        await getMasterData(pageNo: 1, masterdata: obj2["masterdata"], filter: filter, fieldObj: obj2, formData: setDefaultData["formData"]);
      }
    }

    if (defaultuser) {
      await getList(
        personid: setDefaultData["formData"]["personid"],
        userroleid: setDefaultData["formData"]["userroleid"],
        moduletypeid: setDefaultData["formData"]["moduletypeid"],
      );
    }
    if (key != 'defaultuser') {
      if (setDefaultData["formData"]["personid"] != null || setDefaultData["formData"]["userroleid"] != null) {
        await getList(
          personid: setDefaultData["formData"]["personid"],
          moduletypeid: setDefaultData["formData"]["moduletypeid"],
          userroleid: setDefaultData["formData"]["userroleid"],
        );
      }
    }
  }

  Future getList({
    required moduletypeid,
    personid,
    userroleid,
  }) async {
    try {
      setDefaultData["data"] = [];
      state["selectall"] = false;
      state["allviewright"] = false;
      state["selfviewright"] = false;
      state["alladdright"] = false;
      state["selfaddright"] = false;
      state["alleditright"] = false;
      state["selfeditright"] = false;
      state["alldelright"] = false;
      state["selfdelright"] = false;
      state["allprintright"] = false;
      state["selfprintright"] = false;
      state["allfinancialdata"] = false;
      state["selffinancialdata"] = false;
      state["requestright"] = false;
      state["changepriceright"] = false;
      state["sort"] = 1;
      // setSearchValue('');

      var url = Config.weburl + pageName;
      var userAction = 'list${pageName}data';

      await setShowShimmer(true);

      var reqBody = {
        'moduletypeid': moduletypeid,
        "personid": (personid == "undefined" || personid == null) ? '' : personid,
        "userroleid": userroleid ?? '',
        'sort': !setDefaultData["sortData"].containsKey("formname") ? 1 : setDefaultData["sortData"]["formname"],
      };

      var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName);

      if (resBody["status"] == 200) {
        setDefaultData["data"] = [];
        setDefaultData["searchResultArray"] = resBody["data"].map((data) => data);
        setDefaultData["data"] = resBody["data"];
        setDefaultData["fieldOrder"] = resBody["fieldorder"]["fields"];
        setDefaultData["nextpage"] = resBody["nextpage"];
        setDefaultData["pageName"] = resBody["pagename"];

        var result = await handleAllSelected();
        if (result[0]) {
          state["allviewright"] = true;
        }
        if (result[1]) {
          state["selfviewright"] = true;
        }
        if (result[2]) {
          state["alladdright"] = true;
        }
        if (result[3]) {
          state["selfaddright"] = true;
        }
        if (result[4]) {
          state["alleditright"] = true;
        }
        if (result[5]) {
          state["selfeditright"] = true;
        }
        if (result[6]) {
          state["alldelright"] = true;
        }
        if (result[7]) {
          state["selfdelright"] = true;
        }
        if (result[8]) {
          state["allprintright"] = true;
        }
        if (result[9]) {
          state["selfprintright"] = true;
        }
        if (result[10]) {
          state["allfinancialdata"] = true;
        }
        if (result[11]) {
          state["selffinancialdata"] = true;
        }
        if (result[12]) {
          state["requestright"] = true;
        }
        if (result[13]) {
          state["changepriceright"] = true;
        }

        for (var data in dialogBoxData["formfields"]) {
          for (var fields in data["formFields"]) {
            if (fields.containsKey("masterdata") && !fields.containsKey("masterdatadependancy") && !setDefaultData["masterData"].containsKey(fields["masterdata"])) {
              await getMasterData(pageNo: 1, masterdata: fields["masterdata"]);
            } else if (fields.containsKey("masterdata") &&
                fields.containsKey("masterdataarray") &&
                !setDefaultData["masterData"].containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
              var array = [];
              for (var object in fields["masterdataarray"]) {
                if (object.runtimeType == Object) {
                  array.add(object);
                } else {
                  array.add({"label": object, 'value': object});
                }
              }
              setDefaultData["masterData"][fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]] = array;
            }
          }
        }
        setaddButtonDisable(false);
        await setShowShimmer(false);
      } else {
        setaddButtonDisable(false);
      }
    } catch (er) {
      await setShowShimmer(false);
    }
  }

  Future handleAllSelected() async {
    var selfView = true,
        allView = true,
        selfAdd = true,
        allAdd = true,
        selfEdit = true,
        allEdit = true,
        selfDelete = true,
        allDelete = true,
        selfPrint = true,
        allPrint = true,
        selfFinance = true,
        allFinance = true,
        canManageReq = true,
        canChangePrice = true;
    await setDefaultData["data"].where((data) {
      if (searchValue.trim().isEmpty) {
        return true;
      } else {
        return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
      }
    }).forEach((data) {
      if (!(data["allviewright"] == 1)) {
        allView = false;
      }
      if (!(data["selfviewright"] == 1)) {
        selfView = false;
      }
      if (!(data["alladdright"] == 1)) {
        allAdd = false;
      }
      if (!(data["selfaddright"] == 1)) {
        selfAdd = false;
      }
      if (!(data["alleditright"] == 1)) {
        allEdit = false;
      }
      if (!(data["selfeditright"] == 1)) {
        selfEdit = false;
      }
      if (!(data["alldelright"] == 1)) {
        allDelete = false;
      }
      if (!(data["selfdelright"] == 1)) {
        selfDelete = false;
      }
      if (!(data["allprintright"] == 1)) {
        allPrint = false;
      }
      if (!(data["selfprintright"] == 1)) {
        selfPrint = false;
      }
      if (!(data["allfinancialdata"] == 1)) {
        allFinance = false;
      }
      if (!(data["selffinancialdata"] == 1)) {
        selfFinance = false;
      }
      if (!(data["requestright"] == 1)) {
        canManageReq = false;
      }
      if (!(data["changepriceright"] == 1)) {
        canChangePrice = false;
      }
    });

    if (setDefaultData["data"].where((data) {
          if (searchValue.isEmpty) {
            return true;
          } else {
            return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
          }
        }).length ==
        0) {
      selfView = false;
      allView = false;
      selfAdd = false;
      allAdd = false;
      selfEdit = false;
      allEdit = false;
      selfDelete = false;
      allDelete = false;
      selfPrint = false;
      allPrint = false;
      selfFinance = false;
      allFinance = false;
      canManageReq = false;
      canChangePrice = false;
    }

    return [
      allView,
      selfView,
      allAdd,
      selfAdd,
      allEdit,
      selfEdit,
      allDelete,
      selfDelete,
      allPrint,
      selfPrint,
      allFinance,
      selfFinance,
      canManageReq,
      canChangePrice,
    ];
  }

  Future getDefaultData(value) async {
    var url = '${Config.weburl}userrightstemplate';
    var useraction = 'listuserrightstemplatedata';

    var filter = {"_id": value};

    if (setDefaultData["data"] == null) {
      setDefaultData["pageNo"] = 1;
    }

    var reqBody = {
      "searchtext": '',
      "paginationinfo": {
        'filter': filter,
      }
    };

    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: useraction, pageName: pageName);

    if (resBody["status"] == 200) {
      message.value = resBody["message"];

      setDefaultData["data"] = [];
      setDefaultData["data"] = resBody["data"][0]?["rights"];
      setDefaultData["searchResultArray"] = resBody["data"][0]?.rights.map((data) => data);
    } else {
      message.value = resBody["message"];
    }
    setdefaultsetButtonDisable(false);
  }

  Future handleResetButtonClick() async {
    setDefaultData["data"] = [];
    setDefaultData["searchResultArray"] = [];
    await getList(
      personid: setDefaultData["formData"]["personid"],
      moduletypeid: setDefaultData["formData"]["moduletypeid"],
      userroleid: setDefaultData["formData"]["userroleid"],
    );
  }

  Future handleSwitches({e, id, field}) async {
    var data = await IISMethods().getObjectFromArray(setDefaultData["data"], '_id', id);
    var index = setDefaultData["data"].toList().indexWhere((obj) => obj["_id"] == data["_id"]);
    setDefaultData["data"][index][field] = (e ? 1 : 0);
    jsonPrint(setDefaultData["data"]);
    if (field == 'allviewright' && !e) {
      setDefaultData["data"][index]["alladdright"] = 0;
      setDefaultData["data"][index]["alleditright"] = 0;
      setDefaultData["data"][index]["alldelright"] = 0;
      setDefaultData["data"][index]["selfaddright"] = 0;
      setDefaultData["data"][index]["selfeditright"] = 0;
      setDefaultData["data"][index]["selfdelright"] = 0;
      state["alladdright"] = false;
      state["alleditright"] = false;
      state["alldelright"] = false;
      state["selfaddright"] = false;
      state["selfeditright"] = false;
      state["selfdelright"] = false;
    } else if (field == 'allviewright' && e) {
      setDefaultData["data"][index]["selfviewright"] = 0;
    } else if (field == 'alladdright' || field == 'alleditright' || field == 'alldelright') {
      if (!e && (!(setDefaultData["data"][index]["alladdright"] == 0) && !(setDefaultData["data"][index]["alleditright"] == 0) && !(setDefaultData["data"][index]["alldelright"] == 0))) {
        if (e && field.contains("all")) {
          setDefaultData["data"][index]["self${field.substring(3, field.length)}"] = 0;
        }
      } else if (!e && ((setDefaultData["data"][index]["alladdright"] == 1) || (setDefaultData["data"][index]["alleditright"] == 1) || (setDefaultData["data"][index]["alldelright"] == 1))) {
        if (setDefaultData["data"][index]["selfviewright"] == 0) {
          setDefaultData["data"][index]["allviewright"] = 1;
        }
        if (e && field.contains("all")) {
          setDefaultData["data"][index]["self${field.substring(3, field.length)}"] = 0;
        }
      } else {
        if (setDefaultData["data"][index]["selfviewright"] == 0 && e) {
          setDefaultData["data"][index]["allviewright"] = 1;
        }
        if (e && field.contains("all")) {
          setDefaultData["data"][index]["self${field.substring(3, field.length)}"] = 0;
        }
      }
    } else if (field == 'selfviewright' && !e) {
      setDefaultData["data"][index]["selfaddright"] = 0;
      setDefaultData["data"][index]["selfeditright"] = 0;
      setDefaultData["data"][index]["selfdelright"] = 0;
      setDefaultData["data"][index]["alladdright"] = 0;
      setDefaultData["data"][index]["alladdright"] = 0;
      setDefaultData["data"][index]["alldelright"] = 0;
      state["selfaddright"] = false;
      state["selfeditright"] = false;
      state["selfdelright"] = false;
      state["alladdright"] = false;
      state["alladdright"] = false;
      state["alldelright"] = false;
    } else if (field == 'selfviewright' && e) {
      setDefaultData["data"][index]["allviewright"] = 0;
    } else if (field == 'selfaddright' || field == 'selfeditright' || field == 'selfdelright') {
      if (!e && (!(setDefaultData["data"][index]["selfaddright"] == 0) && !(setDefaultData["data"][index]["selfeditright"] == 0) && !(setDefaultData["data"][index]["selfdelright"] == 0))) {
        data[field] = (e ? 1 : 0);
        if (e && field.contains("self")) {
          setDefaultData["data"][index]["all${field.substring(4, field.length)}"] = 0;
        }
      } else if (!e && ((setDefaultData["data"][index]["selfaddright"] == 1) || (setDefaultData["data"][index]["selfeditright"] == 1) || (setDefaultData["data"][index]["selfdelright"] == 1))) {
        data[field] = (e ? 1 : 0);

        if (setDefaultData["data"][index]["allviewright"] == 0) {
          setDefaultData["data"][index]["selfviewright"] = 1;
        }
        if (e && field.contains("self")) {
          setDefaultData["data"][index]["all${field.substring(4, field.length)}"] = 0;
        }
      } else {
        data[field] = (e ? 1 : 0);
        if (setDefaultData["data"][index]["allviewright"] == 0 && e) {
          setDefaultData["data"][index]["selfviewright"] = 1;
        }
        if (e && field.contains("self")) {
          setDefaultData["data"][index]["all${field.substring(4, field.length)}"] = 0;
        }
      }
    } else {
      if (e) {
        if (field.contains("all")) {
          setDefaultData["data"][index]["self${field.substring(3, field.length)}"] = 0;
        } else if (field.contains("self")) {
          setDefaultData["data"][index]["all${field.substring(4, field.length)}"] = 0;
        }
      }
    }

    if (!e) {
      if (field == "allviewright") {
        state["allviewright"] = false;
      }
      if (field == "selfviewright") {
        state["selfviewright"] = false;
      }
      if (field == "alladdright") {
        state["alladdright"] = false;
      }
      if (field == "selfaddright") {
        state["selfaddright"] = false;
      }
      if (field == "alleditright") {
        state["alleditright"] = false;
      }
      if (field == "selfeditright") {
        state["selfeditright"] = false;
      }
      if (field == "alldelright") {
        state["alldelright"] = false;
      }
      if (field == "selfdelright") {
        state["selfdelright"] = false;
      }
      if (field == "allprintright") {
        state["allprintright"] = false;
      }
      if (field == "selfprintright") {
        state["selfprintright"] = false;
      }
      if (field == "allfinancialdata") {
        state["allfinancialdata"] = false;
      }
      if (field == "selffinancialdata") {
        state["selffinancialdata"] = false;
      }
      if (field == "requestright") {
        state["requestright"] = false;
      }
      if (field == "changepriceright") {
        state["changepriceright"] = false;
      }
      if (field == "allexportdata") {
        state['allexportdata'] = false;
      }
      if (field == "allimportdata") {
        state['allimportdata'] = false;
      }
    } else if (e && await isSelectedAll(field)) {
      if (field == "allviewright") {
        state["allviewright"] = true;
      }
      if (field == "selfviewright") {
        state["selfviewright"] = true;
      }
      if (field == "alladdright") {
        state["alladdright"] = true;
      }
      if (field == "selfaddright") {
        state["selfaddright"] = true;
      }
      if (field == "alleditright") {
        state["alleditright"] = true;
      }
      if (field == "selfeditright") {
        state["selfeditright"] = true;
      }
      if (field == "alldelright") {
        state["alldelright"] = true;
      }
      if (field == "selfdelright") {
        state["selfdelright"] = true;
      }
      if (field == "allprintright") {
        state["allprintright"] = true;
      }
      if (field == "selfprintright") {
        state["selfprintright"] = true;
      }
      if (field == "allfinancialdata") {
        state["allfinancialdata"] = true;
      }
      if (field == "selffinancialdata") {
        state["selffinancialdata"] = true;
      }
      if (field == "requestright") {
        state["requestright"] = true;
      }
      if (field == "changepriceright") {
        state["changepriceright"] = true;
      }
      if (field == "allimportdata") {
        state['allexportdata'] = true;
      }
      if (field == "allimportdata") {
        state['allimportdata'] = true;
      }
    }
    jsonPrint(setDefaultData["data"]);
  }

  Future isSelectedAll(field) async {
    var isSelectedAll = true;

    setDefaultData["data"].where((data) {
      if (searchValue.isEmpty) {
        return true;
      } else {
        return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
      }
    }).forEach((data) {
      if (!(data[field] == 1)) {
        isSelectedAll = false;
      }
    });

    if (setDefaultData["data"].where((data) {
          if (searchValue.isEmpty) {
            return true;
          } else {
            return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
          }
        }).length ==
        0) {
      isSelectedAll = false;
    }
    return isSelectedAll;
  }

  Future handleSaveButtonClick() async {
    var hasError = !(setDefaultData["formData"]["userroleid"] != null) && !(setDefaultData["formData"]["personid"] != null);
    if (hasError) {
      setaddButtonDisable(false);
    } else {
      if (setDefaultData["data"].length <= setDefaultData["searchResultArray"].length) {
        setDefaultData["data"].forEach((object) async {
          var data = await IISMethods().getObjectFromArray(setDefaultData["data"], '_id', object["_id"]);
          var index = setDefaultData["searchResultArray"].toList().indexWhere((obj) => obj["_id"] == data["_id"]);
          setDefaultData["searchResultArray"].toList()[index] = data;
        });
        setDefaultData["data"] = await setDefaultData["searchResultArray"].toList();
        if (state["sort"] == -1) {
          setDefaultData["data"] = List.from(setDefaultData["data"].toList().reversed);
        }
      }

      var reqe = {
        "personid": (setDefaultData["formData"]["personid"] == "undefined" || setDefaultData["formData"]["personid"] == null) ? '' : setDefaultData["formData"]["personid"],
        "userroleid": (setDefaultData["formData"]["userroleid"] == "undefined" || setDefaultData["formData"]["userroleid"] == null) ? '' : setDefaultData["formData"]["userroleid"],
        "branchid": setDefaultData["formData"]["branchid"] == "undefined" ? '' : setDefaultData["formData"]["branchid"],
        "companyid": setDefaultData["formData"]["companyid"] == "undefined" ? '' : setDefaultData["formData"]["companyid"],
        "moduletypeid": setDefaultData["formData"]["moduletypeid"],
        "data": List.from(setDefaultData["data"]),
      };
      await updateData(reqe);
    }
  }

  Future handleClearButtonClick(e) async {
    setDefaultData["data"].map((data) {
      data["allviewright"] = 0;
      data["selfviewright"] = 0;
      data["alladdright"] = 0;
      data["selfaddright"] = 0;
      data["alleditright"] = 0;
      data["selfeditright"] = 0;
      data["alldelright"] = 0;
      data["selfdelright"] = 0;
      data["allfinancialdata"] = 0;
      data["selffinancialdata"] = 0;
      data["allprintright"] = 0;
      data["selfprintright"] = 0;
      data["requestright"] = 0;
      data["changepriceright"] = 0;
    });

    var reqe = {
      "personid": (setDefaultData["formData"]["personid"] == "undefined" || setDefaultData["formData"]["personid"] == null) ? '' : setDefaultData["formData"]["personid"],
      "userroleid": setDefaultData["formData"]["userroleid"],
      "moduletypeid": setDefaultData["formData"]["moduletypeid"],
      'companyid': setDefaultData["formData"]["companyid"] == "undefined" ? '' : setDefaultData["formData"]["companyid"],
      "data": setDefaultData["data"],
    };

    await updateData(reqe);
    await handleGrid(value: false, type: 'modal', key: 'clearflow', id: 0);
  }

  Future updateData(reqData) async {
    var url = '${Config.weburl}$pageName/update';
    var useraction = 'update${pageName}data';

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: useraction, pageName: pageName);
    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody["message"];
      state["selectall"] = false;
      state["allviewright"] = false;
      state["selfviewright"] = false;
      state["alladdright"] = false;
      state["selfaddright"] = false;
      state["alleditright"] = false;
      state["selfeditright"] = false;
      state["alldelright"] = false;
      state["selfdelright"] = false;
      state["allprintright"] = false;
      state["selfprintright"] = false;
      state["allfinancialdata"] = false;
      state["selffinancialdata"] = false;
      state["requestright"] = false;
      state["changepriceright"] = false;
      searchValue = "";
      setDefaultData["data"] = [];

      await getList(
        personid: setDefaultData["formData"]["personid"],
        moduletypeid: setDefaultData["formData"]["moduletypeid"],
        userroleid: setDefaultData["formData"]["userroleid"],
      );
      showSuccess(message.value);
    } else {
      message.value = resBody["message"];
      showError(message.value);
    }
  }

  handleGrid({id, type, key, value}) async {
    if (type == HtmlControls.kModel) {
      if (value) {
        setDefaultData["modal"][key] = id;
      } else {}
    } else {}
  }

  Future handleSelectAll({e, field}) async {
    var dataWithModuleFilter;
    if (setDefaultData["formData"]["moduleid"] == "*") {
      dataWithModuleFilter = setDefaultData["data"];
    } else if (setDefaultData["formData"]["moduleid"] == 'withoutmodule') {
      dataWithModuleFilter = setDefaultData["data"].where((data) => data["moduleid"] == '');
    } else {
      dataWithModuleFilter = setDefaultData["data"].where((data) => data["moduleid"] == setDefaultData["formData"]["moduleid"]);
    }

    state[field] = e;
    await dataWithModuleFilter.where((data) {
      if (searchValue.isEmpty) {
        return true;
      } else {
        return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
      }
    }).forEach((object) {
      object[field] = e ? 1 : 0;
    });

    if (field == 'allviewright' && !e) {
      await dataWithModuleFilter.where((data) {
        if (searchValue.isEmpty) {
          return true;
        } else {
          return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
        }
      }).forEach((object) {
        object["alladdright"] = 0;
        object["alleditright"] = 0;
        object["alldelright"] = 0;
        object[field] = e ? 1 : 0;
        state["alladdright"] = e;
        state["alleditright"] = e;
        state["alldelright"] = e;
      });
    } else if (field == 'allviewright' && e) {
      dataWithModuleFilter.where((data) {
        if (searchValue.isEmpty) {
          return true;
        } else {
          return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
        }
      }).forEach((object) {
        object["selfviewright"] = 0;
      });
      state["allviewright"] = e;
      state["selfviewright"] = false;
    } else if (field == 'alladdright' || field == 'alleditright' || field == 'alldelright') {
      dataWithModuleFilter.where((data) {
        if (searchValue.isEmpty) {
          return true;
        } else {
          return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
        }
      }).forEach((object) {
        if (!e && (!(object["alladdright"] == 0) && !(object["alleditright"] == 0) && !(object["alldelright"] == 0))) {
          object[field] = (e ? 1 : 0);
          if (e && field.contains("all")) {
            object["self${field.substring(3, field.length)}"] = 0;
            state["selfviewright"] = false;
          }
        } else if (!e && (object["alladdright"] == 1 || object["alleditright"] == 1 || object["alldelright"] == 1)) {
          object[field] = (e ? 1 : 0);
          if (object["selfviewright"] == 0) {
            object["allviewright"] = 1;
            state["allviewright"] = true;
          }
          if (e && field.contains("all")) {
            object["self${field.substring(3, field.length)}"] = 0;
            state["selfviewright"] = false;
          }
        } else {
          object[field] = (e ? 1 : 0);
          if (e && object["selfviewright"] == 0) {
            object["allviewright"] = 1;
            state["allviewright"] = true;
          }
          if (e && field.contains("all")) {
            object["self${field.substring(3, field.length)}"] = 0;
            if (field == 'alladdright') {
              state["selfaddright"] = false;
            } else if (field == 'alleditright') {
              state["selfeditright"] = false;
            } else if (field == 'alldelright') {
              state["selfdelright"] = false;
            }
          }
        }
      });
    } else if (field == 'selfviewright' && !e) {
      dataWithModuleFilter.where((data) {
        if (searchValue.isEmpty) {
          return true;
        } else {
          return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
        }
      }).forEach((object) {
        object["selfaddright"] = 0;
        object["selfeditright"] = 0;
        object["selfdelright"] = 0;
        state["selfaddright"] = e;
        state["selfeditright"] = e;
        state["selfdelright"] = e;
      });
    } else if (field == 'selfviewright' && e) {
      dataWithModuleFilter.where((data) {
        if (searchValue.isEmpty) {
          return true;
        } else {
          return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
        }
      }).forEach((object) {
        object["allviewright"] = 0;
      });
      state["selfviewright"] = e;
      state["allviewright"] = false;
    } else if (field == 'selfaddright' || field == 'selfeditright' || field == 'selfdelright') {
      dataWithModuleFilter.where((data) {
        if (searchValue.isEmpty) {
          return true;
        } else {
          return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
        }
      }).forEach((object) {
        if (!e && (!(object["selfaddright"] == 0) && !(object["selfeditright"] == 0) && !(object["selfdelright"] == 0))) {
          object[field] = (e ? 1 : 0);
          if (e && field.contains("self")) {
            object["all${field.substring(4, field.length)}"] = 0;
            state["allviewright"] = false;
          }
        } else if (!e && (object["selfaddright"] == 1 || object["selfeditright"] == 1 || object["selfdelright"] == 1)) {
          object[field] = (e ? 1 : 0);
          if (object["allviewright"] == 0) {
            object["selfviewright"] = 1;
            state["selfviewright"] = true;
          }
          if (e && field.contains("self")) {
            object["all${field.substring(4, field.length)}"] = 0;
            state["allviewright"] = false;
          }
        } else {
          object[field] = (e ? 1 : 0);
          if (object["allviewright"] == 0 && e) {
            object["selfviewright"] = 1;
            state["selfviewright"] = true;
          }
          if (e && field.contains("self")) {
            object["all${field.substring(4, field.length)}"] = 0;
            if (field == 'selfaddright') {
              state["alladdright"] = false;
            } else if (field == 'selfeditright') {
              state["alleditright"] = false;
            } else if (field == 'selfdelright') {
              state["alldelright"] = false;
            }
          }
        }
      });
    } else {
      dataWithModuleFilter.where((data) {
        if (searchValue.isEmpty) {
          return true;
        } else {
          return data["formname"].toString().toLowerCase().contains(searchValue.toLowerCase());
        }
      }).forEach((object) {
        object[field] = e ? 1 : 0;
        if (e && !(field == 'requestright' || field == 'changepriceright')) {
          if (field.contains("all")) {
            object["self${field.substring(3, field.length)}"] = 0;
            if (field == 'allfinancialdata') {
              state["selffinancialdata"] = false;
            } else if (field == 'allprintright') {
              state["selfprintright"] = false;
            }
          } else if (field.contains("self")) {
            object["all${field.substring(4, field.length)}"] = 0;
            if (field == 'selffinancialdata') {
              state["allfinancialdata"] = false;
            } else if (field == 'selfprintright') {
              state["allprintright"] = false;
            }
          }
        }
      });
    }
  }
}
