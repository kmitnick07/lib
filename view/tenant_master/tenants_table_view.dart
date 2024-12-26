// ignore_for_file: must_be_immutable
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/hover_builder.dart';
import 'package:prestige_prenew_frontend/components/prenew_logo.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/helper/device_service.dart';
import 'package:prestige_prenew_frontend/controller/tenant_master_controller.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:prestige_prenew_frontend/view/tenant/co_applicant_dialog.dart';
import 'package:prestige_prenew_frontend/view/tenant_master/tenants_kanban_card_view.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_checkbox.dart';
import '../../components/customs/custom_dialogs.dart';
import '../../components/customs/custom_shimmer.dart';
import '../../components/customs/custom_tooltip.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../models/Menu/menu_model.dart';
import '../../models/form_data_model.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../no_data_found_screen.dart';
import '../tenant/rent_history_dialog.dart';
import '../tenant/status_history_dialog.dart';
import '../tenant/tenant_history_dialog.dart';
import '../user_role_hierarchy/member_show.dart';

AutoScrollController autoscrollcontroller = AutoScrollController();

class TenantDataTableView extends GetView<TenantMasterController> {
  final FormDataModel setDefaultData;
  final double width;
  final List<PopupMenuItem<dynamic>>? popupMenuItems;
  final String? pageName;
  List<Map<String, dynamic>> fieldOrder = [];
  List<Map<String, dynamic>> data = [];
  final Function(String id, int index)? editDataFun;
  final Function(String id)? deleteDataFun;
  final Function(int pageNo, int pageLimit)? onPageChange;
  final Function(int index, String field, String type, dynamic value)? handleGridChange;
  final bool isLoading;
  UserRight pageRights = UserRight();
  ScrollController horizontalScrollController = ScrollController();

  TenantDataTableView({
    super.key,
    required this.width,
    required this.setDefaultData,
    this.popupMenuItems,
    this.pageName,
    required this.fieldOrder,
    this.editDataFun,
    this.deleteDataFun,
    required this.data,
    this.isLoading = false,
    this.onPageChange,
    this.handleGridChange,
  });

  @override
  Widget build(BuildContext context) {
    pageRights = IISMethods().getPageRights(alias: pageName ?? '') ?? UserRight();
    return PopScope(
        canPop: false,
        child: GetBuilder(
            init: Get.put(TenantMasterController()),
            builder: (TenantMasterController controller) {
              return ResponsiveBuilder(
                builder: (context, sizingInformation) {
                  if (sizingInformation.isMobile) {
                    return Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              controller.setDefaultData.pageNo.value = 1;
                              await controller.getList();
                            },
                            child: (data.isEmpty && !(controller.loadingPaginationData.value || isLoading))
                                ? const Center(child: NoDataFoundScreen())
                                : Obx(() {
                                    return ListView.separated(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      controller: controller.tableScrollController,
                                      padding: const EdgeInsets.all(8),
                                      itemCount: data.length + ((controller.loadingPaginationData.value || isLoading) ? 5 : 0),
                                      itemBuilder: (context, index) {
                                        if (data.length <= index) {
                                          return TenantKanBanCardView(
                                            data: {},
                                            pageName: controller.pageName.value,
                                            index: index,
                                            isLoading: true,
                                          );
                                        }
                                        devPrint('LENGTH--->${data.length}--->${data.length + ((controller.loadingPaginationData.value || isLoading) ? 5 : 0)}');
                                        bool isEditVisible = true;
                                        isEditVisible = pageRights.alleditright == 1 || (pageRights.selfeditright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid));
                                        bool isApproverVisible = true;
                                        isApproverVisible = !isLoading && controller.approverTenantProject.contains(data[index]['tenantprojectid']);
                                        return Container(
                                          decoration: BoxDecoration(boxShadow: [BoxShadow(color: ColorTheme.kBlack.withOpacity(0.1), spreadRadius: 6, blurRadius: 2)]),
                                          child: GestureDetector(
                                            onLongPressStart: sizingInformation.isMobile
                                                ? (details) {
                                                    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                                                    showMenu(
                                                      context: context,
                                                      position: RelativeRect.fromRect(Rect.fromPoints(details.globalPosition, details.globalPosition), Offset.zero & overlay.size),
                                                      items: [
                                                        if (isEditVisible)
                                                          CommonDataTableWidget.menuOption(
                                                            btnName: 'Edit',
                                                            onTap: () async {
                                                              if (editDataFun != null) {
                                                                editDataFun!(data[index]['_id'], index);
                                                              }
                                                            },
                                                          ),
                                                        if (isApproverVisible)
                                                          CommonDataTableWidget.menuOption(
                                                            onTap: () {
                                                              controller.getSapData(selectedIds: [data[index]['_id']], tenantProjectId: controller.setDefaultData.filterData['tenantprojectid']);
                                                            },
                                                            btnName: 'Submit to SAP',
                                                          ),
                                                        if (data[index]['historyexist'] == 1)
                                                          CommonDataTableWidget.menuOption(
                                                            onTap: () {
                                                              tenantHistory(data[index]['_id']);
                                                            },
                                                            btnName: 'Tenant History',
                                                          ),
                                                        CommonDataTableWidget.menuOption(
                                                          onTap: () async {
                                                            controller.getSAPHistory(id: data[index]['_id'] ?? '');
                                                            controller.getSAPContractHistory(id: data[index]['_id'] ?? '');
                                                            controller.getTenant360Details(data: data[index] ?? {});
                                                          },
                                                          btnName: 'Tenant Details',
                                                        )
                                                      ],
                                                    );
                                                  }
                                                : null,
                                            child: Slidable(
                                              key: ValueKey(index >= data.length ? "${DateTime.now()}" : data[index]['_id']),
                                              endActionPane: ActionPane(
                                                motion: const ScrollMotion(),
                                                extentRatio: 0.25,
                                                children: [
                                                  const SizedBox(width: 15),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Visibility(
                                                        visible: isEditVisible,
                                                        child: InkWell(
                                                          onTap: () {
                                                            if (editDataFun != null) {
                                                              editDataFun!(data[index]['_id'], index);
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 60,
                                                            width: 60,
                                                            decoration: BoxDecoration(
                                                              color: Colors.black,
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                            child: const Icon(
                                                              Icons.edit,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: isEditVisible,
                                                        child: const SizedBox(height: 15),
                                                      ),
                                                      // if (!isLoading && false)
                                                      //   Visibility(
                                                      //     visible: !isLoading && data[index]['historyexist'] == 1,
                                                      //     child: InkWell(
                                                      //       onTap: () {
                                                      //         tenantHistory(data[index]['_id']);
                                                      //       },
                                                      //       child: Container(
                                                      //         height: 60,
                                                      //         width: 60,
                                                      //         decoration: BoxDecoration(
                                                      //           color: Colors.black,
                                                      //           borderRadius: BorderRadius.circular(15),
                                                      //         ),
                                                      //         child: const Icon(
                                                      //           Icons.history,
                                                      //           color: Colors.white,
                                                      //         ),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      Visibility(
                                                        visible: !isLoading && isApproverVisible,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            controller.getSapData(selectedIds: [data[index]['_id']], tenantProjectId: controller.setDefaultData.filterData['tenantprojectid']);
                                                          },
                                                          child: Container(
                                                            height: 60,
                                                            width: 60,
                                                            decoration: BoxDecoration(
                                                              color: Colors.black,
                                                              borderRadius: BorderRadius.circular(15),
                                                            ),
                                                            child: const Icon(
                                                              CupertinoIcons.upload_circle,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(visible: !isLoading && isApproverVisible, child: const SizedBox(height: 15)),
                                                      InkWell(
                                                        onTap: () async {
                                                          controller.getSAPHistory(id: data[index]['_id'] ?? '');
                                                          controller.getSAPContractHistory(id: data[index]['_id'] ?? '');
                                                          controller.getTenant360Details(data: data[index] ?? {});
                                                        },
                                                        child: Container(
                                                          height: 60,
                                                          width: 60,
                                                          decoration: BoxDecoration(
                                                            color: Colors.black,
                                                            borderRadius: BorderRadius.circular(15),
                                                          ),
                                                          child: const Icon(
                                                            Icons.info_outline_rounded,
                                                            color: ColorTheme.kWhite,
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              // child: Container(color: Colors.red,height: 100,),
                                              child: TenantKanBanCardView(
                                                data: index >= data.length ? {} : data[index],
                                                isLoading: isLoading,
                                                pageName: controller.pageName.value,
                                                index: index,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return Container(
                                          // color: ColorTheme.kBackgroundColor,
                                          height: 20,
                                        );
                                      },
                                    );
                                  }),
                          ),
                        ),
                        Visibility(
                          visible: !sizingInformation.isMobile,
                          child: SizedBox(
                            width: width,
                            child: Row(
                              children: <Widget>[
                                PopupMenuButton(
                                  color: ColorTheme.kWhite,
                                  itemBuilder: (context) {
                                    return [
                                      ...List.generate(
                                        pageLimit.length,
                                        (index) => PopupMenuItem(
                                          child: TextWidget(text: pageLimit[index]['label']),
                                          onTap: () async {
                                            onPageChange!(1, pageLimit[index]['value']!);
                                          },
                                        ),
                                      )
                                    ];
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: ColorTheme.kWhite,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 38,
                                          decoration: BoxDecoration(
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          height: 38,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(6),
                                              bottomRight: Radius.circular(6),
                                            ),
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
                                  ),
                                ).paddingOnly(right: 8),
                                Obx(() {
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
                                const Spacer(),
                                Visibility(
                                  visible: setDefaultData.noOfPages.value > 1,
                                  child: Builder(builder: (context) {
                                    AutoScrollController autoscrollcontroller = AutoScrollController();
                                    return Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CustomButton(
                                            onTap: 1 != setDefaultData.pageNo.value
                                                ? () {
                                                    if (1 != setDefaultData.pageNo.value) {
                                                      onPageChange!(setDefaultData.pageNo.value - 1, setDefaultData.pageLimit);
                                                      autoscrollcontroller.scrollToIndex(setDefaultData.pageNo.value - 1, preferPosition: AutoScrollPosition.middle, duration: const Duration(milliseconds: 500));
                                                    }
                                                  }
                                                : null,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 14,
                                            title: 'Previous',
                                            width: 50,
                                            buttonColor: ColorTheme.kBackGroundGrey,
                                            height: 38,
                                            borderRadius: 8,
                                            fontColor: 1 != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                          ),
                                        ),
                                        Container(
                                          height: 38,
                                          constraints: const BoxConstraints(maxWidth: 300),
                                          child: ListView.separated(
                                            controller: autoscrollcontroller,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              return AutoScrollTag(
                                                index: index,
                                                controller: autoscrollcontroller,
                                                key: ValueKey(index),
                                                child: Obx(() {
                                                  return InkWell(
                                                    onTap: () {
                                                      if (onPageChange != null) {
                                                        onPageChange!(index + 1, setDefaultData.pageLimit);
                                                        autoscrollcontroller.scrollToIndex(index, preferPosition: AutoScrollPosition.middle);
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
                                                      autoscrollcontroller.scrollToIndex(setDefaultData.pageNo.value + 1, preferPosition: AutoScrollPosition.middle);
                                                    }
                                                  }
                                                : null,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 14,
                                            title: 'Next',
                                            width: 50,
                                            buttonColor: ColorTheme.kBackGroundGrey,
                                            height: 38,
                                            borderRadius: 8,
                                            fontColor: setDefaultData.noOfPages.value != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                )
                              ],
                            ).paddingAll(8),
                          ),
                        ),
                      ],
                    );
                  }
                  double totalFlex = 0;

                  List<Map<String, dynamic>> field = fieldOrder.where((element) => element['active'] == 1).toList();

                  for (var element in field) {
                    totalFlex += (element['tblsize'] ?? 20);
                  }
                  double ratio = 1;
                  if (totalFlex * 10 < (width)) {
                    ratio = (width) / (totalFlex * 10);
                  }
                  Map<int, TableColumnWidth> sizeMap = Map.from(
                    field.map((element) => FixedColumnWidth((element['tblsize'] ?? 20) * 10 * ratio)).toList().asMap(),
                  );
                  if (isLoading == true && fieldOrder.isNullOrEmpty && data.isNullOrEmpty) {
                    return Table(
                      columnWidths: sizeMap,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: ColorTheme.kTableHeader),
                          children: [
                            ...List.generate(isLoading && field.isNullOrEmpty ? 6 : field.length, (index) {
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
                                              height: 30,
                                            ),
                                          ).paddingAll(8))
                                ]))
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          interactive: true,
                          controller: horizontalScrollController,
                          child: SingleChildScrollView(
                            controller: horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Visibility(
                              visible: isLoading == true || fieldOrder.isNotNullOrEmpty,
                              replacement: SizedBox(width: width, height: 500, child: const Center(child: NoDataFoundScreen())),
                              child: Column(
                                children: [
                                  Container(
                                    color: ColorTheme.kTableHeader,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Table(
                                      columnWidths: sizeMap,
                                      children: [
                                        TableRow(
                                          decoration: const BoxDecoration(color: ColorTheme.kTableHeader),
                                          children: [
                                            ...List.generate(isLoading && field.isNullOrEmpty ? 5 : field.length, (index) {
                                              return TableCell(
                                                verticalAlignment: TableCellVerticalAlignment.middle,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                                  child: (isLoading && index >= field.length)
                                                      // Dummy data when isLoading is true
                                                      ? Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          height: 12,
                                                        ).paddingAll(8)
                                                      : (field[index]['type'] == 'checkbox')
                                                          ? Row(
                                                              children: [
                                                                Obx(() {
                                                                  return CustomCheckBox(
                                                                    value: controller.selectAll.value,
                                                                    onChanged: (value) {
                                                                      if (handleGridChange != null) {
                                                                        handleGridChange!(
                                                                          index,
                                                                          field[index]['field'],
                                                                          'selectAll',
                                                                          value,
                                                                        );
                                                                      }
                                                                    },
                                                                  );
                                                                }),
                                                                Flexible(
                                                                  child: TextWidget(
                                                                    text: '${field[index]['text'].toUpperCase()} (${controller.selectedCount.value})',
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w400,
                                                                    color: ColorTheme.kBlack,
                                                                    textOverflow: TextOverflow.visible,
                                                                    maxLines: 2,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Visibility(
                                                              visible: field[index]['sorttable'] == 1,
                                                              replacement: TextWidget(
                                                                text: field[index]['text'].toUpperCase(),
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w400,
                                                                color: ColorTheme.kBlack,
                                                                textOverflow: TextOverflow.visible,
                                                                maxLines: 2,
                                                              ),
                                                              child: InkWell(
                                                                onTap: () {
                                                                  // if (onSort != null) {
                                                                  //   onSort!(field[index]['sortby']);
                                                                  // }
                                                                },
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    Flexible(
                                                                      child: TextWidget(
                                                                        text: field[index]['text'].toUpperCase(),
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w400,
                                                                        color: ColorTheme.kBlack,
                                                                        textOverflow: TextOverflow.visible,
                                                                        maxLines: 2,
                                                                      ),
                                                                    ),
                                                                    SvgPicture.asset(
                                                                      setDefaultData.sortData[field[index]['sortby'] ?? ''] == 1 ? AssetsString.kSortDscSvg : AssetsString.kSortAscSvg,
                                                                      height: 18,
                                                                    ),
                                                                  ],
                                                                ),
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
                                    child: SingleChildScrollView(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Visibility(
                                            visible: isLoading == true || data.isNotNullOrEmpty,
                                            replacement: SizedBox(width: width, height: 500, child: const Center(child: NoDataFoundScreen())),
                                            child: Table(
                                              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                              columnWidths: sizeMap,
                                              children: List.generate(
                                                /*(data).length +*/
                                                (isLoading ? 5 : (data).length),
                                                // Add dummy rows if isLoading is true
                                                (index) => TableRow(
                                                  decoration: const BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        color: ColorTheme.kBorderColor,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                  ),
                                                  children: [
                                                    ...List.generate(
                                                      (field ?? []).length,
                                                      (i) {
                                                        // if (isLoading) {
                                                        //   // Dummy data when isLoading is true
                                                        //   return CustomShimmer(
                                                        //     isLoading: isLoading,
                                                        //     child: Container(
                                                        //       decoration: BoxDecoration(
                                                        //         color: ColorTheme.kBlack,
                                                        //         borderRadius: BorderRadius.circular(4),
                                                        //       ),
                                                        //       height: 20,
                                                        //     ),
                                                        //   ).paddingAll(8);
                                                        // } else {
                                                        Map<String, dynamic> obj = (index < data.length) ? data[index] : {};
                                                        Map<String, dynamic> innerObj = field[i];
                                                        return TableCell(
                                                          // child: SizedBox(),
                                                          verticalAlignment: (innerObj['type'] == 'status' || controller.setDefaultData.fieldOrder[i]['type'] == 'menu') ? TableCellVerticalAlignment.middle : TableCellVerticalAlignment.top,
                                                          child: Builder(builder: (context) {
                                                            return projectListTile(obj, innerObj, index, isLoading).paddingSymmetric(vertical: 8, horizontal: 16);
                                                          }),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Row(
                          children: <Widget>[
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
                                      (index) => CommonDataTableWidget.menuOption(
                                        btnName: (pageLimit[index]['label'] ?? "").toString(),
                                        onTap: () async {
                                          onPageChange!(1, pageLimit[index]['value']!);
                                        },
                                      ),
                                    )
                                  ];
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: ColorTheme.kWhite,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 38,
                                        decoration: BoxDecoration(
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        height: 38,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(6),
                                            bottomRight: Radius.circular(6),
                                          ),
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
                                ),
                              ).paddingOnly(right: 8),
                            ),
                            Obx(() {
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
                            const SizedBox(
                              width: 8,
                            ),
                            Obx(() {
                              return Visibility(
                                visible: controller.isSapSelection.value,
                                replacement: const SizedBox(
                                  width: 200,
                                  height: 25,
                                ),
                                child: TextWidget(
                                  text: '${controller.selectedCount.value} Tenant Selected',
                                  color: ColorTheme.kPrimaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            }),
                            const Spacer(),
                            Visibility(
                              visible: setDefaultData.noOfPages.value > 1,
                              child: Builder(builder: (context) {
                                return Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomButton(
                                        onTap: 1 != setDefaultData.pageNo.value
                                            ? () {
                                                if (1 != setDefaultData.pageNo.value) {
                                                  onPageChange!(setDefaultData.pageNo.value - 1, setDefaultData.pageLimit);
                                                  autoscrollcontroller.scrollToIndex(setDefaultData.pageNo.value - 1, preferPosition: AutoScrollPosition.middle, duration: const Duration(milliseconds: 500));
                                                }
                                              }
                                            : null,
                                        fontWeight: FontTheme.notoSemiBold,
                                        fontSize: 14,
                                        title: 'Previous',
                                        width: 50,
                                        buttonColor: ColorTheme.kBackGroundGrey,
                                        height: 38,
                                        borderRadius: 8,
                                        fontColor: 1 != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                      ),
                                    ),
                                    Container(
                                      height: 38,
                                      constraints: const BoxConstraints(maxWidth: 300),
                                      child: ListView.separated(
                                        controller: autoscrollcontroller,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return AutoScrollTag(
                                            index: index,
                                            controller: autoscrollcontroller,
                                            key: ValueKey(index),
                                            child: Obx(() {
                                              return InkWell(
                                                onTap: () {
                                                  if (onPageChange != null) {
                                                    onPageChange!(index + 1, setDefaultData.pageLimit);
                                                    autoscrollcontroller.scrollToIndex(index, preferPosition: AutoScrollPosition.middle);
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
                                                  autoscrollcontroller.scrollToIndex(setDefaultData.pageNo.value + 1, preferPosition: AutoScrollPosition.middle);
                                                }
                                              }
                                            : null,
                                        fontWeight: FontTheme.notoSemiBold,
                                        fontSize: 14,
                                        title: 'Next',
                                        width: 50,
                                        buttonColor: ColorTheme.kBackGroundGrey,
                                        height: 38,
                                        borderRadius: 8,
                                        fontColor: setDefaultData.noOfPages.value != setDefaultData.pageNo.value ? ColorTheme.kPrimaryColor : ColorTheme.kGrey,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            )
                          ],
                        ).paddingAll(8),
                      ),
                    ],
                  );
                },
              );
            }));
  }

  Widget projectListTile(data, fieldOrder, index, bool isLoading) {
    bool isEditVisible = true;
    isEditVisible = pageRights.alleditright == 1 || (pageRights.selfeditright == 1 && (data['recordinfo']?['entryuid'] == Settings.uid));
    bool isApproverVisible = true;
    isApproverVisible = controller.approverTenantProject.contains(data['tenantprojectid']);
    switch (fieldOrder['type']) {
      case "checkbox":
        return CustomCheckBox(
          value: data[fieldOrder['field']] == 1,
          onChanged: (value) {
            if (handleGridChange != null) {
              handleGridChange!(
                index,
                fieldOrder['field'],
                'checkbox',
                value,
              );
            }
          },
        );
      case 'menu':
        return Theme(
          data: Theme.of(Get.context!).copyWith(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: PopupMenuButton(
            offset: const Offset(-35, 0),
            constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 135,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            shadowColor: ColorTheme.kBlack,
            tooltip: '',
            surfaceTintColor: ColorTheme.kTableHeader,
            elevation: 6,
            popUpAnimationStyle: AnimationStyle(
              curve: Curves.bounceInOut,
            ),
            padding: EdgeInsets.zero,
            color: ColorTheme.kWhite,
            position: PopupMenuPosition.over,
            itemBuilder: (context) {
              return [
                if (isEditVisible)
                  CommonDataTableWidget.menuOption(
                    btnName: 'Edit',
                    onTap: () async {
                      if (editDataFun != null) {
                        editDataFun!(data['_id'], index);
                      }
                      // controller.setFormData(id: , editeDataIndex: );
                      // Get.dialog(const MasterForm(title: "Edit", btnName: "Update"));
                    },
                  ),

                // if (data['historyexist'] == 1)
                //   CommonDataTableWidget.menuOption(
                //     onTap: () {
                //       tenantHistory(data['_id']);
                //     },
                //     btnName: 'Tenant History',
                //   ),
                if (isApproverVisible)
                  CommonDataTableWidget.menuOption(
                    onTap: () {
                      controller.getSapData(selectedIds: [data['_id']], tenantProjectId: controller.setDefaultData.filterData['tenantprojectid']);
                    },
                    btnName: 'Submit to SAP',
                  ),

                /// DIRECT DELETE (EASY AT DEVELOPMENT TIME TO DELETE ANY ITEM)
                // PopupMenuItem(
                //   onTap: () async {
                //     if (deleteDataFun != null) {
                //       deleteDataFun!(obj['_id']);
                //     }
                //   },
                //   child: const TextWidget(text: 'Direct Delete'),
                // ),
                CommonDataTableWidget.menuOption(
                  onTap: () async {
                    controller.getSAPHistory(id: data['_id'] ?? '');
                    controller.getSAPContractHistory(id: data['_id'] ?? '');
                    controller.getTenant360Details(data: data ?? {});
                  },
                  btnName: 'Tenant Details',
                )
              ];
            },
            child: const Icon(
              Icons.more_vert,
            ),
          ),
        );

      case "status":
        int sapStatus = 1; //Pending
        switch (data['SAP_vendor_status']) {
          case 5:
          case 10:
            sapStatus = 3; //For Success
            break;
          case 2:
          case 3:
          case 4:
          case 7:
          case 8:
          case 9:
            sapStatus = 2; //For In-progress
            break;
        }
        return CustomShimmer(
          isLoading: isLoading,
          child: Column(
            children: [
              CustomTooltip(
                message: 'SAP Status: ${sapStatus == 3 ? 'Success' : sapStatus == 2 ? 'In-Progress' : 'Pending'}',
                child: Container(
                  height: 32,
                  width: 32,
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
                    // size: 10,
                    color: sapStatus == 3
                        ? ColorTheme.kSuccessColor
                        : sapStatus == 2
                            ? ColorTheme.kWarnColor
                            : null,
                  ),
                ),
              ).paddingOnly(bottom: 16),
              CustomTooltip(
                message: data['tenantstatus'] ?? '',
                child: Theme(
                  data: Theme.of(Get.context!).copyWith(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: PopupMenuButton(
                    offset: const Offset(-40, 0),
                    constraints: const BoxConstraints(
                      minWidth: 135,
                    ),
                    // enabled: isEditVisible,
                    enabled: false,
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
                              onTap: () {
                                controller.handleGridChange(type: HtmlControls.kTenantStatus, field: 'tenantstatusid', index: index, value: controller.setDefaultData.masterDataList['tenantstatus'][stageIndex]['_id']);
                              },
                              btnName: controller.setDefaultData.masterDataList['tenantstatus'][stageIndex]['status'],
                              svgImageUrl: controller.setDefaultData.masterDataList['tenantstatus'][stageIndex]['image'],
                            );
                          },
                        )
                      ];
                    },
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: ColorTheme.kBackgroundColor,
                      ),
                      padding: const EdgeInsets.all(4),
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
                              // colorFilter: ColorFilter.mode(
                              //     (((controller.setDefaultData.masterDataList['tenantstatus'] ?? [{}]).firstWhere((element) {
                              //               return element['_id'].toString() == data['tenantstatusid'].toString();
                              //             }) ??
                              //             {})['color'] ??
                              //         '').toString().toColor(),
                              //     BlendMode.srcIn),
                            );
                          }
                          return const SizedBox();
                        } catch (e) {
                          return const SizedBox.shrink();
                        }
                      }),
                    ),
                  ),
                ).paddingOnly(bottom: 16),
              ),
              InkResponse(
                onTap: isEditVisible
                    ? () {
                        CustomDialogs().statusChangeDialog(
                          onTap: () {
                            controller.handleGridChange(type: HtmlControls.kStatus, field: 'status', index: index, value: data['status'] != 1);
                            Get.back();
                          },
                          value: data['status'],
                        );
                      }
                    : null,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: ColorTheme.kBackgroundColor,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: data['status'] == 1 ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'tenantid':
        return Container(
          height: 75,
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: ColorTheme.kScaffoldColor,
            border: Border.all(
              color: ColorTheme.kBorderColor,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: CustomShimmer(
            isLoading: isLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  decoration: BoxDecoration(color: ColorTheme.kPrimaryColor.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                  padding: const EdgeInsets.all(5),
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
                const SizedBox(
                  height: 3,
                ),
                SizedBox(
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
                        message: (data[fieldOrder['field']['subfield'][index]['field']]).toString().isNullOrEmpty
                            ? '${fieldOrder['field']['subfield'][index]['text']}'
                            : '${fieldOrder['field']['subfield'][index]['text']} \n ${data[fieldOrder['field']['subfield'][index]['field']]}',
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
                              '${fieldOrder['field']['subfield'][index]['text'][0]}',
                              style: GoogleFonts.novaMono(
                                fontSize: 14,
                                fontWeight: FontTheme.notoSemiBold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 4,
                    ),
                    itemCount: (fieldOrder['field']?['subfield'] ?? []).length,
                  ),
                )
              ],
            ),
          ),
        );
      case 'hutmentdetails':
        return Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: ColorTheme.kScaffoldColor,
            border: Border.all(
              color: ColorTheme.kBorderColor,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: CustomShimmer(
            isLoading: isLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
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
                                    colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['eligibilityname'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
                                  ),
                                )
                              : index == 2
                                  ? CustomTooltip(
                                      message: "Non-Survey Structure${(data['xpartname']).toString().isNullOrEmpty ? '' : "\n${data['xpartname']}"}",
                                      textAlign: TextAlign.center,
                                      child: SvgPicture.asset(
                                        AssetsString.kXPart,
                                        colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['xpartname'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
                                      ),
                                    )
                                  : index == 3
                                      ? CustomTooltip(
                                          message: "Current Voting List Serial No${(data['serialno']).toString().isNullOrEmpty ? '' : "\n${data['serialno']}"}",
                                          textAlign: TextAlign.center,
                                          child: SvgPicture.asset(
                                            AssetsString.kSerialNoSvg,
                                            colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['serialno'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
                                          ),
                                        )
                                      : index == 4
                                          ? CustomTooltip(
                                              message: "Form 3/4${(data['form3_4']).toString().isNullOrEmpty ? '' : "\n${data['form3_4']}"}",
                                              textAlign: TextAlign.center,
                                              child: SvgPicture.asset(
                                                AssetsString.kFormNoSvg,
                                                colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['form3_4'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
                                              ),
                                            )
                                          : index == 5
                                              ? CustomTooltip(
                                                  message: "Voting List Part${(data['votinglistpart']).toString().isNullOrEmpty ? '' : "\n${data['votinglistpart']}"}",
                                                  textAlign: TextAlign.center,
                                                  child: SvgPicture.asset(
                                                    AssetsString.kVoterListSvg,
                                                    colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['votinglistpart'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 4,
                    ),
                    itemCount: 6,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Container(
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
                            height: 29,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => Container(
                                height: 29,
                                width: 28.5,
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
                                            colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['housetax'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
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
                                                colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['watertaxbill'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
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
                                                    colorFilter: ColorFilter.mode(ColorTheme.kBlack.withOpacity(data['elecricitybill'].toString().isNullOrEmpty ? 0.2 : 1), BlendMode.srcIn),
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
                                                          IISMethods().getDocumentHistory(tenantId: data['_id'] ?? "", documentType: 'Family NOC Image', pagename: controller.formName.value);
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
                const SizedBox(
                  height: 4,
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
                          child: Row(
                            children: [
                              TextWidget(
                                text: 'MEASUREMENT',
                                fontWeight: FontTheme.notoSemiBold,
                                fontSize: 10,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case 'tenantdetails':
        return Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: ColorTheme.kScaffoldColor,
            border: Border.all(
              color: ColorTheme.kBorderColor,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: CustomShimmer(
            isLoading: isLoading,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Container(
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
                          height: 32,
                          width: 32,
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: InkWell(
                              onTap: (data['tenantownerphoto'].toString().isNotNullOrEmpty && data['tenantownerphoto']['url'].toString().isNotNullOrEmpty)
                                  ? () {
                                      documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(data['tenantownerphoto'] ?? {})));
                                    }
                                  : null,
                              child: Image.network(
                                FilesDataModel.fromJson(data['tenantownerphoto']).url ?? '',
                                errorBuilder: (context, error, stackTrace) {
                                  return SvgPicture.asset(
                                    AssetsString.kUser,
                                  );
                                },
                              ),
                            ),
                          ),
                          // child: ,
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
                                )),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextWidget(
                                text: data['tenantname'] ?? '',
                                color: ColorTheme.kPrimaryColor,
                                fontSize: 12,
                                fontWeight: FontTheme.notoBold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                ...List.generate((data['coapplicant'] ?? []).length, (index) {
                  var subData = data['coapplicant'][index];
                  devPrint(data['tenantaadharimage']);
                  return (subData['name']).toString().isNotNullOrEmpty && subData['isexpire'] != 1
                      ? index < 2
                          ? Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: subData['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 32,
                                        width: 32,
                                        padding: const EdgeInsets.all(2),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: InkWell(
                                            onTap: (subData['ownerphoto'].toString().isNotNullOrEmpty && subData['ownerphoto']['url'].toString().isNotNullOrEmpty)
                                                ? () {
                                                    documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(subData['ownerphoto'] ?? {})));
                                                  }
                                                : null,
                                            child: Image.network(
                                              FilesDataModel.fromJson(Map<String, dynamic>.from(subData['ownerphoto'] ?? {})).url ?? '',
                                              errorBuilder: (context, error, stackTrace) {
                                                return SvgPicture.asset(
                                                  AssetsString.kUser,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // child: ,
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
                                                  color: subData['hutmentsupportid'] == Config.kHutmentSupportId ? ColorTheme.kSuccessColor : ColorTheme.kErrorColor,
                                                  width: 1.5,
                                                ),
                                              )),
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: TextWidget(
                                              text: subData['name'] ?? '',
                                              color: ColorTheme.kPrimaryColor,
                                              fontSize: 12,
                                              fontWeight: FontTheme.notoBold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                              ],
                            )
                          : const SizedBox.shrink()
                      : const SizedBox.shrink();
                }),
                if ((data['coapplicant'] ?? []).length > 2)
                  InkWell(
                    onTap: () {
                      coApplicantDetailsDialog(data: data['coapplicant'] ?? []);
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: ColorTheme.kWhite, border: Border.all(color: ColorTheme.kGrey, width: 1.5)),
                          child: const Align(
                            alignment: Alignment.center,
                            child: TextWidget(
                              text: "See all",
                              color: ColorTheme.kPrimaryColor,
                              fontSize: 14,
                              fontWeight: FontTheme.notoSemiBold,
                            ),
                          ).paddingSymmetric(vertical: 6),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    ),
                  ),
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
                      ),
                const SizedBox(
                  height: 4,
                ),
                Visibility(
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
                          child: Opacity(
                            opacity: (data['tenantcontactno']).toString().isNullOrEmpty ? 0.3 : 1,
                            child: SvgPicture.asset(
                              index == (data['tenantcontactno'] ?? []).length ? AssetsString.kEmail : AssetsString.kPhone,
                            ),
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
                const SizedBox(
                  height: 4,
                ),
                SizedBox(
                  height: 32,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                                    message: "Aadhaar No${(data['tenantaadharno']).toString().isNullOrEmpty ? '' : "\n${data['tenantaadharno']}"}",
                                    textAlign: TextAlign.center,
                                    child: InkWell(
                                      onTap: (data['tenantaadharimage']?['url']).toString().isNullOrEmpty
                                          ? null
                                          : () {
                                              documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(data['tenantaadharimage'] ?? {})));
                                            },
                                      child: Image.asset(
                                        opacity: AlwaysStoppedAnimation(
                                          data['tenantaadharno'].toString().isNotNullOrEmpty ? 1 : 0.5,
                                        ),
                                        AssetsString.kAadhar,
                                        color: ColorTheme.kRed,
                                      ),
                                    ),
                                  )
                                : index == 1
                                    ? CustomTooltip(
                                        message: "Voter Id No${(data['tenantvoterid']).toString().isNullOrEmpty ? '' : "\n${data['tenantvoterid']}"}",
                                        textAlign: TextAlign.center,
                                        child: InkWell(
                                          onTap: (data['tenantvoterimage']?['url']).toString().isNullOrEmpty
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
                                              onTap: (data['tenantpanimage']?['url']).toString().isNullOrEmpty
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
                                                  onTap: (data['tenantrationcardimage']?['url']).toString().isNullOrEmpty
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
                      ),
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
                          )
                        ],
                      ).paddingOnly(left: 4)
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
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
                              controller.handleTenantExpired(id: data['_id'], index: index);
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
                              controller.handleHutmentSold(index: index, id: data['_id']);
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
                                  data: data ?? {},
                                  statusList: controller.setDefaultData.masterDataList['tenantstatus'] ?? [],
                                );
                              }));
                            },
                            child: SvgPicture.asset(AssetsString.kCalender)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      case 'concentdetails':
        return Container(
          width: 140,
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
            child: CustomShimmer(
              isLoading: isLoading,
              child: Column(
                children: [
                  ...commonDocumentView(
                    id: data['_id'] ?? "",
                    showDivider: false,
                    obj: [
                      {
                        'name': 'Attended Common Consent',
                        'value': data['attendedcommonconsent'] == 1 ? 'YES' : 'NO',
                        'url': {},
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
                    ],
                    formName: controller.formName.value,
                  ),
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
        );
      case 'rentdetails':
        Map rent = {};
        try {
          rent = ((List.from(data['rentdetails']).isNullOrEmpty ? [{}] : List.from(data['rentdetails'])) as List?)?.lastWhere(
            (element) {
              return element['paymenttypeid'] == '6639a3b42a3062b9e51b0154' && element['isdelete'] != 1;
            },
            orElse: () {
              return ((List.from(data['rentdetails']).isNullOrEmpty ? [{}] : List.from(data['rentdetails'])) as List?)?.last;
            },
          );
        } catch (e) {}
        return CustomShimmer(
          isLoading: isLoading,
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: ColorTheme.kScaffoldColor,
              border: Border.all(
                color: ColorTheme.kBorderColor,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(4),
            child: rent.isNullOrEmpty
                ? const SizedBox(
                    height: 70,
                    child: Center(
                      child: TextWidget(text: 'No Rent Data Found'),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: ColorTheme.kWhite,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((rent['paymenttypename']).toString().isNotNullOrEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextWidget(
                                  text: (rent['paymenttypename'] ?? '').toString().toUpperCase(),
                                  color: ColorTheme.kPrimaryColor,
                                  fontWeight: FontTheme.notoSemiBold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomTooltip(
                                message: 'PAYMENT HISTORY',
                                child: InkResponse(
                                  onTap: () {
                                    CustomDialogs().customFilterDialogs(
                                        context: Get.context!,
                                        widget: InfoForm(
                                          widthOfDialog: 500,
                                          infoPopUpWidget: RentHistoryDialog(data: data['rentdetails'] ?? []),
                                          isHeaderShow: false,
                                        ));
                                  },
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    size: 15,
                                    color: ColorTheme.kPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                        slotPaymentRow(title: rent['paymenttypefrequency'] == 2 ? 'Start Date' : 'Date', value: (rent['startdate'] ?? '-')),
                        if (rent['paymenttypefrequency'] == 2) slotPaymentRow(title: 'End Date', value: (rent['enddate'] ?? '-')),
                        const Divider(),
                        if (rent['rentinmonth'].toString().isNotNullOrEmpty || rent['noofmonths'].toString().isNotNullOrEmpty) ...[
                          Row(children: [
                            CustomTooltip(
                              message: 'Rent per Month',
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
                                message: 'Shifting Charges',
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
                  ), /*(rent['rentinmonth'])
                    .toString()
                    .isNullOrEmpty */ /*|| rent['rentinmonth'].toString().isNullOrEmpty || rent['noofmonths'].toString().isNullOrEmpty || rent['totalrent'].toString().isNullOrEmpty || rent['shiftingcharge'].toString().isNullOrEmpty*/ /*
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            rent['rentinmonth'].toString().isNotNullOrEmpty || rent['noofmonths'].toString().isNotNullOrEmpty
                                ? TextWidget(
                                    text: '${(rent['rentinmonth'] ?? '').toString().toAmount()} * ${(rent['noofmonths'] ?? '')}M',
                                    color: ColorTheme.kPrimaryColor,
                                    fontWeight: FontTheme.notoRegular,
                                    fontSize: 12,
                                  )
                                : const SizedBox.shrink(),
                            if (data['rentdetails'].length > 1)
                              Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: ColorTheme.kWhite,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: CustomTooltip(
                                    message: "rent history".toUpperCase(),
                                    textAlign: TextAlign.center,
                                    child: InkWell(
                                      onTap: () {
                                        Get.dialog(RentHistoryDialog(data: data['rentdetails'] ?? []));
                                      },
                                      child: const Icon(
                                        Icons.history,
                                        size: 18,
                                      ),
                                    ),
                                  )),
                          ],
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
                  ),*/
          ),
        );
      case 'paymentdetails':
        List rentDetailList = [];
        try {
          rentDetailList = ((List.from(data['rentdetails']).isNullOrEmpty ? [] : List.from(data['rentdetails'])) as List?)!;
        } catch (e) {}
        return Container(
          width: 140,
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
        );

      // Map rent = {};
      // try {
      //   rent = ((List.from(data['rentdetails']).isNullOrEmpty ? [{}] : List.from(data['rentdetails'])) as List?)?.last;
      // } catch (e) {}
      // return Container(
      //   width: 140,
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(4),
      //     color: ColorTheme.kScaffoldColor,
      //     border: Border.all(
      //       color: ColorTheme.kBorderColor,
      //       width: 1,
      //     ),
      //   ),
      //   padding: const EdgeInsets.all(4),
      //   child: Container(
      //     color: ColorTheme.kWhite,
      //     padding: const EdgeInsets.all(4),
      //     child: CustomShimmer(
      //       isLoading: isLoading,
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: 'Request Slot'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               TextWidget(
      //                 text: (rent['requestslotname'] ?? '-').toString().toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor,
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 8,
      //           ),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: 'Rent received'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               TextWidget(
      //                 text: (rent['rentreceiveddate'] ?? '-').toString().toDateFormat().toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor,
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //             ],
      //           ),
      //           const Divider(),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: '${rent['paymentinstrumentname'] ?? 'Payment'} No.'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               TextWidget(
      //                 text: (rent['paymentno'] ?? '-').toString().toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor,
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 8,
      //           ),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: '${rent['paymentinstrumentname'] ?? 'Payment'} Date'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               TextWidget(
      //                 text: (rent['paymentdate'] ?? '-').toString().toDateFormat().toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor,
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 8,
      //           ),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: '${rent['paymentinstrumentname'] ?? 'Payment'} Received at site '.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               TextWidget(
      //                 text: (rent['paymentreceivedsitedate'] ?? '-').toString().toDateFormat().toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor,
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 8,
      //           ),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: '${rent['paymentinstrumentname'] ?? 'Payment'} HANDOVER DATE'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               TextWidget(
      //                 text: (rent['paymenthandoverdate'] ?? '-').toString().toDateFormat().toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor,
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //             ],
      //           ),
      //           const Divider(),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: 'No. of Days'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               Container(
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(4),
      //                   color: ColorTheme.kPrimaryColor.withOpacity(0.1),
      //                 ),
      //                 padding: const EdgeInsets.all(4),
      //                 child: TextWidget(
      //                   text: (data['daysofrentpay'] ?? ' - ').toString().toDateFormat().toUpperCase(),
      //                   color: ColorTheme.kPrimaryColor,
      //                   fontWeight: FontTheme.notoBold,
      //                   fontSize: 10,
      //                 ),
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 8,
      //           ),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: 'Days to Pay'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               Container(
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(4),
      //                   color: ColorTheme.kPrimaryColor.withOpacity(0.1),
      //                 ),
      //                 padding: const EdgeInsets.all(4),
      //                 child: TextWidget(
      //                   text: (data['daysafterrentpay'] ?? ' - ').toString().toDateFormat().toUpperCase(),
      //                   color: ColorTheme.kPrimaryColor,
      //                   fontWeight: FontTheme.notoBold,
      //                   fontSize: 10,
      //                 ),
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 8,
      //           ),
      //           Row(
      //             children: [
      //               TextWidget(
      //                 text: 'Due Date'.toUpperCase(),
      //                 color: ColorTheme.kPrimaryColor.withOpacity(0.7),
      //                 fontWeight: FontTheme.notoSemiBold,
      //                 fontSize: 10,
      //               ),
      //               const Spacer(),
      //               Container(
      //                 decoration: BoxDecoration(
      //                   borderRadius: BorderRadius.circular(4),
      //                   color: ColorTheme.kPrimaryColor.withOpacity(0.1),
      //                 ),
      //                 padding: const EdgeInsets.all(4),
      //                 child: TextWidget(
      //                   text: (data['rentduedate'] ?? ' - ').toString().toDateFormat().toUpperCase(),
      //                   color: ColorTheme.kPrimaryColor,
      //                   fontWeight: FontTheme.notoBold,
      //                   fontSize: 10,
      //                 ),
      //               ),
      //             ],
      //           ),
      //           const SizedBox(
      //             height: 8,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // );
      default:
        return TextWidget(
          text: data[fieldOrder['field']].toString().toDateFormat(),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: ColorTheme.kBlack,
        );
    }
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

  Future<dynamic> dataInfo(
    BuildContext context,
    int index,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
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
                Text.rich(
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
                Text.rich(
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
                Visibility(
                  visible: (data[index]["recordinfo"]["updatedate"]).toString().isNotNullOrEmpty,
                  replacement: Text.rich(
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
                          text: data[index]["recordinfo"]["entrydate"].toString().toDateFormat(),
                          style: const TextStyle(
                            color: ColorTheme.kBlack,
                            fontSize: 15,
                            fontWeight: FontTheme.notoSemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: Text.rich(
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
                          text: data[index]["recordinfo"]["updatedate"].toString().toDateFormat(),
                          style: const TextStyle(
                            color: ColorTheme.kBlack,
                            fontSize: 15,
                            fontWeight: FontTheme.notoSemiBold,
                          ),
                        ),
                      ],
                    ),
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
        );
      },
    );
  }

  Future coApplicantDetailsDialog({required var data}) {
    return Get.dialog(CoApplicantDialog(coApplicantData: data));
  }

  Future<dynamic> tenantHistory(
    String? id,
  ) async {
    RxMap<String, dynamic> ownerHistoryMap = <String, dynamic>{}.obs;
    RxBool isTenantHistoryLoading = false.obs;
    isTenantHistoryLoading.value = true;

    var res = await IISMethods().listData(
      userAction: "listtenant",
      pageName: "tenant",
      url: "${Config.weburl}tenant/ownerhistory",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {"tenantid": id ?? ""},
          "projection": {},
          "sort": {},
        },
      },
    );

    if (res['status'] == 200) {
      ownerHistoryMap.value = res["data"] ?? {};
    }

    isTenantHistoryLoading.value = false;
    jsonPrint(tag: "96354163656341635", data);

    CustomDialogs().customPopDialog(
        child: TenantHistoryDialog(
          ownerHistory: ownerHistoryMap,
          rentdetailsdata: res["rentdetails"],
          data: const {},
        ),
        alignment: Alignment.topCenter);
  }
}

Widget tooltipHome({String? title, required String image, required List<FilesDataModel> imageList}) {
  return CustomTooltip(
    message: title,
    child: InkWell(
      onTap: imageList.isNullOrEmpty
          ? null
          : () {
              RxInt currentIndex = 0.obs;
              CarouselController carouselController = CarouselController();
              AutoScrollController galleryController = AutoScrollController();
              carouselController.animateToPage(currentIndex.value);
              Get.dialog(
                Dialog(
                  surfaceTintColor: ColorTheme.kWhite,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 450,
                        width: 700,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              child: CarouselSlider(
                                carouselController: carouselController,
                                items: imageList.map(
                                  (image) {
                                    return SizedBox(
                                      width: 700,
                                      child: FastCachedImage(
                                        url: image.url ?? "",
                                        height: Get.height,
                                        fit: BoxFit.contain,
                                        fadeInDuration: const Duration(seconds: 1),
                                        errorBuilder: (context, exception, stacktrace) {
                                          return const Opacity(
                                            opacity: 0.3,
                                            child: PrenewLogo(
                                              size: 150,
                                              showName: true,
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, progress) {
                                          return Container(
                                            color: ColorTheme.kWhite.withOpacity(0.2),
                                            child: const Stack(
                                              alignment: Alignment.center,
                                              children: [CupertinoActivityIndicator(radius: 20.0, color: ColorTheme.kWhite)],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ).toList(),
                                options: CarouselOptions(
                                  viewportFraction: 1,
                                  height: Get.height * 0.65,
                                  autoPlay: imageList.length > 1,
                                  autoPlayInterval: const Duration(milliseconds: 5000),
                                  pauseAutoPlayOnTouch: imageList.length > 1,
                                  scrollPhysics: imageList.length == 1 ? const NeverScrollableScrollPhysics() : null,
                                  onPageChanged: (index, reason) {
                                    currentIndex.value = index;
                                    galleryController.scrollToIndex(
                                      index,
                                      preferPosition: AutoScrollPosition.middle,
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (imageList.length > 1)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    HoverBuilder(
                                      builder: (isHovered) => AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: isHovered ? 1 : 0.2,
                                        child: InkResponse(
                                          onTap: () {
                                            carouselController.previousPage(
                                              curve: Curves.easeIn,
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: ColorTheme.kBlack.withOpacity(.8),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.arrow_back_ios_new_outlined,
                                                color: ColorTheme.kWhite,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    HoverBuilder(
                                      builder: (isHovered) => AnimatedOpacity(
                                        duration: const Duration(milliseconds: 300),
                                        opacity: isHovered ? 1 : 0.2,
                                        child: InkResponse(
                                          onTap: () {
                                            carouselController.nextPage(
                                              curve: Curves.easeIn,
                                            );
                                          },
                                          child: CircleAvatar(
                                            backgroundColor: ColorTheme.kBlack.withOpacity(.8),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.arrow_forward_ios_outlined,
                                                color: ColorTheme.kWhite,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (imageList.length > 1)
                              Align(
                                alignment: Alignment.topRight,
                                child: HoverBuilder(
                                  builder: (isHovered) => AnimatedOpacity(
                                    duration: const Duration(milliseconds: 300),
                                    opacity: isHovered ? 1 : 0.2,
                                    child: InkResponse(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor: ColorTheme.kBlack.withOpacity(.8),
                                        child: const Padding(
                                          padding: EdgeInsets.all(1),
                                          child: Icon(
                                            Icons.clear_rounded,
                                            color: ColorTheme.kWhite,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ).paddingAll(6)
                          ],
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 700,
                        color: ColorTheme.kBlack.withOpacity(0.85),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageList.length,
                          controller: galleryController,
                          itemBuilder: (context, index) {
                            return AutoScrollTag(
                              key: ValueKey(index),
                              index: index,
                              controller: galleryController,
                              child: InkWell(
                                onTap: () {
                                  carouselController.animateToPage(index);
                                },
                                child: Obx(
                                  () => AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: currentIndex.value == index ? 150 : 90,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: currentIndex.value == index ? Border.all(color: ColorTheme.kBlack, width: 2.5) : null,
                                    ),
                                    child: FastCachedImage(
                                      url: imageList[index].url ?? "",
                                      fit: BoxFit.contain,
                                      fadeInDuration: const Duration(seconds: 1),
                                      errorBuilder: (context, exception, stacktrace) {
                                        return const Opacity(
                                          opacity: 0.3,
                                          child: PrenewLogo(
                                            size: 50,
                                          ),
                                        );
                                      },
                                      loadingBuilder: (context, progress) {
                                        return Container(
                                          color: ColorTheme.kWhite.withOpacity(0.2),
                                          child: const Stack(
                                            alignment: Alignment.center,
                                            children: [CupertinoActivityIndicator(radius: 20.0, color: ColorTheme.kWhite)],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
      child: Builder(builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ColorTheme.kWhite,
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Opacity(
            opacity: imageList.isNullOrEmpty ? 0.1 : 1,
            child: Image.asset(
              image,
              height: 23,
              width: 22,
            ),
          ),
        );
      }),
    ),
  );
}

commonDocumentView({
  String id = "",
  required String formName,
  bool showDivider = true,
  List obj = const [],
}) {
  return [
    if (showDivider) const Divider(),
    ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        /// NEVER CHANGE NAME OF ANY DOCUMENT BECAUSE THAT IS ALSO GO FOR API CALL WHEN DOCUMENT HISTORY NEEDED
        return commonDocumentRow(id: id, index: index, obj: obj, formName: formName);
      },
      separatorBuilder: (context, index) => const SizedBox(
        height: 8,
      ),
      itemCount: obj.length,
    ),
  ];
}

commonDocumentRow({String id = "", List obj = const [], int index = 0, String formName = ''}) {
  return Row(
    children: [
      TextWidget(
        text: (obj[index]['name']).toUpperCase(),
        fontWeight: FontTheme.notoSemiBold,
        fontSize: 10,
        textOverflow: TextOverflow.visible,
        textAlign: TextAlign.start,
        color: ColorTheme.kBlack.withOpacity(0.8),
      ),
      const SizedBox(width: 4),
      if (obj[index]['url']['url'].toString().isNotNullOrEmpty) ...[
        InkWell(
            onTap: () {
              documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(obj[index]['url'] ?? {})));
            },
            child: const Icon(Icons.visibility_rounded, size: 13)),
        const SizedBox(width: 4),
        CustomTooltip(
          message: "View " + (obj[index]['name'] ?? ''),
          textAlign: TextAlign.center,
          child: InkWell(
              onTap: () {
                IISMethods().getDocumentHistory(
                  tenantId: id,
                  documentType: obj[index]['name'] ?? '',
                  pagename: formName,
                );
              },
              child: const Icon(Icons.history, size: 13)),
        ),
      ],
      const Spacer(),
      TextWidget(
        text: (obj[index]['value']) ?? '',
        fontWeight: FontTheme.notoSemiBold,
        fontSize: 10,
        textOverflow: TextOverflow.visible,
        textAlign: TextAlign.start,
        color: ColorTheme.kBlack.withOpacity(0.8),
      ),
    ],
  );
}
