import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/row_column_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/controller/master_controller.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../components/customs/custom_common_widgets.dart';
import '../components/customs/text_widget.dart';
import '../components/forms/master_form.dart';
import '../config/Import-Export/excel_export.dart';
import '../config/Import-Export/excel_import_func.dart';
import '../style/assets_string.dart';
import '../style/string_const.dart';

class MasterView extends StatelessWidget {
  const MasterView({super.key, this.pageName});

  final String? pageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.kScaffoldColor,
        body: GetBuilder(
          init: Get.put(MasterController()),
          builder: (controller) {
            return ResponsiveBuilder(builder: (context, sizingInformation) {
              return CommonHeaderFooter(
                  filterData: controller.setDefaultData.filterData,
                  title: controller.formName.value,
                  path: "Masters / ",
                  onTapPath: () => navigateTo(RouteNames.kMastersListScreen),
                  showFilterInHeader: false,
                  onFilterInHeaderChange: () {},
                  hasSearch: true,
                  onSearch: (p0) async {
                    controller.searchText.value = p0;
                    await controller.getList();
                    controller.searchText.value = '';
                  },
                  actions: [
                    if ((getCurrentPageName() == 'pincode' || getCurrentPageName() == 'city' || getCurrentPageName() == 'locality' || getCurrentPageName() == 'committeedesignations') && IISMethods().hasImportExportRight(alias: getCurrentPageName()))
                      Theme(
                        data: Theme.of(Get.context!).copyWith(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: PopupMenuButton(
                          offset: const Offset(-11, 40),
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
                              if (IISMethods().hasExportRight(alias: getCurrentPageName()))
                                CommonDataTableWidget.menuOption(
                                  onTap: () {
                                    ExcelExport().exportData(
                                        dialogBoxData: controller.dialogBoxData,
                                        formName: controller.dialogBoxData['formname'] ?? "",
                                        pageName: controller.dialogBoxData['pagename'],
                                        filter: controller.setDefaultData.filterData,
                                        setDefaultData: controller.setDefaultData);
                                  },
                                  btnName: StringConst.kExportDataBtnTxt,
                                ),
                              if (IISMethods().hasImportRight(alias: getCurrentPageName()))
                                CommonDataTableWidget.menuOption(
                                  onTap: () async {
                                    await ExcelImport().showPickFileDialog(dialogBoxData: controller.dialogBoxData, formName: controller.dialogBoxData['formname'] ?? "").then((value) => controller.getList());
                                  },
                                  btnName: StringConst.kImportDataBtnTxt,
                                ),
                            ];
                          },
                          child: !(sizingInformation.isMobile || sizingInformation.isTablet)
                              ? Container(
                                  width: 135,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: ColorTheme.kBackGroundGrey,
                                  ),
                                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SvgPicture.asset(
                                        AssetsString.kExport,
                                        colorFilter: const ColorFilter.mode(ColorTheme.kBlack, BlendMode.srcIn),
                                      ),
                                      const TextWidget(
                                        text: StringConst.kExportBtnTxt,
                                        fontSize: 13,
                                        fontWeight: FontTheme.notoSemiBold,
                                        color: ColorTheme.kBlack,
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: ColorTheme.kBlack,
                                      ),
                                    ],
                                  ),
                                ).paddingOnly(right: 12)
                              : SvgPicture.asset(
                                  AssetsString.kExport,
                                  // ignore: deprecated_member_use
                                  color: ColorTheme.kWhite,
                                  height: 23,
                                ).paddingOnly(right: 12),
                        ),
                      ),
                  ],
                  onTapAddNew: IISMethods().hasAddRight(alias: controller.pageName.value)
                      ? () async {
                          controller.setFormData();

                          CustomDialogs().customFilterDialogs(context: context, widget: const MasterForm());
                          // Get.dialog(
                          //   barrierDismissible: false,
                          //   const MasterForm(),
                          // ).then((value) {});
                        }
                      : null,
                  txtSearchController: controller.searchController,
                  child: Obx(() {
                    return CommonDataTableWidget(
                      isLoading: controller.loadingData.value || controller.setDefaultData.fieldOrder.isEmpty,
                      isPageLoading: controller.loadingPaginationData.value,
                      tableScrollController: controller.tableScrollController,
                      onRefresh: () async {
                        controller.setDefaultData.pageNo.value = 1;
                        controller.searchText.value = "";
                        controller.searchController.text = "";
                        await controller.getList();
                      },
                      editDataFun: (id, index) {
                        controller.setFormData(id: id, editeDataIndex: index);
                        CustomDialogs().customFilterDialogs(context: context, widget: const MasterForm(title: "Update", btnName: "Update"));
                        // Get.dialog(barrierDismissible: false, const MasterForm(title: "Update", btnName: "Update"));
                      },
                      deleteDataFun: (id, index) {
                        controller.deleteData({
                          "_id": id,
                        });
                      },
                      field4title: getCurrentPageName() == "subapprovalcategory" ? "View" : null,
                      field4: (id, parentNameString, index) async {
                        await CustomDialogs().customPopDialog(child: addApprovalTemplate(title: "View", data: controller.setDefaultData.data[index]));
                      },
                      onPageChange: (pageNo, pageLimit) {
                        controller.searchText.value = controller.searchController.text;
                        controller.setDefaultData.pageNo.value = pageNo;
                        controller.setDefaultData.pageLimit = pageLimit;
                        controller.getList();
                      },
                      onSort: (sortFieldName) {
                        if (controller.setDefaultData.sortData.containsKey(sortFieldName)) {
                          controller.setDefaultData.sortData[sortFieldName] = controller.setDefaultData.sortData[sortFieldName] == 1 ? -1 : 1;
                        } else {
                          controller.setDefaultData.sortData.clear();
                          controller.setDefaultData.sortData[sortFieldName] = 1;
                        }
                        controller.getList();
                      },
                      handleGridChange: (index, field, type, value, masterfieldname, name) {
                        controller.handleGridChange(type: type, field: field, index: index, value: value);
                      },
                      pageName: controller.pageName.value,
                      setDefaultData: controller.setDefaultData,
                      data: controller.setDefaultData.data.value,
                      fieldOrder: controller.setDefaultData.fieldOrder.value,
                    );
                  }));
            });
          },
        ));
  }
}

Widget addApprovalTemplate({
  String title = "",
  required Map<String, dynamic> data,
}) {
  return SizedBox(
    width: 450,
    child: ResponsiveBuilder(builder: (context, sizeInformation) {
      Widget approvalMasterDialog(BuildContext context) {
        return SizedBox(
          width: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: title,
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
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RowColumnWidget(
                    grouptype: sizeInformation.isDesktop ? GroupType.row : GroupType.column,
                    children: [
                      expandedRowColumn(sizeInformation.isDesktop, headerText(title: "Construction Stage", value: data['constructionstage'] ?? "")),
                      expandedRowColumn(sizeInformation.isDesktop, headerText(title: "Approval", value: data['approvalcategory'] ?? "")),
                    ],
                  ),
                  RowColumnWidget(
                    grouptype: sizeInformation.isDesktop ? GroupType.row : GroupType.column,
                    children: [
                      expandedRowColumn(sizeInformation.isDesktop, headerText(title: "Sub Approval", value: data['name'] ?? "")),
                      expandedRowColumn(sizeInformation.isDesktop, headerText(title: "Status", value: (data['status'] ?? "") == 1 ? "Active" : "Inactive")),
                    ],
                  ),
                  RowColumnWidget(
                    grouptype: sizeInformation.isDesktop ? GroupType.row : GroupType.column,
                    children: [
                      expandedRowColumn(sizeInformation.isDesktop, headerText(title: "Frequency", value: data['approvalcategory'] ?? "")),
                    ],
                  ),
                ],
              ).paddingOnly(left: 24, right: 24, top: 12),
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

Widget headerText({
  required String title,
  required String value,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(width: 2),
      TextWidget(
        text: title.toString().toDateFormat(),
        color: ColorTheme.kBlack,
        fontWeight: FontTheme.notoSemiBold,
        textOverflow: TextOverflow.visible,
        fontSize: 14,
      ),
      TextWidget(
        text: value.toString().toDateFormat(),
        color: ColorTheme.kPrimaryColor,
        textOverflow: TextOverflow.visible,
        fontWeight: FontTheme.notoRegular,
        fontSize: 14,
      ),
    ],
  ).paddingOnly(bottom: 12, right: 8);
}
