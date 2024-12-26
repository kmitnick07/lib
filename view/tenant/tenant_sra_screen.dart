import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/customs/text_widget.dart';
import '../../components/forms/filter_form.dart';
import '../../components/forms/tenent_sra_form.dart';
import '../../components/json/tenants_sra_json.dart';
import '../../config/Import-Export/excel_export.dart';
import '../../config/Import-Export/excel_import_func.dart';
import '../../config/config.dart';
import '../../controller/tenant/tenant_sra_controller.dart';
import '../../routes/route_name.dart';
import '../../style/assets_string.dart';
import '../../style/string_const.dart';
import '../../style/theme_const.dart';
import '../CommonWidgets/common_header_footer.dart';
import '../CommonWidgets/common_table.dart';

class TenantSRAScreen extends StatelessWidget {
  const TenantSRAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: ColorTheme.kScaffoldColor,
          body: ResponsiveBuilder(
            builder: (context, sizingInformation) {
              double width = sizingInformation.isMobile || sizingInformation.isTablet ? MediaQuery.sizeOf(context).width : MediaQuery.sizeOf(context).width - 140;
              return GetBuilder(
                init: Get.put(TenantSRAController()),
                builder: (controller) {
                  return Obx(() {
                    return CommonHeaderFooter(
                      filterData: controller.setDefaultData.filterData,
                      title: controller.formName.value,
                      hasSearch: true,
                      onSearch: (p0) async {
                        controller.searchText.value = p0;
                        await controller.getList();
                        controller.searchText.value = '';
                      },
                      showFilterInHeader: false,
                      setDefaultData: controller.setDefaultData,
                      onFilterInHeaderChange: () {
                        controller.getList();
                        controller.setDefaultData.filterData.removeNullValues();
                        controller.setDefaultData.filterData.refresh();
                      },
                      onTapFilter: () async {
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
                          ),
                        );
                        },
                      onTapAddNew: controller.isAddButtonVisible.value
                          ? () async {
                              controller.setFormData();
                              await CustomDialogs().customFilterDialogs(
                                  context: context,
                                  widget: TenantSRAForm(
                                    pagename: controller.pageName.value,
                                  ));
                              controller.setFilterData();
                              controller.setDefaultData.filterData.removeNullValues();
                              // Get.dialog(
                              //   barrierDismissible: false,
                              //   const TenantSRAForm(),
                              // ).then((value) {});
                            }
                          : null,
                      actions: [
                        if (IISMethods().hasImportExportRight(alias: getCurrentPageName()))
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
                                  if (controller.pageName.value == 'posthandoversra' && IISMethods().hasImportRight(alias: getCurrentPageName()))
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
                      child: CommonDataTableWidget(
                        onRefresh: () async {
                          controller.setDefaultData.filterData.value = {};
                          controller.setDefaultData.pageNo.value = 1;
                          controller.searchText.value = "";
                          controller.searchController.text = "";
                          await controller.setFilterData();
                          await controller.getList();
                        },
                        pageName: controller.pageName.value,
                        pageField: controller.pageName.value,
                        fieldOrder: controller.setDefaultData.fieldOrder.value,
                        data: controller.setDefaultData.data.value,
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
                        isLoading: controller.loadingData.value,
                        setDefaultData: controller.setDefaultData,
                        editDataFun: (id, index) async {
                          controller.setFormData(id: id, editeDataIndex: index);
                          await CustomDialogs().customFilterDialogs(
                              context: context,
                              widget: TenantSRAForm(
                                title: "Edit",
                                btnName: "Update",
                                pagename: controller.pageName.value,
                              ));
                          controller.setFilterData();
                          controller.setDefaultData.filterData.removeNullValues();
                        },
                        deleteDataFun: (id, index) {
                          controller.deleteData({
                            "_id": id,
                          });
                        },
                        field3title: 'Documents',
                        field3: controller.pageName.value == 'tenantproject'
                            ? (id, parentNameString) async {
                                await controller.getMasterFormData(id: id, pagename: "tenantprojectdocument");
                                await CustomDialogs().customPopDialog(child: communityEngagement(controller: controller, parentId: id, pagename: "tenantprojectdocument", id: id));
                                controller.pageName.value = getCurrentPageName();
                                controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                              }
                            : null,
                        field6title: 'Society',
                        field6: controller.pageName.value == 'tenantproject'
                            ? (id) async {
                                await controller.getMasterFormData(id: id, pagename: "society");
                                await CustomDialogs().customPopDialog(child: communityEngagement(controller: controller, parentId: id, pagename: "society"));
                                controller.pageName.value = getCurrentPageName();
                                controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                              }
                            : null,

                        field4title: 'SRA Body',
                        field4: controller.pageName.value == 'tenantproject'
                            ? (id, parentNameString, index) async {
                                await controller.getMasterFormData(id: id, pagename: "srabody");
                                await CustomDialogs().customPopDialog(child: communityEngagement(controller: controller, parentId: id, pagename: "srabody"));
                                controller.pageName.value = getCurrentPageName();
                                controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                              }
                            : null,

                        handleGridChange: (index, field, type, value, masterfieldname, name) {
                          controller.handleGridChange(type: type, field: field, index: index, value: value);
                        },
                        field5title: 'User Assign',
                        field5: controller.pageName.value == 'tenantproject'
                            ? (id,i) async {
                                controller.setDefaultData.masterFormData['tenantprojectid'] = id;
                                controller.setMasterFormData(parentId: id, page: 'managerassign');
                                await controller.setUserInTable(id);
                                controller.setDefaultData.masterFormData.refresh();
                                // controller.setManagerAssignData();
                                controller.setDefaultData.masterFormData['tenantprojectid'] = id;

                                await CustomDialogs().customPopDialog(
                                  child: const SizedBox(
                                    width: 800,
                                    child: TenantSRAForm(
                                      pagename: 'managerassign',
                                      title: "User Assign",
                                      btnName: "Save",
                                      isMasterForm: true,
                                    ),
                                  ),
                                );
                                await Future.delayed(const Duration(milliseconds: 100));
                                controller.pageName.value = getCurrentPageName();
                                controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);

                                controller.setFilterData();
                              }
                            : null,
                        // field7title: 'Payment Configuration',
                        // field7: controller.pageName.value == 'tenantproject'
                        //     ? (id) async {
                        //         controller.setDefaultData.masterFormData['tenantprojectid'] = id;
                        //         controller.setMasterFormData(parentId: id, page: 'paymentconfiguration');
                        //         await controller.setPaymentInTable(id);
                        //         controller.setDefaultData.masterFormData.refresh();
                        //         controller.setDefaultData.masterFormData['tenantprojectid'] = id;
                        //
                        //         await CustomDialogs().customPopDialog(
                        //           child: const SizedBox(
                        //             width: 800,
                        //             child: TenantSRAForm(
                        //               pagename: 'paymentconfiguration',
                        //               title: "Payment Configuration",
                        //               btnName: "Save",
                        //               isMasterForm: true,
                        //             ),
                        //           ),
                        //         );
                        //         await Future.delayed(const Duration(milliseconds: 500));
                        //         controller.pageName.value = getCurrentPageName();
                        //         controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                        //         controller.setFilterData();
                        //       }
                        //     : null,
                        tableScrollController: controller.tableScrollController,
                      ),
                    );
                  });
                },
              );
            },
          )),
    );
  }

  Widget communityEngagement({required TenantSRAController controller, required String parentId, required String pagename, String? id}) {
    if (pagename == "tenantprojectdocument") {
      controller.getFilterDocumentList();
    }
    return SizedBox(
      width: 800,
      child: ResponsiveBuilder(builder: (context, sizeInformation) {
        Widget communityForm(BuildContext context) {
          return Column(
            children: [
              Container(
                height: 100,
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
                    children: [
                      TextWidget(
                        text: pagename == "tenantprojectdocument"
                            ? "Documents"
                            : pagename == "managerassign"
                                ? "User Assign"
                                : pagename == "srabody"
                                    ? 'SRA Body'
                                    : pagename == "society"
                                        ? 'Society'
                                        : "Community Engagement",
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.kPrimaryColor,
                        fontSize: 18,
                      ),
                      if (pagename == "tenantprojectdocument" && !sizeInformation.isMobile)
                        Obx(() {
                          return constrainedBoxWithPadding(
                            width: 300,
                            child: DropDownSearchCustom(
                              focusNode: FocusNode(),
                              canShiftFocus: false,
                              items: List<Map<String, dynamic>>.from(controller.filterDocumentTypeList),
                              isCleanable: true,
                              clickOnCleanBtn: () async {
                                controller.selectedDocumentType = {};
                                await controller.getMasterFormData(id: id, pagename: "tenantprojectdocument");
                              },
                              initValue: controller.selectedDocumentType['label'] != null ? controller.selectedDocumentType : null,
                              hintColor: ColorTheme.kBlack,
                              hintText: 'Select Document Type',
                              isSearchable: true,
                              onChanged: (v) async {
                                controller.selectedDocumentType = v ?? {};
                                await controller.getMasterFormData(id: id, documenttype: v!['documenttype'] ?? "", documenttypeid: v!['documenttypeid'] ?? "", pagename: "tenantprojectdocument");
                                controller.filterDocumentTypeList.refresh();
                              },
                              dropValidator: (Map<String, dynamic>? v) {
                                return null;
                              },
                            ),
                          );
                        }),
                      const Spacer(),
                      Visibility(
                        visible: IISMethods().hasAddRight(alias: getCurrentPageName()) && sizeInformation.isMobile,
                        child: CustomButton(
                          onTap: () async {
                            controller.setMasterFormData(parentId: parentId, page: pagename);
                            devPrint("$pagename   4545124321212");
                            CustomDialogs().customFilterDialogs(
                              context: context,
                              widget: TenantSRAForm(
                                pagename: pagename,
                                title: pagename == "tenantprojectdocument"
                                    ? "Add Documents"
                                    : pagename == "srabody"
                                        ? 'SRA Body'
                                        : pagename == "society"
                                            ? 'Society'
                                            : "Add Community Engagement",
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
                            controller.setMasterFormData(parentId: parentId, page: pagename);
                            devPrint("$pagename   4545124321212");
                            CustomDialogs().customFilterDialogs(
                              context: context,
                              widget: TenantSRAForm(
                                pagename: pagename,
                                title: pagename == "tenantprojectdocument"
                                    ? "Add Documents"
                                    : pagename == "srabody"
                                        ? 'Add SRA Body'
                                        : pagename == "society"
                                            ? 'Add Society'
                                            : "Add Community Engagement",
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
                              const TextWidget(
                                text: 'Add New',
                                fontSize: 13,
                                fontWeight: FontTheme.notoRegular,
                                color: ColorTheme.kWhite,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
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
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(sizeInformation.isMobile? 8: 24),
                  decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(() {
                          RxList<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename] ?? []).obs;
                          return CommonDataTableWidget(
                            pageName: getCurrentPageName(),
                            showPagination: false,
                            fieldOrder: controller.setDefaultData.masterFieldOrder.value,
                            data: data,
                            tableScrollController: controller.tableScrollController,
                            pageField: pagename,
                            handleGridChange: (index, field, type, value, masterfieldname, name) async {
                              data[index][field] = value ? 1 : 0;
                              if (await controller.updateMasterData(reqData: data[index], editeDataIndex: index, pagename: pagename)) {
                                Get.back();
                              }
                            },
                            onTapDocument: (id, name, documentMap) {
                              IISMethods().getDocumentHistory(
                                tenantId: id,
                                documentType: name,
                                pagename: pagename == "society" ? 'Society' : "Tenant Project Document",
                              );
                            },
                            editDataFun: (id, index) {
                              controller.setMasterFormData(parentId: parentId, editeDataIndex: index, id: id, page: pagename);
                              CustomDialogs().customFilterDialogs(
                                context: context,
                                widget: TenantSRAForm(
                                  pagename: pagename,
                                  title: pagename == "tenantprojectdocument"
                                      ? "Edit Documents"
                                      : pagename == "society"
                                          ? 'Edit Society'
                                          : pagename == "srabody"
                                              ? 'Edit SRA Body'
                                              : "Edit Community Engagement",
                                  btnName: "Save",
                                  isMasterForm: true,
                                ),
                              );
                            },
                            deleteDataFun: pagename != "society"
                                ? (id, index) {
                                    controller.deleteMasterData(
                                      reqData: {
                                        "_id": id,
                                        "tenantprojectid": parentId,
                                      },
                                      pageName: pagename,
                                    );
                                  }
                                : null,
                            onSort: (sortFieldName) async {
                              if (controller.setDefaultData.sortData.containsKey(sortFieldName)) {
                                controller.setDefaultData.sortData[sortFieldName] = controller.setDefaultData.sortData[sortFieldName] == 1 ? -1 : 1;
                              } else {
                                controller.setDefaultData.sortData.clear();
                                controller.setDefaultData.sortData[sortFieldName] = 1;
                              }
                              await controller.getMasterFormData(
                                id:parentId,
                                pagename: pagename,
                                sort: controller.setDefaultData.sortData.value,
                              );
                            },
                            width: sizeInformation.isMobile ? MediaQuery.sizeOf(context).width - 33 : 734,
                            setDefaultData: controller.setDefaultData,
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
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
            width: 800,
            child: communityForm(context),
          ),
        );
      }),
    );
  }
}
