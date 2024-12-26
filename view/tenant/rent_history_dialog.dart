import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';

class RentHistoryDialog extends StatelessWidget {
  final List data;

  const RentHistoryDialog({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: ColorTheme.kWhite,
      backgroundColor: ColorTheme.kWhite,
      alignment: Alignment.topRight,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        width: 500,
        color: ColorTheme.kWhite,
        height: Get.height,
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) => SizedBox(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      text: "Payment History",
                      fontSize: 16,
                      textAlign: TextAlign.left,
                      color: ColorTheme.kBlack,
                      fontWeight: FontTheme.notoSemiBold,
                    ).paddingOnly(left: 4, bottom: 4),
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
                ),
                const SizedBox(height: 12),
                data.isNullOrEmpty
                    ? const NoDataFoundScreen()
                    : Expanded(
                        child: ListView.separated(
                          itemCount: (data).length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 16);
                          },
                          itemBuilder: (context, index) {
                            var rent = data[index];
                            return IntrinsicHeight(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: ColorTheme.kWhite,
                                  border: Border.all(
                                    color: ColorTheme.kBorderColor,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                color: ColorTheme.kWhite,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if ((rent['paymenttypename']).toString().isNotNullOrEmpty) ...[
                                                    TextWidget(
                                                      text: (rent['paymenttypename'] ?? '').toString().toUpperCase(),
                                                      color: ColorTheme.kPrimaryColor,
                                                      fontWeight: FontTheme.notoSemiBold,
                                                      fontSize: 12,
                                                    ),
                                                    const Divider(),
                                                  ],

                                                  slotPaymentRow(title: rent['paymenttypefrequency'] == 2 ? 'Start Date' : 'Date', value: (rent['startdate'] ?? '-')),
                                                  if (rent['paymenttypefrequency'] == 2) slotPaymentRow(title: 'End Date', value: (rent['enddate'] ?? '-')),
                                                  const Divider(),
                                                  if (rent['rentinmonth'].toString().isNotNullOrEmpty || rent['noofmonths'].toString().isNotNullOrEmpty) ...[
                                                    Row(children: [
                                                      CustomTooltip(
                                                        message: 'Rent per Month'.toUpperCase(),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color: ColorTheme.kBackgroundColor,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          padding: const EdgeInsets.all(4),
                                                          child: SvgPicture.asset(
                                                            AssetsString.kCalender,
                                                            height: 15,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      TextWidget(
                                                        text: '${(rent['rentinmonth'] ?? '').toString().toAmount()} * ${(rent['noofmonths'] ?? '')}M',
                                                        color: ColorTheme.kPrimaryColor,
                                                        fontWeight: FontTheme.notoRegular,
                                                        fontSize: 12,
                                                      ),
                                                    ]),
                                                    const SizedBox(height: 8)
                                                  ],
                                                  TextWidget(
                                                    text: (rent['totalrent'] ?? '').toString().toAmount(),
                                                    color: ColorTheme.kPrimaryColor,
                                                    fontWeight: FontTheme.notoSemiBold,
                                                    fontSize: 12,
                                                  ),
                                                  Visibility(
                                                    visible: rent['shiftingcharge'].toString().isNotNullOrEmpty,
                                                    child: const Divider(),
                                                  ),
                                                  Visibility(
                                                    visible: rent['shiftingcharge'].toString().isNotNullOrEmpty,
                                                    child: Row(
                                                      children: [
                                                        CustomTooltip(
                                                          message: 'SHIFTING CHARGES',
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                              color: ColorTheme.kBackgroundColor,
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            padding: const EdgeInsets.all(4),
                                                            child: SvgPicture.asset(
                                                              AssetsString.kLoadingTruck,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        TextWidget(
                                                          text: (rent['shiftingcharge'] ?? '').toString().toAmount(),
                                                          color: ColorTheme.kPrimaryColor,
                                                          fontWeight: FontTheme.notoRegular,
                                                          fontSize: 12,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                    const VerticalDivider(),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: ColorTheme.kWhite,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            slotPaymentRow(title: 'Request Slot', value: (rent['requestslotname'] ?? "-")),
                                            const SizedBox(height: 8),
                                            slotPaymentRow(title: 'Rent received', value: (rent['rentreceiveddate'] ?? '-')),
                                            const Divider(),
                                            slotPaymentRow(title: '${rent['paymentinstrumentname'] ?? 'Payment'} No.', value: (rent['paymentno'] ?? '-')),
                                            const SizedBox(height: 8),
                                            slotPaymentRow(title: '${rent['paymentinstrumentname'] ?? 'Payment'} Date', value: (rent['paymentdate'] ?? '-')),
                                            const SizedBox(height: 8),
                                            slotPaymentRow(title: '${rent['paymentinstrumentname'] ?? 'Payment'} Received at site', value: (rent['paymentreceivedsitedate'] ?? '-')),
                                            const SizedBox(height: 8),
                                            slotPaymentRow(title: '${rent['paymentinstrumentname'] ?? 'Payment'} HANDOVER DATE', value: (rent['paymenthandoverdate'] ?? '-')),
                                          ],
                                        ).paddingOnly(right: 4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                if (sizingInformation.isDesktop && data.isNotNullOrEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        title: 'Close',
                        buttonColor: ColorTheme.kBlack,
                        fontColor: ColorTheme.kWhite,
                        showBoxBorder: true,
                        height: 34,
                        width: 80,
                        borderRadius: 5,
                        onTap: () {
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ).paddingAll(20),
        ),
      ),
    );
  }

  Widget slotPaymentRow({
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
