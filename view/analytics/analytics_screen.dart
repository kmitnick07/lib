import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/row_column_widget.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/controller/analytics/analytics_screen_controller.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../components/customs/drop_down_search_custom.dart';
import '../../config/config.dart';

class AnalyticsScreen extends GetView<AnalyticsScreenController> {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonHeaderFooter(
      title: 'Analytics',
      // actions: [
      //   Obx(() {
      //     return constrainedBoxWithPadding(
      //       width: 300,
      //       child: DropDownSearchCustom(
      //         // width: fieldWidth,
      //         focusNode: FocusNode(),
      //         canShiftFocus: false,
      //         items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
      //           'value': element['_id'],
      //           'label': element['name'],
      //         })),
      //         initValue: controller.tenantProject.value.isNotNullOrEmpty
      //             ? List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
      //           'value': element['_id'],
      //           'label': element['name'],
      //         })).firstWhere(
      //               (element) => element['value'] == controller.commonTenantProject.value,
      //           orElse: () {
      //             return {};
      //           },
      //         )
      //             : null,
      //
      //         hintText: "Select Tenant Project",
      //         isCleanable: false,
      //
      //         // initValue:
      //         isSearchable: true,
      //         onChanged: (v) async {
      //           controller.commonTenantProject.value = v?['value'];
      //           controller.consentTenantProject.value = v?['value'];
      //           controller.eligibilityTenantProject.value = v?['value'];
      //           controller.tatTenantProject.value = v?['value'];
      //           controller.statusCountProject.value = v?['value'];
      //           controller.rentPaymentTenantProject.value = v?['value'];
      //           await controller.getTenantProject();
      //           await controller.getHutmentStatusReport();
      //           await controller.getConsentReport();
      //           await controller.getEligibilityReport();
      //           await controller.getTurnAroundTimeReport();
      //           await controller.getRentPaymentReport();
      //         },
      //         dropValidator: (Map<String, dynamic>? v) {
      //           return null;
      //         },
      //       ),
      //     );
      //   }),
      // ],
      txtSearchController: TextEditingController(),
      child: ResponsiveBuilder(builder: (context, sizingInformation) {
        return Padding(
          padding: EdgeInsets.all(sizingInformation.isMobile ? 12 : 24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
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
                        RowColumnWidget(
                          grouptype: sizingInformation.isMobile ? GroupType.column : GroupType.row,
                          mainAxisSize: !sizingInformation.isMobile ? MainAxisSize.max : MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: TextWidget(
                                text: 'Hutment Status',
                                color: ColorTheme.kBlack,
                                fontSize: 18,
                                fontWeight: FontTheme.notoMedium,
                              ),
                            ),
                            Obx(() {
                              return constrainedBoxWithPadding(
                                width: 300,
                                child: DropDownSearchCustom(
                                  // width: fieldWidth,
                                  focusNode: FocusNode(),
                                  canShiftFocus: false,
                                  items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                        'value': element['_id'],
                                        'label': element['name'],
                                      })),
                                  initValue: controller.tenantProject.value.isNotNullOrEmpty
                                      ? List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                            'value': element['_id'],
                                            'label': element['name'],
                                          })).firstWhere(
                                          (element) => element['value'] == controller.statusCountProject.value,
                                          orElse: () {
                                            return {};
                                          },
                                        )
                                      : null,

                                  hintText: "Select Tenant Project",
                                  isCleanable: false,

                                  // initValue:
                                  isSearchable: true,
                                  onChanged: (v) async {
                                    controller.statusCountProject.value = v?['value'];
                                    devPrint(controller.statusCountProject.value);
                                    controller.getHutmentStatusReport();
                                  },
                                  dropValidator: (Map<String, dynamic>? v) {
                                    return null;
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Obx(() {
                            List<Color> colors = [
                              ColorTheme.kReportGreen,
                              ColorTheme.kReportOccurYellow,
                              ColorTheme.kReportDarkYellow,
                              ColorTheme.kReportSkyBlue,
                              ColorTheme.kReportLightGreen,
                              ColorTheme.kReportBlue,
                              ColorTheme.kReportYellow,
                            ];
                            List<String> svgList = [
                              AssetsString.kEligible,
                              AssetsString.kUnDecided,
                              AssetsString.kHome2,
                              AssetsString.kInEligible,
                            ];
                            return MasonryGridView.builder(
                              shrinkWrap: true,
                              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: sizingInformation.isMobile
                                      ? 1
                                      : sizingInformation.isTablet
                                          ? 4
                                          : 7),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              itemBuilder: (context, index) {
                                return CircleAvatar(
                                  radius: 75,
                                  backgroundColor: colors[index % colors.length].withOpacity(0.1),
                                  foregroundColor: ColorTheme.kBlack,
                                  child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        TextWidget(
                                          text: controller.statusCountReport[index]['total'] ?? '',
                                          fontSize: 30,
                                          fontWeight: FontTheme.notoMedium,
                                        ),
                                        TextWidget(
                                          text: controller.statusCountReport[index]['tenantstatus'] ?? '',
                                          fontSize: 16,
                                          fontWeight: FontTheme.notoMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.statusCountReport.length,
                            );
                          }),
                        )
                      ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Wrap(
                        children: [
                          Obx(() {
                            return constrainedBoxWithPadding(
                              width: 300,
                              child: DropDownSearchCustom(
                                // width: fieldWidth,
                                focusNode: FocusNode(),
                                canShiftFocus: false,
                                items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                      'value': element['_id'],
                                      'label': element['name'],
                                    })),
                                initValue: controller.tenantProject.value.isNotNullOrEmpty
                                    ? List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                          'value': element['_id'],
                                          'label': element['name'],
                                        })).firstWhere(
                                        (element) => element['value'] == controller.consentTenantProject.value,
                                        orElse: () {
                                          return {};
                                        },
                                      )
                                    : null,

                                hintText: "Select Tenant Project",
                                isCleanable: false,

                                // initValue:
                                isSearchable: true,
                                onChanged: (v) async {
                                  controller.consentTenantProject.value = v?['value'];
                                  controller.consentLocalityList.value = List<Map<String, dynamic>>.from(controller.tenantProject.firstWhere((element) => element['_id'] == controller.consentTenantProject.value)['locality'] ?? []);
                                  controller.consentSelectedLocality.value = '';
                                  controller.getConsentReport();
                                },
                                dropValidator: (Map<String, dynamic>? v) {
                                  return null;
                                },
                              ),
                            );
                          }),
                          Obx(() {
                            return constrainedBoxWithPadding(
                              width: 300,
                              child: DropDownSearchCustom(
                                // width: fieldWidth,
                                focusNode: FocusNode(),
                                canShiftFocus: false,
                                items: List<Map<String, dynamic>>.from(controller.consentLocalityList.map((element) => {
                                      'value': element['localityid'],
                                      'label': element['locality'],
                                    })),
                                initValue: controller.consentSelectedLocality.value.isNotNullOrEmpty
                                    ? List<Map<String, dynamic>>.from(controller.consentLocalityList.map((element) => {
                                          'value': element['localityid'],
                                          'label': element['locality'],
                                        })).firstWhere(
                                        (element) => element['value'] == controller.consentSelectedLocality.value,
                                        orElse: () {
                                          return {};
                                        },
                                      )
                                    : null,

                                hintText: "Select Locality",
                                isCleanable: true,
                                clickOnCleanBtn: () {
                                  controller.consentSelectedLocality.value = '';
                                  devPrint(controller.consentSelectedLocality.value);
                                  controller.getConsentReport();
                                },
                                // initValue:
                                isSearchable: true,
                                onChanged: (v) async {
                                  controller.consentSelectedLocality.value = v?['value'];
                                  devPrint(controller.consentSelectedLocality.value);
                                  controller.getConsentReport();
                                },
                                dropValidator: (Map<String, dynamic>? v) {
                                  return null;
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                      Obx(() {
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
                                  child: Builder(builder: (context) {
                                    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(controller.consentReport.values.toList()[index]);
                                    return SfCircularChart(
                                      annotations: [
                                        CircularChartAnnotation(
                                            height: '100%',
                                            width: '100%',
                                            widget: PhysicalModel(
                                              shape: BoxShape.circle,
                                              elevation: 0,
                                              color: ColorTheme.kWhite,
                                              child: Center(
                                                child: TextWidget(
                                                  text: controller.consentReport.keys.toList()[index],
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
                                                "tenantprojectid": controller.consentTenantProject.value,
                                                "reportof": controller.consentReport.keys.toList()[index],
                                                "status": pointIndex // 0. Pendings, 1. Received
                                                // "projectid": "660d31c0ea684f20148ccfa6"
                                              },
                                              endpoint: 'consenttabularreport',
                                              title: '${data[pointIndex]['label']} ${controller.consentReport.keys.toList()[index]}',
                                            );
                                          },
                                          dataSource: data,
                                          innerRadius: '100',
                                          radius: '150',
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
                                    );
                                  }),
                                ),
                              ),
                            );
                          },
                          itemCount: controller.consentReport.keys.length,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                // Container(
                //   decoration: BoxDecoration(
                //     color: ColorTheme.kWhite,
                //     borderRadius: BorderRadius.circular(6),
                //   ),
                //   child: Column(
                //     children: [
                //       RowColumnWidget(
                //         grouptype: sizingInformation.isMobile ? GroupType.column : GroupType.row,
                //         mainAxisSize: !sizingInformation.isMobile ? MainAxisSize.max : MainAxisSize.min,
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           const Padding(
                //             padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                //             child: TextWidget(
                //               text: 'Eligibility Status',
                //               color: ColorTheme.kBlack,
                //               fontSize: 18,
                //               fontWeight: FontTheme.notoMedium,
                //             ),
                //           ),
                //           Obx(() {
                //             return constrainedBoxWithPadding(
                //               width: 300,
                //               child: DropDownSearchCustom(
                //                 // width: fieldWidth,
                //                 focusNode: FocusNode(),
                //                 canShiftFocus: false,
                //                 items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                //                       'value': element['_id'],
                //                       'label': element['name'],
                //                     })),
                //                 initValue: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                //                       'value': element['_id'],
                //                       'label': element['name'],
                //                     })).firstWhere(
                //                   (element) => element['value'] == controller.eligibilityTenantProject.value,
                //                   orElse: () {
                //                     return {};
                //                   },
                //                 ),
                //
                //                 hintText: "Select Tenant Project",
                //                 isCleanable: false,
                //
                //                 // initValue:
                //                 isSearchable: true,
                //                 onChanged: (v) async {
                //                   controller.eligibilityTenantProject.value = v?['value'];
                //                   devPrint(controller.eligibilityTenantProject.value);
                //                   controller.getEligibilityReport();
                //                 },
                //                 dropValidator: (Map<String, dynamic>? v) {
                //                   return null;
                //                 },
                //               ),
                //             );
                //           }),
                //         ],
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.all(16.0),
                //         child: Obx(() {
                //           List<Color> colors = [
                //             ColorTheme.kReportLightGreen,
                //             ColorTheme.kReportBlue,
                //             ColorTheme.kReportYellow,
                //             ColorTheme.kReportViolet,
                //           ];
                //           List<String> svgList = [
                //             AssetsString.kEligible,
                //             AssetsString.kUnDecided,
                //             AssetsString.kHome2,
                //             AssetsString.kInEligible,
                //           ];
                //           return MasonryGridView.builder(
                //             shrinkWrap: true,
                //             gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                //                 crossAxisCount: sizingInformation.isMobile
                //                     ? 1
                //                     : sizingInformation.isTablet
                //                         ? 2
                //                         : 4),
                //             crossAxisSpacing: 16,
                //             mainAxisSpacing: 16,
                //             itemBuilder: (context, index) {
                //               return Container(
                //                 height: 100,
                //                 decoration: BoxDecoration(
                //                   color: colors[index % colors.length].withOpacity(0.1),
                //                   borderRadius: BorderRadius.circular(8),
                //                 ),
                //                 child: Row(
                //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //                   children: [
                //                     Column(
                //                       mainAxisSize: MainAxisSize.max,
                //                       crossAxisAlignment: CrossAxisAlignment.start,
                //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //                       children: [
                //                         TextWidget(
                //                           text: controller.eligibilityReport[index]['result'] ?? '',
                //                           fontSize: 30,
                //                           fontWeight: FontTheme.notoMedium,
                //                         ),
                //                         TextWidget(
                //                           text: controller.eligibilityReport[index]['eligibilityname'] ?? '',
                //                           fontSize: 16,
                //                           fontWeight: FontTheme.notoMedium,
                //                         ),
                //                       ],
                //                     ),
                //                     SvgPicture.asset(
                //                       svgList[index % svgList.length],
                //                       colorFilter: ColorFilter.mode(
                //                         colors[index % colors.length],
                //                         BlendMode.srcIn,
                //                       ),
                //                       height: 60,
                //                     )
                //                   ],
                //                 ),
                //               );
                //             },
                //             physics: const NeverScrollableScrollPhysics(),
                //             itemCount: controller.eligibilityReport.length,
                //           );
                //         }),
                //       )
                //     ],
                //   ),
                // ),
                // const SizedBox(
                //   height: 16,
                // ),
                Padding(
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
                        RowColumnWidget(
                          grouptype: sizingInformation.isMobile ? GroupType.column : GroupType.row,
                          mainAxisSize: !sizingInformation.isMobile ? MainAxisSize.max : MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                              child: TextWidget(
                                text: 'TAT (Turn Around Time) (Days)',
                                color: ColorTheme.kBlack,
                                fontSize: 18,
                                fontWeight: FontTheme.notoMedium,
                              ),
                            ),
                            Obx(() {
                              return constrainedBoxWithPadding(
                                width: 300,
                                child: DropDownSearchCustom(
                                  // width: fieldWidth,
                                  focusNode: FocusNode(),
                                  canShiftFocus: false,
                                  items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                        'value': element['_id'],
                                        'label': element['name'],
                                      })),
                                  initValue: controller.tenantProject.value.isNotNullOrEmpty
                                      ? List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                            'value': element['_id'],
                                            'label': element['name'],
                                          })).firstWhere(
                                          (element) => element['value'] == controller.tatTenantProject.value,
                                          orElse: () {
                                            return {};
                                          },
                                        )
                                      : null,

                                  hintText: "Select Tenant Project",
                                  isCleanable: false,

                                  // initValue:
                                  isSearchable: true,
                                  onChanged: (v) async {
                                    controller.tatTenantProject.value = v?['value'];
                                    devPrint(controller.tatTenantProject.value);
                                    controller.getTurnAroundTimeReport();
                                  },
                                  dropValidator: (Map<String, dynamic>? v) {
                                    return null;
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Obx(() {
                            List<Color> colors = [
                              ColorTheme.kReportGreen,
                              ColorTheme.kReportOccurYellow,
                              ColorTheme.kReportDarkYellow,
                              ColorTheme.kReportSkyBlue,
                              ColorTheme.kReportLightGreen,
                              ColorTheme.kReportBlue,
                              ColorTheme.kReportYellow,
                            ];
                            List<String> svgList = [
                              AssetsString.kEligible,
                              AssetsString.kUnDecided,
                              AssetsString.kHome2,
                              AssetsString.kInEligible,
                            ];
                            return MasonryGridView.builder(
                              shrinkWrap: true,
                              gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: sizingInformation.isMobile
                                      ? 1
                                      : sizingInformation.isTablet
                                          ? 2
                                          : 4),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              itemBuilder: (context, index) {
                                return Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextWidget(
                                            text: controller.tatReport[index]['TAT'] ?? '',
                                            fontSize: 30,
                                            fontWeight: FontTheme.notoMedium,
                                          ),
                                          TextWidget(
                                            text: controller.tatReport[index]['status'] ?? '',
                                            fontSize: 16,
                                            fontWeight: FontTheme.notoMedium,
                                          ),
                                        ],
                                      ),
                                      SvgPicture.network(
                                        controller.tatReport[index]['image'] ?? '',
                                        colorFilter: ColorFilter.mode(
                                          colors[index % colors.length],
                                          BlendMode.srcIn,
                                        ),
                                        height: 60,
                                      )
                                    ],
                                  ),
                                );
                              },
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.tatReport.length,
                            );
                          }),
                        )
                      ],
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
                                ? Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextWidget(
                                          text: 'Rent Payment Status',
                                          fontWeight: FontTheme.notoSemiBold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Obx(() {
                                        return constrainedBoxWithPadding(
                                          width: 400,
                                          child: DropDownSearchCustom(
                                            // width: fieldWidth,
                                            focusNode: FocusNode(),
                                            canShiftFocus: false,
                                            items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                                  'value': element['_id'],
                                                  'label': element['name'],
                                                })),
                                            initValue: controller.rentPaymentTenantProject.value.isNotNullOrEmpty
                                                ? List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                                      'value': element['_id'],
                                                      'label': element['name'],
                                                    })).firstWhere(
                                                    (element) => element['value'] == controller.rentPaymentTenantProject.value,
                                                    orElse: () {
                                                      return {};
                                                    },
                                                  )
                                                : null,
                                            hintText: "Select Tenant Project",
                                            isCleanable: false,

                                            // initValue:
                                            isSearchable: true,
                                            onChanged: (v) async {
                                              controller.rentPaymentTenantProject.value = v?['value'];
                                              devPrint(controller.rentPaymentTenantProject.value);
                                              controller.getRentPaymentReport();
                                            },
                                            dropValidator: (Map<String, dynamic>? v) {
                                              return null;
                                            },
                                          ),
                                        );
                                      }),
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
                                                      "tenantprojectid": controller.rentPaymentTenantProject.value
                                                      // "projectid": "660d31c0ea684f20148ccfa6"
                                                    },
                                                    endpoint: 'rentpaymentstatustabularreport',
                                                    title: '${data[pointIndex]['_id'].toString().capitalizeFirst} Rent Payment',
                                                  );
                                                },
                                                dataSource: data,
                                                radius: '150',
                                                // dataSource: (controller.commonConsentReport.values.last as Map?)
                                                //     ?.keys
                                                //     .map((e) => {
                                                //           'label': e,
                                                //           'value': controller.commonConsentReport[e],
                                                //         })
                                                //     .toList(),
                                                xValueMapper: (datum, index) {
                                                  devPrint(datum);
                                                  return datum['_id'].toString().capitalizeFirst;
                                                },
                                                dataLabelMapper: (datum, index) {
                                                  devPrint(datum);
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
                                  )
                                : Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextWidget(
                                          text: 'Eligibility Status',
                                          fontWeight: FontTheme.notoSemiBold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Obx(() {
                                        return constrainedBoxWithPadding(
                                          width: 300,
                                          child: DropDownSearchCustom(
                                            // width: fieldWidth,
                                            focusNode: FocusNode(),
                                            canShiftFocus: false,
                                            items: List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                                  'value': element['_id'],
                                                  'label': element['name'],
                                                })),
                                            initValue: controller.eligibilityTenantProject.value.isNotNullOrEmpty
                                                ? List<Map<String, dynamic>>.from(controller.tenantProject.map((element) => {
                                                      'value': element['_id'],
                                                      'label': element['name'],
                                                    })).firstWhere(
                                                    (element) => element['value'] == controller.eligibilityTenantProject.value,
                                                    orElse: () {
                                                      return {};
                                                    },
                                                  )
                                                : null,

                                            hintText: "Select Tenant Project",
                                            isCleanable: false,

                                            // initValue:
                                            isSearchable: true,
                                            onChanged: (v) async {
                                              controller.eligibilityTenantProject.value = v?['value'];
                                              devPrint(controller.eligibilityTenantProject.value);
                                              controller.getEligibilityReport();
                                            },
                                            dropValidator: (Map<String, dynamic>? v) {
                                              return null;
                                            },
                                          ),
                                        );
                                      }),
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
                                                      "tenantprojectid": controller.eligibilityTenantProject.value
                                                      // "projectid": "660d31c0ea684f20148ccfa6"
                                                    },
                                                    endpoint: 'eligibilitytabularreport',
                                                    title: '${data[pointIndex]['eligibilityname'].toString().capitalizeFirst}',
                                                  );
                                                },
                                                dataSource: data,
                                                radius: '150',
                                                xValueMapper: (datum, index) {
                                                  devPrint(datum);
                                                  return datum['eligibilityname'].toString().capitalizeFirst;
                                                },
                                                dataLabelMapper: (datum, index) {
                                                  devPrint(datum);
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
                      );
                    },
                    itemCount: 2,
                  ),
                ),
                const SizedBox(
                  height: 200,
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
