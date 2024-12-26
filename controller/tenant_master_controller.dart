import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:prestige_prenew_frontend/view/tenant/contract_payment_status_dialog.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:uuid/uuid.dart';

import '../components/customs/custom_button.dart';
import '../components/customs/custom_date_picker.dart';
import '../components/customs/custom_text_form_field.dart';
import '../components/customs/loader.dart';
import '../components/forms/tenants_master_form.dart';
import '../components/funtions.dart';
import '../components/json/tenants_sra_json.dart';
import '../config/config.dart';
import '../config/helper/offline_data.dart';
import '../routes/route_generator.dart';
import '../routes/route_name.dart';
import '../style/theme_const.dart';
import '../utils/aws_service/file_data_model.dart';
import '../view/tenant/full_tenant_history_dialog.dart';
import '../view/tenant/sap_dialog.dart';

class TenantMasterController extends GetxController {
  RxString pageName = ''.obs;
  RxString formName = ''.obs;
  RxString message = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  List<String> disableFiledList = [];
  RxMap dialogBoxData = {}.obs;

  // Map validator = {};
  RxInt statusCode = 0.obs;
  RxInt selectedTab = 0.obs;
  RxDouble boxWidth = 0.0.obs;
  RxBool loadingData = true.obs;
  RxBool sapDataLoading = true.obs;
  RxBool loadingPaginationData = true.obs;
  RxBool formLoadingData = false.obs;
  RxBool updateObj = false.obs;
  final formKey0 = GlobalKey<FormState>();
  int cursorPos = 10000000;
  RxBool validateForm = false.obs;
  RxBool enterInOffline = false.obs;
  Rx<FilesDataModel> selectedFile = FilesDataModel().obs;
  Map<int, FocusNode> focusNodes = {};
  Map<int, GlobalKey<FormFieldState>> formKeys = {};
  RxMap validator = {}.obs;
  RxMap<String, dynamic> kanbanData = <String, dynamic>{}.obs;
  Map initialStateData = {"addButtonDisable": false, "lastEditedDataIndex": -1, "uploadingFiles": [], "masterUploadingFiles": []};
  List screenView = [
    AssetsString.kTable,
    AssetsString.kKanBan,
  ];
  RxInt selectedView = 0.obs;

  // RxInt selectedView = (kDebugMode ? 1 : 0).obs;
  RxInt uploadDocCount = 0.obs;
  bool autoFillFirstData = false;
  Map<String, ScrollController> kanbanCardScrollController = {};
  RxBool kanbanDataLoading = true.obs;
  RxBool formButtonLoading = false.obs;
  TextEditingController searchController = TextEditingController();

  String searchText = '';
  RxInt currentExpandedIndex = (0).obs;
  AutoScrollController tabScrollController = AutoScrollController();
  ScrollController tableScrollController = ScrollController();
  ScrollController formScrollController = ScrollController();
  RxBool isAddButtonVisible = false.obs;
  RxBool isSapContractHistoryLoading = true.obs;
  RxList sapHistoryList = [].obs;
  RxList<Map<String, dynamic>> sapContractHistoryList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> sapContractHistoryFieldOrderList = <Map<String, dynamic>>[].obs;
  RxBool isSapSelection = false.obs;
  RxBool selectAll = false.obs;
  RxInt selectedCount = 0.obs;
  Map<String, dynamic> fieldSetting = {};
  List<String> approverTenantProject = [];

  @override
  Future<void> onInit() async {
    setDefaultData.pageLimit = 5;

    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        tableScrollController.addListener(() async {
          if (tableScrollController.position.pixels >= tableScrollController.position.maxScrollExtent - 100) {
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
        });
      }
    }
    selectedTab.listen(
      (p0) {
        validateForm.value = false;
        tabScrollController.scrollToIndex(
          p0,
          preferPosition: AutoScrollPosition.middle,
        );
      },
    );
    pageName.value = getCurrentPageName();
    if (pageName.value == "offlinetenant") {
      pageName.value = "tenant";
    }
    isAddButtonVisible.value = IISMethods().hasAddRight(alias: pageName.value);
    devPrint(pageName.value);
    dialogBoxData.value = TenantsSRAJson.designationFormFields(pageName.value);
    formName.value = dialogBoxData['formname'];
    formName.refresh();
    setPageTitle('${formName.value} | PRENEW', Get.context!);
    if (!isoffline.value) await getTenantProject();
    await getList();
    if (!isoffline.value) await setFilterData();
    if (!isoffline.value) getStatusList();
    super.onInit();
  }

  @override
  void dispose() {
    // Get.delete<TenantMasterController>();
    super.dispose();
  }

  Future<void> setKanBanData() async {
    kanbanDataLoading.value = true;
    kanbanData.clear();
    kanbanData.value = await getKanbanData();
    kanbanDataLoading.value = false;
    kanbanData.refresh();
  }

  Future<void> getKanbanGroupPaginationData(String groupId) async {
    if (kanbanData[groupId]['nextpage'] == 0 || kanbanData[groupId]['isLoading'] == true) {
      return;
    }
    kanbanData[groupId]['isLoading'] = true;
    kanbanData.refresh();
    Map<String, dynamic> body = {
      "paginationinfo": {
        "pageno": kanbanData[groupId]['currentpage'] + 1,
        "pagelimit": 5,
        "filter": {
          'tenantstatusid': groupId,
        },
        "sort": {}
      }
    };
    var response = await IISMethods().listData(userAction: 'listtenant', pageName: 'tenant', url: Config.weburl + pageName.value, reqBody: body, masterlisting: true);
    if (response["status"] == 200) {
      kanbanData[groupId]['currentpage'] = response['currentpage'];
      kanbanData[groupId]['nextpage'] = response['nextpage'];
      (kanbanData[groupId]['data'] as List).addAll(response['data']);
      kanbanData[groupId]['isLoading'] = false;
      kanbanData.refresh();
    }
  }

  // Future<void> getDocumentHistory({
  //   required String tenantId,
  //   required String documentType,
  //   String? pagename,
  // }) async {
  //   FormDataModel setDefaultData1 = FormDataModel();
  //   setDefaultData1.fieldOrder = [
  //     {
  //       "field": "uploaddate",
  //       "text": "Uploaded Date",
  //       "type": "text",
  //       "freeze": 1,
  //       "active": 1,
  //       // "sorttable": 1,
  //       "filter": 1,
  //       "filterfieldtype": "input-text",
  //       "defaultvalue": "",
  //       "tblsize": 18,
  //     },
  //     {
  //       "field": "uploadby",
  //       "text": "Uploaded By",
  //       "type": "text",
  //       "freeze": 1,
  //       "active": 1,
  //       // "sorttable": 1,
  //       "filter": 1,
  //       "filterfieldtype": "input-text",
  //       "defaultvalue": "",
  //       "tblsize": 18,
  //     },
  //     {
  //       "field": "name",
  //       "text": "File Name",
  //       "type": "text",
  //       "freeze": 1,
  //       "active": 1,
  //       // "sorttable": 1,
  //       "filter": 1,
  //       "filterfieldtype": "input-text",
  //       "defaultvalue": "",
  //       "tblsize": 18,
  //     },
  //     // {
  //     //   "field": "extension",
  //     //   "text": "Type",
  //     //   "type": "text",
  //     //   "freeze": 1,
  //     //   "active": 1,
  //     //   // "sorttable": 1,
  //     //   "filter": 1,
  //     //   "filterfieldtype": "input-text",
  //     //   "defaultvalue": "",
  //     //   "tblsize": 10,
  //     // },
  //     {
  //       "field": "eye",
  //       "text": "Document",
  //       "type": "eye",
  //       "freeze": 1,
  //       "active": 1,
  //       // "sorttable": 1,
  //       "filter": 1,
  //       "filterfieldtype": "input-text",
  //       "defaultvalue": "",
  //       "tblsize": 10,
  //     },
  //   ].obs;
  //   Map<String, dynamic> body = {
  //     "paginationinfo": {
  //       "pageno": 1,
  //       "pagelimit": 999999999999999,
  //       "filter": {
  //         'tbldocumentid': tenantId,
  //         'documenttype': documentType,
  //         'pagename': pagename ?? formName.value,
  //       },
  //       "sort": {}
  //     }
  //   };
  //   var response =
  //       await IISMethods().listData(userAction: 'documenthistory', pageName: 'documenthistory', url: "${Config.weburl}documenthistory", reqBody: body, masterlisting: true);
  //   if (response["status"] == 200) {
  //     CommonDataTableWidget.showDocumentHistory(setDefaultData1, List<Map<String, dynamic>>.from(response['data']), documentType, () async {
  //       Get.dialog(
  //         barrierDismissible: false,
  //         ResponsiveBuilder(builder: (context, sizingInformation) {
  //           return Dialog(
  //             shadowColor: ColorTheme.kBlack,
  //             backgroundColor: ColorTheme.kWhite,
  //             surfaceTintColor: ColorTheme.kWhite,
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //             insetPadding: sizingInformation.isMobile ? EdgeInsets.zero : const EdgeInsets.all(12),
  //             alignment: Alignment.topCenter,
  //             child: SizedBox(
  //               width: 600,
  //               height: 400,
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         const TextWidget(
  //                           text: 'Add New Document',
  //                           fontSize: 16,
  //                           fontWeight: FontTheme.notoSemiBold,
  //                           color: ColorTheme.kPrimaryColor,
  //                         ),
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             color: ColorTheme.kBlack.withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(5),
  //                           ),
  //                           child: IconButton(
  //                             onPressed: () {
  //                               Get.back();
  //                             },
  //                             splashColor: ColorTheme.kWhite,
  //                             hoverColor: ColorTheme.kWhite.withOpacity(0.1),
  //                             splashRadius: 20,
  //                             constraints: const BoxConstraints(),
  //                             padding: EdgeInsets.zero,
  //                             icon: const Icon(Icons.close),
  //                           ).paddingAll(2),
  //                         )
  //                       ],
  //                     ),
  //                   ),
  //                   const Divider(),
  //                   Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: CustomFileDragArea(
  //                       fileTypes: FileTypes.pdfAndImage,
  //                       disableMultipleFiles: true,
  //                       child: DottedBorder(
  //                         borderType: BorderType.Rect,
  //                         color: ColorTheme.kBorderColor,
  //                         dashPattern: const [8, 8, 1, 1],
  //                         child: Container(
  //                           height: 200,
  //                           width: 550,
  //                           color: ColorTheme.kWhite,
  //                           child: Center(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Expanded(
  //                                   child: Column(
  //                                     mainAxisAlignment: MainAxisAlignment.center,
  //                                     children: [
  //                                       Obx(() {
  //                                         return Visibility(
  //                                           visible: selectedFile.value.bytes != null,
  //                                           replacement: const Icon(
  //                                             size: 40,
  //                                             Icons.upload_file_outlined,
  //                                             color: ColorTheme.kPrimaryColor,
  //                                           ),
  //                                           child: const Icon(
  //                                             size: 40,
  //                                             Icons.description_outlined,
  //                                             color: ColorTheme.kPrimaryColor,
  //                                           ),
  //                                         );
  //                                       }),
  //                                       Obx(() {
  //                                         return TextWidget(
  //                                           text: selectedFile.value.bytes == null ? 'Please Select or Drop File Here' : selectedFile.value.name ?? '',
  //                                           fontSize: 16,
  //                                           color: ColorTheme.kPrimaryColor,
  //                                           fontWeight: FontTheme.notoSemiBold,
  //                                         );
  //                                       }),
  //                                       Obx(() {
  //                                         return Visibility(
  //                                           visible: selectedFile.value.bytes == null,
  //                                           child: const TextWidget(
  //                                             text: "(Only PDF, JPG, JPEG, PNG] file supported)",
  //                                             fontSize: 12,
  //                                             color: ColorTheme.kPrimaryColor,
  //                                             fontWeight: FontTheme.notoSemiBold,
  //                                           ),
  //                                         );
  //                                       }),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       onFilePicked: (files) async {
  //                         files = await IISMethods().uploadFiles(files);
  //                       },
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   CustomButton(
  //                     onTap: () async {
  //                       // await handleFormData(
  //                       //   key: res["field"],
  //                       //   value: fileModelList,
  //                       //   type: res["type"],
  //                       // );
  //                     },
  //                     fontSize: 13,
  //                     borderRadius: 4,
  //                     height: 40,
  //                     title: 'Upload',
  //                   ).paddingSymmetric(horizontal: 22)
  //                 ],
  //               ),
  //             ),
  //           );
  //         }),
  //       );
  //       // List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: FileTypes.pdfAndImage);
  //       // await handleFormData(
  //       //   key: res["field"],
  //       //   value: fileModelList,
  //       //   type: res["type"],
  //       // );
  //     });
  //   }
  // }

  Future<Map<String, dynamic>> getKanbanData() async {
    setDefaultData.filterData.removeNullValues();
    Map<String, dynamic> body = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 5,
        "filter": {
          "columns": [
            'private_survey',
            'government_survey',
            'draft_annexure',
            'final_annexure',
            'supplementary_annexure',
            'inspection',
            'rent_payment',
            'key_handover',
            'evacuation',
            'demolition',
            'unit_handover',
          ],
          ...setDefaultData.filterData,
        },
        "sort": {}
      },
      'searchtext': searchText,
    };
    var response = await IISMethods().listData(userAction: 'listtenant', pageName: 'tenant', url: '${Config.weburl}tenantkanban', reqBody: body);
    if (response["status"] == 200) {
      return Map<String, dynamic>.from(response['alldata']);
    }
    return {};
  }

  getTenantProject() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 500000000000,
        "filter": {'status': 1},
        "projection": {},
        "sort": {}
      }
    };
    var tenantproject = ((await IISMethods().listData(userAction: 'listtenantproject', pageName: 'tenant', url: '${Config.weburl}tenantproject', reqBody: reqBody))?['data'] as List?);
    if (tenantproject.isNotNullOrEmpty) {
      setDefaultData.filterData['tenantprojectid'] = tenantproject?.first['_id'];
    }
  }

  Future<void> getList([bool appendData = false]) async {
    if (!appendData) {
      setDefaultData.data.value = [];
      loadingData.value = true;
    } else {
      loadingPaginationData.value = true;
    }
    selectAll.value = false;
    selectedCount.value = 0;
    setDefaultData.filterData.removeNullValues();
    final url = Config.weburl + pageName.value;
    final userAction = "list$pageName";
    var filter = {};
    setDefaultData.filterData.removeNullValues();
    for (var entry in setDefaultData.filterData.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.toString().isNotNullOrEmpty) {
        filter[key] = value;
      }
    }
    filter.remove('searchtext');
    final reqBody = {
      'searchtext': searchText,
      'paginationinfo': {
        'pageno': setDefaultData.pageNo.value,
        'pagelimit': setDefaultData.pageLimit,
        'filter': filter,
        'sort': setDefaultData.sortData,
      },
    };
    jsonPrint(reqBody);
    var resBody = {};
    if (isoffline.value) {
      resBody = Settings.offlineFieldDataList;
      resBody['data'] = Settings.offlineTenantDataList;
    } else {
      resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);
    }

    statusCode.value = resBody["status"] ?? 0;

    if (resBody["status"] == 200) {
      if (!appendData) {
        setDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data'] ?? []);
      } else {
        setDefaultData.data.addAll(List<Map<String, dynamic>>.from(resBody['data']));
      }
      setDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"]);
      fieldSetting = Map<String, dynamic>.from(resBody['defaultsettings'] ?? {});
      devPrint(fieldSetting);
      disableFiledList = List<String>.from(resBody['disablefiledlist']);
      setDefaultData.nextPage = resBody['nextpage'];
      setDefaultData.pageName = resBody['pagename'];
      setDefaultData.contentLength = resBody['totaldocs'] ?? 0;
      setDefaultData.noOfPages.value = (setDefaultData.contentLength / setDefaultData.pageLimit).ceil();
      approverTenantProject = List<String>.from(resBody['approvertenantprojectlist'] ?? []);

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

  handleGridChange({required int index, required String field, required String type, dynamic value}) async {
    switch (type) {
      case HtmlControls.kStatus:
      case HtmlControls.kSwitch:
        setDefaultData.data[index][field] = value ? 1 : 0;
        break;
      case HtmlControls.kTenantStatus:
        var stage = setDefaultData.masterDataList['tenantstatus'].firstWhere((element) {
          return element['_id'].toString() == value.toString();
        });
        setDefaultData.data[index][field] = value;
        setDefaultData.data[index]["tenantstatus"] = stage['status'];
    }
    await updateData(reqData: setDefaultData.data[index], editeDataIndex: index);
  }

  handleKanbanGridChange({required int index, required String field, required bool isMobile, required String type, dynamic value, dynamic data}) async {
    switch (type) {
      case HtmlControls.kStatus:
      case HtmlControls.kSwitch:
        if (isMobile) {
          setDefaultData.data[index][field] = value ? 1 : 0;
        } else {
          devPrint("98645286456645319645 --->" + data['tenantfirstname']);
          data[field] = value ? 1 : 0;
        }
        break;
      case HtmlControls.kTenantStatus:
        var stage = setDefaultData.masterDataList['tenantstatus'].firstWhere((element) {
          return element['_id'].toString() == value.toString();
        });
        if (isMobile) {
          setDefaultData.data[index][field] = value;
          setDefaultData.data[index]["tenantstatus"] = stage['status'];
        } else {
          data[field] = value;
          data["tenantstatus"] = stage['status'];
          devPrint("98645286456645319645 --->" + data['tenantstatus']);
        }
    }
    if (isMobile) {
      await updateData(reqData: setDefaultData.data[index], editeDataIndex: index);
    } else {
      await updateData(reqData: data);
    }
  }

  Future<void> getStatusList() async {
    final url = "${Config.weburl}tenantstatus";
    const userAction = "listtenantstatus";
    final reqBody = {
      'searchtext': '',
      'paginationinfo': {
        'pageno': 1,
        'pagelimit': 999999999999,
        'filter': {},
        'sort': {},
      },
    };
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;

    if (resBody["status"] == 200) {
      setDefaultData.masterDataList["tenantstatus"] = resBody["data"];
    }

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
      devPrint('API--->${fieldObj['field']}');
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
        var resBody = {};

        if (isoffline.value) {
          int status = 200;
          if ((fieldObj['masterdatadependancy'] ?? false)) {
            status = (Settings.offlineDropdownDataList[fieldObj["field"]][filter[fieldObj['dependentfilter'].keys.first]] ?? []).length > 0 ? 200 : 401;
          } else {
            status = (Settings.offlineDropdownDataList[fieldObj["field"]] ?? []).length > 0 ? 200 : 401;
          }
          List data = [];

          data = (fieldObj['masterdatadependancy'] ?? false) ? (Settings.offlineDropdownDataList[fieldObj["field"]][filter[fieldObj['dependentfilter'].keys.first]] ?? []) : (Settings.offlineDropdownDataList[fieldObj["field"]] ?? []);

          resBody = {
            "data": data,
            "status": status,
            "nextpage": 0,
          };
        } else {
          resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value, masterlisting: true);
        }
        if (resBody["status"] == 200) {
          if ((fieldObj["type"] == HtmlControls.kInputText || fieldObj["type"] == HtmlControls.kNumberInput || fieldObj["type"] == HtmlControls.kInputTextArea)) {
            if (setDefaultData.formData['_id'].toString().isNullOrEmpty) {
              resBody as Map<String, dynamic>;
              String key = resBody.keys.firstWhere((element) => element != 'status');
              setDefaultData.masterData[masterDataKey] = resBody[key];
            }
          } else {
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

  Future setFormData({String? id, int? editeDataIndex, bool? clone, bool? isOfflineData}) async {
    validateForm.value = false;
    enterInOffline.value = isOfflineData ?? isoffline.value;
    selectedTab.value = 0;
    formLoadingData.value = true;
    devPrint(dialogBoxData);
    dialogBoxData['tabs'][2]['defaultvisibility'] = false;
    initialStateData['lastEditedDataIndex'] = editeDataIndex;
    setDefaultData.formData.value = {};
    updateObj.value = false;
    var tempFormData = {};
    if (id != null) {
      tempFormData = await IISMethods().getObjectFromArray(enterInOffline.value ? Settings.offlineTenantDataList : setDefaultData.data, '_id', id);
      updateObj.value = true;
    } else {
      for (var tabs in dialogBoxData['tabs']) {
        for (var data in tabs["formfields"]) {
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
              case HtmlControls.kMultipleImagePicker:
                tempFormData[fields["field"]] = [];
                break;
              case HtmlControls.kMultipleContactSelection:
                tempFormData[fields["field"]] = [''];
                break;
              case HtmlControls.kMultipleTextFieldWithTitle:
                tempFormData[fields["field"]] = [];
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
    }

    setDefaultData.formData.value = Map<String, dynamic>.from(tempFormData);
    if (id.isNullOrEmpty) {
      handleFormData(value: setDefaultData.filterData['tenantprojectid'], type: HtmlControls.kDropDown, key: 'tenantprojectid');
    }

    if (enterInOffline.value) {
      dialogBoxData['tabs'][2]['defaultvisibility'] = true;
    } else if (setDefaultData.formData['hascoapplicant'] != null && (setDefaultData.formData['hascoapplicant']) == 1) {
      dialogBoxData['tabs'][2]['defaultvisibility'] = true;
    }

    ///comment temp
    getMasterDataForTab();
    // for (var tabs in dialogBoxData['tabs']) {
    //   for (var data in tabs["formfields"]) {
    //     for (var fields in data["formFields"]) {
    //       if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
    //         var isTrue = fields.containsKey("masterdatadependancy");
    //         if (isTrue) {
    //           isTrue = fields["masterdatadependancy"];
    //         }
    //         if (isTrue || !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) || fields["isselfrefernce"] == null || fields["setvaluefromlogininfo"] == null) {
    //           await getMasterData(pageNo: 1, fieldObj: fields, formData: setDefaultData.formData);
    //           var masterDataKey = fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"];
    //           if (setDefaultData.masterData[masterDataKey] != null && setDefaultData.masterData[masterDataKey].isNotEmpty) {
    //             await handleFormData(
    //               key: fields["field"],
    //               value: setDefaultData.masterData[masterDataKey]?.first['value'],
    //               type: fields['type'],
    //               onChangeFill: false,
    //             );
    //           }
    //         }
    //       } else if (fields["masterdata"] != null && fields.containsKey("masterdataarray") && !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"])) {
    //         var array = [];
    //         for (var object in fields["masterdataarray"]) {
    //           if (object is Map<String, dynamic>) {
    //             array.add(object);
    //           } else {
    //             array.add({"label": object, "value": object});
    //           }
    //         }
    //         setDefaultData.masterData[fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]] = array;
    //       }
    //     }
    //   }
    // }
    formLoadingData.value = false;
    update();
  }

  getMasterDataForTab() async {
    if ((getDeviceType(MediaQuery.sizeOf(Get.context!)) == DeviceScreenType.mobile || getDeviceType(MediaQuery.sizeOf(Get.context!)) == DeviceScreenType.tablet) &&
        selectedTab.value == 4 &&
        setDefaultData.formData['SAP_vendorcode'].toString().isNullOrEmpty) {
      Get.snackbar(
        'Note:',
        'The payment contract will only be generated once the vendor has been created in SAP.',
        duration: const Duration(seconds: 5),
        backgroundColor: ColorTheme.kWhite,
        snackPosition: SnackPosition.BOTTOM,
        boxShadows: [
          BoxShadow(
            color: ColorTheme.kBlack.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.all(8),
      );
    }
    var tab = dialogBoxData['tabs'][selectedTab.value];
    if (tab['type'] == HtmlControls.kFieldGroupList) {
      List<Map<String, dynamic>> valueList = List<Map<String, dynamic>>.from(List.from(setDefaultData.formData[tab['field']] ?? []).isNullOrEmpty ? [<String, dynamic>{}] : setDefaultData.formData[tab['field']]);
      setDefaultData.formData[tab['field']] = valueList;
    }

    for (var data in tab["formfields"]) {
      for (var fields in data["formFields"]) {
        if (fields["masterdata"] != null && !fields.containsKey("masterdataarray")) {
          var isTrue = fields.containsKey("masterdatadependancy");
          if (isTrue) {
            isTrue = fields["masterdatadependancy"];
          }
          if (isTrue || !setDefaultData.masterData.containsKey(fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]) || fields["isselfrefernce"] == null || fields["setvaluefromlogininfo"] == null) {
            await getMasterData(pageNo: 1, fieldObj: fields, formData: setDefaultData.formData);
            var masterDataKey = fields["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"];
            if (fields["type"] == HtmlControls.kInputText || fields["type"] == HtmlControls.kNumberInput || fields["type"] == HtmlControls.kInputTextArea) {
              if (setDefaultData.masterData[masterDataKey].toString().isNotNullOrEmpty) {
                await handleFormData(
                  key: fields["field"],
                  value: setDefaultData.masterData[masterDataKey],
                  type: fields['type'],
                  onChangeFill: false,
                );
              }
            } else if (setDefaultData.masterData[masterDataKey] != null && setDefaultData.masterData[masterDataKey].isNotEmpty && autoFillFirstData) {
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

        if (setDefaultData.formData[fields['field']].toString().isNullOrEmpty && (fields['field'] == "commonconsentid" || fields['field'] == "individualconsentid" || fields['field'] == "individualagreementid")) {
          handleFormData(value: setDefaultData.masterData[fields?["storemasterdatabyfield"] == true ? fields["field"] : fields["masterdata"]].first['value'], type: fields['type'], key: fields['field']);
        }
      }
    }
    if (selectedTab.value == 3) {
      final reqBody = {
        'searchtext': '',
        'paginationinfo': {
          'pageno': 1,
          'pagelimit': 10,
          'filter': {
            'tenantprojectid': setDefaultData.formData['tenantprojectid'] ?? '',
            'societyid': setDefaultData.formData['societyid'] ?? '',
            'tenantid': setDefaultData.formData['_id'] ?? '',
          },
          'sort': {},
        },
      };
      if (isoffline.value) {
        if (setDefaultData.formData["societyid"].toString().isNotNullOrEmpty && setDefaultData.formData["tenantprojectid"].toString().isNotNullOrEmpty) {
          List temp = Settings.offlineDropdownDataList["societyid"]?[setDefaultData.formData["tenantprojectid"]] ?? [];
          var societyIndex = temp.indexWhere(
            (element) => element['_id'] == setDefaultData.formData["societyid"],
          );
          if (societyIndex > -1) {
            setDefaultData.formData['commonconsent'] = temp[societyIndex]["commonconsent"] ?? [];
            setDefaultData.formData['generalbodyresolution'] = temp[societyIndex]["generalbodyresolution"] ?? [];
          }
        }
      } else {
        var response = await IISMethods().listData(userAction: 'listconsentdocument', pageName: 'tenant', url: '${Config.weburl}consentdocument', reqBody: reqBody);
        if (response['status'] == 200) {
          setDefaultData.formData['commonconsent'] = response["data"];
        }
        response = await IISMethods().listData(userAction: 'listconsentdocument', pageName: 'tenant', url: '${Config.weburl}gbrdocument', reqBody: reqBody);
        if (response['status'] == 200) {
          setDefaultData.formData['generalbodyresolution'] = response["data"];
        }
      }
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
    int? docIndex,
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
      case HtmlControls.kDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["tabs"], key);
        var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
        if (fieldObj["masterdataarray"] != null) {
          setDefaultData.formData[key] = value ?? '';
        } else {
          setDefaultData.formData[fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
          setDefaultData.formData[key] = res?["_id"];
        }
        if (value == 1) {
          if (key == 'attendedcommonconsent' && ((setDefaultData.formData['commonconsent'] ?? []) as List).isNullOrEmpty) {
            showError('No Common Consent is Added to ${setDefaultData.formData['tenantprojectname'] ?? 'Tenant Project'}');
          }
          if (key == 'attendedgeneralbodyresolution' && ((setDefaultData.formData['generalbodyresolution'] ?? []) as List).isNullOrEmpty) {
            showError('No General Body Resolution is Added to ${setDefaultData.formData['tenantprojectname'] ?? 'Tenant Project'}');
          }
        }

        if (key == 'tenantprojectid') {
          setDefaultData.formData['rentdetails'] ??= <Map<String, dynamic>>[{}];
          // setDefaultData.formData['rentdetails'][0]['noofmonths'] = res['rentnomonth'];
          // handleRentCalculation(0);
          setDefaultData.formData['rentnomonth'] = res?['rentnomonth'] ?? '';

          final reqBody = {
            'searchtext': '',
            'paginationinfo': {
              'pageno': 1,
              'pagelimit': 0,
              'filter': {
                'tenantprojectid': setDefaultData.formData['tenantprojectid'],
              },
              'sort': {},
            },
          };
          if (!isoffline.value) {
            var response = await IISMethods().listData(userAction: 'listvendorcode', pageName: 'tenant', url: '${Config.weburl}vendorcode', reqBody: reqBody);
            if (response['status'] == 200) {
              setDefaultData.formData['vendorcode'] = response["data"]['vendorcode'] ?? "";
              setDefaultData.formData['codeid'] = response["data"]['codeid'] ?? "";
            }
          } else {
            setDefaultData.formData['vendorcode'] = "";
            setDefaultData.formData['codeid'] = "";
          }
        }
        break;
      case HtmlControls.kRadio:
      case HtmlControls.kCheckBox:
        if (key == "tenantisexpire") {
          devPrint("564687467671--->\n");

          Get.back();
          int index = setDefaultData.data.indexWhere((element) => element['_id'] == setDefaultData.formData['_id']);
          handleTenantExpired(id: setDefaultData.formData['_id'], index: index);
          return;
        }
        setDefaultData.formData[key] = value ? 1 : 0;

      case HtmlControls.kMultiSelectDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["tabs"], key);
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
                "${fieldObj["formdatafield"]}": res[fieldObj["masterdatafield"]],
              });
            }
          }
        } catch (e) {
          setDefaultData.formData[key] = [];
        }
        break;
      case HtmlControls.kMultipleFilePickerFieldWithTitle:
        {
          try {
            List data = value ?? setDefaultData.formData[key] ?? [];
            if (docIndex is int) {
              var currData = value[docIndex];
              Map obj = {};
              if ((currData['isdoc'] ?? false) && currData['doc'] != null) {
                List<FilesDataModel> doc = List<FilesDataModel>.from(await IISMethods().uploadFiles(List<FilesDataModel>.from(currData['doc'])));
                obj = {"doc": doc.first.toJson(), "name": currData['name']};
              } else {
                obj = currData;
              }
              if ((docIndex) < data.length) {
                data[docIndex] = obj;
              } else if (currData.isNotEmpty) {
                data.add(obj);
              }
            }
            setDefaultData.formData[key] = data;
          } catch (e1) {
            devPrint(e1.toString());
            devPrint(e1.toString());
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
            Map? oldData = IISMethods().encryptDecryptObj((setDefaultData.formData[key] ?? {})['url'].toString().isNotNullOrEmpty ? setDefaultData.formData[key] : null);
            setDefaultData.formData[key] = value.first.toJson();
            if (oldData?['old'] == null) {
              setDefaultData.formData[key]['old'] = IISMethods().encryptDecryptObj(oldData);
            } else {
              setDefaultData.formData[key]['old'] = IISMethods().encryptDecryptObj(oldData?['old']);
            }
            if (key == 'tenantcanceledcheque' && !isoffline.value) {
              AppLoader();
              var response = await IISMethods().listData(userAction: 'addtenant', pageName: 'tenant', url: '${Config.weburl}readcheque', reqBody: value.first.toJson());
              if (response['status'] == 200) {
                showSuccess(response['message'] ?? '');
              } else {
                if (!enterInOffline.value) {
                  showError(response['message'] ?? '');
                }
              }
              setDefaultData.formData.addAll(Map<String, dynamic>.from(response['data'] ?? {}));
              RemoveAppLoader();
            }
          }
        }
        break;
      case HtmlControls.kMultipleImagePicker:
        {
          if (setDefaultData.formData[key] == null) {
            setDefaultData.formData[key] = [];
          }
          value as List<FilesDataModel>;
          setDefaultData.formData[key] as List;
          setDefaultData.formData[key].addAll(value.map((element) {
            return element.toJson();
          }).toList());
          setDefaultData.formData.refresh();
          value = List<FilesDataModel>.from(
            await IISMethods().uploadFiles(
              List<FilesDataModel>.from(setDefaultData.formData[key].map((element) {
                return FilesDataModel.fromJson(element);
              }).toList()),
            ),
          );
          if (value.isNotEmpty) {
            setDefaultData.formData[key] = value.map((element) {
              return element.toJson();
            }).toList();
          }
        }
        break;
      default:
        setDefaultData.formData[key] = value;
    }

    var obj = getObjectFromFormData(dialogBoxData["tabs"], key);

    if (obj["onchangefill"] != null && onChangeFill) {
      for (var field in obj["onchangefill"]) {
        var obj2 = getObjectFromFormData(dialogBoxData["tabs"], field);
        if (obj2["type"] == HtmlControls.kDropDown) {
          await handleFormData(type: obj2['type'], key: obj2["field"], value: '');
        } else if (obj2["type"] == HtmlControls.kMultiSelectDropDown) {
          setDefaultData.formData[field] = [];
        }
        await getMasterData(pageNo: 1, fieldObj: obj2, formData: setDefaultData.formData);
        var masterDataKey = obj2["storemasterdatabyfield"] == true ? obj2["field"] : obj2["masterdata"];
        if (setDefaultData.masterData[masterDataKey]?.length >= 1 && autoFillFirstData) {
          await handleFormData(
            key: obj2["field"],
            value: setDefaultData.masterData[masterDataKey]?.first['value'],
            type: obj2['type'],
          );
        }
      }
    }
    setDefaultData.formData.refresh();
    devPrint(jsonEncode(setDefaultData.formData));
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
        var fieldObj = getObjectFromFormData(dialogBoxData["tabs"], key);
        var res = await IISMethods().getObjectFromArray(setDefaultData.masterDataList[fieldObj["storemasterdatabyfield"] == true ? fieldObj["field"] : fieldObj["masterdata"]], "_id", value);
        setDefaultData.formData[groupKey][index][fieldObj["formdatafield"]] = res?[fieldObj["masterdatafield"]];
        setDefaultData.formData[groupKey][index][key] = res?["_id"];

        if (key == 'paymenttypeid') {
          setDefaultData.formData[groupKey][index]['noofmonths'] = setDefaultData.formData['rentnomonth'] ?? "";
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
          if (key == 'canceledcheque' && !isoffline.value) {
            AppLoader();
            var response = await IISMethods().listData(userAction: 'addtenant', pageName: 'tenant', url: '${Config.weburl}readcheque', reqBody: value.first.toJson());
            if (response['status'] == 200) {
              showSuccess(response['message'] ?? '');
            } else {
              if (!enterInOffline.value) {
                showError(response['message'] ?? '');
              }
            }
            Map<String, dynamic>.from(response['data'] ?? {}).forEach(
              (key, value) {
                setDefaultData.formData[groupKey][index][key.replaceAll('tenant', '')] = value;
              },
            );

            RemoveAppLoader();
          }
        }
        break;
      case HtmlControls.kMultiSelectDropDown:
        var fieldObj = getObjectFromFormData(dialogBoxData["tabs"], key);
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
        // value--;
        devPrint("15454867486465   " + value);
        setDefaultData.formData[groupKey][index][key] = value;
    }

    var obj = getObjectFromFormData(dialogBoxData["tabs"], key);

    if (obj["onchangefill"] != null && onChangeFill) {
      for (var field in obj["onchangefill"]) {
        var obj2 = getObjectFromFormData(dialogBoxData["tabs"], field);
        if (obj2["type"] == HtmlControls.kDropDown) {
          await handleFormData(type: obj2['type'], key: obj2["field"], value: '');
        } else if (obj2["type"] == HtmlControls.kMultiSelectDropDown) {
          setDefaultData.formData[field] = [];
        }
        await getMasterData(pageNo: 1, fieldObj: obj2, formData: setDefaultData.formData);
        var masterDataKey = obj2["storemasterdatabyfield"] == true ? obj2["field"] : obj2["masterdata"];
        if (setDefaultData.masterData[masterDataKey]?.length >= 1 && autoFillFirstData) {
          await handleFormData(
            key: obj2["field"],
            value: setDefaultData.masterData[masterDataKey]?.first['value'],
            type: obj2['type'],
          );
        }
      }
    }

    if (groupKey == 'rentdetails') {
      handleRentCalculation(index);
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

  handleRentCalculation(index) {
    if (setDefaultData.formData['rentdetails'][index]['paymenttypefrequency'] == 2) {
      double rentInMonths = setDefaultData.formData['rentdetails'][index]['rentinmonth'].toString().converttoDouble;
      double noOfMonths = setDefaultData.formData['rentdetails'][index]['noofmonths'].toString().converttoDouble;
      if (setDefaultData.formData['rentdetails'][index]['startdate'].toString().isNotNullOrEmpty) {
        DateTime startDate = DateTime.parse(setDefaultData.formData['rentdetails'][index]['startdate'].toString());

        setDefaultData.formData['rentdetails'][index]['enddate'] = dateConvertIntoUTC(DateTime(startDate.year, startDate.month + int.parse(setDefaultData.formData['rentdetails'][index]['noofmonths'].toString()), startDate.day).subtract(Duration(days: 1)));
      }
      setDefaultData.formData['rentdetails'][index]['totalrent'] = (rentInMonths * noOfMonths).toStringAsFixed(2).converttoDouble;
      setDefaultData.formData['rentdetails'][index]['totalpayable'] = (setDefaultData.formData['rentdetails'][index]['totalrent'].toString().converttoDouble).toStringAsFixed(2).converttoDouble;
    }
  }

  handleAddButtonClick() {
    FocusManager.instance.primaryFocus?.unfocus();
    Map data = IISMethods().encryptDecryptObj(setDefaultData.formData);
    addData(reqData: data);
  }

  Future<dynamic> addOfflineData({reqData}) async {
    List temp = [];
    temp.addAll(Settings.offlineTenantDataList);
    if (reqData.containsKey('_id') && temp.indexWhere((x) => x['_id'] == reqData['_id']) > -1) {
      int index = temp.indexWhere((x) => x['_id'] == reqData['_id']);
      temp.removeAt(index);
      temp.insert(index, reqData);
    } else {
      if (!reqData.containsKey('_id')) {
        var uuid = const Uuid();
        reqData['_id'] = uuid.v4();
        reqData['isnew'] = 1;
      }
      temp.add(reqData);
      getList();
    }

    Settings.offlineTenantDataList = temp;
    return {"status": 200, "message": reqData['isnew'] == 1 ? "Tenant inserted successfully." : "Tenant updated successfully.", "data": reqData};
  }

  //call add data request
  Future addData({
    reqData,
  }) async {
    var url = '${Config.weburl}${pageName.value}/add';

    var userAction = "add$pageName";
    formButtonLoading.value = true;
    var resBody = {};
    if (enterInOffline.value) {
      resBody = await addOfflineData(reqData: reqData);
    } else {
      resBody = await IISMethods().addData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName.value);
    }
    formButtonLoading.value = false;

    statusCode.value = resBody["status"] ?? 0;
    if (statusCode.value == 200) {
      try {
        message.value = resBody["message"];
        setDefaultData.pageNo = 1.obs;

        ///Don't Remove This Code
        // if (!(reqData as Map<String, dynamic>).containsKey('_id')) {
        //   setDefaultData.data.insert(0, resBody['data']);
        //   setDefaultData.data.removeLast();
        //   initialStateData["lastEditedDataIndex"] = 0;
        //   setDefaultData.pageLimit++;
        // } else {
        //   setDefaultData.data[initialStateData["lastEditedDataIndex"]].addAll(resBody['data']);
        // }
        getList();
        if (resBody.containsKey('data')) {
          setDefaultData.formData.addAll(resBody['data']);
          devPrint(setDefaultData.formData);
        }
        if (selectedTab.value != dialogBoxData['tabs'].length - 1) {
          if (dialogBoxData['tabs'][selectedTab.value + 1]['defaultvisibility'] == false) {
            selectedTab.value += 2;
            formScrollController.jumpTo(0);
          } else {
            selectedTab.value++;
            formScrollController.jumpTo(0);
          }
          selectedTab.refresh();
          getMasterDataForTab();
        } else {
          setDefaultData.data.value = [];
          await getList();
          Get.back();
        }
      } catch (e) {
        await getList();
      }
    } else {
      message.value = resBody["message"] ?? "";
      if (!enterInOffline.value) {
        showError(message.value);
      }
    }
  }

  Future<bool> updateData({
    required Map reqData,
    int? editeDataIndex = -1,
    Map<dynamic, String>? projection,
  }) async {
    var url = '${Config.weburl + pageName.value}/add';

    var userAction = "add$pageName";

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = await resBody["message"];
      var updatedDataIndex = editeDataIndex! > -1 ? editeDataIndex : initialStateData["lastEditedDataIndex"] ?? -1;
      if (updatedDataIndex != null && updatedDataIndex > -1) {
        var updatedResData = resBody['data'];
        setDefaultData.data[updatedDataIndex] = updatedResData;
      } else {
        await getList();
      }
    } else {
      message.value = resBody['message'];
      if (!enterInOffline.value) {
        showError(message.value);
      }
    }
    setDefaultData.data.refresh();
    update();
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
      Get.back();
      showSuccess(message.value);
    } else {
      message.value = resBody['message'];
      Get.back();
      if (!enterInOffline.value) {
        showError(message.value);
      }
    }
  }

  Map<String, dynamic> getObjectFromFormData(formData, String field) {
    Map<String, dynamic> object = {};
    for (var tab in formData) {
      for (var data in tab['formfields']) {
        if (object.isEmpty) {
          data["formFields"].forEach((e) {
            if (e['field'] == field) {
              object.addAll(e);
            }
          });
        } else {
          object = object;
        }
      }
    }
    return object;
  }

  Future<bool> getSAPHistory({required String id}) async {
    RxBool isSAPHistoryLoading = false.obs;
    isSAPHistoryLoading.value = true;

    var res = await IISMethods().listData(
      userAction: "listtenant",
      pageName: "tenant",
      url: "${Config.weburl}saptenanthistory",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"tenantid": id},
          "projection": {},
          "sort": {},
        },
      },
    );

    if (res['status'] == 200) {
      sapHistoryList.value = res["data"] ?? [];
    }

    isSAPHistoryLoading.value = false;
    return res['status'] == 200;
  }

  Future<bool> getSAPContractHistory({required String id}) async {
    isSapContractHistoryLoading.value = true;

    var res = await IISMethods().listData(
      userAction: "listtenant",
      pageName: "tenant",
      url: "${Config.weburl}rentstatus",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"tenantid": id},
          "projection": {},
          "sort": {},
        },
      },
    );
    jsonPrint(res, tag: "1233489647574654165456");

    if (res['status'] == 200) {
      sapContractHistoryList.value = List<Map<String, dynamic>>.from(res["data"] ?? []);
      sapContractHistoryFieldOrderList.value = List<Map<String, dynamic>>.from(res['fieldorder']["fields"]);
      jsonPrint(sapContractHistoryList, tag: "3489647574654165456");
    }

    isSapContractHistoryLoading.value = false;
    return res['status'] == 200;
  }

  Future<void> getTenant360Details({required Map<dynamic, dynamic> data}) async {
    RxMap<String, dynamic> ownerHistoryMap = <String, dynamic>{}.obs;
    RxBool isTenantHistoryLoading = false.obs;
    isTenantHistoryLoading.value = true;

    var res = await IISMethods().listData(
      userAction: "listtenant",
      pageName: "tenant",
      url: "${Config.weburl}tenant/ownerhistory",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"tenantid": data['_id'] ?? ""},
          "projection": {},
          "sort": {},
        },
      },
    );

    if (res['status'] == 200) {
      ownerHistoryMap.value = res["data"] ?? {};
    }

    isTenantHistoryLoading.value = false;

    CustomDialogs().customPopDialog(
        child: FullTenantHistoryDialog(
          data: data,
          ownerHistory: ownerHistoryMap,
          setDefaultData: setDefaultData,
          sapHistoryList: sapHistoryList,
          sapContractHistoryList: sapContractHistoryList,
          sapContractHistoryFieldOrderList: sapContractHistoryFieldOrderList,
          isSapContractHistoryLoading: isSapContractHistoryLoading,
          formName: formName,
        ),
        alignment: Alignment.topCenter);
  }

  ///HUTMENT SOLD /TENANT EXPIRED

  Future<void> handleTenantExpired({required int index, required String id}) async {
    Map<String, dynamic> data = Map<String, dynamic>.from(setDefaultData.data[index]);
    RxBool updateLoading = false.obs;
    for (Map<String, dynamic> element in List<Map<String, dynamic>>.from(setDefaultData.data[index]['coapplicant'])) {
      element['isSelected'] = element['isprimary'];
      element['primaryApplicant'] = element['isprimary'] == 1 ? 'Yes' : 'No';
    }
    RxMap<String, dynamic> deathCertificate = <String, dynamic>{}.obs;
    RxMap<String, dynamic> successionCertificate = <String, dynamic>{}.obs;
    RxString deathDate = ''.obs;
    Widget child = SizedBox(
      width: 800,
      child: ResponsiveBuilder(builder: (context, sizingInformation) {
        return Column(
          children: [
            Container(
              height: 85,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorTheme.kBorderColor,
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Row(
                  children: [
                    const Expanded(
                      child: TextWidget(
                        text: 'Change Tenant',
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.kPrimaryColor,
                        textOverflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // setDefaultData.data[index] = data;
                        Get.back();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ColorTheme.kBackGroundGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.clear,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sizingInformation.isMobile ? 8 : 24.0, vertical: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: sizingInformation.isMobile ? const EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.zero,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: 'Hutment No :',
                                  fontWeight: FontTheme.notoSemiBold,
                                  color: ColorTheme.kBlack.withOpacity(0.5),
                                  textOverflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                ),
                                TextWidget(
                                  text: '${data['hutmentno'] ?? ''}',
                                  fontWeight: FontTheme.notoRegular,
                                  color: ColorTheme.kPrimaryColor,
                                  textOverflow: TextOverflow.ellipsis,
                                  fontSize: 18,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: 'Tenant Name :',
                                  fontWeight: FontTheme.notoSemiBold,
                                  color: ColorTheme.kBlack.withOpacity(0.5),
                                  textOverflow: TextOverflow.ellipsis,
                                  fontSize: 14,
                                ),
                                TextWidget(
                                  text: '${data['tenantname'] ?? ''}',
                                  fontWeight: FontTheme.notoRegular,
                                  color: ColorTheme.kPrimaryColor,
                                  textOverflow: TextOverflow.ellipsis,
                                  fontSize: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: sizingInformation.isMobile ? 8 : 16,
                    ),
                    Wrap(
                      children: [
                        Obx(
                          () {
                            var field = deathCertificate.value;
                            var textController = TextEditingController(text: field['name'] ?? '');
                            if (cursorPos <= textController.text.length) {
                              textController.selection = TextSelection.collapsed(offset: cursorPos);
                            } else {
                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                            }
                            Map<String, dynamic> res = {
                              'field': 'tenantdeathcertificate',
                              'text': 'Death Certificate',
                              'type': HtmlControls.kFilePicker,
                              'disabled': false,
                              'defaultvisibility': true,
                              'required': false,
                              'filetypes': FileTypes.pdfAndImage,
                              'gridsize': FieldSize.k375,
                              'condition': {
                                'tenantisexpire': [1]
                              }
                            };
                            return constrainedBoxWithPadding(
                              width: res['gridsize'],
                              child: CustomTextFormField(
                                // textInputType: TextInputType.number,
                                controller: textController,
                                hintText: "No File Chosen",
                                readOnly: true,

                                onTap: () async {
                                  List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                  fileModelList = await IISMethods().uploadFiles(fileModelList);
                                  deathCertificate.value = fileModelList.first.toJson();
                                },
                                onFieldSubmitted: (v) async {
                                  List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                  fileModelList = await IISMethods().uploadFiles(fileModelList);
                                  deathCertificate.value = fileModelList.first.toJson();
                                },
                                prefixWidget: const TextWidget(
                                  text: 'Choose File',
                                  fontSize: 14,
                                  fontWeight: FontTheme.notoRegular,
                                ).paddingSymmetric(horizontal: 4),
                                // validator: (v) {
                                //   var field = (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? {};
                                //   if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                //     if (field['url'].toString().isNullOrEmpty) {
                                //       return "Please Enter ${res["text"]}";
                                //     }
                                //   }
                                //   return null;
                                // },
                                isRequire: res["required"],
                                textFieldLabel: res["text"],
                              ),
                            );
                          },
                        ),
                        Obx(
                          () {
                            var textController = TextEditingController(
                                text: deathDate.value.isNotNullOrEmpty
                                    ? deathDate.value.toDateFormat().toString().toDateFormat() /*DateFormat("dd-MM-yyyy").format(DateTime.parse())*/
                                    : '');
                            if (cursorPos <= textController.text.length) {
                              textController.selection = TextSelection.collapsed(offset: cursorPos);
                            } else {
                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                            }
                            Map<String, dynamic> res = {
                              'field': 'rentreceiveddate',
                              'text': 'Death Date',
                              'type': HtmlControls.kDatePicker,
                              'disabled': false,
                              'defaultvisibility': true,
                              'required': false,
                              'gridsize': FieldSize.k375,
                            };
                            return constrainedBoxWithPadding(
                              width: res['gridsize'],
                              child: CustomTextFormField(
                                textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),

                                controller: textController,
                                hintText: "Enter ${res["text"]}",
                                readOnly: true,
                                disableField: res["disabled"],
                                onTap: () => showCustomDatePicker(
                                    isFutureDateSelected: false,
                                    initialDate: deathDate.value.isNotNullOrEmpty ? DateTime.parse(deathDate.value) : null,
                                    onDateSelected: (p0) async {
                                      deathDate.value = p0;
                                    }),
                                onFieldSubmitted: (v) async {
                                  showCustomDatePicker(
                                      initialDate: deathDate.value.isNotNullOrEmpty ? DateTime.parse(deathDate.value) : null,
                                      onDateSelected: (p0) async {
                                        deathDate.value = p0;
                                      });
                                },
                                suffixIcon: AssetsString.kCalender,
                                // validator: (v) {
                                //   if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                //     if (v.toString().isNullOrEmpty) {
                                //       return "Please Enter ${res["text"]}";
                                //     } else if (res.containsKey("regex")) {
                                //       if (!RegExp(res["regex"]).hasMatch(v)) {
                                //         return "Please Enter a valid ${res["text"]}";
                                //       }
                                //     }
                                //   }
                                //   return null;
                                // },
                                isRequire: res["required"],
                                textFieldLabel: res["text"],
                              ),
                            );
                          },
                        ),
                        Obx(
                          () {
                            var field = successionCertificate.value;
                            var textController = TextEditingController(text: field['name'] ?? '');
                            if (cursorPos <= textController.text.length) {
                              textController.selection = TextSelection.collapsed(offset: cursorPos);
                            } else {
                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                            }
                            Map<String, dynamic> res = {
                              'field': 'successioncertificate',
                              'text': 'Succession Certificate',
                              'type': HtmlControls.kFilePicker,
                              'disabled': false,
                              'defaultvisibility': true,
                              'required': false,
                              'filetypes': FileTypes.pdfAndImage,
                              'gridsize': FieldSize.k375,
                              'condition': {
                                'tenantisexpire': [1]
                              }
                            };
                            return constrainedBoxWithPadding(
                              width: res['gridsize'],
                              child: CustomTextFormField(
                                // textInputType: TextInputType.number,
                                controller: textController,
                                hintText: "No File Chosen",
                                readOnly: true,

                                onTap: () async {
                                  List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                  fileModelList = await IISMethods().uploadFiles(fileModelList);
                                  successionCertificate.value = fileModelList.first.toJson();
                                },
                                onFieldSubmitted: (v) async {
                                  List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                  fileModelList = await IISMethods().uploadFiles(fileModelList);
                                  successionCertificate.value = fileModelList.first.toJson();
                                },
                                prefixWidget: const TextWidget(
                                  text: 'Choose File',
                                  fontSize: 14,
                                  fontWeight: FontTheme.notoRegular,
                                ).paddingSymmetric(horizontal: 4),
                                // validator: (v) {
                                //   var field = (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? {};
                                //   if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                //     if (field['url'].toString().isNullOrEmpty) {
                                //       return "Please Enter ${res["text"]}";
                                //     }
                                //   }
                                //   return null;
                                // },
                                isRequire: res["required"],
                                textFieldLabel: res["text"],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: sizingInformation.isMobile ? 8 : 16,
                    ),

                    ///VIEW 0
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: sizingInformation.isMobile ? const EdgeInsets.symmetric(horizontal: 8.0) : EdgeInsets.zero,
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: ColorTheme.kBorderColor)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const TextWidget(
                                      text: 'Select Co-Applicant',
                                      fontWeight: FontWeight.w500,
                                      color: ColorTheme.kPrimaryColor,
                                      textOverflow: TextOverflow.ellipsis,
                                      fontSize: 18,
                                    ).paddingSymmetric(vertical: 16, horizontal: 12),
                                    Expanded(
                                      child: Obx(() {
                                        List<Map<String, dynamic>> coapplicants = List<Map<String, dynamic>>.from(setDefaultData.data[index]['coapplicant']);
                                        return Container(
                                          clipBehavior: Clip.hardEdge,
                                          decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                                          child: CommonDataTableWidget(
                                            width: sizingInformation.isMobile ? MediaQuery.sizeOf(context).width - 50 : min(750, MediaQuery.sizeOf(context).width - 50),
                                            showPagination: false,
                                            setDefaultData: FormDataModel(),
                                            handleGridChange: (i, field, type, value, masterfieldname, name) {
                                              var id = setDefaultData.data[index]['coapplicant'].where((entry) => entry['isexpire'] != 1).toList()[i]['_id'];
                                              i = (setDefaultData.data[index]['coapplicant'] as List).indexWhere(
                                                (element) => element['_id'] == id,
                                              );
                                              for (Map<String, dynamic> element in List<Map<String, dynamic>>.from(setDefaultData.data[index]['coapplicant'])) {
                                                element['isSelected'] = 0;
                                              }
                                              setDefaultData.data[index]['coapplicant'][i]['isSelected'] = 1;
                                              devPrint(setDefaultData.data[index]['coapplicant']);
                                              setDefaultData.data.refresh();
                                            },
                                            fieldOrder: const [
                                              {
                                                "field": "isSelected",
                                                "text": "Select",
                                                "type": "checkbox",
                                                "freeze": 1,
                                                "active": 1,
                                                "sorttable": 0,
                                                "sortby": "name",
                                                "filter": 0,
                                                "filterfieldtype": "dropdown",
                                                "defaultvalue": "",
                                                "tblsize": 10,
                                              },
                                              {
                                                "field": "isprimary",
                                                "text": "Primary",
                                                "type": "approve",
                                                "freeze": 1,
                                                "active": 1,
                                                "sorttable": 0,
                                                "sortby": "name",
                                                "filter": 0,
                                                "filterfieldtype": "dropdown",
                                                "defaultvalue": "",
                                                "tblsize": 12,
                                              },
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
                                                "tblsize": 20,
                                              },
                                              {
                                                "field": "relation",
                                                "text": "Relation",
                                                "type": "text",
                                                "freeze": 1,
                                                "active": 1,
                                                "sorttable": 0,
                                                "sortby": "name",
                                                "filter": 0,
                                                "filterfieldtype": "dropdown",
                                                "defaultvalue": "",
                                                "tblsize": 12,
                                              },
                                            ],
                                            data: List<Map<String, dynamic>>.from(data['hascoapplicant'] == 1 ? (setDefaultData.data.value[index]['coapplicant'] ?? []) : []).where((entry) => entry['isexpire'] != 1).toList(),
                                            tableScrollController: tableScrollController,
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                borderWidth: 1,
                                buttonColor: ColorTheme.kTableHeader,
                                borderColor: ColorTheme.kTableHeader,
                                height: 36,
                                showBoxBorder: true,
                                width: sizingInformation.isDesktop ? 50 : 30,
                                onTap: () async {
                                  setFormData(id: id, editeDataIndex: index).then((value) {
                                    selectedTab.value = 2;
                                    formScrollController.jumpTo(0);
                                    dialogBoxData['tabs'][2]['defaultvisibility'] = true;
                                    getMasterDataForTab();
                                  });
                                  await Get.dialog(
                                    barrierDismissible: false,
                                    TenantsMasterForm(
                                      oldData: setDefaultData.data[index],
                                    ),
                                  );
                                  setDefaultData.data.refresh();
                                  setFilterData();
                                  setDefaultData.filterData.removeNullValues();
                                },
                                borderRadius: 6,
                                widget: Row(
                                  children: [
                                    if (sizingInformation.isDesktop) const Icon(Icons.add, color: ColorTheme.kBlack),
                                    if (sizingInformation.isDesktop) const SizedBox(width: 4),
                                    TextWidget(
                                      text: 'Add Co-Applicant',
                                      color: ColorTheme.kBlack,
                                      fontWeight: FontTheme.notoMedium,
                                      fontSize: sizingInformation.isDesktop ? 16 : 14,
                                    ).paddingOnly(right: 4),
                                  ],
                                ),
                              ),
                              Obx(() {
                                return CustomButton(
                                  isLoading: updateLoading.value,
                                  onTap: () async {
                                    var newApplicant;

                                    try {
                                      newApplicant = List<Map<String, dynamic>>.from(setDefaultData.data[index]['coapplicant'] ?? []).firstWhere((element) => element['isSelected'] == 1);
                                    } catch (e) {
                                      if (!enterInOffline.value) {
                                        showError('Please select a Co-Applicant');
                                      }
                                      return;
                                    }
                                    setDefaultData.data[index]['newtenant'] = newApplicant;
                                    setDefaultData.data[index]['tenantisexpire'] = 1;
                                    setDefaultData.data[index]['tenantdeathcertificate'] = deathCertificate.value;
                                    setDefaultData.data[index]['successioncertificate'] = successionCertificate.value;
                                    setDefaultData.data[index]['tenantdeathdate'] = deathDate.value;
                                    if (await updateData(
                                      reqData: setDefaultData.data[index],
                                      editeDataIndex: index,
                                    )) {
                                      Get.back();
                                    }
                                  },
                                  height: 40,
                                  width: 70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  buttonColor: ColorTheme.kPrimaryColor,
                                  fontColor: ColorTheme.kWhite,
                                  borderRadius: 4,
                                  title: 'Update',
                                );
                              }),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );

    if (getDeviceType(MediaQuery.sizeOf(Get.context!)) == DeviceScreenType.mobile) {
      showBottomBar.value = false;
      await showModalBottomSheet(
        context: Get.context!,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        isScrollControlled: true,
        constraints: BoxConstraints.tight(Size(MediaQuery.of(Get.context!).size.width, MediaQuery.of(Get.context!).size.height * 0.95)),
        builder: (context) => SizedBox(height: MediaQuery.of(context).size.height - 80, child: child),
        isDismissible: false,

        // isScrollControlled: true,
      );
      showBottomBar.value = true;
    } else {
      Get.dialog(Dialog(
        alignment: Alignment.centerRight,
        insetPadding: EdgeInsets.zero,
        surfaceTintColor: ColorTheme.kWhite,
        child: child,
      ));
    }
  }

  void handleHutmentSold({required int index, required String id, bool? isFormOpen}) {
    Get.dialog(CustomDialogs.alertDialog(
      message: 'Do you want to change\nTenant details ?',
      onYes: () async {
        Get.back();
        if (isFormOpen == true) {
          Get.back();
        }
        setFormData(id: id, editeDataIndex: index).then((value) {
          selectedTab.value = 1;
          formScrollController.jumpTo(0);
          var tabs = dialogBoxData['tabs'][1];
          dialogBoxData['tabs'][2]['defaultvisibility'] = false;
          Map<String, dynamic> tempFormData = {};
          getMasterDataForTab();
          for (var data in tabs["formfields"]) {
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
                case HtmlControls.kMultipleImagePicker:
                  tempFormData[fields["field"]] = [];
                  break;
                case HtmlControls.kMultipleContactSelection:
                  tempFormData[fields["field"]] = [''];
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
          setDefaultData.formData.addAll(tempFormData);
          setDefaultData.formData['coapplicant'] = [];
          setDefaultData.formData['hutmentsold'] = 1;
        });
        await Get.dialog(
          barrierDismissible: false,
          TenantsMasterForm(
            oldData: setDefaultData.data[index],
          ),
        );
        setDefaultData.data.refresh();
        setFilterData();
        setDefaultData.filterData.removeNullValues();
      },
      onNo: () {
        Get.back();
      },
    ));
  }

  ///HUTMENT SOLD /TENANT EXPIRED

  ///PUSH TO SAP

  Future pushTenantsToSAP(List<Map<String, dynamic>> tenantsData) async {
    Map<String, dynamic> reqBody = {};
    reqBody['data'] = tenantsData.map(
      (e) {
        return {'tenantid': e['_id'], ...e};
      },
    ).toList();
    reqBody['fortenant'] = 1;
    var response = await IISMethods().listData(
      userAction: 'synctosap',
      pageName: 'tenant',
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

  Future<void> getSapData({required List selectedIds, required String tenantProjectId}) async {
    if (selectedIds.isNullOrEmpty) {
      showError('Select Atleast 1 Tenant');
      return;
    }
    isSapSelection.value = false;
    RxMap<String, dynamic> totalRentData = <String, dynamic>{}.obs;
    RxBool sapDataLoading = true.obs;

    FormDataModel sapSetDefaultData = FormDataModel();
    sapDataLoading.value = true;
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
          'fortenant': 1,
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
            title: 'Tenant',
            fieldOrder: sapSetDefaultData.fieldOrder,
            data: sapSetDefaultData.data,
            isLoading: sapDataLoading,
            setDefaultData: sapSetDefaultData,
            rentMap: totalRentData,
            stage: stage,
            onSubmitToSAP: () async {
              var response = await pushTenantsToSAP(sapSetDefaultData.data);
              if (response['status'] == 200) {
                sapSetDefaultData.data.value = List<Map<String, dynamic>>.from(response['data']);
                sapSetDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(response['fieldorder']);
                stage.value = 1;
                getList();
              }
            },
          ));
    }
  }
}

Future<void> getContractPaymentDetails({
  required String tenantId,
  required String contractNo,
  required String paymentCode,
  required String contractStartDate,
  required String contractEndDate,
}) async {
  RxInt statusCode = 0.obs;
  RxBool isContractDetailsLoading = true.obs;
  FormDataModel contractSetDefaultData = FormDataModel();
  final url = "${Config.weburl}rentstatus";
  const userAction = "listcontractlisting";
  final reqBody = {
    'searchtext': '',
    'paginationinfo': {
      'pageno': 1,
      'pagelimit': 999999999999,
      "filter": {
        "tenantid": tenantId,
        "contractno": contractNo,
        "paymentcode": paymentCode,
        "contract_start_date": contractStartDate,
        "contract_end_date": contractEndDate,
      },
      'sort': {},
    },
  };
  var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: getCurrentPageName());

  statusCode.value = resBody["status"] ?? 0;

  if (resBody["status"] == 200) {
    isContractDetailsLoading.value = false;
    jsonPrint(tag: "45165341634106534165341", resBody);
    contractSetDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"] ?? []);
    contractSetDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data'] ?? []);

    CustomDialogs().customFilterDialogs(
      context: Get.context!,
      widget: ContractDetails(
        fieldOrder: contractSetDefaultData.fieldOrder,
        data: contractSetDefaultData.data,
        isLoading: isContractDetailsLoading,
        setDefaultData: contractSetDefaultData,
      ),
    );
  }
}
