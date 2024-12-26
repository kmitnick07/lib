import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../models/form_data_model.dart';
import '../../style/theme_const.dart';
import '../CommonWidgets/common_table.dart';

class SapContractHistoryDialog extends StatelessWidget {
  final String titleName;
  final RxList<Map<String, dynamic>> sapContractHistoryList;
  final RxList<Map<String, dynamic>> sapContractHistoryFieldOrderList;
  final RxBool isSapContractHistoryLoading;
  final FormDataModel setDefaultData;

  const SapContractHistoryDialog({super.key, required this.titleName, required this.sapContractHistoryList, required this.sapContractHistoryFieldOrderList, required this.isSapContractHistoryLoading, required this.setDefaultData});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: titleName,
              fontSize: 20,
              fontWeight: FontTheme.notoBold,
            ).paddingOnly(bottom: 12, left: 12, top: 12),
            Obx(() {
              return Expanded(
                child: CommonDataTableWidget(
                  setDefaultData: setDefaultData,
                  showPagination: false,
                  fieldOrder: sapContractHistoryFieldOrderList.value,
                  data: sapContractHistoryList.value,
                  isLoading: isSapContractHistoryLoading.value,
                  tableScrollController: ScrollController(),
                ),
              );
            })
          ],
        );
      },
    );
  }
}
