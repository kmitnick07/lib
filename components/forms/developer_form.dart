import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_checkbox.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/controller/developer/developer_controller.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config/dev/dev_helper.dart';
import '../../config/iis_method.dart';
import '../../style/assets_string.dart';
import '../../style/string_const.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../customs/custom_text_form_field.dart';
import '../customs/drop_down_search_custom.dart';
import '../customs/multi_drop_down_custom.dart';
import '../funtions.dart';

class DeveloperForm extends StatelessWidget {
  const DeveloperForm({super.key, this.isMasterForm = false, this.title = "Add", this.btnName = StringConst.kAddBtnTxt});

  final bool isMasterForm;
  final String title;
  final String btnName;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizeInformation) {
      Widget developerForm() {
        return GetBuilder(
            init: Get.put(DeveloperController()),
            builder: (DeveloperController controller) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: ColorTheme.kWhite,
                ),
                width: double.parse(controller.dialogBoxData['rightsidebarsize'].toString()),
                child: Form(
                  key: controller.formKey0,
                  autovalidateMode: controller.validateForm.value ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      Container(
                        height: sizeInformation.isMobile ? null : 85,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: ColorTheme.kBorderColor,
                              width: 0.5,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(sizeInformation.isMobile ? 12 : 24),
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
                          physics: const ScrollPhysics(),
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
                                  switch (res["type"]) {
                                    case HtmlControls.kInputTextArea:
                                      return Obx(() {
                                        var textController = TextEditingController(
                                            text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString().isEmpty ||
                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] == null
                                                ? ""
                                                : (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString());
                                        if (controller.cursorPos <= textController.text.length) {
                                          textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                        } else {
                                          textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                        }
                                        return constrainedBoxWithPadding(
                                            width: res['gridsize'],
                                            child: CustomTextFormField(
                                              focusNode: controller.focusNodes[focusOrderCode],
                                              height: 80,
                                              controller: textController,
                                              hintText: "Enter ${res["text"]}",
                                              maxLine: 4,
                                              disableField: res["disabled"],
                                              readOnly: res["disabled"],
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
                                              onChanged: (v) async {
                                                await controller.handleFormData(
                                                  key: res["field"],
                                                  value: v,
                                                  type: res["type"],
                                                );
                                                controller.cursorPos = textController.selection.extent.offset;
                                              },
                                            ));
                                      });

                                    case HtmlControls.kInputText:
                                      return Obx(() {
                                        var textController = TextEditingController(
                                            text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString().isEmpty ||
                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] == null
                                                ? ""
                                                : (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString());
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
                                              showSuffixDivider: (res.containsKey('suffixtext') && res['suffixtext'] != null),
                                              suffixWidget: (res.containsKey('suffixtext') && res['suffixtext'] != null)
                                                  ? TextWidget(
                                                      text: res['suffixtext'],
                                                    ).paddingSymmetric(horizontal: 4)
                                                  : const SizedBox.shrink(),
                                              validator: (v) {
                                                if (controller.validator[res["field"]] ?? false) {
                                                  if (v.toString().isEmpty) {
                                                    return "Please Enter ${res["text"]}";
                                                  } else if (res.containsKey("regex")) {
                                                    if (!RegExp(res["regex"]).hasMatch(res["autocapital"] == true ? v.toUpperCase() : v)) {
                                                      return "Please Enter a valid ${res["text"]}";
                                                    }
                                                  }
                                                }
                                                return null;
                                              },
                                              isRequire: res["required"],
                                              textFieldLabel: res["text"],
                                              readOnly: res["disabled"],
                                              onChanged: (v) async {
                                                await controller.handleFormData(
                                                  key: res["field"],
                                                  value: res["field"].toString().toLowerCase().contains("name")
                                                      ? v.toCamelCase
                                                      : res["autocapital"] == true
                                                          ? v.toUpperCase()
                                                          : v,
                                                  type: res["type"],
                                                );
                                                controller.cursorPos = textController.selection.extent.offset;
                                              },
                                            ));
                                      });

                                    case HtmlControls.kCheckBox:
                                      return Obx(() {
                                        var textController = TextEditingController(
                                            text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString().isEmpty ||
                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] == null
                                                ? ""
                                                : (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString());

                                        return constrainedBoxWithPadding(
                                            width: res['gridsize'],
                                            child: CustomCheckBox(
                                              focusNode: controller.focusNodes[focusOrderCode],
                                              label: res["text"],
                                              value: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] == 1,
                                              onChanged: (v) async {
                                                await controller.handleFormData(
                                                  key: res["field"],
                                                  value: v,
                                                  type: res["type"],
                                                );
                                                controller.cursorPos = textController.selection.extent.offset;
                                              },
                                            ));
                                      });
                                    case HtmlControls.kNumberInput:
                                      return Obx(() {
                                        var textController = TextEditingController(
                                            text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString().isEmpty ||
                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] == null
                                                ? ""
                                                : (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString());
                                        if (controller.cursorPos <= textController.text.length) {
                                          textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                        } else {
                                          textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                        }
                                        return constrainedBoxWithPadding(
                                            width: res['gridsize'],
                                            child: CustomTextFormField(
                                              focusNode: controller.focusNodes[focusOrderCode],
                                              textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                              showSuffixDivider: (res.containsKey('suffixtext') && res['suffixtext'] != null),
                                              suffixWidget: (res.containsKey('suffixtext') && res['suffixtext'] != null)
                                                  ? TextWidget(
                                                      text: res['suffixtext'],
                                                    ).paddingSymmetric(horizontal: 4)
                                                  : const SizedBox.shrink(),
                                              showPrefixDivider: (res.containsKey('prefixtext') && res['prefixtext'] != null),
                                              prefixWidget: (res.containsKey('prefixtext') && res['prefixtext'] != null)
                                                  ? (res.containsKey('prefixtext') && res['prefixtext'] != null)
                                                      ? TextWidget(
                                                          text: res['prefixtext'],
                                                        ).paddingSymmetric(horizontal: 4)
                                                      : const SizedBox.shrink()
                                                  : null,
                                              inputFormatters: [
                                                IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                  LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                              ],
                                              readOnly: res["disabled"],
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
                                                  } else if (res.containsKey("regex")) {
                                                    if (!RegExp(res["regex"]).hasMatch(v)) {
                                                      return "Please Enter a valid ${res["text"]}";
                                                    }
                                                  } else if ((res.containsKey('minvalue') && double.parse(v.toString().isEmpty ? '0' : v.toString()) < res['minvalue']) ||
                                                      (res.containsKey('maxvalue') && double.parse(v) > v['maxvalue']) ||
                                                      (res.containsKey('maxlength') && v.length > res['maxlength']) ||
                                                      (res.containsKey('shouldgreaterthan') && double.parse(v) <= double.parse(controller.setDefaultData.formData[res['shouldgreaterthan']]))) {
                                                    return "Please Enter a valid ${res["text"]}";
                                                  } else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                    return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                  }
                                                }
                                                return null;
                                              },
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

                                    case HtmlControls.kAvatarPicker:
                                      return Builder(builder: (context) {
                                        RxBool docLoading = false.obs;
                                        return Obx(
                                          () {
                                            FilesDataModel field =
                                                FilesDataModel.fromJson((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]);
                                            var textController = TextEditingController(text: field.name ?? '');
                                            if (controller.cursorPos <= textController.text.length) {
                                              textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                            } else {
                                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: res["text"],
                                                        style: TextStyle(
                                                          overflow: TextOverflow.visible,
                                                          fontFamily: FontTheme.themeFontFamily,
                                                          fontWeight: FontTheme.notoRegular,
                                                          color: ColorTheme.kBlack,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      if (res["required"] ?? false)
                                                        const TextSpan(
                                                          text: " *",
                                                          style: TextStyle(
                                                            color: ColorTheme.kPrimaryColor,
                                                            fontSize: 12,
                                                            fontWeight: FontTheme.notoRegular,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ).paddingOnly(bottom: 4),
                                                Row(
                                                  children: [
                                                    field.url != null
                                                        ? Container(
                                                            height: 64,
                                                            width: 64,
                                                            clipBehavior: Clip.hardEdge,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: docLoading.value
                                                                ? const CupertinoActivityIndicator(color: ColorTheme.kBlack).paddingSymmetric(horizontal: 8)
                                                                : Image.network(
                                                                    field.url ?? "",
                                                                    errorBuilder: (context, error, stackTrace) {
                                                                      return SvgPicture.asset(
                                                                        AssetsString.kUser,
                                                                      );
                                                                    },
                                                                  ),
                                                          ).paddingOnly(right: 12)
                                                        : Container(
                                                            height: 64,
                                                            width: 64,
                                                            decoration: BoxDecoration(
                                                              color: ColorTheme.kBlack.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                          ).paddingOnly(right: 12),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Obx(() {
                                                              return CustomButton(
                                                                width: 100,
                                                                height: 38,
                                                                borderRadius: 6,
                                                                fontSize: 14,
                                                                fontColor: ColorTheme.kWhite,
                                                                onTap: () async {
                                                                  List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                  docLoading.value = true;
                                                                  controller.uploadDocCount.value++;
                                                                  await controller.handleFormData(
                                                                    key: res["field"],
                                                                    value: fileModelList,
                                                                    type: res["type"],
                                                                  );
                                                                  docLoading.value = false;
                                                                  controller.uploadDocCount.value--;
                                                                },
                                                                title: ((controller.setDefaultData.formData[res['field']] ?? '').toString().isNullOrEmpty) ? res['uploadtext'] : res['uploadedtext'],
                                                              );
                                                            }).paddingOnly(right: 6),
                                                            CustomButton(
                                                              width: 90,
                                                              height: 38,
                                                              borderRadius: 6,
                                                              buttonColor: ColorTheme.kBlack.withOpacity(0.1),
                                                              fontSize: 14,
                                                              fontColor: ColorTheme.kTextColor,
                                                              onTap: () async {
                                                                docLoading.value = true;
                                                                controller.uploadDocCount.value++;
                                                                await controller.handleFormData(
                                                                  key: res["field"],
                                                                  value: <FilesDataModel>[],
                                                                  type: res["type"],
                                                                );
                                                                docLoading.value = false;
                                                                controller.uploadDocCount.value--;
                                                                devPrint('${controller.setDefaultData.formData[res['field']]}265644624');
                                                              },
                                                              title: res['resettext'],
                                                            ),
                                                          ],
                                                        ).paddingOnly(bottom: 6),
                                                        Wrap(
                                                          children: [
                                                            TextWidget(
                                                              text: res["note"],
                                                              fontSize: 12,
                                                              color: ColorTheme.kTextColor,
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ).paddingSymmetric(horizontal: 6, vertical: 8);
                                          },
                                        );
                                      });
                                    case HtmlControls.kFilePicker:
                                      return Builder(builder: (context) {
                                        RxBool docLoading = false.obs;
                                        return Obx(
                                          () {
                                            var field = (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? {};
                                            var textController = TextEditingController(text: field['name'] ?? '');
                                            if (controller.cursorPos <= textController.text.length) {
                                              textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                            } else {
                                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                            }
                                            return constrainedBoxWithPadding(
                                              width: res['gridsize'],
                                              child: CustomTextFormField(
                                                focusNode: controller.focusNodes[focusOrderCode],
                                                controller: textController,
                                                hintText: "No File Chosen",
                                                readOnly: true,
                                                disableField: res["disabled"],
                                                onTap: () async {
                                                  List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                  docLoading.value = true;
                                                  controller.uploadDocCount.value++;
                                                  await controller.handleFormData(
                                                    key: res["field"],
                                                    value: fileModelList,
                                                    type: res["type"],
                                                  );
                                                  docLoading.value = false;
                                                  controller.uploadDocCount.value--;
                                                },
                                                onFieldSubmitted: (v) async {
                                                  List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                  docLoading.value = true;
                                                  controller.uploadDocCount.value++;
                                                  await controller.handleFormData(
                                                    key: res["field"],
                                                    value: fileModelList,
                                                    type: res["type"],
                                                  );
                                                  docLoading.value = false;
                                                  controller.uploadDocCount.value--;
                                                },
                                                prefixWidget: docLoading.value
                                                    ? const CupertinoActivityIndicator(color: ColorTheme.kBlack).paddingSymmetric(horizontal: 8)
                                                    : const TextWidget(
                                                        text: 'Choose File',
                                                        fontSize: 14,
                                                        fontWeight: FontTheme.notoRegular,
                                                      ).paddingSymmetric(horizontal: 4),
                                                validator: (v) {
                                                  var field = (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? {};
                                                  if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
                                                    if (field['url'].toString().isNullOrEmpty) {
                                                      return "Please Enter ${res["text"]}";
                                                    }
                                                  }
                                                  return null;
                                                },
                                                isRequire: res["required"],
                                                textFieldLabel: res["text"],
                                              ),
                                            );
                                          },
                                        );
                                      });
                                    case HtmlControls.kMultiSelectDropDown:
                                      var masterdatakey = res["masterdata"] /*?? res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["field"] : res["masterdata"]*/;

                                      return Obx(() {
                                        return constrainedBoxWithPadding(
                                          width: res['gridsize'],
                                          child: MultiDropDownSearchCustom(
                                            selectedItems:
                                                List<Map<String, dynamic>>.from(((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]) ?? []),
                                            field: res["field"],
                                            width: res['gridsize'].toString().converttoDouble,
                                            focusNode: controller.focusNodes[focusOrderCode],
                                            dropValidator: (p0) {
                                              // if (p0?.isEmpty == true || p0 == null) {
                                              //   return "Select ${res['text']}";
                                              // }
                                              if (controller.validator[res["field"]] ?? false) {
                                                if (p0?.isEmpty == true || p0 == null) {
                                                  return "Please Select a ${res['text']}";
                                                }
                                              }
                                              return null;
                                            },
                                            items: List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[masterdatakey] ?? []),
                                            initValue: ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? "").toString().isNotNullOrEmpty
                                                ? null
                                                : (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]?.last,
                                            isRequire: res["required"],
                                            textFieldLabel: res["text"],
                                            hintText: "Select ${res["text"]}",
                                            isCleanable: res["cleanable"],
                                            buttonText: res["text"],
                                            clickOnCleanBtn: () async {
                                              await controller.handleFormData(
                                                key: res["field"],
                                                value: "",
                                                type: res["type"],
                                              );
                                            },
                                            isSearchable: res["searchable"],
                                            onChanged: (v) async {
                                              devPrint(v);
                                              await controller.handleFormData(
                                                key: res["field"],
                                                value: v,
                                                type: res["type"],
                                              );
                                            },
                                          ),
                                        );
                                      });
                                    case HtmlControls.kDatePicker:
                                      return Obx(
                                        () {
                                          var textController = TextEditingController(
                                              text: ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? "").toString().isNullOrEmpty
                                                  ? ""
                                                  : DateFormat("dd-MM-yyyy")
                                                      .format(DateTime.parse((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]).toLocal())
                                                      .toString());
                                          if (controller.cursorPos <= textController.text.length) {
                                            textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                          } else {
                                            textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                          }
                                          return constrainedBoxWithPadding(
                                            width: res['gridsize'],
                                            child: CustomTextFormField(
                                              focusNode: controller.focusNodes[focusOrderCode],
                                              controller: textController,
                                              hintText: "Enter ${res["text"]}",
                                              readOnly: true,
                                              disableField: res["disabled"],
                                              onTap: () => showCustomDatePicker(
                                                initialDate:
                                                    ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? "").toString().isNotNullOrEmpty
                                                        ? DateTime.parse((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]).toLocal()
                                                        : DateTime.now(),
                                                onDateSelected: (p0) async {
                                                  await controller.handleFormData(
                                                    key: res["field"],
                                                    value: p0,
                                                    type: res["type"],
                                                  );
                                                },
                                              ),
                                              onFieldSubmitted: (v) async {
                                                showCustomDatePicker(
                                                  initialDate: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]].toString().isNotNullOrEmpty
                                                      ? DateTime.parse((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]).toLocal()
                                                      : DateTime.now(),
                                                  onDateSelected: (p0) async {
                                                    await controller.handleFormData(
                                                      key: res["field"],
                                                      value: p0,
                                                      type: res["type"],
                                                    );
                                                  },
                                                );
                                              },
                                              suffixIcon: AssetsString.kCalender,
                                              validator: (v) {
                                                if (controller.validator[res["field"]] ?? false || res.containsKey("regex")) {
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
                                            ),
                                          );
                                        },
                                      );

                                    case HtmlControls.kDropDown:
                                      return Obx(() {
                                        var masterdatakey = res?["storemasterdatabyfield"] == true ? res["field"] : res["masterdata"];
                                        var list = IISMethods().encryptDecryptObj(controller.setDefaultData.masterData[masterdatakey]);
                                        if (res.containsKey("isselfrefernce") &&
                                            res["isselfrefernce"] &&
                                            (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["isselfreferncefield"]].toString().isNotEmpty) {
                                          list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                            if ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["isselfreferncefield"]] != e["label"]) {
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
                                              buttonText: res["text"],
                                              clickOnAddBtn: () async {},
                                              clickOnCleanBtn: () async {
                                                await controller.handleFormData(
                                                  key: res["field"],
                                                  value: "",
                                                  type: res["type"],
                                                );
                                              },
                                              isSearchable: res["searchable"],
                                              initValue: (list ?? [])
                                                      .where(
                                                          (element) => element["value"] == (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]])
                                                      .toList()
                                                      .isNotEmpty
                                                  ? list
                                                          .where((element) =>
                                                              element["value"] == (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]])
                                                          .toList()
                                                          ?.first ??
                                                      {}
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
                                Obx(() {
                                  return Expanded(
                                    child: CustomButton(
                                      isLoading: controller.addButtonLoading.value,
                                      onTap: (!controller.addButtonLoading.value && controller.uploadDocCount.value == 0)
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
                                              await controller.handleAddButtonClick();
                                              controller.addButtonLoading.value = false;
                                            }
                                          : null,
                                      circularProgressColor: ColorTheme.kWhite,
                                      height: 50,
                                      width: 70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      buttonColor: ColorTheme.kPrimaryColor,
                                      fontColor: ColorTheme.kWhite,
                                      borderRadius: 4,
                                      title: btnName,
                                    ),
                                  );
                                }),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomButton(
                                    onTap: () {
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
                                )
                              ],
                            ),
                          )),
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
                                    onTap: (!controller.addButtonLoading.value && controller.uploadDocCount.value == 0)
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
                                            await controller.handleAddButtonClick();
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
                ),
              );
            });
      }

      if (sizeInformation.isMobile) {
        return Container(
          color: ColorTheme.kWhite,
          child: developerForm(),
        );
      }
      return Dialog(
        backgroundColor: ColorTheme.kWhite,
        alignment: Alignment.centerRight,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
        insetPadding: EdgeInsets.zero,
        child: developerForm(),
      );
    });
  }
}
