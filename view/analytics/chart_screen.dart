import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../components/customs/custom_date_range_picker.dart';
import '../../components/customs/custom_shimmer.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/customs/text_widget.dart';
import '../../config/config.dart';
import '../../controller/analytics/chart_controller.dart';
import '../../style/theme_const.dart';
import '../CommonWidgets/common_table.dart';
import '../no_data_found_screen.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key, this.pageName});

  final String? pageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.kScaffoldColor,
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          return GetBuilder(
            global: false,
            init: Get.put(ChartController()),
            builder: (ChartController controller) {
              return CommonHeaderFooter(
                title: "Charts",
                hasSearch: false,
                txtSearchController: controller.searchController,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: (sizingInformation.isMobile || sizingInformation.isTablet) ? MediaQuery.sizeOf(context).height / 2 : MediaQuery.sizeOf(context).height / 1.25,
                        decoration: BoxDecoration(
                          color: ColorTheme.kWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: ColorTheme.kBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Obx(() {
                          return CustomShimmer(
                            isLoading: controller.isProjectStatusLoading.value,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: controller.projectStatusData['charttitle'] ?? 'Cartesian Chart',
                                            color: ColorTheme.kBlack,
                                            fontSize: 18,
                                            fontWeight: FontTheme.notoMedium,
                                            textOverflow: TextOverflow.visible,
                                          ),
                                          TextWidget(
                                            text: controller.projectStatusString.value,
                                            color: ColorTheme.kHintTextColor,
                                            fontSize: 12,
                                            fontWeight: FontTheme.notoRegular,
                                          ),
                                        ],
                                      ),
                                    ),
                                    dateFilter(controller: controller, flag: 1),
                                  ],
                                ).paddingAll(24),
                                Expanded(
                                  child: Obx(() {
                                    return SfCartesianChart(
                                      plotAreaBorderWidth: 1,
                                      legend: const Legend(
                                        isVisible: true,
                                        position: LegendPosition.bottom,
                                      ),
                                      tooltipBehavior: TooltipBehavior(
                                        enable: true,
                                        elevation: 7,
                                        tooltipPosition: TooltipPosition.auto,
                                      ),
                                      primaryXAxis: CategoryAxis(
                                        isInversed: true,
                                        majorGridLines: const MajorGridLines(width: 0),
                                        labelPlacement: LabelPlacement.betweenTicks,
                                        labelAlignment: LabelAlignment.center,
                                        axisLabelFormatter: (axisLabelRenderArgs) {
                                          final double originalFontSize = axisLabelRenderArgs.textStyle.fontSize ?? 12;
                                          final double reducedFontSize = originalFontSize - 2;

                                          int maxCharactersPerLine = (sizingInformation.isMobile || sizingInformation.isTablet) ? 10 : 20;

                                          final String text = axisLabelRenderArgs.text;
                                          final List<String> words = text.split(' ');
                                          final List<String> lines = [];
                                          String currentLine = '';

                                          for (final word in words) {
                                            if ((currentLine.isEmpty ? 0 : currentLine.length + 1) + word.length <= maxCharactersPerLine) {
                                              currentLine += (currentLine.isEmpty ? '' : ' ') + word;
                                            } else {
                                              lines.add(currentLine);
                                              currentLine = word;
                                            }
                                          }

                                          if (currentLine.isNotEmpty) {
                                            lines.add(currentLine);
                                          }

                                          return ChartAxisLabel(
                                            lines.join('\n'),
                                            TextStyle(
                                              fontFamily: "notosans",
                                              fontWeight: FontTheme.notoMedium,
                                              fontSize: reducedFontSize,
                                            ),
                                          );
                                        },
                                      ),
                                      primaryYAxis: const NumericAxis(
                                        axisLine: AxisLine(width: 0),
                                        labelFormat: '{value}',
                                        majorTickLines: MajorTickLines(size: 0),
                                      ),
                                      series: [
                                        ...List.generate(((controller.projectStatusData['data'] ?? {})[0] ?? {}).keys.length - 1, (innerIndex) {
                                          final firstData = controller.projectStatusData['data'][0];
                                          final keys = firstData?.keys.toList() ?? [];
                                          final dataSource = controller.projectStatusData['data'] ?? {};
                                          final seriesName = keys.length > innerIndex + 1 ? keys[innerIndex + 1] : "";
                                          return StackedBarSeries(
                                            color: controller.seriesColors[innerIndex],
                                            dataSource: dataSource,
                                            xValueMapper: (sales, _) => sales[firstData?.keys.toList()[0]] ?? "",
                                            yValueMapper: (sales, _) => sales[keys[innerIndex + 1]] == 0 ? null : sales[keys[innerIndex + 1]] ?? 0,
                                            name: seriesName,
                                            dataLabelSettings: const DataLabelSettings(isVisible: true, labelAlignment: ChartDataLabelAlignment.middle),
                                          );
                                        }),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          );
                        }),
                      ).paddingSymmetric(vertical: 16),
                      Container(
                        height: (sizingInformation.isMobile || sizingInformation.isTablet) ? MediaQuery.sizeOf(context).height / 2 : MediaQuery.sizeOf(context).height / 1.25,
                        decoration: BoxDecoration(
                          color: ColorTheme.kWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: ColorTheme.kBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Obx(() {
                          return CustomShimmer(
                            isLoading: controller.isProjectDataLoading.value,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: controller.apiProjectData['charttitle'] ?? 'Bar Chart',
                                            color: ColorTheme.kBlack,
                                            fontSize: 18,
                                            fontWeight: FontTheme.notoMedium,
                                          ),
                                          TextWidget(
                                            text: controller.projectString.value,
                                            color: ColorTheme.kHintTextColor,
                                            fontSize: 12,
                                            fontWeight: FontTheme.notoRegular,
                                          ),
                                        ],
                                      ),
                                    ),
                                    dateFilter(controller: controller, flag: 2),
                                  ],
                                ).paddingAll(24),
                                Expanded(
                                  child: SfCartesianChart(
                                    tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                                    primaryXAxis: CategoryAxis(
                                      majorGridLines: const MajorGridLines(width: 0),
                                      axisLabelFormatter: (axisLabelRenderArgs) {
                                        final double originalFontSize = axisLabelRenderArgs.textStyle.fontSize ?? 12;
                                        final double reducedFontSize = originalFontSize - 2;

                                        int maxCharactersPerLine = (sizingInformation.isMobile || sizingInformation.isTablet) ? 10 : 20;

                                        final String text = axisLabelRenderArgs.text;
                                        final List<String> words = text.split(' ');
                                        final List<String> lines = [];
                                        String currentLine = '';

                                        for (final word in words) {
                                          if ((currentLine.isEmpty ? 0 : currentLine.length + 1) + word.length <= maxCharactersPerLine) {
                                            currentLine += (currentLine.isEmpty ? '' : ' ') + word;
                                          } else {
                                            lines.add(currentLine);
                                            currentLine = word;
                                          }
                                        }

                                        if (currentLine.isNotEmpty) {
                                          lines.add(currentLine);
                                        }

                                        return ChartAxisLabel(
                                          lines.join('\n'),
                                          TextStyle(
                                            fontFamily: "notosans",
                                            fontWeight: FontTheme.notoMedium,
                                            fontSize: reducedFontSize,
                                          ),
                                        );
                                      },
                                    ),
                                    primaryYAxis: const NumericAxis(
                                      majorGridLines: MajorGridLines(width: 0),
                                    ),
                                    series: [
                                      ColumnSeries<MapEntry<String, num>, String>(
                                        dataSource: controller.projectData.entries.toList(),
                                        xValueMapper: (entry, _) => entry.key,
                                        yValueMapper: (entry, _) => entry.value,
                                        color: ColorTheme.kGraphPurpleColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ).paddingSymmetric(vertical: 12),
                      Container(
                        height: (sizingInformation.isMobile || sizingInformation.isTablet) ? MediaQuery.sizeOf(context).height / 2 : MediaQuery.sizeOf(context).height / 1.25,
                        decoration: BoxDecoration(
                          color: ColorTheme.kWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: ColorTheme.kBorderColor,
                            width: 1,
                          ),
                        ),
                        child: Obx(
                          () {
                            return CustomShimmer(
                              isLoading: controller.isRentDataLoading.value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextWidget(
                                              text: controller.apiRentData['charttitle'] ?? 'Pie Chart',
                                              color: ColorTheme.kBlack,
                                              fontSize: 18,
                                              fontWeight: FontTheme.notoMedium,
                                            ),
                                            TextWidget(
                                              text: controller.rentDetailsString.value,
                                              color: ColorTheme.kHintTextColor,
                                              fontSize: 12,
                                              fontWeight: FontTheme.notoRegular,
                                            ),
                                          ],
                                        ),
                                      ),
                                      dateFilter(controller: controller, flag: 3),
                                    ],
                                  ).paddingAll(24),
                                  constrainedBoxWithPadding(
                                    width: FieldSize.k325,
                                    child: Obx(() {
                                      return DropDownSearchCustom(
                                        hintText: "Select Tenant Project",
                                        onChanged: (v) {
                                          controller.tenantprojectid.value = v?['value'];
                                          controller.rentDetails.value = v!;
                                          controller.fetchAllData(flag: 3);
                                        },
                                        initValue: controller.rentDetails,
                                        items: List<Map<String, dynamic>>.from(controller.rentDetailsList),
                                        dropValidator: (p0) {
                                          return null;
                                        },
                                      );
                                    }),
                                  ).paddingOnly(left: 12),
                                  controller.rentData.isEmpty
                                      ? const Expanded(
                                          child: Center(
                                            child: NoDataFoundScreen(),
                                          ),
                                        )
                                      : Expanded(
                                          child: Obx(() {
                                            return SfCircularChart(
                                              legend: const Legend(
                                                isVisible: true,
                                                alignment: ChartAlignment.center,
                                              ),
                                              series: <PieSeries<MapEntry<String, num>, String>>[
                                                PieSeries<MapEntry<String, num>, String>(
                                                  dataSource: controller.rentData.entries.toList(),
                                                  xValueMapper: (entry, _) => entry.key,
                                                  yValueMapper: (entry, _) => entry.value,
                                                  dataLabelMapper: (entry, _) => '${entry.key}: ${entry.value}',
                                                  startAngle: 0,
                                                  endAngle: 0,
                                                  enableTooltip: true,
                                                  dataLabelSettings: const DataLabelSettings(
                                                    isVisible: true,
                                                    labelPosition: ChartDataLabelPosition.outside,
                                                    labelIntersectAction: LabelIntersectAction.none,
                                                    textStyle: TextStyle(fontSize: 12),
                                                    labelAlignment: ChartDataLabelAlignment.middle,
                                                    overflowMode: OverflowMode.none,
                                                    angle: 0,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                      ).paddingSymmetric(vertical: 12),
                    ],
                  ).paddingSymmetric(horizontal: 24, vertical: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget dateFilter({required ChartController controller, required int flag}) {
    return Theme(
      data: Theme.of(Get.context!).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton(
        offset: const Offset(0, 40),
        constraints: const BoxConstraints(
          minWidth: 115,
        ),
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
            CommonDataTableWidget.menuOption(
              onTap: () {
                controller.fetchAllData(flag: flag);
              },
              btnName: 'All',
            ),
            CommonDataTableWidget.menuOption(
              onTap: () {
                controller.fetchTodayData(flag: flag);
              },
              btnName: 'Today',
            ),
            CommonDataTableWidget.menuOption(
              onTap: () {
                controller.fetchLast7DaysData(flag: flag);
              },
              btnName: 'Last 7 Days',
            ),
            CommonDataTableWidget.menuOption(
              onTap: () async {
                controller.fetchLastMonthData(flag: flag);
              },
              btnName: 'Last Month',
            ),
            CommonDataTableWidget.menuOption(
              onTap: () async {
                Get.dialog(CustomDateRangePicker(
                  onDateSelected: (startDate, endDate) {
                    if (flag == 1) {
                      controller.fetchProjectStatusData(startDate: startDate, endDate: endDate);
                      controller.projectStatusString.value = "${startDate.toDateFormat()} to ${endDate.toDateFormat()}";
                      controller.projectStatusFilterString.value = "Custom";
                    } else if (flag == 2) {
                      controller.fetchProjectData(startDate: startDate, endDate: endDate);
                      controller.projectString.value = "${startDate.toDateFormat()} to ${endDate.toDateFormat()}";
                      controller.projectFilterString.value = "Custom";
                    } else if (flag == 3) {
                      controller.fetchRentData(id: controller.tenantprojectid.value, startDate: startDate, endDate: endDate);
                      controller.rentDetailsString.value = "${startDate.toDateFormat()} to ${endDate.toDateFormat()}";
                      controller.rentDetailsFilterString.value = "Custom";
                    }
                  },
                ));
              },
              btnName: 'Custom',
            ),
          ];
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: ColorTheme.kGrey.withOpacity(0.1), borderRadius: BorderRadius.circular(5), border: Border.all(color: ColorTheme.kBlack, width: 0.5)),
              child: Row(
                children: [
                  TextWidget(
                    text: flag == 1
                        ? controller.projectStatusString.value.contains('to')
                            ? controller.projectStatusFilterString.value
                            : controller.projectStatusString.value
                        : flag == 2
                            ? controller.projectStatusString.value.contains('to')
                                ? controller.projectFilterString.value
                                : controller.projectString.value
                            : flag == 3
                                ? controller.projectStatusString.value.contains('to')
                                    ? controller.rentDetailsFilterString.value
                                    : controller.rentDetailsString.value
                                : null,
                  ).paddingOnly(top: 6, bottom: 6, left: 8),
                  const Icon(Icons.filter_list_alt, size: 18).paddingSymmetric(horizontal: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
