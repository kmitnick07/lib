// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/json/tenants_sra_json.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/view/new_tenant_project/payment_for_sra_dialog.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../components/customs/custom_date_picker.dart';
import '../../components/customs/loader.dart';
import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../routes/route_generator.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../../view/tenant/contract_payment_status_dialog.dart';
import '../../view/tenant/sap_dialog.dart';

class NewTenantProjectController extends GetxController {
  RxString pageName = ''.obs;
  RxString searchText = ''.obs;
  RxString formName = ''.obs;
  RxString message = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  RxMap dialogBoxData = {}.obs;
  Map validator = {};
  Map<int, FocusNode> focusNodes = {};
  Map<int, GlobalKey<FormFieldState>> formKeys = {};
  RxMap<String, dynamic> uploadedFile = <String, dynamic>{}.obs;
  RxInt statusCode = 0.obs;
  RxInt uploadDocCount = 0.obs;
  RxBool loadingData = true.obs;
  RxBool formLoadingData = false.obs;
  RxBool masterFormLoadingData = false.obs;
  RxBool updateObj = false.obs;
  final formKey0 = GlobalKey<FormState>();
  int cursorPos = 0;
  RxBool validateForm = false.obs;
  bool autoFilling = false;
  RxBool addButtonLoading = false.obs;
  RxBool isAddButtonVisible = false.obs;
  RxInt selectedTab = (-1).obs;
  RxInt currentExpandedIndex = 0.obs;
  RxBool isApprovingPayment = false.obs;
  RxBool isSocietyApproving = false.obs;
  TextEditingController searchController = TextEditingController();
  AutoScrollController tabScrollController = AutoScrollController();
  ScrollController formScrollController = ScrollController();
  Map<String, dynamic> fieldsSetting = {};
  RxBool selectAll = false.obs;
  RxInt selectionCount = 0.obs;
  RxList<Map<String, dynamic>> sapContractHistoryList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> sapContractHistoryFieldOrderList = <Map<String, dynamic>>[].obs;
  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};

  ScrollController tableScrollController = ScrollController();
  ScrollController formTableScrollController = ScrollController();

  RxBool loadingPaginationData = false.obs;
  RxBool isMasterDataEditing = false.obs;
  RxBool canApprovePayment = false.obs;
  RxBool enableInnerScroll = false.obs;

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
      if (Platform.isAndroid || Platform.isIOS) {
        formScrollController.addListener(() {
          if (formScrollController.position.atEdge) {
            bool isTop = formScrollController.position.pixels == 0;

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
        formScrollController.addListener(() {
          if (formScrollController.position.atEdge) {
            bool isTop = formScrollController.position.pixels == 0;

            if (isTop) {
              devPrint('🍺 At the top');
            } else {
              devPrint('🍺 At the bottom');
              enableInnerScroll.value = true;
            }
          }
        });
        formTableScrollController.addListener(() {
          if (formTableScrollController.position.atEdge) {
            bool isTop = formTableScrollController.position.pixels == 0;

            if (isTop) {
              devPrint('🍺 At the top');
              enableInnerScroll.value = false;
            } else {
              devPrint('🍺 At the bottom');
            }
          }
        });
      }
    }
    selectedTab.listen(
      (p0) {
        tabScrollController.scrollToIndex(p0);
        if (!formLoadingData.value) {
          getMasterDataListForTab();
        }
        formKey0.currentState?.reset();
        validateForm.value = false;
        try {
          formScrollController.jumpTo(0);
        } catch (e) {
          devPrint(e);
        }
        selectionCount.value = 0;
        isSocietyApproving.value = false;
        selectAll.value = false;
      },
    );
    // if (Get.arguments is Map) {
    //   pageName.value = Get.arguments['pagename'] ?? "";
    // } else {
    //   pageName.value = getCurrentPageName();
    // }
    pageName.value = getCurrentPageName();
    isAddButtonVisible.value = IISMethods().hasAddRight(alias: pageName.value);
    dialogBoxData.value = TenantsSRAJson.designationFormFields('tenantproject');
    formName.value = dialogBoxData['formname'] ?? "";
    setPageTitle('${formName.value} | PRENEW', Get.context!);
    formName.refresh();
    await getList();
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<NewTenantProjectController>(force: true);
    super.dispose();
  }

  Future<void> getList([bool appendData = false]) async {
    if (!appendData) {
      loadingData.value = true;
    } else {
      loadingPaginationData.value = true;
    }
    setDefaultData.data.value == [];
    setDefaultData.data.refresh();
    update();
    final url = Config.weburl + pageName.value;
    final userAction = "list${pageName.value}";
    var filter = {};
    for (var entry in setDefaultData.filterData.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.toString().isNotNullOrEmpty) {
        filter[key] = value;
      }
    }

    filter.remove('searchtext');
    Map<String, dynamic> reqBody = {
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
      fieldsSetting = resBody['defaultsettings'];
      for (var field in setDefaultData.fieldOrder) {
        if (field['masterdata'] != null && field['masterdataarray'] != null && field['masterdatadependancy'] != null) {
          if (field['masterdata'] && !field['masterdataarray'] && !field['masterdatadependancy'] && !setDefaultData.masterData[field['storemasterdatabyfield'] == true ? field['field'] : field['masterdata']]) {
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
    }

    loadingData.value = false;
    loadingPaginationData.value = false;
    loadingData.refresh();
    setDefaultData.fieldOrder.refresh();
    setDefaultData.data.refresh();
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
    setDefaultData.oldFilterData.value = IISMethods().encryptDecryptObj(setDefaultData.filterData.value);

    ///comment temp

    for (var fields in setDefaultData.fieldOrder) {
      devPrint(fields);
      if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
        var isTrue = fields.containsKey("masterdatadependancy");
        if (isTrue) {
          isTrue = fields["masterdatadependancy"];
        }
        if (isTrue || !setDefaultData.masterData.containsKey(fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) || fields["isselfrefernce"] == null || fields["setvaluefromlogininfo"] == null) {
          await getMasterData(
            pageNo: 1,
            fieldObj: fields,
            formData: setDefaultData.filterData,
          );
          jsonPrint(fields, tag: 'fields');
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
      } else if (fields["masterdata"] != null && fields.containsKey("masterdataarray") && !setDefaultData.masterData.containsKey(fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
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
    formLoadingData.value = false;
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

      var projection = {};

      if (fieldObj["projection"] != null) {
        projection = {...fieldObj["projection"]};
      }

      var sort = {};

      if (fieldObj["sort"] != null) {
        sort = {...fieldObj["sort"]};
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
          "paginationinfo": {"pageno": pageNo, "pagelimit": 500000000000, "filter": filter, "projection": projection, "sort": sort}
        };

        var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value, masterlisting: !(fieldObj['type'] == HtmlControls.kTable));

        if (resBody["status"] == 200) {
          if (pageNo == 1) {
            setDefaultData.masterData[masterDataKey] = [];
            setDefaultData.masterDataList[masterDataKey] = [];
          }
          for (var data in resBody["data"]) {
            setDefaultData.masterData[masterDataKey].add({"label": data[fieldObj["masterdatafield"]], "value": data["_id"].toString()});
          }

          setDefaultData.masterDataList[masterDataKey] = [...setDefaultData.masterDataList[masterDataKey], ...resBody["data"]];

          if (fieldObj['type'] == HtmlControls.kTable) {
            setDefaultData.formData[fieldObj['field']] = IISMethods().encryptDecryptObj(setDefaultData.masterDataList[masterDataKey]);
            try {
              fieldObj['fieldorder'] = resBody["fieldorder"]['fields'];
            } catch (e) {}
          }
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

  Future setFormData({String? id, int? editeDataIndex, bool? clone, bool canSwitchTab = true}) async {
    formKey0.currentState?.reset();
    validator.clear();
    dialogBoxData.value = TenantsSRAJson.designationFormFields(pageName.value);
    formLoadingData.value = true;

    if (canSwitchTab) {
      selectedTab.value = 0;
    }
    expandedIndex.value = 0;
    validateForm.value = false;
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
        if (data['type'] == HtmlControls.kFieldGroupList) {
          tempFormData[data['field']] = [{}];
        } else {
          for (var fields in data["formFields"]) {
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
              case HtmlControls.kMultipleTextFieldWithTitle:
              case HtmlControls.kTable:
                tempFormData[fields["field"]] = fields["defaultvalue"] ?? [];
              default:
                tempFormData[fields["field"]] = fields["defaultvalue"] ?? '';
                break;
            }
          }
        }
      }
    }
    tempFormData['pincodeNewEntry'] = 0;
    setPaymentInTable(tempFormData['_id']);
    setDefaultData.formData.value = Map<String, dynamic>.from(tempFormData);

    ///comment temp
    getMasterDataListForTab();
    formLoadingData.value = false;
    update();
  }

  Future<void> getMasterDataListForTab() async {
    List fieldList = [];
    isMasterDataEditing.value = false;
    setDefaultData.masterFormData.clear();
    if (dialogBoxData['dataview'] == 'tab') {
      fieldList = [
        dialogBoxData["formfields"][selectedTab.value],
      ];
    } else {
      fieldList = dialogBoxData["formfields"];
    }
    for (var data in fieldList) {
      for (var fields in data["formFields"]) {
        devPrint(fields);
        if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
          var isTrue = fields.containsKey("masterdatadependancy");
          if (isTrue) {
            isTrue = fields["masterdatadependancy"];
          }
          if (isTrue || !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) || fields["isselfrefernce"] == null || fields["setvaluefromlogininfo"] == null) {
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
        } else if (fields["masterdata"] != null && fields.containsKey("masterdataarray") && !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
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

    await getWbsCodes();
  }

  Future<void> getWbsCodes() async {
    if (selectedTab.value == 2) {
      Map<String, dynamic> reqestBody = {};
      // if (page == 'society') {
      reqestBody = {
        'searchtext': '',
        'paginationinfo': {
          'pageno': 1,
          'pagelimit': 10,
          'filter': {
            'societyid': setDefaultData.masterFormData['_id'] ?? '',
            'tenantprojectid': setDefaultData.formData['_id'] ?? '',
            'forsociety': 1,
          },
          'sort': {},
        },
      };
      var response = await IISMethods().listData(userAction: 'listwbscodes', pageName: pageName.value, url: '${Config.weburl}wbscodes', reqBody: reqestBody);
      if (response['status'] == 200) {
        setDefaultData.masterFormData['wbscodes'] = response["data"];
      }
    } else if (selectedTab.value == 3) {
      Map<String, dynamic> reqestBody = {};
      reqestBody = {
        'searchtext': '',
        'paginationinfo': {
          'pageno': 1,
          'pagelimit': 10,
          'filter': {
            'sraid': setDefaultData.masterFormData['_id'] ?? '',
            'tenantprojectid': setDefaultData.formData['_id'] ?? '',
            'forsra': 1,
          },
          'sort': {},
        },
      };
      // }
      var response = await IISMethods().listData(userAction: 'listwbscodes', pageName: pageName.value, url: '${Config.weburl}wbscodes', reqBody: reqestBody);
      if (response['status'] == 200) {
        setDefaultData.masterFormData['wbscodes'] = response["data"];
      }
    }
  }

  Future setMasterFormData({String? id, String? parentId, int? editeDataIndex, bool? clone, String? page, bool canSwitchTab = true}) async {
    dialogBoxData.value = TenantsSRAJson.designationFormFields(page.toString());
    masterFormLoadingData.value = true;
    if (canSwitchTab) {
      selectedTab.value = 0;
    }
    expandedIndex.value = 0;
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
        if (data['type'] == HtmlControls.kFieldGroupList) {
          tempFormData[data['field']] = [{}];
        } else {
          for (var fields in (data["formFields"])) {
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
              case HtmlControls.kMultipleTextFieldWithTitle:
                tempFormData[fields["field"]] = <Map<String, dynamic>>[];
                break;
              default:
                tempFormData[fields["field"]] = fields["defaultvalue"] ?? '';
                break;
            }
          }
        }
      }
    }

    setDefaultData.masterFormData.value = Map<String, dynamic>.from(tempFormData);
    setDefaultData.masterFormData['tenantprojectid'] = parentId;

    ///comment temp
    for (var data in dialogBoxData["formfields"]) {
      for (var fields in data["formFields"]) {
        if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
          var isTrue = fields.containsKey("masterdatadependancy");
          if (isTrue) {
            isTrue = fields["masterdatadependancy"];
          }
          if (isTrue || !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) || fields["isselfrefernce"] == null || fields["setvaluefromlogininfo"] == null) {
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
        } else if (fields["masterdata"] != null && fields.containsKey("masterdataarray") && !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
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

    devPrint(page);
    if (page == 'srabody' || page == 'society') {
      Map<String, dynamic> reqBody = {};
      if (page == 'society') {
        reqBody = {
          'searchtext': '',
          'paginationinfo': {
            'pageno': 1,
            'pagelimit': 10,
            'filter': {
              'societyid': setDefaultData.masterFormData['_id'] ?? '',
              'tenantprojectid': setDefaultData.masterFormData['tenantprojectid'] ?? '',
              'forsociety': 1,
            },
            'sort': {},
          },
        };
      } else if (page == 'srabody') {
        reqBody = {
          'searchtext': '',
          'paginationinfo': {
            'pageno': 1,
            'pagelimit': 10,
            'filter': {
              'sraid': setDefaultData.masterFormData['_id'] ?? '',
              'tenantprojectid': setDefaultData.masterFormData['tenantprojectid'] ?? '',
              'forsra': 1,
            },
            'sort': {},
          },
        };
      }
      var response = await IISMethods().listData(userAction: 'listwbscodes', pageName: pageName.value, url: '${Config.weburl}wbscodes', reqBody: reqBody);
      if (response['status'] == 200) {
        setDefaultData.masterFormData['wbscodes'] = response["data"];
      }
    }
    masterFormLoadingData.value = false;
    update();
  }

  Future<void> setUserInTable(String id) async {
    var responseData = await IISMethods().listData(
      userAction: "listtenantproject",
      pageName: 'tenantproject',
      url: '${Config.weburl}tenantprojectmanager',
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"tenantprojectid": id},
          "projection": {},
          "sort": {}
        }
      },
    );

    var dataList = responseData['data'];

    if (dataList.isNotEmpty) {
      var firstDataItem = dataList[0];
      var parsedData = Map<String, dynamic>.from(firstDataItem);
      setDefaultData.masterFormData.value = parsedData.toString().isNotNullOrEmpty ? parsedData : {};
    } else {
      devPrint('Data list is empty');
      setDefaultData.masterFormData.value = {};
    }
  }

  Future<void> setPaymentInTable(String? id) async {
    if (id.isNullOrEmpty) {
      return;
    }
    var responseData = await IISMethods().listData(
      userAction: "listtenantproject",
      pageName: 'tenantproject',
      url: '${Config.weburl}paymentconfiguration',
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {
            "tenantprojectid": id ?? '',
            'fortenant': 1,
          },
          "projection": {},
          "sort": {}
        }
      },
    );

    if ((responseData['data'] ?? []).isNotEmpty) {
      var parsedData = Map<String, dynamic>.from(responseData['data']);
      setDefaultData.formData.value.addAll(parsedData.toString().isNotNullOrEmpty ? parsedData : {});
      setDefaultData.formData.refresh();
    } else {
      devPrint('Data list is empty');
      setDefaultData.formData.value = {};
    }
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
              setDefaultData.formData["cityid"] = (setDefaultData.masterDataList['pincode'] as List?)?.first['cityid'];
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
                "${fieldObj["field"]}": res[fieldObj["masterdatafield"]],
              });
            }
          }
        } catch (e) {
          setDefaultData.formData[key] = [];
        }
        break;
      case HtmlControls.kFilePicker:
      case HtmlControls.kImagePicker:
      case HtmlControls.kAvatarPicker:
        {
          value as List<FilesDataModel>;
          value = List<FilesDataModel>.from(await IISMethods().uploadFiles(value));
          if (value.isNotEmpty) {
            Map? oldData = IISMethods().encryptDecryptObj((setDefaultData.formData[key] ?? {})['url'].toString().isNotNullOrEmpty ? setDefaultData.formData[key] : null);

            setDefaultData.formData[key] = value.first.toJson();
            if (oldData?['old'] == null) {
              setDefaultData.formData[key]['old'] = IISMethods().encryptDecryptObj(oldData);
            } else {
              setDefaultData.formData[key]['old'] = IISMethods().encryptDecryptObj(oldData?['old']);
            }
          }
        }
        devPrint(setDefaultData.formData[key]);
        break;

      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        if (fieldObj["masterdataarray"] != null) {
          setDefaultData.formData[key] = value ?? '';
        } else {
          var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
          setDefaultData.formData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
          setDefaultData.formData[key] = res?["_id"];

          if (key == 'hutmentid') {
            setDefaultData.formData['tenantname'] = res?['tenantname'] ?? '';
          }
        }

        break;
      case HtmlControls.kCheckBox:
        setDefaultData.formData[key] = value ? 1 : 0;
      case HtmlControls.kMultipleTextFieldWithTitle:
        setDefaultData.formData[key] = value;
      default:
        setDefaultData.formData[key] = value.toString();
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

  Future handleFormGroupField({
    type,
    groupKey,
    index,
    key,
    value,
    onChangeFill = true,
  }) async {
    switch (type) {
      case HtmlControls.kNumberInput:
        if (value.toString().contains(".")) {
          setDefaultData.formData[groupKey][index][key] = double.tryParse(value?.toString() ?? '0');
        } else {
          setDefaultData.formData[groupKey][index][key] = int.tryParse(value?.toString() ?? '0');
        }
        // if (key == 'rentinmonth') {
        //   if (setDefaultData.formData[groupKey][index]['noofmonths'].toString().isNotNullOrEmpty) {
        //     devPrint(int.parse(setDefaultData.formData[groupKey][index]['noofmonths'].toString()));
        //     devPrint(int.parse(setDefaultData.formData[groupKey][index]['noofmonths'].toString()));
        //     setDefaultData.formData[groupKey][index]['totalrent'] =
        //         (double.parse(setDefaultData.formData[groupKey][index]['noofmonths'].toString()) * double.parse(value.toString())).toStringAsFixed(2);
        //   }
        // }
        break;
      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
        setDefaultData.formData[groupKey][index][fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
        setDefaultData.formData[groupKey][index][key] = res?["_id"];

        if (key == 'paymenttypeid') {
          setDefaultData.formData[groupKey][index]['noofmonths'] = '';
          setDefaultData.formData[groupKey][index]['startdate'] = '';
          setDefaultData.formData[groupKey][index]['enddate'] = '';
          setDefaultData.formData[groupKey][index]['startdate'] = '';
          setDefaultData.formData[groupKey][index]['rentinmonth'] = '';
          setDefaultData.formData[groupKey][index]['totalrent'] = '';
          setDefaultData.formData[groupKey][index]['paymenttypecode'] = res?['paymenttypecode'];
          setDefaultData.formData[groupKey][index]['paymenttypename'] = res?['paymenttypename'];
          setDefaultData.formData[groupKey][index]['paymenttypefrequency'] = res?['paymenttypefrequency'];
          setDefaultData.formData[groupKey][index]['paymenttypefrequencystr'] = res?['paymenttypefrequencystr'];
        }
        break;
      case HtmlControls.kRadio:
      case HtmlControls.kCheckBox:
        if (key == 'isprimary' && value) {
          for (var data in setDefaultData.formData[groupKey]) {
            data[key] = 0;
          }
        }
        // else if (key == "isexpire" && !value) {
        //   return;
        // }
        setDefaultData.formData[groupKey][index][key] = value ? 1 : 0;

      case HtmlControls.kFilePicker:
      case HtmlControls.kImagePicker:
      case HtmlControls.kAvatarPicker:
        {
          value as List<FilesDataModel>;
          value = List<FilesDataModel>.from(await IISMethods().uploadFiles(value));
          if (value.isNotEmpty) {
            Map? oldData = IISMethods().encryptDecryptObj((setDefaultData.formData[groupKey][index][key] ?? {})['url'].toString().isNotNullOrEmpty ? setDefaultData.formData[groupKey][index][key] : null);
            setDefaultData.formData[groupKey][index][key] = value.first.toJson();
            if (oldData?['old'] == null) {
              setDefaultData.formData[groupKey][index][key]['old'] = IISMethods().encryptDecryptObj(oldData);
            } else {
              setDefaultData.formData[groupKey][index][key]['old'] = IISMethods().encryptDecryptObj(oldData?['old']);
            }
          }
        }
        break;
      case HtmlControls.kMultiSelectDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        try {
          if (fieldObj.containsKey("masterdataarray")) {
            try {
              for (var e in value) {
                setDefaultData.formData[groupKey][index][key].add({
                  "${fieldObj["field"]}id": e,
                  "${fieldObj["field"]}": e,
                });
              }
            } catch (e) {
              setDefaultData.formData[groupKey][index][key] = [];
            }
          } else {
            setDefaultData.formData[groupKey][index][key] = [];
            for (var e in value) {
              var masterDataKey = fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"];
              var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[masterDataKey], "_id", e);

              setDefaultData.formData[groupKey][index][key].add({
                "${fieldObj["field"]}id": e,
                "${fieldObj["formdatafield"]}": res[fieldObj["masterdatafield"]],
              });
            }
          }
        } catch (e) {
          setDefaultData.formData[key] = [];
        }
        break;
      case HtmlControls.kMultipleImagePicker:
        {
          if (setDefaultData.formData[groupKey][index][key] == null) {
            setDefaultData.formData[groupKey][index][key] == [];
          }
          value as List<FilesDataModel>;
          setDefaultData.formData[groupKey][index][key] as List;
          setDefaultData.formData[groupKey][index][key].addAll(value.map((element) {
            return element.toJson();
          }).toList());
          setDefaultData.formData.refresh();
          value = List<FilesDataModel>.from(
            await IISMethods().uploadFiles(
              List<FilesDataModel>.from(setDefaultData.formData[groupKey][index][key].map((element) {
                return FilesDataModel.fromJson(element);
              }).toList()),
            ),
          );
          if (value.isNotEmpty) {
            setDefaultData.formData[groupKey][index][key] = value.map((element) {
              return element.toJson();
            }).toList();
          }
        }
        break;
      default:
        // if (key == 'startdate') {
        //   if (setDefaultData.formData[groupKey][index]['noofmonths'].toString().isNotNullOrEmpty) {
        //     DateTime startDate = DateTime.parse(value);
        //     setDefaultData.formData[groupKey][index]['enddate'] =
        //         dateConvertIntoUTC(DateTime(startDate.year, startDate.month + int.parse(setDefaultData.formData[groupKey][index]['noofmonths'].toString()), startDate.day));
        //   }
        // }

        setDefaultData.formData[groupKey][index][key] = value;
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
        if (setDefaultData.masterData[masterDataKey]?.length >= 1 && false) {
          await handleFormData(
            key: obj2["field"],
            value: setDefaultData.masterData[masterDataKey]?.first['value'],
            type: obj2['type'],
          );
        }
      }
    }

    if (key == 'paymentinstrumentid') {
      setDefaultData.formData[groupKey][index]['paymentno'] = '';
      setDefaultData.formData[groupKey][index]['paymentdate'] = '';
      setDefaultData.formData[groupKey][index]['paymentreceivedsitedate'] = '';
      setDefaultData.formData[groupKey][index]['paymenthandoverdate'] = '';
    }

    setDefaultData.formData.refresh();
    update();
  }

  Future handleMasterFormGroupField({
    type,
    groupKey,
    index,
    key,
    value,
    onChangeFill = true,
  }) async {
    switch (type) {
      case HtmlControls.kNumberInput:
        if (value.toString().contains(".")) {
          setDefaultData.masterFormData[groupKey][index][key] = double.tryParse(value?.toString() ?? '0');
        } else {
          setDefaultData.masterFormData[groupKey][index][key] = int.tryParse(value?.toString() ?? '0');
        }
        // if (key == 'rentinmonth') {
        //   if (setDefaultData.masterFormData[groupKey][index]['noofmonths'].toString().isNotNullOrEmpty) {
        //     devPrint(int.parse(setDefaultData.masterFormData[groupKey][index]['noofmonths'].toString()));
        //     devPrint(int.parse(setDefaultData.masterFormData[groupKey][index]['noofmonths'].toString()));
        //     setDefaultData.masterFormData[groupKey][index]['totalrent'] =
        //         (double.parse(setDefaultData.masterFormData[groupKey][index]['noofmonths'].toString()) * double.parse(value.toString())).toStringAsFixed(2);
        //   }
        // }
        break;
      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
        setDefaultData.masterFormData[groupKey][index][fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
        setDefaultData.masterFormData[groupKey][index][key] = res?["_id"];

        if (key == 'paymenttypeid') {
          setDefaultData.masterFormData[groupKey][index]['noofmonths'] = '';
          setDefaultData.masterFormData[groupKey][index]['startdate'] = '';
          setDefaultData.masterFormData[groupKey][index]['enddate'] = '';
          setDefaultData.masterFormData[groupKey][index]['startdate'] = '';
          setDefaultData.masterFormData[groupKey][index]['rentinmonth'] = '';
          setDefaultData.masterFormData[groupKey][index]['totalrent'] = '';
          setDefaultData.masterFormData[groupKey][index]['paymenttypecode'] = res?['paymenttypecode'];
          setDefaultData.masterFormData[groupKey][index]['paymenttypename'] = res?['paymenttypename'];
          setDefaultData.masterFormData[groupKey][index]['paymenttypefrequency'] = res?['paymenttypefrequency'];
          setDefaultData.masterFormData[groupKey][index]['paymenttypefrequencystr'] = res?['paymenttypefrequencystr'];
        }
        break;
      case HtmlControls.kRadio:
      case HtmlControls.kCheckBox:
        if (key == 'isprimary' && value) {
          for (var data in setDefaultData.masterFormData[groupKey]) {
            data[key] = 0;
          }
        }
        // else if (key == "isexpire" && !value) {
        //   return;
        // }
        setDefaultData.masterFormData[groupKey][index][key] = value ? 1 : 0;

      case HtmlControls.kFilePicker:
      case HtmlControls.kImagePicker:
      case HtmlControls.kAvatarPicker:
        {
          value as List<FilesDataModel>;
          value = List<FilesDataModel>.from(await IISMethods().uploadFiles(value));
          if (value.isNotEmpty) {
            Map? oldData = IISMethods().encryptDecryptObj((setDefaultData.masterFormData[groupKey][index][key] ?? {})['url'].toString().isNotNullOrEmpty ? setDefaultData.masterFormData[groupKey][index][key] : null);
            setDefaultData.masterFormData[groupKey][index][key] = value.first.toJson();
            if (oldData?['old'] == null) {
              setDefaultData.masterFormData[groupKey][index][key]['old'] = IISMethods().encryptDecryptObj(oldData);
            } else {
              setDefaultData.masterFormData[groupKey][index][key]['old'] = IISMethods().encryptDecryptObj(oldData?['old']);
            }
          }
        }
        break;
      case HtmlControls.kMultiSelectDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        try {
          if (fieldObj.containsKey("masterdataarray")) {
            try {
              for (var e in value) {
                setDefaultData.masterFormData[groupKey][index][key].add({
                  "${fieldObj["field"]}id": e,
                  "${fieldObj["field"]}": e,
                });
              }
            } catch (e) {
              setDefaultData.masterFormData[groupKey][index][key] = [];
            }
          } else {
            setDefaultData.masterFormData[groupKey][index][key] = [];
            for (var e in value) {
              var masterDataKey = fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"];
              var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[masterDataKey], "_id", e);

              setDefaultData.masterFormData[groupKey][index][key].add({
                "${fieldObj["field"]}id": e,
                "${fieldObj["formdatafield"]}": res[fieldObj["masterdatafield"]],
              });
            }
          }
        } catch (e) {
          setDefaultData.masterFormData[key] = [];
        }
        break;
      case HtmlControls.kMultipleImagePicker:
        {
          if (setDefaultData.masterFormData[groupKey][index][key] == null) {
            setDefaultData.masterFormData[groupKey][index][key] == [];
          }
          value as List<FilesDataModel>;
          setDefaultData.masterFormData[groupKey][index][key] as List;
          setDefaultData.masterFormData[groupKey][index][key].addAll(value.map((element) {
            return element.toJson();
          }).toList());
          setDefaultData.masterFormData.refresh();
          value = List<FilesDataModel>.from(
            await IISMethods().uploadFiles(
              List<FilesDataModel>.from(setDefaultData.masterFormData[groupKey][index][key].map((element) {
                return FilesDataModel.fromJson(element);
              }).toList()),
            ),
          );
          if (value.isNotEmpty) {
            setDefaultData.masterFormData[groupKey][index][key] = value.map((element) {
              return element.toJson();
            }).toList();
          }
        }
        break;
      default:
        // if (key == 'startdate') {
        //   if (setDefaultData.masterFormData[groupKey][index]['noofmonths'].toString().isNotNullOrEmpty) {
        //     DateTime startDate = DateTime.parse(value);
        //     setDefaultData.masterFormData[groupKey][index]['enddate'] =
        //         dateConvertIntoUTC(DateTime(startDate.year, startDate.month + int.parse(setDefaultData.masterFormData[groupKey][index]['noofmonths'].toString()), startDate.day));
        //   }
        // }
        setDefaultData.masterFormData[groupKey][index][key] = value;
    }

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
        if (setDefaultData.masterData[masterDataKey]?.length >= 1 && false) {
          await handleFormData(
            key: obj2["field"],
            value: setDefaultData.masterData[masterDataKey]?.first['value'],
            type: obj2['type'],
          );
        }
      }
    }

    handleRentCalculation(index);

    if (key == 'paymentinstrumentid') {
      setDefaultData.masterFormData[groupKey][index]['paymentno'] = '';
      setDefaultData.masterFormData[groupKey][index]['paymentdate'] = '';
      setDefaultData.masterFormData[groupKey][index]['paymentreceivedsitedate'] = '';
      setDefaultData.masterFormData[groupKey][index]['paymenthandoverdate'] = '';
    }

    setDefaultData.masterFormData.refresh();
    update();
  }

  handleRentCalculation(index) {
    if (setDefaultData.masterFormData['payments'][index]['paymenttypefrequency'] == 2) {
      double rentInMonths = setDefaultData.masterFormData['payments'][index]['rentinmonth'].toString().converttoDouble;
      double noOfMonths = setDefaultData.masterFormData['payments'][index]['noofmonths'].toString().converttoDouble;
      if (setDefaultData.masterFormData['payments'][index]['startdate'].toString().isNotNullOrEmpty) {
        DateTime startDate = DateTime.parse(setDefaultData.masterFormData['payments'][index]['startdate'].toString());

        setDefaultData.masterFormData['payments'][index]['enddate'] =
            dateConvertIntoUTC(DateTime(startDate.year, startDate.month + int.parse(setDefaultData.masterFormData['payments'][index]['noofmonths'].toString()), startDate.day).subtract(Duration(days: 1)));
      }
      setDefaultData.masterFormData['payments'][index]['totalrent'] = (rentInMonths * noOfMonths).toStringAsFixed(2).converttoDouble;
      setDefaultData.masterFormData['payments'][index]['totalpayable'] = (setDefaultData.masterFormData['payments'][index]['totalrent'].toString().converttoDouble).toStringAsFixed(2).converttoDouble;
    }
  }

  Future handleMasterFormData({
    type,
    key,
    value,
    fieldType,
    fieldKey,
    fieldValue,
    onChangeFill = true,
  }) async {
    devPrint(value);
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

              // setDefaultData.masterFormData[key].add({
              //   "${fieldObj["field"]}id": e,
              //   "${fieldObj["field"]}": res[fieldObj["masterdatafield"]],
              // });
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
            Map oldData = IISMethods().encryptDecryptObj(setDefaultData.masterFormData[key] ?? {});
            setDefaultData.masterFormData[key] = value.first.toJson();
            if (oldData['old'] == null) {
              setDefaultData.masterFormData[key]['old'] = IISMethods().encryptDecryptObj(oldData);
            } else {
              setDefaultData.masterFormData[key]['old'] = IISMethods().encryptDecryptObj(oldData['old']);
            }
            if (key == 'tenantcanceledcheque') {
              AppLoader();
              var response = await IISMethods().listData(userAction: 'addtenantproject', pageName: 'tenantproject', url: '${Config.weburl}readcheque', reqBody: value.first.toJson());
              if (response['status'] == 200) {
                showSuccess(response['message'] ?? '');
              } else {
                showError(response['message'] ?? '');
              }
              setDefaultData.masterFormData.addAll(Map<String, dynamic>.from(response['data'] ?? {}));
              RemoveAppLoader();
            }
          }
        }
        break;

      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["formfields"], key);
        if (fieldObj["masterdataarray"] != null) {
          setDefaultData.masterFormData[key] = value ?? '';
        } else {
          var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
          devPrint(res);
          setDefaultData.masterFormData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
          setDefaultData.masterFormData[key] = res?["_id"];
          if (key == 'pincodeid') {
            setDefaultData.masterFormData["area"] = res['area'];
            setDefaultData.masterFormData["city"] = res['city'];
          }
          if (key == 'hutmentid') {
            setDefaultData.masterFormData['tenantname'] = res['tenantname'] ?? '';
          }
          if (key == 'paymenttypeid') {
            setDefaultData.masterFormData['noofmonths'] = '';
            setDefaultData.masterFormData['startdate'] = '';
            setDefaultData.masterFormData['enddate'] = '';
            setDefaultData.masterFormData['startdate'] = '';
            setDefaultData.masterFormData['rentinmonth'] = '';
            setDefaultData.masterFormData['totalrent'] = '';
            setDefaultData.masterFormData['paymenttypecode'] = res?['paymenttypecode'];
            setDefaultData.masterFormData['paymenttypename'] = res?['paymenttypename'];
            setDefaultData.masterFormData['paymenttypefrequency'] = res?['paymenttypefrequency'];
            setDefaultData.masterFormData['paymenttypefrequencystr'] = res?['paymenttypefrequencystr'];
          }

          if (key == 'documenttypeid') {
            setDefaultData.masterFormData['documentlevelid'] = res?['level'];
            setDefaultData.masterFormData['documentlevelname'] = res?['levelname'];
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
      case HtmlControls.kMultipleTextFieldWithTitle:
        setDefaultData.masterFormData[key] = value;
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
    devPrint(setDefaultData.masterFormData);
    // setManagerAssignData();

    update();
  }

  void setManagerAssignData() {
    setDefaultData.masterFormData['managerassign'] = [];

    setDefaultData.masterFormData['managerassign'] = ((setDefaultData.masterFormData['clustermanager'] ?? []) as List).map((e) {
      e['_id'] = e['clustermanagerid'];
      return e;
    }).toList();
    if (setDefaultData.masterFormData['projectmanagerid'].toString().isNotNullOrEmpty) {
      ((setDefaultData.masterFormData['managerassign']) as List).insert(
        0,
        {
          'name': setDefaultData.masterFormData['projectmanager'] ?? '',
          'email': setDefaultData.masterFormData['email'] ?? '',
          'userrole': setDefaultData.masterFormData['userrole'] ?? '',
          'userroleid': setDefaultData.masterFormData['userroleid'] ?? '',
          '_id': setDefaultData.masterFormData['projectmanagerid'] ?? '',
        },
      );
    }
  }

  handleGridChange({required int index, required String field, required String type, dynamic value}) async {
    switch (type) {
      case HtmlControls.kStatus:
      case HtmlControls.kSwitch:
        setDefaultData.data[index][field] = value ? 1 : 0;
        // Get.back();
        break;

      case HtmlControls.kDocumentAdd:
        var obj1 = getObjectFromFormData(dialogBoxData["formfields"], field);

        List<FilesDataModel> files = await IISMethods().pickSingleFile(fileType: obj1['filetypes']);
        files = await IISMethods().uploadFiles(files);
        setDefaultData.data[index][field] = files.first.toJson();
    }
    if (await updateData(reqData: setDefaultData.data[index], editeDataIndex: index)) {}
  }

  // handleMemberInfo({required int index, required String type}) {
  //   devPrint("$index    6833643335");
  // }

  handleAddButtonClick() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (setDefaultData.formData.containsKey('_id')) {
      if (await updateData(reqData: setDefaultData.formData)) {
        if (dialogBoxData['dataview'] != 'tab' || dialogBoxData['formfields'].length - 1 == selectedTab.value) {
          Get.back();
        } else {
          selectedTab.value++;
        }
      }
    } else {
      await addData(reqData: setDefaultData.formData);
    }
  }

  Future<bool> handleMasterAddButtonClick({String? pagename}) async {
    if (setDefaultData.masterFormData.containsKey('_id')) {
      return (await updateMasterData(reqData: setDefaultData.masterFormData, pagename: pagename));
    } else {
      return (await addMasterData(reqData: setDefaultData.masterFormData, pageName: pagename));
    }
  }

  //call add data request
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
      if (dialogBoxData['dataview'] != 'tab' || dialogBoxData['formfields'].length - 1 == selectedTab.value) {
        Get.back();
      } else {
        selectedTab.value++;
        setDefaultData.formData.value = resBody['data'];
        setPaymentInTable(resBody['data']['_id']);
      }
      showSuccess(message.value);
    } else {
      message.value = resBody["message"];
      showError(message.value);
    }
  }

  Future<bool> addMasterData({reqData, pageName}) async {
    devPrint("$pageName   45445455");
    var url = '${Config.weburl}$pageName/add';
    var userAction = "addtenantproject";
    var resBody = await IISMethods().addData(url: url, reqBody: reqData, userAction: userAction, pageName: 'tenantproject');
    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody["message"];
      getMasterFormData(id: reqData['tenantprojectid'], pagename: pageName);
      showSuccess(message.value);
    } else {
      message.value = resBody["message"];
      showError(message.value);
    }
    return resBody["status"] == 200;
  }

  getMasterFormData({String? id, String? documenttype, String? documenttypeid, String? pagename, Map? sort}) async {
    devPrint("$pagename    212478841");
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 99999999999,
        "filter": {
          "tenantprojectid": id,
        },
        "sort": sort ?? {}
      }
    };
    var response;
    try {
      response = await IISMethods().listData(userAction: 'list${pageName.value.toString()}', pageName: pageName.value.toString(), url: '${Config.weburl}${pagename.toString()}', reqBody: reqBody);
    } on Exception catch (e) {
      devPrint(e);
    }

    setDefaultData.masterData[pagename.toString()] = response['data'];
    setDefaultData.masterFieldOrder.value = List<Map<String, dynamic>>.from(response['fieldorder']['fields']);
    canApprovePayment.value = response['canapprove'] == true;
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

  Future<bool> updateMasterData({
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
      getMasterFormData(id: reqData['tenantprojectid'], pagename: pagename);
      showSuccess(message.value);
    } else {
      message.value = resBody['message'];
      showError(message.value);
    }
    return resBody["status"] == 200;
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
      setDefaultData.data.refresh();
      Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody['message'];
      Get.back();
      showError(message.value);
    }
  }

  Future deleteMasterData({reqData, pageName}) async {
    String url = '${Config.weburl + pageName}/delete';

    String userAction = "deletetenantproject";

    var resBody = await IISMethods().deleteData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName);
    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = resBody['message'];
      Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody['message'];
      Get.back();
      showError(message.value);
    }
  }

  RxList<Map<String, dynamic>> filterDocumentTypeList = <Map<String, dynamic>>[].obs;
  Map<String, dynamic> selectedDocumentType = {};

  getFilterDocumentList() async {
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": {}, "projection": {}, "sort": {}}
    };
    filterDocumentTypeList.value = List<Map<String, dynamic>>.from(
      ((await IISMethods().listData(userAction: 'listdocumenttypedata', pageName: 'tenantproject', url: '${Config.weburl}documenttype', reqBody: reqBody))['data']) ?? [],
    );
    if (filterDocumentTypeList.value.isNotNullOrEmpty) {
      for (var i = 0; i < filterDocumentTypeList.value.length; i++) {
        filterDocumentTypeList.value[i]['label'] = filterDocumentTypeList.value[i]['documenttype'] ?? "";
        filterDocumentTypeList.value[i]['value'] = filterDocumentTypeList.value[i]['_id'] ?? "";
      }
    }
  }

//SOCIETY-->PUSHTOSAP

  Future pushSocietyToSAP(List<Map<String, dynamic>> tenantData) async {
    Map<String, dynamic> reqBody = {};
    reqBody['data'] = tenantData.map(
      (e) {
        return {'tenantid': e['_id'], ...e};
      },
    ).toList();
    reqBody['forsociety'] = 1;

    var response = await IISMethods().listData(
      userAction: 'synctosap',
      pageName: 'tenantproject',
      url: '${Config.weburl}synctosap',
      reqBody: reqBody,
    );
    if (response['status'] == 200) {
      // showSuccess(response['message'].toString());
    } else {
      showError(response['message'].toString());
    }
    return response;
  }

  Future<void> getSocietySapData({required List selectedIds, required String tenantProjectId}) async {
    if (selectedIds.isNullOrEmpty) {
      showError('Select Atleast 1 Society');
      return;
    }
    RxMap<String, dynamic> totalRentData = <String, dynamic>{}.obs;
    RxBool sapDataLoading = true.obs;
    selectAll.value = false;
    selectionCount.value = 0;
    isSocietyApproving.value = false;
    FormDataModel sapSetDefaultData = FormDataModel();
    final url = "${Config.weburl}paymentlisting";
    const userAction = "listpaymentlisting";
    final reqBody = {
      'searchtext': '',
      'paginationinfo': {
        'pageno': 1,
        'pagelimit': 999999999999,
        'filter': {
          "ids": selectedIds,
          "tenantprojectid": tenantProjectId,
          'forsociety': 1,
        },
        'sort': {},
      },
    };
    RxInt stage = 0.obs;
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;

    if (resBody["status"] == 200) {
      sapSetDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"] ?? []);
      sapSetDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data'] ?? []);
      totalRentData.value = resBody['totalpayment'] ?? {};
      sapDataLoading.value = false;

      await CustomDialogs().customFilterDialogs(
          context: Get.context!,
          widget: SapDialog(
            title: 'Society',
            fieldOrder: sapSetDefaultData.fieldOrder,
            data: sapSetDefaultData.data,
            isLoading: sapDataLoading,
            setDefaultData: sapSetDefaultData,
            rentMap: totalRentData,
            stage: stage,
            onSubmitToSAP: () async {
              var response = await pushSocietyToSAP(sapSetDefaultData.data);
              if (response['status'] == 200) {
                sapSetDefaultData.data.value = List<Map<String, dynamic>>.from(response['data']);
                sapSetDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(response['fieldorder']);
                stage.value = 1;
              }
            },
          ));
    }
  }

  Future<bool> getSAPContractHistory({required String id}) async {
    AppLoader();
    var res = await IISMethods().listData(
      userAction: "listsociety",
      pageName: "society",
      url: "${Config.weburl}rentstatus",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"societyid": id},
          "projection": {},
          "sort": {},
        },
      },
    );
    jsonPrint(res, tag: "1233489647574654165456");
    RemoveAppLoader();
    if (res['status'] == 200) {
      sapContractHistoryList.value = List<Map<String, dynamic>>.from(res["data"] ?? []);
      sapContractHistoryFieldOrderList.value = List<Map<String, dynamic>>.from(res['fieldorder']["fields"]);
      jsonPrint(sapContractHistoryList, tag: "3489647574654165456");
      CustomDialogs().customFilterDialogs(
        context: Get.context!,
        widget: ContractDetails(
          fieldOrder: sapContractHistoryFieldOrderList,
          data: sapContractHistoryList,
          isLoading: false.obs,
          setDefaultData: FormDataModel(),
        ),
      );
    }
    return res['status'] == 200;
  }

//SOCIETY-->PUSH TO SAP

//PAYMENT-->PUSH TO SAP

  Future pushPaymentToSAP(List<Map<String, dynamic>> tenantData) async {
    Map<String, dynamic> reqBody = {};
    reqBody['data'] = tenantData.map(
      (e) {
        return {
          'tenantid': e['_id'],
          'payments': e['payments'],
          ...e,
        };
      },
    ).toList();
    reqBody['forpayment'] = 1;

    var response = await IISMethods().listData(
      userAction: 'synctosap',
      pageName: 'tenantproject',
      url: '${Config.weburl}synctosap',
      reqBody: reqBody,
    );
    if (response['status'] == 200) {
      // showSuccess(response['message'].toString());
    } else {
      showError(response['message'].toString());
    }
    return response;
  }

  Future<void> getPaymentForSRA({required String groupId}) async {
    RxBool paymentForSRADataLoading = true.obs;

    List<Map<String, dynamic>> paymentForSRAData = <Map<String, dynamic>>[];
    paymentForSRADataLoading.value = true;
    final url = "${Config.weburl}paymentforsra";
    const userAction = "listpaymentforsralisting";
    final reqBody = {
      'searchtext': '',
      'paginationinfo': {
        'pageno': 1,
        'pagelimit': 999999999999,
        "filter": {"groupid": groupId},
        'sort': {},
      },
    };
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;

    if (resBody["status"] == 200) {
      paymentForSRAData = List<Map<String, dynamic>>.from(resBody['data'] ?? []);
      paymentForSRADataLoading.value = false;

      await CustomDialogs().customFilterDialogs(
          context: Get.context!,
          widget: PaymentForSraDialog(
            data: paymentForSRAData,
            title: 'Payment For SRA',
          ));
    }
    paymentForSRADataLoading.value = false;
  }

  Future<void> getPaymentSapData({required List selectedIds, required List paymentGroupIds, required String tenantProjectId}) async {
    if (selectedIds.isNullOrEmpty) {
      showError('Select Atleast 1 Payment');
      return;
    }
    RxMap<String, dynamic> totalRentData = <String, dynamic>{}.obs;
    RxBool sapDataLoading = true.obs;
    selectAll.value = false;
    selectionCount.value = 0;
    isApprovingPayment.value = false;
    FormDataModel sapSetDefaultData = FormDataModel();
    final url = "${Config.weburl}paymentlisting";
    const userAction = "listpaymentlisting";
    final reqBody = {
      'searchtext': '',
      'paginationinfo': {
        'pageno': 1,
        'pagelimit': 999999999999,
        'filter': {"ids": selectedIds, "tenantprojectid": tenantProjectId, 'forpayment': 1, 'paymentGroupIds': paymentGroupIds},
        'sort': {},
      },
    };
    RxInt stage = 0.obs;
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;

    if (resBody["status"] == 200) {
      sapSetDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"] ?? []);
      sapSetDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data'] ?? []);
      totalRentData.value = resBody['totalpayment'] ?? {};
      sapDataLoading.value = false;

      await CustomDialogs().customFilterDialogs(
        context: Get.context!,
        widget: SapDialog(
          title: 'Payment',
          fieldOrder: sapSetDefaultData.fieldOrder,
          data: sapSetDefaultData.data,
          isLoading: sapDataLoading,
          setDefaultData: sapSetDefaultData,
          rentMap: totalRentData,
          stage: stage,
          onSubmitToSAP: () async {
            var response = await pushPaymentToSAP(sapSetDefaultData.data);
            if (response['status'] == 200) {
              sapSetDefaultData.data.value = List<Map<String, dynamic>>.from(response['data']);
              sapSetDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(response['fieldorder']);
              stage.value = 1;
            }
          },
        ),
      );
    }
  }
//PAYMENT-->PUSHTOSAP
}
