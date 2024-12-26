import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';

import '../../components/funtions.dart';
import '../../components/json/sap_tenant_history.dart';
import '../../config/config.dart';
import '../../routes/route_generator.dart';
import '../../routes/route_name.dart';
import '../../utils/aws_service/file_data_model.dart';

class SapTenantHistoryController extends GetxController {
  RxString pageName = ''.obs;
  RxString formName = ''.obs;
  RxString message = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  RxMap dialogBoxData = {}.obs;
  Map validator = {};
  Map<int, FocusNode> focusNodes = {};
  RxMap<String, dynamic> uploadedFile = <String, dynamic>{}.obs;
  RxInt statusCode = 0.obs;
  RxBool loadingData = false.obs;
  RxBool loadingPaginationData = false.obs;
  RxBool formLoadingData = false.obs;
  RxBool updateObj = false.obs;
  RxBool addButtonLoading = false.obs;
  RxBool addMultipleButtonLoading = false.obs;
  final formKey0 = GlobalKey<FormState>();
  int cursorPos = 0;
  RxBool validateForm = false.obs;
  bool autoFilling = false;
  RxString searchText = ''.obs;
  RxBool isAddButtonVisible = false.obs;
  RxBool obscureText = true.obs;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();

  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};

  ScrollController tableScrollController = ScrollController();

  @override
  Future<void> onInit() async {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        tableScrollController.addListener(() async {
          if (tableScrollController.position.atEdge) {
            double offset = tableScrollController.offset;
            bool isTop = tableScrollController.position.pixels == 0;

            if (!isTop) {
              devPrint('🍺 At the bottom');
              if (setDefaultData.nextPage == 1) {
                setDefaultData.pageNo.value = setDefaultData.pageNo.value + 1;
                if (!loadingPaginationData.value) {
                  await getList(true);
                  // tableScrollController.animateTo(offset, duration: const Duration(milliseconds: 50), curve: Curves.linear);
                  // tableScrollController
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
    dialogBoxData.value = SapTenantHistoryJson.designationFormFields(pageName.value);
    formName.value = dialogBoxData['formname'] ?? "";
    isAddButtonVisible.value = IISMethods().hasAddRight(alias: pageName.value);
    formName.refresh();
    await setFormData();
    await getList();
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<SapTenantHistoryController>();
    super.dispose();
  }

  Future<void> getList([bool appendData = false]) async {
    if (!appendData) {
      setDefaultData.data.value == [];
      loadingData.value = true;
    } else {
      loadingPaginationData.value = true;
    }
    setDefaultData.data.refresh();
    update();
    final url = Config.weburl + pageName.value;
    final userAction = "list$pageName";
    Map filter = {}/*IISMethods().encryptDecryptObj(setDefaultData.formData)*/;
    for (var entry in setDefaultData.filterData.entries) {
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
    if (setDefaultData.data == []) {
      setDefaultData.pageNo = 1.obs;
    }
    final searchtext = searchText.value;
    filter.removeNullValues();
    final reqBody = {
      'searchtext': searchtext,
      'paginationinfo': {
        'pageno': setDefaultData.pageNo.value,
        'pagelimit': setDefaultData.pageLimit,
        'filter': filter,
        'sort': setDefaultData.sortData.value,
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
    } else {
      showError(resBody['message']);
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
            case HtmlControls.kMultiSelectDropDown:
            case HtmlControls.kDateRangePicker:
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
    setDefaultData.filterData.removeNullValues();
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
      if (pageName.value == "clustername" && fieldObj['field'] == 'tenantproject') {
        devPrint("4531434340");
        filter['unassigned'] = setDefaultData.formData.containsKey('_id') ? 2 : 1;
        filter['clusterid'] = setDefaultData.formData['_id'] ?? "";
        filter['cluster'] = 1;
      }
      // if (pageName.value == RouteNames.kProject.split('/').last && fieldObj['field'] == 'tenantprojectid') {
      //   filter['unassigned'] = setDefaultData.formData['_id'].toString().isNullOrEmpty ? 1 : 2;
      //   filter['projectid'] = setDefaultData.formData['_id'] ?? '';
      // }
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
          setPageTitle('${formName.value} | PRENEW', Get.context!);

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
              tempFormData[fields["field"]] = {};
              break;
            case HtmlControls.kDateRangePicker:
              tempFormData[fields["field"]] = <String>[];
              break;
            default:
              tempFormData[fields["field"]] = fields["defaultvalue"] ?? '';
              break;
          }
        });
      }
    }

    setDefaultData.formData.value = Map<String, dynamic>.from(tempFormData);
    // devPrint("\n\n\n\n" + pageName.value + "\n\n\n" + jsonEncode(tempFormData) + "\n\n\n\n1212121212");

    ///comment temp
    for (var data in dialogBoxData["formfields"]) {
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
    devPrint(value);
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
              jsonPrint(setDefaultData.masterDataList[masterDataKey], tag: 'masterDate');
              jsonPrint(res, tag: 'masterDate2');
              setDefaultData.formData[key].add({
                "${fieldObj["field"]}id": e,
                "${fieldObj["formdatafield"]}": res[fieldObj["masterdatafield"]],
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
    jsonPrint(setDefaultData.formData);
    update();
  }

// Future<void> exportReport() async {
//   final excel = Excel.createExcel();
//   String pagename = 'Tenant Report';
//
//   final sheet = excel['Tenant Report'];
//   excel.setDefaultSheet('Tenant Report');
//   excel.delete('Sheet1');
//   var boldStyle = CellStyle(
//     bold: true,
//     fontSize: 18,
//   );
//   for (Map<String, dynamic> tenantProject in setDefaultData.data) {
//     sheet.appendRow([TextCellValue(tenantProject['tenantprojectname'] ?? '')]);
//     sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1)).cellStyle = boldStyle;
//
//     sheet.appendRow(fieldOrder.map((e) => TextCellValue(e['text'] ?? '')).toList());
//     for (int i = 0; i < fieldOrder.length; i++) {
//       sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: sheet.maxRows - 1)).cellStyle = CellStyle(
//         bold: true,
//       );
//     }
//
//     for (Map<String, dynamic> tenant in tenantProject['tenants']) {
//       sheet.appendRow(fieldOrder.map((e) {
//         if (e['field'] == 'statusdate') {
//           return TextCellValue((tenant["${tenant['tenantstatusid'] ?? ""}_date"] ?? '').toString().toDateFormat());
//         }
//         if (tenant[e['field'] ?? ''] is List) {
//           return TextCellValue(((tenant[e['field'] ?? ''] ?? []).join(', ')).toString());
//         }
//         return TextCellValue((tenant[e['field'] ?? ''] ?? '').toString().toDateFormat());
//       }).toList());
//     }
//     sheet.appendRow([const TextCellValue('')]);
//   }
//   for (int i = 0; i < fieldOrder.length; i++) {
//     sheet.setColumnAutoFit(i);
//   }
//
//   if (kIsWeb) {
//     excel.save(fileName: '$pagename-${DateTime.now()}.xlsx');
//   } else {
//     Permission.manageExternalStorage.request();
//
//     var fileBytes = excel.save();
//     var directory = Platform.isAndroid ? await getDownloadsDirectory() : await getApplicationDocumentsDirectory();
//     devPrint(directory?.path);
//     File savedFile = File('${directory?.path}/$pagename-${DateTime.now()}.xlsx');
//     await savedFile.writeAsBytes(fileBytes!);
//     OpenFile.open(savedFile.path);
//   }
// }
}
