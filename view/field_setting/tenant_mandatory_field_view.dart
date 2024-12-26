import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:prestige_prenew_frontend/view/field_setting/tenant_project_mandatory_field_view.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_checkbox.dart';
import '../../config/dev/dev_helper.dart';
import '../../controller/dynamic_field_setting/tenant_mandatory_field_controller.dart';

class MandatoryFieldMappingView extends GetView<MandatoryFieldMapping> {
  const MandatoryFieldMappingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonHeaderFooter(
        title: 'Mandatory Fields Mapping',
        headerWidgets: SizedBox(
          height: 30,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  List title = [
                    'Tenant Project',
                    'Society',
                    'SRA Body',
                    'Tenant',
                  ];
                  return InkWell(
                    onTap: () {
                      controller.selectedTab.value = index;
                    },
                    child: Obx(() {
                      return Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8,),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: controller.selectedTab.value == index ? ColorTheme.kBlack : ColorTheme.kBackGroundGrey,
                        ),
                        child: Center(
                          child: TextWidget(
                            text: title[index],
                            fontSize: 14,
                            fontWeight: FontTheme.notoMedium,
                            color: controller.selectedTab.value == index ? ColorTheme.kWhite : ColorTheme.kBlack,
                          ),
                        ),
                      );
                    }),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    width: 8,
                  );
                },
                itemCount: 4),
          ),
        ),
        txtSearchController: TextEditingController(),
        child: Obx(() {
          if (controller.selectedTab.value != 3) {
            return TenantProjectMandatoryFieldView(
              selectedTab: controller.selectedTab.value,
            );
          }
          return tenantMasterMandatoryFieldView(controller);
        }),
      ),
    );
  }
}

Widget tenantMasterMandatoryFieldView(MandatoryFieldMapping controller) {
  return Column(
    children: [
      Expanded(
        child: Column(
          children: [
            Container(
              color: ColorTheme.kTableHeader,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Center(
                      child: TextWidget(
                        text: 'Fields',
                        fontSize: 16,
                        fontWeight: FontTheme.notoSemiBold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      return ListView(
                        controller: controller.horizontalHeaderController,
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...List.generate(
                            controller.tenantStatusList.length,
                            (index) {
                              return SizedBox(
                                width: 200,
                                height: 100,
                                child: Center(
                                  child: TextWidget(
                                    text: controller.tenantStatusList.value[index]['status'].toString(),
                                    fontSize: 16,
                                    fontWeight: FontTheme.notoSemiBold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Row(
              children: [
                Theme(
                  data: ThemeData(scrollbarTheme: const ScrollbarThemeData(trackVisibility: WidgetStatePropertyAll(false), thumbVisibility: WidgetStatePropertyAll(false),)),
                  child: SizedBox(
                    width: 200,
                    child: Obx(() {
                      return ListView(
                        controller: controller.verticalHeaderController,
                        children: List.generate(
                          controller.tenantFields.length,
                          (index) {
                            Map<String, dynamic> tab = controller.tenantFields[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: ColorTheme.kWarnColor.withOpacity(0.2),
                                  width: 200,
                                  height: 50,
                                  child: Center(
                                    child: TextWidget(
                                      text: tab['title'],
                                      fontSize: 18,
                                      fontWeight: FontTheme.notoBold,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> field = tab['fields'][index];
                                      return Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 0.5, color: ColorTheme.kBorderColor),
                                          color: ColorTheme.kBackGroundGrey,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        width: 200,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextWidget(
                                            text: field['text'],
                                            fontSize: 14,
                                            fontWeight: FontTheme.notoMedium,
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: tab['fields'].length)
                              ],
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: controller.horizontalBodyController,
                    child: SingleChildScrollView(
                      controller: controller.verticalBodyController,
                      child: Obx(() {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          // shrinkWrap: true,
                          children: List.generate(
                            controller.tenantFields.length,
                            (index) {
                              Map<String, dynamic> tab = controller.tenantFields[index];
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    color: ColorTheme.kWarnColor.withOpacity(0.2),
                                    height: 50,
                                    width: controller.tenantStatusList.length * 200,
                                  ),
                                  Column(
                                    children: List.generate(
                                      tab['fields'].length,
                                      (fieldIndex) {
                                        Map<String, dynamic> field = tab['fields'][fieldIndex];
                                        return SizedBox(
                                          height: 50,
                                          child: Obx(() {
                                            return Row(
                                              children: [
                                                ...List.generate(
                                                  controller.tenantStatusList.length,
                                                  (index) {
                                                    RxBool selected =
                                                        ((((controller.fieldSetting[controller.tenantStatusList[index]['_id']] ?? {})[field['field']] ?? {})['required'] ?? false) as bool).obs;
                                                    return Container(
                                                      decoration: BoxDecoration(border: Border.all(width: 0.5, color: ColorTheme.kBorderColor)),
                                                      width: 200,
                                                      height: 100,
                                                      child: Center(child: Obx(
                                                        () {
                                                          return CustomCheckBox(
                                                            value: selected.value,
                                                            onChanged: (value) {
                                                              // for (var status in controller.tenantStatusList) {
                                                              //   for (var tab in controller.fields) {
                                                              //     for (var field in tab['fields']) {
                                                              //       if (controller.fieldSetting[status['_id']] == null) {
                                                              //         controller.fieldSetting[status['_id']] = {};
                                                              //       }
                                                              //       if (controller.fieldSetting[status['_id']][field['field']] == null) {
                                                              //         controller.fieldSetting[status['_id']][field['field']] = {};
                                                              //       }
                                                              //       controller.fieldSetting[status['_id']][field['field']]['required'] = value;
                                                              //     }
                                                              //   }
                                                              // }
                                                              if (controller.fieldSetting[controller.tenantStatusList[index]['_id']] == null) {
                                                                controller.fieldSetting[controller.tenantStatusList[index]['_id']] = {};
                                                              }
                                                              if (controller.fieldSetting[controller.tenantStatusList[index]['_id']][field['field']] == null) {
                                                                controller.fieldSetting[controller.tenantStatusList[index]['_id']][field['field']] = {};
                                                              }
                                                              controller.fieldSetting[controller.tenantStatusList[index]['_id']][field['field']]['required'] = value;
                                                              controller.fieldSetting[controller.tenantStatusList[index]['_id']][field['field']]['displayorder'] = fieldIndex;
                                                              selected.value = value!;
                                                              // controller.fieldSetting.refresh();
                                                            },
                                                          );
                                                        },
                                                      ) /*TextWidget(
                                                                text: '${field['field']} ${controller.tenantStatusList.value[index]['_id'].toString()}',
                                                                fontSize: 14,
                                                                fontWeight: FontTheme.notoMedium,
                                                              ),*/
                                                          ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              return CustomButton(
                isLoading: controller.formButtonLoading.value,
                onTap: (!controller.formButtonLoading.value)
                    ? () async {
                        controller.formButtonLoading.value = true;
                        await controller.addData();
                        controller.formButtonLoading.value = false;
                      }
                    : null,
                height: 40,
                width: 70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                buttonColor: ColorTheme.kPrimaryColor,
                fontColor: ColorTheme.kWhite,
                borderRadius: 4,
                title: 'Save',
              );
            }),
          )
        ],
      )
    ],
  );
}
