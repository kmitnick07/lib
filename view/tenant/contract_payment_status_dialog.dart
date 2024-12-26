import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../models/form_data_model.dart';
import '../../style/theme_const.dart';
import '../CommonWidgets/common_table.dart';

class ContractDetails extends StatelessWidget {
  final RxList<Map<String, dynamic>> fieldOrder;
  final RxList<Map<String, dynamic>> data;
  final RxBool isLoading;
  final FormDataModel setDefaultData;

  const ContractDetails({super.key, required this.fieldOrder, required this.data, required this.isLoading, required this.setDefaultData});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Dialog(
          surfaceTintColor: ColorTheme.kWhite,
          backgroundColor: ColorTheme.kWhite,
          alignment: Alignment.topRight,
          insetPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: SizedBox(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      text: "Contract Payment Status",
                      fontSize: 16,
                      textAlign: TextAlign.left,
                      color: ColorTheme.kBlack,
                      fontWeight: FontTheme.notoSemiBold,
                    ).paddingOnly(left: 4),
                    Container(
                      padding: EdgeInsets.zero,
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
                        icon: const Icon(Icons.clear_rounded),
                      ),
                    ),
                  ],
                ).paddingAll(20),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    return CommonDataTableWidget(setDefaultData: setDefaultData, width: Get.width, showPagination: false, isLoading: isLoading.value, fieldOrder: fieldOrder, data: data, tableScrollController: null);
                  }),
                ),
                if (!sizingInformation.isMobile)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        title: 'Close',
                        buttonColor: ColorTheme.kBackGroundGrey,
                        fontColor: ColorTheme.kPrimaryColor,
                        // showBoxBorder: true,
                        height: 34,
                        width: 80,
                        borderRadius: 5,
                        onTap: () {
                          Get.back();
                        },
                      ),
                    ],
                  ).paddingAll(20),
              ],
            ),
          ),
        );
      },
    );
  }
}
