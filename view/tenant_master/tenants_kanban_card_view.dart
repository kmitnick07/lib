import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/controller/tenant_master_controller.dart';
import 'package:prestige_prenew_frontend/view/tenant_master/tenants_table_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/customs/custom_shimmer.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../components/customs/text_widget.dart';
import '../../config/config.dart';
import '../../config/helper/device_service.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../models/Menu/menu_model.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../CommonWidgets/common_table.dart';
import '../tenant/rent_history_dialog.dart';
import '../tenant/status_history_dialog.dart';
import '../user_role_hierarchy/member_show.dart';

class TenantKanBanCardView extends GetView<TenantMasterController> {
  TenantKanBanCardView({this.isLoading = false, required this.data, required this.pageName, required this.index, super.key});

  final Map<String, dynamic> data;
  final bool isLoading;

  final String pageName;
  final int index;
  UserRight pageRights = UserRight();

  @override
  Widget build(BuildContext context) {
    FilesDataModel ownerImage = FilesDataModel.fromJson(data['tenantownerphoto'] ?? {});
    /*var edgeInsets = const EdgeInsets.all(12);
    return Container(
      // constraints: const BoxConstraints(minWidth: 400),
      padding: edgeInsets,
      decoration: BoxDecoration(
        color: ColorTheme.kWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        // boxShadow: [
        //   BoxShadow(
        //     color: ColorTheme.kPrimaryColor.withOpacity(0.3),
        //     blurStyle: BlurStyle.outer,
        //     blurRadius: 3,
        //     spreadRadius: 2,
        //   )
        // ],
      ),
      child: CustomShimmer(
        isLoading: isLoading,
        child: Column(
          children: [
            Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: ColorTheme.kWhite,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: const Color(0xFFA8AAAE).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFFA8AAAE).withOpacity(0.16),
                          )),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Center(
                          child: TextWidget(
                            text: data['hutmentno'] ?? '',
                            color: ColorTheme.kWhite,
                            fontWeight: FontTheme.notoSemiBold,
                            fontSize: 14,
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (controller.setDefaultData.fieldOrder.isNotEmpty)
                    SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: ColorTheme.kScaffoldColor,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: CustomTooltip(
                              message: '${controller.setDefaultData.fieldOrder[0]['field']['subfield'][index]['text']} \n ${data[controller.setDefaultData.fieldOrder[0]['field']['subfield'][index]['field']] ?? ''}',
                              textAlign: TextAlign.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorTheme.kPrimaryColor,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${controller.setDefaultData.fieldOrder[0]['field']['subfield'][index]['text'][0]}',
                                    style: GoogleFonts.novaMono(
                                      fontSize: 14,
                                      fontWeight: FontTheme.notoSemiBold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                          width: 4,
                        ),
                        itemCount: controller.setDefaultData.fieldOrder[0]['field']['subfield'].length,
                      ),
                    )
                ],
              ),
            ).paddingOnly(bottom: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                      border: Border.all(
                        color: data['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Visibility(
                        visible: (ownerImage['url'] ?? '').toString().isNotNullOrEmpty,
                        replacement: SvgPicture.asset(AssetsString.kUser),
                        child: Image.network(
                          ownerImage['url'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: data['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                            width: 1.5,
                          ),
                          top: BorderSide(
                            color: data['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                            width: 1.5,
                          ),
                          right: BorderSide(
                            color: data['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextWidget(
                                  text: data['tenantpassbookname'] ?? "",
                                  color: ColorTheme.kPrimaryColor,
                                  fontSize: 12,
                                  textOverflow: TextOverflow.visible,
                                  fontWeight: FontTheme.notoBold,
                                ),
                              ),
                            ).paddingOnly(bottom: 8),
                            (data['committeedesignation'] ?? []).length == 0
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    height: 22,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: ColorTheme.kBlack.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: TextWidget(
                                            text: data['committeedesignation'][index]['committeedesignation'],
                                            fontWeight: FontTheme.notoMedium,
                                            fontSize: 10,
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) => const SizedBox(
                                        width: 4,
                                      ),
                                      itemCount: (data['committeedesignation'] ?? []).length,
                                    ),
                                  )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // const SizedBox(height: 8),
            const Divider(thickness: 2.0),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, contactIndex) => Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: ColorTheme.kScaffoldColor,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: CustomTooltip(
                          message: (data['tenantcontactno'][contactIndex] ?? ''),
                          textAlign: TextAlign.center,
                          child: SvgPicture.asset(
                            AssetsString.kPhone,
                          ),
                        ),
                      ),
                      separatorBuilder: (context, index) => const SizedBox(
                        width: 4,
                      ),
                      itemCount: (data['tenantcontactno'] ?? []).length,
                    ),
                  ),
                ),
                SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: ColorTheme.kScaffoldColor,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: index == 0
                              ? CustomTooltip(
                                  message: data['tenantaadharno'] ?? '',
                                  textAlign: TextAlign.center,
                                  child: Image.asset(
                                    opacity: AlwaysStoppedAnimation(
                                      data['tenantaadharno'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                    ),
                                    AssetsString.kAadhar,
                                  ),
                                )
                              : index == 1
                                  ? CustomTooltip(
                                      message: data['tenantvoterid'] ?? '',
                                      textAlign: TextAlign.center,
                                      child: Image.asset(
                                        opacity: AlwaysStoppedAnimation(
                                          data['tenantvoterid'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                        ),
                                        AssetsString.kElectionCard,
                                      ),
                                    )
                                  : index == 2
                                      ? CustomTooltip(
                                          message: data['tenantpan'] ?? '',
                                          textAlign: TextAlign.center,
                                          child: Image.asset(
                                            opacity: AlwaysStoppedAnimation(
                                              data['tenantpan'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                            ),
                                            AssetsString.kPanCard,
                                          ),
                                        )
                                      : index == 3
                                          ? CustomTooltip(
                                              message: data['tenantrationcard'] ?? '',
                                              textAlign: TextAlign.center,
                                              child: Image.asset(
                                                opacity: AlwaysStoppedAnimation(
                                                  data['tenantrationcard'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                                ),
                                                AssetsString.kRationCard,
                                              ))
                                          : const SizedBox.shrink(),
                        ),
                        separatorBuilder: (context, index) => const SizedBox(
                          width: 4,
                        ),
                        itemCount: 4,
                      ),
                    ],
                  ),
                ).paddingOnly(right: 4.5),
                Row(
                  children: [
                    tooltipHome(
                      title: 'Interior Photos',
                      image: AssetsString.kInternalHome,
                      imageList: FilesDataModel().fromJsonList(List<Map<String, dynamic>>.from(data['internalimages'] ?? [])),
                    ).paddingOnly(right: 4),
                    tooltipHome(
                      title: 'Exterior Photos',
                      image: AssetsString.kExternalHome,
                      imageList: FilesDataModel().fromJsonList(List<Map<String, dynamic>>.from(data['externalimages'] ?? [])),
                    ),
                  ],
                )
              ],
            ).paddingOnly(bottom: 8),

            Builder(builder: (context) {
              bool isExpanded = false;
              Map rent = ((data['rentdetails'] ?? [{}]) as List).last;

              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  width: 600,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: ColorTheme.kScaffoldColor,
                    border: Border.all(
                      color: ColorTheme.kBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      listTileTheme: ListTileTheme.of(context).copyWith(dense: true, minVerticalPadding: 4),
                    ),
                    child: ExpansionTile(
                      dense: true,
                      onExpansionChanged: (value) {
                        setState(
                          () {
                            isExpanded = value;
                          },
                        );
                      },
                      // tilePadding: EdgeInsets.zero,
                      // childrenPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      title: Center(
                        child: TextWidget(
                          text: (isExpanded ? 'Show Less' : 'Show More').toUpperCase(),
                          fontSize: 10,
                          color: ColorTheme.kPrimaryColor,
                          fontWeight: FontTheme.notoMedium,
                        ),
                      ),
                      backgroundColor: ColorTheme.kScaffoldColor,
                      leading: const SizedBox.shrink(),
                      trailing: const SizedBox.shrink(),
                      children: [
                        Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: ColorTheme.kScaffoldColor,
                              border: Border.all(
                                color: ColorTheme.kBorderColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Visibility(
                                      visible: data['clustername'].toString().isNotNullOrEmpty,
                                      child: Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          color: ColorTheme.kWhite,
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AssetsString.kTower,
                                                ),
                                                const VerticalDivider(),
                                                Expanded(
                                                  child: TextWidget(
                                                    text: data['clustername'] ?? "",
                                                    fontWeight: FontTheme.notoSemiBold,
                                                    fontSize: 10,
                                                    color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Visibility(
                                      visible: data['localityname'].toString().isNotNullOrEmpty,
                                      child: Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          color: ColorTheme.kWhite,
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  AssetsString.kTower,
                                                ),
                                                const VerticalDivider(),
                                                Expanded(
                                                  child: TextWidget(
                                                    text: data['localityname'] ?? "",
                                                    fontWeight: FontTheme.notoSemiBold,
                                                    fontSize: 10,
                                                    color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 32,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) => Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: ColorTheme.kWhite,
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: index == 0
                                                ? CustomTooltip(
                                                    message: data['hutmentusetypename'] ?? '',
                                                    textAlign: TextAlign.center,
                                                    child: SvgPicture.asset(
                                                      AssetsString.kHome,
                                                    ),
                                                  )
                                                : index == 1
                                                    ? CustomTooltip(
                                                        message: data['eligibilityname'] ?? '',
                                                        textAlign: TextAlign.center,
                                                        child: SvgPicture.asset(
                                                          AssetsString.kEligible,
                                                          colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['eligibilityname'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                        ),
                                                      )
                                                    : index == 2
                                                        ? CustomTooltip(
                                                            message: data['xpartname'] ?? '',
                                                            textAlign: TextAlign.center,
                                                            child: SvgPicture.asset(
                                                              AssetsString.kXPart,
                                                              colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['xpartname'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                            ),
                                                          )
                                                        : const SizedBox.shrink(),
                                          ),
                                          separatorBuilder: (context, index) => const SizedBox(
                                            width: 4,
                                          ),
                                          itemCount: 3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        color: ColorTheme.kWhite,
                                        child: IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                AssetsString.kReceipt,
                                              ),
                                              const VerticalDivider(),
                                              Expanded(
                                                child: SizedBox(
                                                  height: 30,
                                                  child: ListView.separated(
                                                    scrollDirection: Axis.horizontal,
                                                    shrinkWrap: true,
                                                    itemBuilder: (context, index) => Container(
                                                      height: 30,
                                                      width: 30,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        color: ColorTheme.kBackgroundColor,
                                                      ),
                                                      padding: const EdgeInsets.all(4),
                                                      child: index == 0
                                                          ? CustomTooltip(
                                                              message: 'House Tax',
                                                              textAlign: TextAlign.center,
                                                              child: SvgPicture.asset(
                                                                AssetsString.kHome2,
                                                                colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['housetax'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                              ),
                                                            )
                                                          : index == 1
                                                              ? CustomTooltip(
                                                                  message: 'Water Bill',
                                                                  textAlign: TextAlign.center,
                                                                  child: SvgPicture.asset(
                                                                    AssetsString.kWater,
                                                                    colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['watertaxbill'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                                  ),
                                                                )
                                                              : index == 2
                                                                  ? CustomTooltip(
                                                                      message: 'Ele. Bill',
                                                                      textAlign: TextAlign.center,
                                                                      child: SvgPicture.asset(
                                                                        AssetsString.kElectricity,
                                                                        colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['elecricitybill'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                                      ),
                                                                    )
                                                                  : const SizedBox.shrink(),
                                                    ),
                                                    separatorBuilder: (context, index) => const SizedBox(
                                                      width: 4,
                                                    ),
                                                    itemCount: 3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  color: ColorTheme.kWhite,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          AssetsString.kRuler,
                                        ),
                                        const VerticalDivider(),
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            children: [
                                              TextWidget(
                                                text: 'MEASUREMENT',
                                                fontWeight: FontTheme.notoSemiBold,
                                                fontSize: 10,
                                                textOverflow: TextOverflow.ellipsis,
                                                color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                              ),
                                              const Spacer(),
                                              TextWidget(
                                                text: (data['measurement']).toString().isNullOrEmpty ? " - " : '${data['measurement'] ?? ""} Sq. Ft.',
                                                fontWeight: FontTheme.notoSemiBold,
                                                fontSize: 12,
                                                color: ColorTheme.kPrimaryColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // const SizedBox(
                                        //   width: 8,
                                        // ),
                                        // Expanded(
                                        //   flex: 3,
                                        //   child: Row(
                                        //     children: [
                                        //       TextWidget(
                                        //         text: 'EXTERIOR',
                                        //         fontWeight: FontTheme.notoSemiBold,
                                        //         fontSize: 10,
                                        //         textOverflow: TextOverflow.ellipsis,
                                        //         color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                        //       ),
                                        //       const Spacer(),
                                        //       const TextWidget(
                                        //         text: '380 Sq. Ft.',
                                        //         fontWeight: FontTheme.notoSemiBold,
                                        //         fontSize: 12,
                                        //         textOverflow: TextOverflow.ellipsis,
                                        //         color: ColorTheme.kPrimaryColor,
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            bottomLeft: Radius.circular(4),
                                          ),
                                          border: Border.all(
                                            color: ColorTheme.kPrimaryColor,
                                            width: 1,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: SvgPicture.asset(
                                          AssetsString.kKeyHandOver,
                                        ),
                                        // child: ,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(4),
                                                bottomRight: Radius.circular(4),
                                              ),
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: ColorTheme.kPrimaryColor,
                                                  width: 1,
                                                ),
                                                top: BorderSide(
                                                  color: ColorTheme.kPrimaryColor,
                                                  width: 1,
                                                ),
                                                right: BorderSide(
                                                  color: ColorTheme.kPrimaryColor,
                                                  width: 1,
                                                ),
                                              )),
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextWidget(
                                                text: ("${data['tenantstatus'] ?? ""} Date").toString().toUpperCase(),
                                                color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                fontSize: 10,
                                                fontWeight: FontTheme.notoBold,
                                              ),
                                              TextWidget(
                                                text: (data["${data['tenantstatusid'] ?? ""}_date"]).toString().toDateFormat().toUpperCase(),
                                                color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                fontSize: 10,
                                                fontWeight: FontTheme.notoBold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Column(
                            children: [
                              Visibility(
                                visible: (rent['rentinmonth']).toString().isNotNullOrEmpty,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: ColorTheme.kScaffoldColor,
                                    border: Border.all(
                                      color: ColorTheme.kBorderColor,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: (rent['rentinmonth']).toString().isNullOrEmpty
                                      ? const SizedBox(
                                          height: 70,
                                          child: Center(
                                            child: TextWidget(text: 'No Rent Data Found'),
                                          ),
                                        )
                                      : Container(
                                          color: ColorTheme.kWhite,
                                          padding: const EdgeInsets.all(4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextWidget(
                                                text: '${(rent['rentinmonth'] ?? '').toString().toAmount()} * ${(rent['noofmonths'] ?? '')}M',
                                                color: ColorTheme.kPrimaryColor,
                                                fontWeight: FontTheme.notoRegular,
                                                fontSize: 12,
                                              ),
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
                                                    TextWidget(
                                                      text: (rent['shiftingcharge'] ?? '').toString().toAmount(),
                                                      color: ColorTheme.kPrimaryColor,
                                                      fontWeight: FontTheme.notoRegular,
                                                      fontSize: 12,
                                                    ),
                                                    const Spacer(),
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
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const Divider(),
                                              TextWidget(
                                                text: (rent['totalpayable'] ?? '').toString().toAmount(),
                                                color: ColorTheme.kPrimaryColor,
                                                fontWeight: FontTheme.notoSemiBold,
                                                fontSize: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: ColorTheme.kScaffoldColor,
                                  border: Border.all(
                                    color: ColorTheme.kBorderColor,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  color: ColorTheme.kWhite,
                                  padding: const EdgeInsets.all(4),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      List obj = [
                                        {
                                          'name': 'Common Consent',
                                          'value': data['commonconsentname'] ?? '',
                                        },
                                        {
                                          'name': 'Individual Consent',
                                          'value': data['individualconsentname'] ?? '',
                                        },
                                        {
                                          'name': 'Individual Agreement',
                                          'value': data['individualagreementname'] ?? '',
                                        },
                                      ];
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: TextWidget(
                                              text: (obj[index]['name']).toUpperCase(),
                                              fontWeight: FontTheme.notoSemiBold,
                                              fontSize: 10,
                                              textOverflow: TextOverflow.visible,
                                              textAlign: TextAlign.start,
                                              color: ColorTheme.kBlack.withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          if (obj[index]['value'].toString().trim().toUpperCase() == 'NO'.toUpperCase())
                                            const Icon(
                                              Icons.clear,
                                              size: 12,
                                              color: ColorTheme.kErrorColor,
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: TextWidget(
                                                text: obj[index]['value'].toString().toUpperCase(),
                                                textAlign: TextAlign.center,
                                                color: ColorTheme.kBlack,
                                                fontSize: 8,
                                                height: 1,
                                                fontWeight: FontTheme.notoSemiBold,
                                              ),
                                              // child: IntrinsicHeight(
                                              //   child: Row(
                                              //     mainAxisSize: MainAxisSize.min,
                                              //     mainAxisAlignment: MainAxisAlignment.center,
                                              //     crossAxisAlignment: CrossAxisAlignment.center,
                                              //     children: [
                                              //       Icon(
                                              //         Icons.check,
                                              //         size: 12,
                                              //         color: ColorTheme.kSuccessColor,
                                              //       ),
                                              //       VerticalDivider(),
                                              //      TextWidget(
                                              //                                 text: Obj[index]['value'],
                                              //                                 textAlign: TextAlign.center,
                                              //                                 color: Colors.black,
                                              //                                 fontSize: 8,
                                              //                                 fontWeight: FontTheme.notoSemiBold,
                                              //                               ),
                                              //     ],
                                              //   ),
                                              // ),
                                            ),
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) => const SizedBox(
                                      height: 8,
                                    ),
                                    itemCount: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: ColorTheme.kScaffoldColor,
                                  border: Border.all(
                                    color: ColorTheme.kBorderColor,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  color: ColorTheme.kWhite,
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'Request Slot'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          TextWidget(
                                            text: (rent['requestslotname'] ?? '-').toString().toUpperCase(),
                                            color: ColorTheme.kPrimaryColor,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'Rent received'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          TextWidget(
                                            text: (rent['rentreceiveddate'] ?? '-').toString().toDateFormat().toUpperCase(),
                                            color: ColorTheme.kPrimaryColor,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'Chq No.'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          TextWidget(
                                            text: (rent['paymentno'] ?? '-').toString().toUpperCase(),
                                            color: ColorTheme.kPrimaryColor,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'ChQ Date'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          TextWidget(
                                            text: (rent['paymentdate'] ?? '-').toString().toDateFormat().toUpperCase(),
                                            color: ColorTheme.kPrimaryColor,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'ChQ Received at site '.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          TextWidget(
                                            text: (rent['paymentreceivedsitedate'] ?? '-').toString().toDateFormat().toUpperCase(),
                                            color: ColorTheme.kPrimaryColor,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'CHQ HANDOVER DATE'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          TextWidget(
                                            text: (rent['paymenthandoverdate'] ?? '-').toString().toDateFormat().toUpperCase(),
                                            color: ColorTheme.kPrimaryColor,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'No. of Days'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: ColorTheme.kPrimaryColor.withOpacity(0.1),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: TextWidget(
                                              text: (data['daysofrentpay'] ?? ' - ').toString().toDateFormat().toUpperCase(),
                                              color: ColorTheme.kPrimaryColor,
                                              fontWeight: FontTheme.notoBold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'Days to Pay'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: ColorTheme.kPrimaryColor.withOpacity(0.1),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: TextWidget(
                                              text: (data['daysafterrentpay'] ?? ' - ').toString().toDateFormat().toUpperCase(),
                                              color: ColorTheme.kPrimaryColor,
                                              fontWeight: FontTheme.notoBold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: 'Due Date'.toUpperCase(),
                                            color: ColorTheme.kPrimaryColor.withOpacity(0.7),
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 10,
                                          ),
                                          const Spacer(),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: ColorTheme.kPrimaryColor.withOpacity(0.1),
                                            ),
                                            padding: const EdgeInsets.all(4),
                                            child: TextWidget(
                                              text: (data['rentduedate'] ?? ' - ').toString().toDateFormat().toUpperCase(),
                                              color: ColorTheme.kPrimaryColor,
                                              fontWeight: FontTheme.notoBold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            })
          ],
        ),
      ),
    );
   */
    // Vatsal
    return ResponsiveBuilder(builder: (context, sizeInformation) {
      pageRights = IISMethods().getPageRights(alias: pageName ?? '') ?? UserRight();
      bool isEditVisible = true;
      isEditVisible = pageRights.alleditright == 1 || (pageRights.selfeditright == 1 && (data['recordinfo']?['entryuid'] == Settings.uid));
      return Container(
        // margin: const EdgeInsets.only(
        //   bottom: 16,
        // ),
        constraints: sizeInformation.isMobile ? null : const BoxConstraints(minWidth: 400),
        decoration: BoxDecoration(
          color: ColorTheme.kWhite,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: ColorTheme.kPrimaryColor.withOpacity(0.3),
              blurStyle: BlurStyle.outer,
              blurRadius: 3,
              spreadRadius: 2,
            )
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          width: sizeInformation.isMobile ? MediaQuery.of(context).size.width : 400,
          child: CustomShimmer(
            isLoading: isLoading ?? false,
            child: Column(
              children: [
                Container(
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: ColorTheme.kWhite,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Center(
                            child: TextWidget(
                              text: data['hutmentno'] ?? '',
                              color: ColorTheme.kWhite,
                              fontWeight: FontTheme.notoSemiBold,
                              fontSize: 14,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                      ),
                      ...[
                        const SizedBox(width: 8),
                        InkResponse(
                          onTap: isEditVisible
                              ? () {
                                  CustomDialogs().statusChangeDialog(
                                    onTap: () async {
                                      await controller.handleKanbanGridChange(
                                        type: HtmlControls.kStatus,
                                        field: 'status',
                                        value: data['status'] != 1,
                                        data: data,
                                        index: index,
                                        isMobile: sizeInformation.isMobile,
                                      );

                                      /// because of no data update on status change that's why getKanbanData() call
                                      !sizeInformation.isMobile ? controller.kanbanData.value = await controller.getKanbanData() : null;
                                      Get.back();
                                    },
                                    value: data['status'],
                                  );
                                }
                              : null,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(4), bottomLeft: Radius.circular(4)),
                              color: ColorTheme.kBackgroundColor,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.circle,
                              size: 10,
                              color: data['status'] == 1 ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                            ),
                          ),
                        )
                      ],
                      const Spacer(),
                      if (controller.setDefaultData.fieldOrder.isNotEmpty)
                        Builder(builder: (context) {
                          int i = controller.setDefaultData.fieldOrder.indexWhere((p0) => p0['type'] == 'tenantid');
                          return SizedBox(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: ColorTheme.kScaffoldColor,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: CustomTooltip(
                                    message:
                                        "${controller.setDefaultData.fieldOrder[i]['field']['subfield'][index]['text']}${(data[controller.setDefaultData.fieldOrder[i]['field']['subfield'][index]['field']]).toString().isNullOrEmpty ? '' : "\n${data[controller.setDefaultData.fieldOrder[i]['field']['subfield'][index]['field']]}"}",
                                    textAlign: TextAlign.center,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: ColorTheme.kPrimaryColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${controller.setDefaultData.fieldOrder[i]['field']['subfield'][index]['text'][0]}',
                                          style: GoogleFonts.novaMono(
                                            fontSize: 14,
                                            fontWeight: FontTheme.notoSemiBold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(
                                width: 4,
                              ),
                              itemCount: controller.setDefaultData.fieldOrder[i]['field']['subfield'].length,
                            ),
                          );
                        })
                    ],
                  ),
                ).paddingOnly(bottom: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: data['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        padding: const EdgeInsets.all(4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Visibility(
                            visible: (ownerImage.url ?? '').toString().isNotNullOrEmpty,
                            replacement: SvgPicture.asset(AssetsString.kUser),
                            child: Image.network(
                              ownerImage.url ?? '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(4),
                              bottomRight: Radius.circular(4),
                            ),
                            border: Border(
                              left: BorderSide(
                                color: data['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextWidget(
                                      text: data['tenantname'] ?? "",
                                      color: ColorTheme.kPrimaryColor,
                                      fontSize: 12,
                                      textOverflow: TextOverflow.visible,
                                      fontWeight: FontTheme.notoBold,
                                    ),
                                  ),
                                ).paddingOnly(bottom: 8),
                                (data['committeedesignation'] ?? []).length == 0
                                    ? const SizedBox.shrink()
                                    : SizedBox(
                                        height: 22,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: ColorTheme.kBlack.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: TextWidget(
                                                text: data['committeedesignation'][index]['committeedesignation'],
                                                fontWeight: FontTheme.notoMedium,
                                                fontSize: 10,
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) => const SizedBox(
                                            width: 4,
                                          ),
                                          itemCount: (data['committeedesignation'] ?? []).length,
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: ColorTheme.kScaffoldColor,
                    border: Border.all(
                      color: ColorTheme.kBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Visibility(
                          visible: (data['tenantcontactno'] ?? []).length + (data['tenantemail'].toString().isNotNullOrEmpty ? 1 : 0) > 0,
                          child: SizedBox(
                            height: 32,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: ColorTheme.kWhite,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: CustomTooltip(
                                  message: index < (data['tenantcontactno'] ?? []).length ? (data['tenantcontactno'][index]) : data['tenantemail'],
                                  textAlign: TextAlign.center,
                                  child: SvgPicture.asset(
                                    index == (data['tenantcontactno'] ?? []).length ? AssetsString.kEmail : AssetsString.kPhone,
                                  ),
                                ),
                              ),
                              separatorBuilder: (context, index) => const SizedBox(
                                width: 4,
                              ),
                              itemCount: (data['tenantcontactno'] ?? []).length + (data['tenantemail'].toString().isNotNullOrEmpty ? 1 : 0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: ColorTheme.kWhite,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: index == 0
                                    ? CustomTooltip(
                                        message: "Aadhaar No${(data['tenantaadharno']).toString().isNullOrEmpty ? '' : "\n${data['tenantaadharno']}"}",
                                        textAlign: TextAlign.center,
                                        child: InkWell(
                                          onTap: (data['tenantaadharimage'] ?? {})['url'].toString().isNullOrEmpty
                                              ? null
                                              : () {
                                                  documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(data['tenantaadharimage'] ?? {})));
                                                },
                                          child: Image.asset(
                                            opacity: AlwaysStoppedAnimation(
                                              data['tenantaadharno'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                            ),
                                            AssetsString.kAadhar,
                                          ),
                                        ),
                                      )
                                    : index == 1
                                        ? CustomTooltip(
                                            message: "Voter Id No${(data['tenantvoterid']).toString().isNullOrEmpty ? '' : "\n${data['tenantvoterid']}"}",
                                            textAlign: TextAlign.center,
                                            child: InkWell(
                                              onTap: (data['tenantvoterimage'] ?? {})['url'].toString().isNullOrEmpty
                                                  ? null
                                                  : () {
                                                      documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(data['tenantvoterimage'] ?? {})));
                                                    },
                                              child: Image.asset(
                                                opacity: AlwaysStoppedAnimation(
                                                  data['tenantvoterid'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                                ),
                                                AssetsString.kElectionCard,
                                              ),
                                            ),
                                          )
                                        : index == 2
                                            ? CustomTooltip(
                                                message: "Pan No${(data['tenantpan']).toString().isNullOrEmpty ? '' : "\n${data['tenantpan']}"}",
                                                textAlign: TextAlign.center,
                                                child: InkWell(
                                                  onTap: (data['tenantpanimage'] ?? {})['url'].toString().isNullOrEmpty
                                                      ? null
                                                      : () {
                                                          documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(data['tenantpanimage'] ?? {})));
                                                        },
                                                  child: Image.asset(
                                                    opacity: AlwaysStoppedAnimation(
                                                      data['tenantpan'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                                    ),
                                                    AssetsString.kPanCard,
                                                  ),
                                                ),
                                              )
                                            : index == 3
                                                ? CustomTooltip(
                                                    message: "Ration Card No${(data['tenantrationcard']).toString().isNullOrEmpty ? '' : "\n${data['tenantrationcard']}"}",
                                                    textAlign: TextAlign.center,
                                                    child: InkWell(
                                                      onTap: (data['tenantrationcardimage'] ?? {})['url'].toString().isNullOrEmpty
                                                          ? null
                                                          : () {
                                                              documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(data['tenantrationcardimage'] ?? {})));
                                                            },
                                                      child: Image.asset(
                                                        opacity: AlwaysStoppedAnimation(
                                                          data['tenantrationcard'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                                        ),
                                                        AssetsString.kRationCard,
                                                      ),
                                                    ))
                                                : const SizedBox.shrink(),
                              ),
                              separatorBuilder: (context, index) => const SizedBox(
                                width: 4,
                              ),
                              itemCount: 4,
                            ),
                          ],
                        ),
                      ).paddingOnly(right: 4.5),
                      Row(
                        children: [
                          tooltipHome(
                            title: 'Internal Photos',
                            image: AssetsString.kInternalHome,
                            imageList: FilesDataModel().fromJsonList(List<Map<String, dynamic>>.from(data['internalimages'] ?? [])),
                          ).paddingOnly(right: 4),
                          tooltipHome(
                            title: 'External Photos',
                            image: AssetsString.kExternalHome,
                            imageList: FilesDataModel().fromJsonList(List<Map<String, dynamic>>.from(data['externalimages'] ?? [])),
                          ),
                        ],
                      )
                    ],
                  ),
                ).paddingOnly(bottom: 8),
                Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ColorTheme.kScaffoldColor,
                      border: Border.all(
                        color: ColorTheme.kBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 32,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) => Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: ColorTheme.kWhite,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: index == 0
                                        ? CustomTooltip(
                                            message: "Hutment Use${(data['hutmentusetypename']).toString().isNullOrEmpty ? '' : "\n${data['hutmentusetypename']}"}",
                                            textAlign: TextAlign.center,
                                            child: SvgPicture.asset(
                                              AssetsString.kHome,
                                            ),
                                          )
                                        : index == 1
                                            ? CustomTooltip(
                                                message: "Eligibility${(data['eligibilityname']).toString().isNullOrEmpty ? '' : "\n${data['eligibilityname']}"}",
                                                textAlign: TextAlign.center,
                                                child: SvgPicture.asset(
                                                  AssetsString.kEligible,
                                                  colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['eligibilityname'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                ),
                                              )
                                            : index == 2
                                                ? CustomTooltip(
                                                    message: "Non-Survey Structure${(data['xpartname']).toString().isNullOrEmpty ? '' : "\n${data['xpartname']}"}",
                                                    textAlign: TextAlign.center,
                                                    child: SvgPicture.asset(
                                                      AssetsString.kXPart,
                                                      colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['xpartname'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                  ),
                                  separatorBuilder: (context, index) => const SizedBox(
                                    width: 4,
                                  ),
                                  itemCount: 3,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                color: ColorTheme.kWhite,
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsString.kReceipt,
                                      ),
                                      const VerticalDivider(),
                                      Expanded(
                                        child: SizedBox(
                                          height: 30,
                                          child: ListView.separated(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) => Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                color: ColorTheme.kBackgroundColor,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: index == 0
                                                  ? InkWell(
                                                      onTap: () {
                                                        IISMethods().getDocumentHistory(tenantId: data['_id'] ?? "", documentType: 'House Tax', pagename: controller.formName.value);
                                                      },
                                                      child: CustomTooltip(
                                                        message: "House Tax${(data['housetax']).toString().isNullOrEmpty ? '' : "\n${data['housetax']}"}",
                                                        textAlign: TextAlign.center,
                                                        child: SvgPicture.asset(
                                                          AssetsString.kHome2,
                                                          colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['housetax'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                        ),
                                                      ),
                                                    )
                                                  : index == 1
                                                      ? InkWell(
                                                          onTap: () {
                                                            IISMethods().getDocumentHistory(tenantId: data['_id'] ?? "", documentType: 'Water Connection', pagename: controller.formName.value);
                                                          },
                                                          child: CustomTooltip(
                                                            message: "Water Connection${(data['watertaxbill']).toString().isNullOrEmpty ? '' : "\n${data['watertaxbill']}"}",
                                                            textAlign: TextAlign.center,
                                                            child: SvgPicture.asset(
                                                              AssetsString.kWater,
                                                              colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['watertaxbill'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                            ),
                                                          ),
                                                        )
                                                      : index == 2
                                                          ? InkWell(
                                                              onTap: () {
                                                                IISMethods().getDocumentHistory(tenantId: data['_id'] ?? "", documentType: 'Electric Bill', pagename: controller.formName.value);
                                                              },
                                                              child: CustomTooltip(
                                                                message: "Electric Bill${(data['elecricitybill']).toString().isNullOrEmpty ? '' : "\n${data['elecricitybill']}"}",
                                                                textAlign: TextAlign.center,
                                                                child: SvgPicture.asset(
                                                                  AssetsString.kElectricity,
                                                                  colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['elecricitybill'] == null ? 0.2 : 1), BlendMode.srcIn),
                                                                ),
                                                              ),
                                                            )
                                                          : index == 3
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    IISMethods().getDocumentHistory(tenantId: data['_id'] ?? "", documentType: 'Gumasta License', pagename: controller.formName.value);
                                                                  },
                                                                  child: CustomTooltip(
                                                                    message: "Gumasta License No${(data['gumastalicense']).toString().isNullOrEmpty ? '' : "\n${data['gumastalicense']}"}",
                                                                    textAlign: TextAlign.center,
                                                                    child: SvgPicture.asset(
                                                                      AssetsString.kGumasta,
                                                                      colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['gumastalicense'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
                                                                    ),
                                                                  ),
                                                                )
                                                              : index == 4
                                                                  ? InkWell(
                                                                      onTap: () {
                                                                        IISMethods().getDocumentHistory(tenantId: data['_id'] ?? "", documentType: 'Family NOC', pagename: controller.formName.value);
                                                                      },
                                                                      child: CustomTooltip(
                                                                        message: "Family NOC",
                                                                        textAlign: TextAlign.center,
                                                                        child: SvgPicture.asset(
                                                                          AssetsString.kFamilyNOC,
                                                                          colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity((data['familynocimage']?['url']).toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : const SizedBox.shrink(),
                                            ),
                                            separatorBuilder: (context, index) => const SizedBox(
                                              width: 4,
                                            ),
                                            itemCount: 5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 38,
                                padding: const EdgeInsets.all(4),
                                color: ColorTheme.kWhite,
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsString.kRuler,
                                      ),
                                      const VerticalDivider(),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            TextWidget(
                                              text: 'MEAS',
                                              fontWeight: FontTheme.notoSemiBold,
                                              fontSize: 10,
                                              textOverflow: TextOverflow.ellipsis,
                                              color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                            ),
                                            const Spacer(),
                                            TextWidget(
                                              text: (data['measurement']).toString().isNullOrEmpty ? " - " : '${data['measurement'] ?? ""} Sq. Ft.',
                                              fontWeight: FontTheme.notoSemiBold,
                                              fontSize: 12,
                                              color: ColorTheme.kPrimaryColor,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // const SizedBox(
                                      //   width: 8,
                                      // ),
                                      // Expanded(
                                      //   flex: 3,
                                      //   child: Row(
                                      //     children: [
                                      //       TextWidget(
                                      //         text: 'EXTERIOR',
                                      //         fontWeight: FontTheme.notoSemiBold,
                                      //         fontSize: 10,
                                      //         textOverflow: TextOverflow.ellipsis,
                                      //         color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                      //       ),
                                      //       const Spacer(),
                                      //       const TextWidget(
                                      //         text: '380 Sq. Ft.',
                                      //         fontWeight: FontTheme.notoSemiBold,
                                      //         fontSize: 12,
                                      //         textOverflow: TextOverflow.ellipsis,
                                      //         color: ColorTheme.kPrimaryColor,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Container(
                              padding: const EdgeInsets.all(4),
                              color: ColorTheme.kWhite,
                              child: Row(
                                children: [
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: ColorTheme.kWhite,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: CustomTooltip(
                                        message: 'Tenant Expired ?',
                                        textAlign: TextAlign.center,
                                        child: InkWell(
                                          onTap: () async {
                                            controller.handleTenantExpired(id: data['_id'], index: controller.setDefaultData.data.indexWhere((element) => element['_id'] == data['_id']));
                                          },
                                          child: SvgPicture.asset(
                                            AssetsString.kUserExpired,
                                          ),
                                        )),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: ColorTheme.kWhite,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: CustomTooltip(
                                      message: 'Hutment Sold',
                                      textAlign: TextAlign.center,
                                      child: InkWell(
                                          onTap: () async {
                                            controller.handleHutmentSold(index: controller.setDefaultData.data.indexWhere((element) => element['_id'] == data['_id']), id: data['_id']);
                                          },
                                          child: SvgPicture.asset(
                                            AssetsString.kSold,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
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
                                            CustomDialogs().customPopDialog(child: Obx(() {
                                              return StatusHistoryDialog(
                                                data: data,
                                                statusList: controller.setDefaultData.masterDataList['tenantstatus'] ?? [],
                                              );
                                            }));
                                          },
                                          child: SvgPicture.asset(AssetsString.kCalender)),
                                    ),
                                  ),
                                ],
                              ),
                            ))
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    bottomLeft: Radius.circular(4),
                                  ),
                                  border: Border.all(
                                    color: ColorTheme.kPrimaryColor,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(6),
                                child: PopupMenuButton(
                                  offset: const Offset(-5, 36),
                                  constraints: const BoxConstraints(
                                    minWidth: 135,
                                  ),
                                  enabled: isEditVisible,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  tooltip: '',
                                  surfaceTintColor: ColorTheme.kWhite,
                                  shadowColor: ColorTheme.kBlack,
                                  elevation: 6,
                                  popUpAnimationStyle: AnimationStyle(
                                    curve: Curves.bounceInOut,
                                  ),
                                  position: PopupMenuPosition.over,
                                  padding: EdgeInsets.zero,
                                  color: ColorTheme.kWhite,
                                  itemBuilder: (context) {
                                    return [
                                      ...List.generate(
                                        (controller.setDefaultData.masterDataList['tenantstatus'] ?? []).length,
                                        (stageIndex) {
                                          return CommonDataTableWidget.menuOption(
                                            onTap: () async {
                                              await controller.handleKanbanGridChange(
                                                  type: HtmlControls.kTenantStatus,
                                                  field: 'tenantstatusid',
                                                  value: controller.setDefaultData.masterDataList['tenantstatus'][stageIndex]['_id'],
                                                  data: data,
                                                  index: index,
                                                  isMobile: sizeInformation.isMobile);

                                              /// because of no data update on status change that's why getKanbanData() call
                                              !sizeInformation.isMobile ? controller.kanbanData.value = await controller.getKanbanData() : null;
                                            },
                                            btnName: controller.setDefaultData.masterDataList['tenantstatus'][stageIndex]['status'],
                                            svgImageUrl: controller.setDefaultData.masterDataList['tenantstatus'][stageIndex]['image'],
                                          );
                                        },
                                      )
                                    ];
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(0),
                                        child: Obx(() {
                                          try {
                                            if (((controller.setDefaultData.masterDataList['tenantstatus'] ?? []) as List).isNotNullOrEmpty) {
                                              return SvgPicture.network(
                                                ((controller.setDefaultData.masterDataList['tenantstatus'] ?? []) as List).isNotNullOrEmpty
                                                    ? ((controller.setDefaultData.masterDataList['tenantstatus'] ?? [{}]).firstWhere((element) {
                                                              return element['_id'].toString() == data['tenantstatusid'].toString();
                                                            }) ??
                                                            {})['image'] ??
                                                        ''
                                                    : '',
                                              );
                                            }
                                            return const SizedBox();
                                          } catch (e) {
                                            return const SizedBox.shrink();
                                          }
                                        }),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down_rounded, size: 18)
                                    ],
                                  ),
                                ),
                                // child: ,
                              ),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: ColorTheme.kPrimaryColor,
                                          width: 1,
                                        ),
                                        top: BorderSide(
                                          color: ColorTheme.kPrimaryColor,
                                          width: 1,
                                        ),
                                        right: BorderSide(
                                          color: ColorTheme.kPrimaryColor,
                                          width: 1,
                                        ),
                                      )),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget(
                                        text: ("${data['tenantstatus'] ?? ""} Date").toString().toUpperCase(),
                                        color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                        fontSize: 10,
                                        fontWeight: FontTheme.notoBold,
                                      ),
                                      TextWidget(
                                        text: (data["${data['tenantstatusid'] ?? ""}_date"]).toString().toDateFormat().toUpperCase(),
                                        color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                        fontSize: 10,
                                        fontWeight: FontTheme.notoBold,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 8,
                ),
                Builder(builder: (context) {
                  bool isExpanded = false;
                  // Map rent = {};
                  // try {
                  //   rent = ((List.from(data['rentdetails']).isNullOrEmpty ? [{}] : List.from(data['rentdetails'])) as List?)?.lastWhere(
                  //     (element) {
                  //       return element['paymenttypeid'] == '6639a3b42a3062b9e51b0154' && element['isdelete'] != 1;
                  //     },
                  //     orElse: () {
                  //       return ((List.from(data['rentdetails']).isNullOrEmpty ? [{}] : List.from(data['rentdetails'])) as List?)?.last;
                  //     },
                  //   );
                  // } catch (e) {}
                  List rentDetailList = [];
                  try {
                    rentDetailList = ((List.from(data['rentdetails']).isNullOrEmpty ? [] : List.from(data['rentdetails'])) as List?)!;
                  } catch (e) {}

                  return StatefulBuilder(builder: (context, setState) {
                    return Container(
                      width: 600,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: ColorTheme.kScaffoldColor,
                        border: Border.all(
                          color: ColorTheme.kBorderColor,
                          width: 1,
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          listTileTheme: ListTileTheme.of(context).copyWith(dense: true, minVerticalPadding: 4),
                        ),
                        child: ExpansionTile(
                          dense: true,
                          onExpansionChanged: (value) {
                            setState(
                              () {
                                isExpanded = value;
                              },
                            );
                          },
                          // tilePadding: EdgeInsets.zero,
                          // childrenPadding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          title: Center(
                            child: TextWidget(
                              text: (isExpanded ? 'Show Less' : 'Show More').toUpperCase(),
                              fontSize: 10,
                              color: ColorTheme.kPrimaryColor,
                              fontWeight: FontTheme.notoMedium,
                            ),
                          ),
                          backgroundColor: ColorTheme.kScaffoldColor,
                          leading: const SizedBox.shrink(),
                          tilePadding: const EdgeInsets.symmetric(horizontal: 4),
                          iconColor: ColorTheme.kBlack,
                          collapsedIconColor: ColorTheme.kBlack,
                          // trailing: Container(
                          //   decoration: BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       border: Border.all(
                          //         color: ColorTheme.kBlack,
                          //         width: 1,
                          //       )),
                          //   child: Icon(isExpanded ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,color: ColorTheme.kBlack,),
                          // ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: [
                                  // if (rent.isNotNullOrEmpty)
                                  //   Container(
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(4),
                                  //       color: ColorTheme.kScaffoldColor,
                                  //       border: Border.all(
                                  //         color: ColorTheme.kBorderColor,
                                  //         width: 1,
                                  //       ),
                                  //     ),
                                  //     padding: const EdgeInsets.all(4),
                                  //     child: Container(
                                  //       decoration: BoxDecoration(
                                  //         borderRadius: BorderRadius.circular(4),
                                  //         color: ColorTheme.kWhite,
                                  //       ),
                                  //       padding: const EdgeInsets.all(4),
                                  //       child: Column(
                                  //         crossAxisAlignment: CrossAxisAlignment.start,
                                  //         children: [
                                  //           if ((rent['paymenttypename']).toString().isNotNullOrEmpty) ...[
                                  //             Row(
                                  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //               children: [
                                  //                 TextWidget(
                                  //                   text: (rent['paymenttypename'] ?? '').toString().toUpperCase(),
                                  //                   color: ColorTheme.kPrimaryColor,
                                  //                   fontWeight: FontTheme.notoSemiBold,
                                  //                   fontSize: 12,
                                  //                 ),
                                  //                 CustomTooltip(
                                  //                   message: 'PAYMENT HISTORY',
                                  //                   child: InkResponse(
                                  //                     onTap: () {
                                  //                       CustomDialogs().customFilterDialogs(
                                  //                           context: Get.context!,
                                  //                           widget: InfoForm(
                                  //                             widthOfDialog: 500,
                                  //                             infoPopUpWidget: RentHistoryDialog(data: data['rentdetails'] ?? []),
                                  //                             isHeaderShow: false,
                                  //                           ));
                                  //                     },
                                  //                     child: const Icon(
                                  //                       Icons.info_outline_rounded,
                                  //                       size: 15,
                                  //                       color: ColorTheme.kPrimaryColor,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //             const Divider(),
                                  //           ],
                                  //           slotPaymentRow(title: rent['paymenttypefrequency'] == 2 ? 'Start Date' : 'Date', value: (rent['startdate'] ?? '-')),
                                  //           if (rent['paymenttypefrequency'] == 2) slotPaymentRow(title: 'End Date', value: (rent['enddate'] ?? '-')),
                                  //           const Divider(),
                                  //           if (rent['rentinmonth'].toString().isNotNullOrEmpty || rent['noofmonths'].toString().isNotNullOrEmpty) ...[
                                  //             Row(children: [
                                  //               CustomTooltip(
                                  //                 message: 'Rent per Month',
                                  //                 child: Container(
                                  //                   decoration: BoxDecoration(
                                  //                     color: ColorTheme.kBackgroundColor,
                                  //                     borderRadius: BorderRadius.circular(4),
                                  //                   ),
                                  //                   padding: const EdgeInsets.all(4),
                                  //                   child: SvgPicture.asset(
                                  //                     AssetsString.kCalender,
                                  //                     height: 15,
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //               const SizedBox(width: 10),
                                  //               TextWidget(
                                  //                 text: '${(rent['rentinmonth'] ?? '').toString().toAmount()} * ${(rent['noofmonths'] ?? '')}M',
                                  //                 color: ColorTheme.kPrimaryColor,
                                  //                 fontWeight: FontTheme.notoRegular,
                                  //                 fontSize: 12,
                                  //               ),
                                  //             ]),
                                  //             const SizedBox(height: 8)
                                  //           ],
                                  //           TextWidget(
                                  //             text: (rent['totalrent'] ?? '').toString().toAmount(),
                                  //             color: ColorTheme.kPrimaryColor,
                                  //             fontWeight: FontTheme.notoSemiBold,
                                  //             fontSize: 12,
                                  //           ),
                                  //           Visibility(
                                  //             visible: rent['shiftingcharge'].toString().isNotNullOrEmpty,
                                  //             child: const Divider(),
                                  //           ),
                                  //           Visibility(
                                  //             visible: rent['shiftingcharge'].toString().isNotNullOrEmpty,
                                  //             child: Row(
                                  //               children: [
                                  //                 CustomTooltip(
                                  //                   message: 'Shifting Charges',
                                  //                   child: Container(
                                  //                     decoration: BoxDecoration(
                                  //                       color: ColorTheme.kBackgroundColor,
                                  //                       borderRadius: BorderRadius.circular(4),
                                  //                     ),
                                  //                     padding: const EdgeInsets.all(4),
                                  //                     child: SvgPicture.asset(
                                  //                       AssetsString.kLoadingTruck,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 const SizedBox(width: 10),
                                  //                 TextWidget(
                                  //                   text: (rent['shiftingcharge'] ?? '').toString().toAmount(),
                                  //                   color: ColorTheme.kPrimaryColor,
                                  //                   fontWeight: FontTheme.notoRegular,
                                  //                   fontSize: 12,
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),

                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: ColorTheme.kScaffoldColor,
                                      border: Border.all(
                                        color: ColorTheme.kBorderColor,
                                        width: 1,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Container(
                                      color: ColorTheme.kWhite,
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        children: [
                                          ...commonDocumentView(id: data['_id'] ?? "", showDivider: false, formName: controller.formName.value, obj: [
                                            {
                                              'name': 'Attended Common Consent',
                                              'value': data['attendedcommonconsent'] == 1 ? 'YES' : 'NO',
                                              'url': data['commonconsentfile'] ?? {},
                                            },
                                            {
                                              'name': 'Individual Consent',
                                              'value': data['individualconsentname'] ?? '',
                                              'url': data['individualconsentfile'] ?? {},
                                            },
                                            {
                                              'name': 'Individual Agreement',
                                              'value': data['individualagreementname'] ?? '',
                                              'url': data['individualagreementfile'] ?? {},
                                            },
                                          ]),
                                          ...commonDocumentView(id: data['_id'] ?? "", formName: controller.formName.value, obj: [
                                            {
                                              'name': 'Attended GBR',
                                              'value': data['attendedgeneralbodyresolution'] == 1 ? 'YES' : 'NO',
                                              'url': {},
                                            },
                                            {
                                              'name': 'Survey',
                                              'url': data['annexuresurveydoc'] ?? {},
                                            },
                                            {
                                              'name': 'Rent Agreement',
                                              'url': data['rentagreementdoc'] ?? {},
                                            },
                                            {
                                              'name': 'Dislocation Allowance',
                                              'url': data['dislocationallowancedoc'] ?? {},
                                            },
                                          ]),
                                          ...commonDocumentView(id: data['_id'] ?? "", formName: controller.formName.value, obj: [
                                            {
                                              'name': 'Survey Slip',
                                              'url': data['surveyslip'] ?? {},
                                            },
                                            {
                                              'name': 'Hut Photo Pass',
                                              'url': data['hutphotopass'] ?? {},
                                            },
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),

                                  if (rentDetailList.isNotNullOrEmpty)
                                    Container(
                                      // width: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: ColorTheme.kScaffoldColor,
                                        border: Border.all(
                                          color: ColorTheme.kBorderColor,
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: Container(
                                        color: ColorTheme.kWhite,
                                        child: CustomShimmer(
                                          isLoading: isLoading,
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                color: ColorTheme.kBackGroundGrey,
                                                child: const Row(
                                                  children: [
                                                    Expanded(
                                                        child: TextWidget(
                                                      text: 'Payment Type',
                                                    )),
                                                    Expanded(
                                                        child: TextWidget(
                                                      text: 'Total Payment',
                                                      textAlign: TextAlign.right,
                                                    )),
                                                    Expanded(
                                                        child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextWidget(
                                                            text: 'Request Slot',
                                                            textAlign: TextAlign.right,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 30,
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ).paddingAll(2),
                                              ),
                                              if (rentDetailList.isNullOrEmpty)
                                                const SizedBox(
                                                  height: 70,
                                                  child: Center(
                                                    child: TextWidget(text: 'No Payment Data Found'),
                                                  ),
                                                )
                                              else
                                                Container(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ...List.generate(
                                                        rentDetailList.length,
                                                        (index) {
                                                          Map rent = rentDetailList[index];
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                      child: TextWidget(
                                                                    fontSize: 12,
                                                                    text: rent['paymenttypename'],
                                                                  )),
                                                                  Expanded(
                                                                      child: Column(
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
                                                                      TextWidget(
                                                                        fontSize: 12,
                                                                        text: rent['totalrent'].toString().isNotNullOrEmpty ? rent['totalrent'].toString().toAmount() : '-',
                                                                        textAlign: TextAlign.right,
                                                                        fontWeight: FontTheme.notoBold,
                                                                      ),
                                                                    ],
                                                                  )),
                                                                  Expanded(
                                                                      child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: TextWidget(
                                                                          fontSize: 12,
                                                                          text: rent['requestslotname'].toString().isNotNullOrEmpty ? rent['requestslotname'].toString() : '-',
                                                                          textAlign: TextAlign.right,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                        child: InkResponse(
                                                                          onTap: () {
                                                                            CustomDialogs().customFilterDialogs(
                                                                                context: Get.context!,
                                                                                widget: InfoForm(
                                                                                  widthOfDialog: 500,
                                                                                  infoPopUpWidget: RentHistoryDialog(data: [rent]),
                                                                                  isHeaderShow: false,
                                                                                ));
                                                                          },
                                                                          child: const Icon(
                                                                            Icons.info_outline_rounded,
                                                                            size: 14,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )),
                                                                ],
                                                              ).paddingAll(2),
                                                              if (rentDetailList.length - 1 > index) const Divider(),
                                                            ],
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                }),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        ),
      );
    });
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
// Widget tooltipHome({String? title, required String image, required List<FilesDataModel> imageList}) {
//   return CustomTooltip(
//     message: title,
//     child: InkWell(
//       onTap: imageList.isNullOrEmpty
//           ? null
//           : () {
//               Get.dialog(Dialog(
//                 surfaceTintColor: ColorTheme.kWhite,
//                 clipBehavior: Clip.antiAlias,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     SizedBox(
//                       height: 450,
//                       width: 700,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           ClipRRect(
//                             child: CarouselSlider(
//                               carouselController: controller.carouselController,
//                               items: imageList.map(
//                                 (image) {
//                                   return SizedBox(
//                                     width: 700,
//                                     child: FastCachedImage(
//                                       url: image.url ?? "",
//                                       height: Get.height,
//                                       fit: BoxFit.cover,
//                                       fadeInDuration: const Duration(seconds: 1),
//                                       errorBuilder: (context, exception, stacktrace) {
//                                         return const Opacity(
//                                           opacity: 0.3,
//                                           child: PrenewLogo(
//                                             size: 150,
//                                             showName: true,
//                                           ),
//                                         );
//                                       },
//                                       loadingBuilder: (context, progress) {
//                                         return Container(
//                                           color: ColorTheme.kWhite.withOpacity(0.2),
//                                           child: Stack(
//                                             alignment: Alignment.center,
//                                             children: [
//                                               // if (progress.isDownloading && progress.totalBytes != null) Text('${progress.downloadedBytes ~/ 1024} / ${progress.totalBytes! ~/ 1024} kb', style: const TextStyle(color: ColorTheme.kBlack)),
//                                               SizedBox(width: 80, height: 80, child: CircularProgressIndicator(color: ColorTheme.kBlack, value: progress.progressPercentage.value)),
//                                             ],
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   );
//                                 },
//                               ).toList(),
//                               options: CarouselOptions(
//                                 viewportFraction: 1,
//                                 height: Get.height * 0.65,
//                                 autoPlay: true,
//                                 autoPlayInterval: const Duration(milliseconds: 5000),
//                                 pauseAutoPlayOnTouch: true,
//                                 onPageChanged: (index, reason) {
//                                   controller.currentIndex.value = index;
//                                   controller.galleryController.scrollToIndex(
//                                     index,
//                                     preferPosition: AutoScrollPosition.middle,
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 HoverBuilder(
//                                   builder: (isHovered) => AnimatedOpacity(
//                                     duration: const Duration(milliseconds: 300),
//                                     opacity: isHovered ? 1 : 0.2,
//                                     child: InkResponse(
//                                       onTap: () {
//                                         controller.carouselController.previousPage(
//                                           curve: Curves.easeIn,
//                                         );
//                                       },
//                                       child: CircleAvatar(
//                                         backgroundColor: ColorTheme.kBlack.withOpacity(.8),
//                                         child: const Padding(
//                                           padding: EdgeInsets.all(8),
//                                           child: Icon(
//                                             Icons.arrow_back_ios_new_outlined,
//                                             color: ColorTheme.kWhite,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 HoverBuilder(
//                                   builder: (isHovered) => AnimatedOpacity(
//                                     duration: const Duration(milliseconds: 300),
//                                     opacity: isHovered ? 1 : 0.2,
//                                     child: InkResponse(
//                                       onTap: () {
//                                         controller.carouselController.nextPage(
//                                           curve: Curves.easeIn,
//                                         );
//                                       },
//                                       child: CircleAvatar(
//                                         backgroundColor: ColorTheme.kBlack.withOpacity(.8),
//                                         child: const Padding(
//                                           padding: EdgeInsets.all(8),
//                                           child: Icon(
//                                             Icons.arrow_forward_ios_outlined,
//                                             color: ColorTheme.kWhite,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Align(
//                             alignment: Alignment.topRight,
//                             child: HoverBuilder(
//                               builder: (isHovered) => AnimatedOpacity(
//                                 duration: const Duration(milliseconds: 300),
//                                 opacity: isHovered ? 1 : 0.2,
//                                 child: InkResponse(
//                                   onTap: () {
//                                     Get.back();
//                                   },
//                                   child: CircleAvatar(
//                                     radius: 15,
//                                     backgroundColor: ColorTheme.kBlack.withOpacity(.8),
//                                     child: const Padding(
//                                       padding: EdgeInsets.all(1),
//                                       child: Icon(
//                                         Icons.clear_rounded,
//                                         color: ColorTheme.kWhite,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ).paddingAll(6)
//                         ],
//                       ),
//                     ),
//                     Container(
//                       height: 100,
//                       width: 700,
//                       color: ColorTheme.kBlack.withOpacity(0.85),
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: imageList.length,
//                         controller: controller.galleryController,
//                         itemBuilder: (context, index) {
//                           return AutoScrollTag(
//                             key: ValueKey(index),
//                             index: index,
//                             controller: controller.galleryController,
//                             child: InkWell(
//                               onTap: () {
//                                 controller.carouselController.animateToPage(index);
//                               },
//                               child: Obx(
//                                 () => AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   // Adjust the duration as per your preference
//                                   width: controller.currentIndex.value == index ? 150 : 90,
//                                   height: 100,
//                                   decoration: BoxDecoration(
//                                     border: controller.currentIndex.value == index ? Border.all(color: ColorTheme.kBlack, width: 2.5) : null,
//                                   ),
//                                   child: FastCachedImage(
//                                     url: imageList[index].url ?? "",
//                                     fit: BoxFit.cover,
//                                     fadeInDuration: const Duration(seconds: 1),
//                                     errorBuilder: (context, exception, stacktrace) {
//                                       return const Opacity(
//                                         opacity: 0.3,
//                                         child: PrenewLogo(
//                                           size: 50,
//                                         ),
//                                       );
//                                     },
//                                     loadingBuilder: (context, progress) {
//                                       return Container(
//                                         color: ColorTheme.kWhite.withOpacity(0.2),
//                                         child: Stack(
//                                           alignment: Alignment.center,
//                                           children: [
//                                             // if (progress.isDownloading && progress.totalBytes != null) Text('${progress.downloadedBytes ~/ 1024} / ${progress.totalBytes! ~/ 1024} kb', style: const TextStyle(color: ColorTheme.kBlack)),
//                                             SizedBox(width: 80, height: 80, child: CircularProgressIndicator(color: ColorTheme.kBlack, value: progress.progressPercentage.value)),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ));
//             },
//       child: Builder(builder: (context) {
//         return Container(
//           decoration: BoxDecoration(
//             color: ColorTheme.kWhite,
//             borderRadius: BorderRadius.circular(4),
//           ),
//           padding: const EdgeInsets.all(4),
//           child: Opacity(
//             opacity: imageList.isNullOrEmpty ? 0.1 : 1,
//             child: Image.asset(
//               image,
//               height: 23,
//               width: 22,
//             ),
//           ),
//         );
//       }),
//     ),
//   );
// }
}
