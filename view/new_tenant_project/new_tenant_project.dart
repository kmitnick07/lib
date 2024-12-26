import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/controller/new_tenant_project/new_tenant_project_controller.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/text_widget.dart';
import '../../components/forms/filter_form.dart';
import '../../components/forms/new_tenant_project_form.dart';
import '../../components/json/tenants_sra_json.dart';
import '../../config/Import-Export/excel_export.dart';
import '../../config/Import-Export/excel_import_func.dart';
import '../../routes/route_name.dart';
import '../../style/assets_string.dart';
import '../../style/string_const.dart';
import '../../style/theme_const.dart';
import '../CommonWidgets/common_header_footer.dart';
import '../CommonWidgets/common_table.dart';

class NewTenantProjectScreen extends StatelessWidget {
  const NewTenantProjectScreen({super.key});

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
                init: Get.put(NewTenantProjectController()),
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
                        CustomDialogs().customFilterDialogs(
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

                        controller.setFilterData();
                      },
                      onTapAddNew: controller.isAddButtonVisible.value
                          ? () async {
                              controller.setFormData();
                              await CustomDialogs().customFilterDialogs(
                                  context: context,
                                  widget: NewTenantProjectForm(
                                    pagename: controller.pageName.value,
                                  ));
                              await controller.getList();
                              controller.setFilterData();
                              controller.setDefaultData.filterData.removeNullValues();
                              // Get.dialog(
                              //   barrierDismissible: false,
                              //   const NewTenantProjectForm(),
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
                                        Map dialogBoxData = controller.dialogBoxData.value;
                                        dialogBoxData['formfields'] = [(dialogBoxData['formfields'] as List)[0]];

                                        ExcelExport().exportData(
                                            dialogBoxData: controller.dialogBoxData,
                                            formName: controller.dialogBoxData['formname'] ?? "",
                                            pageName: controller.dialogBoxData['pagename'],
                                            filter: controller.setDefaultData.filterData,
                                            setDefaultData: controller.setDefaultData);
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
                          controller.setDefaultData.pageNo.value = 1;
                          controller.searchText.value = "";
                          controller.searchController.text = "";
                          controller.setFilterData();
                          controller.setDefaultData.filterData.removeNullValues();
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
                              widget: NewTenantProjectForm(
                                title: "Edit",
                                btnName: "Update",
                                pagename: controller.pageName.value,
                              ));
                          controller.setFilterData();
                          await controller.getList();
                          controller.setDefaultData.filterData.removeNullValues();
                        },
                        deleteDataFun: (id, index) {
                          controller.deleteData({
                            "_id": id,
                          });
                        },
                        // field3title: 'Documents',
                        // field3: controller.pageName.value == 'tenantproject'
                        //     ? (id, parentNameString) async {
                        //         await controller.getMasterFormData(id: id, pagename: "tenantprojectdocument");
                        //         await CustomDialogs().customPopDialog(child: communityEngagement(controller: controller, parentId: id, pagename: "tenantprojectdocument", id: id));
                        //         controller.pageName.value = getCurrentPageName();
                        //         controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                        //       }
                        //     : null,
                        field6title: 'Payment Management',
                        field6: (id) async {
                          controller.selectedTab.value = 1;
                          await controller.getMasterFormData(id: id, pagename: "paymentmanagement");
                          await CustomDialogs().customPopDialog(child: communityEngagement(controller: controller, parentId: id, pagename: "paymentmanagement"));
                          controller.selectionCount.value = 0;
                          controller.isApprovingPayment.value = false;
                          controller.selectAll.value = false;
                          controller.pageName.value = 'tenantproject';
                          controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                        },

                        // field4title: 'SRA Body',
                        // field4: controller.pageName.value == 'tenantproject'
                        //     ? (id, parentNameString, index) async {
                        //         await controller.getMasterFormData(id: id, pagename: "srabody");
                        //         await CustomDialogs().customPopDialog(child: communityEngagement(controller: controller, parentId: id, pagename: "srabody"));
                        //         controller.pageName.value = getCurrentPageName();
                        //         controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                        //       }
                        //     : null,

                        // field4title: 'Community Engagement',
                        // field4: controller.pageName.value == 'tenantproject'
                        //     ? (id, parentNameString, index) async {
                        //         await controller.getMasterFormData(id: id, pagename: "communityengagement");
                        //         await CustomDialogs().customPopDialog(child: communityEngagement(controller: controller, parentId: id, pagename: "communityengagement"));
                        //         controller.pageName.value = getCurrentPageName();
                        //         controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                        //       }
                        //     : null,
                        handleGridChange: (index, field, type, value, masterfieldname, name) {
                          controller.handleGridChange(type: type, field: field, index: index, value: value);
                        },
                        // field5title: 'User Assign',
                        // field5: controller.pageName.value == 'tenantproject'
                        //     ? (id) async {
                        //         controller.setDefaultData.masterFormData['tenantprojectid'] = id;
                        //         controller.setMasterFormData(parentId: id, page: 'managerassign');
                        //         await controller.setUserInTable(id);
                        //         controller.setDefaultData.masterFormData.refresh();
                        //         // controller.setManagerAssignData();
                        //         controller.setDefaultData.masterFormData['tenantprojectid'] = id;
                        //
                        //         await CustomDialogs().customPopDialog(
                        //           child: const SizedBox(
                        //             width: 800,
                        //             child: NewTenantProjectForm(
                        //               pagename: 'managerassign',
                        //               title: "User Assign",
                        //               btnName: "Save",
                        //               isMasterForm: true,
                        //             ),
                        //           ),
                        //         );
                        //         await Future.delayed(const Duration(milliseconds: 100));
                        //         controller.pageName.value = getCurrentPageName();
                        //         controller.dialogBoxData.value = TenantsSRAJson.designationFormFields(controller.pageName.value);
                        //
                        //         controller.setFilterData();
                        //       }
                        //     : null,
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
                        //             child: NewTenantProjectForm(
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

  // Future<void> secondFromData(String id, TenantProjectController controller) async {
  //   var reqBody = {
  //     "paginationinfo": {
  //       "pageno": 1,
  //       "pagelimit": 99999999999,
  //       "filter": {"tenantprojectid": id},
  //       "sort": {}
  //     }
  //   };
  //   var response = await IISMethods().listData(userAction: 'listcommunityengagement', pageName: 'communityengagement', url: '${Config.weburl}communityengagement', reqBody: reqBody);
  //   controller.setDefaultData.masterData['communityengagement'] = response['data'];
  //   controller.setDefaultData.masterFieldOrder.value = List<Map<String, dynamic>>.from(response['fieldorder']['fields']);
  // }

  Widget communityEngagement({required NewTenantProjectController controller, required String parentId, required String pagename, String? id}) {
    var dialogBoxData = TenantsSRAJson.designationFormFields(pagename);

    return SizedBox(
      width: 1000,
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
                padding: EdgeInsets.all(sizeInformation.isMobile ? 8 : 24),
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextWidget(
                          text: dialogBoxData['formname'],
                          fontWeight: FontWeight.w500,
                          color: ColorTheme.kPrimaryColor,
                          textOverflow: TextOverflow.ellipsis,
                          fontSize: 18,
                        ),
                      ),
                      // if (pagename == "tenantprojectdocument" && !sizeInformation.isMobile)
                      //   Obx(() {
                      //     return constrainedBoxWithPadding(
                      //       width: 300,
                      //       child: DropDownSearchCustom(
                      //         focusNode: FocusNode(),
                      //         canShiftFocus: false,
                      //         items: List<Map<String, dynamic>>.from(controller.filterDocumentTypeList),
                      //         isCleanable: true,
                      //         clickOnCleanBtn: () async {
                      //           controller.selectedDocumentType = {};
                      //           await controller.getMasterFormData(id: id, pagename: "tenantprojectdocument");
                      //         },
                      //         initValue: controller.selectedDocumentType['label'] != null ? controller.selectedDocumentType : null,
                      //         hintColor: ColorTheme.kBlack,
                      //         hintText: 'Select Document Type',
                      //         isSearchable: true,
                      //         onChanged: (v) async {
                      //           controller.selectedDocumentType = v ?? {};
                      //           await controller.getMasterFormData(id: id, documenttype: v!['documenttype'] ?? "", documenttypeid: v!['documenttypeid'] ?? "", pagename: "tenantprojectdocument");
                      //           controller.filterDocumentTypeList.refresh();
                      //         },
                      //         dropValidator: (Map<String, dynamic>? v) {
                      //           return null;
                      //         },
                      //       ),
                      //     );
                      //   }),
                      Visibility(
                        visible: IISMethods().hasAddRight(alias: controller.pageName.value) && sizeInformation.isMobile,
                        child: CustomButton(
                          onTap: () async {
                            controller.setMasterFormData(parentId: parentId, page: pagename, canSwitchTab: false);
                            CustomDialogs().customFilterDialogs(
                              context: context,
                              widget: NewTenantProjectForm(
                                pagename: pagename,
                                title: "Add Payment Management",
                                btnName: "Save",
                                isMasterForm: true,
                              ),
                            );
                          },
                          width: 40,
                          fontSize: 14,
                          borderRadius: 4,
                          height: 40,
                          widget: const Icon(
                            Icons.add,
                            color: ColorTheme.kWhite,
                          ),
                        ),
                      ),
                      Obx(() {
                        return Stack(
                          children: [
                            Obx(() {
                              return Visibility(
                                visible: controller.canApprovePayment.value,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomButton(
                                    title: 'Submit to SAP',
                                    widget: !controller.isApprovingPayment.value
                                        ? const Icon(
                                            CupertinoIcons.upload_circle,
                                            color: ColorTheme.kWhite,
                                          )
                                        : null,
                                    width: 40,
                                    fontSize: 14,
                                    borderRadius: 4,
                                    height: 40,
                                    onTap: controller.isApprovingPayment.value
                                        ? () {
                                            List selectedIds = [];
                                            List paymentGroupIds = [];
                                            // = controller.setDefaultData.data.where((element) {
                                            //   return element['isSelected'] == 1;
                                            // }).map((element) {
                                            //   return element['_id'];
                                            // }).toList();
                                            String tenantProjectId = parentId;
                                            // controller.setDefaultData.data.firstWhere((element) => element['isSelected'] == 1)['tenantprojectid'] ?? '';
                                            for (var element in (controller.setDefaultData.masterData[pagename] ?? [])) {
                                              if (element['isSelected'] == 1) {
                                                selectedIds.add(element['tenantid']);
                                                paymentGroupIds.add(element['_id']);
                                                element['isSelected'] = 0;
                                                controller.selectionCount.value = 0;
                                                controller.selectAll.value = false;
                                              }
                                            }
                                            devPrint('tenantProjectId-->$tenantProjectId');
                                            controller.getPaymentSapData(selectedIds: selectedIds, tenantProjectId: tenantProjectId, paymentGroupIds: paymentGroupIds);
                                          }
                                        : () {
                                            controller.isApprovingPayment.value = !controller.isApprovingPayment.value;
                                          },
                                  ),
                                ),
                              );
                            }),
                            if (controller.isApprovingPayment.value)
                              Positioned(
                                top: 2,
                                right: 1,
                                child: InkWell(
                                  onTap: () {
                                    controller.isApprovingPayment.value = !controller.isApprovingPayment.value;
                                  },
                                  child: const CircleAvatar(
                                    backgroundColor: ColorTheme.kRed,
                                    radius: 8,
                                    child: Icon(
                                      Icons.clear_rounded,
                                      color: ColorTheme.kWhite,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        );
                      }),
                      Visibility(
                        visible: IISMethods().hasAddRight(alias: controller.pageName.value) && !sizeInformation.isMobile,
                        child: CustomButton(
                          onTap: () async {
                            controller.setMasterFormData(parentId: parentId, page: pagename, canSwitchTab: false);
                            CustomDialogs().customFilterDialogs(
                              context: context,
                              widget: NewTenantProjectForm(
                                pagename: pagename,
                                title: "Add Payment Management",
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
                  margin: EdgeInsets.all(sizeInformation.isMobile ? 8 : 24),
                  decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor)),
                  child: Column(
                    children: [
                      Expanded(
                        child: Obx(() {
                          RxList<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[pagename] ?? []).obs;
                          return CommonDataTableWidget(
                            pageName: 'tenantproject',
                            showPagination: false,
                            containsRights: false,
                            fieldOrder: !controller.isApprovingPayment.value
                                ? controller.setDefaultData.masterFieldOrder.value
                                : [
                                    {
                                      "field": "isSelected",
                                      "text": "Select All (${controller.selectionCount.value})",
                                      "type": "checkbox",
                                      "freeze": 1,
                                      "active": 1,
                                      "sorttable": 0,
                                      'canselectall': 1,
                                      'selectall': controller.selectAll.value ? 1 : 0,
                                      "sortby": "name",
                                      "filter": 0,
                                      "filterfieldtype": "dropdown",
                                      "defaultvalue": "",
                                      "tblsize": 10,
                                    },
                                    ...List<Map<String, dynamic>>.from(IISMethods().encryptDecryptObj(controller.setDefaultData.masterFieldOrder.value)).sublist(1),
                                  ],
                            data: data,
                            field4title: 'Submit to SAP',
                            field4: controller.canApprovePayment.value
                                ? (id, parentNameString, index) {
                                    controller.getPaymentSapData(tenantProjectId: parentId, selectedIds: [data[index]['tenantid']], paymentGroupIds: [data[index]['_id']]);
                                  }
                                : null,
                            tableScrollController: controller.tableScrollController,
                            rentInfoDataFun: (id, index, field, type) {
                              controller.getPaymentForSRA(groupId: id);
                            },
                            pageField: pagename,
                            handleGridChange: (index, field, type, value, masterfieldname, name) async {
                              if (type == HtmlControls.kCheckBox) {
                                controller.setDefaultData.masterData[pagename][index][field] = value ? 1 : 0;
                                if (value) {
                                  controller.selectionCount.value++;
                                } else {
                                  controller.selectionCount.value--;
                                }
                                controller.setDefaultData.masterData.refresh();
                              } else if (type == 'selectAllCheckbox') {
                                for (var element in (controller.setDefaultData.masterData[pagename] ?? [])) {
                                  element[field] = value ? 1 : 0;
                                  if (value) {
                                    controller.selectionCount.value = (controller.setDefaultData.masterData[pagename] ?? []).length;
                                  } else {
                                    controller.selectionCount.value = 0;
                                  }
                                  controller.selectAll.value = value;
                                }
                              }
                              // if (await controller.updateMasterData(reqData: data[index], editeDataIndex: index, pagename: pagename)) {
                              //   Get.back();
                              // }
                            },
                            onTapDocument: (id, name, documentMap) {
                              IISMethods().getDocumentHistory(
                                tenantId: id,
                                documentType: name,
                                pagename: pagename == "society" ? 'Society' : "Tenant Project Document",
                              );
                            },
                            editDataFun: (id, index) async {
                              controller.setMasterFormData(parentId: parentId, editeDataIndex: index, id: id, page: pagename, canSwitchTab: false);
                              await CustomDialogs().customFilterDialogs(
                                context: context,
                                widget: NewTenantProjectForm(
                                  pagename: pagename,
                                  title: "Edit Payment Management",
                                  btnName: "Save",
                                  isMasterForm: true,
                                ),
                              );
                            },
                            deleteDataFun: (id, index) async {
                              await controller.deleteMasterData(
                                reqData: data[index],
                                pageName: pagename,
                              );
                              controller.getMasterFormData(
                                pagename: pagename,
                                id: parentId,
                              );
                            },
                            onSort: (sortFieldName) async {
                              if (controller.setDefaultData.sortData.containsKey(sortFieldName)) {
                                controller.setDefaultData.sortData[sortFieldName] = controller.setDefaultData.sortData[sortFieldName] == 1 ? -1 : 1;
                              } else {
                                controller.setDefaultData.sortData.clear();
                                controller.setDefaultData.sortData[sortFieldName] = 1;
                              }
                              await controller.getMasterFormData(
                                id: parentId,
                                pagename: pagename,
                                sort: controller.setDefaultData.sortData.value,
                              );
                            },
                            width: sizeInformation.isMobile ? MediaQuery.sizeOf(context).width - 16 : 1000,
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
            width: 1000,
            child: communityForm(context),
          ),
        );
      }),
    );
  }
}
