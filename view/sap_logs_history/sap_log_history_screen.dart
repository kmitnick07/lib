import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_tooltip.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/controller/sap_log_history_controller/sap_log_history_controller.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SapLogHistoryScreen extends StatelessWidget {
  const SapLogHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder(
        init: Get.put(SapLogHistoryController()),
        builder: (controller) {
          return ResponsiveBuilder(builder: (context, sizingInformation) {
            return CommonHeaderFooter(
              title: 'SAP LOG History',
              txtSearchController: controller.searchTextController,
              onSearch: (p0) {
                controller.searchText = p0;
                controller.getList();
              },
              headerWidgets: IconButton(
                onPressed: () {
                  controller.getList();
                },
                icon: const CustomTooltip(
                  message: 'Refresh Data',
                  child: Icon(
                    Icons.refresh_rounded,
                  ),
                ),
              ),
              hasSearch: true,
              child: Obx(() {
                return CommonDataTableWidget(
                  isLoading: controller.loadingData.value,
                  setDefaultData: controller.setDefaultData,
                  fieldOrder: controller.setDefaultData.fieldOrder,
                  handleGridChange: (index, field, type, value, masterfieldname ,name) {
                    devPrint(index);
                    controller.handleGridChange(index: index, field: field, type: type);
                  },
                  onRefresh: () async {
                    await controller.getList();
                  },
                  data: controller.setDefaultData.data.value,
                  tableScrollController: ScrollController(),
                  onPageChange: (pageNo, pageLimit) {
                    controller.setDefaultData.pageNo.value = pageNo;
                    controller.setDefaultData.pageLimit = pageLimit;
                    controller.getList();
                  },
                );
              }),
            );
          });
        },
      ),
    );
  }
}
