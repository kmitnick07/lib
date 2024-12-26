import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_search_box.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/helper/device_service.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/style/string_const.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/customs/multi_drop_down_custom.dart';
import '../../components/customs/text_widget.dart';
import '../../components/funtions.dart';
import '../../components/json/approval_json.dart';
import '../../components/repo/auth/auth_repo.dart';
import '../../config/helper/offline_data.dart';
import '../../config/settings.dart';
import '../../routes/route_generator.dart';
import '../../routes/route_name.dart';
import '../../style/assets_string.dart';
import '../../view/CommonWidgets/common_table.dart';
import '../Approval/approval_master_controller.dart';
import '../layout_templete_controller.dart';

class DashBoardController extends GetxController {
  RxInt selectedTab = 0.obs;

  RxList<Map<String, dynamic>> tenantProject = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filterDurationList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filterApprovalsDurationList = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> societyList = <String, dynamic>{}.obs;

  //Reports
  RxMap<String, dynamic> consentReport = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> eligibilityReport = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> tatReport = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> statusCountReport = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> rentPaymentReport = <Map<String, dynamic>>[].obs;

  //Reports Loading
  RxBool consentReportLoading = false.obs;
  RxBool eligibilityReportLoading = false.obs;
  RxBool tatReportLoading = false.obs;
  RxBool approvalsLoading = false.obs;
  RxBool statusCountReportLoading = false.obs;
  ScrollController statusCountScrollController = ScrollController();
  RxBool rentPaymentReportLoading = false.obs;

  //Filter
  RxMap<String, dynamic> commonFilters = <String, dynamic>{}.obs;
  RxMap<String, dynamic> commonApprovalsFilters = <String, dynamic>{}.obs;

  List<String> reportKeys = ['common', 'hutmentstatusreport', 'consentreport', 'eligibilityreport', 'tatreport', 'rentpaymentstatusreport'];
  List<String> reportApprovalsKeys = ['approvals'];

  FormDataModel setDefaultData = FormDataModel();
  RxBool loadingData = false.obs;
  RxBool loadingPaginationData = false.obs;
  RxString pageName = 'approvals'.obs;
  RxString searchText = ''.obs;
  RxInt statusCode = 0.obs;

  // ScrollController tableScrollController = ScrollController();
  RxMap dialogBoxData = {}.obs;
  RxString formName = ''.obs;
  RxBool isAddButtonVisible = false.obs;

  Future<void> onInitl() async {
    if (!Settings.isUserLogin) {
      navigateTo(RouteNames.kLoginScreen);
    } else if (!isoffline.value) {
      DeviceData().sendDeviceData();
    }
    if (!kIsWeb && !isoffline.value) {
      await AuthRepo().getLoginData();
      await Offline().setData();
      await Get.find<LayoutTemplateController>().getMenuList();
      Get.find<LayoutTemplateController>().getBottomBarRights();
      Get.find<LayoutTemplateController>().showDrawer.value = true;
    }
    dialogBoxData.value = ApprovalJson.designationFormFields(pageName.value) ?? {};
    if (!isoffline.value) {
      setPageTitle('Dashboard | PRENEW', Get.context!);
      await getTenantProject();
      await getFilterDurationList();
      await getApprovalsFilterDurationList();
      var society = await getSociety(tenantproject: []);
      for (var key in reportKeys) {
        societyList[key] = society;
      }
    }
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<DashBoardController>();
    Get.delete<ApprovalMasterController>();
    super.dispose();
  }

  Future<void> onRefresh() async {
    devPrint("8654165341asdfghjkl3541");
    getHutmentStatusReport();
    getConsentReport();
    getTurnAroundTimeReport();
    getRentPaymentReport();
    getEligibilityReport();
    // await getApprovalsList(approvalsFilter: {'isexpirybased': 1});
  }

  Future<void> getApprovalsList({bool appendData = false, String fromdate = "", String todate = "", int filterduration = 1, Map? approvalsFilter}) async {
    devPrint("9641635416534163: 'getApprovalsList'");
    setDefaultData.data.value == [];
    if (!appendData) {
      loadingData.value = true;
    } else {
      loadingPaginationData.value = true;
    }
    setDefaultData.data.refresh();
    update();
    devPrint("98465978454865485pageName");
    devPrint(pageName.value);
    final url = Config.weburl + pageName.value;
    final userAction = "list$pageName";
    var filter = {};
    filter = {
      'isexpirybased': 1,
    };
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
        'projection': {'approvals': 0},
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

  getTenantProject() async {
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": {}, "projection": {}, "sort": {}}
    };
    tenantProject.value = List<Map<String, dynamic>>.from(
        ((await IISMethods().listData(userAction: 'listtenantproject', pageName: 'analytics', url: '${Config.weburl}tenantproject', reqBody: reqBody))['data']) ?? []);
    if (tenantProject.value.isNotNullOrEmpty) {
      for (var key in reportKeys) {
        if ((commonFilters[key]) == null) {
          commonFilters[key] = {};
        }
      }
    }
  }

  getFilterDurationList() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 500000000000,
        "filter": {'ispast': 1},
        "projection": {},
        "sort": {}
      }
    };
    filterDurationList.value = List<Map<String, dynamic>>.from(
      ((await IISMethods()
              .listData(userAction: 'listtenantproject', pageName: 'dashboard', url: '${Config.weburl}filterduration', reqBody: reqBody, masterlisting: true))['data']) ??
          [],
    );
    for (var key in reportKeys) {
      if (commonFilters[key] == null) {
        commonFilters[key] = {};
      }
      commonFilters[key]['filterduration'] = 1;
    }
  }

  getApprovalsFilterDurationList() async {
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": {}, "projection": {}, "sort": {}}
    };
    filterApprovalsDurationList.value = List<Map<String, dynamic>>.from(
      ((await IISMethods()
              .listData(userAction: 'listtenantproject', pageName: 'dashboard', url: '${Config.weburl}filterduration', reqBody: reqBody, masterlisting: true))['data']) ??
          [],
    );
    for (var key in reportApprovalsKeys) {
      if (commonApprovalsFilters[key] == null) {
        commonApprovalsFilters[key] = {};
      }
      commonApprovalsFilters[key]['filterduration'] = 1;
    }
  }

  getSociety({tenantproject}) async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 500000000000,
        "filter": {
          'tenantproject': tenantproject ?? [],
        },
        "projection": {},
        "sort": {}
      }
    };
    return List<Map<String, dynamic>>.from(
        ((await IISMethods().listData(userAction: 'listsociety', pageName: 'dashboard', url: '${Config.weburl}society', reqBody: reqBody, masterlisting: true))['data']) ?? []);
  }

  getHutmentStatusReport() async {
    statusCountReportLoading.value = true;
    String key = 'hutmentstatusreport';
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 10,
        "filter": commonFilters[key] ?? {},
        "sort": {},
      },
      "searchtext": ""
    };
    statusCountReport.value = List<Map<String, dynamic>>.from(
        (await IISMethods().listData(userAction: 'listtenantstatusreport', pageName: 'dashboard', url: '${Config.weburl}hutmentstatusreport', reqBody: reqBody))['data']);
    statusCountReportLoading.value = false;
  }

  getConsentReport() async {
    consentReportLoading.value = true;
    String key = 'consentreport';
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 10, "filter": commonFilters[key] ?? {}, "sort": {}},
      "searchtext": ""
    };
    consentReport.value = Map<String, dynamic>.from(
        (await IISMethods().listData(userAction: 'listconsentreport', pageName: 'dashboard', url: '${Config.weburl}consentreport', reqBody: reqBody))['data']);
    consentReportLoading.value = false;
  }

  getEligibilityReport() async {
    eligibilityReportLoading.value = true;
    String key = 'eligibilityreport';
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 10, "filter": commonFilters[key] ?? {}, "sort": {}},
      "searchtext": ""
    };
    eligibilityReport.value = List<Map<String, dynamic>>.from(
            (await IISMethods().listData(userAction: 'listeligibilityreport', pageName: 'dashboard', url: '${Config.weburl}eligibilityreport', reqBody: reqBody))['data'])
        .where((element) => element['result'] > 0)
        .toList();
    eligibilityReportLoading.value = false;
  }

  getTurnAroundTimeReport() async {
    tatReportLoading.value = true;
    String key = 'tatreport';
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 10, "filter": commonFilters[key] ?? {}, "sort": {}},
      "searchtext": ""
    };
    tatReport.value = List<Map<String, dynamic>>.from(
        (await IISMethods().listData(userAction: 'listtatreport', pageName: 'dashboard', url: '${Config.weburl}tatreport', reqBody: reqBody))['data']);
    tatReportLoading.value = false;
  }

  getRentPaymentReport() async {
    rentPaymentReportLoading.value = true;
    String key = 'rentpaymentstatusreport';
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 10, "filter": commonFilters[key] ?? {}, "sort": {}},
      "searchtext": ""
    };
    rentPaymentReport.value = List<Map<String, dynamic>>.from((await IISMethods()
            .listData(userAction: 'listrentpaymentstatusreport', pageName: 'dashboard', url: '${Config.weburl}rentpaymentstatusreport', reqBody: reqBody))['data'])
        .where((element) => element['result'] > 0)
        .toList();
    rentPaymentReportLoading.value = false;
  }

  showFilterButton({required String reportKey, required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TapRegion(
          onTapInside: (event) async {
            Offset offset = Offset(max(0, event.position.dx - 350), event.position.dy - 10);
            devPrint(event.position.toString());
            devPrint(offset.dx);
            Widget filterDialog = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  return constrainedBoxWithPadding(
                    width: 200,
                    child: MultiDropDownSearchCustom(
                      items: List<Map<String, dynamic>>.from(tenantProject.map((element) => {
                            'value': element['_id'],
                            'label': element['name'],
                          })),
                      isCleanable: true,
                      optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                      selectedOptionColor: ColorTheme.kWarnColor,
                      filledColor: ColorTheme.kWarnColor,
                      borderColor: ColorTheme.kWarnColor,
                      fontColor: ColorTheme.kWhite,
                      staticText: 'TENANT PROJECT',
                      prefixWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          AssetsString.kTenantProject,
                          colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                        ),
                      ),
                      clickOnCleanBtn: () async {
                        List selectedValue = [];
                        var society = await getSociety(tenantproject: selectedValue);

                        commonFilters[reportKey].remove('society');
                        commonFilters[reportKey]['tenantproject'] = selectedValue;
                        societyList[reportKey] = society;
                        commonFilters.refresh();
                        switch (reportKey) {
                          case 'hutmentstatusreport':
                            getHutmentStatusReport();
                            break;
                          case 'consentreport':
                            getConsentReport();
                            break;
                          case 'eligibilityreport':
                            getEligibilityReport();
                            break;
                          case 'tatreport':
                            getTurnAroundTimeReport();
                            break;
                          case 'rentpaymentstatusreport':
                            getRentPaymentReport();
                        }
                      },
                      onChanged: (p0) async {
                        List selectedValue = [];
                        for (var e in p0) {
                          Map<String, dynamic> tenantProject = this.tenantProject.firstWhere((element) => element['_id'] == e);
                          selectedValue.add({
                            "tenantprojectid": e,
                            "tenantproject": tenantProject['name'],
                          });
                        }
                        var society = await getSociety(tenantproject: selectedValue);
                        commonFilters[reportKey].remove('society');

                        commonFilters[reportKey]['tenantproject'] = selectedValue;
                        societyList[reportKey] = society;
                        commonFilters.refresh();
                        jsonPrint(tag: "98654249865416532465", society);
                        switch (reportKey) {
                          case 'hutmentstatusreport':
                            getHutmentStatusReport();
                            break;
                          case 'consentreport':
                            getConsentReport();
                            break;
                          case 'eligibilityreport':
                            getEligibilityReport();
                            break;
                          case 'tatreport':
                            getTurnAroundTimeReport();
                            break;
                          case 'rentpaymentstatusreport':
                            getRentPaymentReport();
                        }
                      },
                      hintText: 'TENANT PROJECT',
                      // textFieldLabel: 'Tenant Project',
                      dropValidator: (p0) {},
                      selectedItems: List<Map<String, dynamic>>.from(commonFilters[reportKey]?['tenantproject'] ?? []),
                      field: 'tenantproject',
                    ),
                  );
                }),
                Obx(() {
                  return constrainedBoxWithPadding(
                    width: 200,
                    child: MultiDropDownSearchCustom(
                      items: List<Map<String, dynamic>>.from((societyList[reportKey] ?? []).map((element) => {
                            'value': element['_id'],
                            'label': element['tenantname'],
                          })),
                      optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                      selectedOptionColor: ColorTheme.kWarnColor,
                      filledColor: ColorTheme.kWarnColor,
                      borderColor: ColorTheme.kWarnColor,
                      fontColor: ColorTheme.kWhite,
                      staticText: 'SOCIETY',
                      prefixWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          AssetsString.kBuilding,
                          colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                        ),
                      ),
                      isCleanable: true,
                      clickOnCleanBtn: () async {
                        List selectedValue = [];
                        if (commonFilters[reportKey] == null) {
                          commonFilters[reportKey] = {};
                        }
                        commonFilters[reportKey]['society'] = selectedValue;

                        commonFilters.refresh();
                        switch (reportKey) {
                          case 'hutmentstatusreport':
                            getHutmentStatusReport();
                            break;
                          case 'consentreport':
                            getConsentReport();
                            break;
                          case 'eligibilityreport':
                            getEligibilityReport();
                            break;
                          case 'tatreport':
                            getTurnAroundTimeReport();
                            break;
                          case 'rentpaymentstatusreport':
                            getRentPaymentReport();
                        }
                      },
                      onChanged: (p0) async {
                        List selectedValue = [];
                        for (var e in p0) {
                          Map<String, dynamic> tenantProject = societyList[reportKey].firstWhere((element) => element['_id'] == e);
                          selectedValue.add({
                            "societyid": e,
                            "society": tenantProject['tenantname'],
                          });
                        }
                        if (commonFilters[reportKey] == null) {
                          commonFilters[reportKey] = {};
                        }
                        commonFilters[reportKey]['society'] = selectedValue;

                        commonFilters.refresh();
                        switch (reportKey) {
                          case 'hutmentstatusreport':
                            getHutmentStatusReport();
                            break;
                          case 'consentreport':
                            getConsentReport();
                            break;
                          case 'eligibilityreport':
                            getEligibilityReport();
                            break;
                          case 'tatreport':
                            getTurnAroundTimeReport();
                            break;
                          case 'rentpaymentstatusreport':
                            getRentPaymentReport();
                        }
                      },
                      hintText: 'SOCIETY',
                      // textFieldLabel: 'Society',
                      dropValidator: (p0) {},
                      selectedItems: List<Map<String, dynamic>>.from(commonFilters[reportKey]?['society'] ?? []),
                      field: 'society',
                    ),
                  );
                }),
                Obx(() {
                  return constrainedBoxWithPadding(
                      width: 200,
                      child: DropDownSearchCustom(
                        focusNode: FocusNode(),
                        canShiftFocus: false,
                        showPrefixDivider: false,
                        optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                        selectedOptionColor: ColorTheme.kWarnColor,
                        fillColor: ColorTheme.kWarnColor,
                        borderColor: ColorTheme.kWarnColor,
                        fontColor: ColorTheme.kWhite,
                        staticText: 'DURATION',
                        prefixWidget: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            AssetsString.kCalender,
                            colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                          ),
                        ),
                        items: List<Map<String, dynamic>>.from(filterDurationList),
                        initValue: commonFilters[reportKey]['filterduration'].toString().isNotNullOrEmpty
                            ? commonFilters[reportKey]['filterduration'] == 0
                                ? {
                                    'value': 0,
                                    'label': '${commonFilters[reportKey]['fromdate'].toString().toDateFormat()} - ${commonFilters[reportKey]['todate'].toString().toDateFormat()}',
                                  }
                                : List<Map<String, dynamic>>.from(filterDurationList).firstWhere(
                                    (element) => element['value'] == commonFilters[reportKey]['filterduration'],
                                    orElse: () {
                                      return {};
                                    },
                                  )
                            : null,
                        hintText: "DURATION",
                        isCleanable: false,
                        hintColor: ColorTheme.kWarnColor,
                        isSearchable: false,
                        onChanged: (v) async {
                          Future.delayed(const Duration(milliseconds: 1)).then(
                            (value) async {
                              String fromdate = '';
                              String todate = '';
                              bool cancelled = false;
                              debugPrint(v.toString());
                              if (v?['value'].toString().converttoInt == 0) {
                                await showCustomDateRangePicker(onDateSelected: (String startDate, String endDate) {
                                  fromdate = startDate;
                                  todate = endDate;
                                }, onCancel: () {
                                  cancelled = true;
                                });
                              }
                              if (cancelled) {
                                return;
                              }
                              if (commonFilters[reportKey] == null) {
                                commonFilters[reportKey] = {};
                              }
                              commonFilters[reportKey]['filterduration'] = v?['value'].toString().converttoInt;
                              commonFilters[reportKey]['fromdate'] = fromdate;
                              commonFilters[reportKey]['todate'] = todate;

                              commonFilters.refresh();
                              switch (reportKey) {
                                case 'hutmentstatusreport':
                                  getHutmentStatusReport();
                                  break;
                                case 'consentreport':
                                  getConsentReport();
                                  break;
                                case 'eligibilityreport':
                                  getEligibilityReport();
                                  break;
                                case 'tatreport':
                                  getTurnAroundTimeReport();
                                  break;
                                case 'rentpaymentstatusreport':
                                  getRentPaymentReport();
                              }
                            },
                          );
                        },
                        dropValidator: (val) {
                          return null;
                        },
                      ));
                }),
              ],
            );

            if (getDeviceType(MediaQuery.sizeOf(Get.context!)) == DeviceScreenType.mobile) {
              showBottomBar.value = false;
              await showModalBottomSheet(
                context: Get.context!,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                ),
                showDragHandle: true,

                isScrollControlled: true,
                // backgroundColor: ColorTheme.kWhite,
                // constraints: BoxConstraints.tight(Size(MediaQuery.of(Get.context!).size.width, MediaQuery.of(Get.context!).size.height * .8)),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: filterDialog,
                ),
              );
              showBottomBar.value = true;
            } else {
              await Get.dialog(
                barrierColor: Colors.transparent,
                Dialog(
                    shadowColor: Colors.transparent,
                    elevation: 10,
                    backgroundColor: Colors.transparent,
                    alignment: Alignment.topLeft,
                    insetPadding: EdgeInsets.only(top: offset.dy, left: offset.dx),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              Get.back();
                            },
                            child: const SizedBox(
                              height: 30,
                              width: 40,
                            )),
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorTheme.kBlack.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                                color: ColorTheme.kWhite),
                            padding: const EdgeInsets.all(8.0),
                            child: filterDialog),
                      ],
                    )),
              );
            }
          },
          child: MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: Container(
              decoration: BoxDecoration(
                color: ColorTheme.kWarnColor,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                AssetsString.kFilter,
                height: 18,
                colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
              ),
            ),
          )),
    );
  }

  showApprovalsFilterButton({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TapRegion(
          onTapInside: (event) async {
            Offset offset = Offset(max(0, event.position.dx - 350), event.position.dy - 10);
            devPrint(event.position.toString());
            devPrint(offset.dx);
            Widget filterDialog = Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  return constrainedBoxWithPadding(
                    width: 200,
                    child: DropDownSearchCustom(
                      focusNode: FocusNode(),
                      canShiftFocus: false,
                      showPrefixDivider: false,
                      optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                      selectedOptionColor: ColorTheme.kWarnColor,
                      fillColor: ColorTheme.kWarnColor,
                      borderColor: ColorTheme.kWarnColor,
                      fontColor: ColorTheme.kWhite,
                      staticText: 'DURATION',
                      prefixWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          AssetsString.kCalender,
                          colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                        ),
                      ),
                      items: List<Map<String, dynamic>>.from(filterApprovalsDurationList),
                      initValue: commonApprovalsFilters['approvals']['filterduration'].toString().isNotNullOrEmpty
                          ? commonApprovalsFilters['approvals']['filterduration'] == 0
                              ? {
                                  'value': 0,
                                  'label':
                                      '${commonApprovalsFilters['approvals']['fromdate'].toString().toDateFormat()} - ${commonApprovalsFilters['approvals']['todate'].toString().toDateFormat()}',
                                }
                              : List<Map<String, dynamic>>.from(filterApprovalsDurationList).firstWhere(
                                  (element) => element['value'] == commonApprovalsFilters['approvals']['filterduration'],
                                  orElse: () {
                                    return {};
                                  },
                                )
                          : null,

                      hintText: "DURATION",
                      // textFieldLabel: "Duration",
                      isCleanable: false,

                      // initValue:
                      isSearchable: true,
                      onChanged: (v) async {
                        Future.delayed(const Duration(milliseconds: 1)).then((value) async {
                          String fromdate = '';
                          String todate = '';
                          bool cancelled = false;
                          debugPrint(v.toString());
                          if (v?['value'].toString().converttoInt == 0) {
                            await showCustomDateRangePicker(
                                onDateSelected: (String startDate, String endDate) {
                                  fromdate = startDate;
                                  todate = endDate;
                                },
                                isFutureDateSelected: true,
                                onCancel: () {
                                  cancelled = true;
                                });
                          }
                          if (cancelled) {
                            return;
                          }
                          if (commonApprovalsFilters['approvals'] == null) {
                            commonApprovalsFilters['approvals'] = {};
                          }
                          commonApprovalsFilters['approvals']['filterduration'] = v?['value'].toString().converttoInt;
                          commonApprovalsFilters['approvals']['fromdate'] = fromdate;
                          commonApprovalsFilters['approvals']['todate'] = todate;
                          devPrint("fromdate,  todate");
                          devPrint(commonApprovalsFilters['approvals']['filterduration']);
                          devPrint("$fromdate,  $todate");
                          commonApprovalsFilters.refresh();
                          // ApprovalMasterController approvalMasterController = Get.find<ApprovalMasterController>();
                          // approvalMasterController.pageName.value = "approvals";
                          getApprovalsList(approvalsFilter: {'fromdate': fromdate, 'todate': todate, 'filterduration': commonApprovalsFilters['approvals']['filterduration'] ?? 1});
                        });
                      },
                      dropValidator: (Map<String, dynamic>? v) {
                        return null;
                      },
                    ),
                  );
                }),
              ],
            );
            if (getDeviceType(MediaQuery.sizeOf(Get.context!)) == DeviceScreenType.mobile) {
              showBottomBar.value = false;
              await showModalBottomSheet(
                context: Get.context!,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                ),
                showDragHandle: true,

                isScrollControlled: true,
                // backgroundColor: ColorTheme.kWhite,
                // constraints: BoxConstraints.tight(Size(MediaQuery.of(Get.context!).size.width, MediaQuery.of(Get.context!).size.height * .8)),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: filterDialog,
                ),
              );
              showBottomBar.value = true;
            } else {
              await Get.dialog(
                barrierColor: Colors.transparent,
                Dialog(
                    shadowColor: Colors.transparent,
                    elevation: 10,
                    backgroundColor: Colors.transparent,
                    alignment: Alignment.topLeft,
                    insetPadding: EdgeInsets.only(top: offset.dy, left: offset.dx),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              Get.back();
                            },
                            child: const SizedBox(
                              height: 30,
                              width: 40,
                            )),
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorTheme.kBlack.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                                color: ColorTheme.kWhite),
                            padding: const EdgeInsets.all(8.0),
                            child: filterDialog),
                      ],
                    )),
              );
            }
          },
          child: MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: Container(
              decoration: BoxDecoration(
                color: ColorTheme.kWarnColor,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(
                AssetsString.kFilter,
                height: 18,
                colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
              ),
            ),
          )),
    );
  }

  Future<FormDataModel> getList({required FormDataModel setDefaultData, filter, searchText, required String endpoint, bool? appendData}) async {
    Map<String, dynamic> reqBody = {
      "paginationinfo": {
        "pageno": setDefaultData.pageNo.value,
        "pagelimit": setDefaultData.pageLimit,
        "filter": filter ?? {},
        "sort": setDefaultData.sortData.value,
      },
      "searchtext": searchText ?? ''
    };

    var resBody = await IISMethods().listData(userAction: 'listrentpaymentstatusreport', pageName: 'dashboard', url: '${Config.weburl}$endpoint', reqBody: reqBody);
    if (appendData ?? false) {
      setDefaultData.data.value.addAll(List<Map<String, dynamic>>.from(resBody['data']));
      setDefaultData.data.refresh();
    } else {
      setDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data']);
    }
    setDefaultData.nextPage = resBody['nextpage'];
    setDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"]);
    setDefaultData.contentLength = resBody['totaldocs'] ?? 0;
    setDefaultData.noOfPages.value = (setDefaultData.contentLength / setDefaultData.pageLimit).ceil();
    return setDefaultData;
  }

  getTenantList({
    required Map<String, dynamic> filter,
    required String endpoint,
    required String title,
  }) async {
    RxString searchText = ''.obs;
    FocusNode searchFocusNode1 = FocusNode();
    TextEditingController searchController = SearchController();
    FormDataModel setDefaultData = FormDataModel();
    ScrollController tableScrollController = ScrollController();
    RxBool loadingPaginationData = false.obs;
    RxBool isSearching = false.obs;
    RxBool isloading = false.obs;
    isloading.value = true;
    getList(
      endpoint: endpoint,
      setDefaultData: setDefaultData,
      filter: filter,
      searchText: searchText.value,
    ).then((value) {
      setDefaultData = value;
      isloading.value = false;
    });
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        tableScrollController.addListener(() async {
          if (tableScrollController.position.atEdge) {
            bool isTop = tableScrollController.position.pixels == 0;

            if (isTop) {
              devPrint('🍺 At the top');
            } else {
              devPrint('🍺 At the bottom');
              devPrint(setDefaultData.nextPage);
              if (setDefaultData.nextPage == 1) {
                setDefaultData.pageNo.value = setDefaultData.pageNo.value + 1;
                if (!loadingPaginationData.value) {
                  loadingPaginationData.value = true;
                  setDefaultData = await getList(appendData: true, setDefaultData: setDefaultData, endpoint: endpoint, filter: filter, searchText: searchText.value);
                  loadingPaginationData.value = false;
                }
              }
            }
          }
        });
      }
    }
    await CustomDialogs().customPopDialog(child: ResponsiveBuilder(builder: (context, sizingInformation) {
      return Container(
        alignment: Alignment.centerRight,
        color: ColorTheme.kWhite,
        width: 1200,
        child: Column(
          children: [
            Container(
              height: sizingInformation.isMobile ? null : 90,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorTheme.kBorderColor,
                    width: 0.5,
                  ),
                ),
              ),
              padding: EdgeInsets.all(sizingInformation.isMobile ? 12 : 24),
              child: Center(
                child: Obx(() {
                  return Row(
                    children: [
                      if (!isSearching.value || !sizingInformation.isMobile)
                        Expanded(
                          child: TextWidget(
                            text: title,
                            fontWeight: FontWeight.w500,
                            color: ColorTheme.kPrimaryColor,
                            textOverflow: TextOverflow.ellipsis,
                            fontSize: 18,
                          ),
                        )
                      else
                        Expanded(
                          child: SearchBox(
                            txtSearch: searchController,
                            focusNode: searchFocusNode1,
                            onSearch: (p1) async {
                              isloading.value = true;
                              searchText.value = p1;
                              if (p1.isNullOrEmpty) {
                                isSearching.value = false;
                              }
                              searchController.text = p1;
                              setDefaultData.pageNo.value = 1;
                              setDefaultData = await getList(setDefaultData: setDefaultData, endpoint: endpoint, filter: filter, searchText: searchText.value);
                              isloading.value = false;
                            },
                            onChanged: (p0) {
                              searchText.value = p0;
                            },
                            isSearching: searchText.value.isNotNullOrEmpty,
                          ),
                        ),
                      Obx(() {
                        return Visibility(
                          visible: !isSearching.value && sizingInformation.isMobile,
                          child: CustomButton(
                            onTap: () async {
                              isSearching.value = true;
                              searchFocusNode1.requestFocus();
                            },
                            borderRadius: 4,
                            width: 10,
                            height: sizingInformation.isMobile ? 36 : 40,
                            circularProgressColor: ColorTheme.kBlack,
                            widget: const Icon(
                              Icons.search_rounded,
                            ),
                            fontColor: ColorTheme.kBlack,
                            buttonColor: ColorTheme.kBackGroundGrey,
                          ),
                        );
                      }),
                      Visibility(
                        visible: !sizingInformation.isMobile,
                        child: SearchBox(
                          txtSearch: searchController,
                          onSearch: (p1) async {
                            isloading.value = true;
                            searchText.value = p1;
                            if (p1.isNullOrEmpty) {
                              isSearching.value = false;
                            }
                            searchController.text = p1;
                            setDefaultData.pageNo.value = 1;
                            setDefaultData = await getList(setDefaultData: setDefaultData, endpoint: endpoint, filter: filter, searchText: searchText.value);
                            isloading.value = false;
                          },
                          onChanged: (p0) {
                            searchText.value = p0;
                          },
                          isSearching: searchText.value.isNotNullOrEmpty,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      CustomButton(
                        onTap: () async {
                          FormDataModel defaultData = FormDataModel.fromJson(setDefaultData.toJson());
                          defaultData.pageLimit = defaultData.contentLength;
                          defaultData = await getList(setDefaultData: defaultData, endpoint: endpoint, filter: filter, searchText: searchText.value);
                          final excel = Excel.createExcel();
                          String pagename = title;

                          final sheet = excel[title];
                          excel.setDefaultSheet(title);
                          excel.delete('Sheet1');
                          var boldStyle = CellStyle(
                            bold: true,
                            fontSize: 18,
                          );
                          sheet.appendRow([
                            TextCellValue(
                                '$title ${filter['filterduration'] == 0 ? '(${filter['fromdate'].toString().toDateFormat()} - ${filter['todate'].toString().toDateFormat()})' : getDateRange(filter['filterduration'])}')
                          ]);
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: sheet.maxRows - 1)).cellStyle = boldStyle;
                          sheet.appendRow(defaultData.fieldOrder.map((e) => TextCellValue(e['text'] ?? '')).toList());
                          for (int i = 0; i < defaultData.fieldOrder.length; i++) {
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: sheet.maxRows - 1)).cellStyle = CellStyle(
                              bold: true,
                            );
                          }

                          for (Map<String, dynamic> tenant in defaultData.data) {
                            sheet.appendRow(defaultData.fieldOrder.map((e) {
                              if (e['field'] == 'statusdate') {
                                return TextCellValue((tenant["${tenant['tenantstatusid'] ?? ""}_date"] ?? '').toString().toDateFormat());
                              }
                              if (tenant[e['field'] ?? ''] is List) {
                                return TextCellValue(((tenant[e['field'] ?? ''] ?? []).join(', ')).toString());
                              }
                              return TextCellValue((tenant[e['field'] ?? ''] ?? '').toString().toDateFormat());
                            }).toList());
                          }

                          for (int i = 0; i < defaultData.fieldOrder.length; i++) {
                            sheet.setColumnAutoFit(i);
                          }

                          if (kIsWeb) {
                            excel.save(fileName: '$pagename-${DateTime.now()}.xlsx');
                          } else {
                            Permission.manageExternalStorage.request();

                            var fileBytes = excel.save();
                            var directory = Platform.isAndroid ? await getDownloadsDirectory() : await getApplicationDocumentsDirectory();
                            devPrint(directory?.path);
                            File savedFile = File('${directory?.path}/$pagename-${DateTime.now()}.xlsx');
                            await savedFile.writeAsBytes(fileBytes!);
                            OpenFile.open(savedFile.path);
                          }
                        },
                        borderRadius: 4,
                        width: 10,
                        height: sizingInformation.isMobile ? 36 : 40,
                        circularProgressColor: ColorTheme.kBlack,
                        widget: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              AssetsString.kExport,
                              colorFilter: const ColorFilter.mode(ColorTheme.kBlack, BlendMode.srcIn),
                            ),
                            if (!sizingInformation.isMobile) ...[
                              const SizedBox(
                                width: 4,
                              ),
                              const TextWidget(
                                text: StringConst.kExportBtnTxt,
                                fontSize: 13,
                                fontWeight: FontTheme.notoSemiBold,
                                color: ColorTheme.kBlack,
                              ),
                            ]
                          ],
                        ),
                        fontColor: ColorTheme.kBlack,
                        buttonColor: ColorTheme.kBackGroundGrey,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: 36,
                          height: 36,
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
                  );
                }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(sizingInformation.isMobile ? 0 : 24.0),
                child: Container(
                  decoration: sizingInformation.isMobile
                      ? null
                      : BoxDecoration(
                          border: Border.all(
                            color: ColorTheme.kBorderColor,
                          ),
                          color: ColorTheme.kWhite,
                        ),
                  child: Obx(() {
                    return CommonDataTableWidget(
                      width: sizingInformation.isDesktop ? 1150 : MediaQuery.sizeOf(context).width - 66,
                      data: setDefaultData.data.value,
                      fieldOrder: setDefaultData.fieldOrder.value,
                      setDefaultData: setDefaultData,
                      isLoading: isloading.value,
                      onRefresh: () async {
                        setDefaultData.pageNo.value = 1;
                        loadingPaginationData.value = false;
                        isloading.value = true;
                        setDefaultData = await getList(
                          endpoint: endpoint,
                          setDefaultData: setDefaultData,
                          filter: filter,
                          searchText: searchText.value,
                        );
                        isloading.value = false;
                      },
                      onSort: (sortFieldName) async {
                        if (setDefaultData.sortData.containsKey(sortFieldName)) {
                          if (setDefaultData.sortData[sortFieldName] == -1) {
                            setDefaultData.sortData.remove(sortFieldName);
                          } else {
                            setDefaultData.sortData[sortFieldName] = setDefaultData.sortData[sortFieldName] == 1 ? -1 : 1;
                          }
                        } else {
                          setDefaultData.sortData.clear();
                          setDefaultData.sortData[sortFieldName] = 1;
                        }
                        setDefaultData.pageNo.value = 1;
                        isloading.value = true;
                        setDefaultData = await getList(
                          endpoint: endpoint,
                          setDefaultData: setDefaultData,
                          filter: filter,
                          searchText: searchText.value,
                        );
                        isloading.value = false;
                      },
                      onPageChange: (pageNo, pageLimit) {
                        setDefaultData.pageNo.value = pageNo;
                        setDefaultData.pageLimit = pageLimit;
                        isloading.value = true;
                        getList(setDefaultData: setDefaultData, endpoint: endpoint, searchText: searchText.value, filter: filter);
                        isloading.value = false;
                      },
                      tableScrollController: tableScrollController,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    }));
  }

  String getDateRange(int? value) {
    DateTime now = DateTime.now();
    switch (value) {
      case 1: // All
        return '';
      case 2: // Today
        return '(${DateFormat("dd MMM yyyy").format(now)})';
      case 3: // Yesterday
        DateTime yesterday = now.subtract(const Duration(days: 1));
        return '(${DateFormat("dd MMM yyyy").format(yesterday)})';
      case 4: // Last 7 Days
        DateTime lastWeek = now.subtract(const Duration(days: 7));
        DateTime yesterday = now.subtract(const Duration(days: 1));
        return '(${DateFormat("dd MMM yyyy").format(lastWeek)} - ${DateFormat("dd MMM yyyy").format(yesterday)})';
      case 5: // Last Month
        DateTime lastMonthStart = DateTime(now.year, now.month - 1, 1);
        DateTime lastMonthEnd = DateTime(now.year, now.month, 0);
        return '(${DateFormat("dd MMM yyyy").format(lastMonthStart)} - ${DateFormat("dd MMM yyyy").format(lastMonthEnd)})';
      case 0: // Custom
        return 'Custom';
      default:
        return '';
    }
  }
}
