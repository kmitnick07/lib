import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart' as graph;
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';

import '../../../style/theme_const.dart';
import '../../components/customs/custom_button.dart';
import '../../components/customs/text_widget.dart';
import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../config/iis_method.dart';
import '../../routes/route_generator.dart';
import '../../style/string_const.dart';

class UserRoleHierarchyController extends GetxController {
  String pageName = "";
  int index = -1;
  RxMap dialogBoxData = {}.obs;
  RxString message = "".obs;
  RxBool hasError = false.obs;
  RxInt statusCode = 0.obs;
  RxBool loadingData = false.obs;
  RxBool loadingMasterData = true.obs;
  RxMap uploadedFile = {}.obs;
  RxBool selectAll = false.obs;
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
  RxString searchMenu = "".obs;
  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};

  List<dynamic> primaryParentData = [];
  graph.Graph hierarchyTree = graph.Graph()..isTree = true;

  @override
  onInit() {
    super.onInit();
    setPageTitle('User Role Hierarchy | PRENEW', Get.context!);
  }

  Future clearData() async {
    searchMenu.value = "";
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

  String printSelectPicker(
    data,
    masterdata,
  ) {
    if (masterdata == "module") {
      return data[masterdata].toString();
    } else {
      return data[masterdata].toString();
    }
  }


  @override
  void dispose() {
    Get.delete<UserRoleHierarchyController>();
    super.dispose();
  }

  fetch() async {
    loadingData.value = true;
    for (var data in dialogBoxData["formfields"]) {
      for (var fields in data["formFields"]) {
        if (fields.containsKey("masterdata") && !setDefaultData["masterData"].containsKey(fields["masterdata"]) && !fields.containsKey("masterdataarray")) {
          await getMasterData(pageNo: 1, fieldObj: fields, formData: setDefaultData["formData"]);
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
          setDefaultData["masterData"] = IISMethods().getCopy(setDefaultData["masterData"]);
        }
      }
    }

    await getList(
      subcategoryid: setDefaultData["formData"]["subcategoryid"],
      itemid: setDefaultData["formData"]["itemid"],
      branch: setDefaultData["formData"]["branchname"],
      companyid: setDefaultData["formData"]["companyid"],
      branchid: setDefaultData["formData"]["branchid"],
      categoryid: setDefaultData["formData"]["categoryid"],
    );

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

      if (fieldObj.containsKey('dependentfilter')) {
        fieldObj['dependentfilter'].keys.forEach((key) {
          final value = formData![fieldObj['dependentfilter'][key]];
          if (value != null) {
            isDepend = 1;
            filter[key] = value;
            setDefaultData["formData"][fieldObj["field"]] = "";
            setDefaultData["formData"][fieldObj["masterdata"]] = null;
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
          ...IISMethods().getCopy(fieldObj["filter"]),
          ...filter,
        };

        var reqBody = {
          "paginationinfo": {
            "pageno": pageNo,
            "pagelimit": 500000000000,
            "filter": filter,
            "projection": projection,
            "sort": {},
          }
        };

        var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName, masterlisting: true);
        if (resBody["status"] == 200) {
          setDefaultData["masterData"] = await IISMethods().getCopy(setDefaultData["masterData"]);
          setDefaultData["masterDataList"] = await IISMethods().getCopy(setDefaultData["masterDataList"]);
          if (pageNo == 1) {
            setDefaultData["masterData"][masterDataKey] = [];
            setDefaultData["masterDataList"][masterDataKey] = [];
          }
          await resBody["data"].forEach((data) {
            setDefaultData["masterData"][masterDataKey].add({"label": printSelectPicker(data, fieldObj["masterdatafield"]), "value": data["_id"].toString()});
          });

          setDefaultData["masterDataList"][masterDataKey] = [...setDefaultData["masterDataList"][masterDataKey], ...resBody["data"]];

          setDefaultData['masterData'] = await IISMethods().getCopy(setDefaultData['masterData']);
          setDefaultData['masterDataList'] = await IISMethods().getCopy(setDefaultData['masterDataList']);

          if (resBody["nextpage"] == 1) {
            await getMasterData(pageNo: pageNo + 1, fieldObj: fieldObj, formData: formData, storeMasterDataByField: storeMasterDataByField);
          }
        }
      } else {
        setDefaultData["masterData"][masterDataKey] = [];
        setDefaultData["masterDataList"][masterDataKey] = [];
      }
    } catch (err) {
      rethrow;
    }
    update();
  }

  Future getList({
    companyid,
    branchid,
    branch,
    itemid,
    subcategoryid,
    categoryid,
    parentid = "",
  }) async {
    loadingData.value = true;
    var url = '${Config.weburl}userrolehierarchy';
    var userAction = 'list$pageName';

    var filter = {};

    for (var entry in setDefaultData["filterData"].entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is num) {
        if (value != 0) {
          filter[key] = value;
        }
      } else {
        filter[key] = value;
      }
    }

    if (setDefaultData["data"] == null && setDefaultData['data'] == []) {
      setDefaultData["pageNo"] = 1;
    }
    Map<String, dynamic> reqBody = {};

    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName);
    if (resBody["status"] == 200) {
      setDefaultData['data'] = [];
      setDefaultData['data'] = Map<String, dynamic>.from(IISMethods().encryptDecryptObj(resBody['data'] ?? []));
      setDefaultData['nextpage'] = resBody['nextpage'];
      setDefaultData['pageName'] = resBody['pagename'];
      await generateTree();
    } else {
      setDefaultData['data'] = [];
    }

    loadingData.value = false;
    update();
  }

  Future handleFormData({
    type,
    key,
    value,
  }) async {
    if (type == HtmlControls.kCheckBox) {
      setDefaultData["formData"][key] = (value ? 1 : 0);
    } else if (type == HtmlControls.kDatePicker) {
      setDefaultData["formData"][key] = value ?? '';
    } else if (type == HtmlControls.kDropDown) {
      var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
      if (fieldObj["masterdataarray"] != null) {
        setDefaultData["formData"][key] = value ?? '';
      } else {
        try {
          var res = await IISMethods().getObjectFromArray(setDefaultData["masterDataList"][fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
          setDefaultData["formData"][fieldObj["formdatafield"]] = res[fieldObj["masterdatafield"]];
          setDefaultData["formData"][key] = res["_id"];
        } catch (e) {
          setDefaultData["formData"].remove(fieldObj["formdatafield"]);
          setDefaultData["formData"].remove(key);
        }
      }
    } else {
      setDefaultData["formData"][key] = value;
    }

    setDefaultData["formData"] = await IISMethods().getCopy(setDefaultData["formData"]);
    setDefaultData["data"] = [];

    await getList(
      subcategoryid: setDefaultData["formData"]["subcategoryid"],
      itemid: setDefaultData["formData"]["itemid"],
      branch: setDefaultData["formData"]["branch"],
      companyid: setDefaultData["formData"]["companyid"],
      branchid: setDefaultData["formData"]["branchid"],
      categoryid: setDefaultData["formData"]["categoryid"],
    );

    var obj = getObjectFromFormData(dialogBoxData["formfields"], key);

    if (obj.containsKey("onchangefill")) {
      obj["onchangefill"].forEach((field) async {
        var obj2 = getObjectFromFormData(dialogBoxData["formfields"], field);
        if (obj2["type"] == HtmlControls.kDropDown) {
          await handleFormData(type: obj2['type'], key: obj2["field"], value: '');
        } else if (obj2["type"] == HtmlControls.kMultiSelectDropDown) {
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
      });
    }
  }

  handleSearch(v) async {
    searchMenu.value = v;
    List check = await setDefaultData["data"].where((element) => element["item"].toString().toLowerCase().contains(searchMenu.value.toLowerCase())).map((e) => e['isassigned'] == 1).toList();
    if (check.contains(false)) {
      selectAll.value = false;
    }
  }

  Future updateData() async {
    Map<String, dynamic> reqData = {"userrolehierarchy": setDefaultData['data']};
    var url = '${Config.weburl + pageName}/add';

    var userAction = "update$pageName";

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName);
    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody['message'];
      setDefaultData['data'] = resBody['data']['userrolehierarchy'];
    } else {
      message.value = resBody['message'];
      await getList();
    }
    update();
  }

  Future<List?> addUsersToNode(String id) async {
    var pageName = 'userrole';
    var url = Config.weburl + pageName;
    var userAction = 'list${pageName}data';
    var filter = {};
    Map reqBody = {
      "searchtext": "",
      "paginationinfo": {"pageno": 1, "pagelimit": 20000000000000, "filter": filter, "sort": {}},
      'projection': {'_id': 1, 'userrole': 1}
    };
    var resBody = await IISMethods().listData(url: url, reqBody: IISMethods().getCopy(reqBody), userAction: userAction, pageName: pageName);
    if (resBody["status"] == 200) {
      setDefaultData["masterFormData"] = await IISMethods().getCopy(resBody["data"]);
    } else {}
    List addedUsers = addedTreeNodes.map((e) => e['_id']).toList();
    setDefaultData['masterFormData'].removeWhere((element) => addedUsers.contains(element['_id']));
    await showDialog(
      context: Get.context!,
      builder: (context) {
        return Dialog(
          alignment: Alignment.topCenter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: StatefulBuilder(builder: (context, setFormState) {
            return Container(
              width: 400,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.9,
                minWidth: 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: ColorTheme.kWhite,
                    ),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: TextWidget(
                                text: "Select User Role",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              onPressed: () {
                                setDefaultData["masterFormData"] = [];
                                Get.back();
                              },
                              splashColor: ColorTheme.kRed,
                              hoverColor: ColorTheme.kRed.withOpacity(0.4),
                              splashRadius: 18,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Visibility(
                    visible: setDefaultData["masterFormData"].isNotEmpty,
                    replacement: const NoDataFoundScreen(),
                    child: Column(
                      children: [
                        constrainedBoxWithPadding(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              var data = setDefaultData["masterFormData"][index];
                              data['isSelected'] = false;
                              return StatefulBuilder(builder: (context, setState) {
                                return InkWell(
                                  onTap: () {
                                    data['isSelected'] = !data['isSelected'];
                                    setState(() {});
                                    if (kDebugMode) {
                                      print(data);
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: data['isSelected'],
                                        activeColor: ColorTheme.kPrimaryColor,
                                        onChanged: (v) async {
                                          data['isSelected'] = !data['isSelected'];
                                          setState(() {});
                                          if (kDebugMode) {
                                            print(data);
                                          }
                                        },
                                      ),
                                      TextWidget(text: data['userrole'], fontSize: 16),
                                    ],
                                  ),
                                );
                              });
                            },
                            itemCount: setDefaultData["masterFormData"].length,
                            shrinkWrap: true,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 20.0,
                            right: 20,
                            bottom: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomButton(
                                onTap: () {
                                  Get.back();
                                },
                                height: 35,
                                width: 80,
                                title: StringConst.kAddBtnTxt,
                                borderRadius: 5,
                                fontColor: ColorTheme.kWhite,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              CustomButton(
                                title: StringConst.kResetBtnTxt,
                                onTap: () {
                                  for (var data in setDefaultData["masterFormData"]) {
                                    data['isSelected'] = false;
                                    setFormState(() {});
                                  }
                                },
                                height: 35,
                                width: 80,
                                showBoxBorder: true,
                                borderRadius: 5,
                                buttonColor: ColorTheme.kWhite,
                                fontColor: ColorTheme.kHintTextColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
    return null;
  }

  Future<List?> showUserList(String id) async {
    var pageName = 'rolewiseuser';
    var url = Config.weburl + pageName;
    var userAction = 'list${pageName}data';
    var filter = {};
    Map reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 9999999999999,
        "filter": {
          "userroleid": id,
        },
        "sort": {}
      }
    };
    var resBody = await IISMethods().listData(url: url, reqBody: IISMethods().getCopy(reqBody), userAction: userAction, pageName: pageName, masterlisting: true);
    if (resBody["status"] == 200) {
      setDefaultData["masterFormData"] = await IISMethods().getCopy(resBody["data"]);
    } else {}
    await showDialog(
      context: Get.context!,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.hardEdge,
          alignment: Alignment.topCenter,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: StatefulBuilder(builder: (context, setFormState) {
            return Container(
              width: 600,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.9,
                minWidth: 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: ColorTheme.kWhite,
                    ),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: TextWidget(
                                text: "UserRole wise User details",
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              splashColor: ColorTheme.kRed,
                              hoverColor: ColorTheme.kRed.withOpacity(0.4),
                              splashRadius: 18,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: CommonDataTableWidget(
                        tableScrollController: null,
                        width: 600,
                        showPagination: false,
                        data: List<Map<String, dynamic>>.from(setDefaultData["masterFormData"] ?? []),
                        fieldOrder: const [
                          {
                            "field": "name",
                            "text": "Name",
                            "type": "text",
                            "freeze": 1,
                            "active": 1,
                            "sorttable": 0,
                            "sortby": "name",
                            "filter": 0,
                            "filterfieldtype": "dropdown",
                            "defaultvalue": "",
                            "tblsize": 1,
                          },
                          {
                            "field": "employeeid",
                            "text": "EID",
                            "type": "text",
                            "freeze": 1,
                            "active": 1,
                            "sorttable": 0,
                            "sortby": "rolety0e",
                            "filter": 0,
                            "filterfieldtype": "dropdown",
                            "defaultvalue": "",
                            "tblsize": 1,
                          },
                          {
                            "field": "email",
                            "text": "Email",
                            "type": "text",
                            "freeze": 1,
                            "active": 1,
                            "sorttable": 0,
                            "sortby": "email",
                            "filter": 0,
                            "filterfieldtype": "dropdown",
                            "defaultvalue": "",
                            "tblsize": 1,
                          },
                        ],
                        setDefaultData: FormDataModel(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
    return null;
  }

  String? removeNode({required String id}) {
    String? parentId;
    for (graph.Edge edge in hierarchyTree.edges) {
      if (edge.destination.key?.value.toString() == id) {
        parentId = edge.source.key?.value.toString();
        hierarchyTree.removeEdge(edge);
      }
    }
    setDefaultData['data'] = removeChildById(setDefaultData['data'], id);
    return parentId;
  }

  Map<String, dynamic> removeChildById(Map<String, dynamic> parent, String childId) {
    List<dynamic>? children = parent['children'];

    if (children != null) {
      List<dynamic> updatedChildren = [];
      for (var child in children) {
        if (child['_id'] != childId) {
          Map<String, dynamic> updatedChild = removeChildById(child, childId);
          updatedChildren.add(updatedChild);
        }
      }
      parent['children'] = updatedChildren;
    }

    return parent;
  }

  Map<String, dynamic> addChildById({
    required Map<String, dynamic> parent,
    required String parentId,
    Map<String, dynamic>? newChild,
    List<Map<String, dynamic>>? newChildren,
    int? flag,
  }) {
    newChild?['pid'] = parentId;
    newChildren?.forEach((element) {
      element['pid'] = parentId;
    });
    if (flag == 1 && parent['_id'] == parentId) {
      parent['children'] ??= [];
      if (newChild != null) parent['children'].add(newChild);
      if (newChildren != null) parent['children'].addAll(newChildren);
      return parent;
    }
    List<dynamic>? children = parent['children'];

    if (children != null) {
      for (var child in children) {
        if (child['_id'] == parentId) {
          child['children'] ??= [];
          if (newChild != null) child['children'].add(newChild);
          if (newChildren != null) child['children'].addAll(newChildren);
          return parent;
        } else {
          Map<String, dynamic> updatedChild = addChildById(
            parent: child,
            parentId: parentId,
            newChild: newChild,
            flag: 0,
          );
          if (updatedChild.isNotEmpty) {
            child['children'] = updatedChild['children'];
          }
        }
      }
    }

    return parent;
  }

  void addNode({required String parentId, required Map<String, dynamic> newChild}) {
    hierarchyTree.addEdge(
      graph.Node.Id(parentId),
      graph.Node.Id(newChild['_id']),
    );
    newChild['pid'] = parentId;
    addChildById(parent: setDefaultData['data'], parentId: parentId, newChild: newChild, flag: 1);
  }

  List<Map<String, dynamic>> addedTreeNodes = [];

  Future<void> generateTree() async {
    hierarchyTree = graph.Graph()..isTree = true;
    addedTreeNodes = [];
    Map<String, dynamic> treeData = Map<String, dynamic>.from(setDefaultData['data']);
    makeTree(treeData);
  }

  Map<String, dynamic>? findNodeInFamily({required String targetId, required Map<String, dynamic> treeData}) {
    if (treeData['_id'] == targetId) {
      return treeData;
    }
    if (treeData.containsKey('children') && treeData['children'] != null) {
      List<Map<String, dynamic>> children = List<Map<String, dynamic>>.from(treeData['children']);
      for (var child in children) {
        Map<String, dynamic>? nodeFoundInChild = findNodeInFamily(targetId: targetId, treeData: child);
        if (nodeFoundInChild != null) {
          return nodeFoundInChild;
        }
      }
    }
    return null;
  }

  Map<String, dynamic>? findNodeById({required String targetId}) {
    Map<String, dynamic> node = addedTreeNodes.firstWhere((element) => element['_id'] == targetId, orElse: () => {});
    if (node == {}) {
      return null;
    }
    return node;
  }

  void makeTree(Map<String, dynamic> treeData) {
    hierarchyTree.addNode(graph.Node.Id(treeData['_id']));
    addedTreeNodes.add(treeData);
    if (treeData.containsKey('pid') && treeData['pid'] != null && treeData['pid'].toString().isNotEmpty) {
      hierarchyTree.addEdge(graph.Node.Id(treeData['pid']), graph.Node.Id(treeData['_id']));
    }
    if (treeData.containsKey('children') && treeData['children'] != null && treeData['children'].toString().isNotEmpty) {
      List<Map<String, dynamic>> children = List<Map<String, dynamic>>.from(treeData['children']);
      for (var child in children) {
        makeTree(child);
      }
    }
  }
}
