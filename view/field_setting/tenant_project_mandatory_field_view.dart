import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_checkbox.dart';
import '../../config/dev/dev_helper.dart';
import '../../controller/dynamic_field_setting/tenant_project_mandatory_field_controller.dart';

class TenantProjectMandatoryFieldView extends GetView<TenantProjectMandatoryFieldController> {
  const TenantProjectMandatoryFieldView({super.key, required this.selectedTab});

  final int selectedTab;

  @override
  Widget build(BuildContext context) {
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
                              controller.tableHeader.length,
                              (index) {
                                return SizedBox(
                                  width: 200,
                                  height: 100,
                                  child: Center(
                                    child: TextWidget(
                                      text: controller.tableHeader.value[index]['title'].toString(),
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
                    data: ThemeData(scrollbarTheme: const ScrollbarThemeData(trackVisibility: WidgetStatePropertyAll(false), thumbVisibility: WidgetStatePropertyAll(false))),
                    child: SizedBox(
                      width: 200,
                      child: Obx(() {
                        return ListView(
                          controller: controller.verticalHeaderController,
                          children: List.generate(
                            1,
                            (index) {
                              Map<String, dynamic> tab = controller.tenantFields[selectedTab];
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
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SingleChildScrollView(
                          controller: controller.verticalBodyController,
                          child: Obx(() {
                            return Column(
                              // mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              // shrinkWrap: true,
                              children: List.generate(
                                1,
                                (index) {
                                  Map<String, dynamic> tab = controller.tenantFields[selectedTab];
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        color: ColorTheme.kWarnColor.withOpacity(0.2),
                                        height: 50,
                                        width: controller.tableHeader.length * 200,
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
                                                      controller.tableHeader.length,
                                                      (index) {
                                                        return Container(
                                                          decoration: BoxDecoration(border: Border.all(width: 0.5, color: ColorTheme.kBorderColor)),
                                                          width: 200,
                                                          height: 100,
                                                          child: Center(child: Obx(
                                                            () {
                                                              return CustomCheckBox(
                                                                value:
                                                                    ((((controller.fieldSetting[tab['field']] ?? {})[field['field']] ?? {})[controller.tableHeader[index]['field']] ?? false) as bool),
                                                                onChanged: (value) {
                                                                  if (controller.fieldSetting[tab['field']] == null) {
                                                                    controller.fieldSetting[tab['field']] = {};
                                                                  }
                                                                  if (controller.fieldSetting[tab['field']][field['field']] == null) {
                                                                    controller.fieldSetting[tab['field']][field['field']] = {};
                                                                  }
                                                                  controller.fieldSetting[tab['field']][field['field']][controller.tableHeader[index]['field']] = value;
                                                                  controller.fieldSetting[tab['field']][field['field']]['displayorder'] = fieldIndex;
                                                                  if (tab['field'] == 'tenantproject') {
                                                                    if (field['field'] == 'area') {
                                                                      controller.fieldSetting[tab['field']]['pincodeid'][controller.tableHeader[index]['field']] = value;
                                                                      controller.fieldSetting[tab['field']][field['field']]['displayorder'] = fieldIndex;

                                                                    } else if (field['field'] == 'city') {
                                                                      controller.fieldSetting[tab['field']]['cityid'][controller.tableHeader[index]['field']] = value;
                                                                      controller.fieldSetting[tab['field']][field['field']]['displayorder'] = fieldIndex;

                                                                    }
                                                                  }
                                                                  controller.fieldSetting.refresh();
                                                                  jsonPrint(controller.fieldSetting.value);
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
}
