import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/forms/tenants_master_form.dart';
import 'package:prestige_prenew_frontend/config/Import-Export/excel_export.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/controller/tenant_master_controller.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:prestige_prenew_frontend/view/tenant_master/tenants_kanban_view.dart';
import 'package:prestige_prenew_frontend/view/tenant_master/tenants_table_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/forms/filter_form.dart';
import '../../components/json/tenants_sra_json.dart';
import '../../config/Import-Export/excel_import_func.dart';
import '../../controller/layout_templete_controller.dart';
import '../../routes/route_name.dart';
import '../../style/string_const.dart';
import '../CommonWidgets/common_table.dart';

class TenantsMasterView extends StatelessWidget {
  const TenantsMasterView({super.key, this.pageName});

  final String? pageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.kScaffoldColor,
        body: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            double width = sizingInformation.isMobile ? MediaQuery.sizeOf(context).width : MediaQuery.sizeOf(context).width - 141;
            return GetBuilder(
              // global: false,
              init: Get.put(TenantMasterController()),
              builder: (controller) {
                return CommonHeaderFooter(
                  filterData: controller.setDefaultData.filterData,
                  hasSearch: true,
                  onFilterInHeaderChange: () {
                    if (controller.selectedView.value == 0) {
                      controller.getList();
                    } else {
                      controller.setKanBanData();
                    }
                  },
                  showFilterInHeader: true,
                  headerWidgets: sizingInformation.isMobile
                      ? null
                      : Obx(
                          () {
                            return Container(
                              width: 70,
                              margin: sizingInformation.isDesktop ? null : const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                border: !sizingInformation.isDesktop
                                    ? null
                                    : Border.all(
                                        color: ColorTheme.kBorderColor,
                                        width: 1,
                                      ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: CupertinoSlidingSegmentedControl(
                                backgroundColor: ColorTheme.kWhite,
                                thumbColor: ColorTheme.kPrimaryColor,
                                groupValue: controller.selectedView.value,
                                children: controller.screenView
                                    .map(
                                      (e) => ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 30,
                                          maxWidth: 30,
                                        ),
                                        child: SvgPicture.asset(
                                          e,
                                          height: 30,
                                          width: 30,
                                          colorFilter: ColorFilter.mode(
                                            controller.screenView.indexOf(e) != controller.selectedView.value ? ColorTheme.kPrimaryColor : ColorTheme.kWhite,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()
                                    .asMap(),
                                onValueChanged: (value) {
                                  controller.selectedView.value = value!;
                                  if (value == 1) {
                                    controller.setKanBanData();
                                  } else {
                                    controller.getList();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                  onTapFilter: () async {
                    controller.setFilterData();
                    CustomDialogs().customFilterDialogs(
                      context: context,
                      widget: FilterForm(
                        title: "Filter",
                        btnName: "Apply",
                        setDefaultData: controller.setDefaultData,
                        onFilterApply: () {
                          controller.setDefaultData.filterData.removeNullValues();
                          if (controller.selectedView.value == 0) {
                            controller.getList();
                          } else {
                            controller.setKanBanData();
                          }
                        },
                        onResetFilter: () {
                          controller.setFilterData();
                        },
                      ),
                    );
                  },
                  onSearch: (p0) {
                    controller.searchText = p0;

                    if (controller.selectedView.value == 1) {
                      controller.setKanBanData();
                    } else {
                      controller.getList();
                    }
                  },
                  setDefaultData: controller.setDefaultData,
                  actions: sizingInformation.isMobile
                      ? null
                      : [
                          if (controller.approverTenantProject.isNotNullOrEmpty)
                            Obx(() {
                              return Stack(
                                children: [
                                  Obx(() {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomButton(
                                        title: 'Submit to SAP',
                                        widget: controller.isSapSelection.value
                                            ? null
                                            : const Icon(
                                                CupertinoIcons.upload_circle,
                                                color: ColorTheme.kWhite,
                                              ),
                                        width: 30,
                                        height: 40,
                                        borderRadius: 6,
                                        onTap: controller.isSapSelection.value
                                            ? () {
                                                List selectedIds = [];
                                                // = controller.setDefaultData.data.where((element) {
                                                //   return element['isSelected'] == 1;
                                                // }).map((element) {
                                                //   return element['_id'];
                                                // }).toList();
                                                String tenantProjectId = controller.setDefaultData.filterData['tenantprojectid'];
                                                // controller.setDefaultData.data.firstWhere((element) => element['isSelected'] == 1)['tenantprojectid'] ?? '';
                                                for (var element in controller.setDefaultData.data) {
                                                  if (element['isSelected'] == 1) {
                                                    selectedIds.add(element['_id']);
                                                    element['isSelected'] = 0;
                                                    controller.setDefaultData.data.refresh();
                                                    controller.selectedCount.value = 0;
                                                    controller.selectAll.value = false;
                                                  }
                                                }
                                                jsonPrint(tag: "selctedIds:   ", selectedIds);
                                                jsonPrint(tag: "tenantProjectId:   ", tenantProjectId);
                                                controller.getSapData(selectedIds: selectedIds, tenantProjectId: tenantProjectId);
                                              }
                                            : () {
                                                controller.isSapSelection.value = !controller.isSapSelection.value;
                                              },
                                      ),
                                    );
                                  }),
                                  if (controller.isSapSelection.value)
                                    Positioned(
                                      top: 2,
                                      right: 1,
                                      child: InkWell(
                                        onTap: () {
                                          controller.isSapSelection.value = !controller.isSapSelection.value;
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
                                              filter: controller.setDefaultData.filterData,
                                              setDefaultData: controller.setDefaultData);
                                        },
                                        btnName: 'Export Tenant',
                                      ),
                                    if (IISMethods().hasImportRight(alias: getCurrentPageName()))
                                      CommonDataTableWidget.menuOption(
                                        onTap: () async {
                                          Map<String, dynamic> dialogData = IISMethods().encryptDecryptObj(controller.dialogBoxData);
                                          (dialogData['tabs'] as List?)?.removeAt(4);
                                          (dialogData['tabs'] as List?)?.removeAt(2);
                                          await ExcelImport()
                                              .showPickFileDialog(
                                                  dialogBoxData: dialogData,
                                                  formName: controller.dialogBoxData['formname'] ?? "",
                                                  pageName: controller.dialogBoxData['pagename'],
                                                  selectedTenantProject: (controller.setDefaultData.masterData['tenantproject'] as List).firstWhere(
                                                    (element) {
                                                      return element['value'] == controller.setDefaultData.filterData['tenantprojectid'];
                                                    },
                                                    orElse: () {
                                                      return {};
                                                    },
                                                  ))
                                              .then((value) => controller.getList());
                                        },
                                        btnName: 'Import Tenant',
                                      ),
                                    if (IISMethods().hasImportRight(alias: getCurrentPageName()))
                                      CommonDataTableWidget.menuOption(
                                        onTap: () async {
                                          Map<String, dynamic> dialogData = TenantsSRAJson.designationFormFields('tenant/payment');

                                          await ExcelImport()
                                              .showPickFileDialog(
                                                  dialogBoxData: dialogData,
                                                  formName: controller.dialogBoxData['formname'] ?? "",
                                                  pageName: 'tenant',
                                                  selectedTenantProject: (controller.setDefaultData.masterData['tenantproject'] as List).firstWhere(
                                                    (element) {
                                                      return element['value'] == controller.setDefaultData.filterData['tenantprojectid'];
                                                    },
                                                    orElse: () {
                                                      return {};
                                                    },
                                                  ))
                                              .then((value) => controller.getList());
                                        },
                                        btnName: 'Import Payment',
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
                  onTapAddNew: controller.isAddButtonVisible.value
                      ? () async {
                          showBottomBar.value = false;
                          controller.setFormData();
                          await Get.dialog(barrierDismissible: false, TenantsMasterForm());
                          showBottomBar.value = true;
                          controller.setFilterData();
                          controller.setDefaultData.filterData.removeNullValues();
                        }
                      : null,
                  title: controller.formName.value,
                  txtSearchController: controller.searchController,
                  child: Obx(
                    () {
                      if (controller.selectedView.value == 0) {
                        return Obx(() {
                          return TenantDataTableView(
                            isLoading: controller.loadingData.value || controller.setDefaultData.fieldOrder.isEmpty,
                            width: width,
                            editDataFun: (id, index) async {
                              showBottomBar.value = false;
                              controller.setFormData(id: id, editeDataIndex: index);
                              await Get.dialog(
                                barrierDismissible: false,
                                TenantsMasterForm(
                                  oldData: controller.setDefaultData.data[index],
                                ),
                              );
                              showBottomBar.value = true;
                              // controller.setFilterData();
                              controller.setDefaultData.filterData.removeNullValues();
                            },
                            onPageChange: (pageNo, pageLimit) {
                              controller.searchText = controller.searchController.text;
                              controller.setDefaultData.pageNo.value = pageNo;
                              controller.setDefaultData.pageLimit = pageLimit;
                              controller.getList();
                            },
                            handleGridChange: (index, field, type, value) {
                              if (type == 'checkbox') {
                                controller.setDefaultData.data[index][field] = value ? 1 : 0;

                                if (!value) {
                                  controller.selectAll.value = false;
                                }
                                if (value) {
                                  controller.selectedCount++;
                                } else {
                                  controller.selectedCount--;
                                }
                              } else if (type == 'selectAll') {
                                if (value) {
                                  controller.selectedCount.value = 0;
                                }

                                for (var data in controller.setDefaultData.data) {
                                  data[field] = value ? 1 : 0;
                                  if (value) {
                                    controller.selectedCount++;
                                  } else {
                                    controller.selectedCount--;
                                  }
                                }
                                controller.selectAll.value = value;
                              }
                              controller.selectAll.refresh();

                              controller.setDefaultData.data.refresh();
                            },
                            pageName: controller.pageName.value,
                            setDefaultData: controller.setDefaultData,
                            data: controller.setDefaultData.data.value,
                            fieldOrder: !controller.isSapSelection.value
                                ? controller.setDefaultData.fieldOrder
                                : [
                                    {
                                      "field": "isSelected",
                                      "text": "Select All",
                                      "type": "checkbox",
                                      "freeze": 1,
                                      "active": 1,
                                      "sorttable": 0,
                                      "sortby": "name",
                                      "filter": 0,
                                      "filterfieldtype": "dropdown",
                                      "defaultvalue": "",
                                      "tblsize": 15,
                                    },
                                    ...List<Map<String, dynamic>>.from(IISMethods().encryptDecryptObj(controller.setDefaultData.fieldOrder)).sublist(1),
                                  ],
                          );
                        });
                      } else {
                        return TenantsKanbanView();
                      }
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}
