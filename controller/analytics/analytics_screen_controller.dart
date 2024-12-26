import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/text_widget.dart';
import '../../config/dev/dev_helper.dart';
import '../../style/theme_const.dart';

class AnalyticsScreenController extends GetxController {
  RxList<Map<String, dynamic>> tenantProject = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> consentLocalityList = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> consentReport = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> eligibilityReport = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> tatReport = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> statusCountReport = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> rentPaymentReport = <Map<String, dynamic>>[].obs;
  RxString commonTenantProject = ''.obs;
  RxString consentTenantProject = ''.obs;
  RxString eligibilityTenantProject = ''.obs;
  RxString tatTenantProject = ''.obs;
  RxString statusCountProject = ''.obs;
  RxString rentPaymentTenantProject = ''.obs;
  RxString consentSelectedLocality = ''.obs;

  @override
  Future<void> onInit() async {
    await getTenantProject();
    await getHutmentStatusReport();
    await getConsentReport();
    await getEligibilityReport();
    await getTurnAroundTimeReport();
    await getRentPaymentReport();

    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<AnalyticsScreenController>();
    super.dispose();
  }

  getTenantProject() async {
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": {}, "projection": {}, "sort": {}}
    };
    tenantProject.value =
        List<Map<String, dynamic>>.from((await IISMethods().listData(userAction: 'listtenantproject', pageName: 'analytics', url: '${Config.weburl}tenantproject', reqBody: reqBody))['data']);
    if (tenantProject.value.isNotNullOrEmpty) {
      consentTenantProject.value = tenantProject.first['_id'];
      consentLocalityList.value = List<Map<String, dynamic>>.from(tenantProject.first['locality'] ?? []);
      eligibilityTenantProject.value = tenantProject.first['_id'];
      tatTenantProject.value = tenantProject.first['_id'];
      rentPaymentTenantProject.value = tenantProject.first['_id'];
      statusCountProject.value = tenantProject.first['_id'];
    }
  }

  getHutmentStatusReport() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 10,
        "filter": {
          "tenantprojectid": statusCountProject.value,
        },
        "sort": {}
      },
      "searchtext": ""
    };
    statusCountReport.value = List<Map<String, dynamic>>.from(
        (await IISMethods().listData(userAction: 'listtenantstatusreport', pageName: 'analytics', url: '${Config.weburl}hutmentstatusreport', reqBody: reqBody))['data']);
  }

  getConsentReport() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 10,
        "filter": {
          "tenantprojectid": consentTenantProject.value,
          "localityid": consentSelectedLocality.value,
        },
        "sort": {}
      },
      "searchtext": ""
    };
    consentReport.value =
        Map<String, dynamic>.from((await IISMethods().listData(userAction: 'listconsentreport', pageName: 'analytics', url: '${Config.weburl}consentreport', reqBody: reqBody))['data']);
  }

  getEligibilityReport() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 10,
        "filter": {
          "tenantprojectid": eligibilityTenantProject.value,
        },
        "sort": {}
      },
      "searchtext": ""
    };
    eligibilityReport.value =
        List<Map<String, dynamic>>.from((await IISMethods().listData(userAction: 'listeligibilityreport', pageName: 'analytics', url: '${Config.weburl}eligibilityreport', reqBody: reqBody))['data'])
            .where((element) => element['result'] > 0)
            .toList();
  }

  getTurnAroundTimeReport() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 10,
        "filter": {
          "tenantprojectid": tatTenantProject.value,
        },
        "sort": {}
      },
      "searchtext": ""
    };
    tatReport.value = List<Map<String, dynamic>>.from((await IISMethods().listData(userAction: 'listtatreport', pageName: 'analytics', url: '${Config.weburl}tatreport', reqBody: reqBody))['data']);
  }

  getRentPaymentReport() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 10,
        "filter": {
          "tenantprojectid": rentPaymentTenantProject.value,
        },
        "sort": {}
      },
      "searchtext": ""
    };
    rentPaymentReport.value = List<Map<String, dynamic>>.from(
            (await IISMethods().listData(userAction: 'listrentpaymentstatusreport', pageName: 'analytics', url: '${Config.weburl}rentpaymentstatusreport', reqBody: reqBody))['data'])
        .where((element) => element['result'] > 0)
        .toList();
  }

  getTenantList({
    required Map<String, dynamic> filter,
    required String endpoint,
    required String title,
  }) async {
    return;
    RxList<Map<String, dynamic>> data = <Map<String, dynamic>>[].obs;
    String searchText = '';
    FormDataModel setDefaultData = FormDataModel();
    ScrollController tableScrollController = ScrollController();
    RxBool loadingPaginationData = true.obs;
    RxBool isloading = false.obs;
    isloading.value = true;
    setDefaultData = await getList(
      endpoint: endpoint,
      setDefaultData: setDefaultData,
      filter: filter,
      searchText: searchText,
    );
    isloading.value = false;
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
                if (loadingPaginationData.value) {
                  loadingPaginationData.value = true;
                  setDefaultData = await getList(appendData: true, setDefaultData: setDefaultData, endpoint: endpoint, filter: filter, searchText: searchText);
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
        width: 800,
        child: Column(
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
                    Expanded(
                      child: TextWidget(
                        text: title,
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.kPrimaryColor,
                        textOverflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      ),
                    ),
                    InkWell(
                      onTap: () {
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
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorTheme.kBorderColor,
                    ),
                    color: ColorTheme.kWhite,
                  ),
                  child: Obx(() {
                    return CommonDataTableWidget(
                      width: sizingInformation.isDesktop ? 734 : MediaQuery.sizeOf(context).width - 66,
                      data: setDefaultData.data.value,
                      fieldOrder: const [
                        {
                          "field": "tenantname",
                          "text": "Tenant Name",
                          "type": "text",
                          "freeze": 1,
                          "active": 1,
                          "sorttable": 1,
                          "sortby": "tenantname",
                          "filter": 0,
                          "filterfieldtype": "dropdown",
                          "defaultvalue": "",
                          "tblsize": 1.5,
                        },
                        {
                          "field": "hutmentno",
                          "text": "Hutment no.",
                          "type": "text",
                          "freeze": 1,
                          "active": 1,
                          "sorttable": 1,
                          "sortby": "hutmentno",
                          "filter": 0,
                          "filterfieldtype": "lookup",
                          "defaultvalue": "",
                          "tblsize": 1,
                        },
                      ],
                      setDefaultData: setDefaultData,
                      isLoading: isloading.value,
                      onRefresh: () async {
                        setDefaultData.pageNo.value = 1;
                        isloading.value = true;
                        setDefaultData = await getList(
                          endpoint: endpoint,
                          setDefaultData: setDefaultData,
                          filter: filter,
                          searchText: searchText,
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
                          searchText: searchText,
                        );
                        isloading.value = false;
                      },
                      onPageChange: (pageNo, pageLimit) {
                        setDefaultData.pageNo.value = pageNo;
                        setDefaultData.pageLimit = pageLimit;
                        isloading.value = true;
                        getList(setDefaultData: setDefaultData, endpoint: endpoint, searchText: searchText, filter: filter);
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

    var resBody = await IISMethods().listData(userAction: 'listrentpaymentstatusreport', pageName: 'analytics', url: '${Config.weburl}$endpoint', reqBody: reqBody);
    if (appendData ?? false) {
      setDefaultData.data.value.addAll(List<Map<String, dynamic>>.from(resBody['data']));
      setDefaultData.data.refresh();
    } else {
      setDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data']);
    }
    setDefaultData.nextPage = resBody['nextpage'];
    // setDefaultData.pageName = resBody['pagename'];
    setDefaultData.contentLength = resBody['totaldocs'] ?? 0;
    setDefaultData.noOfPages.value = (setDefaultData.contentLength / setDefaultData.pageLimit).ceil();
    return setDefaultData;
  }
}
