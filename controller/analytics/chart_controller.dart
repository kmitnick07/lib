import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

import '../../components/customs/custom_date_picker.dart';
import '../../config/config.dart';
import '../../config/iis_method.dart';
import '../../style/theme_const.dart';

class ChartController extends GetxController {
  RxBool isProjectStatusLoading = false.obs;
  RxBool isProjectDataLoading = false.obs;
  RxBool isRentDataLoading = false.obs;
  RxString projectStatusString = 'All'.obs;
  RxString projectString = 'All'.obs;
  RxString rentDetailsString = 'All'.obs;
  RxString projectStatusFilterString = 'All'.obs;
  RxString projectFilterString = 'All'.obs;
  RxString rentDetailsFilterString = 'All'.obs;
  RxString tenantprojectid = ''.obs;
  RxMap<String, dynamic> rentDetails = <String, dynamic>{}.obs;

  RxList<Map<String, dynamic>> rentDetailsList = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> projectStatusData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> apiProjectData = <String, dynamic>{}.obs;
  RxMap<String, dynamic> apiRentData = <String, dynamic>{}.obs;
  RxMap<String, num> projectData = <String, num>{}.obs;
  RxMap<String, num> rentData = <String, num>{}.obs;

  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    fetchProjectStatusData();
    fetchProjectData();
    fetchRentDataList();
    super.onInit();
  }

  @override
  void dispose() {
    Get.delete<ChartController>();
    super.dispose();
  }

  final List<Color> seriesColors = [
    ColorTheme.kGraphPurpleColor,
    ColorTheme.kGraphGreenColor,
    ColorTheme.kGraphYellowColor,
    ColorTheme.kGraphPurpleColor,
    ColorTheme.kGraphGreenColor,
    ColorTheme.kGraphYellowColor,
    ColorTheme.kGraphPurpleColor,
  ];

  void fetchTodayData({int? flag}) {
    final today = dateConvertIntoUTC(DateTime.now());
    if (flag == 1) {
      fetchProjectStatusData(startDate: today, endDate: today);
      projectStatusString.value = 'Today';
    }
    if (flag == 2) {
      fetchProjectData(startDate: today, endDate: today);
      projectString.value = 'Today';
    }
    if (flag == 3) {
      fetchRentData(id: tenantprojectid.value, startDate: today, endDate: today);
      rentDetailsString.value = 'Today';
    }
  }

  void fetchAllData({int? flag}) {
    if (flag == 1) {
      fetchProjectStatusData(startDate: "", endDate: "");
      projectStatusString.value = 'All';
    }
    if (flag == 2) {
      fetchProjectData(startDate: '', endDate: '');
      projectString.value = 'All';
    }
    if (flag == 3) {
      fetchRentData(id: tenantprojectid.value, startDate: '', endDate: '');
      rentDetailsString.value = 'All';
    }
  }

  void fetchLast7DaysData({int? flag, bool allDataShow = false}) {
    final today = DateTime.now();
    final lastWeek = dateConvertIntoUTC(today.subtract(const Duration(days: 7)));
    final todayStr = dateConvertIntoUTC(today);

    if (flag == 1 || allDataShow) {
      fetchProjectStatusData(startDate: lastWeek, endDate: todayStr);
      projectStatusString.value = "Last 7 Days";
    }
    if (flag == 2 || allDataShow) {
      fetchProjectData(startDate: lastWeek, endDate: todayStr);
      projectString.value = "Last 7 Days";
    }
    if (flag == 3 || allDataShow) {
      fetchRentData(id: tenantprojectid.value, startDate: lastWeek, endDate: todayStr);
      rentDetailsString.value = "Last 7 Days";
    }
  }

  void fetchLastMonthData({int? flag}) {
    final today = DateTime.now();
    final lastMonth = dateConvertIntoUTC(DateTime(today.year, today.month - 1, today.day));
    final todayStr = dateConvertIntoUTC(today);

    if (flag == 1) {
      fetchProjectStatusData(startDate: lastMonth, endDate: todayStr);
      projectStatusString.value = "Last Month";
    }
    if (flag == 2) {
      fetchProjectData(startDate: lastMonth, endDate: todayStr);
      projectString.value = "Last Month";
    }
    if (flag == 3) {
      fetchRentData(id: tenantprojectid.value, startDate: lastMonth, endDate: todayStr);
      rentDetailsString.value = "Last Month";
    }
  }

  Future<void> fetchProjectStatusData({String? startDate, String? endDate}) async {
    isProjectStatusLoading.value = true;
    projectStatusData.value = {
      "charttitle": "title",
      "data": [
        {"name   ": "0", "    ": 400},
        {"name   ": "1", "    ": 150},
        {"name   ": "2", "    ": 300},
        {"name   ": "3", "    ": 75},
        {"name   ": "4", "    ": 450},
        {"name   ": "5", "    ": 300},
        {"name   ": "6", "    ": 600},
      ]
    };
    var res = await IISMethods().listData(
      userAction: "listchart",
      pageName: "charts",
      url: "${Config.weburl}chart/tenantstatus",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"startdate": startDate ?? "", "enddate": endDate ?? ""},
          "projection": {},
          "sort": {},
        },
      },
    );
    if (res['status'] == 200) {
      projectStatusData.clear();
      projectStatusData.value = res["data"] ?? [];
      projectStatusData.refresh();
    }

    isProjectStatusLoading.value = false;
  }

  Future<void> fetchProjectData({String? startDate, String? endDate}) async {
    isProjectDataLoading.value = true;
    projectData.value = {
      "   ": 250,
      "    ": 600,
      "     ": 100,
      "      ": 150,
    };
    var res = await IISMethods().listData(
      userAction: "listchart",
      pageName: "charts",
      url: "${Config.weburl}chart/developersproject",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"startdate": startDate ?? "", "enddate": endDate ?? ""},
          "projection": {},
          "sort": {}
        },
      },
    );
    if (res['status'] == 200) {
      projectData.clear();
      apiProjectData.value = res["data"];
      final keysToRemove = ['charttitle', '_id'];

      for (var entry in apiProjectData.entries) {
        if (!keysToRemove.contains(entry.key)) {
          projectData[entry.key] = entry.value.toDouble();
        }
      }
      projectData.refresh();
    }

    isProjectDataLoading.value = false;
  }

  Future<void> fetchRentDataList() async {
    var res = await IISMethods().listData(
      userAction: "listtenantproject",
      pageName: "tenantproject",
      url: "${Config.weburl}tenantproject",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 9999999999990,
          "filter": {},
          "projection": {},
          "sort": {},
        },
      },
    );
    if (res['status'] == 200) {
      rentDetailsList.value = List<Map<String, dynamic>>.from((res["data"].map((e) {
                return {'value': e['_id'], 'label': e['name']};
              }) ??
              [])
          .toList());
      rentDetails.value = rentDetailsList.first;
      tenantprojectid.value = rentDetails['value'];
      fetchRentData(id: tenantprojectid.value);
    }
  }

  Future<void> fetchRentData({String? id, String? startDate, String? endDate}) async {
    isRentDataLoading.value = true;
    rentData.value = {
      " ": 250,
      "  ": 600,
      "   ": 100,
      "    ": 150,
    };
    var res = await IISMethods().listData(
      userAction: "listchart",
      pageName: "charts",
      url: "${Config.weburl}chart/rentofproject",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 999999999990,
          "filter": {"tenantprojectid": id, "startdate": startDate ?? "", "enddate": endDate ?? ""},
          "projection": {},
          "sort": {}
        },
      },
    );
    if (res['status'] == 200) {
      rentData.clear();
      apiRentData.value = res["data"];
      final keysToRemove = ['charttitle', '_id'];

      for (var entry in apiRentData.entries) {
        if (!keysToRemove.contains(entry.key)) {
          String newKey = entry.key.replaceAll('_', ' ');
          rentData[newKey] = entry.value.toDouble();
        }
      }
      rentData.refresh();
    }
    isRentDataLoading.value = false;
  }
}
