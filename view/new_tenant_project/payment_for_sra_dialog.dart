import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/row_column_widget.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_common_widgets.dart';
import '../../style/theme_const.dart';

class PaymentForSraDialog extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String title;

  const PaymentForSraDialog({super.key, required this.data, required this.title});

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
            width: sizingInformation.isMobile ? null : 650,
            child: Column(
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextWidget(
                        text: title,
                        fontSize: 16,
                        textAlign: TextAlign.left,
                        color: ColorTheme.kBlack,
                        fontWeight: FontTheme.notoSemiBold,
                      ).paddingOnly(left: 4),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
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
                const Divider(),
                data.isNullOrEmpty
                    ? const NoDataFoundScreen()
                    : Expanded(
                        child: ListView.separated(
                          itemCount: data.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 8);
                          },
                          itemBuilder: (context, index) {
                            return IntrinsicHeight(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: ColorTheme.kWhite,
                                  border: Border.all(
                                    color: ColorTheme.kBorderColor,
                                  ),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: ColorTheme.kWhite,
                                  ),
                                  padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text: (data[index]['tenantname'] ?? '').toString().toUpperCase(),
                                        color: ColorTheme.kPrimaryColor,
                                        fontWeight: FontTheme.notoSemiBold,
                                        fontSize: 12,
                                      ),
                                      const Divider(),
                                      ...List.generate(
                                        data[index]['requestslots'].length,
                                        (slotIndex) {
                                          jsonPrint(tag: "454154152416532415", data[index]['requestslots']);
                                          var slotNo = data[index]['requestslots'];
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6),
                                              color: ColorTheme.kWhite,
                                              border: Border.all(
                                                color: ColorTheme.kBorderColor,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: (slotNo[slotIndex]['requestslotname'] ?? '').toString().toUpperCase(),
                                                  color: ColorTheme.kPrimaryColor,
                                                  fontWeight: FontTheme.notoSemiBold,
                                                  fontSize: 12,
                                                ),
                                                const Divider(),
                                                ...List.generate(
                                                  (slotNo[slotIndex]['payments']).length,
                                                  (amountIndex) {
                                                    var rent = slotNo[slotIndex]['payments'][amountIndex];
                                                    return Container(
                                                      decoration: sizingInformation.isMobile
                                                          ? BoxDecoration(
                                                              borderRadius: BorderRadius.circular(4),
                                                              color: ColorTheme.kWhite,
                                                              border: Border.all(
                                                                color: ColorTheme.kBorderColor,
                                                              ),
                                                            )
                                                          : null,
                                                      padding: sizingInformation.isMobile ? const EdgeInsets.all(4) : null,
                                                      child: Column(
                                                        children: [
                                                          IntrinsicHeight(
                                                            child: RowColumnWidget(
                                                              grouptype: sizingInformation.isMobile ? GroupType.column : GroupType.row,
                                                              children: [
                                                                expandedRowColumn(
                                                                    sizingInformation.isDesktop,
                                                                    TextWidget(
                                                                      fontSize: 12,
                                                                      text: rent['paymenttypename'],
                                                                    )),
                                                                sizingInformation.isMobile ? const Divider() : const VerticalDivider(),
                                                                expandedRowColumn(
                                                                    sizingInformation.isDesktop,
                                                                    Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                      children: [
                                                                        paymentRow(title: rent['paymenttypefrequency'] == 2 ? 'Start Date' : 'Date', value: (rent['startdate'] ?? '-')),
                                                                        if (rent['paymenttypefrequency'] == 2) paymentRow(title: 'End Date', value: (rent['enddate'] ?? '-')),
                                                                      ],
                                                                    )),
                                                                sizingInformation.isMobile ? const Divider() : const VerticalDivider(),
                                                                expandedRowColumn(
                                                                    sizingInformation.isDesktop,
                                                                    RowColumnWidget(
                                                                      grouptype: sizingInformation.isMobile ? GroupType.row : GroupType.column,
                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                      children: [
                                                                        if (rent['paymenttypefrequency'] == 2)
                                                                          TextWidget(
                                                                            fontSize: 12,
                                                                            text: '${(rent['rentinmonth'] ?? '').toString().toAmount()} * ${(rent['noofmonths'] ?? '')}M',
                                                                            color: ColorTheme.kPrimaryColor,
                                                                            fontWeight: FontTheme.notoRegular,
                                                                            textAlign: TextAlign.right,
                                                                          ),
                                                                        if (sizingInformation.isMobile) const Spacer(),
                                                                        TextWidget(
                                                                          fontSize: 12,
                                                                          text: rent['totalrent'].toString().isNotNullOrEmpty ? rent['totalrent'].toString().toAmount() : '-',
                                                                          textAlign: TextAlign.right,
                                                                          fontWeight: FontTheme.notoBold,
                                                                        ),
                                                                      ],
                                                                    )),
                                                              ],
                                                            ).paddingAll(2),
                                                          ),
                                                          if ((slotNo[slotIndex]['payments']).length - 1 > index) const Divider(),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ).paddingOnly(bottom: 4);
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget paymentRow({
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextWidget(
            text: title.toString().toDateFormat().toUpperCase(),
            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
            fontWeight: FontTheme.notoSemiBold,
            textOverflow: TextOverflow.visible,
            fontSize: 10,
          ),
        ),
        TextWidget(
          text: value.toString().toDateFormat().toUpperCase(),
          color: ColorTheme.kPrimaryColor,
          fontWeight: FontTheme.notoSemiBold,
          textOverflow: TextOverflow.visible,
          fontSize: 10,
        ).paddingOnly(left: 12),
      ],
    );
  }
}
