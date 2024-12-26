import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/forms/filter_form.dart';
import '../../controller/SAPTenantHistory/sap_tenant_history_controller.dart';

class SapTenantHistory extends StatelessWidget {
  const SapTenantHistory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.kScaffoldColor,
        body: GetBuilder(
          init: Get.put(SapTenantHistoryController()),
          builder: (controller) {
            return ResponsiveBuilder(builder: (context, sizingInformation) {
              return CommonHeaderFooter(
                title: controller.formName.value,
                txtSearchController: controller.searchController,
                filterData: controller.setDefaultData.filterData,
                onFilterInHeaderChange: () {
                  controller.getList();
                },
                onTapFilter: () async {
                  controller.setFilterData();
                  await CustomDialogs().customFilterDialogs(
                      context: context,
                      widget: FilterForm(
                        title: "Filter",
                        btnName: "Apply",
                        setDefaultData: controller.setDefaultData,
                        onFilterApply: () {
                          controller.getList();
                        },
                        onResetFilter: () {
                          controller.setFilterData();
                        },
                      ));
                },
                showFilterInHeader: true,
                setDefaultData: controller.setDefaultData,
                child: Obx(() {
                  return CommonDataTableWidget(
                    isLoading: controller.loadingData.value,
                    setDefaultData: controller.setDefaultData,
                    fieldOrder: controller.setDefaultData.fieldOrder.value,
                    data: controller.setDefaultData.data.value,
                    tableScrollController: ScrollController(),
                    onSort: (sortFieldName) {
                      if (controller.setDefaultData.sortData.containsKey(sortFieldName)) {
                        controller.setDefaultData.sortData[sortFieldName] = controller.setDefaultData.sortData[sortFieldName] == 1 ? -1 : 1;
                      } else {
                        controller.setDefaultData.sortData.clear();
                        controller.setDefaultData.sortData[sortFieldName] = 1;
                      }
                      controller.getList();
                    },
                    onPageChange: (pageNo, pageLimit) {
                      controller.searchText.value = controller.searchController.text;
                      controller.setDefaultData.pageNo.value = pageNo;
                      controller.setDefaultData.pageLimit = pageLimit;
                      controller.getList();
                    },
                  );
                }),
              );
            });
          },
        ));
  }
}
