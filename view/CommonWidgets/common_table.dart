// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_checkbox.dart';
import 'package:prestige_prenew_frontend/components/customs/loader.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/hover_builder.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/helper/device_service.dart';
import 'package:prestige_prenew_frontend/models/Menu/menu_model.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/customs/custom_shimmer.dart';
import '../../components/customs/custom_text_form_field.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../components/customs/multi_drop_down_custom.dart';
import '../../components/prenew_logo.dart';
import '../../config/dev/dev_helper.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../config/uppercase_formatter.dart';
import '../../controller/layout_templete_controller.dart';
import '../../routes/route_name.dart';
import 'common_refresh_indicator.dart';

AutoScrollController paginationScrollController = AutoScrollController();

class CommonDataTableWidget extends StatelessWidget {
  final _deleteFormKey = GlobalKey<FormState>();
  final FormDataModel setDefaultData;
  double? width;
  final List<PopupMenuItem<dynamic>>? popupMenuItems;
  final String? pageName;
  final String? pageField;
  List<Map<String, dynamic>> fieldOrder = [];
  List data = [];
  Future<void> Function()? onRefresh;
  final Function(String id, int index)? editDataFun;
  final Function(String id, int index, String field, String type)? infoDataFun;
  final Function(String id, int index, String field, String type)? rentInfoDataFun;
  final Function(String id, int index, String field, String type, String listData)? rentDataFun;
  final Function(String id, int index)? deleteDataFun;
  final Function(int index)? deleteLocalDataFun;
  final Function(String id, int index)? deleteTableDocFun;
  final Function(String id, int index)? field5;
  final Function(String id, String type, Map<String, dynamic> documentMap)? onTapDocument;
  final String? field5title;
  final Function(String id, String? parentNameString, int index)? field4;
  final String? field4title;
  final Function(String id, String? parentNameString)? field3;
  final Function(String id, String? parentNameString)? inTableAddButton;
  final Function(String id)? inTableEyeButton;
  final String? field3title;
  final Function(String id)? field6;
  final String? field6title;
  final Function(String id)? field7;
  final String? field7title;
  final Function(int pageNo, int pageLimit)? onPageChange;
  final Function(String sortFieldName)? onSort;
  final Function(int index, String field, String type, dynamic value, dynamic masterfieldname, dynamic name)? handleGridChange;
  final Widget Function(
    int index,
    String field,
    BuildContext context,
  )? widgetBuilder;
  final Widget Function(int index)? infoPopUpWidget;
  final bool? hideInfo;
  final bool isLoading;
  final bool isPageLoading;
  final bool? containsRights;
  final bool? showPagination;
  final bool isTableEyeButtonVisible;
  final ScrollController? tableScrollController;
  ScrollController horizontalController = ScrollController();
  final ScrollPhysics? verticalScrollPhysics;

  CommonDataTableWidget({
    super.key,
    this.width,
    required this.setDefaultData,
    this.popupMenuItems,
    this.pageName,
    this.hideInfo,
    this.onTapDocument,
    required this.fieldOrder,
    this.editDataFun,
    this.deleteDataFun,
    required this.data,
    this.isLoading = false,
    this.isPageLoading = false,
    this.onPageChange,
    this.onRefresh,
    required this.tableScrollController,
    this.handleGridChange,
    this.field4,
    this.field3,
    this.inTableAddButton,
    this.containsRights,
    this.showPagination = true,
    this.onSort,
    this.field5,
    this.infoPopUpWidget,
    this.pageField,
    this.field4title,
    this.field3title,
    this.field5title,
    this.field6,
    this.field6title,
    this.inTableEyeButton,
    this.isTableEyeButtonVisible = false,
    this.field7,
    this.field7title,
    this.deleteLocalDataFun,
    this.widgetBuilder,
    this.infoDataFun,
    this.rentDataFun,
    this.verticalScrollPhysics,
    this.deleteTableDocFun,
    this.rentInfoDataFun,
  });

  @override
  Widget build(BuildContext context) {
    pageRights = IISMethods().getPageRights(alias: pageName ?? '') ?? UserRight();
    jsonPrint(pageRights.toJson(), tag: '---->$pageName');
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        width = width ?? (sizingInformation.isMobile ? MediaQuery.sizeOf(context).width : MediaQuery.sizeOf(context).width - globalTableWidth.value);
        return Align(
          alignment: Alignment.topRight,
          child: Builder(
            builder: (context) {
              double totalFlex = 0;
              double totalFix = 0;
              const double srNoWidth = 0;
              List<Map<String, dynamic>> field = fieldOrder.where((element) => element['active'] == 1.0).toList();

              for (var element in field) {
                if (element['disableflex'] == 1) {
                  totalFix += (element['tblsize'] ?? 20);
                } else {
                  totalFlex += (element['tblsize'] ?? 20);
                }
              }
              double ratio = 1;
              if (totalFlex * 10 < (width! - srNoWidth - totalFix)) {
                ratio = (width! - srNoWidth - totalFix) / (totalFlex * 10);
              }
              Map<int, TableColumnWidth> sizeMap = Map.from(
                // field.map((element) => FixedColumnWidth((element['tblsize'] ?? 20).toString().converttoInt * ((element['disableflex']).toString().converttoInt == 1 ? 1 : 10 * ratio))).toList().asMap(),
                field.map((element) => FixedColumnWidth(((element['tblsize'] ?? 20) * (element['disableflex'] == 1 ? 1 : 10 * ratio)).toDouble())).toList().asMap(),
              );
              List<TableColumnWidth> temp = [];
              sizeMap.forEach((key, value) {
                temp.add(value);
              });
              sizeMap = temp.asMap();

              if (/*isLoading == true &&*/ fieldOrder.isNullOrEmpty && data.isNullOrEmpty) {
                return Table(
                  columnWidths: sizeMap,
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: ColorTheme.kTableHeader),
                      children: [
                        ...List.generate(/*isLoading && */ field.isNullOrEmpty ? 6 : field.length, (index) {
                          return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child:
                                  // Dummy data when isLoading is true
                                  Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                height: 12,
                              ).paddingAll(8));
                        })
                      ],
                    ),
                    ...List.generate(
                        5,
                        (index) => TableRow(children: [
                              ...List.generate(
                                  6,
                                  (index) => CustomShimmer(
                                        isLoading: isLoading,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: ColorTheme.kBlack,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          height: 20,
                                        ),
                                      ).paddingAll(8))
                            ]))
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: RawScrollbar(
                      thumbColor: ColorTheme.kTableHeader.withOpacity(0.5),
                      radius: const Radius.circular(12),
                      interactive: true,
                      thumbVisibility: true,
                      scrollbarOrientation: ScrollbarOrientation.bottom,
                      controller: horizontalController,
                      child: SingleChildScrollView(
                        controller: horizontalController,
                        scrollDirection: Axis.horizontal,
                        child: ColoredBox(
                          color: ColorTheme.kWhite,
                          child: Visibility(
                            visible: isLoading == true || fieldOrder.isNotNullOrEmpty,
                            replacement: SizedBox(
                                width: width,
                                child: const NoDataFoundScreen(
                                  width: 200,
                                  height: 200,
                                )),
                            child: Column(
                              children: [
                                Container(
                                  color: ColorTheme.kTableHeader,
                                  // padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Table(
                                    columnWidths: sizeMap,
                                    children: [
                                      TableRow(
                                        decoration: const BoxDecoration(color: ColorTheme.kTableHeader),
                                        children: [
                                          ...List.generate(isLoading && field.isNullOrEmpty ? 5 : field.length, (index) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                              child: (isLoading && index >= field.length)
                                                  // Dummy data when isLoading is true
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      height: 12,
                                                    ).paddingAll(8)
                                                  : field[index]['type'] == 'checkbox'
                                                      ? Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            if (field[index]['canselectall'] == 1)
                                                              CustomCheckBox(
                                                                value: field[index]['selectall'] == 1,
                                                                onChanged: (value) {
                                                                  if (handleGridChange != null) {
                                                                    handleGridChange!(index, field[index]['field'], 'selectAllCheckbox', value, '', '');
                                                                  }
                                                                },
                                                              ),
                                                            const SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: TextWidget(
                                                                text: (field[index]['text'] ?? '').toUpperCase(),
                                                                fontSize: 14,
                                                                fontWeight: FontTheme.notoMedium,
                                                                color: ColorTheme.kBlack,
                                                                textOverflow: TextOverflow.visible,
                                                                maxLines: 2,
                                                                textAlign: TextAlign.left,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Visibility(
                                                          visible: (onSort != null) && (field[index]['sorttable'] == 1),
                                                          replacement: TextWidget(
                                                            text: (field[index]['text'] ?? '').toUpperCase(),
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            color: ColorTheme.kBlack,
                                                            textOverflow: TextOverflow.visible,
                                                            maxLines: 2,
                                                          ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (onSort != null) {
                                                                setDefaultData.pageNo.value = 1;
                                                                onSort!(field[index]['sortby']);
                                                              }
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  child: TextWidget(
                                                                    text: (field[index]['text'] ?? '').toUpperCase(),
                                                                    fontSize: 14,
                                                                    fontWeight: FontTheme.notoMedium,
                                                                    color: ColorTheme.kBlack,
                                                                    textOverflow: TextOverflow.visible,
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                                if (!setDefaultData.sortData.containsKey(field[index]['sortby'] ?? ''))
                                                                  SvgPicture.asset(AssetsString.kSortDisableSvg, height: 18)
                                                                else
                                                                  SvgPicture.asset(
                                                                    setDefaultData.sortData[field[index]['sortby'] ?? ''] == 1 ? AssetsString.kSortDscSvg : AssetsString.kSortAscSvg,
                                                                    height: 18,
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                            );
                                          })
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: commonRefreshIndicator(
                                    onRefresh: onRefresh,
                                    sizingInformation: sizingInformation,
                                    child: SingleChildScrollView(
                                      controller: tableScrollController,
                                      padding: EdgeInsets.only(bottom: sizingInformation.isMobile ? 100 : 0),
                                      physics: verticalScrollPhysics ?? const AlwaysScrollableScrollPhysics(),
                                      child: Builder(builder: (ctx) {
                                        return Column(
                                          children: [
                                            Visibility(
                                              visible: isLoading == true || data.isNotNullOrEmpty,
                                              replacement: SizedBox(width: width, height: 500, child: const Center(child: NoDataFoundScreen())),
                                              child: Table(
                                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                columnWidths: sizeMap,
                                                children: List.generate(
                                                  /*(data).length +*/
                                                  (isLoading ? 5 : (data).length), // Add dummy rows if isLoading is true
                                                  (index) => TableRow(
                                                    decoration: BoxDecoration(
                                                      color: index < data.length && data[index]['color'] != null
                                                          ? data[index]['color'].toString().toColor().withOpacity(0.4)
                                                          : index % 2 == 0
                                                              ? Colors.white
                                                              : ColorTheme.kBlack.withOpacity(0.03),
                                                      // border: Border(
                                                      //   bottom: BorderSide(
                                                      //     color: ColorTheme.kBorderColor,
                                                      //     width: 0.5,
                                                      //   ),
                                                      // ),
                                                    ),
                                                    children: [
                                                      ...List.generate(
                                                        field.length + (isLoading && data.isEmpty ? 5 : 0),
                                                        (i) {
                                                          if (isLoading) {
                                                            // Dummy data when isLoading is true
                                                            return CustomShimmer(
                                                              isLoading: isLoading,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: ColorTheme.kBlack,
                                                                  borderRadius: BorderRadius.circular(4),
                                                                ),
                                                                height: 20,
                                                              ),
                                                            ).paddingAll(8);
                                                          } else {
                                                            // if (i == 0) {
                                                            //   return TextWidget(
                                                            //     text: ((setDefaultData.pageNo - 1) * setDefaultData.pageLimit) + index + 1,
                                                            //     fontSize: 14,
                                                            //     color: ColorTheme.kBlack,
                                                            //   );
                                                            // }

                                                            Map<String, dynamic> obj = data[index];
                                                            Map<String, dynamic> innerObj = field[i];
                                                            return projectListTile(obj, innerObj, index).paddingAll(sizingInformation.isMobile ? 10 : 8);
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: isPageLoading,
                                              child: Table(
                                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                columnWidths: sizeMap,
                                                children: List.generate(
                                                  /*(data).length +*/
                                                  5, // Add dummy rows if isLoading is true
                                                  (index) => TableRow(
                                                    decoration: BoxDecoration(
                                                      color: index % 2 == 0 ? Colors.white : ColorTheme.kBlack.withOpacity(0.03),
                                                      // border: Border(
                                                      //   bottom: BorderSide(
                                                      //     color: ColorTheme.kBorderColor,
                                                      //     width: 0.5,
                                                      //   ),
                                                      // ),
                                                    ),
                                                    children: [
                                                      ...List.generate(
                                                        5,
                                                        (i) {
                                                          // Dummy data when isLoading is true
                                                          return CustomShimmer(
                                                            isLoading: isPageLoading,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                color: ColorTheme.kBlack,
                                                                borderRadius: BorderRadius.circular(4),
                                                              ),
                                                              height: 20,
                                                            ),
                                                          ).paddingAll(8);
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: !sizingInformation.isMobile && (showPagination ?? true),
                    child: SizedBox(
                      width: sizingInformation.isDesktop ? width : MediaQuery.sizeOf(context).width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: <Widget>[
                              Row(
                                children: [
                                  Theme(
                                    data: Theme.of(Get.context!).copyWith(
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                    child: PopupMenuButton(
                                      constraints: const BoxConstraints(
                                        minWidth: 135,
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
                                          ...List.generate(
                                            pageLimit.length,
                                            (index) => menuOption(
                                              btnName: (pageLimit[index]['label'] ?? "").toString(),
                                              onTap: () async {
                                                setDefaultData.pageNo.value = 1;
                                                onPageChange!(setDefaultData.pageNo.value, pageLimit[index]['value']!);
                                              },
                                            ),
                                          )
                                        ];
                                      },
                                      child: Row(
                                        children: [
                                          Visibility(
                                            visible: sizingInformation.isDesktop,
                                            child: Container(
                                              height: 38,
                                              clipBehavior: Clip.hardEdge,
                                              decoration: BoxDecoration(
                                                color: ColorTheme.kWhite,
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(6),
                                                  bottomLeft: Radius.circular(6),
                                                ),
                                                border: Border.all(
                                                  width: 1,
                                                  color: ColorTheme.kBorderColor,
                                                ),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: const Center(
                                                child: TextWidget(
                                                  text: 'Show',
                                                  fontWeight: FontTheme.notoSemiBold,
                                                  fontSize: 14,
                                                  color: ColorTheme.kPrimaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            clipBehavior: Clip.hardEdge,
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: ColorTheme.kWhite,
                                              borderRadius: sizingInformation.isDesktop
                                                  ? const BorderRadius.only(
                                                      topRight: Radius.circular(6),
                                                      bottomRight: Radius.circular(6),
                                                    )
                                                  : BorderRadius.circular(6),
                                              border: Border.all(
                                                width: 1,
                                                color: ColorTheme.kBorderColor,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: TextWidget(
                                                    text: setDefaultData.pageLimit,
                                                    fontWeight: FontTheme.notoSemiBold,
                                                    fontSize: 14,
                                                    color: ColorTheme.kPrimaryColor,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.keyboard_arrow_down_rounded,
                                                  color: ColorTheme.kPrimaryColor,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ).paddingOnly(right: 8),
                                  ),
                                  Visibility(
                                    visible: sizingInformation.isDesktop,
                                    child: Obx(() {
                                      return Visibility(
                                        visible: !isLoading,
                                        replacement: const SizedBox(
                                          width: 200,
                                          height: 25,
                                        ),
                                        child: TextWidget(
                                          text:
                                              'Showing ${setDefaultData.pageLimit * (setDefaultData.pageNo.value - 1) + (setDefaultData.data.isNotNullOrEmpty ? 1 : 0)} to ${(setDefaultData.pageLimit * (setDefaultData.pageNo.value - 1)) + setDefaultData.data.length} of ${setDefaultData.contentLength} entries',
                                          color: ColorTheme.kPrimaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Visibility(
                                visible: setDefaultData.noOfPages.value > 1,
                                child: Builder(builder: (context) {
                                  return Padding(
                                    padding: sizingInformation.isTablet ? const EdgeInsets.only(right: 90) : EdgeInsets.zero,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CustomButton(
                                            onTap: 1 != setDefaultData.pageNo.value
                                                ? () {
                                                    if (1 != setDefaultData.pageNo.value) {
                                                      onPageChange!(setDefaultData.pageNo.value - 1, setDefaultData.pageLimit);
                                                      paginationScrollController.scrollToIndex(setDefaultData.pageNo.value - 1, preferPosition: AutoScrollPosition.middle);
                                                    }
                                                  }
                                                : null,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 14,
                                            title: 'Previous',
                                            widget: sizingInformation.isDesktop
                                                ? TextWidget(
                                                    text: 'Previous',
                                                    color: 1 != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                                    fontSize: 14,
                                                    fontWeight: FontTheme.notoSemiBold,
                                                  )
                                                : const Icon(
                                                    Icons.arrow_back_ios_new_rounded,
                                                    color: ColorTheme.kBlack,
                                                  ),
                                            width: 20,
                                            buttonColor: ColorTheme.kBackGroundGrey,
                                            height: 38,
                                            borderRadius: 8,
                                            fontColor: 1 != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                          ),
                                        ),
                                        Container(
                                          height: 38,
                                          constraints: BoxConstraints(maxWidth: sizingInformation.isDesktop ? 300 : 180),
                                          child: ListView.separated(
                                            controller: paginationScrollController,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return AutoScrollTag(
                                                index: index,
                                                controller: paginationScrollController,
                                                key: ValueKey(index),
                                                child: Obx(() {
                                                  return InkWell(
                                                    onTap: () {
                                                      if (onPageChange != null) {
                                                        onPageChange!(index + 1, setDefaultData.pageLimit);
                                                        paginationScrollController.scrollToIndex(index, preferPosition: AutoScrollPosition.middle, duration: Durations.long1);
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 38,
                                                      height: 38,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        color: setDefaultData.pageNo.value == index + 1 ? ColorTheme.kPrimaryColor : ColorTheme.kBackGroundGrey,
                                                      ),
                                                      child: Center(
                                                        child: TextWidget(
                                                          text: index + 1,
                                                          fontSize: 14,
                                                          fontWeight: FontTheme.notoSemiBold,
                                                          color: setDefaultData.pageNo.value != index + 1 ? ColorTheme.kBlack : ColorTheme.kWhite,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              );
                                            },
                                            separatorBuilder: (context, index) => const SizedBox(
                                              width: 8,
                                            ),
                                            itemCount: setDefaultData.noOfPages.value,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CustomButton(
                                            onTap: setDefaultData.noOfPages.value != setDefaultData.pageNo.value
                                                ? () {
                                                    if (setDefaultData.noOfPages.value != setDefaultData.pageNo.value) {
                                                      onPageChange!(setDefaultData.pageNo.value + 1, setDefaultData.pageLimit);
                                                      paginationScrollController.scrollToIndex(setDefaultData.pageNo.value - 1, preferPosition: AutoScrollPosition.middle, duration: Durations.long1);
                                                    }
                                                  }
                                                : null,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 14,
                                            title: 'Next',
                                            width: 20,
                                            widget: sizingInformation.isDesktop
                                                ? TextWidget(
                                                    text: 'Next',
                                                    color: setDefaultData.noOfPages.value != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                                    fontSize: 14,
                                                    fontWeight: FontTheme.notoSemiBold,
                                                  )
                                                : const Icon(
                                                    Icons.arrow_forward_ios_rounded,
                                                    color: ColorTheme.kBlack,
                                                  ),
                                            buttonColor: ColorTheme.kBackGroundGrey,
                                            height: 38,
                                            borderRadius: 8,
                                            fontColor: setDefaultData.noOfPages.value != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                          ),
                                        ),
                                        // if (!sizingInformation.isDesktop)
                                        //   const SizedBox(
                                        //     width: 50,
                                        //   )
                                      ],
                                    ),
                                  );
                                }),
                              )
                            ],
                          ).paddingOnly(
                            left: 8,
                            right: 8,
                            top: 8,
                          ),
                          Visibility(
                            visible: !sizingInformation.isDesktop,
                            child: Obx(() {
                              return Visibility(
                                visible: !isLoading,
                                replacement: const SizedBox(
                                  width: 200,
                                  height: 25,
                                ),
                                child: TextWidget(
                                  text:
                                      'Showing ${setDefaultData.pageLimit * (setDefaultData.pageNo.value - 1) + (setDefaultData.data.isNotNullOrEmpty ? 1 : 0)} to ${(setDefaultData.pageLimit * (setDefaultData.pageNo.value - 1)) + setDefaultData.data.length} of ${setDefaultData.contentLength} entries',
                                  color: ColorTheme.kPrimaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            }),
                          ),
                        ],
                      ).paddingOnly(bottom: 24),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  UserRight pageRights = UserRight();

  Widget projectListTile(obj, innerObj, index) {
    FormDataModel setDefaultData1 = FormDataModel();
    setDefaultData1.fieldOrder = [
      {
        "field": "uploadeddate",
        "text": "Uploaded Date",
        "type": "text",
        "freeze": 1,
        "active": 1,
        // "sorttable": 1,
        "filter": 1,
        "filterfieldtype": "input-text",
        "defaultvalue": "",
        "tblsize": 10,
      },
      {
        "field": "uploadedby",
        "text": "Uploaded By",
        "type": "text",
        "freeze": 1,
        "active": 1,
        // "sorttable": 1,
        "filter": 1,
        "filterfieldtype": "input-text",
        "defaultvalue": "",
        "tblsize": 18,
      },
      {
        "field": "name",
        "text": "File Name",
        "type": "text",
        "freeze": 1,
        "active": 1,
        // "sorttable": 1,
        "filter": 1,
        "filterfieldtype": "input-text",
        "defaultvalue": "",
        "tblsize": 18,
      },
      {
        "field": "eye",
        "text": "Document",
        "type": "eye",
        "freeze": 1,
        "active": 1,
        // "sorttable": 1,
        "filter": 1,
        "filterfieldtype": "input-text",
        "defaultvalue": "",
        "tblsize": 8,
      },
    ].obs;
    switch (innerObj['type']) {
      case "icon":
        return SvgPicture.network((FilesDataModel.fromJson(obj[innerObj['field']])).url.toString(),
            alignment: Alignment.centerLeft,
            height: 25,
            colorFilter: const ColorFilter.mode(
              ColorTheme.kBlack,
              BlendMode.srcIn,
            ));
      case "action_status":
        bool isEditVisible = true;
        bool isDeleteVisible = true;
        isEditVisible = !(data[index]["isupdatable"] == 0) && (!(containsRights ?? true) || pageRights.alleditright == 1 || (pageRights.selfeditright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid)));
        isDeleteVisible = !(data[index]["isupdatable"] == 0) && (!(containsRights ?? true) || pageRights.alldelright == 1 || (pageRights.selfdelright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid)));
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Theme(
              data: Theme.of(Get.context!).copyWith(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton(
                // offset: const Offset(50, -4),
                constraints: const BoxConstraints(
                  minWidth: 90,
                  // maxWidth: 250,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                tooltip: '',
                surfaceTintColor: ColorTheme.kTableHeader,
                shadowColor: ColorTheme.kBlack,
                elevation: 6,
                popUpAnimationStyle: AnimationStyle(
                  curve: Curves.bounceInOut,
                ),
                position: PopupMenuPosition.under,
                padding: EdgeInsets.zero,
                color: ColorTheme.kWhite,
                itemBuilder: (context) {
                  return [
                    if (isEditVisible && editDataFun != null)
                      menuOption(
                          onTap: () async {
                            if (editDataFun != null) {
                              editDataFun!(obj['_id'], index);
                            }
                            // controller.setFormData(id: , editeDataIndex: );
                            // Get.dialog(const MasterForm(title: "Edit", btnName: "Update"));
                          },
                          btnName: 'Edit'),
                    if (isDeleteVisible && deleteDataFun != null)
                      menuOption(
                        onTap: () async {
                          TextEditingController deleteController = TextEditingController();
                          deleteDialog(deleteController, obj, index);
                        },
                        btnName: 'Delete',
                      ),

                    /// DIRECT DELETE (EASY AT DEVELOPMENT TIME TO DELETE ANY ITEM)
                    // menuOption(
                    //     onTap: () async {
                    //       if (deleteDataFun != null) {
                    //         deleteDataFun!(obj['_id']);
                    //       }
                    //     },
                    //     btnName: 'Developer Delete ',
                    //     boxColor: ColorTheme.kRedError),
                    if (field3 != null)
                      menuOption(
                          onTap: () {
                            if (field3 != null) {
                              field3!(obj['_id'], obj['name']);
                            }
                          },
                          btnName: field3title ?? ''),
                    if (field4 != null && field4title != null)
                      menuOption(
                        onTap: () {
                          if (field4 != null) {
                            field4!(obj['_id'], obj['name'], index);
                          }
                        },
                        btnName: field4title ?? '',
                      ),
                    if (field5 != null)
                      menuOption(
                        onTap: () {
                          if (field5 != null) {
                            field5!(obj['_id'], index);
                          }
                        },
                        btnName: field5title ?? '',
                      ),
                    if (isEditVisible && field6 != null)
                      menuOption(
                        onTap: () {
                          if (field6 != null) {
                            field6!(obj['_id']);
                          }
                        },
                        btnName: field6title ?? '',
                      ),
                    if (isEditVisible && field7 != null)
                      menuOption(
                        onTap: () {
                          if (field7 != null) {
                            field7!(obj['_id']);
                          }
                        },
                        btnName: field7title ?? '',
                      ),
                    if ((data[index].containsKey('recordinfo')))
                      menuOption(
                          onTap: () {
                            dataInfo(index: index);
                          },
                          btnName: 'Info')
                  ];
                },
                child: const Icon(
                  Icons.more_vert,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            InkResponse(
              onTap: isEditVisible
                  ? () {
                      if (handleGridChange != null) {
                        CustomDialogs().statusChangeDialog(
                            onTap: () async {
                              await handleGridChange!(index, innerObj['field'], 'status', obj[innerObj['field']] != 1, '', '');
                              Get.back();
                            },
                            value: obj[innerObj['field']]);
                      }
                    }
                  : null,
              child: Icon(
                Icons.circle,
                size: 10,
                color: obj[innerObj['field']] == 1 ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
              ),
            ),
          ],
        );
      case 'widget_builder':
        return Builder(
          builder: (context) {
            if (widgetBuilder != null) {
              return widgetBuilder!(
                index,
                innerObj['field'],
                context,
              );
            }
            return const SizedBox.shrink();
          },
        );
      case "name":
        return ((obj[innerObj['field']?["prefix"]]).toString().isNullOrEmpty && (obj[innerObj['field']?["name"]]).toString().isNullOrEmpty)
            ? const TextWidget(text: '-').paddingOnly(left: 8)
            : Wrap(
                children: [
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: ColorTheme.kNameTextBG),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if ((obj[innerObj['field']?["prefix"]]).toString().isNotNullOrEmpty)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorTheme.kHintColor),
                              borderRadius: BorderRadius.circular(24),
                              color: ColorTheme.kWhite.withOpacity(0.8),
                            ),
                            child: TextWidget(
                              text: obj[innerObj['field']["prefix"]].toString(),
                              fontSize: 10,
                              color: ColorTheme.kBlack,
                              fontWeight: FontWeight.w600,
                            ).paddingSymmetric(horizontal: 8, vertical: 4),
                          ).paddingAll(2),
                        if (obj[innerObj['field']?["name"]].toString().isNotNullOrEmpty)
                          Flexible(
                            child: TextWidget(
                              textOverflow: TextOverflow.visible,
                              text: obj[innerObj['field']["name"]].toString(),
                              fontSize: 10,
                              color: ColorTheme.kBlack,
                              fontWeight: FontWeight.w600,
                            ).paddingOnly(
                                left: (obj[innerObj['field']?["prefix"]]).toString().isNullOrEmpty ? 8 : 2,
                                right: 8,
                                top: (obj[innerObj['field']?["prefix"]]).toString().isNullOrEmpty ? 4 : 0,
                                bottom: (obj[innerObj['field']?["prefix"]]).toString().isNullOrEmpty ? 4 : 0),
                          ),
                      ],
                    ),
                  ),
                ],
              );
      case HtmlControls.kTextArray:
        return TextWidget(
          text: (obj[innerObj['field']] ?? [])
              .map((element) {
                if (element is String) {
                  return element;
                }
                return element[innerObj['field']];
              })
              .toList()
              .join(', ')
              .toString(),
          fontSize: 14,
          color: ColorTheme.kBlack,
        );
      case 'approve':
        if (obj[innerObj['field']] == 1) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.check,
              color: ColorTheme.kSuccessColor,
            ),
          );
        } else {
          return const SizedBox();
        }
      case "switch":
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 20,
            child: Transform.scale(
              scale: 0.8,
              alignment: Alignment.center,
              child: Switch(
                value: obj[innerObj['field']] == 1,
                onChanged: (value) {
                  if (handleGridChange != null) {
                    handleGridChange!(index, innerObj['field'], innerObj['type'], value, '', '');
                  }
                },
                focusColor: ColorTheme.kWhite,
                inactiveTrackColor: ColorTheme.kGrey.withOpacity(0.5),
                inactiveThumbColor: ColorTheme.kGrey,
                activeColor: ColorTheme.kGraphGreenColor,
                activeTrackColor: ColorTheme.kGraphGreenColor.withOpacity(0.5),
                splashRadius: 10,
                hoverColor: ColorTheme.kWhite,
              ),
            ),
          ),
        );
      case 'sap_status':
        return Row(
          children: [
            CustomButton(
              height: 35,
              buttonColor: Colors.transparent,
              borderWidth: 1,
              width: 20,
              title: obj[innerObj['field']] == 1 ? 'Paid' : 'Pending',
              fontColor: obj[innerObj['field']] == 1 ? ColorTheme.kSuccessColor : ColorTheme.kWarnColor,
              borderColor: obj[innerObj['field']] == 1 ? ColorTheme.kSuccessColor : ColorTheme.kWarnColor,
              showBoxBorder: true,
              borderRadius: 6,
            ),
          ],
        );
      case "status":
        return Row(
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: obj[innerObj['field']] == 1 ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
            ).paddingOnly(right: 12),

            /// because this type is used in contract dialog there is only display option enable not any other operations that's why below code is commented
            // Theme(
            //   data: Theme.of(Get.context!).copyWith(
            //     hoverColor: Colors.transparent,
            //     splashColor: Colors.transparent,
            //     highlightColor: Colors.transparent,
            //   ),
            //   child: PopupMenuButton(
            //     offset: const Offset(-30, 0),
            //     constraints: const BoxConstraints(
            //       minWidth: 135,
            //     ),
            //     enabled: innerObj['disable'] != 0,
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            //     tooltip: '',
            //     surfaceTintColor: ColorTheme.kWhite,
            //     shadowColor: ColorTheme.kBlack,
            //     elevation: 6,
            //     popUpAnimationStyle: AnimationStyle(
            //       curve: Curves.bounceInOut,
            //     ),
            //     position: PopupMenuPosition.over,
            //     padding: EdgeInsets.zero,
            //     color: ColorTheme.kWhite,
            //     itemBuilder: (context) {
            //       return [
            //         CommonDataTableWidget.demoMenuOption(
            //           selectedColor: obj[innerObj['field']] == 1 ? ColorTheme.kSuccessColor.withOpacity(0.2) : null,
            //           isSelected: obj[innerObj['field']] == 1,
            //           onTap: obj[innerObj['field']] == 1
            //               ? null
            //               : () async {
            //                   if (handleGridChange != null) {
            //                     handleGridChange!(index, innerObj['field'], innerObj['type'], true, '', '');
            //                   }
            //                 },
            //           btnName: 'Active',
            //           hoverColor: obj[innerObj['field']] == 1 ? ColorTheme.kSuccessColor.withOpacity(0.0) : ColorTheme.kTableHeader,
            //         ),
            //         CommonDataTableWidget.demoMenuOption(
            //           selectedColor: obj[innerObj['field']] == 0 ? ColorTheme.kErrorColor.withOpacity(0.2) : null,
            //           isSelected: obj[innerObj['field']] == 0,
            //           onTap: obj[innerObj['field']] == 0
            //               ? null
            //               : () async {
            //                   if (handleGridChange != null) {
            //                     handleGridChange!(index, innerObj['field'], innerObj['type'], false, '', '');
            //                   }
            //                 },
            //           btnName: 'In-Active',
            //           hoverColor: obj[innerObj['field']] == 0 ? ColorTheme.kErrorColor.withOpacity(0.0) : ColorTheme.kTableHeader,
            //         ),
            //       ];
            //     },
            //     child: Icon(
            //       Icons.circle,
            //       size: 10,
            //       color: obj[innerObj['field']] == 1 ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
            //     ).paddingOnly(right: 12),
            //   ),
            // ),
          ],
        );

      case HtmlControls.kDropStatus:
        bool isEditVisible = true;
        bool isDeleteVisible = true;
        RxInt myOwnIndex = 0.obs;
        isEditVisible = !(data[index]["isupdatable"] == 0) && (!(containsRights ?? true) || pageRights.alleditright == 1 || (pageRights.selfeditright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid)));
        isDeleteVisible = !(data[index]["isupdatable"] == 0) && (!(containsRights ?? true) || pageRights.alldelright == 1 || (pageRights.selfdelright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid)));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Theme(
              data: Theme.of(Get.context!).copyWith(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton(
                offset: const Offset(0, 28),
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
                      setDefaultData.masterDataList['constructionstage'].length,
                      (stageIndex) {
                        return CommonDataTableWidget.menuOption(
                          onTap: () async {
                            if (handleGridChange != null) {
                              await handleGridChange!(
                                index,
                                innerObj['updatefieldkey'],
                                HtmlControls.kDropStatus,
                                setDefaultData.masterDataList['constructionstage'][stageIndex]['_id'],
                                innerObj['updatefieldnamekey'],
                                setDefaultData.masterDataList['constructionstage'][stageIndex]['name'],
                              );
                            }
                            myOwnIndex.value = stageIndex;
                          },
                          btnName: setDefaultData.masterDataList['constructionstage'][stageIndex]['name'] ?? "",
                        );
                      },
                    )
                  ];
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: ColorTheme.kBackgroundColor,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Wrap(
                    children: [
                      TextWidget(text: data[index]['constructionstagename'] ?? "", fontSize: 12),
                      const SizedBox(width: 2),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case "textwithsubtitle":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: obj[innerObj['field']["text"]].toString().toDateFormat(),
              fontSize: 14,
              fontWeight: FontTheme.notoRegular,
              color: (innerObj['color'] ?? '000000').toString().toColor(),
            ),
            if (obj[innerObj['field']["subtitles"]] != null)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: obj[innerObj['field']["subtitles"]].length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: [
                      SizedBox(
                        height: 6,
                        width: 6,
                        child: CircleAvatar(
                          foregroundColor: (obj['subtitlescolor']).toString().isNotNullOrEmpty ? (obj['subtitlescolor'] ?? '000000').toString().toColor() : ColorTheme.kGrey,
                          backgroundColor: (obj['subtitlescolor']).toString().isNotNullOrEmpty ? (obj['subtitlescolor'] ?? '000000').toString().toColor() : ColorTheme.kGrey,
                        ),
                      ).paddingOnly(right: 4),
                      Expanded(
                        child: TextWidget(
                          text: '${obj[innerObj['field']["subtitles"]][index] ?? '-'}',
                          fontSize: 11,
                          fontWeight: FontTheme.notoRegular,
                          color: (obj['subtitlescolor']).toString().isNotNullOrEmpty ? (obj['subtitlescolor'] ?? '000000').toString().toColor() : ColorTheme.kGrey,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        );
      case "menu":
        bool isEditVisible = true;
        bool isDeleteVisible = true;
        isEditVisible = !(containsRights ?? false) || pageRights.alleditright == 1 || (pageRights.selfeditright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid));
        isDeleteVisible = !(containsRights ?? false) || pageRights.alldelright == 1 || (pageRights.selfdelright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid));

        return Theme(
          data: Theme.of(Get.context!).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton(
            // offset: const Offset(110, -12),
            constraints: const BoxConstraints(
              minWidth: 90,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            tooltip: '',
            surfaceTintColor: ColorTheme.kTableHeader,
            shadowColor: ColorTheme.kBlack,
            elevation: 6,
            popUpAnimationStyle: AnimationStyle(
              curve: Curves.bounceInOut,
            ),
            position: PopupMenuPosition.under,
            padding: EdgeInsets.zero,
            color: ColorTheme.kWhite,
            itemBuilder: (context) {
              return [
                if (isEditVisible && editDataFun != null)
                  menuOption(
                      onTap: () async {
                        if (editDataFun != null && obj['_id'] != null) {
                          editDataFun!(obj['_id'], index);
                        }
                      },
                      btnName: 'Edit'),
                if (isDeleteVisible && deleteDataFun != null)
                  menuOption(
                    onTap: () async {
                      TextEditingController deleteController = TextEditingController();
                      deleteDialog(deleteController, obj, index);
                    },
                    btnName: 'Delete',
                  ),
                if (field3 != null)
                  menuOption(
                      onTap: () {
                        if (field3 != null) {
                          field3!(obj['_id'], obj['name']);
                        }
                      },
                      btnName: field3title ?? ''),
                if (field4 != null && field4title != null)
                  menuOption(
                    onTap: () {
                      if (field4 != null) {
                        field4!(obj['_id'], obj['name'], index);
                      }
                    },
                    btnName: field4title ?? '',
                  ),
                if (pageField == 'tenantproject')
                  menuOption(
                      onTap: () {
                        if (field3 != null) {
                          field3!(obj['_id'], obj['name']);
                        }
                      },
                      btnName: field3title ?? 'Documents'),
                if (pageField == 'tenantproject')
                  menuOption(
                    onTap: () {
                      if (field4 != null) {
                        field4!(obj['_id'], obj['name'], index);
                      }
                    },
                    btnName: 'Community Engagement',
                  ),
                if (isDeleteVisible && field5 != null && pageField == 'tenantproject')
                  menuOption(
                    onTap: () {
                      if (field5 != null) {
                        field5!(obj['_id'], index);
                      }
                    },
                    btnName: 'User Assign',
                  ),
                if (!(hideInfo ?? false))
                  menuOption(
                      onTap: () {
                        dataInfo(index: index);
                      },
                      btnName: 'Info')
              ];
            },
            child: const Icon(
              Icons.more_vert,
            ),
          ),
        );

      case "sraweller":
        return Wrap(
          children: [
            InkWell(
              onTap: () {
                // showDocumentHistory(setDefaultData1, RxList<Map<String, dynamic>>.from(obj['sradwellerdocumenthistory'] ?? {}), "SRA Dweller Document History", () {});
              },
              child: Container(
                decoration: BoxDecoration(color: ColorTheme.kNameTextBG.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                child: Wrap(
                  children: [
                    SvgPicture.asset(
                      AssetsString.kFileCertificate,
                      colorFilter: const ColorFilter.mode(ColorTheme.kBlack, BlendMode.srcIn),
                    ).paddingAll(8),
                    TextWidget(
                      text: obj[innerObj['field']].toString(),
                      fontSize: 14,
                      color: ColorTheme.kBlack,
                    ).paddingOnly(top: 8, right: 8, bottom: 8)
                  ],
                ),
              ),
            ),
          ],
        );

      case "document":
        return Wrap(
          children: [
            CustomTooltip(
              message: (obj['documenttype']).toString().isNotNullOrEmpty
                  ? "${obj['documenttype']} History"
                  : (innerObj['text']).toString().isNotNullOrEmpty
                      ? "${innerObj['text']} History"
                      : "History",
              child: InkWell(
                onTap: onTapDocument != null
                    ? () {
                        onTapDocument!(obj["_id"] ?? "", obj['documenttype'] ?? "", obj['document'] ?? {});
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorTheme.kNameTextBG.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: const Icon(Icons.history_rounded),
                  ),
                ),
              ),
            ) /*.paddingOnly(right: 8)*/,

            // Other Documents
            // Visibility(
            //   visible: ('${innerObj['field'][1]}') == 'otherdocument',
            //   child: CustomTooltip(
            //     message: "Other Documents",
            //     child: InkWell(
            //       onTap: () {
            //         // showDocumentHistory(setDefaultData1, RxList<Map<String, dynamic>>.from(obj['${innerObj['field'][1]}history'] ?? {}), "Other Documents History", () {});
            //       },
            //       child: Container(
            //         decoration: BoxDecoration(
            //           color: ColorTheme.kNameTextBG.withOpacity(0.5),
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         child: Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: SvgPicture.asset(
            //             AssetsString.kFiles,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ).paddingOnly(right: 8),
            // ),
          ],
        );

      case "document_add":
        return Wrap(
          children: [
            CustomTooltip(
              message: obj[innerObj['field']['value']],
              child: InkWell(
                onTap: () {
                  devPrint('8794451254565464565445');
                  devPrint("obj['_id']: ${obj['_id']}\t fieldOrder: ${innerObj['text']}\t getCurrentPageName(): ${getCurrentPageName()}");
                  IISMethods().getDocumentHistory(tenantId: obj['_id'] ?? '', documentType: innerObj['text'] ?? '', pagename: getCurrentPageName());
                },
                child: Container(
                  decoration: BoxDecoration(color: ColorTheme.kNameTextBG.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                  child: SvgPicture.asset(
                    AssetsString.kFileCertificate,
                  ).paddingAll(8),
                ).paddingOnly(right: 8),
              ),
            ),
            CustomTooltip(
              message: "Upload New",
              child: InkResponse(
                onTap: () {
                  if (handleGridChange != null) {
                    handleGridChange!(index, innerObj['field']['field'], 'document_add', true, '', '');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: ColorTheme.kNameTextBG.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.upload_rounded).paddingAll(8),
                ).paddingOnly(right: 8),
              ),
            ),
          ],
        );

      case HtmlControls.kAvatarPicker:
        return Align(
          alignment: Alignment.centerLeft,
          child: CustomTooltip(
            message: (obj['recordinfo']).toString().isNotNullOrEmpty
                ? ((obj['recordinfo']?['updateby']).toString().isNotNullOrEmpty)
                    ? "${obj['recordinfo']?['updateby'] ?? ''}\n${(obj['recordinfo']?['updatedate']).toString().toDateFormat()}\n${(obj['recordinfo']?['updatedate']).toString().toTimeFormat()}"
                    : "${obj['recordinfo']?['entryby'] ?? ''}\n${(obj['recordinfo']?['entrydate']).toString().toDateFormat()}\n${(obj['recordinfo']?['entrydate']).toString().toTimeFormat()}"
                : null,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: ClipOval(
                child: (obj[innerObj['field']]).toString().isNullOrEmpty
                    ? SvgPicture.asset(AssetsString.kUser, height: 28)
                    : Visibility(
                        replacement: SvgPicture.asset(AssetsString.kUser, height: 28),
                        visible: (obj[innerObj['field']]?['url']).toString().isNotNullOrEmpty,
                        child: InkWell(
                          onTap: () {
                            documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(obj[innerObj['field']] ?? {})));
                          },
                          child: Image.network(
                            FilesDataModel.fromJson(obj[innerObj['field']]).url ?? "",
                            fit: BoxFit.cover,
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      case 'list':
        return Wrap(
          children: [
            ...List.generate(
                (obj[innerObj['field']['field']] ?? []).length,
                (index) => Padding(
                      padding: const EdgeInsets.only(right: 4, bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: ShapeDecoration(
                          color: ColorTheme.kBackGroundGrey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: TextWidget(
                          text: obj[innerObj['field']['field']][index][innerObj['field']['key']],
                          color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontTheme.notoSemiBold,
                          height: 1,
                        ).paddingOnly(top: 4),
                      ),
                    ))
          ],
        );
      case 'string-list':
        return ((obj[innerObj['field']] ?? []).length <= 0)
            ? const TextWidget(text: '-')
            : Wrap(
                children: [
                  ...List.generate(
                      (obj[innerObj['field']] ?? []).length,
                      (index) => Padding(
                            padding: const EdgeInsets.only(right: 4, bottom: 4),
                            child: Container(
                              // height: 24,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: ShapeDecoration(
                                color: ColorTheme.kBackGroundGrey,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                              child: TextWidget(
                                text: obj[innerObj['field']][index],
                                color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontTheme.notoSemiBold,
                                height: 1,
                              ).paddingOnly(top: 4),
                            ),
                          ))
                ],
              );

      case "buildingname":
        return Wrap(
          children: [
            Container(
              decoration: BoxDecoration(color: ColorTheme.kHintColor.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
              child: Wrap(
                children: [
                  ...List.generate(
                    obj[innerObj['field']].length,
                    (index) => Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorTheme.kHintColor),
                              borderRadius: BorderRadius.circular(24),
                              color: obj[innerObj['field']][index]['flag'] == 1 ? ColorTheme.kBlack : ColorTheme.kWhite,
                            ),
                            child: TextWidget(
                              text: obj[innerObj['field']][index]['lbl'] ?? "",
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: obj[innerObj['field']][index]['flag'] == 1 ? ColorTheme.kWhite : ColorTheme.kHintColor,
                            ).paddingSymmetric(horizontal: 8, vertical: 4))
                        .paddingAll(4),
                  ),
                ],
              ),
            ),
          ],
        );

      case "labels":
        return Wrap(
          children: [
            ...List.generate(
                obj[innerObj['field']].length,
                (index) => CustomTooltip(
                      message: obj[innerObj['field']][index]['message'] ?? "",
                      child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: ColorTheme.kBackGroundGrey),
                              child: TextWidget(
                                text: obj[innerObj['field']][index]['lbl'] ?? "",
                                fontSize: obj[innerObj['field']][index]['bgcolor'] != null ? 12 : 14,
                                fontWeight: FontWeight.w500,
                                color: (obj[innerObj['field']][index]['fontcolor'] ?? "000000").toString().toColor(),
                              ).paddingSymmetric(horizontal: 8, vertical: 2))
                          .paddingOnly(right: 8, top: 8, bottom: 8),
                    )),
          ],
        );
      case "nested-list":
        return Wrap(children: [
          Container(
            decoration: BoxDecoration(color: ColorTheme.kHintColor.withOpacity(0.2), borderRadius: BorderRadius.circular(24)),
            child: Wrap(
              children: [
                if ((obj[innerObj['field']?['child']]).toString().isNotNullOrEmpty)
                  Container(
                          decoration: BoxDecoration(border: Border.all(color: ColorTheme.kHintColor), borderRadius: BorderRadius.circular(24), color: ColorTheme.kBlack),
                          child: TextWidget(
                            text: obj[innerObj['field']['child']] ?? "",
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: ColorTheme.kWhite,
                          ).paddingSymmetric(horizontal: 8, vertical: 4))
                      .paddingAll(4),
                if (innerObj['field']?["parent"].length > 0)
                  ...List.generate(
                    innerObj['field']["parent"].length,
                    (index) => Container(
                            decoration: BoxDecoration(border: Border.all(color: ColorTheme.kHintColor), borderRadius: BorderRadius.circular(24), color: ColorTheme.kWhite),
                            child: TextWidget(
                              text: obj[innerObj['field']?["parent"]?[index]] ?? "",
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: ColorTheme.kBlack,
                            ).paddingSymmetric(horizontal: 8, vertical: 4))
                        .paddingOnly(right: 4, top: 4, bottom: 4, left: (obj[innerObj['field']?['child']]).toString().isNotNullOrEmpty ? 0 : 4),
                  ),
              ],
            ),
          ),
        ]);

      case "progress-status":
        return Wrap(
          children: [
            InkResponse(
              onTap: () {},
              child: CustomTooltip(
                message: "Total ${getCurrentPageName() == 'tenantproject' ? 'Tenants' : 'Units'}",
                child: Container(
                  child: TextWidget(
                    text: (obj[innerObj['field']["total"]] ?? "").toString(),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: "27437a".toColor(),
                  ).paddingSymmetric(horizontal: 8, vertical: 2),
                ).paddingOnly(right: 8, top: 8, bottom: 8),
              ),
            ),
            InkResponse(
              onTap: () {},
              child: CustomTooltip(
                message: "Handover",
                child: Container(
                        child: TextWidget(
                  text: (obj[innerObj['field']["completed"]] ?? "").toString(),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: "2bb150".toColor(),
                ).paddingSymmetric(horizontal: 8, vertical: 2))
                    .paddingOnly(right: 8, top: 8, bottom: 8),
              ),
            ),
            InkResponse(
              onTap: () {},
              child: CustomTooltip(
                message: "Pending",
                child: Container(
                        child: TextWidget(
                  text: (obj[innerObj['field']["pending"]] ?? "").toString(),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: "db8e3f".toColor(),
                ).paddingSymmetric(horizontal: 8, vertical: 2))
                    .paddingOnly(right: 8, top: 8, bottom: 8),
              ),
            )
          ],
        );

      // case "address":
      //   return Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       TextWidget(
      //         text: obj[innerObj['field']]['address'].toString(),
      //         fontSize: 14,
      //         color: ColorTheme.kBlack,height: 1,
      //       ),
      //       Visibility(
      //         visible: obj[innerObj['field']]['tags'].length > 0 /*|| !(obj[innerobj['field']]['tags']).isNotNullOrEmpty*/,
      //         child: Wrap(
      //           children: [
      //             ...List.generate(
      //               obj[innerObj['field']]['tags'].length,
      //               (index) => Container(
      //                       decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: (obj[innerObj['field']]['tags'][index]['bgcolor'] ?? "FFFFFF").toString().toColor()),
      //                       child: TextWidget(
      //                         text: obj[innerObj['field']]['tags'][index]['lbl'] ?? "",
      //                         fontSize: obj[innerObj['field']]['tags'][index]['bgcolor'] != null ? 10 : 12,
      //                         fontWeight: FontWeight.w500,
      //                         color: (obj[innerObj['field']]['tags'][index]['fontcolor'] ?? "000000").toString().toColor(),
      //                       ).paddingSymmetric(horizontal: 8, vertical: 4))
      //                   .paddingOnly(
      //                 right: 4,
      //                 top: 4,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   );

      case "unit":
        return TextWidget(
          text: (obj[innerObj['field']]).toString().isNullOrEmpty ? "-" : "${double.parse((obj[innerObj['field']]).toString())}  Sq. Ft.",
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: ColorTheme.kBlack,
        );
      case "measurewithunit":
        return TextWidget(
          text: (obj[innerObj['field']['value']]).toString().isNullOrEmpty ? "-" : "${double.parse((obj[innerObj['field']['value']]).toString())}  ${(obj[innerObj['field']['unit']] ?? "Sq. Ft.").toString()}",
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: ColorTheme.kBlack,
        );

      case "projectassign":
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if (inTableAddButton != null) {
                  inTableAddButton!(obj['_id'], obj['name']);
                }
              },
              splashColor: ColorTheme.kWhite,
              hoverColor: ColorTheme.kWhite.withOpacity(0.1),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: ColorTheme.kWhite.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kPrimaryColor)),
                child: const Center(child: Icon(Icons.add)),
              ),
            ),
            if (isTableEyeButtonVisible) ...[
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  if (inTableEyeButton != null) {
                    inTableEyeButton!(obj['_id']);
                  }
                },
                splashColor: ColorTheme.kWhite,
                hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: ColorTheme.kWhite.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kPrimaryColor)),
                  child: const Center(child: Icon(Icons.visibility_rounded, size: 16)),
                ),
              )
            ],
          ],
        );

      /// deleteLocalDataFun only works with locally add entries that's why there is no '_id' available so don't use when you have '_id' available
      case "delete":
        return Wrap(
          children: [
            if (deleteLocalDataFun != null)
              InkWell(
                onTap: () async {
                  await Get.dialog(CustomDialogs.alertDialog(
                      message: 'Are you sure, want to delete?',
                      onNo: () {
                        Get.back();
                      },
                      onYes: () async {
                        devPrint('4659654153241653215632');
                        devPrint("\n\n$index");
                        await deleteLocalDataFun!(index);
                        Get.back();
                      }));
                },
                splashColor: ColorTheme.kWhite,
                hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: ColorTheme.kWhite.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kCherryRed)),
                  child: const Center(child: Icon(Icons.delete_outline_rounded, color: ColorTheme.kCherryRed)),
                ),
              ),
          ],
        );

      case "delete-table-doc":
        return Wrap(
          children: [
            /// current document is doesn't delete so it will use here with static condition
            if (deleteDataFun != null && (obj?['candelete']).toString().isNullOrEmpty ? true : obj['candelete'] == 1)
              InkWell(
                onTap: () async {
                  TextEditingController deleteController = TextEditingController();
                  deleteDialog(deleteController, obj, index);
                },
                splashColor: ColorTheme.kWhite,
                hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: ColorTheme.kWhite.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: ColorTheme.kCherryRed)),
                  child: const Center(child: Icon(Icons.delete_outline_rounded, color: ColorTheme.kCherryRed)),
                ),
              ),
          ],
        );

      case "contact":
        return TextWidget(
          text: ((obj['field'] as List?)?.join(', ')).toString().toDateFormat(),
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: ColorTheme.kBlack,
        );

      case "eye":
        return (data[index]['url']).toString().isNullOrEmpty
            ? const SizedBox.shrink()
            : InkResponse(
                onTap: () {
                  Map<String, dynamic> obj = data[index];
                  documentDownload(imageList: FilesDataModel.fromJson(obj));
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.remove_red_eye_rounded,
                    size: 20,
                  ),
                ),
              );

      /// modal-eye ---> use for map the file from data with the help of fieldOrder var name
      case "modal-eye":
        String field = fieldOrder.firstWhere((element) => element['type'] == 'modal-eye')['field'] ?? '';
        return (data[index]?[field]?['url']).toString().isNullOrEmpty
            ? const SizedBox.shrink()
            : InkResponse(
                onTap: () {
                  Map<String, dynamic> obj = data[index]?[field];
                  documentDownload(imageList: FilesDataModel.fromJson(obj));
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.remove_red_eye_rounded,
                    size: 20,
                  ),
                ),
              );

      case "open":
        return InkResponse(
          onTap: () {
            if (handleGridChange != null) {
              handleGridChange!(index, 'open', 'open', true, '', '');
            }
          },
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.remove_red_eye_rounded,
              size: 20,
            ),
          ),
        );

      case "clear":
        return InkResponse(
          onTap: () {
            devPrint("object");
            if (editDataFun != null) {
              editDataFun!(obj['userroleid'], index);
            }
          },
          child: const Icon(
            Icons.clear,
            size: 20,
            color: ColorTheme.kBlack,
          ),
        );
      case "sap_submission_status":
        int sapStatus = 1; //Pending

        try {
          List success = innerObj['field']['success'] ?? [];
          List inprogress = innerObj['field']['in_progress'] ?? [];

          if (success.contains(obj['SAP_vendor_status'])) {
            sapStatus = 3; //For Success
          } else if (inprogress.contains(obj['SAP_vendor_status'])) {
            sapStatus = 2; //For In-progress
          }
        } catch (e) {
          devPrint("object");
        }

        return Center(
          child: Row(
            children: [
              const Spacer(),
              CustomTooltip(
                message: 'SAP Status: ${sapStatus == 3 ? 'Success' : sapStatus == 2 ? 'In-Progress' : 'Pending'}',
                child: InkResponse(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ColorTheme.kBackgroundColor,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      sapStatus == 3
                          ? Icons.check_circle_outline_rounded
                          : sapStatus == 2
                              ? Icons.hourglass_bottom_rounded
                              : CupertinoIcons.clock,
                      size: 20,
                      color: sapStatus == 3
                          ? ColorTheme.kSuccessColor
                          : sapStatus == 2
                              ? ColorTheme.kWarnColor
                              : null,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        );

      case "checkbox":
        return CustomCheckBox(
          value: obj[innerObj['field']] == 1,
          onChanged: (value) {
            if (handleGridChange != null) {
              handleGridChange!(index, innerObj['field'], 'checkbox', value, '', '');
            }
          },
        );

      case "address":
        return (((obj[innerObj['field']?["titlename"]]).toString().isNullOrEmpty) &&
                ((obj[innerObj['field']['address']] ?? "").toString().isNullOrEmpty) &&
                ((obj[innerObj['field']['area']] ?? "").toString().isNullOrEmpty) &&
                ((obj[innerObj['field']['pincode']] ?? "").toString().isNullOrEmpty) &&
                ((obj[innerObj['field']['city']] ?? "").toString().isNullOrEmpty))
            ? const TextWidget(text: "-")
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((obj[innerObj['field']?["titlename"]]).toString().isNotNullOrEmpty)
                    TextWidget(
                      text: (obj[innerObj['field']["titlename"]] ?? "").toString(),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ColorTheme.kBlack,
                    ).paddingOnly(bottom: 4),
                  if ((obj[innerObj['field']['address']] ?? "").toString().isNotNullOrEmpty)
                    TextWidget(
                      text: (obj[innerObj['field']['address']] ?? "").toString(),
                      fontSize: 14,
                      color: ColorTheme.kBlack,
                    ).paddingOnly(bottom: 5),
                  Wrap(
                    children: [
                      if ((obj[innerObj['field']['area']] ?? "").toString().isNotNullOrEmpty)
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: "FF6e6d6f".toColor()),
                          child: TextWidget(
                            text: (obj[innerObj['field']['area']] ?? "").toString(),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: "FFFFFFFF".toColor(),
                          ).paddingSymmetric(horizontal: 8, vertical: 4),
                        ).paddingOnly(
                          right: 8,
                        ),
                      if ((obj[innerObj['field']['pincode']] ?? "").toString().isNotNullOrEmpty)
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: "FF808080".toColor()),
                          child: TextWidget(
                            text: (obj[innerObj['field']['pincode']] ?? "").toString(),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: "FFFFFFFF".toColor(),
                          ).paddingSymmetric(horizontal: 8, vertical: 4),
                        ).paddingOnly(
                          right: 8,
                        ),
                      if ((obj[innerObj['field']['city']] ?? "").toString().isNotNullOrEmpty)
                        Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: "e8e8e8".toColor()),
                                child: TextWidget(
                                  text: (obj[innerObj['field']['city']] ?? "").toString(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: "FF6e6d6f".toColor(),
                                ).paddingSymmetric(horizontal: 8, vertical: 4))
                            .paddingOnly(
                          right: 8,
                        ),
                    ],
                  ),
                ],
              );
      case HtmlControls.kPrimaryField:
        return TextWidget(
          text: obj[innerObj['field']].toString().isNotNullOrEmpty ? obj[innerObj['field']].toString().toDateFormat() : 'INVALID',
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: obj[innerObj['field']].toString().isNotNullOrEmpty ? ColorTheme.kBlack : ColorTheme.kErrorColor,
        );
      case "modal-text":
        return InkWell(
          onTap: () {
            if (infoDataFun != null) {
              infoDataFun!(obj['_id'], index, innerObj['field'], innerObj['type']);
            }
          },
          child: Wrap(
            children: [
              TextWidget(
                text: obj[innerObj['field']].toString().toDateFormat(),
                fontSize: 14,
                fontWeight: FontTheme.notoRegular,
                textOverflow: TextOverflow.visible,
              ).paddingOnly(right: 4),
              const Icon(Icons.info_outline_rounded, size: 18).paddingOnly(top: 2)
            ],
          ),
        );

      case "yes-no":
        return TextWidget(
          text: obj[innerObj['field']] == 0 ? 'No' : 'Yes',
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: (innerObj['color'] ?? '000000').toString().toColor(),
        );

      case "rent-details":
        return InkWell(
          onTap: () {
            if (rentDataFun != null) {
              rentDataFun!(obj['_id'], index, innerObj['field']?['sum'], innerObj['type'], innerObj['field']?['list']);
            }
          },
          child: Wrap(
            children: [
              TextWidget(
                text: obj[innerObj['field']].toString().toDateFormat(),
                fontSize: 14,
                fontWeight: FontTheme.notoRegular,
                textOverflow: TextOverflow.visible,
              ).paddingOnly(right: 4),
              const Icon(Icons.info_outline_rounded, size: 18).paddingOnly(top: 2)
            ],
          ),
        );

      case "rent-info-details":
        return InkWell(
          /// buttonshow IS USED FOR WHEN WE HIDE "i" BUTTON FROM BACKEND
          onTap: (rentInfoDataFun != null && (obj[innerObj['buttonshow']]).toString().isNullOrEmpty ? false : (obj[innerObj['buttonshow']] == 1))
              ? () {
                  rentInfoDataFun!(obj['_id'], index, innerObj['field'], innerObj['type']);
                }
              : null,
          child: Wrap(
            children: [
              TextWidget(
                text: (obj[innerObj['field']] ?? '').toString().toAmount(),
                fontSize: 14,
                fontWeight: FontTheme.notoRegular,
                textOverflow: TextOverflow.visible,
              ).paddingOnly(right: 4),
              if ((rentInfoDataFun != null) && (obj[innerObj['buttonshow']]).toString().isNullOrEmpty ? false : (obj[innerObj['buttonshow']] == 1)) const Icon(Icons.info_outline_rounded, size: 18).paddingOnly(top: 2)
            ],
          ),
        );

      case 'time':
        return TextWidget(
          text: obj[innerObj['field']].toString().toDateTimeFormat(),
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: (innerObj['color'] ?? '000000').toString().toColor(),
        );
      case HtmlControls.kMultiSelectDropDown:
        return constrainedBoxWithPadding(
          // width: res['gridsize'].toString().converttoInt,
          child: MultiDropDownSearchCustom(
            selectedItems: List<Map<String, dynamic>>.from(
              obj[innerObj['field']] ?? [],
            ),
            field: innerObj["field"] ?? '',
            // focusNode: controller.focusNodes[focusOrderCode],
            dropValidator: (p0) {
              return null;
            },
            items: List<Map<String, dynamic>>.from(setDefaultData.masterData[innerObj['masterdata']] ?? []),
            // initValue: ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? "").toString().isNotNullOrEmpty
            //     ? null
            //     : (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]?.last,
            // isRequire: res["required"],
            // textFieldLabel: res["text"],
            hintText: "Select ${innerObj["text"]}",
            isCleanable: false,
            // isSearchable: res["searchable"],
            onChanged: (v) async {
              devPrint(v);
              if (handleGridChange != null) {
                handleGridChange!(index, innerObj["field"], HtmlControls.kMultiSelectDropDown, v, '', '');
              }
              // isMasterForm
              //     ? await controller.handleMasterFormData(
              //         key: res["field"],
              //         value: v,
              //         type: res["type"],
              //       )
              //     : await controller.handleFormData(
              //         key: res["field"],
              //         value: v,
              //         type: res["type"],
              //       );
              // devPrint(controller.setDefaultData.formData[res["field"]]);
            },
            // initValue: controller.setDefaultData[widget.formKey][res["field"]].join(","),
            // onChanged: (v) async {
            //   print(v);
            //   await widget.handleFormData(
            //     key: res["field"],
            //     value: v,
            //     type: res["type"],
            //   );
            //   await Future.delayed(
            //       const Duration(milliseconds: 500));
            //   setState(() {});
            // },
          ),
        );

      default:
        return TextWidget(
          text: obj[innerObj['field']].toString().toDateFormat(),
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: (innerObj['color'] ?? '000000').toString().toColor(),
        );
    }
  }

  static PopupMenuItem<dynamic> menuOption({
    required void Function()? onTap,
    required String btnName,
    String? svgImageUrl,
    Color? selectedColor,
    Color? boxColor,
    Color? btnTextColor = ColorTheme.kBlack,
    bool? customSelection = false,
  }) {
    return PopupMenuItem(
      height: 32,
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: HoverBuilder(builder: (bool isHovered) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: selectedColor,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: customSelection!
                  ? null
                  : isHovered
                      ? boxColor ?? ColorTheme.kTableHeader
                      : null,
            ),
            child: Row(
              children: [
                if (svgImageUrl.toString().isNotNullOrEmpty) SvgPicture.network(svgImageUrl!).paddingOnly(left: 10),
                TextWidget(
                  text: btnName,
                  color: btnTextColor,
                  fontSize: 14,
                  fontWeight: FontTheme.notoMedium,
                ).paddingOnly(left: svgImageUrl.toString().isNotNullOrEmpty ? 10 : 12),
              ],
            ),
          ),
        );
      }),
    );
  }

  static PopupMenuItem<dynamic> demoMenuOption({
    required void Function()? onTap,
    required String btnName,
    Color? selectedColor,
    required Color hoverColor,
    bool? customSelection = false,
    bool? isSelected = false,
  }) {
    return PopupMenuItem(
      height: 34,
      onTap: isSelected! ? null : onTap,
      padding: EdgeInsets.zero,
      child: MouseRegion(
        cursor: isSelected ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: HoverBuilder(builder: (bool isHovered) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: selectedColor,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              alignment: Alignment.centerLeft,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: customSelection! ? null : (isHovered ? hoverColor : null),
              ),
              child: TextWidget(text: btnName).paddingOnly(left: 12),
            ),
          );
        }),
      ),
    );
  }

  static showDocumentHistory(RxList<Map<String, dynamic>> data, List<Map<String, dynamic>> fieldOrder, String pagename, dynamic Function()? onTapAddNewDoc) {
    CustomDialogs().customPopDialog(child: ResponsiveBuilder(
      builder: (context, sizingInformation) {
        RxInt statusCode = 0.obs;
        RxString message = ''.obs;
        return SizedBox(
          width: 800,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: sizingInformation.isMobile ? 12 : 24, right: sizingInformation.isMobile ? 12 : 24, bottom: 12, top: sizingInformation.isMobile ? 12 : 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextWidget(
                      text: pagename,
                      fontWeight: FontWeight.w500,
                      color: ColorTheme.kPrimaryColor,
                      fontSize: 18,
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(color: ColorTheme.kBlack.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        splashColor: ColorTheme.kWhite,
                        hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                        splashRadius: 20,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.close),
                      ).paddingAll(2),
                    ),
                  ],
                ),
              ),
              Divider(height: sizingInformation.isMobile ? 0 : null),
              if (data.isNullOrEmpty)
                const NoDataFoundScreen()
              else
                Expanded(
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    margin: sizingInformation.isMobile ? null : const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12),
                    decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Obx(() {
                            return CommonDataTableWidget(
                              width: 750,
                              setDefaultData: FormDataModel(),
                              tableScrollController: null,
                              fieldOrder: fieldOrder,
                              data: data.value,
                              showPagination: false,
                              deleteDataFun: (id, index) async {
                                String url = '${Config.weburl}documenthistory/delete';
                                String userAction = "deletedocument${getCurrentPageName()}";
                                Map<String, dynamic> reqData = {'_id': id};
                                var resBody = await IISMethods().deleteData(url: url, reqBody: reqData, userAction: userAction, pageName: getCurrentPageName());
                                statusCode.value = resBody["status"];
                                if (resBody["status"] == 200) {
                                  message.value = resBody['message'];
                                  data.removeWhere((element) => element["_id"] == reqData['_id']);
                                  Get.back();
                                  showSuccess(message.value);
                                } else {
                                  message.value = resBody['message'];
                                  Get.back();
                                  showError(message.value);
                                }
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ));
  }

  deleteDialog(TextEditingController deleteController, obj, index) {
    if (!kIsWeb) {
      CustomDialogs().customDialog(
        buttonCount: 2,
        content: "Are you Sure! You want to Delete the data.",
        onTapPositive: () async {
          AppLoader();
          if (deleteDataFun != null) {
            await deleteDataFun!(obj['_id'], index);
          }
          RemoveAppLoader();
        },
      );
    } else {
      Get.dialog(Dialog(
        surfaceTintColor: ColorTheme.kWhite,
        backgroundColor: ColorTheme.kWhite,
        alignment: Alignment.topCenter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ResponsiveBuilder(builder: (context, sizeInformation) {
          return Container(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 450),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    splashColor: ColorTheme.kPrimaryColor,
                    hoverColor: ColorTheme.kPrimaryColor.withOpacity(0.1),
                    splashRadius: 20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close),
                  ),
                ),
                const TextWidget(
                  text: "Are You Sure!",
                  fontSize: 25,
                  color: ColorTheme.kBlack,
                  fontWeight: FontTheme.notoBold,
                ).paddingOnly(bottom: 20),
                Visibility(
                  visible: !sizeInformation.isMobile,
                  child: Form(
                    key: _deleteFormKey,
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PrenewLogo(
                            size: 120,
                          ).paddingOnly(right: 7),
                          const VerticalDivider().paddingOnly(right: 7),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Type ",
                                        style: TextStyle(
                                          color: ColorTheme.kTextColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "\"DELETE\"",
                                        style: TextStyle(color: ColorTheme.kBlack, fontSize: 15, fontWeight: FontTheme.notoSemiBold),
                                      ),
                                      TextSpan(
                                        text: " to delete the data.",
                                        style: TextStyle(
                                          color: ColorTheme.kTextColor,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).paddingOnly(bottom: 15),
                                CustomTextFormField(
                                  controller: deleteController,
                                  isCopyPasteEnable: false,
                                  textCapitalization: TextCapitalization.sentences,
                                  autofocus: true,
                                  inputFormatters: [
                                    UpperCaseFormatter(),
                                  ],
                                  contentPadding: const EdgeInsets.all(12),
                                  onFieldSubmitted: (v) async {
                                    if (_deleteFormKey.currentState!.validate() && deleteDataFun != null) {
                                      deleteDataFun!(obj['_id'], index);
                                    }
                                  },
                                  validator: (v) {
                                    if (v.toString().isEmpty) {
                                      return "Please Type DELETE.";
                                    } else if (v.toString().toUpperCase() != "DELETE") {
                                      return "Please Type only DELETE.";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).paddingOnly(bottom: 20),
                ),
                Visibility(
                  visible: sizeInformation.isMobile,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Are you Sure! You want to ",
                            style: TextStyle(
                              color: ColorTheme.kTextColor,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: "\"DELETE\"",
                            style: TextStyle(color: ColorTheme.kBlack, fontSize: 15, fontWeight: FontTheme.notoSemiBold),
                          ),
                          TextSpan(
                            text: " the data.",
                            style: TextStyle(
                              color: ColorTheme.kTextColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).paddingOnly(bottom: 20),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      title: "Confirm",
                      buttonColor: ColorTheme.kBlack,
                      fontColor: ColorTheme.kWhite,
                      height: 40,
                      width: 90,
                      borderRadius: 5,
                      onTap: () async {
                        if (!sizeInformation.isMobile) {
                          if (!_deleteFormKey.currentState!.validate()) {
                            return;
                          }
                        }
                        if (deleteDataFun != null) {
                          await deleteDataFun!(obj['_id'], index);
                        }
                      },
                    ),
                    CustomButton(
                      title: "Cancel",
                      buttonColor: ColorTheme.kWhite,
                      fontColor: ColorTheme.kHintTextColor,
                      showBoxBorder: true,
                      height: 40,
                      width: 70,
                      borderRadius: 5,
                      onTap: () {
                        Get.back();
                      },
                    ).paddingOnly(left: 10),
                  ],
                ),
              ],
            ),
          );
        }),
      ));
    }
  }

  Future<dynamic> dataInfo({
    required int index,
  }) {
    return Get.dialog(Dialog(
      surfaceTintColor: ColorTheme.kWhite,
      backgroundColor: ColorTheme.kWhite,
      alignment: Alignment.topCenter,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                splashColor: ColorTheme.kWhite,
                hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                splashRadius: 20,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close),
              ),
            ),
            const TextWidget(
              text: "Info",
              fontSize: 20,
              color: ColorTheme.kBlack,
              fontWeight: FontTheme.notoBold,
            ).paddingOnly(bottom: 20),
            Visibility(
              visible: (data[index]["recordinfo"]["entryby"]).toString().isNotNullOrEmpty,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Entry by: ",
                      style: TextStyle(
                        color: ColorTheme.kHintTextColor,
                        fontSize: 15,
                        fontWeight: FontTheme.notoRegular,
                      ),
                    ),
                    TextSpan(
                      text: (data[index]["recordinfo"]["entryby"] ?? "").toString(),
                      style: const TextStyle(
                        color: ColorTheme.kBlack,
                        fontSize: 15,
                        fontWeight: FontTheme.notoSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Entry Date: ",
                    style: TextStyle(
                      color: ColorTheme.kHintTextColor,
                      fontSize: 15,
                      fontWeight: FontTheme.notoRegular,
                    ),
                  ),
                  TextSpan(
                    text: data[index]["recordinfo"]["entrydate"].toString().toDateTimeFormat(),
                    style: const TextStyle(
                      color: ColorTheme.kBlack,
                      fontSize: 15,
                      fontWeight: FontTheme.notoSemiBold,
                    ),
                  ),
                ],
              ),
            ).paddingOnly(bottom: 20),
            Visibility(
              visible: (data[index]["recordinfo"]["updateby"]).toString().isNotNullOrEmpty,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Update by: ",
                      style: TextStyle(
                        color: ColorTheme.kHintTextColor,
                        fontSize: 15,
                        fontWeight: FontTheme.notoRegular,
                      ),
                    ),
                    TextSpan(
                      text: (data[index]["recordinfo"]["updateby"] ?? "").toString(),
                      style: const TextStyle(
                        color: ColorTheme.kBlack,
                        fontSize: 15,
                        fontWeight: FontTheme.notoSemiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Update Date: ",
                    style: TextStyle(
                      color: ColorTheme.kHintTextColor,
                      fontSize: 15,
                      fontWeight: FontTheme.notoRegular,
                    ),
                  ),
                  TextSpan(
                    text: data[index]["recordinfo"]["updatedate"].toString().toDateTimeFormat(),
                    style: const TextStyle(
                      color: ColorTheme.kBlack,
                      fontSize: 15,
                      fontWeight: FontTheme.notoSemiBold,
                    ),
                  ),
                ],
              ),
            ).paddingOnly(bottom: 20),
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
    ));
  }
}
