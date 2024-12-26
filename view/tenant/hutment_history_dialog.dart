import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/row_column_widget.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_common_widgets.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../config/helper/device_service.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';

class HutmentHistoryDialog extends StatelessWidget {
  final Map data;

  final List rentDetails;

  const HutmentHistoryDialog({super.key, required this.data, required this.rentDetails});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: RowColumnWidget(
                  grouptype: sizingInformation.isDesktop ? GroupType.row : GroupType.column,
                  children: [
                    expandedRowColumn(
                      sizingInformation.isDesktop,
                      Column(
                        children: [
                          rentPaymentRow(title: 'Hutment No : ', value: (data["hutmentno"]).toString().toDateFormat()),
                          rentPaymentRow(title: 'Annex No : ', value: (data["annexno"]).toString().toDateFormat()),
                          rentPaymentRow(title: 'SRA Card No : ', value: (data['sracardno']).toString().toDateFormat()),
                          rentPaymentRow(title: 'Year of Structure : ', value: (data['yearofstructure']).toString().toDateFormat()),
                        ],
                      ),
                    ),
                    sizingInformation.isDesktop ? const VerticalDivider() : const Divider(),
                    expandedRowColumn(
                      sizingInformation.isDesktop,
                      Column(
                        children: [
                          rentPaymentRow(title: 'Fom 3/4 : ', value: (data["form3_4"]).toString().toDateFormat()),
                          rentPaymentRow(title: 'Current Voting List Serial No : ', value: (data['serialno']).toString().toDateFormat()),
                          rentPaymentRow(title: 'Voting List Part : ', value: (data['votinglistpart']).toString().toDateFormat()),
                          rentPaymentRow(title: 'Voter Serial Part (2000/2011) : ', value: (data['votinglistpart']).toString().toDateFormat()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              IntrinsicHeight(
                child: RowColumnWidget(
                  grouptype: sizingInformation.isDesktop ? GroupType.row : GroupType.column,
                  children: [
                    expandedRowColumn(
                      sizingInformation.isDesktop,
                      Column(
                        children: [
                          rentPaymentRow(title: 'Cluster Name : ', value: (data['clustername']).toString().toDateFormat()),
                          data["${data['tenantstatus'] ?? ""}_date"].toString().isNullOrEmpty
                              ? rentPaymentRow(title: 'Hutment Status : ', value: (data['tenantstatus']).toString().toDateFormat())
                              : rentPaymentRow(title: 'Hutment Status : ', value: "${data['tenantstatus'].toString().toDateFormat()} ( ${data["${data['tenantstatus'] ?? ""}_date"].toString().toDateFormat()} )"),
                          rentPaymentRow(title: 'Hutment Use : ', value: (data['hutmentusetypename']).toString().toDateFormat()),
                          if (data.containsKey("ownbyname") && data['ownbyname'].toString().isNotNullOrEmpty) rentPaymentRow(title: 'Own By : ', value: (data['ownbyname']).toString().toDateFormat()),
                          rentPaymentRow(title: 'Structure Detail : ', value: (data['structuredetail']).toString().toDateFormat()),
                        ],
                      ),
                    ),
                    sizingInformation.isDesktop ? const VerticalDivider() : const Divider(),
                    expandedRowColumn(
                      sizingInformation.isDesktop,
                      Column(
                        children: [
                          rentPaymentRow(title: 'House Tax No : ', value: (data['housetax']).toString().toDateFormat()),
                          rentPaymentRow(title: 'Water Connection : ', value: (data["watertaxbill"]).toString().toDateFormat()),
                          rentPaymentRow(title: 'Electric Bill No : ', value: (data['elecricitybill']).toString().toDateFormat()),
                          rentPaymentRow(title: 'Measurement : ', value: (data['measurement']).toString().toDateFormat()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              RowColumnWidget(
                grouptype: sizingInformation.isDesktop ? GroupType.row : GroupType.column,
                children: [
                  if ((data["internalimages"]).toString().isNullOrEmpty || (data["internalimages"]).length > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: TextWidget(
                            text: "Internal Photos",
                            fontSize: 14,
                            fontWeight: FontTheme.notoSemiBold,
                          ),
                        ),
                        DottedBorder(
                          borderType: BorderType.Rect,
                          color: ColorTheme.kBorderColor,
                          dashPattern: const [8, 8, 1, 1],
                          child: Container(
                            height: 180,
                            width: !sizingInformation.isDesktop ? null : Get.width / 2.6,
                            color: ColorTheme.kWhite,
                            child: GridView.builder(
                              itemCount: (data["internalimages"]).length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    documentDownload(imageList: FilesDataModel.fromJson(data["internalimages"]?[index] ?? {}));
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kBorderColor, width: 1)),
                                      height: 32,
                                      width: 32,
                                      child: Image.network(
                                        FilesDataModel.fromJson(data["internalimages"]?[index]).url ?? '',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return SvgPicture.asset(
                                            AssetsString.kUser,
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      )),
                                );
                              },
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                            ),
                          ),
                        )
                      ],
                    ),
                  const SizedBox(
                    width: 16,
                  ),
                  if ((data["externalimages"]).toString().isNullOrEmpty || (data["externalimages"]).length > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4.0),
                          child: TextWidget(
                            text: "External Photos",
                            fontSize: 14,
                            fontWeight: FontTheme.notoSemiBold,
                          ),
                        ),
                        DottedBorder(
                          borderType: BorderType.Rect,
                          color: ColorTheme.kBorderColor,
                          dashPattern: const [8, 8, 1, 1],
                          child: Container(
                            height: 180,
                            width: !sizingInformation.isDesktop ? null : Get.width / 2.6,
                            color: ColorTheme.kWhite,
                            child: GridView.builder(
                              itemCount: (data["externalimages"]).length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    documentDownload(imageList: FilesDataModel.fromJson(data["externalimages"]?[index] ?? {}));
                                  },
                                  child: Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kBorderColor, width: 1)),
                                      height: 32,
                                      width: 32,
                                      child: Image.network(
                                        FilesDataModel.fromJson(data["externalimages"]?[index]).url ?? '',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return SvgPicture.asset(
                                            AssetsString.kUser,
                                            fit: BoxFit.contain,
                                          );
                                        },
                                      )),
                                );
                              },
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),
              if (rentDetails.isNotNullOrEmpty) ...[
                const TextWidget(
                  text: "Rent Details",
                  fontSize: 16,
                  fontWeight: FontTheme.notoSemiBold,
                ).paddingSymmetric(vertical: 8),
                MasonryGridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: sizingInformation.isDesktop ? 2 : 1,
                  ),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  itemCount: (rentDetails).length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var rent = rentDetails[index];
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
                        child: RowColumnWidget(
                          grouptype: !sizingInformation.isMobile ? GroupType.row : GroupType.column,
                          children: [
                            expandedRowColumn(
                              !sizingInformation.isMobile,
                              Container(
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
                            !sizingInformation.isMobile ? const VerticalDivider() : const Divider(),
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
                ).paddingOnly(bottom: 12)
              ]
            ],
          ),
        );
      },
    );
  }

  Widget rentPaymentRow({
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: TextWidget(
            text: title.toString().toDateFormat().toUpperCase(),
            color: ColorTheme.kBlack,
            fontWeight: FontTheme.notoSemiBold,
            textOverflow: TextOverflow.visible,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: TextWidget(
            text: value.toString().toUpperCase(),
            color: ColorTheme.kPrimaryColor,
            textOverflow: TextOverflow.visible,
            fontWeight: FontTheme.notoRegular,
            fontSize: 12,
          ),
        ),
      ],
    ).paddingOnly(bottom: 4);
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
        ).paddingOnly(left: 12, right: 4),
      ],
    );
  }
}
