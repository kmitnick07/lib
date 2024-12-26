import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config/helper/device_service.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../../components/customs/custom_button.dart';

class CoApplicantDialog extends StatelessWidget {
  final List coApplicantData;

  const CoApplicantDialog({
    super.key,
    required this.coApplicantData,
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
      child: SizedBox(
        height: Get.height,
        width: 500,
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) => SizedBox(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      text: "Co-Applicant:",
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
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: (coApplicantData).length,
                    shrinkWrap: true,
                    itemBuilder: (context, coApplicantIndex) {
                      var coapplicant = coApplicantData[coApplicantIndex];
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorTheme.kBorderColor),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      child: Row(
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
                                              FilesDataModel.fromJson(coapplicant['ownerphoto']).url?? "",
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                TextWidget(
                                                  text: coapplicant['name'].toString().toDateFormat(),
                                                  fontWeight: FontTheme.notoSemiBold,
                                                  fontSize: 18,
                                                ),
                                                (coapplicant['contactno'] == [])
                                                    ? TextWidget(
                                                        text: ((coapplicant['contactno'] as List?)?.join(', ')).toString().toDateFormat(),
                                                        fontWeight: FontTheme.notoRegular,
                                                      )
                                                    : const TextWidget(text: "-"),
                                                TextWidget(
                                                  text: coapplicant['email'].toString().toDateFormat(),
                                                  fontWeight: FontTheme.notoRegular,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text.rich(
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
                                  ],
                                ),
                              ),
                              const VerticalDivider(),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    documentRow(AssetsString.kAadhar, coapplicant['aadharno'].toString().toDateFormat(), (coapplicant['aadharimage']?['url']).toString().isNullOrEmpty ? null :() {
                                       documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['aadharimage'] ?? {})));
                                    }, (coapplicant['aadharimage']?['url']).toString().isNullOrEmpty),
                                    documentRow(AssetsString.kPanCard, coapplicant['pan'].toString().toDateFormat(), (coapplicant['panimage']?['url']).toString().isNullOrEmpty ? null :() {
                                       documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['panimage'] ?? {})));
                                    }, (coapplicant['panimage']?['url']).toString().isNullOrEmpty),
                                    documentRow(AssetsString.kElectionCard, coapplicant['voterid'].toString().toDateFormat(), (coapplicant['voterimage']?['url']).toString().isNullOrEmpty ? null :() {
                                       documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['voterimage'] ?? {})));
                                    }, (coapplicant['voterimage']?['url']).toString().isNullOrEmpty),
                                    documentRow(AssetsString.kRationCard, coapplicant['rationcard'].toString().toDateFormat(), (coapplicant['rationcardimage']?['url']).toString().isNullOrEmpty ? null :() {
                                       documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(coapplicant['rationcardimage'] ?? {})));
                                    }, (coapplicant['rationcardimage']?['url']).toString().isNullOrEmpty),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 16);
                    },
                  ),
                ),
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
              ],
            ),
          ).paddingAll(20),
        ),
      ),
    );
  }

  Widget historyRentRow({
    required String text,
    required String value,
  }) {
    return Row(
      children: [
        TextWidget(
          text: text.toString().toDateFormat().toUpperCase(),
          color: ColorTheme.kBlack,
          fontWeight: FontTheme.notoSemiBold,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: TextWidget(
            text: value.toString().toUpperCase(),
            color: ColorTheme.kPrimaryColor,
            textOverflow: TextOverflow.visible,
            fontWeight: FontTheme.notoRegular,
          ),
        ),
      ],
    );
  }

  Widget documentRow(String image, String text, void Function()? onTap, bool? isNoDocument) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: ColorTheme.kBorderColor.withOpacity(0.2),
          ),
          padding: const EdgeInsets.all(4),
          child: Center(
            child: Image.asset(image, height: 24),
          ),
        ).paddingOnly(right: 8),
        InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: isNoDocument! ? null : onTap,
          child: Row(
            children: [
              TextWidget(text: text.toString().toDateFormat()),
              const SizedBox(width: 4),
              if (!isNoDocument) const Icon(Icons.visibility_rounded, size: 16, color: ColorTheme.kBlack),
            ],
          ),
        )
      ],
    ).paddingOnly(bottom: 8);
  }
}
