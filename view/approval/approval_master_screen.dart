import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/json/approval_json.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/controller/Approval/approval_master_controller.dart';
import 'package:prestige_prenew_frontend/controller/dashboard/dashboard_controller.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_text_form_field.dart';
import '../../components/forms/approval_master_form.dart';
import '../../components/forms/filter_form.dart';
import '../../components/prenew_logo.dart';
import '../../config/config.dart';
import '../../config/helper/device_service.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../config/uppercase_formatter.dart';
import '../../models/Menu/menu_model.dart';
import '../../routes/route_name.dart';
import '../../style/string_const.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../CommonWidgets/common_header_footer.dart';

class ApprovalMasterScreen extends StatelessWidget {
  const ApprovalMasterScreen({super.key, required this.controller});

  final ApprovalMasterController controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: ColorTheme.kScaffoldColor,
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return CommonHeaderFooter(
                addBtnText: getCurrentPageName() == StringConst.kTemplateAssignment
                    ? StringConst.kAssignBtnTxt
                    : getCurrentPageName() == StringConst.kApprovalTemplate
                        ? StringConst.kAddBtnTxt
                        : null,
                filterData: controller.setDefaultData.filterData,
                showFilterInHeader: getCurrentPageName() == StringConst.kApprovals ? true : false,
                onFilterInHeaderChange: () {
                  controller.getList();
                },
                setDefaultData: controller.setDefaultData,
                title: controller.formName.value,
                hasSearch: true,
                onSearch: (p0) async {
                  controller.searchText.value = p0;
                  await controller.getList();
                  controller.searchText.value = '';
                },
                onTapFilter: getCurrentPageName() == StringConst.kApprovalTemplate
                    ? null
                    : () async {
                        controller.setFilterData();
                        await CustomDialogs().customFilterDialogs(
                            context: context,
                            widget: FilterForm(
                              title: "Filter",
                              btnName: "Apply",
                              setDefaultData: controller.setDefaultData,
                              onFilterApply: () {
                                controller.getList();
                              },
                              onResetFilter: () {
                                controller.setFilterData();
                              },
                            ));
                      },
                onTapAddNew: (controller.isAddButtonVisible.value && getCurrentPageName() != StringConst.kApprovals)
                    ? () async {
                        controller.setFormData();
                        await CustomDialogs().customFilterDialogs(context: context, widget: const ApprovalMasterForm());
                      }
                    : null,
                txtSearchController: controller.searchController,
                child: Obx(() {
                  return CommonDataTableWidget(
                    onTapDocument: (id, projectid, documentMap) async {
                      await controller.getMasterFormData(parentId: id, pagename: getCurrentPageName());
                      await CustomDialogs().customPopDialog(child: addDocTemplate(controller: controller, parentId: id, pagename: getCurrentPageName(), projectid: projectid ?? ""));
                      controller.pageName.value = getCurrentPageName();
                      controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                    },
                    isTableEyeButtonVisible: true,
                    inTableEyeButton: (id) async {
                      await controller.getMasterFormData(parentId: id, pagename: "templateassignment", assignedproject: 1);
                      await CustomDialogs().customPopDialog(child: addApprovalTemplate(isDraggable: false, title: "Project Assignment", parentId: id, pagename: "templateassignment", isCrudAvailable: false));
                      controller.pageName.value = getCurrentPageName();
                      controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                    },
                    isLoading: controller.loadingData.value,
                    tableScrollController: controller.tableScrollController,
                    isPageLoading: controller.loadingPaginationData.value,
                    onRefresh: () async {
                      controller.setDefaultData.pageNo.value = 1;
                      await getCurrentPageName() == StringConst.kDashboard ? Get.find<DashBoardController>().getApprovalsList() : controller.getList();
                    },
                    pageName: controller.pageName.value,
                    editDataFun: (id, index) {
                      controller.setFormData(id: id, editeDataIndex: index);
                      CustomDialogs().customFilterDialogs(context: context, widget: const ApprovalMasterForm(title: "Update", btnName: "Update"));
                    },
                    deleteDataFun: (id, index) {
                      controller.deleteData({
                        "_id": id,
                      });
                    },
                    field3title: getCurrentPageName() == "approvaltemplate" ? "Manage" : "Customize",
                    field3: controller.pageName.value == 'approvaltemplate'
                        ? (id, parentNameString) async {
                            await controller.getMasterFormData(parentId: id, pagename: getCurrentPageName());
                            await CustomDialogs().customPopDialog(child: addApprovalTemplate(title: "Manage", subTitle: parentNameString ?? "", parentId: id, pagename: getCurrentPageName(), parentNameString: parentNameString ?? ""));
                            controller.pageName.value = getCurrentPageName();
                            controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                          }
                        : controller.pageName.value == 'templateassignment'
                            ? (id, parentNameString) async {
                                await controller.getMasterFormData(parentId: id, pagename: getCurrentPageName());
                                await CustomDialogs().customPopDialog(child: addApprovalTemplate(title: "Customize Template", parentId: id, pagename: getCurrentPageName(), parentNameString: parentNameString ?? "", isHeaderVisible: true));
                                controller.pageName.value = getCurrentPageName();
                                controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                              }
                            : null,
                    field4title: getCurrentPageName() == "approvaltemplate" ? "View" : "View",
                    field4: controller.pageName.value == 'approvaltemplate'
                        ? (id, parentNameString, index) async {
                            await controller.getMasterFormData(parentId: id, pagename: getCurrentPageName());
                            await CustomDialogs().customPopDialog(
                                child: addApprovalTemplate(isDraggable: false, title: "Manage", subTitle: parentNameString ?? "", parentId: id, parentIndex: index, pagename: getCurrentPageName(), isCrudAvailable: false, isParentFormVisible: true));
                            controller.pageName.value = getCurrentPageName();
                            controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                          }
                        : controller.pageName.value == 'templateassignment'
                            ? (id, parentNameString, index) async {
                                await controller.getMasterFormData(parentId: id, pagename: getCurrentPageName());
                                await CustomDialogs()
                                    .customPopDialog(child: addApprovalTemplate(isDraggable: false, title: "Customize Template", parentId: id, parentIndex: index, pagename: getCurrentPageName(), isCrudAvailable: false, isHeaderVisible: true));
                                controller.pageName.value = getCurrentPageName();
                                controller.dialogBoxData.value = ApprovalJson.designationFormFields(controller.pageName.value);
                              }
                            : null,
                    inTableAddButton: (id, parentNameString) async {
                      controller.setMasterFormData(parentId: id, page: parentNameString == 'Multi Project'  ? 'multiprojectassign' : 'projectassign', parentNameString: parentNameString);
                      await CustomDialogs().customFilterDialogs(context: context, widget: ApprovalMasterForm(isMasterForm: true, pagename: id == '664c6d3e4c6c893567bfd3a8' ? 'multiprojectassign' : 'projectassign'));
                      controller.dialogBoxData.value = ApprovalJson.designationFormFields(getCurrentPageName());
                    },
                    onPageChange: (pageNo, pageLimit) {
                      controller.searchText.value = controller.searchController.text;
                      controller.setDefaultData.pageNo.value = pageNo;
                      controller.setDefaultData.pageLimit = pageLimit;
                      getCurrentPageName() == StringConst.kDashboard ? Get.find<DashBoardController>().getApprovalsList() : controller.getList();
                    },
                    onSort: (sortFieldName) {
                      if (controller.setDefaultData.sortData.containsKey(sortFieldName)) {
                        controller.setDefaultData.sortData[sortFieldName] = controller.setDefaultData.sortData[sortFieldName] == 1 ? -1 : 1;
                      } else {
                        controller.setDefaultData.sortData.clear();
                        controller.setDefaultData.sortData[sortFieldName] = 1;
                      }
                      getCurrentPageName() == StringConst.kDashboard ? Get.find<DashBoardController>().getApprovalsList() : controller.getList();
                    },
                    handleGridChange: (index, field, type, value, masterfieldname, name) {
                      controller.handleGridChange(type: type, field: field, index: index, value: value);
                    },
                    setDefaultData: controller.setDefaultData,
                    data: controller.setDefaultData.data.value,
                    fieldOrder: controller.setDefaultData.fieldOrder.value,
                  );
                }),
              );
            },
          )),
    );
  }
}

Widget addApprovalTemplate({
  required String parentId,
  int parentIndex = 0,
  String parentNameString = "",
  required String pagename,
  bool isCrudAvailable = true,
  bool isHeaderVisible = false,
  bool isParentFormVisible = false,
  bool isDraggable = true,
  String title = "",
  String subTitle = "",
}) {
  ApprovalMasterController controller = Get.find<ApprovalMasterController>();
  return SizedBox(
    width: 1200,
    child: ResponsiveBuilder(builder: (context, sizeInformation) {
      Widget approvalMasterDialog(BuildContext context) {
        devPrint("856426451321356651    ${controller.setDefaultData.masterData}");
        return SizedBox(
          width: 1200,
          child: Column(
            children: [
              Container(
                height: 85,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ColorTheme.kBorderColor,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    TextWidget(
                      text: title,
                      fontWeight: FontWeight.w500,
                      color: ColorTheme.kPrimaryColor,
                      fontSize: 18,
                    ),
                    if (subTitle.isNotNullOrEmpty) ...[
                      const Icon(Icons.keyboard_arrow_right_rounded),
                      Expanded(
                        child: TextWidget(
                          text: subTitle,
                          fontWeight: FontWeight.w500,
                          color: ColorTheme.kPrimaryColor,
                          textOverflow: TextOverflow.ellipsis,
                          fontSize: 18,
                        ),
                      )
                    ],
                    if (subTitle.isNullOrEmpty) const Spacer(),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ColorTheme.kBackGroundGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.clear,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              if ((controller.setDefaultData.masterData[pagename]).toString().isNullOrEmpty)
                const NoDataFoundScreen()
              else ...[
                if (isHeaderVisible) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: headerColumn(title: "Template Name", value: controller.setDefaultData.masterData[pagename][0]?['approvaltemplate'] ?? "")),
                      Expanded(child: headerColumn(title: "Project", value: controller.setDefaultData.masterData[pagename][0]?['project'] ?? "")),
                      Expanded(
                        child: headerColumn(
                          title: "Buildings",
                          value: controller.setDefaultData.masterData[pagename][0]['building'].map((building) => building['building'].toString()).join(", "),
                        ),
                      ),
                    ],
                  ).paddingOnly(left: 28, right: 24, top: 12),
                ],
                Row(
                  children: [
                    const Expanded(
                      child: TextWidget(
                        text: "Approvals",
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.kPrimaryColor,
                        textOverflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      ),
                    ),
                    if (isParentFormVisible) ...[
                      Visibility(
                        visible: sizeInformation.isMobile,
                        child: CustomButton(
                          onTap: () async {
                            controller.setFormData(id: parentId, editeDataIndex: parentIndex);
                            CustomDialogs().customFilterDialogs(context: context, widget: const ApprovalMasterForm(title: "Update", btnName: "Update"));
                          },
                          width: 50,
                          fontSize: 14,
                          borderRadius: 4,
                          height: 50,
                          widget: const Icon(
                            Icons.edit,
                            color: ColorTheme.kWhite,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: IISMethods().hasAddRight(alias: getCurrentPageName()) && !sizeInformation.isMobile,
                        child: CustomButton(
                          onTap: () async {
                            controller.setFormData(id: parentId, editeDataIndex: parentIndex);
                            Get.back();
                            await CustomDialogs().customFilterDialogs(context: context, widget: const ApprovalMasterForm(title: "Update", btnName: "Update"));
                            controller.getMasterFormData(parentId: parentId, pagename: "approvaltemplate");
                          },
                          width: 100,
                          fontSize: 14,
                          borderRadius: 4,
                          height: 40,
                          widget: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 16,
                                color: ColorTheme.kWhite,
                              ).paddingOnly(right: 16),
                              const TextWidget(
                                text: 'Edit',
                                fontSize: 13,
                                fontWeight: FontTheme.notoRegular,
                                color: ColorTheme.kWhite,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (isCrudAvailable) ...[
                      Visibility(
                        visible: sizeInformation.isMobile,
                        child: CustomButton(
                          onTap: () async {
                            controller.setMasterFormData(parentId: parentId, page: "addnewapproval", parentNameString: parentNameString);
                            CustomDialogs().customFilterDialogs(
                              context: context,
                              widget: const ApprovalMasterForm(
                                pagename: "addnewapproval",
                                title: "Add",
                                btnName: "Save",
                                isMasterForm: true,
                              ),
                            );
                          },
                          width: 50,
                          fontSize: 14,
                          borderRadius: 4,
                          height: 50,
                          widget: const Icon(
                            Icons.add,
                            color: ColorTheme.kWhite,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: IISMethods().hasAddRight(alias: getCurrentPageName()) && !sizeInformation.isMobile,
                        child: CustomButton(
                          onTap: () async {
                            devPrint("controller.setDefaultData.masterData[pagename][0]?['name'] ");
                            devPrint(controller.setDefaultData.masterData[pagename][0]?['name']);
                            controller.setMasterFormData(parentId: parentId, page: "addnewapproval", parentNameString: parentNameString);
                            CustomDialogs().customFilterDialogs(
                              context: context,
                              widget: const ApprovalMasterForm(
                                pagename: "addnewapproval",
                                btnName: "Save",
                                isMasterForm: true,
                              ),
                            );
                          },
                          width: 135,
                          fontSize: 14,
                          borderRadius: 4,
                          height: 40,
                          widget: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: ColorTheme.kWhite,
                              ).paddingOnly(right: 8),
                              TextWidget(
                                text: 'Add New Approval'.toUpperCase(),
                                fontSize: 13,
                                fontWeight: FontTheme.notoRegular,
                                color: ColorTheme.kWhite,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ).paddingOnly(left: 28, right: 24, top: 12),
                if (!isDraggable)
                  Expanded(
                      child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor)),
                    child: Column(
                      children: [
                        Expanded(
                          child: Obx(() {
                            RxList<Map<String, dynamic>> data = (getCurrentPageName() == StringConst.kApprovalTemplate && pagename == "templateassignment")
                                ? List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename] ?? []).obs
                                : List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename][0]['approvals'] ?? []).obs;
                            return CommonDataTableWidget(
                              pageName: getCurrentPageName(),
                              showPagination: false,
                              fieldOrder: controller.setDefaultData.masterFieldOrder.value,
                              data: data,
                              tableScrollController: controller.tableScrollController,
                              pageField: pagename,
                              deleteDataFun: isCrudAvailable
                                  ? (id, index) {
                                      var childKey = (getCurrentPageName() == StringConst.kApprovals || getCurrentPageName() == StringConst.kDashboard) ? "documentid" : "approvalid";
                                      controller.deleteMasterData(
                                        reqData: {
                                          childKey: id,
                                          "_id": parentId,
                                        },
                                        pageName: pagename,
                                      );
                                    }
                                  : null,
                              width: sizeInformation.isMobile ? MediaQuery.sizeOf(context).width - 66 : 1133,
                              setDefaultData: controller.setDefaultData,
                            );
                          }),
                        )
                      ],
                    ),
                  ))
                else
                  Expanded(
                    child: Builder(builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: ColorTheme.kBorderColor,
                          )),
                          child: Scrollbar(
                            interactive: true,
                            thumbVisibility: true,
                            scrollbarOrientation: ScrollbarOrientation.bottom,
                            controller: controller.horizontalController,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              controller: controller.horizontalController,
                              child: Column(
                                children: [
                                  Container(
                                    width: 1152,
                                    color: ColorTheme.kTableHeader,
                                    padding: const EdgeInsets.only(left: 32.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...List.generate(controller.setDefaultData.masterFieldOrder.length, (innerIndex) {
                                          var field = controller.setDefaultData.masterFieldOrder;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                                width: ((controller.setDefaultData.masterFieldOrder[innerIndex]['tblsize'] ?? 20) * 10),
                                                child: TextWidget(
                                                  text: (field[innerIndex]['text'] ?? '').toUpperCase(),
                                                  fontSize: 14,
                                                  color: ColorTheme.kBlack,
                                                  fontWeight: FontTheme.notoMedium,
                                                )),
                                          );
                                        })
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Obx(() {
                                      RxList<Map<String, dynamic>> data = (getCurrentPageName() == StringConst.kApprovalTemplate && pagename == "templateassignment")
                                          ? List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename] ?? []).obs
                                          : List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename][0]['approvals'] ?? []).obs;
                                      int oldItemIndex = 0;
                                      int newItemIndex = 0;
                                      return SizedBox(
                                        width: 1152,
                                        child: ReorderableList(
                                          onReorder: (draggedItem, newPosition) {
                                            devPrint('onReorder');
                                            oldItemIndex = (draggedItem as ValueKey).value;
                                            newItemIndex = (newPosition as ValueKey).value;
                                            devPrint('$oldItemIndex--->$newItemIndex');
                                            // Map<String, dynamic> item = data[oldItemIndex];
                                            // data.removeAt(oldItemIndex);
                                            // data.insert(newItemIndex, item);
                                            // if (getCurrentPageName() == StringConst.kApprovalTemplate && pagename == "templateassignment") {
                                            //   controller.setDefaultData.masterData[pagename] = List<Map<String, dynamic>>.from(data);
                                            // } else {
                                            //   var url = '${Config.weburl}approvaltemplate/approvalupdate';
                                            //   controller.setDefaultData.masterData[pagename][0]['approvals'] = List<Map<String, dynamic>>.from(data);
                                            //   IISMethods().updateData(
                                            //     url: url,
                                            //     reqBody: {
                                            //       '_id': parentId,
                                            //       'approvals': data,
                                            //     },
                                            //     userAction: 'update${controller.pageName}',
                                            //     pageName: controller.pageName.value,
                                            //   );
                                            // }

                                            return true;
                                          },
                                          onReorderDone: (draggedItem) {
                                            devPrint('onReorderDone');
                                            devPrint('$oldItemIndex--->$newItemIndex');
                                            Map<String, dynamic> item = data[oldItemIndex];
                                            data.removeAt(oldItemIndex);
                                            data.insert(newItemIndex, item);
                                            if (getCurrentPageName() == StringConst.kApprovalTemplate && pagename == "templateassignment") {
                                              controller.setDefaultData.masterData[pagename] = List<Map<String, dynamic>>.from(data);
                                            } else {
                                              var url = getCurrentPageName() == StringConst.kApprovalTemplate ? '${Config.weburl}approvaltemplate/approvalupdate' : '${Config.weburl}templateassignment/approvalupdate';
                                              controller.setDefaultData.masterData[pagename][0]['approvals'] = List<Map<String, dynamic>>.from(data);
                                              IISMethods().updateData(
                                                url: url,
                                                reqBody: {
                                                  '_id': parentId,
                                                  'approvals': data.value,
                                                },
                                                userAction: 'update${controller.pageName}',
                                                pageName: controller.pageName.value,
                                              );
                                            }
                                          },
                                          child: CustomScrollView(
                                            slivers: [
                                              ///not remove this code
                                              // SliverPadding(
                                              //     padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                                              //     sliver: SliverList(
                                              //       delegate: SliverChildBuilderDelegate(
                                              //             (BuildContext context, int index) {
                                              //           var res = widget.setDefaultData["newFieldOrder"].where((e) => e['freeze'] == 0).toList()[index];
                                              //           return DragItem(
                                              //             data: res,
                                              //             changeValue: (v) async {
                                              //               await widget.handleGridSwitches(v, res[index]["field"]!);
                                              //               setState(() {});
                                              //             },
                                              //             isFirst: index == 0,
                                              //             isLast: index == widget.setDefaultData["newFieldOrder"].where((e) => e['freeze'] == 0).toList().length - 1,
                                              //           );
                                              //         },
                                              //         childCount: widget.setDefaultData["newFieldOrder"].where((e) => e['freeze'] == 0).length,
                                              //       ),
                                              //     )),
                                              SliverPadding(
                                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                                                  sliver: SliverList(
                                                    delegate: SliverChildBuilderDelegate(
                                                      (BuildContext context, int index) {
                                                        return ReorderableItem(
                                                          key: ValueKey(index),
                                                          childBuilder: (context, state) => Container(
                                                            color: ColorTheme.kWhite,
                                                            child: Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                                              ReorderableListener(
                                                                key: ValueKey(index),
                                                                child: const Icon(
                                                                  Icons.drag_indicator_rounded,
                                                                  color: ColorTheme.kGrey,
                                                                ),
                                                              ),
                                                              ...List.generate(
                                                                controller.setDefaultData.masterFieldOrder.length,
                                                                (innerIndex) {
                                                                  String fieldName = controller.setDefaultData.masterFieldOrder[innerIndex]['field'];
                                                                  String fieldValue = data[index][fieldName] ?? "";
                                                                  bool isDeleteVisible = true;
                                                                  UserRight pageRights = UserRight();
                                                                  pageRights = IISMethods().getPageRights(alias: getCurrentPageName() ?? '') ?? UserRight();
                                                                  isDeleteVisible = pageRights.alldelright == 1 || (pageRights.selfdelright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid));
                                                                  if (controller.setDefaultData.masterFieldOrder[innerIndex]['type'] == 'delete') {
                                                                    return Padding(
                                                                      padding: const EdgeInsets.all(8.0),
                                                                      child: Wrap(
                                                                        children: [
                                                                          if (isDeleteVisible)
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                await Get.dialog(CustomDialogs.alertDialog(
                                                                                    message: 'Are you sure want to delete?',
                                                                                    onNo: () {
                                                                                      Get.back();
                                                                                    },
                                                                                    onYes: () {
                                                                                      var childKey = (getCurrentPageName() == StringConst.kApprovals || getCurrentPageName() == StringConst.kDashboard) ? "documentid" : "approvalid";
                                                                                      controller.deleteMasterData(
                                                                                        reqData: {
                                                                                          childKey: data[index]['_id'],
                                                                                          "_id": parentId,
                                                                                        },
                                                                                        pageName: pagename,
                                                                                      );
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
                                                                      ),
                                                                    );
                                                                  }

                                                                  return Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: SizedBox(
                                                                        width: ((controller.setDefaultData.masterFieldOrder[innerIndex]['tblsize'] ?? 20) * 10),
                                                                        child: TextWidget(
                                                                          text: fieldValue.toDateFormat(),
                                                                          fontSize: 14,
                                                                          fontWeight: FontTheme.notoRegular,
                                                                        )),
                                                                  );
                                                                },
                                                              ),
                                                            ]),
                                                          ),
                                                        );
                                                      },
                                                      childCount: data.length,
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      );
                                      // return SizedBox(
                                      //   width: 1152,
                                      //   child: DragAndDropLists(
                                      //     itemDragOnLongPress: true,
                                      //     itemDragHandle: const DragHandle(
                                      //       onLeft: true,
                                      //       child: Icon(
                                      //         Icons.drag_indicator_rounded,
                                      //         color: ColorTheme.kGrey,
                                      //       ),
                                      //     ),
                                      //     children: [
                                      //       DragAndDropList(
                                      //         children: List.generate(
                                      //           data.length,
                                      //           (index) => DragAndDropItem(
                                      //             child: Container(
                                      //               color: ColorTheme.kWhite,
                                      //               child: Row(key: ValueKey(index), mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                                      //                 const SizedBox(
                                      //                   width: 32,
                                      //                 ),
                                      //                 ...List.generate(
                                      //                   controller.setDefaultData.masterFieldOrder.length,
                                      //                   (innerIndex) {
                                      //                     String fieldName = controller.setDefaultData.masterFieldOrder[innerIndex]['field'];
                                      //                     String fieldValue = data[index][fieldName] ?? "";
                                      //                     bool isDeleteVisible = true;
                                      //                     UserRight pageRights = UserRight();
                                      //                     pageRights = IISMethods().getPageRights(alias: getCurrentPageName() ?? '') ?? UserRight();
                                      //                     isDeleteVisible = pageRights.alldelright == 1 || (pageRights.selfdelright == 1 && (data[index]['recordinfo']?['entryuid'] == Settings.uid));
                                      //                     if (controller.setDefaultData.masterFieldOrder[innerIndex]['type'] == 'delete') {
                                      //                       return Padding(
                                      //                         padding: const EdgeInsets.all(8.0),
                                      //                         child: Wrap(
                                      //                           children: [
                                      //                             if (isDeleteVisible)
                                      //                               InkWell(
                                      //                                 onTap: () async {
                                      //                                   await Get.dialog(CustomDialogs.alertDialog(
                                      //                                       message: 'Are you sure want to delete?',
                                      //                                       onNo: () {
                                      //                                         Get.back();
                                      //                                       },
                                      //                                       onYes: () {
                                      //                                         var childKey = (getCurrentPageName() == StringConst.kApprovals || getCurrentPageName() == StringConst.kDashboard)
                                      //                                             ? "documentid"
                                      //                                             : "approvalid";
                                      //                                         controller.deleteMasterData(
                                      //                                           reqData: {
                                      //                                             childKey: data[index]['_id'],
                                      //                                             "_id": parentId,
                                      //                                           },
                                      //                                           pageName: pagename,
                                      //                                         );
                                      //                                       }));
                                      //                                 },
                                      //                                 splashColor: ColorTheme.kWhite,
                                      //                                 hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                                      //                                 child: Container(
                                      //                                   width: 36,
                                      //                                   height: 36,
                                      //                                   decoration: BoxDecoration(
                                      //                                       color: ColorTheme.kWhite.withOpacity(0.1),
                                      //                                       borderRadius: BorderRadius.circular(4),
                                      //                                       border: Border.all(color: ColorTheme.kCherryRed)),
                                      //                                   child: const Center(child: Icon(Icons.delete_outline_rounded, color: ColorTheme.kCherryRed)),
                                      //                                 ),
                                      //                               ),
                                      //                           ],
                                      //                         ),
                                      //                       );
                                      //                     }
                                      //
                                      //                     return Padding(
                                      //                       padding: const EdgeInsets.all(8.0),
                                      //                       child: SizedBox(
                                      //                           width: ((controller.setDefaultData.masterFieldOrder[innerIndex]['tblsize'] ?? 20) * 10),
                                      //                           child: TextWidget(
                                      //                             text: fieldValue.toDateFormat(),
                                      //                             fontSize: 14,
                                      //                             fontWeight: FontTheme.notoRegular,
                                      //                           )),
                                      //                     );
                                      //                   },
                                      //                 ),
                                      //               ]),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       )
                                      //     ],
                                      //     onItemReorder: (oldItemIndex, oldListIndex, newItemIndex, newListIndex) async {
                                      //       Map<String, dynamic> item = data[oldItemIndex];
                                      //       data.removeAt(oldItemIndex);
                                      //       data.insert(newItemIndex, item);
                                      //       if (getCurrentPageName() == StringConst.kApprovalTemplate && pagename == "templateassignment") {
                                      //         controller.setDefaultData.masterData[pagename] = List<Map<String, dynamic>>.from(data);
                                      //       } else {
                                      //         var url = '${Config.weburl}approvaltemplate/approvalupdate';
                                      //         controller.setDefaultData.masterData[pagename][0]['approvals'] = List<Map<String, dynamic>>.from(data);
                                      //         var resBody = await IISMethods().updateData(
                                      //           url: url,
                                      //           reqBody: {
                                      //             '_id': parentId,
                                      //             'approvals': data,
                                      //           },
                                      //           userAction: 'update${controller.pageName}',
                                      //           pageName: controller.pageName.value,
                                      //         );
                                      //       }
                                      //     },
                                      //     onListReorder: (oldListIndex, newListIndex) {},
                                      //   ),
                                      // );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  )
              ],
            ],
          ),
        );
      }

      if (sizeInformation.isMobile) {
        return Container(
          color: ColorTheme.kWhite,
          child: approvalMasterDialog(context),
        );
      }

      return Dialog(
        backgroundColor: ColorTheme.kWhite,
        surfaceTintColor: ColorTheme.kWhite,
        alignment: Alignment.centerRight,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: 1200,
          child: approvalMasterDialog(context),
        ),
      );
    }),
  );
}

// Widget draggableRowText({required String text}) {
//   return;
// }

Widget addDocTemplate({
  required ApprovalMasterController controller,
  required String parentId,
  String parentNameString = "",
  String projectid = "",
  required String pagename,
}) {
  devPrint("78965616745     ${(controller.setDefaultData.masterData[pagename]?[0]).toString().isNullOrEmpty}");
  return SizedBox(
    width: 1200,
    child: ResponsiveBuilder(builder: (context, sizeInformation) {
      Widget communityForm(BuildContext context) {
        return Column(
          children: [
            Container(
              height: 85,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ColorTheme.kBorderColor,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      text: "Documents",
                      fontWeight: FontWeight.w500,
                      color: ColorTheme.kPrimaryColor,
                      fontSize: 18,
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: ColorTheme.kBackGroundGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.clear,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            if ((controller.setDefaultData.masterData[pagename]?[0]).toString().isNullOrEmpty)
              const NoDataFoundScreen()
            else ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: headerColumn(title: "Construction Stage", value: controller.setDefaultData.masterData[pagename][0]?['constructionstage'] ?? "")),
                      Expanded(child: headerColumn(title: "Approval", value: controller.setDefaultData.masterData[pagename][0]?['approvalcategory'] ?? "")),
                      Expanded(child: headerColumn(title: "Sub Approval", value: controller.setDefaultData.masterData[pagename][0]?['subapprovalcategory'] ?? "")),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: headerColumn(title: "Authority", value: controller.setDefaultData.masterData[pagename][0]?['governmentauthority'] ?? "")),
                      Expanded(flex: 2, child: headerColumn(title: "Frequency", value: controller.setDefaultData.masterData[pagename][0]?['frequencyduration'] ?? "")),
                    ],
                  ),
                ],
              ).paddingOnly(left: 28, right: 24, top: 12),
              const Divider(indent: 24, endIndent: 24),
              Row(
                children: [
                  const Expanded(
                    child: TextWidget(
                      text: "Current Documents",
                      fontWeight: FontWeight.w500,
                      color: ColorTheme.kPrimaryColor,
                      textOverflow: TextOverflow.ellipsis,
                      fontSize: 18,
                    ),
                  ),
                  Visibility(
                    visible: sizeInformation.isMobile,
                    child: CustomButton(
                      onTap: () async {
                        controller.setMasterFormData(parentId: parentId, page: "uploaddocument", parentNameString: parentNameString, projectid: projectid);
                        await CustomDialogs().customFilterDialogs(
                          context: context,
                          widget: ApprovalMasterForm(
                            pagename: "uploaddocument",
                            btnName: "Add",
                            isMasterForm: true,
                            frequencydays: controller.setDefaultData.masterData[pagename][0]?['frequencydays'] ?? "",
                          ),
                        );
                        getCurrentPageName() == StringConst.kDashboard ? Get.find<DashBoardController>().getApprovalsList() : controller.getList();
                      },
                      width: 50,
                      fontSize: 14,
                      borderRadius: 4,
                      height: 50,
                      widget: const Icon(
                        Icons.add,
                        color: ColorTheme.kWhite,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: IISMethods().hasAddRight(alias: getCurrentPageName()) && !sizeInformation.isMobile,
                    child: CustomButton(
                      onTap: () async {
                        controller.setMasterFormData(parentId: parentId, page: "uploaddocument", parentNameString: parentNameString, projectid: projectid);
                        await CustomDialogs().customFilterDialogs(
                          context: context,
                          widget: ApprovalMasterForm(
                            pagename: "uploaddocument",
                            btnName: "Add",
                            isMasterForm: true,
                            frequencydays: controller.setDefaultData.masterData[pagename][0]?['frequencydays'] ?? "",
                          ),
                        );
                        getCurrentPageName() == StringConst.kDashboard ? Get.find<DashBoardController>().getApprovalsList() : controller.getList();
                      },
                      width: 135,
                      fontSize: 14,
                      borderRadius: 4,
                      height: 40,
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: ColorTheme.kWhite,
                          ).paddingOnly(right: 8),
                          const TextWidget(
                            text: 'Upload New',
                            fontSize: 13,
                            fontWeight: FontTheme.notoRegular,
                            color: ColorTheme.kWhite,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).paddingOnly(left: 28, right: 24, top: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(() {
                          RxList<Map<String, dynamic>> data = (getCurrentPageName() == StringConst.kApprovals || getCurrentPageName() == StringConst.kDashboard)
                              ? List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename][0]['documents'] ?? []).obs
                              : List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename][0]['approvals'] ?? []).obs;
                          return CommonDataTableWidget(
                            pageName: getCurrentPageName(),
                            showPagination: false,
                            onTapDocument: (id, projectid, documentMap) {
                              documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(documentMap ?? {})));
                            },
                            fieldOrder: controller.setDefaultData.masterFieldOrder.value,
                            data: data,
                            tableScrollController: controller.tableScrollController,
                            pageField: pagename,
                            deleteDataFun: (id, index) async {
                              var childKey = (getCurrentPageName() == StringConst.kApprovals || getCurrentPageName() == StringConst.kDashboard) ? "documentid" : "approvalid";
                              devPrint("854496541645");
                              devPrint(data[0]["latest"]);
                              await controller.deleteMasterData(
                                reqData: {
                                  childKey: id,
                                  "_id": parentId,
                                },
                                pageName: pagename,
                              );
                              getCurrentPageName() == StringConst.kDashboard ? Get.find<DashBoardController>().getApprovalsList() : controller.getList();
                            },
                            width: sizeInformation.isMobile ? MediaQuery.sizeOf(context).width - 66 : 1133,
                            setDefaultData: controller.setDefaultData,
                          );
                        }),
                      )
                    ],
                  ),
                ),
              )
            ],
          ],
        );
      }

      if (sizeInformation.isMobile) {
        return Container(
          color: ColorTheme.kWhite,
          child: communityForm(context),
        );
      }

      return Dialog(
        backgroundColor: ColorTheme.kWhite,
        surfaceTintColor: ColorTheme.kWhite,
        alignment: Alignment.centerRight,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
        insetPadding: EdgeInsets.zero,
        child: SizedBox(
          width: 1200,
          child: communityForm(context),
        ),
      );
    }),
  );
}

Widget headerColumn({
  required String title,
  required String value,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 2),
      TextWidget(
        text: title.toString().toDateFormat().toUpperCase(),
        color: ColorTheme.kBlack,
        fontWeight: FontTheme.notoSemiBold,
        textOverflow: TextOverflow.visible,
        fontSize: 12,
      ),
      TextWidget(
        text: value.toString().toUpperCase(),
        color: ColorTheme.kPrimaryColor,
        textOverflow: TextOverflow.visible,
        fontWeight: FontTheme.notoRegular,
        fontSize: 12,
      ),
    ],
  ).paddingOnly(bottom: 4, right: 8);
}

final _deleteFormKey = GlobalKey<FormState>();

Widget approvalDeleteDialog({required TextEditingController deleteController, required Function() onTap}) {
  return Dialog(
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
                              controller: TextEditingController(),
                              isCopyPasteEnable: false,
                              textCapitalization: TextCapitalization.sentences,
                              autofocus: true,
                              inputFormatters: [
                                UpperCaseFormatter(),
                              ],
                              contentPadding: const EdgeInsets.all(12),
                              onFieldSubmitted: (v) async {
                                if (_deleteFormKey.currentState!.validate()) {
                                  onTap;
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
                      if ((_deleteFormKey.currentState!.validate()) && (onTap != null)) {
                        onTap;
                      }
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
  );
}
