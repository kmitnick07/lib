import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/controller/project/project_management_controller.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config/iis_method.dart';
import '../../style/string_const.dart';
import '../customs/custom_text_form_field.dart';
import '../customs/drop_down_search_custom.dart';
import '../funtions.dart';

class ProjectManagementForm extends StatelessWidget {
  const ProjectManagementForm({super.key, this.isProjectForm = false, this.title = "Add", this.btnName = StringConst.kAddBtnTxt, this.saveAndAddBtnName = StringConst.kSaveAndAddBtnTxt});

  final bool isProjectForm;
  final String title;
  final String btnName;
  final String saveAndAddBtnName;

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);

    return GetBuilder(
      init: Get.put(ProjectManagementController()),
      builder: (ProjectManagementController controller) {
        Widget projectForm() {
          return ResponsiveBuilder(builder: (context, sizeInformation) {
            return Obx(() {
              return Form(
                key: controller.formKey0,
                autovalidateMode: controller.validateForm.value ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                child: Column(
                  children: [
                    Container(
                      height: 85,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: ColorTheme.kBorderColor,
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Row(
                          children: [
                            TextWidget(
                              text: '$title ${controller.dialogBoxData['formname']}',
                              fontWeight: FontWeight.w500,
                              color: ColorTheme.kPrimaryColor,
                              fontSize: 18,
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                controller.validator = {};
                                controller.validateForm.value = false;
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
                    ).paddingOnly(bottom: 4),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.dialogBoxData['formfields'].length,
                        padding: EdgeInsets.symmetric(horizontal: sizeInformation.isMobile ? 2 : 16),
                        itemBuilder: (context, index) {
                          return Wrap(
                            children: [
                              ...List.generate(controller.dialogBoxData["formfields"][index]["formFields"].length, (i) {
                                var res = controller.dialogBoxData["formfields"][index]["formFields"][i];
                                var focusOrderCode = generateUniqueFieldId(index, i, null, null);
                                if (!controller.focusNodes.containsKey(focusOrderCode)) {
                                  controller.focusNodes[focusOrderCode] = FocusNode();
                                }
                                if (res.containsKey('condition')) {
                                  Map condition = res['condition'];
                                  res['defaultvisibility'] = false;
                                  List<String> fields = List<String>.from(condition.keys.toList());
                                  for (String field in fields) {
                                    for (var value in condition[field]) {
                                      if (controller.setDefaultData.formData[field] == value) {
                                        res['defaultvisibility'] = true;
                                        break;
                                      }
                                    }
                                  }
                                }
                                if (res['defaultvisibility'] == false) {
                                  return const SizedBox.shrink();
                                }
                                jsonPrint(tag: "9864534156324165341", (isProjectForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData));
                                switch (res["type"]) {
                                  case HtmlControls.kInputText:
                                    return Obx(() {
                                      var textController = TextEditingController(
                                          text: (isProjectForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString().isEmpty ||
                                                  (isProjectForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] == null
                                              ? ""
                                              : (isProjectForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString());
                                      if (controller.cursorPos <= textController.text.length) {
                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                      } else {
                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                      }
                                      return constrainedBoxWithPadding(
                                          width: res['gridsize'],
                                          child: CustomTextFormField(
                                            focusNode: controller.focusNodes[focusOrderCode],
                                            textInputType: TextInputType.text,
                                            controller: textController,
                                            hintText: "Enter ${res["text"]}",
                                            inputFormatters: [if (res['field'] == 'email' || res['field'] == 'person_email' || res['field'] == 'personemail') inputTextEmailRegx else inputTextRegx],
                                            validator: (v) {
                                              if (controller.validator[res["field"]] ?? false) {
                                                if (v.toString().isEmpty) {
                                                  return "Please Enter ${res["text"]}";
                                                } else if (res.containsKey("regex")) {
                                                  if (!RegExp(res["regex"]).hasMatch(v)) {
                                                    return "Please Enter a valid ${res["text"]}";
                                                  }
                                                }
                                              }
                                              return null;
                                            },
                                            isRequire: res["required"],
                                            textFieldLabel: res["text"],
                                            disableField: res["disabled"],
                                            onChanged: (v) async {
                                              await controller.handleFormData(
                                                key: res["field"],
                                                value: res["field"].toString().toLowerCase().contains("name") ? v.toCamelCase : v,
                                                type: res["type"],
                                              );
                                              controller.cursorPos = textController.selection.extent.offset;
                                            },
                                          ));
                                    });
                                  case HtmlControls.kNumberInput:
                                    return Obx(() {
                                      var textController = TextEditingController(
                                          text: (isProjectForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString().isEmpty ||
                                                  (isProjectForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] == null
                                              ? ""
                                              : (isProjectForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString());
                                      if (controller.cursorPos <= textController.text.length) {
                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                      } else {
                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                      }
                                      FocusNode focusNode = controller.focusNodes[focusOrderCode] ?? FocusNode();
                                      return constrainedBoxWithPadding(
                                          width: res['gridsize'],
                                          child: CustomTextFormField(
                                            focusNode: focusNode,
                                            textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                            inputFormatters: [
                                              IISMethods().decimalPointRgex(res?['decimalpoint']),
                                              if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue"))) LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                              if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                            ],
                                            disableField: res["disabled"],
                                            controller: textController,
                                            hintText: "Enter ${res["text"]}",
                                            validator: (v) {
                                              if (controller.validator[res["field"]] ?? false) {
                                                if (v.toString().isEmpty) {
                                                  return "Please Enter ${res["text"]}";
                                                } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                  if (!RegExp(res["regex"]).hasMatch(v)) {
                                                    return "Please Enter a valid ${res["text"]}";
                                                  }
                                                } else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                  return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                }
                                              }
                                              return null;
                                            },
                                            showSuffixDivider: (res.containsKey('suffixtext') && res['suffixtext'] != null),
                                            suffixWidget: (res.containsKey('suffixtext') && res['suffixtext'] != null)
                                                ? TextWidget(
                                                    text: res['suffixtext'],
                                                  ).paddingSymmetric(horizontal: 4)
                                                : null,
                                            isRequire: res["required"],
                                            textFieldLabel: res["text"],
                                            onChanged: (v) async {
                                              if (v.endsWith('.')) {
                                                return;
                                              }
                                              await controller.handleFormData(
                                                key: res["field"],
                                                value: v,
                                                type: res["type"],
                                              );
                                              controller.cursorPos = textController.selection.extent.offset;
                                            },
                                          ));
                                    });
                                  case HtmlControls.kDropDown:
                                    return Obx(() {
                                      var masterdatakey = res?["storemasterdatabyfield"] == true ? res["field"] : res["masterdata"];
                                      var list = IISMethods().encryptDecryptObj(controller.setDefaultData.masterData[masterdatakey]);
                                      if (res.containsKey("isselfrefernce") && res["isselfrefernce"] && (controller.setDefaultData.formData)[res["isselfreferncefield"]].toString().isNotEmpty) {
                                        list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                          if ((controller.setDefaultData.formData)[res["isselfreferncefield"]] != e["label"]) {
                                            return e;
                                          }
                                        }).toList();
                                        list.remove(null);
                                      }
                                      return constrainedBoxWithPadding(
                                          width: res['gridsize'],
                                          child: DropDownSearchCustom(
                                            width: res['gridsize'],
                                            focusNode: controller.focusNodes[focusOrderCode],
                                            dropValidator: (p0) {
                                              if (controller.validator[res["field"]] ?? false) {
                                                if (p0?.isEmpty == true || p0 == null) {
                                                  return "Please Select a ${res['text']}";
                                                }
                                              }
                                              return null;
                                            },
                                            items: List<Map<String, dynamic>>.from(list ?? []),
                                            readOnly: res['disabled'],
                                            isRequire: res["required"],
                                            isIcon: res["field"] == "iconid" || res["field"] == "iconunicode",
                                            textFieldLabel: res["text"],
                                            hintText: "Select ${res["text"]}",
                                            isCleanable: res["cleanable"],
                                            showAddButton: false,
                                            buttonText: res["text"],
                                            clickOnAddBtn: () async {
                                              devPrint("+9562349865341563");
                                            },
                                            clickOnCleanBtn: () async {
                                              await controller.handleFormData(
                                                key: res["field"],
                                                value: "",
                                                type: res["type"],
                                              );
                                            },
                                            isSearchable: res["searchable"],
                                            initValue: (list ?? []).where((element) => element["value"] == (controller.setDefaultData.formData)[res["field"]]).toList().isNotEmpty
                                                ? list.where((element) => element["value"] == (controller.setDefaultData.formData)[res["field"]]).toList()?.first ?? {}
                                                : null,
                                            onChanged: (v) async {
                                              await controller.handleFormData(
                                                key: res["field"],
                                                value: v!["value"],
                                                type: res["type"],
                                              );
                                            },
                                          ));
                                    });
                                  default:
                                    return Container(
                                      color: ColorTheme.kRed,
                                      width: 100,
                                      height: 200,
                                    );
                                }
                              }),
                            ],
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: sizeInformation.isMobile,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                isLoading: controller.addButtonLoading.value,
                                onTap: !controller.addButtonLoading.value
                                    ? () async {
                                        controller.validator = await validationForm(
                                          formData: controller.setDefaultData.formData,
                                          validation: controller.dialogBoxData["formfields"],
                                        );
                                        if (!controller.formKey0.currentState!.validate()) {
                                          controller.validateForm.value = true;
                                          return;
                                        }
                                        controller.validateForm.value = false;
                                        controller.addButtonLoading.value = true;
                                        await controller.handleAddButtonClick(saveAndAdd: false);
                                        controller.addButtonLoading.value = false;
                                      }
                                    : null,
                                height: 50,
                                width: 70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                buttonColor: ColorTheme.kPrimaryColor,
                                fontColor: ColorTheme.kWhite,
                                borderRadius: 4,
                                title: btnName,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (btnName.toUpperCase() == StringConst.kAddBtnTxt) ...[
                              Obx(() {
                                return Expanded(
                                  child: CustomButton(
                                    onTap: !controller.addMultipleButtonLoading.value
                                        ? () async {
                                            controller.validator = await validationForm(
                                              formData: controller.setDefaultData.formData,
                                              validation: controller.dialogBoxData["formfields"],
                                            );
                                            if (!controller.formKey0.currentState!.validate()) {
                                              controller.validateForm.value = true;
                                              return;
                                            }
                                            controller.validateForm.value = false;

                                            controller.addMultipleButtonLoading.value = true;
                                            await controller.handleAddButtonClick(saveAndAdd: true);
                                            controller.addMultipleButtonLoading.value = false;
                                          }
                                        : null,
                                    isLoading: controller.addMultipleButtonLoading.value,
                                    circularProgressColor: ColorTheme.kWhite,
                                    height: 50,
                                    width: 70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    buttonColor: ColorTheme.kPrimaryColor,
                                    fontColor: ColorTheme.kWhite,
                                    borderRadius: 4,
                                    title: saveAndAddBtnName,
                                  ),
                                );
                              }),
                              const SizedBox(width: 10)
                            ],
                            Expanded(
                              child: CustomButton(
                                onTap: () async {
                                  controller.formKey0.currentState?.reset();
                                  // controller.validateForm = false;
                                  controller.setFormData(
                                    id: controller.setDefaultData.formData['_id'],
                                    editeDataIndex: controller.setDefaultData.formData['_id'].toString().isNotNullOrEmpty ? controller.initialStateData['lastEditedDataIndex'] : null,
                                  );
                                },
                                height: 50,
                                width: 70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                buttonColor: ColorTheme.kBackGroundGrey,
                                fontColor: ColorTheme.kPrimaryColor,
                                borderRadius: 4,
                                title: StringConst.kResetBtnTxt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !sizeInformation.isMobile,
                      child: Align(
                        alignment: FractionalOffset.centerRight,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
                              child: Obx(() {
                                return CustomButton(
                                  isLoading: controller.addButtonLoading.value,
                                  onTap: !controller.addButtonLoading.value
                                      ? () async {
                                          controller.validator = await validationForm(
                                            formData: controller.setDefaultData.formData,
                                            validation: controller.dialogBoxData["formfields"],
                                          );
                                          if (!controller.formKey0.currentState!.validate()) {
                                            controller.validateForm.value = true;
                                            return;
                                          }
                                          controller.validateForm.value = false;
                                          controller.addButtonLoading.value = true;
                                          await controller.handleAddButtonClick(saveAndAdd: false);
                                          controller.addButtonLoading.value = false;
                                        }
                                      : null,
                                  height: 40,
                                  width: 70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  buttonColor: ColorTheme.kPrimaryColor,
                                  fontColor: ColorTheme.kWhite,
                                  borderRadius: 4,
                                  title: btnName,
                                );
                              }),
                            ),
                            if (btnName.toUpperCase() == StringConst.kAddBtnTxt)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
                                child: Obx(() {
                                  return CustomButton(
                                    onTap: !controller.addMultipleButtonLoading.value
                                        ? () async {
                                            controller.validator = await validationForm(
                                              formData: controller.setDefaultData.formData,
                                              validation: controller.dialogBoxData["formfields"],
                                            );
                                            if (!controller.formKey0.currentState!.validate()) {
                                              controller.validateForm.value = true;
                                              return;
                                            }
                                            controller.validateForm.value = false;

                                            controller.addMultipleButtonLoading.value = true;
                                            await controller.handleAddButtonClick(saveAndAdd: true);
                                            controller.addMultipleButtonLoading.value = false;
                                          }
                                        : null,
                                    isLoading: controller.addMultipleButtonLoading.value,
                                    circularProgressColor: ColorTheme.kWhite,
                                    height: 40,
                                    width: 70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    buttonColor: ColorTheme.kPrimaryColor,
                                    fontColor: ColorTheme.kWhite,
                                    borderRadius: 4,
                                    title: saveAndAddBtnName,
                                  );
                                }),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 24, left: 12),
                              child: CustomButton(
                                onTap: () {
                                  controller.formKey0.currentState?.reset();
                                  controller.setFormData(
                                    id: controller.setDefaultData.formData['_id'],
                                    editeDataIndex: controller.setDefaultData.formData['_id'].toString().isNotNullOrEmpty ? controller.initialStateData['lastEditedDataIndex'] : null,
                                  );
                                },
                                height: 40,
                                width: 70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                buttonColor: ColorTheme.kBackGroundGrey,
                                fontColor: ColorTheme.kPrimaryColor,
                                borderRadius: 4,
                                title: StringConst.kResetBtnTxt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            });
          });
        }

        if (deviceType == DeviceScreenType.mobile) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: ColorTheme.kWhite,
            ),
            constraints: BoxConstraints(maxHeight: Get.height * 0.6),
            child: projectForm(),
          );
        }
        return Dialog(
          backgroundColor: ColorTheme.kWhite,
          alignment: Alignment.centerRight,
          shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
          insetPadding: const EdgeInsets.all(0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: ColorTheme.kWhite,
            ),
            width: controller.dialogBoxData['rightsidebarsize'],
            child: projectForm(),
          ),
        );
      },
    );
  }
}
