import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_shimmer.dart';
import 'package:prestige_prenew_frontend/components/customs/multi_drop_down_custom.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/controller/dashboard/dashboard_controller.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_refresh_indicator.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../components/customs/custom_common_widgets.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/funtions.dart';
import '../../controller/Approval/approval_master_controller.dart';
import '../../controller/layout_templete_controller.dart';
import '../notification_list/notification_list.dart';

class DashBoardScreen extends StatelessWidget {
  final DashBoardController controller;

  const DashBoardScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    String commonKey = 'common';
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (sizingInformation.isDesktop) {
        return Scaffold(
          backgroundColor: ColorTheme.kScaffoldColor,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                  color: ColorTheme.kWhite,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: ColorTheme.kBorderColor,
                    width: 1,
                  )),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                TextWidget(
                                  fontSize: 18,
                                  color: ColorTheme.kPrimaryColor,
                                  fontWeight: FontWeight.w500,
                                  text: 'Dashboard',
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            children: [
                              Obx(() {
                                return constrainedBoxWithPadding(
                                  width: 200,
                                  child: MultiDropDownSearchCustom(
                                    items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                          'value': element['_id'],
                                          'label': element['name'],
                                        })),
                                    isCleanable: true,
                                    filledColor: ColorTheme.kWarnColor,
                                    borderColor: ColorTheme.kWarnColor,

                                    optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                                    selectedOptionColor: ColorTheme.kWarnColor,
                                    fontColor: ColorTheme.kWhite,
                                    clickOnCleanBtn: () async {
                                      List selectedValue = [];
                                      var society = await controller.getSociety(tenantproject: selectedValue);
                                      for (var key in controller.reportKeys) {
                                        if (controller.commonFilters[key] == null) {
                                          controller.commonFilters[key] = {};
                                        }
                                        controller.commonFilters[key].remove('society');
                                        controller.commonFilters[key]['tenantproject'] = IISMethods().encryptDecryptObj(selectedValue);
                                        controller.societyList[key] = society;
                                      }
                                      controller.commonFilters.refresh();
                                      controller.getHutmentStatusReport();
                                      controller.getConsentReport();
                                      controller.getEligibilityReport();
                                      controller.getTurnAroundTimeReport();
                                      controller.getRentPaymentReport();
                                    },
                                    onChanged: (p0) async {
                                      List selectedValue = [];
                                      for (var e in p0) {
                                        Map<String, dynamic> tenantProject = controller.tenantProject.firstWhere((element) => element['_id'] == e);
                                        selectedValue.add({
                                          "tenantprojectid": e,
                                          "tenantproject": tenantProject['name'],
                                        });
                                      }
                                      var society = await controller.getSociety(tenantproject: selectedValue);
                                      for (var key in controller.reportKeys) {
                                        if (controller.commonFilters[key] == null) {
                                          controller.commonFilters[key] = {};
                                        }
                                        controller.commonFilters[key].remove('society');
                                        controller.commonFilters[key]['tenantproject'] = IISMethods().encryptDecryptObj(selectedValue);

                                        controller.societyList[key] = society;
                                      }
                                      controller.commonFilters.refresh();
                                      controller.getHutmentStatusReport();
                                      controller.getConsentReport();
                                      controller.getEligibilityReport();
                                      controller.getTurnAroundTimeReport();
                                      controller.getRentPaymentReport();
                                    },
                                    hintColor: ColorTheme.kWhite,
                                    hintText: 'TENANT PROJECT',
                                    // textFieldLabel: ' ',
                                    dropValidator: (p0) {},
                                    staticText: 'TENANT PROJECT',
                                    prefixWidget: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SvgPicture.asset(
                                        AssetsString.kTenantProject,
                                        colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                                      ),
                                    ),
                                    selectedItems: List<Map<String, dynamic>>.from(controller.commonFilters[commonKey]?['tenantproject'] ?? []),
                                    field: 'tenantproject',
                                  ),
                                );
                              }),
                              Obx(() {
                                return constrainedBoxWithPadding(
                                  width: 200,
                                  child: MultiDropDownSearchCustom(
                                    items: List<Map<String, dynamic>>.from((controller.societyList[commonKey] ?? []).map((element) => {
                                          'value': element['_id'],
                                          'label': element['tenantname'],
                                        })),
                                    isCleanable: true,
                                    optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                                    selectedOptionColor: ColorTheme.kWarnColor,
                                    filledColor: ColorTheme.kWarnColor,
                                    borderColor: ColorTheme.kWarnColor,
                                    fontColor: ColorTheme.kWhite,
                                    clickOnCleanBtn: () async {
                                      List selectedValue = [];
                                      for (var key in controller.reportKeys) {
                                        if (controller.commonFilters[key] == null) {
                                          controller.commonFilters[key] = {};
                                        }
                                        controller.commonFilters[key]['society'] = IISMethods().encryptDecryptObj(selectedValue);
                                      }
                                      controller.commonFilters.refresh();
                                      controller.getHutmentStatusReport();
                                      controller.getConsentReport();
                                      controller.getEligibilityReport();
                                      controller.getTurnAroundTimeReport();
                                      controller.getRentPaymentReport();
                                    },
                                    onChanged: (p0) async {
                                      List selectedValue = [];
                                      for (var e in p0) {
                                        Map<String, dynamic> tenantProject = controller.societyList[commonKey].firstWhere((element) => element['_id'] == e);
                                        selectedValue.add({
                                          "societyid": e,
                                          "society": tenantProject['tenantname'],
                                        });
                                      }
                                      for (var key in controller.reportKeys) {
                                        if (controller.commonFilters[key] == null) {
                                          controller.commonFilters[key] = {};
                                        }
                                        controller.commonFilters[key]['society'] = IISMethods().encryptDecryptObj(selectedValue);
                                      }
                                      controller.commonFilters.refresh();
                                      controller.getHutmentStatusReport();
                                      controller.getConsentReport();
                                      controller.getEligibilityReport();
                                      controller.getTurnAroundTimeReport();
                                      controller.getRentPaymentReport();
                                    },
                                    hintColor: ColorTheme.kWhite,
                                    hintText: 'SOCIETY',
                                    // textFieldLabel: ' ',
                                    staticText: 'SOCIETY',
                                    dropValidator: (p0) {
                                      return null;
                                    },
                                    prefixWidget: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SvgPicture.asset(
                                        AssetsString.kBuilding,
                                        colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                                      ),
                                    ),
                                    selectedItems: List<Map<String, dynamic>>.from(controller.commonFilters[commonKey]?['society'] ?? []),
                                    field: 'society',
                                  ),
                                );
                              }),
                              constrainedBoxWithPadding(
                                width: 56,
                                child: PopupMenuButton(
                                  position: PopupMenuPosition.under,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  constraints: const BoxConstraints(maxHeight: 400),
                                  tooltip: 'Duration',
                                  itemBuilder: (context) {
                                    return List.generate(
                                      controller.filterDurationList.length,
                                      (index) => PopupMenuItem(
                                        onTap: () async {
                                          Future.delayed(const Duration(milliseconds: 1)).then(
                                            (value) async {
                                              String fromdate = '';
                                              String todate = '';
                                              bool cancelled = false;
                                              debugPrint(controller.filterDurationList[index].toString());
                                              if (controller.filterDurationList[index]['value'].toString().converttoInt == 0) {
                                                await showCustomDateRangePicker(onDateSelected: (String startDate, String endDate) {
                                                  fromdate = startDate;
                                                  todate = endDate;
                                                }, onCancel: () {
                                                  cancelled = true;
                                                });
                                              }
                                              if (cancelled) {
                                                return;
                                              }
                                              for (var key in controller.reportKeys) {
                                                if (controller.commonFilters[key] == null) {
                                                  controller.commonFilters[key] = {};
                                                }
                                                controller.commonFilters[key]['filterduration'] = controller.filterDurationList[index]['value'].toString().converttoInt;
                                                controller.commonFilters[key]['fromdate'] = fromdate;
                                                controller.commonFilters[key]['todate'] = todate;
                                              }
                                              controller.commonFilters.refresh();
                                              controller.getHutmentStatusReport();
                                              controller.getConsentReport();
                                              controller.getEligibilityReport();
                                              controller.getTurnAroundTimeReport();
                                              controller.getRentPaymentReport();
                                            },
                                          );
                                        },
                                        child: TextWidget(
                                          fontWeight: controller.commonFilters[commonKey]['filterduration'] == controller.filterDurationList[index]['value']
                                              ? FontTheme.notoBold
                                              : FontTheme.notoMedium,
                                          fontSize: 14,
                                          text: controller.filterDurationList[index]['label'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(color: ColorTheme.kWarnColor, borderRadius: BorderRadius.circular(6)),
                                    child: SvgPicture.asset(
                                      AssetsString.kCalender,
                                      height: 30,
                                      width: 30,
                                      colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                              // Obx(() {
                              //   return constrainedBoxWithPadding(
                              //     width: 200,
                              //     child: DropDownSearchCustom(
                              //       focusNode: FocusNode(),
                              //       canShiftFocus: false,
                              //       fontColor: ColorTheme.kWhite,
                              //       fillColor: ColorTheme.kWarnColor,
                              //       borderColor: ColorTheme.kWarnColor,
                              //       items: List<Map<String, dynamic>>.from(controller.filterDurationList),
                              //       initValue: (controller.commonFilters[commonKey] ?? {})['filterduration'].toString().isNotNullOrEmpty
                              //           ? controller.commonFilters[commonKey]['filterduration'] == 0
                              //               ? {
                              //                   'value': 0,
                              //                   'label':
                              //                       '${controller.commonFilters[commonKey]['fromdate'].toString().toDateFormat()} - ${controller.commonFilters[commonKey]['todate'].toString().toDateFormat()}',
                              //                 }
                              //               : List<Map<String, dynamic>>.from(controller.filterDurationList).firstWhere(
                              //                   (element) {
                              //                     return element['value'] == controller.commonFilters[commonKey]['filterduration'];
                              //                   },
                              //                   orElse: () {
                              //                     return {};
                              //                   },
                              //                 )
                              //           : null,
                              //       hintColor: ColorTheme.kWhite,
                              //       hintText: 'All',
                              //       textFieldLabel: 'Duration',
                              //       isCleanable: false,
                              //       // initValue:
                              //       isSearchable: true,
                              //       onChanged: (v) async {
                              //         String fromdate = '';
                              //         String todate = '';
                              //         bool cancelled = false;
                              //         debugPrint(v.toString());
                              //         if (v?['value'].toString().converttoInt == 0) {
                              //           await showCustomDateRangePicker(onDateSelected: (String startDate, String endDate) {
                              //             fromdate = startDate;
                              //             todate = endDate;
                              //           }, onCancel: () {
                              //             cancelled = true;
                              //           });
                              //         }
                              //         if (cancelled) {
                              //           return;
                              //         }
                              //         for (var key in controller.reportKeys) {
                              //           if (controller.commonFilters[key] == null) {
                              //             controller.commonFilters[key] = {};
                              //           }
                              //           controller.commonFilters[key]['filterduration'] = v?['value'].toString().converttoInt;
                              //           controller.commonFilters[key]['fromdate'] = fromdate;
                              //           controller.commonFilters[key]['todate'] = todate;
                              //         }
                              //         controller.commonFilters.refresh();
                              //         controller.getHutmentStatusReport();
                              //         controller.getConsentReport();
                              //         controller.getEligibilityReport();
                              //         controller.getTurnAroundTimeReport();
                              //         controller.getRentPaymentReport();
                              //       },
                              //       dropValidator: (Map<String, dynamic>? v) {
                              //         return null;
                              //       },
                              //       prefixWidget: Padding(
                              //         padding: const EdgeInsets.all(8.0),
                              //         child: SvgPicture.asset(
                              //           AssetsString.kCalender,
                              //           colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                              //         ),
                              //       ),
                              //     ),
                              //   );
                              // }),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: filterTags(reportKey: commonKey, controller: controller),
                    ),
                    const Divider(),
                    reportCharts(controller),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      return Stack(
        children: [
          CommonHeaderFooter(
            title: 'Dashboard',
            actions: [
              Obx(() {
                return InkWell(
                    onTap: isDialogOpen.value
                        ? null
                        : () async {
                            isDialogOpen.value = true;
                            Get.dialog(
                              Dialog(
                                  backgroundColor: ColorTheme.kWhite,
                                  alignment: Alignment.centerRight,
                                  shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  insetPadding: EdgeInsets.zero,
                                  child: const SizedBox(width: 600, child: NotificationList())),
                            ).then((value) {
                              isDialogOpen.value = false;
                            });
                          },
                    child: SvgPicture.asset(
                      AssetsString.kBellCountSvg,
                      colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                      height: 25,
                      width: 25,
                    ));
              }).paddingOnly(right: 8)
            ],
            txtSearchController: TextEditingController(),
            child: reportCharts(controller),
            onTapFilter: () async {
              showBottomBar.value = false;
              await showModalBottomSheet(
                context: Get.context!,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
                ),
                showDragHandle: true,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() {
                        return constrainedBoxWithPadding(
                          width: sizingInformation.isTablet ? Get.width : 200,
                          child: MultiDropDownSearchCustom(
                            items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                  'value': element['_id'],
                                  'label': element['name'],
                                })),
                            isCleanable: true,
                            filledColor: ColorTheme.kWarnColor,
                            borderColor: ColorTheme.kWarnColor,
                            optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                            selectedOptionColor: ColorTheme.kWarnColor,
                            fontColor: ColorTheme.kWhite,
                            clickOnCleanBtn: () async {
                              List selectedValue = [];
                              var society = await controller.getSociety(tenantproject: selectedValue);
                              for (var key in controller.reportKeys) {
                                if (controller.commonFilters[key] == null) {
                                  controller.commonFilters[key] = {};
                                }
                                controller.commonFilters[key].remove('society');
                                controller.commonFilters[key]['tenantproject'] = IISMethods().encryptDecryptObj(selectedValue);
                                controller.societyList[key] = society;
                              }
                              controller.commonFilters.refresh();
                              controller.getHutmentStatusReport();
                              controller.getConsentReport();
                              controller.getEligibilityReport();
                              controller.getTurnAroundTimeReport();
                              controller.getRentPaymentReport();
                            },
                            onChanged: (p0) async {
                              List selectedValue = [];
                              for (var e in p0) {
                                Map<String, dynamic> tenantProject = controller.tenantProject.firstWhere((element) => element['_id'] == e);
                                selectedValue.add({
                                  "tenantprojectid": e,
                                  "tenantproject": tenantProject['name'],
                                });
                              }
                              var society = await controller.getSociety(tenantproject: selectedValue);
                              for (var key in controller.reportKeys) {
                                if (controller.commonFilters[key] == null) {
                                  controller.commonFilters[key] = {};
                                }
                                controller.commonFilters[key].remove('society');
                                controller.commonFilters[key]['tenantproject'] = IISMethods().encryptDecryptObj(selectedValue);

                                controller.societyList[key] = society;
                              }
                              controller.commonFilters.refresh();
                              controller.getHutmentStatusReport();
                              controller.getConsentReport();
                              controller.getEligibilityReport();
                              controller.getTurnAroundTimeReport();
                              controller.getRentPaymentReport();
                            },
                            hintColor: ColorTheme.kWhite,
                            hintText: 'TENANT PROJECT',
                            dropValidator: (p0) {},
                            staticText: 'TENANT PROJECT',
                            prefixWidget: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                AssetsString.kTenantProject,
                                colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                              ),
                            ),
                            selectedItems: List<Map<String, dynamic>>.from(controller.commonFilters[commonKey]?['tenantproject'] ?? []),
                            field: 'tenantproject',
                          ),
                        );
                      }),
                      Obx(() {
                        return constrainedBoxWithPadding(
                          width: sizingInformation.isTablet ? Get.width : 200,
                          child: MultiDropDownSearchCustom(
                            items: List<Map<String, dynamic>>.from((controller.societyList[commonKey] ?? []).map((element) => {
                                  'value': element['_id'],
                                  'label': element['tenantname'],
                                })),
                            isCleanable: true,
                            optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                            selectedOptionColor: ColorTheme.kWarnColor,
                            filledColor: ColorTheme.kWarnColor,
                            borderColor: ColorTheme.kWarnColor,
                            fontColor: ColorTheme.kWhite,
                            clickOnCleanBtn: () async {
                              List selectedValue = [];
                              for (var key in controller.reportKeys) {
                                if (controller.commonFilters[key] == null) {
                                  controller.commonFilters[key] = {};
                                }
                                controller.commonFilters[key]['society'] = IISMethods().encryptDecryptObj(selectedValue);
                              }
                              controller.commonFilters.refresh();
                              controller.getHutmentStatusReport();
                              controller.getConsentReport();
                              controller.getEligibilityReport();
                              controller.getTurnAroundTimeReport();
                              controller.getRentPaymentReport();
                            },
                            onChanged: (p0) async {
                              List selectedValue = [];
                              for (var e in p0) {
                                Map<String, dynamic> tenantProject = controller.societyList[commonKey].firstWhere((element) => element['_id'] == e);
                                selectedValue.add({
                                  "societyid": e,
                                  "society": tenantProject['tenantname'],
                                });
                              }
                              for (var key in controller.reportKeys) {
                                if (controller.commonFilters[key] == null) {
                                  controller.commonFilters[key] = {};
                                }
                                controller.commonFilters[key]['society'] = IISMethods().encryptDecryptObj(selectedValue);
                              }
                              controller.commonFilters.refresh();
                              controller.getHutmentStatusReport();
                              controller.getConsentReport();
                              controller.getEligibilityReport();
                              controller.getTurnAroundTimeReport();
                              controller.getRentPaymentReport();
                            },
                            hintColor: ColorTheme.kWhite,
                            hintText: 'SOCIETY',
                            staticText: 'SOCIETY',
                            dropValidator: (p0) {
                              return null;
                            },
                            prefixWidget: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                AssetsString.kBuilding,
                                colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                              ),
                            ),
                            selectedItems: List<Map<String, dynamic>>.from(controller.commonFilters[commonKey]?['society'] ?? []),
                            field: 'society',
                          ),
                        );
                      }),
                      Obx(() {
                        jsonPrint(List<Map<String, dynamic>>.from(controller.filterDurationList), tag: "89654219865341653416");
                        return constrainedBoxWithPadding(
                            width: sizingInformation.isTablet ? Get.width : 200,
                            child: DropDownSearchCustom(
                              focusNode: FocusNode(),
                              canShiftFocus: false,
                              showPrefixDivider: false,
                              optionFocusHighlightColor: ColorTheme.kWarnColor.withOpacity(0.1),
                              selectedOptionColor: ColorTheme.kWarnColor,
                              fillColor: ColorTheme.kWarnColor,
                              borderColor: ColorTheme.kWarnColor,
                              fontColor: ColorTheme.kWhite,
                              staticText: 'DURATION',
                              prefixWidget: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  AssetsString.kCalender,
                                  colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                                ),
                              ),
                              items: List<Map<String, dynamic>>.from(controller.filterDurationList),
                              initValue: controller.commonFilters['common']['filterduration'].toString().isNotNullOrEmpty
                                  ? controller.commonFilters['common']['filterduration'] == 0
                                      ? {
                                          'value': 0,
                                          'label':
                                              '${controller.commonFilters['common']['fromdate'].toString().toDateFormat()} - ${controller.commonFilters['common']['todate'].toString().toDateFormat()}',
                                        }
                                      : List<Map<String, dynamic>>.from(controller.filterDurationList).firstWhere(
                                          (element) => element['value'] == controller.commonFilters['common']['filterduration'],
                                          orElse: () {
                                            return {};
                                          },
                                        )
                                  : null,
                              hintText: "DURATION",
                              isCleanable: false,
                              hintColor: ColorTheme.kWarnColor,
                              isSearchable: false,
                              onChanged: (v) async {
                                devPrint("865496451563241653241 $v");
                                Future.delayed(const Duration(milliseconds: 1)).then(
                                  (value) async {
                                    String fromdate = '';
                                    String todate = '';
                                    bool cancelled = false;
                                    debugPrint(v.toString());
                                    if (v?['value'].toString().converttoInt == 0) {
                                      await showCustomDateRangePicker(onDateSelected: (String startDate, String endDate) {
                                        fromdate = startDate;
                                        todate = endDate;
                                      }, onCancel: () {
                                        cancelled = true;
                                      });
                                    }
                                    if (cancelled) {
                                      return;
                                    }
                                    for (var key in controller.reportKeys) {
                                      if (controller.commonFilters[key] == null) {
                                        controller.commonFilters[key] = {};
                                      }
                                      controller.commonFilters[key]['filterduration'] = v?['value'].toString().converttoInt;
                                      controller.commonFilters[key]['fromdate'] = fromdate;
                                      controller.commonFilters[key]['todate'] = todate;
                                    }
                                    controller.commonFilters.refresh();
                                    controller.getHutmentStatusReport();
                                    controller.getConsentReport();
                                    controller.getEligibilityReport();
                                    controller.getTurnAroundTimeReport();
                                    controller.getRentPaymentReport();
                                  },
                                );
                              },
                              dropValidator: (val) {
                                return null;
                              },
                            ));
                      }),
                    ],
                  ),
                ),
              );
              showBottomBar.value = true;
            },
          ),
        ],
      );
    });
  }

  reportCharts(DashBoardController controller) {
    // ApprovalMasterController approvalMasterController = Get.put(ApprovalMasterController());
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      return Padding(
        padding: EdgeInsets.all(sizingInformation.isMobile ? 0 : 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !sizingInformation.isDesktop
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
                    child: filterTags(reportKey: 'common', controller: controller),
                  )
                : const SizedBox.shrink(),
            expandedRowColumn(
              !sizingInformation.isDesktop,
              commonRefreshIndicator(
                onRefresh: controller.onRefresh,
                sizingInformation: sizingInformation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      VisibilityDetector(
                        key: const Key('hutmentstatusreport'),
                        onVisibilityChanged: (info) {
                          var visiblePercentage = info.visibleFraction * 100;
                          devPrint(visiblePercentage);
                          if (!controller.statusCountReportLoading.value && controller.statusCountReport.isNullOrEmpty && visiblePercentage > 0) {
                            controller.getHutmentStatusReport();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(color: ColorTheme.kWhite, borderRadius: BorderRadius.circular(6), boxShadow: [
                              BoxShadow(
                                color: ColorTheme.kBlack.withOpacity(0.07),
                                blurRadius: 10,
                                spreadRadius: 3,
                              )
                            ]),
                            child: Column(
                              children: [
                                tabHeaderWidget(
                                  title: 'Hutment Status',
                                  filterTags: filterTags(reportKey: 'hutmentstatusreport', controller: controller),
                                  filterButton: Builder(
                                    builder: (context) {
                                      return controller.showFilterButton(reportKey: 'hutmentstatusreport', context: context);
                                    },
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 200,
                                  ),
                                  child: Obx(() {
                                    return CustomShimmer(
                                      isLoading: controller.statusCountReportLoading.value,
                                      child: Scrollbar(
                                        interactive: true,
                                        controller: controller.statusCountScrollController,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: sizingInformation.isMobile ? 6 : 16.0),
                                          child: Obx(() {
                                            List<Color> colors = [
                                              ColorTheme.kReportGreen,
                                              ColorTheme.kReportOccurYellow,
                                              ColorTheme.kReportLightGreen,
                                              ColorTheme.kReportSkyBlue,
                                              ColorTheme.kReportCoral,
                                              ColorTheme.kReportBlue,
                                              ColorTheme.kReportYellow,
                                              ColorTheme.kReportPeach,
                                              ColorTheme.kReportLavender,
                                            ];
                                            return SizedBox(
                                              height: 200,
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                controller: controller.statusCountScrollController,
                                                scrollDirection: Axis.horizontal,
                                                // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                //     crossAxisSpacing: sizingInformation.isMobile
                                                //         ? 4
                                                //         : sizingInformation.isTablet || MediaQuery.of(context).size.width < 1500
                                                //             ? MediaQuery.of(context).size.width < 1300
                                                //                 ? MediaQuery.of(context).size.width * 0.0055
                                                //                 : 16
                                                //             : MediaQuery.of(context).size.width * 0.015,
                                                //     mainAxisSpacing: sizingInformation.isMobile
                                                //         ? 4
                                                //         : sizingInformation.isTablet || MediaQuery.of(context).size.width < 1500
                                                //             ? MediaQuery.of(context).size.width < 1300
                                                //                 ? MediaQuery.of(context).size.width * 0.0055
                                                //                 : 16
                                                //             : MediaQuery.of(context).size.width * 0.015,
                                                //     crossAxisCount: sizingInformation.isMobile
                                                //         ? 3
                                                //         : sizingInformation.isTablet
                                                //             ? 4
                                                //             : 9),
                                                separatorBuilder: (context, index) {
                                                  return const SizedBox(
                                                    width: 16,
                                                  );
                                                },
                                                itemBuilder: (context, index) {
                                                  return InkResponse(
                                                    onTap: () {
                                                      controller.getTenantList(
                                                        filter: {
                                                          ...controller.commonFilters['hutmentstatusreport'] ?? {},
                                                          "tenantstatusid": controller.statusCountReport[index]['_id']
                                                        },
                                                        endpoint: 'hutmentstatustabularreport',
                                                        title: controller.statusCountReport[index]['tenantstatus'],
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: colors[index % colors.length].withOpacity(controller.statusCountReportLoading.value ? 1 : 0.1),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: colors[index % colors.length].withOpacity(controller.statusCountReportLoading.value ? 1 : 0.1),
                                                          )),
                                                      width: max(120, MediaQuery.sizeOf(context).width / 10),
                                                      padding: const EdgeInsets.all(8),
                                                      margin: EdgeInsets.only(
                                                          left: index == 0 ? 16 : 0,
                                                          right: (index + 1) == (controller.statusCountReportLoading.value ? 7 : controller.statusCountReport.length) ? 16 : 0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          TextWidget(
                                                            text: controller.statusCountReportLoading.value ? '' : controller.statusCountReport[index]['total'] ?? '',
                                                            fontSize: 30,
                                                            fontWeight: FontTheme.notoMedium,
                                                          ),
                                                          TextWidget(
                                                            text: controller.statusCountReportLoading.value ? '' : controller.statusCountReport[index]['tenantstatus'] ?? '',
                                                            fontSize: !sizingInformation.isDesktop
                                                                ? sizingInformation.isMobile
                                                                    ? 12
                                                                    : 14
                                                                : MediaQuery.of(context).size.width < 1550
                                                                    ? 14
                                                                    : 16,
                                                            fontWeight: FontTheme.notoMedium,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                // physics: const NeverScrollableScrollPhysics(),
                                                itemCount: (controller.statusCountReportLoading.value ? 11 : controller.statusCountReport.length),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      VisibilityDetector(
                        key: const Key('consentreport'),
                        onVisibilityChanged: (info) {
                          var visiblePercentage = info.visibleFraction * 100;
                          devPrint(visiblePercentage);
                          if (!controller.consentReportLoading.value && controller.consentReport.isNullOrEmpty && visiblePercentage > 0) {
                            controller.getConsentReport();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(color: ColorTheme.kWhite, borderRadius: BorderRadius.circular(6), boxShadow: [
                              BoxShadow(
                                color: ColorTheme.kBlack.withOpacity(0.07),
                                blurRadius: 10,
                                spreadRadius: 3,
                              )
                            ]),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                tabHeaderWidget(
                                  title: 'Documents',
                                  filterTags: filterTags(reportKey: 'consentreport', controller: controller),
                                  filterButton: Builder(
                                    builder: (context) {
                                      return controller.showFilterButton(reportKey: 'consentreport', context: context);
                                    },
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(minHeight: 400),
                                  child: Obx(() {
                                    return MasonryGridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: sizingInformation.isDesktop ? 3 : 1),
                                      itemBuilder: (BuildContext context, int index) {
                                        return SizedBox(
                                          height: 400,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(color: ColorTheme.kWhite, borderRadius: BorderRadius.circular(10), boxShadow: [
                                                BoxShadow(
                                                  color: ColorTheme.kBlack.withOpacity(0.07),
                                                  blurRadius: 10,
                                                  spreadRadius: 3,
                                                )
                                              ]),
                                              child: Obx(() {
                                                List<Map<String, dynamic>> data = controller.consentReport.values.length <= index && controller.consentReportLoading.value
                                                    ? [
                                                        {
                                                          'value': 1,
                                                          'label': 'Loading',
                                                          '_id': -1,
                                                        },
                                                      ]
                                                    : List<Map<String, dynamic>>.from(controller.consentReport.values.toList()[index]);
                                                return CustomShimmer(
                                                  isLoading: controller.consentReportLoading.value,
                                                  child: SfCircularChart(
                                                    annotations: [
                                                      CircularChartAnnotation(
                                                          height: '100%',
                                                          width: '100%',
                                                          widget: PhysicalModel(
                                                            shape: BoxShape.circle,
                                                            elevation: 0,
                                                            color: Colors.transparent,
                                                            child: Center(
                                                              child: TextWidget(
                                                                text: controller.consentReport.values.length <= index && controller.consentReportLoading.value
                                                                    ? ''
                                                                    : controller.consentReport.keys.toList()[index],
                                                                fontWeight: FontTheme.notoSemiBold,
                                                                fontSize: 16,
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          )),
                                                    ],
                                                    palette: [
                                                      ColorTheme.kGraphYellowColor.withOpacity(0.8),
                                                      ColorTheme.kGraphGreenColor.withOpacity(0.8),
                                                      ColorTheme.kGraphBlueColor.withOpacity(0.8),
                                                      ColorTheme.kGraphOrangeColor.withOpacity(0.8),
                                                    ],
                                                    legend: const Legend(
                                                      isVisible: true,
                                                      alignment: ChartAlignment.center,
                                                      position: LegendPosition.top,
                                                    ),
                                                    series: [
                                                      DoughnutSeries(
                                                        onPointTap: (pointInteractionDetails) {
                                                          int pointIndex = pointInteractionDetails.pointIndex!;
                                                          controller.getTenantList(
                                                            filter: {
                                                              ...controller.commonFilters['consentreport'] ?? {},
                                                              "reportof": controller.consentReport.keys.toList()[index],
                                                              "status": pointIndex // 0. Pendings, 1. Received
                                                              // "projectid": "660d31c0ea684f20148ccfa6"
                                                            },
                                                            endpoint: 'consenttabularreport',
                                                            title: '${data[pointIndex]['label']} ${controller.consentReport.keys.toList()[index]}',
                                                          );
                                                        },
                                                        dataSource: data,
                                                        innerRadius: sizingInformation.isDesktop ? calculateInnerRadius(sizingInformation).toString() : '100',
                                                        radius: sizingInformation.isDesktop ? calculateRadius(sizingInformation).toString() : '150',
                                                        // dataSource: (controller.commonConsentReport.values.last as Map?)
                                                        //     ?.keys
                                                        //     .map((e) => {
                                                        //           'label': e,
                                                        //           'value': controller.commonConsentReport[e],
                                                        //         })
                                                        //     .toList(),
                                                        xValueMapper: (datum, index) {
                                                          return datum['label'];
                                                        },
                                                        dataLabelMapper: (datum, index) {
                                                          return '${datum['value']}';
                                                        },
                                                        yValueMapper: (datum, index) => datum['value'],
                                                        dataLabelSettings: const DataLabelSettings(
                                                            isVisible: true,
                                                            labelPosition: ChartDataLabelPosition.inside,
                                                            textStyle: TextStyle(
                                                              fontWeight: FontTheme.notoMedium,
                                                              fontSize: 14,
                                                            )
                                                            // useSeriesColor: true,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        );
                                      },
                                      itemCount: controller.consentReport.values.isEmpty && controller.consentReportLoading.value ? 3 : controller.consentReport.keys.length,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      VisibilityDetector(
                        key: const Key('tatreport'),
                        onVisibilityChanged: (info) {
                          var visiblePercentage = info.visibleFraction * 100;
                          devPrint(visiblePercentage);
                          if (!controller.tatReportLoading.value && controller.tatReport.isNullOrEmpty && visiblePercentage > 0) {
                            controller.getTurnAroundTimeReport();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(color: ColorTheme.kWhite, borderRadius: BorderRadius.circular(6), boxShadow: [
                              BoxShadow(
                                color: ColorTheme.kBlack.withOpacity(0.07),
                                blurRadius: 10,
                                spreadRadius: 3,
                              )
                            ]),
                            child: Column(
                              children: [
                                tabHeaderWidget(
                                  title: 'TAT (Turn Around Time)',
                                  filterTags: filterTags(reportKey: 'tatreport', controller: controller),
                                  filterButton: Builder(
                                    builder: (context) {
                                      return controller.showFilterButton(reportKey: 'tatreport', context: context);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Builder(builder: (ctx) {
                                    List<Color> colors = [
                                      ColorTheme.kReportGreen,
                                      ColorTheme.kReportOccurYellow,
                                      ColorTheme.kReportSkyBlue,
                                      ColorTheme.kReportDarkYellow,
                                      ColorTheme.kReportLightGreen,
                                      ColorTheme.kReportBlue,
                                      ColorTheme.kReportYellow,
                                    ];
                                    ScrollController scrollcontroller = ScrollController();
                                    return Scrollbar(
                                      interactive: true,
                                      controller: scrollcontroller,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SizedBox(
                                          height: 200,
                                          child: Obx(() {
                                            return CustomShimmer(
                                              isLoading: controller.tatReportLoading.value,
                                              child: ListView.separated(
                                                controller: scrollcontroller,
                                                scrollDirection: Axis.horizontal,
                                                itemCount: controller.tatReport.isNullOrEmpty && controller.tatReportLoading.value ? 7 : controller.tatReport.length,
                                                shrinkWrap: true,
                                                separatorBuilder: (context, index) {
                                                  return Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Positioned(
                                                        bottom: index % 2 == 0 ? 110 : null,
                                                        top: index % 2 != 0 ? 110 : null,
                                                        child: SizedBox(
                                                          width: 60,
                                                          child: TextWidget(
                                                            text: controller.tatReportLoading.value && controller.tatReport.length <= index
                                                                ? ''
                                                                : '${controller.tatReport[index]['TAT'] ?? 0} Days',
                                                            fontSize: 13,
                                                            height: 1,
                                                            fontWeight: FontTheme.notoMedium,
                                                            textOverflow: TextOverflow.visible,
                                                            color: ColorTheme.kBlue,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 2,
                                                        width: 62,
                                                        color: ColorTheme.kBorderColor,
                                                      ),
                                                    ],
                                                  );
                                                },
                                                itemBuilder: (context, index) {
                                                  double width = MediaQuery.sizeOf(context).width;
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        // width: 150,
                                                        height: 80,
                                                        child: index % 2 == 0
                                                            ? Column(
                                                                children: [
                                                                  TextWidget(
                                                                    text: controller.tatReportLoading.value && controller.tatReport.length <= index
                                                                        ? ''
                                                                        : controller.tatReport[index]['status'] ?? '',
                                                                    fontSize: 16,
                                                                    fontWeight: FontTheme.notoMedium,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        const CircleAvatar(
                                                                          radius: 4,
                                                                          backgroundColor: ColorTheme.kBorderColor,
                                                                        ),
                                                                        Container(
                                                                          height: 32,
                                                                          width: 2,
                                                                          color: ColorTheme.kBorderColor,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                            : null,
                                                      ),
                                                      SizedBox(
                                                        height: 40,
                                                        width: max(200, (width - globalTableWidth.value) / 11 - 70),
                                                        child: TimelineTile(
                                                          isFirst: index == 0,
                                                          axis: TimelineAxis.horizontal,
                                                          isLast: controller.tatReport.length - 1 == index,
                                                          alignment: TimelineAlign.start,
                                                          indicatorStyle: IndicatorStyle(
                                                            indicator: Container(
                                                              color: controller.tatReportLoading.value ? Colors.transparent : ColorTheme.kWhite,
                                                              child: CircleAvatar(
                                                                backgroundColor: colors[index % colors.length].withOpacity(controller.tatReportLoading.value ? 1 : 0.1),
                                                                foregroundColor: colors[index % colors.length],
                                                                child: controller.tatReportLoading.value && controller.tatReport.length <= index
                                                                    ? Container()
                                                                    : SvgPicture.network(
                                                                        controller.tatReportLoading.value && controller.tatReport.length <= index
                                                                            ? ''
                                                                            : controller.tatReport[index]['image'] ?? '',
                                                                        colorFilter: ColorFilter.mode(
                                                                          colors[index % colors.length],
                                                                          BlendMode.srcIn,
                                                                        ),
                                                                      ).paddingAll(7),
                                                              ),
                                                            ),
                                                            padding: EdgeInsets.zero,
                                                            width: 40,
                                                            height: 40,
                                                          ),
                                                          beforeLineStyle: const LineStyle(
                                                            color: ColorTheme.kBorderColor,
                                                            thickness: 2,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        // width: 150,
                                                        height: 80,
                                                        child: index % 2 != 0
                                                            ? Column(
                                                                children: [
                                                                  TextWidget(
                                                                    text: controller.tatReportLoading.value && controller.tatReport.length <= index
                                                                        ? ''
                                                                        : controller.tatReport[index]['status'] ?? '',
                                                                    fontSize: 16,
                                                                    fontWeight: FontTheme.notoMedium,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        const CircleAvatar(
                                                                          radius: 4,
                                                                          backgroundColor: ColorTheme.kBorderColor,
                                                                        ),
                                                                        Container(
                                                                          height: 32,
                                                                          width: 2,
                                                                          color: ColorTheme.kBorderColor,
                                                                        )
                                                                      ].reversed.toList(),
                                                                    ),
                                                                  )
                                                                ].reversed.toList(),
                                                              )
                                                            : null,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ColorTheme.kWhite,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: MasonryGridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: sizingInformation.isDesktop ? 2 : 1),
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 500,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(color: ColorTheme.kWhite, borderRadius: BorderRadius.circular(10), boxShadow: [
                                    BoxShadow(
                                      color: ColorTheme.kBlack.withOpacity(0.07),
                                      blurRadius: 10,
                                      spreadRadius: 3,
                                    )
                                  ]),
                                  child: index == 0
                                      ? VisibilityDetector(
                                          key: const Key('rentpaymentstatusreport'),
                                          onVisibilityChanged: (info) {
                                            var visiblePercentage = info.visibleFraction * 100;
                                            devPrint(visiblePercentage);
                                            if (!controller.rentPaymentReportLoading.value && controller.rentPaymentReport.isNullOrEmpty && visiblePercentage > 0) {
                                              controller.getRentPaymentReport();
                                            }
                                          },
                                          child: CustomShimmer(
                                            isLoading: controller.rentPaymentReportLoading.value,
                                            child: Column(
                                              children: [
                                                tabHeaderWidget(
                                                  title: 'Rent Payment Status',
                                                  filterTags: filterTags(reportKey: 'rentpaymentstatusreport', controller: controller),
                                                  filterButton: Builder(
                                                    builder: (context) {
                                                      return controller.showFilterButton(reportKey: 'rentpaymentstatusreport', context: context);
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Obx(() {
                                                    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(controller.rentPaymentReport.value);
                                                    return SfCircularChart(
                                                      palette: [
                                                        ColorTheme.kGraphYellowColor.withOpacity(0.8),
                                                        ColorTheme.kGraphGreenColor.withOpacity(0.8),
                                                        ColorTheme.kGraphBlueColor.withOpacity(0.8),
                                                        ColorTheme.kGraphOrangeColor.withOpacity(0.8),
                                                        ColorTheme.kGraphPurpleColor.withOpacity(0.8),
                                                      ],
                                                      legend: const Legend(
                                                        isVisible: true,
                                                        alignment: ChartAlignment.center,
                                                        position: LegendPosition.top,
                                                      ),
                                                      series: [
                                                        PieSeries(
                                                          startAngle: 90,
                                                          endAngle: 450,
                                                          onPointTap: (pointInteractionDetails) {
                                                            int pointIndex = pointInteractionDetails.pointIndex!;
                                                            controller.getTenantList(
                                                              filter: {
                                                                "status": controller.rentPaymentReport[pointIndex]['_id'],
                                                                ...controller.commonFilters['rentpaymentstatusreport'] ?? {}
                                                                // "projectid": "660d31c0ea684f20148ccfa6"
                                                              },
                                                              endpoint: 'rentpaymentstatustabularreport',
                                                              title: '${data[pointIndex]['_id'].toString().capitalizeFirst} Rent Payment',
                                                            );
                                                          },
                                                          dataSource: /* controller.rentPaymentReportLoading.value && data.isNullOrEmpty
                                                                ? [
                                                                    {
                                                                      'result': 1,
                                                                      '_id': "loading",
                                                                    }
                                                                  ]
                                                                :*/
                                                              data,
                                                          radius: '150',
                                                          // dataSource: (controller.commonConsentReport.values.last as Map?)
                                                          //     ?.keys
                                                          //     .map((e) => {
                                                          //           'label': e,
                                                          //           'value': controller.commonConsentReport[e],
                                                          //         })
                                                          //     .toList(),
                                                          xValueMapper: (datum, index) {
                                                            return datum['_id'].toString().capitalizeFirst;
                                                          },
                                                          dataLabelMapper: (datum, index) {
                                                            return '${datum['_id'].toString().capitalizeFirst}\n${datum['result']}';
                                                          },
                                                          yValueMapper: (datum, index) => datum['result'],
                                                          dataLabelSettings: const DataLabelSettings(
                                                              isVisible: true,
                                                              labelPosition: ChartDataLabelPosition.inside,
                                                              textStyle: TextStyle(
                                                                fontWeight: FontTheme.notoMedium,
                                                                fontSize: 14,
                                                              )
                                                              // useSeriesColor: true,
                                                              ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ))
                                      : VisibilityDetector(
                                          key: const Key('eligibilityreport'),
                                          onVisibilityChanged: (info) {
                                            var visiblePercentage = info.visibleFraction * 100;
                                            devPrint(visiblePercentage);
                                            if (!controller.eligibilityReportLoading.value && controller.eligibilityReport.isNullOrEmpty && visiblePercentage > 0) {
                                              controller.getEligibilityReport();
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              tabHeaderWidget(
                                                title: 'Eligibility Status',
                                                filterTags: filterTags(reportKey: 'eligibilityreport', controller: controller),
                                                filterButton: Builder(
                                                  builder: (context) {
                                                    return controller.showFilterButton(reportKey: 'eligibilityreport', context: context);
                                                  },
                                                ),
                                              ),
                                              Expanded(
                                                child: Obx(() {
                                                  List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(controller.eligibilityReport.value);
                                                  return SfCircularChart(
                                                    palette: [
                                                      ColorTheme.kGraphYellowColor.withOpacity(0.8),
                                                      ColorTheme.kGraphGreenColor.withOpacity(0.8),
                                                      ColorTheme.kGraphBlueColor.withOpacity(0.8),
                                                      ColorTheme.kGraphOrangeColor.withOpacity(0.8),
                                                      ColorTheme.kGraphPurpleColor.withOpacity(0.8),
                                                    ],
                                                    legend: const Legend(
                                                      isVisible: true,
                                                      alignment: ChartAlignment.center,
                                                      position: LegendPosition.top,
                                                    ),
                                                    series: [
                                                      PieSeries(
                                                        startAngle: 90,
                                                        endAngle: 450,
                                                        onPointTap: (pointInteractionDetails) {
                                                          int pointIndex = pointInteractionDetails.pointIndex!;
                                                          controller.getTenantList(
                                                            filter: {
                                                              "eligibilityid": controller.eligibilityReport[pointIndex]['_id'],
                                                              ...controller.commonFilters['eligibilityreport'] ?? {}
                                                            },
                                                            endpoint: 'eligibilitytabularreport',
                                                            title: '${data[pointIndex]['eligibilityname'].toString().capitalizeFirst}',
                                                          );
                                                        },
                                                        dataSource: data,
                                                        radius: '150',
                                                        xValueMapper: (datum, index) {
                                                          return datum['eligibilityname'].toString().capitalizeFirst;
                                                        },
                                                        dataLabelMapper: (datum, index) {
                                                          return '${datum['eligibilityname'].toString().capitalizeFirst}\n${datum['result']}';
                                                        },
                                                        yValueMapper: (datum, index) => datum['result'],
                                                        dataLabelSettings: const DataLabelSettings(
                                                            isVisible: true,
                                                            labelPosition: ChartDataLabelPosition.inside,
                                                            textStyle: TextStyle(
                                                              fontWeight: FontTheme.notoMedium,
                                                              fontSize: 14,
                                                            )
                                                            // useSeriesColor: true,
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                          itemCount: 2,
                        ),
                      ),
                      // const SizedBox(
                      //   height: 16,
                      // ),
                      // VisibilityDetector(
                      //   key: const Key('approvals'),
                      //   onVisibilityChanged: (info) {
                      //     var visiblePercentage = info.visibleFraction * 100;
                      //     devPrint(visiblePercentage);
                      //     if (controller.pageName.value != "approvals" || (!controller.loadingData.value && (controller.setDefaultData.data.isNullOrEmpty /*&& controller.setDefaultData.contentLength != 0*/) && visiblePercentage > 0)) {
                      //       controller.pageName.value = "approvals";
                      //       controller.getApprovalsList(approvalsFilter: {'isexpirybased': 1});
                      //     }
                      //   },
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Container(
                      //       decoration: BoxDecoration(color: ColorTheme.kWhite, borderRadius: BorderRadius.circular(6), boxShadow: [
                      //         BoxShadow(
                      //           color: ColorTheme.kBlack.withOpacity(0.07),
                      //           blurRadius: 10,
                      //           spreadRadius: 3,
                      //         )
                      //       ]),
                      //       child: Column(
                      //         children: [
                      //           tabHeaderWidget(
                      //             title: 'Approvals',
                      //             filterTags: filterApprovalsTags(controller),
                      //             filterButton: Builder(
                      //               builder: (context) {
                      //                 return controller.showApprovalsFilterButton(context: context);
                      //               },
                      //             ),
                      //           ),
                      //           Padding(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: Container(
                      //               clipBehavior: Clip.hardEdge,
                      //               height: Get.height / 1.2,
                      //               decoration: BoxDecoration(color: ColorTheme.kWhite, borderRadius: BorderRadius.circular(6), boxShadow: [
                      //                 BoxShadow(
                      //                   color: ColorTheme.kBlack.withOpacity(0.07),
                      //                   blurRadius: 10,
                      //                   spreadRadius: 3,
                      //                 )
                      //               ]),
                      //               child: Obx(() {
                      //                 return CommonDataTableWidget(
                      //                   onTapDocument: (id, projectid, documentMap) async {
                      //                     await approvalMasterController.getMasterFormData(parentId: id, pagename: "approvals");
                      //                     await CustomDialogs().customPopDialog(child: addDocTemplate(controller: approvalMasterController, parentId: id, pagename: "approvals", projectid: projectid ?? ""));
                      //                     approvalMasterController.pageName.value = "approvals";
                      //                     approvalMasterController.dialogBoxData.value = ApprovalJson.designationFormFields(approvalMasterController.pageName.value);
                      //                   },
                      //                   isTableEyeButtonVisible: true,
                      //                   inTableEyeButton: (id) async {
                      //                     await approvalMasterController.getMasterFormData(parentId: id, pagename: "templateassignment", assignedproject: 1);
                      //                     await CustomDialogs().customPopDialog(child: addApprovalTemplate(title: "Project Assignment", parentId: id, pagename: "templateassignment", isCrudAvailable: false));
                      //                     controller.pageName.value = "approvals";
                      //                     controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                      //                   },
                      //                   isLoading: controller.loadingData.value,
                      //                   tableScrollController: approvalMasterController.tableScrollController,
                      //                   isPageLoading: controller.loadingPaginationData.value,
                      //                   onRefresh: () async {
                      //                     controller.setDefaultData.pageNo.value = 1;
                      //                     await controller.getApprovalsList(approvalsFilter: {'isexpirybased': 1});
                      //                   },
                      //                   pageName: controller.pageName.value,
                      //                   editDataFun: (id, index) {
                      //                     approvalMasterController.setFormData(id: id, editeDataIndex: index);
                      //                     CustomDialogs().customFilterDialogs(context: context, widget: const ApprovalMasterForm(title: "Update", btnName: "Update"));
                      //                   },
                      //                   deleteDataFun: (id, index) {
                      //                     approvalMasterController.deleteData({
                      //                       "_id": id,
                      //                     });
                      //                   },
                      //                   field3title: "approvals" == "approvaltemplate" ? "Manage" : "Customize",
                      //                   field3: controller.pageName.value == 'approvaltemplate'
                      //                       ? (id, parentNameString) async {
                      //                           await approvalMasterController.getMasterFormData(parentId: id, pagename: "approvals");
                      //                           await CustomDialogs().customPopDialog(child: addApprovalTemplate(title: "Manage", subTitle: parentNameString ?? "", parentId: id, pagename: "approvals", parentNameString: parentNameString ?? ""));
                      //                           controller.pageName.value = "approvals";
                      //                           controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                      //                         }
                      //                       : controller.pageName.value == 'templateassignment'
                      //                           ? (id, parentNameString) async {
                      //                               await approvalMasterController.getMasterFormData(parentId: id, pagename: "approvals");
                      //                               await CustomDialogs().customPopDialog(child: addApprovalTemplate(title: "Customize Template", parentId: id, pagename: "approvals", parentNameString: parentNameString ?? "", isHeaderVisible: true));
                      //                               controller.pageName.value = "approvals";
                      //                               controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                      //                             }
                      //                           : null,
                      //                   field4title: "approvals" == "approvaltemplate" ? "View" : "View",
                      //                   field4: controller.pageName.value == 'approvaltemplate'
                      //                       ? (id, parentNameString, index) async {
                      //                           await approvalMasterController.getMasterFormData(parentId: id, pagename: "approvals");
                      //                           await CustomDialogs().customPopDialog(
                      //                               child: addApprovalTemplate(title: "Manage", subTitle: parentNameString ?? "", parentId: id, parentIndex: index, pagename: "approvals", isCrudAvailable: false, isParentFormVisible: true));
                      //                           controller.pageName.value = "approvals";
                      //                           controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                      //                         }
                      //                       : controller.pageName.value == 'templateassignment'
                      //                           ? (id, parentNameString, index) async {
                      //                               await approvalMasterController.getMasterFormData(parentId: id, pagename: "approvals");
                      //                               await CustomDialogs()
                      //                                   .customPopDialog(child: addApprovalTemplate(title: "Customize Template", parentId: id, parentIndex: index, pagename: "approvals", isCrudAvailable: false, isHeaderVisible: true));
                      //                               controller.pageName.value = "approvals";
                      //                               controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                      //                             }
                      //                           : null,
                      //                   inTableAddButton: (id, parentNameString) async {
                      //                     approvalMasterController.setMasterFormData(parentId: id, page: 'projectassign', parentNameString: parentNameString);
                      //                     await CustomDialogs().customFilterDialogs(context: context, widget: const ApprovalMasterForm(isMasterForm: true, pagename: 'projectassign'));
                      //                     controller.dialogBoxData.value = ApprovalJson.designationFormFields("approvals");
                      //                   },
                      //                   onPageChange: (pageNo, pageLimit) {
                      //                     controller.searchText.value = approvalMasterController.searchController.text;
                      //                     controller.setDefaultData.pageNo.value = pageNo;
                      //                     controller.setDefaultData.pageLimit = pageLimit;
                      //                     controller.getApprovalsList(approvalsFilter: {'isexpirybased': 1});
                      //                   },
                      //                   onSort: (sortFieldName) {
                      //                     if (controller.setDefaultData.sortData.containsKey(sortFieldName)) {
                      //                       controller.setDefaultData.sortData[sortFieldName] = controller.setDefaultData.sortData[sortFieldName] == 1 ? -1 : 1;
                      //                     } else {
                      //                       controller.setDefaultData.sortData.clear();
                      //                       controller.setDefaultData.sortData[sortFieldName] = 1;
                      //                     }
                      //                     controller.getApprovalsList(approvalsFilter: {'isexpirybased': 1});
                      //                   },
                      //                   handleGridChange: (index, field, type, value, masterfieldname, name) {
                      //                     // devPrint("type  $type\nfield  $field\nindex $index\nvalue $value\n1248945431\n");
                      //                     approvalMasterController.handleGridChange(type: type, field: field, index: index, value: value);
                      //                   },
                      //                   setDefaultData: controller.setDefaultData,
                      //                   data: controller.setDefaultData.data.value,
                      //                   fieldOrder: controller.setDefaultData.fieldOrder.value,
                      //                 );
                      //               }),
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget filterTags({
    required String reportKey,
    required DashBoardController controller,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        Map filter = ((controller.commonFilters[reportKey] ?? {}));
        List keys = filter.keys.toList();
        if (reportKey == 'common' || !const DeepCollectionEquality().equals(controller.commonFilters['common'], controller.commonFilters[reportKey])) {
          return Row(
            children: [
              ...List.generate(keys.length, (index) {
                if (keys[index] == 'todate' || keys[index] == 'fromdate') {
                  return const SizedBox();
                }
                if (keys[index] == 'filterduration') {
                  if (filter[keys[index]] == 1) {
                    return const SizedBox();
                  }
                  Map duration = IISMethods().encryptDecryptObj(controller.filterDurationList.firstWhere((p0) => p0['value'] == filter[keys[index]]));
                  if (duration['value'] == 0) {
                    duration['label'] = '${filter['fromdate'].toString().toDateFormat()} - ${filter['todate'].toString().toDateFormat()}';
                  }
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(color: ColorTheme.kWarnColor.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          TextWidget(
                            text: duration['label'],
                            height: 1,
                            fontWeight: FontTheme.notoMedium,
                          ),
                          4.kW,
                          InkResponse(
                            onTap: () {
                              controller.commonFilters[reportKey].remove('todate');
                              controller.commonFilters[reportKey].remove('fromdate');
                              controller.commonFilters[reportKey].remove('filterduration');
                              if (reportKey == 'common') {
                                for (var key in controller.reportKeys) {
                                  controller.commonFilters[key] = IISMethods().encryptDecryptObj(controller.commonFilters[reportKey]);
                                }
                              }
                              controller.commonFilters.refresh();
                              switch (reportKey) {
                                case 'hutmentstatusreport':
                                  controller.getHutmentStatusReport();
                                  break;
                                case 'consentreport':
                                  controller.getConsentReport();
                                  break;
                                case 'eligibilityreport':
                                  controller.getEligibilityReport();
                                  break;
                                case 'tatreport':
                                  controller.getTurnAroundTimeReport();
                                  break;
                                case 'rentpaymentstatusreport':
                                  controller.getRentPaymentReport();
                                case 'common':
                                  controller.getHutmentStatusReport();
                                  controller.getConsentReport();
                                  controller.getEligibilityReport();
                                  controller.getTurnAroundTimeReport();
                                  controller.getRentPaymentReport();
                              }
                            },
                            child: const Icon(
                              Icons.close,
                              size: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return Row(
                  children: [
                    ...List.generate(
                      ((filter[keys[index]] ?? []) as List).length,
                      (i) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(color: ColorTheme.kWarnColor.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                TextWidget(
                                  text: filter[keys[index]][i][keys[index]],
                                  height: 1,
                                  fontWeight: FontTheme.notoMedium,
                                ),
                                4.kW,
                                InkResponse(
                                  onTap: () async {
                                    ((filter[keys[index]] ?? []) as List).removeAt(i);
                                    if (reportKey == 'common') {
                                      for (var key in controller.reportKeys) {
                                        controller.commonFilters[key] = await IISMethods().encryptDecryptObj(controller.commonFilters[reportKey]);
                                      }
                                    }
                                    controller.commonFilters.refresh();
                                    switch (reportKey) {
                                      case 'hutmentstatusreport':
                                        controller.getHutmentStatusReport();
                                        break;
                                      case 'consentreport':
                                        controller.getConsentReport();
                                        break;
                                      case 'eligibilityreport':
                                        controller.getEligibilityReport();
                                        break;
                                      case 'tatreport':
                                        controller.getTurnAroundTimeReport();
                                        break;
                                      case 'rentpaymentstatusreport':
                                        controller.getRentPaymentReport();
                                      case 'common':
                                        controller.getHutmentStatusReport();
                                        controller.getConsentReport();
                                        controller.getEligibilityReport();
                                        controller.getTurnAroundTimeReport();
                                        controller.getRentPaymentReport();
                                    }
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              })
            ],
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget filterApprovalsTags(DashBoardController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        Map filter = ((controller.commonApprovalsFilters['approvals'] ?? {}));
        List keys = filter.keys.toList();
        if ('approvals' == 'common' || !const DeepCollectionEquality().equals(controller.commonApprovalsFilters['common'], controller.commonApprovalsFilters['approvals'])) {
          return Row(
            children: [
              ...List.generate(keys.length, (index) {
                if (keys[index] == 'todate' || keys[index] == 'fromdate') {
                  return const SizedBox();
                }
                if (keys[index] == 'filterduration') {
                  if (filter[keys[index]] == 1) {
                    return const SizedBox();
                  }
                  Map duration = IISMethods().encryptDecryptObj(controller.filterApprovalsDurationList.firstWhere((p0) => p0['value'] == filter[keys[index]]));
                  if (duration['value'] == 0) {
                    duration['label'] = '${filter['fromdate'].toString().toDateFormat()} - ${filter['todate'].toString().toDateFormat()}';
                  }
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(color: ColorTheme.kWarnColor.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          TextWidget(
                            text: duration['label'],
                            height: 1,
                            fontWeight: FontTheme.notoMedium,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          InkResponse(
                            onTap: () {
                              controller.commonApprovalsFilters['approvals'].remove('todate');
                              controller.commonApprovalsFilters['approvals'].remove('fromdate');
                              controller.commonApprovalsFilters['approvals'].remove('filterduration');
                              if ('approvals' == 'common') {
                                for (var key in controller.reportKeys) {
                                  controller.commonApprovalsFilters[key] = IISMethods().encryptDecryptObj(controller.commonApprovalsFilters['approvals']);
                                }
                              }
                              controller.commonApprovalsFilters.refresh();
                              ApprovalMasterController approvalMasterController = Get.find<ApprovalMasterController>();
                              approvalMasterController.pageName.value = "approvals";
                              controller.getApprovalsList(approvalsFilter: {'isexpirybased': 1});
                            },
                            child: const Icon(
                              Icons.close,
                              size: 14,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
                return Row(
                  children: [
                    ...List.generate(
                      ((filter[keys[index]] ?? []) as List).length,
                      (i) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(color: ColorTheme.kWarnColor.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                TextWidget(
                                  text: filter[keys[index]][i][keys[index]],
                                  height: 1,
                                  fontWeight: FontTheme.notoMedium,
                                ),
                                4.kW,
                                InkResponse(
                                  onTap: () async {
                                    ((filter[keys[index]] ?? []) as List).removeAt(i);
                                    if ('approvals' == 'common') {
                                      for (var key in controller.reportKeys) {
                                        controller.commonApprovalsFilters[key] = await IISMethods().encryptDecryptObj(controller.commonApprovalsFilters['approvals']);
                                      }
                                    }
                                    controller.commonApprovalsFilters.refresh();
                                    ApprovalMasterController approvalMasterController = Get.find<ApprovalMasterController>();
                                    approvalMasterController.pageName.value = "approvals";
                                    controller.getApprovalsList(approvalsFilter: {'isexpirybased': 1});
                                  },
                                  child: const Icon(Icons.close, size: 14),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              })
            ],
          );
        }
        return const SizedBox();
      }),
    );
  }

  tabHeaderWidget({required String title, required Widget filterTags, required Widget filterButton}) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (sizingInformation.isDesktop)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: TextWidget(
                    text: title,
                    color: ColorTheme.kBlack,
                    fontSize: 18,
                    fontWeight: FontTheme.notoMedium,
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8),
                    child: TextWidget(
                      text: title,
                      color: ColorTheme.kBlack,
                      fontSize: 22,
                      fontWeight: FontTheme.notoSemiBold,
                    ),
                  ),
                ),
              if (sizingInformation.isDesktop)
                Expanded(
                  child: filterTags,
                ),
              filterButton,
            ],
          ),
          if (!sizingInformation.isDesktop) filterTags,
        ],
      );
    });
  }

  double calculateInnerRadius(SizingInformation sizingInformation) {
    double screenWidth = MediaQuery.of(Get.context!).size.width > 1500 ? MediaQuery.of(Get.context!).size.width * 0.058 : MediaQuery.of(Get.context!).size.width * 0.07;
    return screenWidth;
  }

  double calculateRadius(SizingInformation sizingInformation) {
    double screenWidth = MediaQuery.of(Get.context!).size.width > 1500 ? MediaQuery.of(Get.context!).size.width * 0.082 : MediaQuery.of(Get.context!).size.width * 0.103;
    return screenWidth;
  }
}
