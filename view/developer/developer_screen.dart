import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/forms/developer_form.dart';
import 'package:prestige_prenew_frontend/controller/developer/developer_controller.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config/Import-Export/excel_export.dart';
import '../../config/Import-Export/excel_import_func.dart';
import '../../config/dev/dev_helper.dart';
import '../../config/iis_method.dart';
import '../../routes/route_name.dart';
import '../../style/string_const.dart';
import '../CommonWidgets/common_header_footer.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key, required this.controller});

  final DeveloperController controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: ColorTheme.kScaffoldColor,
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              return CommonHeaderFooter(
                filterData: controller.setDefaultData.filterData,
                showFilterInHeader: false,
                onFilterInHeaderChange: () {},
                title: controller.formName.value,
                hasSearch: true,
                onSearch: (p0) async {
                  controller.searchText.value = p0;
                  await controller.getList();
                  controller.searchText.value = '';
                },
                onTapAddNew: controller.isAddButtonVisible.value
                    ? () async {
                        controller.setFormData();
                        await CustomDialogs().customFilterDialogs(context: context, widget: const DeveloperForm());
                      }
                    : null,
                actions: [
                  if (controller.pageName.value == "user" && IISMethods().hasImportExportRight(alias: getCurrentPageName()))
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
                                      filter: controller.setDefaultData.filterData,setDefaultData: controller.setDefaultData);
                                },
                                btnName: StringConst.kExportDataBtnTxt,
                              ),
                            if (IISMethods().hasImportRight(alias: getCurrentPageName()))
                              CommonDataTableWidget.menuOption(
                                onTap: () async {
                                  await ExcelImport()
                                      .showPickFileDialog(dialogBoxData: controller.dialogBoxData, formName: controller.dialogBoxData['formname'] ?? "")
                                      .then((value) => controller.getList());
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
                txtSearchController: controller.searchController,
                child: Obx(() {
                  return CommonDataTableWidget(
                    isLoading: controller.loadingData.value,
                    tableScrollController: controller.tableScrollController,
                    isPageLoading: controller.loadingPaginationData.value,
                    onRefresh: () async {
                      controller.setDefaultData.filterData.value = {};
                      controller.setDefaultData.pageNo.value = 1;
                      controller.searchText.value = "";
                      controller.searchController.text = "";
                      await controller.getList();
                    },
                    pageName: controller.pageName.value,
                    editDataFun: (id, index) {
                      controller.setFormData(id: id, editeDataIndex: index);
                      CustomDialogs().customFilterDialogs(context: context, widget: const DeveloperForm(title: "Update", btnName: "Update"));
                    },
                    deleteDataFun: (id, index) {
                      controller.deleteData({
                        "_id": id,
                      });
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
                      devPrint("type  $type\nfield  $field\nindex $index\nvalue $value\n1248945431\n");
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
