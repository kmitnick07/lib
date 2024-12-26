import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/forms/tenants_master_form.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/helper/offline_data.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/tenant_master_controller.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../controller/layout_templete_controller.dart';
import '../../models/form_data_model.dart';
import '../CommonWidgets/common_header_footer.dart';
import '../CommonWidgets/common_table.dart';
import '../no_data_found_screen.dart';

class OfflineTenantsMasterView extends StatefulWidget {
  const OfflineTenantsMasterView({super.key, this.pageName});

  final String? pageName;

  @override
  State<OfflineTenantsMasterView> createState() => _OfflineTenantsMasterViewState();
}

class _OfflineTenantsMasterViewState extends State<OfflineTenantsMasterView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.kScaffoldColor,
        body: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            return GetBuilder(
              init: Get.put(TenantMasterController()),
              builder: (controller) {
                return Scaffold(
                    appBar: AppBar(
                      title: const TextWidget(
                        text: "Offline Tenants",
                        color: ColorTheme.kWhite,
                      ),
                      centerTitle: true,
                    ),
                    floatingActionButton: isoffline.value
                        ? FloatingActionButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onPressed: () async {
                              showBottomBar.value = false;
                              controller.setFormData();
                              await Get.dialog(barrierDismissible: false, TenantsMasterForm());
                              showBottomBar.value = true;
                              controller.setFilterData();
                              controller.setDefaultData.filterData.removeNullValues();
                            },
                            backgroundColor: ColorTheme.kBlack,
                            child: const Icon(
                              Icons.add,
                              color: ColorTheme.kWhite,
                            ),
                          ).paddingOnly(bottom: 4, right: 8)
                        : null,
                    body: Settings.offlineTenantDataList.isNullOrEmpty
                        ? const NoDataFoundScreen()
                        : Column(
                            children: [
                              syncNowView(),
                              Expanded(
                                child: CommonDataTableWidget(
                                    setDefaultData: FormDataModel(),
                                    hideInfo: true,
                                    editDataFun: (id, index) async {
                                      showBottomBar.value = false;
                                      controller.setFormData(id: id, editeDataIndex: index, isOfflineData: true);
                                      await Get.dialog(
                                        barrierDismissible: false,
                                        TenantsMasterForm(
                                          oldData: Settings.offlineTenantDataList[index],
                                        ),
                                      );
                                      showBottomBar.value = true;
                                      controller.setDefaultData.filterData.removeNullValues();
                                    },
                                    fieldOrder: const [
                                      {"field": "", "text": "Action", "type": "menu", "freeze": 1, "active": 1, "sorttable": 0, "filter": 0, "defaultvalue": "", "tblsize": 7},
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
                                      {
                                        "field": "surveyno",
                                        "text": "Survey No",
                                        "type": "text",
                                        "freeze": 1,
                                        "active": 1,
                                        "sorttable": 0,
                                        "filter": 1,
                                        "defaultvalue": 0,
                                        "tblsize": 10
                                      },
                                      {
                                        "field": "hutmentno",
                                        "text": "Hutment No",
                                        "type": "text",
                                        "freeze": 1,
                                        "active": 1,
                                        "sorttable": 0,
                                        "filter": 1,
                                        "defaultvalue": 0,
                                        "tblsize": 10
                                      },
                                      {
                                        "field": "tenantfirstname",
                                        "text": "Tenant First Name",
                                        "type": "text",
                                        "freeze": 1,
                                        "active": 1,
                                        "sorttable": 0,
                                        "filter": 1,
                                        "defaultvalue": 0,
                                        "tblsize": 20
                                      },
                                      {
                                        "field": "tenantlastname",
                                        "text": "Tenant Last Name",
                                        "type": "text",
                                        "freeze": 1,
                                        "active": 1,
                                        "sorttable": 0,
                                        "filter": 1,
                                        "defaultvalue": 0,
                                        "tblsize": 20
                                      },
                                    ],
                                    deleteDataFun: (id, index) {
                                      try {
                                        List collection = [];
                                        collection.addAll(Settings.offlineTenantDataList);
                                        devPrint(collection.length);
                                        collection.removeAt(index);
                                        Settings.offlineTenantDataList.clear();
                                        Settings.offlineTenantDataList = collection;
                                        Get.back();
                                        Get.back();
                                        setState(() {});
                                      } catch (e) {
                                        devPrint("object" + e.toString());
                                      }
                                    },
                                    data: Settings.offlineTenantDataList,
                                    tableScrollController: ScrollController()),
                              ),
                            ],
                          ));
              },
            );
          },
        ));
  }
}
