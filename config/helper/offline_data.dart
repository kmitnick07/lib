import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/dashboard/dashboard_controller.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:uuid/uuid.dart';
import '../../components/customs/text_widget.dart';
import '../../components/json/tenants_sra_json.dart';
import '../../models/form_data_model.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../config.dart';
import '../iis_method.dart';

RxBool isoffline = false.obs;
RxBool isUploading = false.obs;

class Offline {
  setData() async {
    // store dropdown data
    try {
      var reqBody = {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5,
          "filter": {"hidedata": 1},
          "sort": {}
        }
      };
      Settings.offlineFieldDataList = await IISMethods().listData(url: '${Config.weburl}tenant', reqBody: reqBody, userAction: "listtenant", pageName: "tenant");
      Map dialogBoxData = TenantsSRAJson.designationFormFields("tenant");
      Map offlineDataList = {};
      for (var i = 0; i < dialogBoxData["tabs"].length; i++) {
        for (var j = 0; j < dialogBoxData["tabs"][i]["formfields"].length; j++) {
          for (var k = 0; k < dialogBoxData["tabs"][i]["formfields"][j]["formFields"].length; k++) {
            Map fieldObj = dialogBoxData["tabs"][i]["formfields"][j]["formFields"][k];
            List masterdataarray = fieldObj["masterdataarray"] ?? [];
            bool masterdatadependancy = !(fieldObj["masterdatadependancy"] ?? false);
            if (masterdatadependancy && masterdataarray.isNullOrEmpty && (fieldObj['type'] == HtmlControls.kDropDown || fieldObj['type'] == HtmlControls.kMultiSelectDropDown)) {
              Map res = await getMasterData(
                pageNo: 1,
                fieldObj: fieldObj,
                pageName: 'tenant',
              );
              List data = res['data'] ?? [];
              offlineDataList[fieldObj["field"]] = data;
              List onchangefill = fieldObj['onchangefill'] ?? [];
              if (onchangefill.isNotNullOrEmpty && data.isNotNullOrEmpty) {
                for (var l = 0; l < onchangefill.length; l++) {
                  var obj2 = getObjectFromFormData(dialogBoxData["tabs"], onchangefill[l]);
                  Map dataList = {};
                  for (var item in data) {
                    var res = await getMasterData(pageNo: 1, fieldObj: obj2, pageName: 'tenant', filter: {fieldObj["field"]: item['_id']});
                    dataList[item['_id']] = res['data'] ?? [];
                  }
                  offlineDataList[obj2["field"]] = dataList;
                }
              }
            }
          }
        }
      }
      Settings.offlineDropdownDataList = offlineDataList;
    } catch (e) {
      devPrint(e);
    }
    // store field order and dynamic form
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

  Future<Map> getMasterData({
    required int pageNo,
    required Map fieldObj,
    Map filter = const {},
    String pageName = '',
  }) async {
    try {
      if (fieldObj['staticfilter'] != null) {
        filter = {...filter, ...fieldObj['staticfilter']};
      }
      var projection = {};
      if (fieldObj["projection"] != null) {
        projection = {...fieldObj["projection"]};
      }
      var url = Config.weburl + fieldObj["masterdata"];
      var userAction = 'list${fieldObj["masterdata"]}data';
      var reqBody = {
        "paginationinfo": {"pageno": pageNo, "pagelimit": 500000000000, "filter": filter, "projection": projection, "sort": {}}
      };
      devPrint(reqBody);
      return await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName, masterlisting: true);
    } catch (err) {
      devPrint(err.toString());
      return {};
    }
  }

  Future<Map> uploadOfflineDocs(data) async {
    Map dialogBoxData = TenantsSRAJson.designationFormFields("tenant");
    List doc = [HtmlControls.kFilePicker, HtmlControls.kImagePicker, HtmlControls.kAvatarPicker, HtmlControls.kMultipleImagePicker];
    for (var i = 0; i < dialogBoxData["tabs"].length; i++) {
      for (var j = 0; j < dialogBoxData["tabs"][i]["formfields"].length; j++) {
        for (var k = 0; k < dialogBoxData["tabs"][i]["formfields"][j]["formFields"].length; k++) {
          Map fieldObj = dialogBoxData["tabs"][i]["formfields"][j]["formFields"][k];
          if (doc.contains(fieldObj['type'])) {
            if (data.containsKey(fieldObj["field"]) && data[fieldObj["field"]] != null) {
              if (data[fieldObj["field"]] is List) {
                List<FilesDataModel> value = [];
                for (var i = 0; i < data[fieldObj["field"]].length; i++) {
                  value.add(FilesDataModel.fromJson(data[fieldObj["field"]][i]));
                }
                if (value.isNotNullOrEmpty) {
                  value = await IISMethods().uploadFiles(value);
                  data[fieldObj["field"]] = value;
                }
              } else {
                var value = data[fieldObj["field"]];
                if (value['name'].toString().isNotNullOrEmpty) {
                  value = await IISMethods().uploadFiles([FilesDataModel.fromJson(value)]);
                  data[fieldObj["field"]] = value[0];
                  devPrint("$value  11112222222");
                }
              }
            }
          }
        }
      }
    }
    return data;
  }

  syncTenantsData() async {
    isUploading.value = true;
    try {
      List collection = [];
      for (Map element in Settings.offlineTenantDataList) {
        element.removeWhere((key, value) => key == "_id");
        collection.add(await uploadOfflineDocs(element));
      }
      var reqData = {"tenants": collection};
      var url = '${Config.weburl}tenant/bulk';
      var userAction = "addtenant";
      var resBody = await IISMethods().addData(url: url, reqBody: reqData, userAction: userAction, pageName: "tenant");
      isUploading.value = false;
      RxList listData = [].obs;
      if (resBody['status'] == 200) {
        for (var i = 0; i < ((resBody['data']['skippedrecords'] ?? []) as List).length; i++) {
          resBody['data']['skippedrecords'][i]['_id'] = const Uuid().v4();
        }
        Settings.offlineTenantDataList = (resBody['data']['skippedrecords'] ?? []) as List;

        listData.value = resBody['data']['datainsertarray'] ?? [];
        RxInt selectedTab = 0.obs;
        await Get.dialog(
          barrierDismissible: true,
          ResponsiveBuilder(builder: (context, sizingInformation) {
            selectedTab.value = 0;
            List<Map<String, dynamic>> tabs = [
              {
                'name': 'Added Records',
                'key': 'datainsertarray',
              },
              // {
              //   'name': 'Updated Records',
              //   'key': 'alradyexistArray',
              // },
              {
                'name': 'Skipped Records',
                'key': 'skippedrecords',
              },
            ];
            return Dialog(
              shadowColor: ColorTheme.kBlack,
              backgroundColor: ColorTheme.kWhite,
              surfaceTintColor: ColorTheme.kWhite,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
              ),
              insetPadding: sizingInformation.isMobile ? EdgeInsets.zero : const EdgeInsets.all(12),
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.78),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: ColorTheme.kBorderColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TextWidget(
                            text: 'Summary',
                            fontSize: 16,
                            fontWeight: FontTheme.notoSemiBold,
                            color: ColorTheme.kPrimaryColor,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorTheme.kBlack.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              splashColor: ColorTheme.kWhite,
                              hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                              splashRadius: 20,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close),
                            ).paddingAll(2),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 36,
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        selectedTab.value = index;
                                        listData.value = resBody['data'][tabs[index]['key']] ?? [];
                                        listData.refresh();
                                      },
                                      child: Obx(() {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: tabs[index]['key'] == 'skippedrecords' && selectedTab.value == index
                                                ? ColorTheme.kErrorColor
                                                : selectedTab.value == index
                                                    ? ColorTheme.kBlack
                                                    : ColorTheme.kBackGroundGrey,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          margin: EdgeInsets.only(left: index == 0 ? 8 : 0, right: (index + 1) == tabs.length ? 8 : 0),
                                          padding: const EdgeInsets.only(left: 8, right: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              TextWidget(
                                                text: tabs[index]['name'],
                                                fontWeight: FontTheme.notoSemiBold,
                                                color: selectedTab.value == index
                                                    ? ColorTheme.kWhite
                                                    : tabs[index]['key'] == 'skippedrecords'
                                                        ? ColorTheme.kErrorColor
                                                        : ColorTheme.kBlack,
                                              ),
                                              const SizedBox(width: 4),
                                              CircleAvatar(
                                                backgroundColor: selectedTab.value == index
                                                    ? ColorTheme.kWhite
                                                    : tabs[index]['key'] == 'skippedrecords'
                                                        ? ColorTheme.kErrorColor
                                                        : ColorTheme.kBlack,
                                                radius: 12,
                                                child: Center(
                                                  child: TextWidget(
                                                    text: ((resBody['data'][tabs[index]['key']] ?? []) as List).length,
                                                    color: tabs[index]['key'] == 'skippedrecords' && selectedTab.value == index
                                                        ? ColorTheme.kErrorColor
                                                        : selectedTab.value == index
                                                            ? ColorTheme.kBlack
                                                            : ColorTheme.kWhite,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(width: 8);
                                  },
                                  itemCount: tabs.length),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Expanded(
                              child: Obx(() {
                                return listData.isNullOrEmpty
                                    ? const NoDataFoundScreen()
                                    : CommonDataTableWidget(
                                        setDefaultData: FormDataModel(),
                                        fieldOrder: [
                                          // {"field": "", "text": "Action", "type": "menu", "freeze": 1, "active": 1, "sorttable": 0, "filter": 0, "defaultvalue": "", "tblsize": 7},
                                          if (selectedTab.value == 1)
                                            {
                                              "field": "message",
                                              "text": "Error",
                                              "type": "text",
                                              "freeze": 1,
                                              "active": 1,
                                              "sorttable": 0,
                                              "filter": 1,
                                              "defaultvalue": 0,
                                              "tblsize": 20
                                            },
                                          const {
                                            "field": "surveyno",
                                            "text": "Survey No",
                                            "type": "text",
                                            "freeze": 1,
                                            "active": 1,
                                            "sorttable": 0,
                                            "filter": 1,
                                            "defaultvalue": 0,
                                            "tblsize": 15
                                          },
                                          const {
                                            "field": "hutmentno",
                                            "text": "Hutment No",
                                            "type": "text",
                                            "freeze": 1,
                                            "active": 1,
                                            "sorttable": 0,
                                            "filter": 1,
                                            "defaultvalue": 0,
                                            "tblsize": 15
                                          },
                                          const {
                                            "field": "fullname",
                                            "text": "Tenant Name",
                                            "type": "text",
                                            "freeze": 1,
                                            "active": 1,
                                            "sorttable": 0,
                                            "filter": 1,
                                            "defaultvalue": 0,
                                            "tblsize": 20
                                          },
                                        ],
                                        data: listData.value,
                                        tableScrollController: ScrollController());
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      } else {
        showError(resBody["message"] ?? "");
      }
    } catch (e) {
      devPrint(e.toString());
    }
  }
}

getConnectivity() async {
  try {
    InternetConnectionChecker().onStatusChange.listen((InternetConnectionStatus status) {
      if (status == InternetConnectionStatus.disconnected) {
        if (Settings.isUserLogin && !isoffline.value) {
          try {
            isUploading.value = false;
            isoffline.value = true;
            Future.delayed(const Duration(seconds: 1)).then((value) {
              navigateTo(RouteNames.kDashboard);
            });
          } catch (e) {
            devPrint(e);
          }
        }
      } else {
        if (Settings.isUserLogin && isoffline.value) {
          isoffline.value = false;
          Get.find<DashBoardController>().onInitl();
          navigateTo(RouteNames.kDashboard);
        }
      }
    });
  } catch (e) {
    isUploading.value = true;
    devPrint(e);
  }
}
