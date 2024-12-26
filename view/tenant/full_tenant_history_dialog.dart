// import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/controller/tenant_master_controller.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:prestige_prenew_frontend/view/tenant/document_dialog.dart';
import 'package:prestige_prenew_frontend/view/tenant/hutment_history_dialog.dart';
import 'package:prestige_prenew_frontend/view/tenant/sap_contract_history_dialog.dart';
import 'package:prestige_prenew_frontend/view/tenant/status_history_dialog.dart';
import 'package:prestige_prenew_frontend/view/tenant/tenant_history_dialog.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../components/customs/custom_common_widgets.dart';
import '../../components/customs/custom_dialogs.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../components/customs/row_column_widget.dart';
import '../../config/helper/device_service.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';

class FullTenantHistoryDialog extends StatelessWidget {
  final Map data;
  RxInt headerIndex = 0.obs;
  final RxMap ownerHistory;
  final RxString formName;
  final RxList sapHistoryList;
  final RxList<Map<String, dynamic>> sapContractHistoryList;
  final RxList<Map<String, dynamic>> sapContractHistoryFieldOrderList;
  final FormDataModel setDefaultData;
  final RxBool isSapContractHistoryLoading;
  List<String> headers = ["Hutment Detail", "Tenant Detail", "Document", "SAP Status", "Contract History"];

  FullTenantHistoryDialog({
    super.key,
    required this.data,
    required this.ownerHistory,
    required this.sapHistoryList,
    required this.sapContractHistoryList,
    required this.sapContractHistoryFieldOrderList,
    required this.isSapContractHistoryLoading,
    required this.setDefaultData,
    required this.formName,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) => Container(
        color: ColorTheme.kWhite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextWidget(
                  text: "Tenant 360 Details",
                  fontSize: 20,
                  color: ColorTheme.kBlack,
                  fontWeight: FontTheme.notoSemiBold,
                ),
                Row(
                  children: [
                    if (sizingInformation.isDesktop) buildColumn(data: data).paddingOnly(right: 20),
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
              ],
            ).paddingOnly(bottom: sizingInformation.isMobile ? 0 : 16),
            if (!sizingInformation.isDesktop) ...[
              buildColumn(data: data, fontSize: 10),
            ],
            sizingInformation.isMobile ? const Divider() : const SizedBox.shrink(),
            Expanded(
              child: Container(
                clipBehavior: sizingInformation.isMobile ? Clip.none : Clip.hardEdge,
                decoration: sizingInformation.isMobile ? const BoxDecoration() : BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(width: 1.5, color: ColorTheme.kTableHeader)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: sizingInformation.isMobile ? 4 : 24, left: sizingInformation.isMobile ? 2 : 24, right: sizingInformation.isMobile ? 2 : 24),
                        child: IntrinsicHeight(
                          child: RowColumnWidget(
                            grouptype: sizingInformation.isDesktop ? GroupType.row : GroupType.column,
                            children: [
                              expandedRowColumn(
                                sizingInformation.isDesktop,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              sizingInformation.isDesktop
                                                  ? Container(
                                                      padding: const EdgeInsets.all(8),
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(
                                                          color: ColorTheme.kBorderColor.withOpacity(0.5),
                                                          width: 1.5,
                                                        ),
                                                      ),
                                                      child: Image.network(
                                                        FilesDataModel.fromJson(data['tenantownerphoto']).url ?? "",
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return SvgPicture.asset(
                                                            AssetsString.kUser,
                                                            height: 60,
                                                          );
                                                        },
                                                      ),
                                                    ).paddingOnly(right: 8)
                                                  : const SizedBox.shrink(),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    rentPaymentRow(title: 'Tenant Project Name : ', value: (data["tenantprojectname"]).toString().toDateFormat()),
                                                    rentPaymentRow(title: 'Vendor Code : ', value: (data["SAP_vendorcode"]).toString().toDateFormat()),
                                                    rentPaymentRow(title: 'Tenant Name : ', value: "${(data["fullname"]).toString().toDateFormat()} ( ${(data["vendorcode"]).toString().toDateFormat()} )"),
                                                    rentPaymentRow(title: 'Contact No. : ', value: (((data['tenantcontactno'] ?? '') as List?)?.join(', ')).toString().toDateFormat()),
                                                    InkWell(
                                                        onTap: () {
                                                          sendEmail(email: data["tenantemail"] ?? '');
                                                        },
                                                        child: rentPaymentRow(title: 'E-mail : ', value: (data["tenantemail"]).toString().toDateFormat())),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    !sizingInformation.isDesktop
                                        ? Container(
                                            padding: const EdgeInsets.all(8),
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: ColorTheme.kBorderColor.withOpacity(0.5),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Image.network(
                                              FilesDataModel.fromJson(data['tenantownerphoto']).url ?? "",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return SvgPicture.asset(
                                                  AssetsString.kUser,
                                                  height: 60,
                                                );
                                              },
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              ),
                              sizingInformation.isDesktop ? const VerticalDivider() : const Divider(),
                              expandedRowColumn(
                                sizingInformation.isDesktop,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          rentPaymentRow(title: 'Survey No : ', value: (data['surveyno']).toString().toDateFormat()),
                                          rentPaymentRow(title: 'Non-Survey Structure : ', value: (data["xpartname"]).toString().toDateFormat()),
                                          rentPaymentRow(title: 'Eligibility : ', value: (data['eligibilityname']).toString().toDateFormat()),
                                          rentPaymentRow(title: 'Society : ', value: (data['societyname']).toString().toDateFormat()),
                                          rentPaymentRow(title: 'Hutment No (SAP) : ', value: (data["SAP_hutmentno"]).toString().toDateFormat()),
                                        ],
                                      ),
                                    ),
                                    !sizingInformation.isDesktop
                                        ? Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: ColorTheme.kWhite,
                                            ),
                                            child: CustomTooltip(
                                              message: 'Status History',
                                              textAlign: TextAlign.center,
                                              child: InkWell(
                                                  onTap: () async {
                                                    CustomDialogs().customPopDialog(
                                                        child: StatusHistoryDialog(
                                                      data: data,
                                                      statusList: Get.find<TenantMasterController>().setDefaultData.masterDataList['tenantstatus'] ?? [],
                                                    ));
                                                  },
                                                  child: SvgPicture.asset(AssetsString.kCalender)),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              ),
                              sizingInformation.isDesktop
                                  ? Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: ColorTheme.kWhite,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: CustomTooltip(
                                        message: 'Status History',
                                        textAlign: TextAlign.center,
                                        child: InkWell(
                                            onTap: () async {
                                              CustomDialogs().customPopDialog(
                                                  child: StatusHistoryDialog(
                                                data: data,
                                                statusList: Get.find<TenantMasterController>().setDefaultData.masterDataList['tenantstatus'] ?? [],
                                              ));
                                            },
                                            child: SvgPicture.asset(AssetsString.kCalender)),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ).paddingOnly(bottom: 20, left: 4, right: 8),
                      ),
                      Obx(() {
                        return singleChildScrollViewRow(
                          isScrollable: Get.width <= 1000,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              for (int index = 0; index < headers.length; index++)
                                expandedRowColumn(
                                  Get.width > 1000,
                                  InkWell(
                                    onTap: () {
                                      headerIndex.value = index;
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: (sizingInformation.isMobile && (index == 0 || index == headers.length - 1)) ? 0 : 8.0),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: Get.width <= 1000 ? Get.width * 0.028 : 0, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: index == headerIndex.value ? ColorTheme.kBlack : ColorTheme.kBackGroundGrey,
                                          // border: index != 0 ? const Border(left: BorderSide(color: Colors.white, width: 1)) : null,
                                        ),
                                        child: TextWidget(
                                          text: headers[index],
                                          color: index != headerIndex.value ? ColorTheme.kPrimaryColor /*.withOpacity(0.8)*/ : Colors.white,
                                          fontSize: 16,
                                          textAlign: TextAlign.center,
                                          fontWeight: FontTheme.notoSemiBold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                      Obx(() {
                        return getContentForIndex(tabNumber: headerIndex.value + 1);
                      }),
                    ],
                  ),
                ),
              ),
            )
          ],
        ).paddingAll(sizingInformation.isMobile ? 8 : 20),
      ),
    );
  }

  Row buildColumn({
    double? fontSize = 12,
    required Map<dynamic, dynamic> data,
    Color? titleTextColor = ColorTheme.kBlack,
    FontWeight? titleTextWeight = FontTheme.notoRegular,
    Color? valueTextColor = ColorTheme.kBlack,
    FontWeight? valueTextWeight = FontTheme.notoRegular,
  }) {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (((data["recordinfo"]?["entryby"]).toString().isNotNullOrEmpty) /* && ((data["recordinfo"]?["updateby"]).toString().isNullOrEmpty)*/) ...[
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Entry by: ",
                      style: TextStyle(
                        color: titleTextColor,
                        fontSize: fontSize,
                        fontWeight: titleTextWeight,
                      ),
                    ),
                    TextSpan(
                      text: (data["recordinfo"]?["entryby"] ?? "").toString(),
                      style: TextStyle(
                        color: valueTextColor,
                        fontSize: fontSize,
                        fontWeight: valueTextWeight,
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Entry Date: ",
                      style: TextStyle(
                        color: titleTextColor,
                        fontSize: fontSize,
                        fontWeight: titleTextWeight,
                      ),
                    ),
                    TextSpan(
                      text: data["recordinfo"]?["entrydate"].toString().toDateTimeFormat(),
                      style: TextStyle(
                        color: valueTextColor,
                        fontSize: fontSize,
                        fontWeight: valueTextWeight,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
        const SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if ((data["recordinfo"]?["updateby"]).toString().isNotNullOrEmpty) ...[
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Update by: ",
                      style: TextStyle(
                        color: titleTextColor,
                        fontSize: fontSize,
                        fontWeight: titleTextWeight,
                      ),
                    ),
                    TextSpan(
                      text: (data["recordinfo"]?["updateby"] ?? "").toString(),
                      style: TextStyle(
                        color: valueTextColor,
                        fontSize: fontSize,
                        fontWeight: valueTextWeight,
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Update Date: ",
                      style: TextStyle(
                        color: titleTextColor,
                        fontSize: fontSize,
                        fontWeight: titleTextWeight,
                      ),
                    ),
                    TextSpan(
                      text: data["recordinfo"]?["updatedate"].toString().toDateTimeFormat(),
                      style: TextStyle(
                        color: valueTextColor,
                        fontSize: fontSize,
                        fontWeight: valueTextWeight,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ],
    );
  }

  getContentForIndex({required int tabNumber}) {
    List rentDetails = data['rentdetails'];
    switch (tabNumber) {
      case 1:
        return ResponsiveBuilder(builder: (BuildContext context, SizingInformation sizingInformation) {
          return HutmentHistoryDialog(data: data, rentDetails: rentDetails).paddingOnly(top: 24, right: sizingInformation.isMobile ? 4 : 24, left: sizingInformation.isMobile ? 4 : 24);
        });
      case 2:
        return ResponsiveBuilder(builder: (BuildContext context, SizingInformation sizingInformation) {
          jsonPrint(tag: " 452468548654615341", data);
          return TenantHistoryDialog(
            ownerHistory: ownerHistory,
            rentdetailsdata: data['rentdetails'],
            data: data,
          ).paddingOnly(top: 24, right: sizingInformation.isMobile ? 4 : 24, left: sizingInformation.isMobile ? 4 : 24);
        });
      case 3:
        return ResponsiveBuilder(builder: (BuildContext context, SizingInformation sizingInformation) {
          return DocumentDialog(data: data, formName: formName.value).paddingOnly(top: 24, right: sizingInformation.isMobile ? 4 : 24, left: sizingInformation.isMobile ? 4 : 24);
        });
      case 4:
        if (sapHistoryList.isNullOrEmpty) {
          return const NoDataFoundScreen();
        } else {
          return ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return SizedBox(
                width: MediaQuery.sizeOf(Get.context!).width,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: sapHistoryList.length,
                  itemBuilder: (context, index) {
                    return TimelineTile(
                      isFirst: index == 0,
                      isLast: index == sapHistoryList.length - 1,
                      alignment: TimelineAlign.start,
                      beforeLineStyle: const LineStyle(
                        color: ColorTheme.kGrey,
                        thickness: 1,
                      ),
                      indicatorStyle: IndicatorStyle(
                        indicator: CircleAvatar(
                          backgroundColor: sapHistoryList[index]?["isremaining"] == 1 ? ColorTheme.kTableHeader : ColorTheme.kPrimaryColor,
                          child: sapHistoryList[index]?["is_success"] == true
                              ? SvgPicture.asset(AssetsString.kSuccess)
                              : TextWidget(
                                  text: sapHistoryList[index]?["number"] ?? "",
                                  color: sapHistoryList[index]?["isremaining"] == 1 ? ColorTheme.kPrimaryColor : ColorTheme.kWhite,
                                ),
                        ),
                        padding: EdgeInsets.zero,
                        width: 35,
                        height: 35,
                      ),
                      endChild: Container(
                        margin: EdgeInsets.all(sizingInformation.isMobile ? 6 : 12),
                        padding: EdgeInsets.symmetric(vertical: sizingInformation.isMobile ? 0 : 16, horizontal: sizingInformation.isMobile ? 12 : 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: ColorTheme.kBorderColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: ColorTheme.kTableHeader),
                              child: SvgPicture.asset(
                                sapHistoryList[index]?["is_success"] == true
                                    ? AssetsString.kDecoratedCheck
                                    : sapHistoryList[index]?["isremaining"] == true
                                        ? AssetsString.kUnDecided
                                        : AssetsString.kInfoCircle,
                                colorFilter: ColorFilter.mode((sapHistoryList[index]?["color"] ?? "000000").toString().toColor(), BlendMode.srcIn),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: RowColumnWidget(
                                      grouptype: sizingInformation.isMobile ? GroupType.column : GroupType.row,
                                      children: [
                                        Flexible(
                                          child: TextWidget(
                                            text: sapHistoryList[index]?['message'],
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: sizingInformation.isMobile ? 14 : 16,
                                          ),
                                        ),
                                        sizingInformation.isMobile ? const SizedBox(height: 4) : const SizedBox(width: 16),
                                        TextWidget(
                                          text: sapHistoryList[index]?['date'].toString().toDateTimeFormat(),
                                          fontWeight: FontTheme.notoRegular,
                                          fontSize: sizingInformation.isMobile ? 12 : 14,
                                        ).paddingOnly(top: sizingInformation.isMobile ? 0 : 2),
                                      ],
                                    ),
                                  ),
                                  if ((sapHistoryList[index]?['sub_message']).toString().isNotNullOrEmpty) ...[
                                    const SizedBox(height: 4),
                                    TextWidget(
                                      text: sapHistoryList[index]?['sub_message'],
                                      fontWeight: FontTheme.notoRegular,
                                      fontSize: sizingInformation.isMobile ? 12 : 14,
                                    )
                                  ],
                                ],
                              ).paddingSymmetric(horizontal: 12),
                            ),
                            if (sapHistoryList[index]?["show_retry"] == 1) ...[
                              sizingInformation.isMobile
                                  ? Container(
                                      decoration: BoxDecoration(color: ColorTheme.kTableHeader, borderRadius: BorderRadius.circular(4)),
                                      child: const Icon(
                                        CupertinoIcons.refresh_thick,
                                        size: 18,
                                      ).paddingAll(4),
                                    ).marginOnly(top: 4)
                                  : Container(
                                      decoration: BoxDecoration(color: ColorTheme.kTableHeader, borderRadius: BorderRadius.circular(4)),
                                      child: TextWidget(
                                        text: "Retry",
                                        fontWeight: FontTheme.notoSemiBold,
                                        fontSize: sizingInformation.isMobile ? 12 : 14,
                                      ).paddingSymmetric(vertical: 6, horizontal: 20),
                                    ).marginOnly(top: 4)
                            ]
                          ],
                        ).paddingSymmetric(vertical: 8),
                      ),
                    );
                  },
                ),
              ).paddingOnly(top: sizingInformation.isMobile ? 12 : 24, right: sizingInformation.isMobile ? 0 : 24, left: sizingInformation.isMobile ? 0 : 24);
            },
          );
        }
      case 5:
        return SizedBox(
          height: Get.height / 1.2,
          child: SapContractHistoryDialog(
            titleName: headers[tabNumber - 1],
            sapContractHistoryList: sapContractHistoryList,
            sapContractHistoryFieldOrderList: sapContractHistoryFieldOrderList,
            setDefaultData: setDefaultData,
            isSapContractHistoryLoading: isSapContractHistoryLoading,
          ),
        );

      default:
        return const Center(
          child: TextWidget(text: "No Data Found"),
        );
    }
  }

  Widget documentRow({
    required String? title,
    required String? imgName,
    String? status,
    required void Function()? onTapHistory,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: TextWidget(text: title ?? "")),
            TextWidget(
              text: status ?? "",
              fontWeight: FontTheme.notoSemiBold,
            ),
          ],
        ).paddingAll(2),
        InkWell(
          onTap: onTapHistory,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kBorderColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text: imgName ?? "NA"),
                onTapHistory.toString().isNullOrEmpty
                    ? const SizedBox.shrink()
                    : const Icon(
                        Icons.visibility,
                        size: 16,
                      )
              ],
            ).paddingSymmetric(vertical: 8, horizontal: 8),
          ),
        )
      ],
    ).paddingOnly(bottom: 4);
  }

  Widget rentPaymentRow({
    required String title,
    required String value,
  }) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        TextWidget(
          text: title.toString().toDateFormat().toUpperCase(),
          color: ColorTheme.kBlack,
          fontWeight: FontTheme.notoSemiBold,
          textOverflow: TextOverflow.visible,
          fontSize: 12,
        ),
        const SizedBox(width: 2),
        TextWidget(
          text: value.toString().toUpperCase(),
          color: ColorTheme.kPrimaryColor,
          textOverflow: TextOverflow.visible,
          fontWeight: FontTheme.notoRegular,
          fontSize: 12,
        ),
      ],
    ).paddingOnly(bottom: 4);
  }

  Widget singleChildScrollViewRow({required bool isScrollable, required Widget child}) {
    if (isScrollable) {
      return SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);
    } else {
      return child;
    }
  }
}
