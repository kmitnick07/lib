import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/row_column_widget.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_common_widgets.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../config/config.dart';
import '../../config/helper/device_service.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';

class TenantHistoryDialog extends StatelessWidget {
  final Map ownerHistory;
  final Map data;
  final List rentdetailsdata;

  const TenantHistoryDialog({super.key, required this.ownerHistory, required this.rentdetailsdata, required this.data});

  @override
  Widget build(BuildContext context) {
    var history = ownerHistory;
    jsonPrint(tag: "8645546541563415634", ownerHistory);
    return ResponsiveBuilder(
      builder: (context, sizingInformation) => Container(
        color: ColorTheme.kWhite,
        child: ownerHistory.isNullOrEmpty
            ? const NoDataFoundScreen()
            : ListView.separated(
                itemCount: (history['ownerhistory'] ?? []).length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  var ownerhistory = history['ownerhistory'][index];
                  devPrint("7896546969845164546585");
                  jsonPrint(ownerhistory);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: index == 0 ? "Main Applicant" : "Old Applicant",
                            fontSize: 20,
                            color: ColorTheme.kBlack,
                            fontWeight: FontTheme.notoSemiBold,
                          ).paddingOnly(left: 4, bottom: 8),
                          Container(
                            decoration: BoxDecoration(color: ColorTheme.kWhite, border: Border.all(color: ColorTheme.kBorderColor), borderRadius: BorderRadius.circular(8)),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: IntrinsicHeight(
                                          child: RowColumnWidget(
                                            grouptype: sizingInformation.isDesktop ? GroupType.row : GroupType.column,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
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
                                                            FilesDataModel.fromJson(ownerhistory['tenantownerphoto']).url ?? "",
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return SvgPicture.asset(
                                                                AssetsString.kUser,
                                                                height: 60,
                                                              );
                                                            },
                                                          ),
                                                        ).paddingOnly(right: 8),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  TextWidget(
                                                                    text: ((ownerhistory['salutation'] ?? '') + "" + ownerhistory['tenantname']).toString().toDateFormat(),
                                                                    fontWeight: FontTheme.notoSemiBold,
                                                                    fontSize: 18,
                                                                    textOverflow: TextOverflow.visible,
                                                                  ),
                                                                  if ((ownerhistory['hutmentsupportid']).toString().isNotNullOrEmpty)
                                                                    CustomTooltip(
                                                                      message: ownerhistory['hutmentsupportname'] ?? '',
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          shape: BoxShape.circle,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: (ownerhistory['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor).withOpacity(0.5),
                                                                              spreadRadius: 4,
                                                                              blurRadius: 4,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child: CircleAvatar(
                                                                          backgroundColor: (ownerhistory['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor).withOpacity(0.7),
                                                                          radius: 5,
                                                                        ),
                                                                      ).paddingOnly(top: 4),
                                                                    )
                                                                ],
                                                              ),
                                                              TextWidget(
                                                                text: ((ownerhistory['tenantcontactno'] as List?)?.join(', ')).toString().toDateFormat(),
                                                                fontWeight: FontTheme.notoRegular,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  sendEmail(email: ownerhistory['tenantemail'] ?? '');
                                                                },
                                                                child: TextWidget(
                                                                  text: (ownerhistory['tenantemail']).toString().toDateFormat(),
                                                                  fontWeight: FontTheme.notoRegular,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (!sizingInformation.isDesktop) tenantStatusView(ownerhistory, false),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              sizingInformation.isMobile
                                                  ? (ownerhistory['committeedesignation'] ?? []).length == 0
                                                      ? const SizedBox.shrink()
                                                      : Wrap(
                                                          children: [
                                                            ...List.generate(
                                                                (ownerhistory['committeedesignation'] ?? []).length,
                                                                (index) => Padding(
                                                                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                                                                      child: Container(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                                        decoration: ShapeDecoration(
                                                                          color: ColorTheme.kBackGroundGrey,
                                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                        ),
                                                                        child: TextWidget(
                                                                          text: ownerhistory['committeedesignation']?[index]?['committeedesignation'] ?? "",
                                                                          color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                                          fontSize: 12,
                                                                          fontWeight: FontTheme.notoSemiBold,
                                                                          height: 1,
                                                                        ).paddingOnly(top: 2),
                                                                      ),
                                                                    ))
                                                          ],
                                                        ).paddingOnly(bottom: 8, top: 4)
                                                  : const SizedBox.shrink(),
                                              Expanded(
                                                flex: sizingInformation.isMobile ? 2 : 3,
                                                child: Row(
                                                  children: [
                                                    sizingInformation.isDesktop ? const VerticalDivider() : const SizedBox(),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          documentRow(
                                                              AssetsString.kAadhar,
                                                              (ownerhistory['tenantaadharno']).toString().toDateFormat(),
                                                              (ownerhistory['tenantaadharimage']?['url']).toString().isNullOrEmpty
                                                                  ? null
                                                                  : () {
                                                                      documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(ownerhistory['tenantaadharimage'] ?? {})));
                                                                    },
                                                              ownerhistory['tenantaadharimage']['url'].toString().isNullOrEmpty),
                                                          documentRow(
                                                              AssetsString.kPanCard,
                                                              (ownerhistory['tenantpan']).toString().toDateFormat(),
                                                              (ownerhistory['tenantpanimage']?['url']).toString().isNullOrEmpty
                                                                  ? null
                                                                  : () {
                                                                      documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(ownerhistory['tenantpanimage'] ?? {})));
                                                                    },
                                                              ownerhistory['tenantpanimage']['url'].toString().isNullOrEmpty),
                                                        ],
                                                      ),
                                                    ),
                                                    const VerticalDivider(),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          documentRow(
                                                              AssetsString.kElectionCard,
                                                              (ownerhistory['tenantvoterid']).toString().toDateFormat(),
                                                              (ownerhistory['tenantvoterimage']?['url']).toString().isNullOrEmpty
                                                                  ? null
                                                                  : () {
                                                                      documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(ownerhistory['tenantvoterimage'] ?? {})));
                                                                    },
                                                              ownerhistory['tenantvoterimage']['url'].toString().isNullOrEmpty),
                                                          documentRow(
                                                              AssetsString.kRationCard,
                                                              (ownerhistory['tenantrationcard']).toString().toDateFormat(),
                                                              (ownerhistory['tenantrationcardimage']?['url']).toString().isNullOrEmpty
                                                                  ? null
                                                                  : () {
                                                                      documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(ownerhistory['tenantrationcardimage'] ?? {})));
                                                                    },
                                                              ownerhistory['tenantrationcardimage']['url'].toString().isNullOrEmpty),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (sizingInformation.isDesktop) tenantStatusView(ownerhistory, false),
                                    ],
                                  ),
                                  !sizingInformation.isMobile
                                      ? (ownerhistory['committeedesignation'] ?? []).length == 0
                                          ? const SizedBox.shrink()
                                          : Wrap(
                                              children: [
                                                ...List.generate(
                                                    (ownerhistory['committeedesignation'] ?? []).length,
                                                    (index) => Padding(
                                                          padding: const EdgeInsets.only(right: 4, bottom: 4),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                            decoration: ShapeDecoration(
                                                              color: ColorTheme.kBackGroundGrey,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                            ),
                                                            child: TextWidget(
                                                              text: ownerhistory['committeedesignation']?[index]?['committeedesignation'] ?? "",
                                                              color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                              fontSize: 12,
                                                              fontWeight: FontTheme.notoSemiBold,
                                                              height: 1,
                                                            ).paddingOnly(top: 2),
                                                          ),
                                                        ))
                                              ],
                                            ).paddingOnly(bottom: 8, top: 12)
                                      : const SizedBox.shrink(),
                                  const Divider(),
                                  RowColumnWidget(
                                    grouptype: sizingInformation.isMobile ? GroupType.column : GroupType.row,
                                    children: [
                                      expandedRowColumn(
                                        !sizingInformation.isMobile,
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget(
                                                  text: 'Account Holder Name: '.toUpperCase(),
                                                  color: ColorTheme.kBlack,
                                                  fontWeight: FontTheme.notoSemiBold,
                                                  textOverflow: TextOverflow.visible,
                                                  fontSize: 12,
                                                ),
                                                const SizedBox(width: 2),
                                                TextWidget(
                                                  text: (data['tenantaccholdername'] ?? '').toString().toDateFormat().toUpperCase(),
                                                  color: ColorTheme.kPrimaryColor,
                                                  textOverflow: TextOverflow.visible,
                                                  fontWeight: FontTheme.notoRegular,
                                                  fontSize: 12,
                                                ),
                                              ],
                                            ).paddingOnly(bottom: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      titleValueRow(title: 'Bank Name:', value: data['tenantbankname'] ?? ''),
                                                      titleValueRow(title: 'Branch:', value: data['tenantbankbranch'] ?? ''),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      titleValueRow(title: 'Account No:', value: data['tenantaccountno'] ?? ''),
                                                      titleValueRow(title: 'IFSC:', value: data['tenantbankifsc'] ?? ''),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if ((data['tenantcanceledcheque']?['url']).toString().isNullOrEmpty)
                                        expandedRowColumn(
                                          !sizingInformation.isMobile,
                                          (data['tenantcanceledcheque']?['url']).toString().isNullOrEmpty
                                              ? const SizedBox.shrink()
                                              : documentRow(
                                                  AssetsString.kPanCard,
                                                  "Cheque",
                                                  data['tenantcanceledcheque']['url'].toString().isNullOrEmpty
                                                      ? null
                                                      : () {
                                                          documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(data['tenantcanceledcheque'] ?? {})));
                                                        },
                                                  data['tenantcanceledcheque']['url'].toString().isNullOrEmpty),
                                        )
                                    ],
                                  ),
                                ],
                              ).paddingAll(8),
                            ),
                          ),
                        ],
                      ),
                      if ((ownerhistory['coapplicant'] ?? []).length != 0)
                        TextWidget(
                          text: index == 0 ? "Co-Applicant:" : "Old Co-Applicant:",
                          fontSize: 16,
                          textAlign: TextAlign.left,
                          color: ColorTheme.kBlack,
                          fontWeight: FontTheme.notoSemiBold,
                        ).paddingAll(8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (ownerhistory['coapplicant'] ?? []).length,
                        itemBuilder: (BuildContext context, int coapplicantIndex) {
                          var coapplicant = ownerhistory['coapplicant'][coapplicantIndex];
                          devPrint("78965469698645465");
                          jsonPrint(coapplicant);
                          return Container(
                            decoration: BoxDecoration(color: ColorTheme.kWhite, border: Border.all(color: ColorTheme.kBorderColor), borderRadius: BorderRadius.circular(8)),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              IntrinsicHeight(
                                                child: RowColumnWidget(
                                                  grouptype: sizingInformation.isDesktop ? GroupType.row : GroupType.column,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
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
                                                                  FilesDataModel.fromJson(coapplicant['ownerphoto']).url ?? "",
                                                                  fit: BoxFit.cover,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return SvgPicture.asset(
                                                                      AssetsString.kUser,
                                                                      height: 60,
                                                                    );
                                                                  },
                                                                ),
                                                              ).paddingOnly(right: 8),
                                                              Expanded(
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        TextWidget(
                                                                          text: '${coapplicant['salutation'] ?? ''}${coapplicant['name'] ?? ''}'.toDateFormat(),
                                                                          fontWeight: FontTheme.notoSemiBold,
                                                                          fontSize: 18,
                                                                          textOverflow: TextOverflow.visible,
                                                                        ),
                                                                        if ((coapplicant['hutmentsupportid']).toString().isNotNullOrEmpty)
                                                                          CustomTooltip(
                                                                            message: coapplicant['hutmentsupportname'] ?? '',
                                                                            child: Container(
                                                                              decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: (coapplicant['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor).withOpacity(0.5),
                                                                                    spreadRadius: 4,
                                                                                    blurRadius: 4,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: CircleAvatar(
                                                                                backgroundColor: (coapplicant['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor).withOpacity(0.7),
                                                                                radius: 5,
                                                                              ),
                                                                            ),
                                                                          )
                                                                      ],
                                                                    ),
                                                                    TextWidget(
                                                                      text: ((coapplicant['contactno'] as List?)?.join(', ')).toString().toDateFormat(),
                                                                      fontWeight: FontTheme.notoRegular,
                                                                    ),
                                                                    InkWell(
                                                                      onTap: () {
                                                                        sendEmail(email: coapplicant['email'] ?? '');
                                                                      },
                                                                      child: TextWidget(
                                                                        text: coapplicant['email'].toString().toDateFormat(),
                                                                        fontWeight: FontTheme.notoRegular,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (!sizingInformation.isDesktop) tenantStatusView(coapplicant, true),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    sizingInformation.isMobile
                                                        ? (coapplicant['committeedesignation'] ?? []).length == 0
                                                            ? const SizedBox.shrink()
                                                            : Wrap(
                                                                children: [
                                                                  ...List.generate(
                                                                      (coapplicant['committeedesignation'] ?? []).length,
                                                                      (index) => Padding(
                                                                            padding: const EdgeInsets.only(right: 4, bottom: 4),
                                                                            child: Container(
                                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                                              decoration: ShapeDecoration(
                                                                                color: ColorTheme.kBackGroundGrey,
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                                              ),
                                                                              child: TextWidget(
                                                                                text: coapplicant['committeedesignation']?[index]?['committeedesignation'] ?? "",
                                                                                color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                                                fontSize: 12,
                                                                                fontWeight: FontTheme.notoSemiBold,
                                                                                height: 1,
                                                                              ).paddingOnly(top: 2),
                                                                            ),
                                                                          ))
                                                                ],
                                                              ).paddingOnly(bottom: 8, top: 4)
                                                        : const SizedBox.shrink(),
                                                    Expanded(
                                                      flex: sizingInformation.isMobile ? 2 : 3,
                                                      child: Row(
                                                        children: [
                                                          sizingInformation.isDesktop ? const VerticalDivider() : const SizedBox(),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                documentRow(
                                                                    AssetsString.kAadhar,
                                                                    coapplicant['aadharno'].toString().toDateFormat(),
                                                                    (coapplicant['aadharimage']?['url']).toString().isNullOrEmpty
                                                                        ? null
                                                                        : () {
                                                                            documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['aadharimage'] ?? {})));
                                                                          },
                                                                    (coapplicant['aadharimage']?['url']).toString().isNullOrEmpty),
                                                                documentRow(
                                                                    AssetsString.kPanCard,
                                                                    coapplicant['pan'].toString().toDateFormat(),
                                                                    (coapplicant['panimage']?['url']).toString().isNullOrEmpty
                                                                        ? null
                                                                        : () {
                                                                            documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['panimage'] ?? {})));
                                                                          },
                                                                    (coapplicant['panimage']?['url']).toString().isNullOrEmpty),
                                                              ],
                                                            ),
                                                          ),
                                                          const VerticalDivider(),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                documentRow(
                                                                    AssetsString.kElectionCard,
                                                                    coapplicant['voterid'].toString().toDateFormat(),
                                                                    (coapplicant['voterimage']?['url']).toString().isNullOrEmpty
                                                                        ? null
                                                                        : () {
                                                                            documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['voterimage'] ?? {})));
                                                                          },
                                                                    (coapplicant['voterimage']?['url']).toString().isNullOrEmpty),
                                                                documentRow(
                                                                    AssetsString.kRationCard,
                                                                    coapplicant['rationcard'].toString().toDateFormat(),
                                                                    (coapplicant['rationcardimage']?['url']).toString().isNullOrEmpty
                                                                        ? null
                                                                        : () {
                                                                            documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['rationcardimage'] ?? {})));
                                                                          },
                                                                    (coapplicant['rationcardimage']?['url']).toString().isNullOrEmpty),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      const TextSpan(
                                                        text: "Relation : ",
                                                        style: TextStyle(
                                                          color: ColorTheme.kBlack,
                                                          fontWeight: FontTheme.notoSemiBold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: coapplicant['relation'].toString().toDateFormat(),
                                                        style: const TextStyle(
                                                          fontWeight: FontTheme.notoRegular,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (sizingInformation.isDesktop) tenantStatusView(coapplicant, true),
                                      ],
                                    ),
                                  ),
                                  !sizingInformation.isMobile
                                      ? (coapplicant['committeedesignation'] ?? []).length == 0
                                          ? const SizedBox.shrink()
                                          : Wrap(
                                              children: [
                                                ...List.generate(
                                                    (coapplicant['committeedesignation'] ?? []).length,
                                                    (index) => Padding(
                                                          padding: const EdgeInsets.only(right: 4, bottom: 4),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                            decoration: ShapeDecoration(
                                                              color: ColorTheme.kBackGroundGrey,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                            ),
                                                            child: TextWidget(
                                                              text: coapplicant['committeedesignation']?[index]?['committeedesignation'] ?? "",
                                                              color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                              fontSize: 12,
                                                              fontWeight: FontTheme.notoSemiBold,
                                                              height: 1,
                                                            ).paddingOnly(top: 2),
                                                          ),
                                                        ))
                                              ],
                                            ).paddingOnly(bottom: 8, top: 12)
                                      : const SizedBox.shrink(),
                                ],
                              ).paddingAll(8),
                            ),
                          ).paddingSymmetric(vertical: 4);
                        },
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget tenantStatusView(Map data, bool isCoApplicant) {
    double size = 23;

    return data[!isCoApplicant ? "tenantisexpire" : "isexpire"] == 1 || data["issold"] == 1
        ? Column(
            children: [
              Row(
                children: [
                  if (data[!isCoApplicant ? "tenantisexpire" : "isexpire"] == 1)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomTooltip(
                              message: (data[!isCoApplicant ? "tenantdeathcertificate" : "deathcertificate"].toString().isNotNullOrEmpty && data[!isCoApplicant ? "tenantdeathcertificate" : "deathcertificate"]['url'].toString().isNotNullOrEmpty)
                                  ? 'Death Certificate'
                                  : null,
                              textAlign: TextAlign.center,
                              child: InkWell(
                                onTap: (data[!isCoApplicant ? "tenantdeathcertificate" : "deathcertificate"].toString().isNotNullOrEmpty && data[!isCoApplicant ? "tenantdeathcertificate" : "deathcertificate"]['url'].toString().isNotNullOrEmpty)
                                    ? () {
                                        documentDownload(imageList: FilesDataModel.fromJson(data[!isCoApplicant ? "tenantdeathcertificate" : "deathcertificate"] ?? {}));
                                      }
                                    : null,
                                child: SvgPicture.asset(
                                  AssetsString.kUserExpired,
                                  height: size,
                                  width: size,
                                ),
                              ),
                            ),
                            if (data['successioncertificate'].toString().isNotNullOrEmpty) ...[
                              const SizedBox(width: 8),
                              CustomTooltip(
                                message: (data['successioncertificate'].toString().isNotNullOrEmpty && data['successioncertificate']['url'].toString().isNotNullOrEmpty) ? 'Succession Certificate' : null,
                                textAlign: TextAlign.center,
                                child: InkWell(
                                  onTap: (data['successioncertificate'].toString().isNotNullOrEmpty && data['successioncertificate']['url'].toString().isNotNullOrEmpty)
                                      ? () {
                                          documentDownload(imageList: FilesDataModel.fromJson(data['successioncertificate'] ?? {}));
                                        }
                                      : null,
                                  child: SvgPicture.asset(
                                    AssetsString.kSuccessionCertificate,
                                    height: size,
                                    width: size,
                                  ),
                                ),
                              )
                            ],
                          ],
                        ),
                        if (data[!isCoApplicant ? "tenantisexpire" : "isexpire"] == 1) TextWidget(text: data[!isCoApplicant ? "tenantdeathdate" : "deathdate"].toString().toDateFormat()).paddingAll(4),
                      ],
                    ).paddingAll(8),
                  if (data["issold"] == 1)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AssetsString.kSold,
                          height: size,
                          width: size,
                        ),
                        if (data["issold"] == 1) TextWidget(text: data["solddate"].toString().toDateFormat()).paddingAll(4),
                      ],
                    ).paddingAll(8),
                ],
              ),
              if (data["maincountstr"].toString().isNotNullOrEmpty)
                Container(
                  decoration: const BoxDecoration(
                    color: ColorTheme.kBlack,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: TextWidget(
                    text: data["maincountstr"],
                    fontSize: 10,
                    color: ColorTheme.kWhite,
                  ).paddingSymmetric(vertical: 3, horizontal: 8),
                ).paddingOnly(top: 4),
            ],
          )
        : Container();
  }

  Widget documentRow(String image, text, void Function()? onTap, bool? isNoDocument) {
    return Expanded(
      child: Row(
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: Center(
              child: Image.asset(image, height: 24),
            ),
          ).paddingOnly(right: 8),
          Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: isNoDocument! ? null : onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: TextWidget(text: text.toString().toDateFormat())),
                  const SizedBox(width: 4),
                  if (!isNoDocument) const Icon(Icons.visibility_rounded, size: 16, color: ColorTheme.kBlack),
                ],
              ),
            ),
          )
        ],
      ).paddingOnly(bottom: 8),
    );
  }

  Widget titleValueRow({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          text: value.toString().toDateFormat().toUpperCase(),
          color: ColorTheme.kPrimaryColor,
          textOverflow: TextOverflow.visible,
          fontWeight: FontTheme.notoRegular,
          fontSize: 12,
        ),
      ],
    ).paddingOnly(bottom: 4);
  }
}
