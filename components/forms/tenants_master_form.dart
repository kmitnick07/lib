import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_drag_file_area.dart';
import 'package:prestige_prenew_frontend/components/customs/measure_size.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/hover_builder.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/controller/tenant_master_controller.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../config/helper/device_service.dart';
import '../../config/helper/offline_data.dart';
import '../../config/iis_method.dart';
import '../../view/CommonWidgets/common_table.dart';
import '../customs/custom_text_form_field.dart';
import '../customs/custom_tooltip.dart';
import '../customs/drop_down_search_custom.dart';
import '../customs/multi_drop_down_custom.dart';
import '../funtions.dart';

class TenantsMasterForm extends GetView<TenantMasterController> {
  TenantsMasterForm({
    super.key,
    this.isMasterForm = false,
    this.oldData,
  });

  final bool isMasterForm;
  Map? oldData;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      surfaceTintColor: ColorTheme.kScaffoldColor,
      backgroundColor: ColorTheme.kScaffoldColor,
      alignment: Alignment.centerRight,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
      insetPadding: EdgeInsets.zero,
      child: WillPopScope(
        onWillPop: () async {
          if (!kIsWeb) {
            bool canPop = false;
            await CustomDialogs().customDialog(
                buttonCount: 2,
                content: 'Are you sure you want to leave this page? Your form will be cleared if you proceed.',
                onTapPositive: () {
                  Get.back();
                  canPop = true;
                });
            if (canPop) {
              Get.back();
            }
          }
          return Future(() => false);
        },
        // canPop: kIsWeb,
        // onPopInvoked: (didPop) async {
        //   if (!kIsWeb) {
        //     bool canPop = false;
        //     await CustomDialogs().customDialog(
        //         buttonCount: 2,
        //         content: 'Are you sure you want to leave this page? Your form will be cleared if you proceed.',
        //         onTapPositive: () {
        //           Get.back();
        //           canPop = true;
        //         });
        //     if (canPop) {
        //       Get.back();
        //     }
        //   }
        // },
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) => ColoredBox(
            color: ColorTheme.kScaffoldColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 24.0,
                    left: 24.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              InkWell(
                                focusNode: FocusNode(skipTraversal: true),
                                onTap: () {
                                  Get.back();
                                },
                                child: TextWidget(
                                  fontSize: 18,
                                  color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                  fontWeight: FontWeight.w500,
                                  text: 'Tenants SRA / ',
                                ),
                              ),
                              Obx(() {
                                return TextWidget(
                                  fontSize: 18,
                                  color: ColorTheme.kPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                  text: controller.formName.value,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      // if (sizingInformation.isDesktop)
                      //   Obx(() {
                      //     int currentStatusIndex = List<Map<String, dynamic>>.from(controller.setDefaultData.masterDataList['tenantstatus'] ?? [])
                      //         .indexWhere((element) => element['_id'] == controller.setDefaultData.formData['tenantstatusid']);
                      //     return SizedBox(
                      //       height: 50,
                      //       child: ListView.builder(
                      //         scrollDirection: Axis.horizontal,
                      //         itemCount: (controller.setDefaultData.masterDataList['tenantstatus'] ?? []).length,
                      //         shrinkWrap: true,
                      //         itemBuilder: (context, index) {
                      //           Map<String, dynamic> status = Map<String, dynamic>.from((controller.setDefaultData.masterDataList['tenantstatus'] ?? [])[index]);
                      //           return SizedBox(
                      //             width: 100,
                      //             child: TimelineTile(
                      //               isFirst: index == 0,
                      //               axis: TimelineAxis.horizontal,
                      //               isLast: index == controller.setDefaultData.masterDataList['tenantstatus'].length - 1,
                      //               alignment: TimelineAlign.start,
                      //               indicatorStyle: IndicatorStyle(
                      //                 indicator: Builder(
                      //                   builder: (context) {
                      //                     return CustomTooltip(
                      //                       message:
                      //                           '${status['status']}${controller.setDefaultData.formData['${status['_id']}_date'].toString().isNotNullOrEmpty ? '\n${controller.setDefaultData.formData['${status['_id']}_date'].toString().toDateFormat()}' : ''}',
                      //                       child: CircleAvatar(
                      //                         backgroundColor: status['_id'] == controller.setDefaultData.formData['tenantstatusid'] ? ColorTheme.kWarnColor : ColorTheme.kBackGroundGrey,
                      //                         child: SvgPicture.network(
                      //                           status['image'] ?? '',
                      //                           colorFilter: ColorFilter.mode(
                      //                             (currentStatusIndex == index)
                      //                                 ? ColorTheme.kWhite
                      //                                 : (currentStatusIndex < index)
                      //                                     ? ColorTheme.kGrey
                      //                                     : ColorTheme.kPrimaryColor,
                      //                             BlendMode.srcIn,
                      //                           ),
                      //                         ).paddingAll(7),
                      //                       ),
                      //                     );
                      //                   },
                      //                 ),
                      //                 padding: EdgeInsets.zero,
                      //                 width: 40,
                      //                 height: 40,
                      //               ),
                      //               beforeLineStyle: LineStyle(
                      //                 color: currentStatusIndex >= index ? ColorTheme.kBlack : ColorTheme.kGrey,
                      //                 thickness: currentStatusIndex >= index ? 2 : 1,
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       ),
                      //     );
                      //   }),
                      // Visibility(visible: sizingInformation.isMobile, child: const Spacer()),
                      Visibility(
                        visible: sizingInformation.isMobile,
                        child: InkWell(
                          onTap: () async {
                            CustomDialogs().customDialog(
                                buttonCount: 2,
                                content: 'Are you sure you want to leave this page? Your form will be cleared if you proceed.',
                                onTapPositive: () {
                                  Get.back();
                                  Get.back();
                                });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: ColorTheme.kBackGroundGrey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.clear),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ColorTheme.kWhite,
                    ),
                    padding: sizingInformation.isMobile ? const EdgeInsets.all(4) : const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                    width: controller.dialogBoxData['rightsidebarsize'] == ModelClassSize.full ? MediaQuery.sizeOf(context).width : controller.dialogBoxData['rightsidebarsize'],
                    child: Obx(() {
                      return Form(
                        key: controller.formKey0,
                        autovalidateMode: controller.validateForm.value ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                        child: Column(
                          children: [
                            Container(
                              height: !sizingInformation.isDesktop ? 72 : 60,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: ColorTheme.kBorderColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              padding: sizingInformation.isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      interactive: true,
                                      controller: controller.tabScrollController,
                                      child: Obx(() {
                                        return ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          controller: controller.tabScrollController,
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.all(10),
                                          itemBuilder: (context, index) {
                                            var tab = controller.dialogBoxData['tabs'][index];
                                            if (tab['defaultvisibility'] == false) {
                                              return const SizedBox.shrink();
                                            }
                                            return AutoScrollTag(
                                              index: index,
                                              controller: controller.tabScrollController,
                                              key: ValueKey(index),
                                              child: SizedBox(
                                                height: 42,
                                                child: Obx(() {
                                                  return InkWell(
                                                    focusNode: FocusNode(skipTraversal: true),
                                                    onTap: controller.setDefaultData.formData.containsKey('_id')
                                                        ? () async {
                                                            controller.selectedTab.value = index;
                                                            controller.formScrollController.jumpTo(0);

                                                            controller.currentExpandedIndex.value = 0;
                                                            await controller.getMasterDataForTab();
                                                            controller.dialogBoxData.refresh();
                                                            controller.selectedTab.refresh();
                                                            controller.update();
                                                          }
                                                        : null,
                                                    child: Obx(
                                                      () => sizingInformation.isMobile || sizingInformation.isTablet
                                                          ? Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Container(
                                                                  width: 30,
                                                                  height: 30,
                                                                  decoration: BoxDecoration(
                                                                    color: controller.selectedTab.value == index ? ColorTheme.kPrimaryColor : ColorTheme.kBackgroundColor,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Center(
                                                                    child: TextWidget(
                                                                      text: tab['order'],
                                                                      fontSize: 14,
                                                                      fontWeight: FontTheme.notoMedium,
                                                                      color: controller.selectedTab.value == index ? ColorTheme.kWhite : ColorTheme.kPrimaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                TextWidget(
                                                                  text: tab['title'].toString().replaceAll('{{index}}', ''),
                                                                  fontSize: 14,
                                                                  fontWeight: FontTheme.notoMedium,
                                                                  color: ColorTheme.kPrimaryColor,
                                                                  height: 1.2,
                                                                ),
                                                              ],
                                                            )
                                                          : Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Container(
                                                                  width: 40,
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                    color: controller.selectedTab.value == index ? ColorTheme.kPrimaryColor : ColorTheme.kBackgroundColor,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: Center(
                                                                    child: TextWidget(
                                                                      text: tab['order'],
                                                                      fontSize: 18,
                                                                      fontWeight: FontTheme.notoMedium,
                                                                      color: controller.selectedTab.value == index ? ColorTheme.kWhite : ColorTheme.kPrimaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: sizingInformation.isMobile ? 8 : 16,
                                                                ),
                                                                Obx(() {
                                                                  return Visibility(
                                                                    visible: (controller.selectedTab.value == index) || sizingInformation.isDesktop,
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        TextWidget(
                                                                          text: tab['title'].toString().replaceAll('{{index}}', ''),
                                                                          fontSize: 16,
                                                                          fontWeight: FontTheme.notoMedium,
                                                                          color: ColorTheme.kPrimaryColor,
                                                                          height: 1.1,
                                                                        ),
                                                                        TextWidget(
                                                                          text: tab['subtitle'],
                                                                          fontSize: 12,
                                                                          fontWeight: FontTheme.notoRegular,
                                                                          color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                                                          height: 1.1,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }),
                                                              ],
                                                            ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            var tab = controller.dialogBoxData['tabs'][index];
                                            if (tab['defaultvisibility'] == false) {
                                              return const SizedBox.shrink();
                                            }
                                            return const Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: Icon(
                                                      Icons.arrow_forward_ios_rounded,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                          itemCount: controller.dialogBoxData['tabs'].length,
                                        );
                                      }),
                                    ),
                                  ),
                                  if (controller.selectedTab.value == 4 && sizingInformation.isDesktop)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 300,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: controller.setDefaultData.formData['SAP_vendorcode'].toString().isNullOrEmpty ? 'Note: ' : 'SAP Vendor Code: ',
                                            fontSize: 14,
                                            fontWeight: FontTheme.notoSemiBold,
                                          ),
                                          Flexible(
                                            child: TextWidget(
                                              text: controller.setDefaultData.formData['SAP_vendorcode'].toString().isNullOrEmpty
                                                  ? 'The payment contract will only be generated once the vendor has been created in SAP.'
                                                  : controller.setDefaultData.formData['SAP_vendorcode'],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Visibility(
                                    visible: !sizingInformation.isMobile,
                                    child: InkWell(
                                      onTap: () async {
                                        // customDialog(
                                        //     buttonCount: 2,
                                        //     content: 'Are you sure you want to leave this page? Your form will be cleared if you proceed.',
                                        //     onTapPositive: () {
                                        Get.back();
                                        //   Get.back();
                                        // });
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: ColorTheme.kBackGroundGrey,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.clear),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ).paddingOnly(bottom: 4),
                            // Obx(() {
                            //   var tab = controller.dialogBoxData['tabs'][controller.selectedTab.value];
                            //
                            //   if (tab['type'] != HtmlControls.kFieldGroupList && !sizingInformation.isMobile) {
                            //     return Row(
                            //       children: [
                            //         Container(
                            //           height: 75,
                            //           padding: EdgeInsets.symmetric(vertical: 12, horizontal: sizingInformation.isMobile ? 8 : 24),
                            //           child: Align(
                            //             alignment: Alignment.centerLeft,
                            //             child: Column(
                            //               crossAxisAlignment: CrossAxisAlignment.start,
                            //               children: [
                            //                 TextWidget(
                            //                   text: '${controller.dialogBoxData['tabs'][controller.selectedTab.value]['title']} Details',
                            //                   fontWeight: FontTheme.notoSemiBold,
                            //                   fontSize: 18,
                            //                   color: ColorTheme.kPrimaryColor,
                            //                 ),
                            //                 TextWidget(
                            //                   text: 'Enter ${controller.dialogBoxData['tabs'][controller.selectedTab.value]['title']} Details',
                            //                   fontWeight: FontTheme.notoRegular,
                            //                   fontSize: 12,
                            //                   color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                            //                 ),
                            //               ],
                            //             ),
                            //           ),
                            //         ),
                            //         const Spacer(),
                            //         Obx(() {
                            //           return Visibility(
                            //             visible: controller.selectedTab.value == 0 && controller.setDefaultData.formData.containsKey('_id'),
                            //             child: Container(
                            //               height: 32,
                            //               width: 32,
                            //               decoration: BoxDecoration(
                            //                 borderRadius: BorderRadius.circular(4),
                            //                 color: ColorTheme.kWhite,
                            //               ),
                            //               padding: const EdgeInsets.all(4),
                            //               child: CustomTooltip(
                            //                 message: 'Hutment Sold',
                            //                 textAlign: TextAlign.center,
                            //                 child: InkWell(
                            //                     onTap: () async {
                            //                       controller.handleHutmentSold(index: controller.initialStateData['lastEditedDataIndex'], id: controller.setDefaultData.formData['_id'], isFormOpen: true);
                            //                     },
                            //                     child: SvgPicture.asset(
                            //                       AssetsString.kSold,
                            //                     )),
                            //               ),
                            //             ),
                            //           );
                            //         }).paddingOnly(right: 32),
                            //       ],
                            //     );
                            //   }
                            //   return const SizedBox.shrink();
                            // }),
                            Expanded(
                              child: FocusTraversalGroup(
                                policy: OrderedTraversalPolicy(),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: sizingInformation.isMobile ? 0 : 16),
                                  child: Obx(() {
                                    int crossCount = sizingInformation.isDesktop ? 3 : 1;
                                    {
                                      var tab = controller.dialogBoxData['tabs'][controller.selectedTab.value];

                                      if (tab['type'] == HtmlControls.kFieldGroupList) {
                                        // List<Map<String, dynamic>> valueList = List<Map<String, dynamic>>.from(List
                                        //     .from(controller.setDefaultData.formData[tab['field']] ?? [])
                                        //     .isNullOrEmpty ? [<String, dynamic>{}] : controller.setDefaultData.formData[tab['field']]);
                                        // // controller.setDefaultData.formData[tab['field']] = valueList;
                                        //
                                        var groupKey = tab['field'];
                                        return ListView.separated(
                                          cacheExtent: 50000,
                                          itemCount: (controller.setDefaultData.formData[tab['field']] ?? []).length,
                                          itemBuilder: (context, listIndex) {
                                            if (groupKey == 'rentdetails' && controller.setDefaultData.formData['rentdetails'][listIndex]['isdelete'] == 1) {
                                              return const SizedBox.shrink();
                                            }

                                            String title = controller.dialogBoxData['tabs'][controller.selectedTab.value]['title'];
                                            if (groupKey == 'coapplicant') {
                                              if (controller.setDefaultData.formData['coapplicant'][listIndex]['name'].toString().isNotNullOrEmpty) {
                                                title = controller.setDefaultData.formData['coapplicant'][listIndex]['name'];
                                              }
                                            }

                                            /// Arpit A - code added by sahil
                                            if (groupKey == 'rentdetails') {
                                              if (controller.setDefaultData.formData['rentdetails'][listIndex]['paymenttypename'].toString().isNotNullOrEmpty) {
                                                title = controller.setDefaultData.formData['rentdetails'][listIndex]['paymenttypename'];
                                              }
                                            }
                                            title = title.replaceAll('{{index}}', '${listIndex + 1}');

                                            return Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    controller.currentExpandedIndex.value = controller.currentExpandedIndex.value == listIndex ? -1 : listIndex;
                                                  },
                                                  child: Container(
                                                    height: 75,
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Row(
                                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              TextWidget(
                                                                text: '$title Details',
                                                                fontWeight: FontTheme.notoSemiBold,
                                                                fontSize: 18,
                                                                color: ColorTheme.kPrimaryColor,
                                                              ),
                                                              TextWidget(
                                                                text: 'Enter $title Details',
                                                                fontWeight: FontTheme.notoRegular,
                                                                fontSize: 12,
                                                                color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                                              ),
                                                            ],
                                                          ),
                                                          const Spacer(),
                                                          if (groupKey == 'rentdetails' &&
                                                              (controller.setDefaultData.formData['rentdetails']?[listIndex]?['contractno']).toString().isNotNullOrEmpty)
                                                            Row(
                                                              children: [
                                                                TextWidget(
                                                                    text: "Contract No: ${controller.setDefaultData.formData['rentdetails']?[listIndex]?['contractno'] ?? ''}"),
                                                                const SizedBox(width: 4),
                                                                InkWell(
                                                                    onTap: () {
                                                                      getContractPaymentDetails(
                                                                          tenantId: controller.setDefaultData.formData['_id'] ?? '',
                                                                          contractNo: controller.setDefaultData.formData['rentdetails']?[listIndex]?['contractno'] ?? '',
                                                                          paymentCode: controller.setDefaultData.formData['rentdetails']?[listIndex]?['paymenttypecode'] ?? '',
                                                                          contractStartDate: controller.setDefaultData.formData['rentdetails']?[listIndex]?['startdate'] ?? '',
                                                                          contractEndDate: controller.setDefaultData.formData['rentdetails']?[listIndex]?['enddate'] ?? '');
                                                                    },
                                                                    child: const Icon(Icons.info_outline_rounded, size: 16)),
                                                                const SizedBox(width: 8),
                                                              ],
                                                            )
                                                          else
                                                            Obx(() {
                                                              return Visibility(
                                                                visible: controller.currentExpandedIndex.value == listIndex /*&& (groupKey != 'rentdetails' || listIndex != 0)*/,
                                                                child: CustomButton(
                                                                  focusNode: FocusNode(skipTraversal: true),
                                                                  showBoxBorder: true,
                                                                  title: 'DELETE',
                                                                  borderRadius: 6,
                                                                  width: 30,
                                                                  height: 36,
                                                                  buttonColor: Colors.transparent,
                                                                  onTap: () {
                                                                    if (controller.selectedTab.value == 2) {
                                                                      controller.setDefaultData.formData[groupKey].removeAt(listIndex);
                                                                      if ((controller.setDefaultData.formData[groupKey] as List?).isNullOrEmpty) {
                                                                        // controller.setDefaultData.formData.remove(groupKey);
                                                                        controller.dialogBoxData['tabs'][2]['defaultvisibility'] = false;
                                                                        controller.dialogBoxData.refresh();
                                                                        controller.selectedTab.value = 1;
                                                                        controller.formScrollController.jumpTo(0);
                                                                        controller.getMasterDataForTab();
                                                                      }
                                                                    } else if (controller.selectedTab.value == 4) {
                                                                      if (controller.setDefaultData.formData['rentdetails'][listIndex].containsKey('_id')) {
                                                                        controller.setDefaultData.formData['rentdetails']?[listIndex]['isdelete'] = 1;
                                                                      } else {
                                                                        controller.setDefaultData.formData[groupKey].removeAt(listIndex);
                                                                      }
                                                                    }
                                                                    controller.setDefaultData.formData.refresh();
                                                                  },
                                                                  borderColor: ColorTheme.kErrorColor,
                                                                  fontColor: ColorTheme.kErrorColor,
                                                                  fontSize: 16,
                                                                ),
                                                              );
                                                            }),
                                                          const SizedBox(
                                                            width: 16,
                                                          ),
                                                          Obx(() {
                                                            return Icon(
                                                              controller.currentExpandedIndex.value == listIndex ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                              size: 25,
                                                            );
                                                          })
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Obx(() {
                                                  return Visibility(
                                                    visible: controller.currentExpandedIndex.value == listIndex,
                                                    child: MasonryGridView.builder(
                                                      cacheExtent: 50000,
                                                      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossCount),
                                                      shrinkWrap: true,
                                                      primary: false,
                                                      controller: controller.formScrollController,
                                                      itemCount: controller.dialogBoxData['tabs'][controller.selectedTab.value]['formfields'].length,
                                                      itemBuilder: (context, index) {
                                                        return Obx(() {
                                                          return MeasureSize(
                                                            onChange: (size) {
                                                              controller.boxWidth.value = size.width;
                                                            },
                                                            child: Container(
                                                              decoration: (index % crossCount) != crossCount - 1
                                                                  ? const BoxDecoration(
                                                                      border: Border(
                                                                          right: BorderSide(
                                                                      color: ColorTheme.kBorderColor,
                                                                    )))
                                                                  : null,
                                                              child: Wrap(
                                                                children: [
                                                                  ...List.generate(
                                                                      controller.dialogBoxData['tabs'][controller.selectedTab.value]["formfields"][index]["formFields"].length,
                                                                      (i) {
                                                                    var res = IISMethods().encryptDecryptObj(
                                                                        controller.dialogBoxData['tabs'][controller.selectedTab.value]["formfields"][index]["formFields"][i]);
                                                                    var groupFocusOrderCode = generateUniqueFieldId(listIndex, index, i, null);
                                                                    if (!controller.focusNodes.containsKey(groupFocusOrderCode)) {
                                                                      controller.focusNodes[groupFocusOrderCode] = FocusNode();
                                                                    }
                                                                    if (!controller.formKeys.containsKey(groupFocusOrderCode)) {
                                                                      controller.formKeys[groupFocusOrderCode] = GlobalKey<FormFieldState>();
                                                                    }
                                                                    res['required'] = controller.fieldSetting[controller.setDefaultData.formData['tenantstatusid']]?[res['field']]
                                                                            ?['required'] ??
                                                                        false;

                                                                    if (res.containsKey('condition')) {
                                                                      Map condition = res['condition'];
                                                                      res['defaultvisibility'] = false;
                                                                      List<String> fields = List<String>.from(condition.keys.toList());
                                                                      for (String field in fields) {
                                                                        for (var value in condition[field]) {
                                                                          if (controller.setDefaultData.formData[groupKey][listIndex][field] == value) {
                                                                            res['defaultvisibility'] = true;
                                                                            break;
                                                                          }
                                                                        }
                                                                      }
                                                                    }

                                                                    if (groupKey == 'rentdetails' &&
                                                                        (controller.setDefaultData.formData['rentdetails']?[listIndex]?['contractno'])
                                                                            .toString()
                                                                            .isNotNullOrEmpty) {
                                                                      res['disabled'] = true;
                                                                    }

                                                                    var fieldWidth = int.parse(((controller.boxWidth.value == 0
                                                                            ? res['gridsize'].toString().converttoInt
                                                                            : (res['gridsize'].toString().converttoInt > 500) || sizingInformation.isMobile
                                                                                ? controller.boxWidth.value
                                                                                : (res['gridsize'].toString().converttoInt > 375)
                                                                                    ? controller.boxWidth.value * 0.66
                                                                                    : res['gridsize'].toString().converttoInt > 250
                                                                                        ? controller.boxWidth.value / 2.02
                                                                                        : controller.boxWidth.value / 3.1))
                                                                        .ceil()
                                                                        .toString());

                                                                    if (res['defaultvisibility'] == false) {
                                                                      return const SizedBox.shrink();
                                                                    }
                                                                    if (res['disabled'] == true && controller.enterInOffline.value) {
                                                                      return const SizedBox.shrink();
                                                                    }
                                                                    return FocusTraversalOrder(
                                                                      order: NumericFocusOrder(groupFocusOrderCode.toString().converttoDouble),
                                                                      child: Builder(
                                                                        builder: (context) {
                                                                          switch (res["type"]) {
                                                                            case HtmlControls.kText:
                                                                              return constrainedBoxWithPadding(
                                                                                width: fieldWidth,
                                                                                child: SizedBox(
                                                                                  width: fieldWidth.toString().converttoDouble,
                                                                                  child: Align(
                                                                                    alignment: Alignment.centerLeft,
                                                                                    child: Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        TextWidget(
                                                                                          text: '${res['title']}',
                                                                                          fontWeight: FontTheme.notoSemiBold,
                                                                                          fontSize: 18,
                                                                                          color: ColorTheme.kPrimaryColor,
                                                                                        ),
                                                                                        TextWidget(
                                                                                          text: '${res['subtitle']}',
                                                                                          fontWeight: FontTheme.notoRegular,
                                                                                          fontSize: 12,
                                                                                          color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            case HtmlControls.kInputText:
                                                                              return Obx(
                                                                                () {
                                                                                  var textController = TextEditingController(
                                                                                      text: controller.setDefaultData.formData[groupKey][listIndex][res["field"]]
                                                                                              .toString()
                                                                                              .isNullOrEmpty
                                                                                          ? ""
                                                                                          : (isMasterForm
                                                                                                  ? controller.setDefaultData.masterFormData
                                                                                                  : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                              .toString());
                                                                                  if (controller.cursorPos <= textController.text.length) {
                                                                                    textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                  } else {
                                                                                    textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                  }
                                                                                  controller.focusNodes[groupFocusOrderCode]?.addListener(
                                                                                    () {
                                                                                      if (!(controller.focusNodes[groupFocusOrderCode]?.hasFocus ?? false)) {
                                                                                        controller.validator[res['field']] = true;
                                                                                        controller.formKeys[groupFocusOrderCode]?.currentState?.validate();
                                                                                      }
                                                                                    },
                                                                                  );
                                                                                  return constrainedBoxWithPadding(
                                                                                      width: fieldWidth,
                                                                                      child: CustomTextFormField(
                                                                                        fieldKey: controller.formKeys[groupFocusOrderCode],
                                                                                        autoValidateMode:
                                                                                            controller.validator[res['field']] == true ? AutovalidateMode.onUserInteraction : null,
                                                                                        textWidth: fieldWidth.toString().converttoDouble,
                                                                                        focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                        textInputType: TextInputType.text,
                                                                                        controller: textController,
                                                                                        headerRadioLabel: res['radiolabel'],
                                                                                        headerRadioValue: res.containsKey('radiofield')
                                                                                            ? (isMasterForm
                                                                                                    ? controller.setDefaultData.masterFormData
                                                                                                    : controller.setDefaultData.formData)[groupKey][listIndex][res['radiofield']] ==
                                                                                                1
                                                                                            : null,
                                                                                        headerRadioOnChange: (value) async {
                                                                                          await controller.handleFormGroupField(
                                                                                            groupKey: groupKey,
                                                                                            index: listIndex,
                                                                                            key: res["radiofield"],
                                                                                            value: value,
                                                                                            type: HtmlControls.kRadio,
                                                                                          );
                                                                                        },
                                                                                        hintText: "Enter ${res["text"]}",
                                                                                        inputFormatters: [
                                                                                          if (res['field'].toString().contains('email')) inputTextEmailRegx else inputTextRegx
                                                                                        ],
                                                                                        validator: (v) {
                                                                                          if (controller.validator[res['field']] == true) {
                                                                                            if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                              devPrint('object--->${controller.validator[res['field']]}');
                                                                                              if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                                return "Please Enter a valid ${res["text"]}";
                                                                                              }
                                                                                            } else if (v.toString().isNotEmpty &&
                                                                                                (res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                                              return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                                            }
                                                                                            controller.validator[res['field']] = false;
                                                                                            controller.validator.refresh();
                                                                                            return null;
                                                                                          }
                                                                                          // if (controller.validator[res["field"]] ?? false) {
                                                                                          if (res['required'] == false && v.toString().isEmpty) {
                                                                                            return null;
                                                                                          }
                                                                                          if (res['required'] == true && v.toString().isEmpty) {
                                                                                            return "Please Enter ${res["text"]}";
                                                                                          } else if (res.containsKey("regex")) {
                                                                                            if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                              return "Please Enter a valid ${res["text"]}";
                                                                                            }
                                                                                          }
                                                                                          // }
                                                                                          return null;
                                                                                        },
                                                                                        isRequire: res["required"],
                                                                                        textFieldLabel: res["text"],
                                                                                        readOnly: res["disabled"],
                                                                                        disableField: res["disabled"],
                                                                                        onChanged: (v) async {
                                                                                          if (controller.validator[res['field']] == true && v.isNullOrEmpty) {
                                                                                            controller.validator[res['field']] = false;
                                                                                            controller.validator.refresh();
                                                                                          }
                                                                                          await controller.handleFormGroupField(
                                                                                            groupKey: groupKey,
                                                                                            index: listIndex,
                                                                                            key: res["field"],
                                                                                            value: res["autocapital"].toString().isNullOrEmpty
                                                                                                ? res["field"].toString().toLowerCase().contains("name")
                                                                                                    ? v.toCamelCase
                                                                                                    : v
                                                                                                : res["autocapital"]
                                                                                                    ? v.toUpperCase()
                                                                                                    : res["field"].toString().toLowerCase().contains("name")
                                                                                                        ? v.toCamelCase
                                                                                                        : v,
                                                                                            type: res["type"],
                                                                                          );
                                                                                          controller.cursorPos = textController.selection.extent.offset;
                                                                                        },
                                                                                      ));
                                                                                },
                                                                              );
                                                                            case HtmlControls.kDatePicker:
                                                                              return Obx(
                                                                                () {
                                                                                  var textController = TextEditingController(
                                                                                      text: (isMasterForm
                                                                                                  ? controller.setDefaultData.masterFormData
                                                                                                  : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                              .toString()
                                                                                              .isNullOrEmpty
                                                                                          ? ""
                                                                                          : (isMasterForm
                                                                                                  ? controller.setDefaultData.masterFormData
                                                                                                  : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                              .toString());
                                                                                  if (controller.cursorPos <= textController.text.length) {
                                                                                    textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                  } else {
                                                                                    textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                  }
                                                                                  return constrainedBoxWithPadding(
                                                                                    width: fieldWidth,
                                                                                    child: CustomTextFormField(
                                                                                      focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                      controller: TextEditingController(
                                                                                        text: (isMasterForm
                                                                                                    ? controller.setDefaultData.masterFormData
                                                                                                    : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                                .toString()
                                                                                                .isNullOrEmpty
                                                                                            ? ""
                                                                                            : DateFormat("dd-MM-yyyy")
                                                                                                .format(DateTime.parse((isMasterForm
                                                                                                        ? controller.setDefaultData.masterFormData
                                                                                                        : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                                    .toLocal())
                                                                                                .toString(),
                                                                                      ),
                                                                                      hintText: "Enter ${res["text"]}",
                                                                                      readOnly: true,
                                                                                      disableField: res["disabled"],
                                                                                      onTap: () => showCustomDatePicker(
                                                                                        initialDate: (isMasterForm
                                                                                                    ? controller.setDefaultData.masterFormData
                                                                                                    : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                                .toString()
                                                                                                .isNotNullOrEmpty
                                                                                            ? DateTime.parse((isMasterForm
                                                                                                    ? controller.setDefaultData.masterFormData
                                                                                                    : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                                .toLocal()
                                                                                            : DateTime.now(),
                                                                                        onDateSelected: (p0) async {
                                                                                          await controller.handleFormGroupField(
                                                                                            groupKey: groupKey,
                                                                                            index: listIndex,
                                                                                            key: res["field"],
                                                                                            value: p0,
                                                                                            type: res['type'],
                                                                                          );
                                                                                        },
                                                                                      ),
                                                                                      onFieldSubmitted: (v) async {
                                                                                        showCustomDatePicker(
                                                                                          initialDate: (isMasterForm
                                                                                                      ? controller.setDefaultData.masterFormData
                                                                                                      : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                                  .toString()
                                                                                                  .isNotNullOrEmpty
                                                                                              ? DateTime.parse((isMasterForm
                                                                                                      ? controller.setDefaultData.masterFormData
                                                                                                      : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                                  .toLocal()
                                                                                              : DateTime.now(),
                                                                                          onDateSelected: (p0) async {
                                                                                            await controller.handleFormGroupField(
                                                                                              groupKey: groupKey,
                                                                                              index: listIndex,
                                                                                              key: res["field"],
                                                                                              value: p0,
                                                                                              type: res['type'],
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                      suffixIcon: AssetsString.kCalender,
                                                                                      validator: (v) {
                                                                                        // if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                                                                        if (res['required'] == true && v.toString().isEmpty) {
                                                                                          return "Please Enter ${res["text"]}";
                                                                                        } else if (res.containsKey("regex")) {
                                                                                          if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                            return "Please Enter a valid ${res["text"]}";
                                                                                          }
                                                                                        }
                                                                                        // }
                                                                                        return null;
                                                                                      },
                                                                                      isRequire: res["required"],
                                                                                      textFieldLabel: res["text"],
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              );
                                                                            case HtmlControls.kNumberInput:
                                                                              return Obx(() {
                                                                                var textController = TextEditingController(
                                                                                    text: ((isMasterForm
                                                                                                    ? controller.setDefaultData.masterFormData
                                                                                                    : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                                                '')
                                                                                            .toString()
                                                                                            .isNullOrEmpty
                                                                                        ? ""
                                                                                        : (isMasterForm
                                                                                                ? controller.setDefaultData.masterFormData
                                                                                                : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                            .toString());
                                                                                if (controller.cursorPos <= textController.text.length) {
                                                                                  textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                } else {
                                                                                  textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                }
                                                                                controller.focusNodes[groupFocusOrderCode]?.addListener(
                                                                                  () {
                                                                                    if (!(controller.focusNodes[groupFocusOrderCode]!.hasFocus)) {
                                                                                      controller.validator[res['field']] = true;
                                                                                      controller.formKeys[groupFocusOrderCode]?.currentState?.validate();
                                                                                    }
                                                                                  },
                                                                                );
                                                                                return constrainedBoxWithPadding(
                                                                                    width: fieldWidth,
                                                                                    child: CustomTextFormField(
                                                                                      fieldKey: controller.formKeys[groupFocusOrderCode],
                                                                                      autoValidateMode:
                                                                                          controller.validator[res['field']] == true ? AutovalidateMode.onUserInteraction : null,
                                                                                      focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                      textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                                      inputFormatters: [
                                                                                        IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                                        if (res.containsKey("maxlength") ||
                                                                                            (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                                          LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                                        if (res.containsKey("minvalue") && res.containsKey("maxvalue"))
                                                                                          LimitRange(res["minvalue"], res["maxvalue"]),
                                                                                      ],
                                                                                      readOnly: res["disabled"],
                                                                                      controller: textController,
                                                                                      hintText: "Enter ${res["text"]}",
                                                                                      disableField: res["disabled"],
                                                                                      suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                          ? TextWidget(
                                                                                              text: res['suffixtext'],
                                                                                              fontSize: 14,
                                                                                              fontWeight: FontTheme.notoRegular,
                                                                                            ).paddingSymmetric(
                                                                                              horizontal: 12,
                                                                                            )
                                                                                          : null,
                                                                                      prefixWidget: (res['prefixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                          ? TextWidget(
                                                                                              text: res['prefixtext'],
                                                                                              fontSize: 14,
                                                                                              fontWeight: FontTheme.notoRegular,
                                                                                            ).paddingSymmetric(
                                                                                              horizontal: 12,
                                                                                            )
                                                                                          : null,
                                                                                      validator: (v) {
                                                                                        if (controller.validator[res['field']] == true) {
                                                                                          if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                            if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                              return "Please Enter a valid ${res["text"]}";
                                                                                            }
                                                                                          } else if (v.toString().isNotEmpty &&
                                                                                              (res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                                            return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                                          }
                                                                                          controller.validator[res['field']] = false;
                                                                                          controller.validator.refresh();
                                                                                          return null;
                                                                                        }
                                                                                        if (res['required'] == false && v.toString().isEmpty) {
                                                                                          return null;
                                                                                        }
                                                                                        // if (controller.validator[res["field"]] ?? false) {
                                                                                        if (res['required'] == true && v.toString().isEmpty) {
                                                                                          return "Please Enter ${res["text"]}";
                                                                                        } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                          if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                            return "Please Enter a valid ${res["text"]}";
                                                                                          }
                                                                                        } else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                                          return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                                        }
                                                                                        // }
                                                                                        return null;
                                                                                      },
                                                                                      isRequire: res["required"],
                                                                                      textFieldLabel: res["text"],
                                                                                      onChanged: (v) async {
                                                                                        if (controller.validator[res['field']] == true && v.isNullOrEmpty) {
                                                                                          controller.validator[res['field']] = false;
                                                                                          controller.validator.refresh();
                                                                                        }
                                                                                        if (v.endsWith('.')) {
                                                                                          return;
                                                                                        }
                                                                                        await controller.handleFormGroupField(
                                                                                          groupKey: groupKey,
                                                                                          index: listIndex,
                                                                                          key: res["field"],
                                                                                          value: v,
                                                                                          type: res["type"],
                                                                                        );
                                                                                        controller.cursorPos = textController.selection.extent.offset;
                                                                                      },
                                                                                    ));
                                                                              });
                                                                            case HtmlControls.kMultipleContactSelection:
                                                                              return Obx(() {
                                                                                List list = (isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                                    [''];
                                                                                if (list.isEmpty) {
                                                                                  list.add('');
                                                                                }
                                                                                return ListView.builder(
                                                                                  itemCount: list.length,
                                                                                  shrinkWrap: true,
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  itemBuilder: (context, contactIndex) {
                                                                                    return Builder(builder: (ctx) {
                                                                                      var textController = TextEditingController(
                                                                                          text: (list[contactIndex] ?? '').toString().isNullOrEmpty
                                                                                              ? ""
                                                                                              : list[contactIndex].toString());
                                                                                      if (controller.cursorPos <= textController.text.length) {
                                                                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                      } else {
                                                                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                      }
                                                                                      var groupFocusOrderCode = generateUniqueFieldId(listIndex, contactIndex, i, null);

                                                                                      var unqKey = generateUniqueFieldId(listIndex, index, i, contactIndex);
                                                                                      if (!controller.focusNodes.containsKey(unqKey)) {
                                                                                        controller.focusNodes[unqKey] = FocusNode();
                                                                                      }
                                                                                      return constrainedBoxWithPadding(
                                                                                          width: fieldWidth,
                                                                                          child: Row(
                                                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: CustomTextFormField(
                                                                                                  focusNode: controller.focusNodes[unqKey],
                                                                                                  textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                                                  inputFormatters: [
                                                                                                    IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                                                    if (res.containsKey("maxlength") ||
                                                                                                        (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                                                      LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                                                    if (res.containsKey("minvalue") && res.containsKey("maxvalue"))
                                                                                                      LimitRange(res["minvalue"], res["maxvalue"]),
                                                                                                  ],
                                                                                                  readOnly: res["disabled"],
                                                                                                  controller: textController,
                                                                                                  hintText: "Enter ${res["text"]}",
                                                                                                  disableField: res["disabled"],
                                                                                                  suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                                      ? TextWidget(
                                                                                                          text: res['suffixtext'],
                                                                                                          fontSize: 14,
                                                                                                          fontWeight: FontTheme.notoRegular,
                                                                                                        ).paddingSymmetric(
                                                                                                          horizontal: 12,
                                                                                                        )
                                                                                                      : null,
                                                                                                  prefixWidget: (res['prefixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                                      ? TextWidget(
                                                                                                          text: res['prefixtext'],
                                                                                                          fontSize: 14,
                                                                                                          fontWeight: FontTheme.notoRegular,
                                                                                                        ).paddingSymmetric(
                                                                                                          horizontal: 12,
                                                                                                        )
                                                                                                      : null,
                                                                                                  validator: (v) {
                                                                                                    // if (controller.validator[res["field"]] ?? false) {
                                                                                                    devPrint('VAJLOKDSF --> $v');
                                                                                                    if (res['required'] == false && v.toString().isEmpty) {
                                                                                                      return null;
                                                                                                    }
                                                                                                    if (res['required'] == true && v.toString().isEmpty) {
                                                                                                      return "Please Enter ${res["text"]}";
                                                                                                    } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                                      if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                                        return "Please Enter a valid ${res["text"]}";
                                                                                                      }
                                                                                                    } else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                                                      return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                                                    }
                                                                                                    // }
                                                                                                    return null;
                                                                                                  },
                                                                                                  isRequire: res["required"],
                                                                                                  textFieldLabel: res["text"],
                                                                                                  onChanged: (v) async {
                                                                                                    list[contactIndex] = v;
                                                                                                    await controller.handleFormGroupField(
                                                                                                      groupKey: groupKey,
                                                                                                      index: listIndex,
                                                                                                      key: res["field"],
                                                                                                      value: list,
                                                                                                      type: res["type"],
                                                                                                    );
                                                                                                    controller.cursorPos = textController.selection.extent.offset;
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: 8,
                                                                                              ),
                                                                                              if (contactIndex != 0)
                                                                                                InkWell(
                                                                                                  focusNode: FocusNode(skipTraversal: true),
                                                                                                  onTap: () async {
                                                                                                    list.removeAt(contactIndex);
                                                                                                    await controller.handleFormGroupField(
                                                                                                      groupKey: groupKey,
                                                                                                      index: listIndex,
                                                                                                      key: res["field"],
                                                                                                      value: list,
                                                                                                      type: res["type"],
                                                                                                    );
                                                                                                  },
                                                                                                  child: Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.circular(6),
                                                                                                      border: Border.all(
                                                                                                        color: ColorTheme.kErrorColor,
                                                                                                      ),
                                                                                                    ),
                                                                                                    height: 36,
                                                                                                    width: 36,
                                                                                                    child: const Icon(
                                                                                                      Icons.delete_outline_rounded,
                                                                                                      color: ColorTheme.kErrorColor,
                                                                                                    ),
                                                                                                  ),
                                                                                                )
                                                                                              else
                                                                                                InkWell(
                                                                                                  focusNode: FocusNode(skipTraversal: true),
                                                                                                  onTap: () async {
                                                                                                    list.add('');
                                                                                                    await controller.handleFormGroupField(
                                                                                                      groupKey: groupKey,
                                                                                                      index: listIndex,
                                                                                                      key: res["field"],
                                                                                                      value: list,
                                                                                                      type: res["type"],
                                                                                                    );
                                                                                                  },
                                                                                                  child: Container(
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.circular(6),
                                                                                                      border: Border.all(
                                                                                                        color: ColorTheme.kBlack,
                                                                                                      ),
                                                                                                    ),
                                                                                                    height: (kIsWeb ? 40 : 48),
                                                                                                    width: (kIsWeb ? 40 : 48),
                                                                                                    child: const Icon(
                                                                                                      Icons.add,
                                                                                                      color: ColorTheme.kBlack,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                            ],
                                                                                          ));
                                                                                    });
                                                                                  },
                                                                                );
                                                                              });
                                                                            case HtmlControls.kInputTextArea:
                                                                              return Obx(() {
                                                                                var textController = TextEditingController(
                                                                                    text: (isMasterForm
                                                                                                ? controller.setDefaultData.masterFormData
                                                                                                : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                            .toString()
                                                                                            .isNullOrEmpty
                                                                                        ? ""
                                                                                        : (isMasterForm
                                                                                                ? controller.setDefaultData.masterFormData
                                                                                                : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                            .toString());
                                                                                if (controller.cursorPos <= textController.text.length) {
                                                                                  textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                } else {
                                                                                  textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                }
                                                                                return constrainedBoxWithPadding(
                                                                                    width: fieldWidth,
                                                                                    child: CustomTextFormField(
                                                                                      focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                      height: 80,
                                                                                      controller: textController,
                                                                                      hintText: "Enter ${res["text"]}",
                                                                                      maxLine: 4,
                                                                                      disableField: res["disabled"],
                                                                                      readOnly: res["disabled"],
                                                                                      validator: (v) {
                                                                                        // if (controller.validator[res["field"]] ?? false) {
                                                                                        if (res['required'] == true && v.toString().isEmpty) {
                                                                                          return "Please Enter ${res["text"]}";
                                                                                        } else if (res.containsKey("regex")) {
                                                                                          if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                            return "Please Enter a valid ${res["text"]}";
                                                                                          }
                                                                                        }
                                                                                        // }
                                                                                        return null;
                                                                                      },
                                                                                      isRequire: res["required"],
                                                                                      textFieldLabel: res["text"],
                                                                                      onChanged: (v) async {
                                                                                        await controller.handleFormGroupField(
                                                                                          groupKey: groupKey,
                                                                                          index: listIndex,
                                                                                          key: res["field"],
                                                                                          value: v,
                                                                                          type: res["type"],
                                                                                        );
                                                                                        controller.cursorPos = textController.selection.extent.offset;
                                                                                      },
                                                                                    ));
                                                                              });
                                                                            case HtmlControls.kDropDown:
                                                                              return Obx(() {
                                                                                var masterdatakey = res?["storemasterdatabyfield"] == true ? res["field"] : res["masterdata"];
                                                                                var list = IISMethods().encryptDecryptObj(controller.setDefaultData.masterData[masterdatakey]);
                                                                                if (res.containsKey("isselfrefernce") &&
                                                                                    res["isselfrefernce"] &&
                                                                                    (isMasterForm
                                                                                            ? controller.setDefaultData.masterFormData
                                                                                            : controller.setDefaultData.formData)[res["isselfreferncefield"]]
                                                                                        .toString()
                                                                                        .isNotEmpty) {
                                                                                  list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                                                                    if ((isMasterForm
                                                                                            ? controller.setDefaultData.masterFormData
                                                                                            : controller.setDefaultData.formData)[res["isselfreferncefield"]] !=
                                                                                        e["label"]) {
                                                                                      return e;
                                                                                    }
                                                                                  }).toList();
                                                                                  list.remove(null);
                                                                                }
                                                                                return constrainedBoxWithPadding(
                                                                                  width: fieldWidth,
                                                                                  child: DropDownSearchCustom(
                                                                                    showToolTip: res["tooltip"].toString().isNotNullOrEmpty,
                                                                                    toolTipText: res["tooltip"] ?? "",

                                                                                    width: fieldWidth,
                                                                                    focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                    dropValidator: (p0) {
                                                                                      // if (controller.validator[res["field"]] ?? false) {
                                                                                      if (res['required'] == true && p0.toString().isNullOrEmpty) {
                                                                                        return "Please Select a ${res['text']}";
                                                                                      }
                                                                                      // }
                                                                                      return null;
                                                                                    },
                                                                                    items: List<Map<String, dynamic>>.from(list ?? []),
                                                                                    readOnly: res['disabled'],
                                                                                    isRequire: res["required"],
                                                                                    isIcon: res["field"] == "iconid" || res["field"] == "iconunicode",
                                                                                    textFieldLabel: res["text"],
                                                                                    hintText: "Select ${res["text"]}",
                                                                                    isCleanable: res["cleanable"],
                                                                                    // showAddButton: masterRights ? res["inpagemasterdata"] ?? false : false,
                                                                                    buttonText: res["text"],
                                                                                    clickOnAddBtn: () async {},
                                                                                    clickOnCleanBtn: () async {
                                                                                      await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: '',
                                                                                        type: res["type"],
                                                                                      );
                                                                                    },
                                                                                    isSearchable: res["searchable"],
                                                                                    initValue: (list ?? [])
                                                                                            .where((element) =>
                                                                                                element["value"] ==
                                                                                                (isMasterForm
                                                                                                    ? controller.setDefaultData.masterFormData
                                                                                                    : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                            .toList()
                                                                                            .isNotEmpty
                                                                                        ? list
                                                                                                .where((element) =>
                                                                                                    element["value"] ==
                                                                                                    (isMasterForm
                                                                                                        ? controller.setDefaultData.masterFormData
                                                                                                        : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                                .toList()
                                                                                                ?.first ??
                                                                                            {}
                                                                                        : null,
                                                                                    onChanged: (v) async {
                                                                                      await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: v?['value'],
                                                                                        type: res["type"],
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                );
                                                                              });
                                                                            case HtmlControls.kFilePicker:
                                                                              return Builder(builder: (context) {
                                                                                RxBool docLoading = false.obs;
                                                                                return Obx(
                                                                                  () {
                                                                                    FilesDataModel field = FilesDataModel.fromJson((isMasterForm
                                                                                            ? controller.setDefaultData.masterFormData
                                                                                            : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                                        {});
                                                                                    var textController = TextEditingController(text: field.name ?? '');
                                                                                    if (controller.cursorPos <= textController.text.length) {
                                                                                      textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                    } else {
                                                                                      textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                    }
                                                                                    if (field.url.toString().isNotNullOrEmpty && field.old == null) {
                                                                                      field.old = IISMethods().encryptDecryptObj(field);
                                                                                    }
                                                                                    return constrainedBoxWithPadding(
                                                                                      width: fieldWidth,
                                                                                      child: CustomTextFormField(
                                                                                        showTitleRowWidget: !isoffline.value && Map?.from(field.old ?? {}).isNotNullOrEmpty,
                                                                                        titleRowWidget: isoffline.value
                                                                                            ? null
                                                                                            : Wrap(
                                                                                                children: [
                                                                                                  InkWell(
                                                                                                      onTap: () {
                                                                                                        documentDownload(
                                                                                                            imageList: FilesDataModel.fromJson(
                                                                                                                Map<String, dynamic>.from(field.old ?? {})));
                                                                                                      },
                                                                                                      child: const Icon(
                                                                                                        Icons.visibility_rounded,
                                                                                                        size: 15,
                                                                                                      )),
                                                                                                  if ((oldData ?? {})[groupKey] != null &&
                                                                                                      (oldData ?? {})[groupKey].length < listIndex &&
                                                                                                      (oldData ?? {})[groupKey][listIndex][res["field"]] != null)
                                                                                                    InkWell(
                                                                                                            onTap: () {
                                                                                                              IISMethods().getDocumentHistory(
                                                                                                                  tenantId: (isMasterForm
                                                                                                                              ? controller.setDefaultData.masterFormData
                                                                                                                              : controller.setDefaultData.formData)[groupKey]
                                                                                                                          [listIndex]['_id'] ??
                                                                                                                      '',
                                                                                                                  documentType: res["doc_history"] ?? '',
                                                                                                                  pagename: controller.formName.value);
                                                                                                            },
                                                                                                            child: const Icon(Icons.history, size: 15))
                                                                                                        .paddingOnly(left: 4),
                                                                                                ],
                                                                                              ),
                                                                                        titleRowWidgetToolTipText: "View ${res["text"]}",
                                                                                        focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                        // textInputType: TextInputType.number,
                                                                                        controller: textController,
                                                                                        hintText: "No File Chosen",
                                                                                        readOnly: true,
                                                                                        disableField: res["disabled"],
                                                                                        onTap: () async {
                                                                                          List<FilesDataModel> fileModelList =
                                                                                              await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                                          docLoading.value = true;
                                                                                          controller.uploadDocCount.value++;
                                                                                          await controller.handleFormGroupField(
                                                                                            groupKey: groupKey,
                                                                                            index: listIndex,
                                                                                            key: res["field"],
                                                                                            value: fileModelList,
                                                                                            type: res["type"],
                                                                                          );
                                                                                          docLoading.value = false;
                                                                                          controller.uploadDocCount.value--;
                                                                                        },
                                                                                        onFieldSubmitted: (v) async {
                                                                                          List<FilesDataModel> fileModelList =
                                                                                              await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                                          docLoading.value = true;
                                                                                          controller.uploadDocCount.value++;
                                                                                          await controller.handleFormGroupField(
                                                                                            groupKey: groupKey,
                                                                                            index: listIndex,
                                                                                            key: res["field"],
                                                                                            value: fileModelList,
                                                                                            type: res["type"],
                                                                                          );
                                                                                          docLoading.value = false;
                                                                                          controller.uploadDocCount.value--;
                                                                                        },
                                                                                        prefixWidget: docLoading.value
                                                                                            ? const CupertinoActivityIndicator(color: ColorTheme.kBlack)
                                                                                                .paddingSymmetric(horizontal: 8)
                                                                                            : const TextWidget(
                                                                                                text: 'Choose File',
                                                                                                fontSize: 14,
                                                                                                height: 1,
                                                                                                fontWeight: FontTheme.notoRegular,
                                                                                              ).paddingSymmetric(horizontal: 4),
                                                                                        validator: (v) {
                                                                                          // if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                                                                          if (res['required'] == true && v.toString().isEmpty) {
                                                                                            return "Please Enter ${res["text"]}";
                                                                                          } else if (res.containsKey("regex")) {
                                                                                            if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                              return "Please Enter a valid ${res["text"]}";
                                                                                            }
                                                                                          }
                                                                                          // }
                                                                                          return null;
                                                                                        },
                                                                                        isRequire: res["required"],
                                                                                        textFieldLabel: res["text"],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              });
                                                                            case HtmlControls.kImagePicker:
                                                                              return Builder(builder: (context) {
                                                                                RxBool docLoading = false.obs;
                                                                                return Obx(
                                                                                  () {
                                                                                    FilesDataModel field = FilesDataModel.fromJson((isMasterForm
                                                                                            ? controller.setDefaultData.masterFormData
                                                                                            : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                                        {});
                                                                                    var textController = TextEditingController(text: field.name ?? '');
                                                                                    if (controller.cursorPos <= textController.text.length) {
                                                                                      textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                    } else {
                                                                                      textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                    }
                                                                                    if (field.url.isNotNullOrEmpty && field.old == null) {
                                                                                      field.old = IISMethods().encryptDecryptObj(field);
                                                                                    }
                                                                                    return constrainedBoxWithPadding(
                                                                                      width: fieldWidth,
                                                                                      child: CustomTextFormField(
                                                                                        showTitleRowWidget: Map?.from(field.old ?? {}).isNotNullOrEmpty,
                                                                                        titleRowWidget: InkWell(
                                                                                            onTap: () {
                                                                                              documentDownload(
                                                                                                  imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(field.old ?? {})));
                                                                                            },
                                                                                            child: const Icon(
                                                                                              Icons.visibility_rounded,
                                                                                              size: 15,
                                                                                            )),
                                                                                        titleRowWidgetToolTipText: "View ${res["text"]}",
                                                                                        focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                        // textInputType: TextInputType.number,
                                                                                        controller: textController,
                                                                                        hintText: "No File Chosen",
                                                                                        readOnly: true,
                                                                                        disableField: res["disabled"],
                                                                                        onTap: () async {
                                                                                          List<FilesDataModel> fileModelList =
                                                                                              await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                                          docLoading.value = true;
                                                                                          controller.uploadDocCount.value++;
                                                                                          await controller.handleFormGroupField(
                                                                                            groupKey: groupKey,
                                                                                            index: listIndex,
                                                                                            key: res["field"],
                                                                                            value: fileModelList,
                                                                                            type: res["type"],
                                                                                          );
                                                                                          docLoading.value = false;
                                                                                          controller.uploadDocCount.value--;
                                                                                        },
                                                                                        onFieldSubmitted: (v) async {
                                                                                          List<FilesDataModel> fileModelList =
                                                                                              await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                                          docLoading.value = true;
                                                                                          controller.uploadDocCount.value++;
                                                                                          await controller.handleFormGroupField(
                                                                                            groupKey: groupKey,
                                                                                            index: listIndex,
                                                                                            key: res["field"],
                                                                                            value: fileModelList,
                                                                                            type: res["type"],
                                                                                          );
                                                                                          docLoading.value = false;
                                                                                          controller.uploadDocCount.value--;
                                                                                        },
                                                                                        prefixWidget: docLoading.value
                                                                                            ? const CupertinoActivityIndicator(color: ColorTheme.kBlack)
                                                                                                .paddingSymmetric(horizontal: 8)
                                                                                            : const TextWidget(
                                                                                                text: 'Choose Image',
                                                                                                fontSize: 14,
                                                                                                fontWeight: FontTheme.notoRegular,
                                                                                              ).paddingSymmetric(horizontal: 4),
                                                                                        validator: (v) {
                                                                                          // if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                                                                          if (res['required'] == true && v.toString().isEmpty) {
                                                                                            return "Please Enter ${res["text"]}";
                                                                                          } else if (res.containsKey("regex")) {
                                                                                            if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                              return "Please Enter a valid ${res["text"]}";
                                                                                            }
                                                                                          }
                                                                                          // }
                                                                                          return null;
                                                                                        },
                                                                                        isRequire: res["required"],
                                                                                        textFieldLabel: res["text"],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              });
                                                                            case HtmlControls.kMultiSelectDropDown:
                                                                              var masterdatakey = res[
                                                                                  "masterdata"] /*?? res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["field"] : res["masterdata"]*/;
                                                                              return Obx(() {
                                                                                return constrainedBoxWithPadding(
                                                                                  width: fieldWidth,
                                                                                  child: MultiDropDownSearchCustom(
                                                                                    selectedItems: List<Map<String, dynamic>>.from(((isMasterForm
                                                                                            ? controller.setDefaultData.masterFormData
                                                                                            : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]) ??
                                                                                        []),
                                                                                    field: res["field"],
                                                                                    width: fieldWidth.toDouble(),
                                                                                    focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                                    dropValidator: (p0) {
                                                                                      // if (p0?.isEmpty == true || p0 == null) {
                                                                                      //   return "Select ${res['text']}";
                                                                                      // }
                                                                                      // if (controller.validator[res["field"]] ?? false) {

                                                                                      if (res['required'] == true &&
                                                                                          List<Map<String, dynamic>>.from(((isMasterForm
                                                                                                      ? controller.setDefaultData.masterFormData
                                                                                                      : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]) ??
                                                                                                  [])
                                                                                              .isNullOrEmpty) {
                                                                                        return "Please Select a ${res['text']}";
                                                                                      }
                                                                                      // }
                                                                                      return null;
                                                                                    },
                                                                                    items:
                                                                                        List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[masterdatakey] ?? []),
                                                                                    initValue: ((isMasterForm
                                                                                                    ? controller.setDefaultData.masterFormData
                                                                                                    : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                                                "")
                                                                                            .toString()
                                                                                            .isNotNullOrEmpty
                                                                                        ? null
                                                                                        : (isMasterForm
                                                                                                ? controller.setDefaultData.masterFormData
                                                                                                : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                            ?.last,
                                                                                    isRequire: res["required"],
                                                                                    textFieldLabel: res["text"],
                                                                                    hintText: "Select ${res["text"]}",
                                                                                    isCleanable: res["cleanable"],
                                                                                    buttonText: res["text"],
                                                                                    clickOnCleanBtn: () async {
                                                                                      await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: '',
                                                                                        type: res["type"],
                                                                                      );
                                                                                    },
                                                                                    isSearchable: res["searchable"],
                                                                                    onChanged: (v) async {
                                                                                      await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: v,
                                                                                        type: res["type"],
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                );
                                                                              });
                                                                            default:
                                                                              return Container(
                                                                                color: ColorTheme.kRed,
                                                                                width: 100,
                                                                                height: 200,
                                                                              );
                                                                          }
                                                                        },
                                                                      ),
                                                                    );
                                                                  }),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                      },
                                                    ),
                                                  );
                                                }),
                                                const Divider(),
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return const SizedBox.shrink();
                                          },
                                        );
                                      }
                                      return MasonryGridView.builder(
                                        cacheExtent: 50000,
                                        gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossCount),
                                        shrinkWrap: false,
                                        controller: controller.formScrollController,
                                        itemCount: controller.dialogBoxData['tabs'][controller.selectedTab.value]['formfields'].length,
                                        itemBuilder: (context, index) {
                                          return Obx(() {
                                            return MeasureSize(
                                              onChange: (size) {
                                                controller.boxWidth.value = size.width;
                                              },
                                              child: Container(
                                                decoration: (index % crossCount) != crossCount - 1
                                                    ? const BoxDecoration(
                                                        border: Border(
                                                            right: BorderSide(
                                                        color: ColorTheme.kBorderColor,
                                                      )))
                                                    : null,
                                                child: Wrap(
                                                  children: [
                                                    ...List.generate(controller.dialogBoxData['tabs'][controller.selectedTab.value]["formfields"][index]["formFields"].length, (i) {
                                                      var res = IISMethods()
                                                          .encryptDecryptObj(controller.dialogBoxData['tabs'][controller.selectedTab.value]["formfields"][index]["formFields"][i]);
                                                      int fieldWidth = int.parse(((controller.boxWidth.value == 0
                                                              ? res['gridsize'].toString().converttoInt
                                                              : (res['gridsize'].toString().converttoInt > 500) || sizingInformation.isMobile
                                                                  ? controller.boxWidth.value
                                                                  : (res['gridsize'].toString().converttoInt > 375)
                                                                      ? controller.boxWidth.value * 0.66
                                                                      : res['gridsize'].toString().converttoInt > 250.toString().converttoInt
                                                                          ? controller.boxWidth.value / 2.02
                                                                          : controller.boxWidth.value / 3.1))
                                                          .ceil()
                                                          .toString());
                                                      var focusOrderCode = generateUniqueFieldId(index, i, null, null);
                                                      if (!controller.focusNodes.containsKey(focusOrderCode)) {
                                                        controller.focusNodes[focusOrderCode] = FocusNode();
                                                      }
                                                      if (!controller.formKeys.containsKey(focusOrderCode)) {
                                                        controller.formKeys[focusOrderCode] = GlobalKey<FormFieldState>();
                                                      }
                                                      if (res.containsKey('condition')) {
                                                        Map condition = res['condition'];
                                                        List<String> fields = List<String>.from(condition.keys.toList());
                                                        for (String field in fields) {
                                                          res['defaultvisibility'] = false;
                                                          for (var value in condition[field]) {
                                                            if (controller.setDefaultData.formData[field] == value) {
                                                              res['defaultvisibility'] = true;
                                                              break;
                                                            }
                                                          }
                                                        }
                                                      }

                                                      res['required'] = res['field'] == 'tenantstatusid' ||
                                                          res['field'] == 'tenantprojectid' ||
                                                          (controller.fieldSetting[controller.setDefaultData.formData['tenantstatusid']]?[res['field']]?['required'] ?? false);
                                                      if (res['defaultvisibility'] == false) {
                                                        return const SizedBox.shrink();
                                                      }
                                                      if (res['disabled'] == true && controller.enterInOffline.value) {
                                                        return const SizedBox.shrink();
                                                      }
                                                      if (controller.setDefaultData.formData['SAP_vendor_status'] == 3 ||
                                                          controller.setDefaultData.formData['SAP_vendor_status'] == 4 ||
                                                          controller.setDefaultData.formData['SAP_vendor_status'] == 7 ||
                                                          controller.setDefaultData.formData['SAP_vendor_status'] == 8 ||
                                                          controller.setDefaultData.formData['SAP_vendor_status'] == 9) {
                                                        if (controller.disableFiledList.contains(res['field'])) {
                                                          res['disabled'] = true;
                                                        }
                                                      }
                                                      return FocusTraversalOrder(
                                                        order: NumericFocusOrder(focusOrderCode.toString().converttoDouble),
                                                        child: Builder(
                                                          builder: (context) {
                                                            switch (res["type"]) {
                                                              case HtmlControls.kText:
                                                                return constrainedBoxWithPadding(
                                                                  width: fieldWidth,
                                                                  child: SizedBox(
                                                                    width: fieldWidth.toString().converttoDouble,
                                                                    child: Row(
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            TextWidget(
                                                                              text: '${res['title']}',
                                                                              fontWeight: FontTheme.notoSemiBold,
                                                                              fontSize: 18,
                                                                              color: ColorTheme.kPrimaryColor,
                                                                            ),
                                                                            TextWidget(
                                                                              text: '${res['subtitle']}',
                                                                              fontWeight: FontTheme.notoRegular,
                                                                              fontSize: 12,
                                                                              color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Obx(() {
                                                                          return Visibility(
                                                                            visible: controller.selectedTab.value == 0 && controller.setDefaultData.formData.containsKey('_id'),
                                                                            child: Container(
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
                                                                                      Get.back();
                                                                                      controller.handleHutmentSold(
                                                                                          index: controller.initialStateData['lastEditedDataIndex'],
                                                                                          id: controller.setDefaultData.formData['_id']);
                                                                                    },
                                                                                    child: SvgPicture.asset(
                                                                                      AssetsString.kSold,
                                                                                    )),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              case HtmlControls.kInputText:
                                                                return Obx(
                                                                  () {
                                                                    var textController = TextEditingController(
                                                                        text: (isMasterForm
                                                                                    ? controller.setDefaultData.masterFormData
                                                                                    : controller.setDefaultData.formData)[res["field"]]
                                                                                .toString()
                                                                                .isNullOrEmpty
                                                                            ? ""
                                                                            : (isMasterForm
                                                                                    ? controller.setDefaultData.masterFormData
                                                                                    : controller.setDefaultData.formData)[res["field"]]
                                                                                .toString());
                                                                    if (controller.cursorPos <= textController.text.length) {
                                                                      textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                    } else {
                                                                      textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                    }
                                                                    controller.focusNodes[focusOrderCode]?.addListener(
                                                                      () {
                                                                        if (!(controller.focusNodes[focusOrderCode]?.hasFocus ?? false)) {
                                                                          controller.validator[res['field']] = true;
                                                                          controller.formKeys[focusOrderCode]?.currentState?.validate();
                                                                        }
                                                                      },
                                                                    );
                                                                    return constrainedBoxWithPadding(
                                                                        width: fieldWidth,
                                                                        child: CustomTextFormField(
                                                                          fieldKey: controller.formKeys[focusOrderCode],
                                                                          autoValidateMode: controller.validator[res['field']] == true ? AutovalidateMode.onUserInteraction : null,
                                                                          textWidth: fieldWidth.toString().converttoDouble,
                                                                          focusNode: controller.focusNodes[focusOrderCode],
                                                                          textInputType: TextInputType.text,
                                                                          controller: textController,

                                                                          /// co-applicant tab radio button
                                                                          headerRadioLabel: res['radiolabel'],
                                                                          headerRadioValue: res.containsKey('radiofield')
                                                                              ? (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res['radiofield']] ==
                                                                                  1
                                                                              : null,
                                                                          headerRadioOnChange: (value) async {
                                                                            await controller.handleFormData(
                                                                              key: res["radiofield"],
                                                                              value: value,
                                                                              type: HtmlControls.kRadio,
                                                                            );
                                                                          },
                                                                          hintText: "Enter ${res["text"]}",
                                                                          inputFormatters: [
                                                                            if ((res['field'] == 'surveyno' || res['field'] == 'sracardno'))
                                                                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]'))
                                                                            else if (res['field'].toString().contains('email'))
                                                                              inputTextEmailRegx
                                                                            else
                                                                              inputTextRegx
                                                                          ],
                                                                          validator: (v) {
                                                                            if (controller.validator[res['field']] == true) {
                                                                              if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                  return "Please Enter a valid ${res["text"]}";
                                                                                }
                                                                              } else if (v.toString().isNotEmpty && (res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                                return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                              }
                                                                              controller.validator[res['field']] = false;
                                                                              controller.validator.refresh();
                                                                              return null;
                                                                            }
                                                                            if (res['required'] == false && v.toString().isEmpty) {
                                                                              return null;
                                                                            }
                                                                            devPrint('${res['field']} ---> ${res["required"]}');
                                                                            if (res["required"] && v.toString().isEmpty) {
                                                                              return "Please Enter ${res["text"]}";
                                                                            } else if (res.containsKey("regex")) {
                                                                              if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                return "Please Enter a valid ${res["text"]}";
                                                                              }
                                                                            }

                                                                            return null;
                                                                          },
                                                                          showPrefix: false,
                                                                          isRequire: res["required"],
                                                                          textFieldLabel: res["text"],
                                                                          readOnly: res["disabled"],
                                                                          disableField: res["disabled"],
                                                                          onChanged: (v) async {
                                                                            if (controller.validator[res['field']] == true && v.isNullOrEmpty) {
                                                                              controller.validator[res['field']] = false;
                                                                              controller.validator.refresh();
                                                                            }
                                                                            await controller.handleFormData(
                                                                              key: res["field"],
                                                                              value: res["autocapital"].toString().isNullOrEmpty
                                                                                  ? res["field"].toString().toLowerCase().contains("name")
                                                                                      ? v.toCamelCase
                                                                                      : v
                                                                                  : res["autocapital"]
                                                                                      ? v.toUpperCase()
                                                                                      : res["field"].toString().toLowerCase().contains("name")
                                                                                          ? v.toCamelCase
                                                                                          : v,
                                                                              type: res["type"],
                                                                            );
                                                                            controller.cursorPos = textController.selection.extent.offset;
                                                                          },
                                                                        ));
                                                                  },
                                                                );
                                                              case HtmlControls.kDatePicker:
                                                                return Obx(
                                                                  () {
                                                                    var textController = TextEditingController(
                                                                        text: (isMasterForm
                                                                                    ? controller.setDefaultData.masterFormData
                                                                                    : controller.setDefaultData.formData)[res["field"]]
                                                                                .toString()
                                                                                .isNullOrEmpty
                                                                            ? ""
                                                                            : (isMasterForm
                                                                                    ? controller.setDefaultData.masterFormData
                                                                                    : controller.setDefaultData.formData)[res["field"]]
                                                                                .toString());
                                                                    if (controller.cursorPos <= textController.text.length) {
                                                                      textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                    } else {
                                                                      textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                    }
                                                                    return constrainedBoxWithPadding(
                                                                      width: fieldWidth,
                                                                      child: CustomTextFormField(
                                                                        focusNode: controller.focusNodes[focusOrderCode],
                                                                        controller: TextEditingController(
                                                                          text: (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]]
                                                                                  .toString()
                                                                                  .isNullOrEmpty
                                                                              ? ""
                                                                              : DateFormat("dd-MM-yyyy")
                                                                                  .format(DateTime.parse((isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[res["field"]])
                                                                                      .toLocal())
                                                                                  .toString(),
                                                                        ),
                                                                        hintText: "Enter ${res["text"]}",
                                                                        readOnly: true,
                                                                        disableField: res["disabled"],
                                                                        onTap: () => showCustomDatePicker(
                                                                          initialDate: (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]]
                                                                                  .toString()
                                                                                  .isNotNullOrEmpty
                                                                              ? DateTime.parse((isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]])
                                                                                  .toLocal()
                                                                              : DateTime.now(),
                                                                          onDateSelected: (p0) async {
                                                                            await controller.handleFormData(
                                                                              key: res["field"],
                                                                              value: p0,
                                                                              type: res["type"],
                                                                            );
                                                                          },
                                                                        ),
                                                                        onFieldSubmitted: (v) async {
                                                                          showCustomDatePicker(
                                                                            initialDate: (isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[res["field"]]
                                                                                    .toString()
                                                                                    .isNotNullOrEmpty
                                                                                ? DateTime.parse((isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[res["field"]])
                                                                                    .toLocal()
                                                                                : DateTime.now(),
                                                                            onDateSelected: (p0) async {
                                                                              await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: p0,
                                                                                type: res["type"],
                                                                              );
                                                                            },
                                                                          );
                                                                        },
                                                                        suffixIcon: AssetsString.kCalender,
                                                                        validator: (v) {
                                                                          if (res['required'] == true && v.toString().isEmpty) {
                                                                            return "Please Enter ${res["text"]}";
                                                                          } else if (res.containsKey("regex")) {
                                                                            if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                              return "Please Enter a valid ${res["text"]}";
                                                                            }
                                                                          }

                                                                          return null;
                                                                        },
                                                                        isRequire: res["required"],
                                                                        textFieldLabel: res["text"],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              case HtmlControls.kNumberInput:
                                                                return Obx(() {
                                                                  var textController = TextEditingController(
                                                                      text: ((isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]] ??
                                                                                  '')
                                                                              .toString()
                                                                              .isNullOrEmpty
                                                                          ? ""
                                                                          : (isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[res["field"]]
                                                                              .toString());
                                                                  if (controller.cursorPos <= textController.text.length) {
                                                                    textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                  } else {
                                                                    textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                  }
                                                                  controller.focusNodes[focusOrderCode]?.addListener(
                                                                    () {
                                                                      if (!(controller.focusNodes[focusOrderCode]!.hasFocus)) {
                                                                        controller.validator[res['field']] = true;
                                                                        controller.formKeys[focusOrderCode]?.currentState?.validate();
                                                                      }
                                                                    },
                                                                  );
                                                                  return constrainedBoxWithPadding(
                                                                      width: fieldWidth,
                                                                      child: CustomTextFormField(
                                                                        fieldKey: controller.formKeys[focusOrderCode],
                                                                        autoValidateMode: controller.validator[res['field']] == true ? AutovalidateMode.onUserInteraction : null,
                                                                        focusNode: controller.focusNodes[focusOrderCode],
                                                                        textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                        inputFormatters: [
                                                                          IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                          if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                            LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                          if (res.containsKey("minvalue") && res.containsKey("maxvalue"))
                                                                            LimitRange(res["minvalue"], res["maxvalue"]),
                                                                        ],
                                                                        readOnly: res["disabled"],
                                                                        controller: textController,
                                                                        hintText: "Enter ${res["text"]}",
                                                                        disableField: res["disabled"],
                                                                        suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                            ? TextWidget(
                                                                                text: res['suffixtext'],
                                                                                fontSize: 14,
                                                                                fontWeight: FontTheme.notoRegular,
                                                                              ).paddingSymmetric(
                                                                                horizontal: 12,
                                                                              )
                                                                            : null,
                                                                        prefixWidget: (res['prefixtext'] ?? '').toString().isNotNullOrEmpty
                                                                            ? TextWidget(
                                                                                text: res['prefixtext'],
                                                                                fontSize: 14,
                                                                                fontWeight: FontTheme.notoRegular,
                                                                              ).paddingSymmetric(
                                                                                horizontal: 12,
                                                                              )
                                                                            : null,
                                                                        validator: (v) {
                                                                          if (controller.validator[res['field']] == true) {
                                                                            if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                              if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                return "Please Enter a valid ${res["text"]}";
                                                                              }
                                                                            } else if (v.toString().isNotEmpty && (res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                              return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                            }
                                                                            controller.validator[res['field']] = false;
                                                                            controller.validator.refresh();
                                                                            return null;
                                                                          }
                                                                          // if (controller.validator[res["field"]] ?? false) {
                                                                          if (res['required'] == false && v.toString().isEmpty) {
                                                                            return null;
                                                                          }
                                                                          if (res['required'] == true && v.toString().isEmpty) {
                                                                            return "Please Enter ${res["text"]}";
                                                                          } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                            if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                              return "Please Enter a valid ${res["text"]}";
                                                                            }
                                                                          } else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                            return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                          }
                                                                          // }
                                                                          return null;
                                                                        },
                                                                        isRequire: res["required"],
                                                                        textFieldLabel: res["text"],
                                                                        onChanged: (v) async {
                                                                          if (controller.validator[res['field']] == true && v.isNullOrEmpty) {
                                                                            controller.validator[res['field']] = false;
                                                                            controller.validator.refresh();
                                                                          }
                                                                          if (v.endsWith('.')) {
                                                                            return;
                                                                          }
                                                                          await controller.handleFormData(
                                                                            key: res["field"],
                                                                            value: v,
                                                                            type: res["type"],
                                                                          );
                                                                          controller.cursorPos = textController.selection.extent.offset;
                                                                        },
                                                                      ));
                                                                });
                                                              case HtmlControls.kMultipleContactSelection:
                                                                return Obx(() {
                                                                  List list = (isMasterForm
                                                                          ? controller.setDefaultData.masterFormData
                                                                          : controller.setDefaultData.formData)[res["field"]] ??
                                                                      [''];
                                                                  if (list.isEmpty) {
                                                                    list.add('');
                                                                  }
                                                                  return ListView.builder(
                                                                    itemCount: list.length,
                                                                    physics: const NeverScrollableScrollPhysics(),
                                                                    shrinkWrap: true,
                                                                    itemBuilder: (context, index) {
                                                                      return Builder(builder: (ctx) {
                                                                        var textController =
                                                                            TextEditingController(text: (list[index] ?? '').toString().isNullOrEmpty ? "" : list[index].toString());
                                                                        if (controller.cursorPos <= textController.text.length) {
                                                                          textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                        } else {
                                                                          textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                        }
                                                                        int unqKey = generateSubFieldId(focusOrderCode, index, 0);
                                                                        if (!controller.focusNodes.containsKey(unqKey)) {
                                                                          controller.focusNodes[unqKey] = FocusNode();
                                                                        }
                                                                        return constrainedBoxWithPadding(
                                                                            width: fieldWidth,
                                                                            child: Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: CustomTextFormField(
                                                                                    focusNode: controller.focusNodes[unqKey],
                                                                                    textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                                    inputFormatters: [
                                                                                      IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                                      if (res.containsKey("maxlength") ||
                                                                                          (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                                        LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                                      if (res.containsKey("minvalue") && res.containsKey("maxvalue"))
                                                                                        LimitRange(res["minvalue"], res["maxvalue"]),
                                                                                    ],
                                                                                    readOnly: res["disabled"],
                                                                                    controller: textController,
                                                                                    hintText: "Enter ${res["text"]}",
                                                                                    disableField: res["disabled"],
                                                                                    suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                        ? TextWidget(
                                                                                            text: res['suffixtext'],
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontTheme.notoRegular,
                                                                                          ).paddingSymmetric(
                                                                                            horizontal: 12,
                                                                                          )
                                                                                        : null,
                                                                                    prefixWidget: (res['prefixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                        ? TextWidget(
                                                                                            text: res['prefixtext'],
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontTheme.notoRegular,
                                                                                          ).paddingSymmetric(
                                                                                            horizontal: 12,
                                                                                          )
                                                                                        : null,
                                                                                    validator: (v) {
                                                                                      devPrint("VALIDATEASNDSD ---> $v");
                                                                                      // if (controller.validator[res["field"]] ?? false) {
                                                                                      if (res['required'] == false && v.toString().isEmpty) {
                                                                                        return null;
                                                                                      }
                                                                                      if (res['required'] == true && v.toString().isEmpty) {
                                                                                        if (res['required'] == false) {
                                                                                          return null;
                                                                                        }
                                                                                        return "Please Enter ${res["text"]}";
                                                                                      } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                        if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                          return "Please Enter a valid ${res["text"]}";
                                                                                        }
                                                                                      } else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                                        return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                                      }
                                                                                      // }
                                                                                      return null;
                                                                                    },
                                                                                    isRequire: res["required"],
                                                                                    textFieldLabel: res["text"],
                                                                                    onChanged: (v) async {
                                                                                      list[index] = v;
                                                                                      await controller.handleFormData(
                                                                                        key: res["field"],
                                                                                        value: list,
                                                                                        type: res["type"],
                                                                                      );
                                                                                      controller.cursorPos = textController.selection.extent.offset;
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                if (res["disabled"] == false)
                                                                                  const SizedBox(
                                                                                    width: 8,
                                                                                  ),
                                                                                if (res["disabled"] == true)
                                                                                  const SizedBox.shrink()
                                                                                else if (index != 0)
                                                                                  InkWell(
                                                                                    focusNode: FocusNode(skipTraversal: true),
                                                                                    onTap: () async {
                                                                                      list.removeAt(index);
                                                                                      await controller.handleFormData(
                                                                                        key: res["field"],
                                                                                        value: list,
                                                                                        type: res["type"],
                                                                                      );
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(6),
                                                                                        border: Border.all(
                                                                                          color: ColorTheme.kErrorColor,
                                                                                        ),
                                                                                      ),
                                                                                      height: (kIsWeb ? 40 : 48),
                                                                                      width: (kIsWeb ? 40 : 48),
                                                                                      child: const Icon(
                                                                                        Icons.delete_outline_rounded,
                                                                                        color: ColorTheme.kErrorColor,
                                                                                      ),
                                                                                    ),
                                                                                  ).paddingOnly(top: 18)
                                                                                else
                                                                                  InkWell(
                                                                                    focusNode: FocusNode(skipTraversal: true),
                                                                                    onTap: () async {
                                                                                      list.add('');
                                                                                      await controller.handleFormData(
                                                                                        key: res["field"],
                                                                                        value: list,
                                                                                        type: res["type"],
                                                                                      );
                                                                                    },
                                                                                    child: Container(
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(6),
                                                                                        border: Border.all(
                                                                                          color: ColorTheme.kBlack,
                                                                                        ),
                                                                                      ),
                                                                                      height: (kIsWeb ? 40 : 48),
                                                                                      width: (kIsWeb ? 40 : 48),
                                                                                      child: const Icon(
                                                                                        Icons.add,
                                                                                        color: ColorTheme.kBlack,
                                                                                      ),
                                                                                    ),
                                                                                  ).paddingOnly(top: 18),
                                                                              ],
                                                                            ));
                                                                      });
                                                                    },
                                                                  );
                                                                });
                                                              case HtmlControls.kInputTextArea:
                                                                return Obx(() {
                                                                  var textController = TextEditingController(
                                                                      text: (isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[res["field"]]
                                                                              .toString()
                                                                              .isNullOrEmpty
                                                                          ? ""
                                                                          : (isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[res["field"]]
                                                                              .toString());
                                                                  if (controller.cursorPos <= textController.text.length) {
                                                                    textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                  } else {
                                                                    textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                  }
                                                                  return constrainedBoxWithPadding(
                                                                      width: fieldWidth,
                                                                      child: CustomTextFormField(
                                                                        focusNode: controller.focusNodes[focusOrderCode],
                                                                        height: 80,
                                                                        controller: textController,
                                                                        hintText: "Enter ${res["text"]}",
                                                                        maxLine: 4,
                                                                        disableField: res["disabled"],
                                                                        readOnly: res["disabled"],
                                                                        validator: (v) {
                                                                          // if (controller.validator[res["field"]] ?? false) {
                                                                          if (res['required'] == false && v.toString().isEmpty) {
                                                                            return null;
                                                                          }
                                                                          if (res['required'] == true && v.toString().isEmpty) {
                                                                            return "Please Enter ${res["text"]}";
                                                                          } else if (res.containsKey("regex")) {
                                                                            if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                              return "Please Enter a valid ${res["text"]}";
                                                                            }
                                                                          }
                                                                          // }
                                                                          return null;
                                                                        },
                                                                        isRequire: res["required"],
                                                                        textFieldLabel: res["text"],
                                                                        onChanged: (v) async {
                                                                          await controller.handleFormData(
                                                                            key: res["field"],
                                                                            value: v,
                                                                            type: res["type"],
                                                                          );
                                                                          controller.cursorPos = textController.selection.extent.offset;
                                                                        },
                                                                      ));
                                                                });
                                                              case HtmlControls.kDropDown:
                                                                return Obx(() {
                                                                  var masterdatakey = res?["storemasterdatabyfield"] == true ? res["field"] : res["masterdata"];
                                                                  var list = IISMethods().encryptDecryptObj(controller.setDefaultData.masterData[masterdatakey]);
                                                                  if (res.containsKey("isselfrefernce") &&
                                                                      res["isselfrefernce"] &&
                                                                      (isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["isselfreferncefield"]]
                                                                          .toString()
                                                                          .isNotEmpty) {
                                                                    list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                                                      if ((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["isselfreferncefield"]] !=
                                                                          e["label"]) {
                                                                        return e;
                                                                      }
                                                                    }).toList();
                                                                    list.remove(null);
                                                                  }
                                                                  return constrainedBoxWithPadding(
                                                                    width: fieldWidth,
                                                                    child: DropDownSearchCustom(
                                                                      width: fieldWidth,
                                                                      focusNode: controller.focusNodes[focusOrderCode],
                                                                      dropValidator: (p0) {
                                                                        // if (controller.validator[res["field"]] ?? false) {
                                                                        if (res['required'] == true && p0.toString().isNullOrEmpty) {
                                                                          return "Please Select a ${res['text']}";
                                                                        }
                                                                        // }
                                                                        return null;
                                                                      },
                                                                      items: List<Map<String, dynamic>>.from(list ?? []),
                                                                      readOnly: res['disabled'],
                                                                      isRequire: res["required"],
                                                                      isIcon: res["field"] == "iconid" || res["field"] == "iconunicode",
                                                                      textFieldLabel: res["text"],
                                                                      hintText: "Select ${res["text"]}",
                                                                      isCleanable: res["cleanable"],
                                                                      // showAddButton: masterRights ? res["inpagemasterdata"] ?? false : false,
                                                                      buttonText: res["text"],
                                                                      clickOnAddBtn: () async {},
                                                                      clickOnCleanBtn: () async {
                                                                        await controller.handleFormData(
                                                                          key: res["field"],
                                                                          value: "",
                                                                          type: res["type"],
                                                                        );
                                                                      },
                                                                      isSearchable: res["searchable"],
                                                                      initValue: (list ?? [])
                                                                              .where((element) =>
                                                                                  element["value"] ==
                                                                                  (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]])
                                                                              .toList()
                                                                              .isNotEmpty
                                                                          ? list
                                                                                  .where((element) =>
                                                                                      element["value"] ==
                                                                                      (isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[res["field"]])
                                                                                  .toList()
                                                                                  ?.first ??
                                                                              {}
                                                                          : null,
                                                                      onChanged: (v) async {
                                                                        await controller.handleFormData(
                                                                          key: res["field"],
                                                                          value: v!["value"],
                                                                          type: res["type"],
                                                                        );
                                                                      },
                                                                    ),
                                                                  );
                                                                });
                                                              case HtmlControls.kMultipleFilePickerFieldWithTitle:
                                                                RxList data = [].obs;
                                                                if ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]
                                                                    is List) {
                                                                  data.addAll((isMasterForm
                                                                          ? controller.setDefaultData.masterFormData
                                                                          : controller.setDefaultData.formData)[res["field"]] ??
                                                                      []);
                                                                }
                                                                return Obx(() {
                                                                  return Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      ListView.builder(
                                                                        itemCount: data.length,
                                                                        shrinkWrap: true,
                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                        itemBuilder: (BuildContext context, int index) {
                                                                          return Builder(builder: (context) {
                                                                            RxBool docLoading = false.obs;
                                                                            return Obx(
                                                                              () {
                                                                                FilesDataModel field = FilesDataModel.fromJson(data[index]['doc'] ?? {});
                                                                                var textController = TextEditingController(text: field.name ?? '');
                                                                                if (field.url.isNotNullOrEmpty && field.old == null) {
                                                                                  field.old = IISMethods().encryptDecryptObj(field);
                                                                                }
                                                                                var nameController = TextEditingController(text: data[index]['name'] ?? "");
                                                                                if (controller.cursorPos <= textController.text.length) {
                                                                                  textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                } else {
                                                                                  textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                                }
                                                                                if (controller.cursorPos <= nameController.text.length) {
                                                                                  nameController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                                } else {
                                                                                  nameController.selection = TextSelection.collapsed(offset: nameController.text.length);
                                                                                }
                                                                                return Row(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: constrainedBoxWithPadding(
                                                                                        child: CustomTextFormField(
                                                                                          controller: nameController,
                                                                                          hintText: "Enter ${res["text"]}",
                                                                                          disableField: res["disabled"],
                                                                                          readOnly: res["disabled"],
                                                                                          isRequire: true,
                                                                                          // isRequire: data[index]['doc'] is Map && (data[index]['doc'] as Map).isNotNullOrEmpty ||
                                                                                          //     data[index]['name'].toString().isNotNullOrEmpty,
                                                                                          textFieldLabel: "Document Name",
                                                                                          validator: (v) {
                                                                                            if (data[index]['doc'] is Map &&
                                                                                                (data[index]['doc'] as Map).isNotNullOrEmpty &&
                                                                                                v.toString().isEmpty) {
                                                                                              return "Please Enter Document Name";
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                          onChanged: (v) async {
                                                                                            data[index]['name'] = v;
                                                                                            await controller.handleFormData(
                                                                                                key: res["field"], value: data, type: res["type"], docIndex: index);
                                                                                            controller.cursorPos = nameController.selection.extent.offset;
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: constrainedBoxWithPadding(
                                                                                        child: CustomTextFormField(
                                                                                          controller: textController,
                                                                                          hintText: "No File Chosen",
                                                                                          readOnly: true,
                                                                                          disableField: res["disabled"],
                                                                                          onTap: () async {
                                                                                            List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(
                                                                                                fileType: res["filetypes"], canCompress: res['field'] != 'tenantcanceledcheque');
                                                                                            docLoading.value = true;
                                                                                            controller.uploadDocCount.value++;
                                                                                            data[index]['doc'] = fileModelList;
                                                                                            data[index]['isdoc'] = true;
                                                                                            await controller.handleFormData(
                                                                                                key: res["field"], value: data, type: res["type"], docIndex: index);
                                                                                            docLoading.value = false;
                                                                                            controller.uploadDocCount.value--;
                                                                                          },
                                                                                          onFieldSubmitted: (v) async {
                                                                                            List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(
                                                                                                fileType: res["filetypes"], canCompress: res['field'] != 'tenantcanceledcheque');
                                                                                            docLoading.value = true;
                                                                                            controller.uploadDocCount.value++;
                                                                                            data[index]['doc'] = fileModelList;
                                                                                            data[index]['isdoc'] = true;
                                                                                            await controller.handleFormData(
                                                                                                key: res["field"], value: data, type: res["type"], docIndex: index);
                                                                                            docLoading.value = false;
                                                                                            controller.uploadDocCount.value--;
                                                                                          },
                                                                                          prefixWidget: docLoading.value
                                                                                              ? const CupertinoActivityIndicator(color: ColorTheme.kBlack)
                                                                                                  .paddingSymmetric(horizontal: 8)
                                                                                              : const TextWidget(
                                                                                                  text: 'Choose File',
                                                                                                  fontSize: 14,
                                                                                                  fontWeight: FontTheme.notoRegular,
                                                                                                ).paddingSymmetric(horizontal: 4),
                                                                                          showSuffixDivider: false,
                                                                                          suffixWidget: const SizedBox.shrink(),
                                                                                          validator: (v) {
                                                                                            if (data[index]['name'].toString().isNotNullOrEmpty && v.toString().isEmpty) {
                                                                                              return "Please Upload ${data[index]['name']}";
                                                                                            }
                                                                                            return null;
                                                                                          },
                                                                                          isRequire: true,
                                                                                          // isRequire: data[index]['doc'] is Map && (data[index]['doc'] as Map).isNotNullOrEmpty ||
                                                                                          //     data[index]['name'].toString().isNotNullOrEmpty,
                                                                                          textFieldLabel: "Documment",
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    InkWell(
                                                                                      focusNode: FocusNode(skipTraversal: true),
                                                                                      onTap: () async {
                                                                                        data.removeAt(index);
                                                                                        await controller.handleFormData(
                                                                                          key: res["field"],
                                                                                          value: data,
                                                                                          type: res["type"],
                                                                                        );
                                                                                      },
                                                                                      child: Container(
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(6),
                                                                                          border: Border.all(
                                                                                            color: ColorTheme.kErrorColor,
                                                                                          ),
                                                                                        ),
                                                                                        height: 36,
                                                                                        width: 36,
                                                                                        child: const Icon(
                                                                                          Icons.delete_outline_rounded,
                                                                                          color: ColorTheme.kErrorColor,
                                                                                        ),
                                                                                      ),
                                                                                    ).paddingOnly(top: 24)
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          });
                                                                        },
                                                                      ),
                                                                      Align(
                                                                        alignment: Alignment.centerRight,
                                                                        child: CustomButton(
                                                                          borderWidth: 1,
                                                                          buttonColor: Colors.transparent,
                                                                          borderColor: ColorTheme.kBlack,
                                                                          height: 38,
                                                                          showBoxBorder: true,
                                                                          width: sizingInformation.isDesktop ? 50 : 30,
                                                                          onTap: () async {
                                                                            data.add({});
                                                                          },
                                                                          borderRadius: 4,
                                                                          widget: const Wrap(
                                                                            crossAxisAlignment: WrapCrossAlignment.center,
                                                                            // mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.add,
                                                                              ),
                                                                              TextWidget(
                                                                                text: 'Add More',
                                                                                fontSize: 13,
                                                                                fontWeight: FontTheme.notoSemiBold,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ).paddingAll(8),
                                                                    ],
                                                                  );
                                                                });

                                                              case HtmlControls.kFilePicker:
                                                                return Builder(builder: (context) {
                                                                  RxBool docLoading = false.obs;
                                                                  return Obx(
                                                                    () {
                                                                      FilesDataModel field = FilesDataModel.fromJson((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["field"]] ??
                                                                          {});
                                                                      var textController = TextEditingController(text: field.name ?? '');
                                                                      if (controller.cursorPos <= textController.text.length) {
                                                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                      } else {
                                                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                      }
                                                                      if (field.url.isNotNullOrEmpty && field.old == null) {
                                                                        field.old = IISMethods().encryptDecryptObj(field);
                                                                      }
                                                                      return constrainedBoxWithPadding(
                                                                        width: fieldWidth,
                                                                        child: CustomTextFormField(
                                                                          showTitleRowWidget: !isoffline.value && Map?.from(field.old ?? {}).isNotNullOrEmpty,
                                                                          titleRowWidget: Wrap(
                                                                            children: [
                                                                              InkWell(
                                                                                  onTap: () {
                                                                                    documentDownload(
                                                                                        imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(field.old ?? {})));
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.visibility_rounded,
                                                                                    size: 15,
                                                                                  )),
                                                                              if ((oldData ?? {})[res["field"]] != null)
                                                                                InkWell(
                                                                                        onTap: () {
                                                                                          IISMethods().getDocumentHistory(
                                                                                              tenantId: controller.setDefaultData.formData['_id'] ?? '',
                                                                                              documentType: res["doc_history"] ?? '',
                                                                                              pagename: controller.formName.value);
                                                                                        },
                                                                                        child: const Icon(Icons.history, size: 15))
                                                                                    .paddingOnly(left: 4),
                                                                            ],
                                                                          ),
                                                                          titleRowWidgetToolTipText: "View ${res["text"]}",
                                                                          focusNode: controller.focusNodes[focusOrderCode],
                                                                          // textInputType: TextInputType.number,
                                                                          controller: textController,
                                                                          hintText: "No File Chosen",
                                                                          readOnly: true,
                                                                          disableField: res["disabled"],
                                                                          onTap: () async {
                                                                            List<FilesDataModel> fileModelList = await IISMethods()
                                                                                .pickSingleFile(fileType: res["filetypes"], canCompress: res['field'] != 'tenantcanceledcheque');
                                                                            docLoading.value = true;
                                                                            controller.uploadDocCount.value++;
                                                                            await controller.handleFormData(
                                                                              key: res["field"],
                                                                              value: fileModelList,
                                                                              type: res["type"],
                                                                            );
                                                                            docLoading.value = false;
                                                                            controller.uploadDocCount.value--;
                                                                          },
                                                                          onFieldSubmitted: (v) async {
                                                                            List<FilesDataModel> fileModelList = await IISMethods()
                                                                                .pickSingleFile(fileType: res["filetypes"], canCompress: res['field'] != 'tenantcanceledcheque');
                                                                            docLoading.value = true;
                                                                            controller.uploadDocCount.value++;
                                                                            await controller.handleFormData(
                                                                              key: res["field"],
                                                                              value: fileModelList,
                                                                              type: res["type"],
                                                                            );
                                                                            docLoading.value = false;
                                                                            controller.uploadDocCount.value--;
                                                                          },
                                                                          prefixWidget: docLoading.value
                                                                              ? const CupertinoActivityIndicator(color: ColorTheme.kBlack).paddingSymmetric(horizontal: 8)
                                                                              : const TextWidget(
                                                                                  text: 'Choose File',
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontTheme.notoRegular,
                                                                                ).paddingSymmetric(horizontal: 4),
                                                                          showSuffixDivider: false,
                                                                          suffixWidget: const SizedBox.shrink(),
                                                                          validator: (v) {
                                                                            // if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                                                            if (res['required'] == true && v.toString().isEmpty) {
                                                                              return "Please Enter ${res["text"]}";
                                                                            } else if (res.containsKey("regex")) {
                                                                              if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                return "Please Enter a valid ${res["text"]}";
                                                                              }
                                                                            }
                                                                            // }
                                                                            return null;
                                                                          },
                                                                          isRequire: res["required"],
                                                                          textFieldLabel: res["text"],
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                });
                                                              case HtmlControls.kImagePicker:
                                                                return Builder(builder: (context) {
                                                                  RxBool docLoading = false.obs;
                                                                  return Obx(
                                                                    () {
                                                                      FilesDataModel field = FilesDataModel.fromJson((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["field"]] ??
                                                                          {});
                                                                      var textController = TextEditingController(text: field.name ?? '');
                                                                      if (controller.cursorPos <= textController.text.length) {
                                                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                      } else {
                                                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                      }
                                                                      if (field.url.isNotNullOrEmpty && field.old == null) {
                                                                        field.old = IISMethods().encryptDecryptObj(field);
                                                                      }
                                                                      return constrainedBoxWithPadding(
                                                                        width: fieldWidth,
                                                                        child: CustomTextFormField(
                                                                          showTitleRowWidget: field.old.isNotNullOrEmpty,
                                                                          titleRowWidget: InkWell(
                                                                              onTap: () {
                                                                                documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(field.old ?? {})));
                                                                              },
                                                                              child: const Icon(
                                                                                Icons.visibility_rounded,
                                                                                size: 15,
                                                                              )),
                                                                          titleRowWidgetToolTipText: "View ${res["text"]}",
                                                                          focusNode: controller.focusNodes[focusOrderCode],
                                                                          // textInputType: TextInputType.number,
                                                                          controller: textController,
                                                                          hintText: "No File Chosen",
                                                                          readOnly: true,
                                                                          disableField: res["disabled"],
                                                                          onTap: () async {
                                                                            List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                            docLoading.value = true;
                                                                            controller.uploadDocCount.value++;
                                                                            await controller.handleFormData(
                                                                              key: res["field"],
                                                                              value: fileModelList,
                                                                              type: res["type"],
                                                                            );
                                                                            docLoading.value = false;
                                                                            controller.uploadDocCount.value--;
                                                                          },
                                                                          onFieldSubmitted: (v) async {
                                                                            List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                            docLoading.value = true;
                                                                            controller.uploadDocCount.value++;
                                                                            await controller.handleFormData(
                                                                              key: res["field"],
                                                                              value: fileModelList,
                                                                              type: res["type"],
                                                                            );
                                                                            docLoading.value = false;
                                                                            controller.uploadDocCount.value--;
                                                                          },
                                                                          prefixWidget: docLoading.value
                                                                              ? const CupertinoActivityIndicator(color: ColorTheme.kBlack).paddingSymmetric(horizontal: 8)
                                                                              : const TextWidget(
                                                                                  text: 'Choose Image',
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontTheme.notoRegular,
                                                                                ).paddingSymmetric(horizontal: 4),
                                                                          validator: (v) {
                                                                            // if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                                                            if (res['required'] == true && v.toString().isEmpty) {
                                                                              return "Please Enter ${res["text"]}";
                                                                            } else if (res.containsKey("regex")) {
                                                                              if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                return "Please Enter a valid ${res["text"]}";
                                                                              }
                                                                            }
                                                                            // }
                                                                            return null;
                                                                          },
                                                                          isRequire: res["required"],
                                                                          textFieldLabel: res["text"],
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                });
                                                              case HtmlControls.kMultipleImagePicker:
                                                                // bool onDragEntered = false;
                                                                return constrainedBoxWithPadding(
                                                                  width: fieldWidth,
                                                                  child: CustomFileDragArea(
                                                                    onFilePicked: (files) async {
                                                                      await controller.handleFormData(
                                                                        key: res["field"],
                                                                        value: files,
                                                                        type: res["type"],
                                                                      );
                                                                    },
                                                                    fileTypes: res['filetypes'],
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(bottom: 4.0),
                                                                          child: TextWidget(
                                                                            text: res['text'],
                                                                            fontSize: 12,
                                                                            fontWeight: FontTheme.notoRegular,
                                                                          ),
                                                                        ),
                                                                        DottedBorder(
                                                                          borderType: BorderType.Rect,
                                                                          color: ColorTheme.kBorderColor,
                                                                          dashPattern: const [8, 8, 1, 1],
                                                                          child: Container(
                                                                            height: 180,
                                                                            width: fieldWidth.toDouble(),
                                                                            color: ColorTheme.kWhite,
                                                                            child: Obx(() {
                                                                              return Visibility(
                                                                                visible: controller.setDefaultData.formData[res['field']] == null ||
                                                                                    controller.setDefaultData.formData[res['field']].isEmpty,
                                                                                replacement: Padding(
                                                                                  padding: const EdgeInsets.all(16),
                                                                                  child: GridView.builder(
                                                                                    itemCount: (controller.setDefaultData.formData[res['field']] ?? []).length + 1,
                                                                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                                                      crossAxisCount: 5,
                                                                                      crossAxisSpacing: 4,
                                                                                      mainAxisSpacing: 5,
                                                                                    ),
                                                                                    itemBuilder: (context, index) {
                                                                                      if (index >= controller.setDefaultData.formData[res['field']].length) {
                                                                                        return FittedBox(
                                                                                          fit: BoxFit.contain,
                                                                                          child: Container(
                                                                                            width: 75,
                                                                                            height: 75,
                                                                                            decoration: BoxDecoration(
                                                                                              border: Border.all(
                                                                                                width: 1,
                                                                                                color: ColorTheme.kBorderColor,
                                                                                              ),
                                                                                              borderRadius: BorderRadius.circular(4),
                                                                                            ),
                                                                                            padding: const EdgeInsets.all(4),
                                                                                            child: const Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                              children: [
                                                                                                Icon(
                                                                                                  Icons.add,
                                                                                                ),
                                                                                                TextWidget(
                                                                                                  text: 'Upload',
                                                                                                  color: ColorTheme.kBlack,
                                                                                                  fontSize: 14,
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                      return GestureDetector(
                                                                                        onLongPressStart: sizingInformation.isMobile
                                                                                            ? (details) {
                                                                                                final RenderBox overlay =
                                                                                                    Overlay.of(context).context.findRenderObject() as RenderBox;
                                                                                                showMenu(
                                                                                                  context: context,
                                                                                                  position: RelativeRect.fromRect(
                                                                                                      Rect.fromPoints(details.globalPosition, details.globalPosition),
                                                                                                      Offset.zero & overlay.size),
                                                                                                  items: [
                                                                                                    CommonDataTableWidget.menuOption(
                                                                                                        onTap: () {
                                                                                                          documentDownload(
                                                                                                              imageList: FilesDataModel.fromJson(
                                                                                                                  controller.setDefaultData.formData[res['field']][index] ?? {}));
                                                                                                        },
                                                                                                        btnName: 'Open',
                                                                                                        svgImageUrl: AssetsString.kEyeOpen),
                                                                                                    CommonDataTableWidget.menuOption(
                                                                                                      onTap: () {
                                                                                                        controller.setDefaultData.formData[res['field']].removeAt(index);
                                                                                                        controller.setDefaultData.formData.refresh();
                                                                                                      },
                                                                                                      btnName: 'Delete',
                                                                                                      svgImageUrl: AssetsString.kDelete,
                                                                                                    ),
                                                                                                  ],
                                                                                                );
                                                                                              }
                                                                                            : null,
                                                                                        child: Container(
                                                                                          width: 75,
                                                                                          height: 75,
                                                                                          decoration: BoxDecoration(
                                                                                            border: Border.all(
                                                                                              width: 1,
                                                                                              color: ColorTheme.kBorderColor,
                                                                                            ),
                                                                                            borderRadius: BorderRadius.circular(4),
                                                                                          ),
                                                                                          padding: const EdgeInsets.all(4),
                                                                                          child: HoverBuilder(
                                                                                            builder: (isHovered) => Stack(
                                                                                              alignment: Alignment.center,
                                                                                              children: [
                                                                                                SizedBox(
                                                                                                  // height: 71,
                                                                                                  // width: 71,
                                                                                                  child: ClipRRect(
                                                                                                    borderRadius: BorderRadius.circular(4),
                                                                                                    child: controller.setDefaultData.formData[res['field']][index]['url']
                                                                                                            .toString()
                                                                                                            .isNotNullOrEmpty
                                                                                                        ? Image.network(
                                                                                                            // keepBytesInMemory: false,
                                                                                                            /*imageUrl:*/
                                                                                                            FilesDataModel.fromJson(
                                                                                                                        controller.setDefaultData.formData[res['field']][index])
                                                                                                                    .url ??
                                                                                                                '',
                                                                                                            fit: BoxFit.cover,
                                                                                                            width: 90,
                                                                                                            height: 90,
                                                                                                          )
                                                                                                        : Image.memory(
                                                                                                            Uint8List.fromList(List<int>.from(
                                                                                                                controller.setDefaultData.formData[res['field']][index]['bytes'])),
                                                                                                            fit: BoxFit.cover,
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                                if (!isoffline.value &&
                                                                                                    controller.setDefaultData.formData[res['field']][index]['url']
                                                                                                        .toString()
                                                                                                        .isNullOrEmpty)
                                                                                                  const CircleAvatar(
                                                                                                    backgroundColor: Colors.black54,
                                                                                                    radius: 14,
                                                                                                    child: CupertinoActivityIndicator(
                                                                                                      color: Colors.white,
                                                                                                    ),
                                                                                                  ),
                                                                                                if (isHovered &&
                                                                                                    controller.setDefaultData.formData[res['field']][index]['url']
                                                                                                        .toString()
                                                                                                        .isNotNullOrEmpty)
                                                                                                  Container(
                                                                                                    height: 71,
                                                                                                    width: 71,
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.circular(4),
                                                                                                      color: ColorTheme.kBlack.withOpacity(0.6),
                                                                                                    ),
                                                                                                    child: Center(
                                                                                                      child: Row(
                                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                                        children: [
                                                                                                          Padding(
                                                                                                            padding: const EdgeInsets.all(2.5),
                                                                                                            child: InkWell(
                                                                                                              onTap: () {
                                                                                                                documentDownload(
                                                                                                                    imageList: FilesDataModel.fromJson(
                                                                                                                        controller.setDefaultData.formData[res['field']][index] ??
                                                                                                                            {}));
                                                                                                              },
                                                                                                              child: Container(
                                                                                                                width: 20,
                                                                                                                height: 20,
                                                                                                                padding: const EdgeInsets.all(3),
                                                                                                                decoration: BoxDecoration(
                                                                                                                  color: ColorTheme.kWhite.withOpacity(0.8),
                                                                                                                  borderRadius: BorderRadius.circular(3),
                                                                                                                ),
                                                                                                                child: SvgPicture.asset(
                                                                                                                  AssetsString.kEyeOpen,
                                                                                                                  height: 14,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          Padding(
                                                                                                            padding: const EdgeInsets.all(2.5),
                                                                                                            child: InkWell(
                                                                                                              onTap: () {
                                                                                                                controller.setDefaultData.formData[res['field']].removeAt(index);
                                                                                                                controller.setDefaultData.formData.refresh();
                                                                                                              },
                                                                                                              child: Container(
                                                                                                                width: 20,
                                                                                                                height: 20,
                                                                                                                padding: const EdgeInsets.all(3),
                                                                                                                decoration: BoxDecoration(
                                                                                                                  color: ColorTheme.kWhite.withOpacity(0.8),
                                                                                                                  borderRadius: BorderRadius.circular(3),
                                                                                                                ),
                                                                                                                child: SvgPicture.asset(
                                                                                                                  AssetsString.kDelete,
                                                                                                                  height: 14,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                child: Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Container(
                                                                                        width: 48,
                                                                                        height: 48,
                                                                                        padding: const EdgeInsets.all(10),
                                                                                        decoration: BoxDecoration(
                                                                                          color: ColorTheme.kBackgroundColor,
                                                                                          borderRadius: BorderRadius.circular(6),
                                                                                        ),
                                                                                        child: const Icon(
                                                                                          size: 28,
                                                                                          Icons.file_upload_outlined,
                                                                                          color: ColorTheme.kPrimaryColor,
                                                                                        )),
                                                                                    const SizedBox(
                                                                                      height: 24,
                                                                                    ),
                                                                                    const TextWidget(
                                                                                      text: 'Drop files here or click to upload',
                                                                                      color: ColorTheme.kPrimaryColor,
                                                                                      fontWeight: FontTheme.notoSemiBold,
                                                                                      fontSize: 18,
                                                                                    ),
                                                                                    TextWidget(
                                                                                      text: '(Upload ${res['text']})',
                                                                                      color: ColorTheme.kPrimaryColor,
                                                                                      fontWeight: FontTheme.notoRegular,
                                                                                      fontSize: 12,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );

                                                              case HtmlControls.kMultiSelectDropDown:
                                                                var masterdatakey = res[
                                                                    "masterdata"] /*?? res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["field"] : res["masterdata"]*/;
                                                                return Obx(() {
                                                                  return constrainedBoxWithPadding(
                                                                    width: fieldWidth,
                                                                    child: MultiDropDownSearchCustom(
                                                                      selectedItems: List<Map<String, dynamic>>.from(((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["field"]]) ??
                                                                          []),
                                                                      field: res["field"],
                                                                      width: fieldWidth.toDouble(),
                                                                      focusNode: controller.focusNodes[focusOrderCode],
                                                                      dropValidator: (p0) {
                                                                        // if (p0?.isEmpty == true || p0 == null) {
                                                                        //   return "Select ${res['text']}";
                                                                        // }
                                                                        // if (controller.validator[res["field"]] ?? false) {
                                                                        if (res['required'] == true &&
                                                                            List<Map<String, dynamic>>.from(((isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[res["field"]]) ??
                                                                                    [])
                                                                                .isNullOrEmpty) {
                                                                          return "Please Select a ${res['text']}";
                                                                        }
                                                                        // }
                                                                        return null;
                                                                      },
                                                                      items: List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[masterdatakey] ?? []),
                                                                      initValue: ((isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]] ??
                                                                                  "")
                                                                              .toString()
                                                                              .isNotNullOrEmpty
                                                                          ? null
                                                                          : (isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[res["field"]]
                                                                              ?.last,
                                                                      isRequire: res["required"],
                                                                      textFieldLabel: res["text"],
                                                                      hintText: "Select ${res["text"]}",
                                                                      isCleanable: res["cleanable"],
                                                                      buttonText: res["text"],
                                                                      clickOnCleanBtn: () async {
                                                                        await controller.handleFormData(
                                                                          key: res["field"],
                                                                          value: "",
                                                                          type: res["type"],
                                                                        );
                                                                      },
                                                                      isSearchable: res["searchable"],
                                                                      onChanged: (v) async {
                                                                        await controller.handleFormData(
                                                                          key: res["field"],
                                                                          value: v,
                                                                          type: res["type"],
                                                                        );
                                                                      },
                                                                    ),
                                                                  );
                                                                });
                                                              case HtmlControls.kMultipleTextFieldWithTitle:
                                                                return Obx(() {
                                                                  List list = (isMasterForm
                                                                          ? controller.setDefaultData.masterFormData
                                                                          : controller.setDefaultData.formData)[res["field"]] ??
                                                                      [];
                                                                  return Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      constrainedBoxWithPadding(
                                                                        child: TextWidget(
                                                                          textAlign: TextAlign.left,
                                                                          text: res['text'],
                                                                          textOverflow: TextOverflow.visible,
                                                                          fontFamily: FontTheme.themeFontFamily,
                                                                          fontWeight: FontTheme.notoRegular,
                                                                          color: ColorTheme.kBlack,
                                                                          fontSize: 12,
                                                                        ),
                                                                      ),
                                                                      ListView.builder(
                                                                        itemCount: list.length,
                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                        shrinkWrap: true,
                                                                        itemBuilder: (context, index) {
                                                                          return Builder(builder: (ctx) {
                                                                            String title = (list[index][res['titlefield']] ?? '').toString().isNullOrEmpty
                                                                                ? ""
                                                                                : list[index][res['titlefield']].toString();
                                                                            var textController = TextEditingController(
                                                                                text: (list[index][res['inputfield']] ?? '').toString().isNullOrEmpty
                                                                                    ? ""
                                                                                    : list[index][res['inputfield']].toString());
                                                                            if (controller.cursorPos <= textController.text.length) {
                                                                              textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                            } else {
                                                                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                            }
                                                                            int unqKey = generateSubFieldId(focusOrderCode, index, 0);
                                                                            if (!controller.focusNodes.containsKey(unqKey)) {
                                                                              controller.focusNodes[unqKey] = FocusNode();
                                                                            }
                                                                            return constrainedBoxWithPadding(
                                                                                width: fieldWidth,
                                                                                child: CustomTextFormField(
                                                                                  focusNode: controller.focusNodes[unqKey],
                                                                                  // textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                                  // inputFormatters: [
                                                                                  //   IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                                  //   if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                                  //     LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                                  //   if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                                                                  // ],
                                                                                  readOnly: res["disabled"],
                                                                                  controller: textController,
                                                                                  hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                                                  disableField: res["disabled"],
                                                                                  suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                      ? TextWidget(
                                                                                          text: res['suffixtext'],
                                                                                          fontSize: 14,
                                                                                          fontWeight: FontTheme.notoRegular,
                                                                                        ).paddingSymmetric(
                                                                                          horizontal: 12,
                                                                                        )
                                                                                      : null,
                                                                                  prefixIconConstraints: BoxConstraints.tightFor(width: fieldWidth / 2, height: 40),
                                                                                  prefixWidget: title.isNotNullOrEmpty
                                                                                      ? ConstrainedBox(
                                                                                          constraints: BoxConstraints.tightFor(
                                                                                            width: fieldWidth / 2,
                                                                                          ),
                                                                                          child: TextWidget(
                                                                                            text: title,
                                                                                            fontSize: 14,
                                                                                            fontWeight: FontTheme.notoRegular,
                                                                                          ).paddingSymmetric(
                                                                                            horizontal: 12,
                                                                                          ),
                                                                                        )
                                                                                      : null,
                                                                                  validator: (v) {
                                                                                    // if (controller.validator[res["field"]] ?? false) {
                                                                                    if (res['required'] == true && v.toString().isEmpty) {
                                                                                      if (res['required'] == false) {
                                                                                        return null;
                                                                                      }
                                                                                      return "Please Enter ${res["text"]}";
                                                                                    } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                      if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                        return "Please Enter a valid ${res["text"]}";
                                                                                      }
                                                                                    }
                                                                                    /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                                                      return "Please Enter a valid ${res["text"]}";
                                                                                    }*/
                                                                                    else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                                      return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                                    }
                                                                                    // }
                                                                                    return null;
                                                                                  },
                                                                                  isRequire: res["required"],
                                                                                  onChanged: (v) async {
                                                                                    list[index][res['inputfield']] = v;
                                                                                    await controller.handleFormData(
                                                                                      key: res["field"],
                                                                                      value: list,
                                                                                      type: res["type"],
                                                                                    );
                                                                                    controller.cursorPos = textController.selection.extent.offset;
                                                                                  },
                                                                                ));
                                                                            // return constrainedBoxWithPadding(
                                                                            //     width: fieldWidth,
                                                                            //     child: Row(
                                                                            //       children: [
                                                                            //         Expanded(
                                                                            //           child: CustomTextFormField(
                                                                            //             focusNode:FocusNode(skipTraversal: true),
                                                                            //             textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                            //             readOnly: true,
                                                                            //             controller: TextEditingController(text: title),
                                                                            //             hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                                            //             disableField: res["disabled"],
                                                                            //             suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                            //                 ? TextWidget(
                                                                            //                     text: res['suffixtext'],
                                                                            //                     fontSize: 14,
                                                                            //                     fontWeight: FontTheme.notoRegular,
                                                                            //                   ).paddingSymmetric(
                                                                            //                     horizontal: 12,
                                                                            //                   )
                                                                            //                 : null,
                                                                            //             // prefixIconConstraints: BoxConstraints.tightFor(width: fieldWidth / 2, height: 40),
                                                                            //             // prefixWidget: title.isNotNullOrEmpty
                                                                            //             //     ? ConstrainedBox(
                                                                            //             //         constraints: BoxConstraints.tightFor(
                                                                            //             //           width: fieldWidth / 2,
                                                                            //             //         ),
                                                                            //             //         child: TextWidget(
                                                                            //             //           text: title,
                                                                            //             //           fontSize: 14,
                                                                            //             //           fontWeight: FontTheme.notoRegular,
                                                                            //             //         ).paddingSymmetric(
                                                                            //             //           horizontal: 12,
                                                                            //             //         ),
                                                                            //             //       )
                                                                            //             //     : null,
                                                                            //             validator: (v) {
                                                                            //               // if (controller.validator[res["field"]] ?? false) {
                                                                            //               if (v.toString().isEmpty) {
                                                                            //                 if (res['required'] == false) {
                                                                            //                   return null;
                                                                            //                 }
                                                                            //                 return "Please Enter ${res["text"]}";
                                                                            //               } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                            //                 if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                            //                   return "Please Enter a valid ${res["text"]}";
                                                                            //                 }
                                                                            //               }
                                                                            //               /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                                            //                 return "Please Enter a valid ${res["text"]}";
                                                                            //               }*/
                                                                            //               else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                            //                 return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                            //               }
                                                                            //               // }
                                                                            //               return null;
                                                                            //             },
                                                                            //             isRequire: res["required"],
                                                                            //             onChanged: (v) async {
                                                                            //               list[index][res['inputfield']] = v;
                                                                            //               await controller.handleFormData(
                                                                            //                 key: res["field"],
                                                                            //                 value: list,
                                                                            //                 type: res["type"],
                                                                            //               );
                                                                            //               controller.cursorPos = textController.selection.extent.offset;
                                                                            //             },
                                                                            //           ),
                                                                            //         ),
                                                                            //         const SizedBox(width: 8,),
                                                                            //         Expanded(
                                                                            //           child: CustomTextFormField(
                                                                            //             focusNode: controller.focusNodes[unqKey],
                                                                            //             textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                            //             inputFormatters: [
                                                                            //               IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                            //               if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                            //                 LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                            //               if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                                                            //             ],
                                                                            //             readOnly: res["disabled"],
                                                                            //             controller: textController,
                                                                            //             hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                                            //             disableField: res["disabled"],
                                                                            //             // suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                            //             //     ? TextWidget(
                                                                            //             //         text: res['suffixtext'],
                                                                            //             //         fontSize: 14,
                                                                            //             //         fontWeight: FontTheme.notoRegular,
                                                                            //             //       ).paddingSymmetric(
                                                                            //             //         horizontal: 12,
                                                                            //             //       )
                                                                            //             //     : null,
                                                                            //             // prefixIconConstraints: BoxConstraints.tightFor(width: fieldWidth / 2, height: 40),
                                                                            //             // prefixWidget: title.isNotNullOrEmpty
                                                                            //             //     ? ConstrainedBox(
                                                                            //             //         constraints: BoxConstraints.tightFor(
                                                                            //             //           width: fieldWidth / 2,
                                                                            //             //         ),
                                                                            //             //         child: TextWidget(
                                                                            //             //           text: title,
                                                                            //             //           fontSize: 14,
                                                                            //             //           fontWeight: FontTheme.notoRegular,
                                                                            //             //         ).paddingSymmetric(
                                                                            //             //           horizontal: 12,
                                                                            //             //         ),
                                                                            //             //       )
                                                                            //             //     : null,
                                                                            //             validator: (v) {
                                                                            //               // if (controller.validator[res["field"]] ?? false) {
                                                                            //               if (v.toString().isEmpty) {
                                                                            //                 if (res['required'] == false) {
                                                                            //                   return null;
                                                                            //                 }
                                                                            //                 return "Please Enter ${res["text"]}";
                                                                            //               } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                            //                 if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                            //                   return "Please Enter a valid ${res["text"]}";
                                                                            //                 }
                                                                            //               }
                                                                            //               /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                                            //                 return "Please Enter a valid ${res["text"]}";
                                                                            //               }*/
                                                                            //               else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                            //                 return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                            //               }
                                                                            //               // }
                                                                            //               return null;
                                                                            //             },
                                                                            //             isRequire: res["required"],
                                                                            //             onChanged: (v) async {
                                                                            //               list[index][res['inputfield']] = v;
                                                                            //               await controller.handleFormData(
                                                                            //                 key: res["field"],
                                                                            //                 value: list,
                                                                            //                 type: res["type"],
                                                                            //               );
                                                                            //               controller.cursorPos = textController.selection.extent.offset;
                                                                            //             },
                                                                            //           ),
                                                                            //         ),
                                                                            //       ],
                                                                            //     ));
                                                                          });
                                                                        },
                                                                      ),
                                                                    ],
                                                                  );
                                                                });
                                                              default:
                                                                return Container(
                                                                  color: ColorTheme.kRed,
                                                                  width: 100,
                                                                  height: 200,
                                                                );
                                                            }
                                                          },
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    }
                                  }),
                                ),
                              ),
                            ),
                            Container(
                              color: ColorTheme.kWhite,
                              padding: EdgeInsets.all(sizingInformation.isMobile ? 6 : 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Obx(() {
                                    return Visibility(
                                      visible: controller.selectedTab.value == 1 && controller.dialogBoxData['tabs'][2]['defaultvisibility'] == false,
                                      child: CustomButton(
                                        borderWidth: 1,
                                        buttonColor: Colors.transparent,
                                        borderColor: ColorTheme.kBlack,
                                        height: 36,
                                        showBoxBorder: true,
                                        width: sizingInformation.isDesktop ? 50 : 30,
                                        onTap: () {
                                          controller.dialogBoxData['tabs'][2]['defaultvisibility'] = true;
                                          controller.dialogBoxData.refresh();
                                          controller.handleAddButtonClick();
                                        },
                                        borderRadius: 6,
                                        widget: Row(
                                          children: [
                                            // if (sizingInformation.isDesktop)
                                            Icon(
                                              Icons.add,
                                              size: sizingInformation.isMobile ? 16 : null,
                                              color: ColorTheme.kBlack,
                                            ),
                                            if (sizingInformation.isDesktop)
                                              const SizedBox(
                                                width: 4,
                                              ),
                                            TextWidget(
                                              text: '${sizingInformation.isDesktop ? 'ADD' : ' '} Co-Applicant'.toUpperCase(),
                                              color: ColorTheme.kBlack,
                                              fontWeight: FontTheme.notoMedium,
                                              fontSize: sizingInformation.isDesktop ? 16 : 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  Obx(() {
                                    return Visibility(
                                      visible: controller.dialogBoxData['tabs'][controller.selectedTab.value]['type'] == HtmlControls.kFieldGroupList,
                                      child: CustomButton(
                                        borderWidth: 1,
                                        buttonColor: Colors.transparent,
                                        borderColor: ColorTheme.kBlack,
                                        height: 36,
                                        showBoxBorder: true,
                                        width: sizingInformation.isDesktop ? 50 : 30,
                                        onTap: () {
                                          if (controller.dialogBoxData['tabs'][controller.selectedTab.value]['field'] == 'coapplicant' &&
                                              (controller.setDefaultData.formData[controller.dialogBoxData['tabs'][controller.selectedTab.value]['field']] as List?)!
                                                      .indexWhere((element) {
                                                    return element['firstname'].toString().isNullOrEmpty || element['lastname'].toString().isNullOrEmpty;
                                                  }) !=
                                                  -1) {
                                            showError('Please Add Current Co-applicant\'s Name');
                                            return;
                                          }
                                          controller.setDefaultData.formData[controller.dialogBoxData['tabs'][controller.selectedTab.value]['field']].add(<String, dynamic>{});
                                          controller.currentExpandedIndex.value =
                                              (controller.setDefaultData.formData[controller.dialogBoxData['tabs'][controller.selectedTab.value]['field']]).length - 1;
                                          controller.setDefaultData.formData.refresh();
                                        },
                                        borderRadius: 6,
                                        widget: Row(
                                          children: [
                                            if (sizingInformation.isDesktop)
                                              const Icon(
                                                Icons.add,
                                                color: ColorTheme.kBlack,
                                              ),
                                            if (sizingInformation.isDesktop)
                                              const SizedBox(
                                                width: 4,
                                              ),
                                            TextWidget(
                                              text: controller.dialogBoxData['tabs'][controller.selectedTab.value]['addbuttontext'].toString().toUpperCase(),
                                              color: ColorTheme.kBlack,
                                              fontWeight: FontTheme.notoMedium,
                                              fontSize: sizingInformation.isDesktop ? 16 : 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  const Spacer(),
                                  if (controller.selectedTab.value != 0)
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Obx(() {
                                        return CustomButton(
                                          borderWidth: 1,
                                          buttonColor: Colors.transparent,
                                          borderColor: ColorTheme.kBlack,
                                          height: 40,
                                          width: 70,
                                          showBoxBorder: true,
                                          onTap: (controller.selectedTab.value != 0 && controller.uploadDocCount.value == 0)
                                              ? () async {
                                                  if (controller.dialogBoxData['tabs'][controller.selectedTab.value - 1]['defaultvisibility'] == false) {
                                                    controller.selectedTab.value -= 2;
                                                    controller.formScrollController.jumpTo(0);
                                                  } else {
                                                    controller.selectedTab.value--;
                                                    controller.formScrollController.jumpTo(0);
                                                  }

                                                  controller.currentExpandedIndex.value = 0;
                                                  controller.selectedTab.refresh();
                                                  controller.getMasterDataForTab();
                                                }
                                              : null,
                                          borderRadius: 6,
                                          widget: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (sizingInformation.isDesktop)
                                                const Icon(
                                                  Icons.arrow_back,
                                                  color: ColorTheme.kMicrosoftText,
                                                ),
                                              if (sizingInformation.isDesktop)
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                              const TextWidget(
                                                text: 'Previous',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: ColorTheme.kMicrosoftText,
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  Obx(() {
                                    return Visibility(
                                      child: Padding(
                                        padding: EdgeInsets.all(sizingInformation.isMobile ? 4 : 8.0),
                                        child: CustomButton(
                                          onTap: controller.uploadDocCount.value == 0
                                              ? () async {
                                                  // controller.validator = await validationForm(
                                                  //   formData: controller.setDefaultData.formData,
                                                  //   validation: controller.dialogBoxData['tabs'][controller.selectedTab.value]["formfields"],
                                                  // );

                                                  if (!controller.formKey0.currentState!.validate()) {
                                                    controller.validateForm.value = true;
                                                    if (controller.dialogBoxData['tabs'][controller.selectedTab.value]['field'] == 'coapplicant' &&
                                                        (controller.setDefaultData.formData[controller.dialogBoxData['tabs'][controller.selectedTab.value]['field']] as List?)!
                                                                .indexWhere((element) => element['name'].toString().isNullOrEmpty) !=
                                                            -1) {
                                                      showError('Please Add Current Co-applicant\'s Name');
                                                      return;
                                                    }
                                                    return;
                                                  }

                                                  controller.validateForm.value = false;
                                                  controller.handleAddButtonClick();
                                                }
                                              : null,
                                          isLoading: controller.formButtonLoading.value,
                                          height: 40,
                                          width: 70,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          buttonColor: ColorTheme.kPrimaryColor,
                                          fontColor: ColorTheme.kWhite,
                                          borderRadius: 4,
                                          title: controller.dialogBoxData['tabs'].length - 1 == controller.selectedTab.value ? 'Add' : null,
                                          widget: controller.dialogBoxData['tabs'].length - 1 != controller.selectedTab.value
                                              ? Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const TextWidget(
                                                      text: 'Save & Next',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: ColorTheme.kWhite,
                                                    ),
                                                    if (sizingInformation.isDesktop)
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                    if (sizingInformation.isDesktop)
                                                      const Icon(
                                                        Icons.arrow_forward,
                                                        color: ColorTheme.kWhite,
                                                      )
                                                  ],
                                                )
                                              : null,
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
