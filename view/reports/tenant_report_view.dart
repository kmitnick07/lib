import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_checkbox.dart';
import '../../components/customs/custom_text_form_field.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/customs/multi_drop_down_custom.dart';
import '../../components/customs/text_widget.dart';
import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../config/dev/dev_helper.dart';
import '../../config/iis_method.dart';
import '../../controller/reports/tenant_report_controller.dart';
import '../../routes/route_name.dart';
import '../../style/assets_string.dart';
import '../../style/string_const.dart';
import '../../utils/aws_service/file_data_model.dart';

class TenantReportView extends StatelessWidget {
  const TenantReportView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.kScaffoldColor,
        body: GetBuilder(
          init: Get.put(TenantReportController()),
          builder: (controller) {
            return ResponsiveBuilder(builder: (context, sizingInformation) {
              return CommonHeaderFooter(
                title: controller.formName.value,
                txtSearchController: controller.searchController,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              ...List.generate(controller.dialogBoxData["formfields"][0]["formFields"].length, (i) {
                                var res = controller.dialogBoxData["formfields"][0]["formFields"][i];
                                // res['gridsize'] .toString().converttoDouble;
                                var focusOrderCode = generateUniqueFieldId(0, i, null, null);
                                if (!controller.focusNodes.containsKey(focusOrderCode)) {
                                  controller.focusNodes[focusOrderCode] = FocusNode();
                                }
                                switch (res["type"]) {
                                  case HtmlControls.kInputTextArea:
                                    return Obx(() {
                                      var textController = TextEditingController(
                                          text: (controller.setDefaultData.formData)[res["field"]].toString().isEmpty || (controller.setDefaultData.formData)[res["field"]] == null ? "" : (controller.setDefaultData.formData)[res["field"]].toString());
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
                                            },
                                          ));
                                    });

                                  case HtmlControls.kInputText:
                                    return Obx(() {
                                      var textController = TextEditingController(
                                          text: (controller.setDefaultData.formData)[res["field"]].toString().isEmpty || (controller.setDefaultData.formData)[res["field"]] == null ? "" : (controller.setDefaultData.formData)[res["field"]].toString());
                                      if (controller.cursorPos <= textController.text.length) {
                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                      } else {
                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                      }
                                      FocusNode focusNode = controller.focusNodes[focusOrderCode] ?? FocusNode();
                                      // focusNode.addListener(() {
                                      //   focusNode.hasFocus ? textController.selection = TextSelection.collapsed(offset: textController.text.length) : null;
                                      // });
                                      return constrainedBoxWithPadding(
                                          width: res['gridsize'],
                                          child: CustomTextFormField(
                                            focusNode: focusNode,
                                            textInputType: TextInputType.text,
                                            controller: textController,
                                            hintText: "Enter ${res["text"]}",
                                            inputFormatters: [
                                              if (res['field'] == 'email' || res['field'] == 'person_email' || res['field'] == 'personemail')
                                                inputTextEmailRegx
                                              else if (getCurrentPageName() == 'locality' && res['field'] == 'name')
                                                FilteringTextInputFormatter.deny(RegExp("[+.,;:!#\$%^&*=/<>?~]"))
                                              else if (getCurrentPageName() == 'salutation' && res['field'] == 'name')
                                                FilteringTextInputFormatter.deny(RegExp("[+,;:!#\$%^&*=_/<>?~]"))
                                              else if (getCurrentPageName() == 'emailsmtp' && (res['field'] == 'host' || res['field'] == 'username'))
                                                FilteringTextInputFormatter.deny(RegExp("[+,;:!#\$%^&*=_/<>?~]"))
                                              else if (getCurrentPageName() == 'form' && res['field'] == 'name')
                                                FilteringTextInputFormatter.deny(RegExp("[+,;:!#\$%^&*=_<>?~]"))
                                              else if (getCurrentPageName() == 'menu' && (res['field'] == 'menuname' || res['field'] == 'formname'))
                                                FilteringTextInputFormatter.deny(RegExp("[+,;:!#\$%^&*=_<>?~]"))
                                              else if (getCurrentPageName() == 'documenttype' && res['field'] == 'shortcode')
                                                FilteringTextInputFormatter.deny(RegExp("[+,;:!#\$%^&*=_/<>?~]"))
                                              else
                                                inputTextRegx,
                                            ],
                                            showSuffixDivider: (res.containsKey('suffixtext') && res['suffixtext'] != null),
                                            obscureText: (res.containsKey('obscure') && res['obscure'] != null) ? controller.obscureText.value : false,
                                            suffixWidget: ((res.containsKey('obscure') && res['obscure'] != null) || (res.containsKey('suffixtext') && res['suffixtext'] != null))
                                                ? Obx(() {
                                                    return Row(
                                                      children: [
                                                        if (res.containsKey('obscure') && res['obscure'] != null)
                                                          InkResponse(
                                                            onTap: () {
                                                              controller.obscureText.value = !controller.obscureText.value;
                                                            },
                                                            child: Icon(controller.obscureText.value ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                                                          ),
                                                        if (res.containsKey('suffixtext') && res['suffixtext'] != null)
                                                          TextWidget(
                                                            text: res['suffixtext'],
                                                          ),
                                                      ],
                                                    ).paddingSymmetric(horizontal: 4);
                                                  })
                                                : const SizedBox.shrink(),
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
                                            readOnly: res["disabled"],
                                            onChanged: (v) async {
                                              await controller.handleFormData(
                                                key: res["field"],
                                                value: res["text"].toString().toLowerCase().contains("name") ? v.toCamelCase : v,
                                                type: res["type"],
                                              );
                                              controller.cursorPos = textController.selection.extent.offset;
                                            },
                                          ));
                                    });
                                  case HtmlControls.kCheckBox:
                                    return Obx(() {
                                      var textController = TextEditingController(
                                          text: (controller.setDefaultData.formData)[res["field"]].toString().isEmpty || (controller.setDefaultData.formData)[res["field"]] == null ? "" : (controller.setDefaultData.formData)[res["field"]].toString());

                                      return constrainedBoxWithPadding(
                                          width: res['gridsize'],
                                          child: CustomCheckBox(
                                            focusNode: controller.focusNodes[focusOrderCode],
                                            label: res["text"],
                                            value: (controller.setDefaultData.formData)[res["field"]] == 1,
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
                                  case HtmlControls.kMultiSelectDropDown:
                                    var masterdatakey = res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["field"] : res["masterdata"];
                                    return Obx(() {
                                      return constrainedBoxWithPadding(
                                        width: res['gridsize'],
                                        child: MultiDropDownSearchCustom(
                                          selectedItems: List<Map<String, dynamic>>.from(((controller.setDefaultData.formData)[res["field"]]) ?? []),
                                          field: res["field"],
                                          width: (double.tryParse(res['gridsize'].toString())),
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
                                          initValue: ((controller.setDefaultData.formData)[res["field"]] ?? "").toString().isNotNullOrEmpty ? null : (controller.setDefaultData.formData)[res["field"]]?.last,
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
                                            await controller.handleFormData(
                                              key: res["field"],
                                              value: v,
                                              type: res["type"],
                                            );
                                          },
                                        ),
                                      );
                                    });
                                  case HtmlControls.kNumberInput:
                                    return Obx(() {
                                      var textController = TextEditingController(
                                          text: (controller.setDefaultData.formData)[res["field"]].toString().isEmpty || (controller.setDefaultData.formData)[res["field"]] == null ? "" : (controller.setDefaultData.formData)[res["field"]].toString());
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
                                              if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue"))) LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
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
                                    return Obx(
                                      () {
                                        var field = (controller.setDefaultData.formData)[res["field"]] ?? {};
                                        var textController = TextEditingController(text: field['name'] ?? '');
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
                                                controller.setDefaultData.formData[res['field']] != null
                                                    ? Center(
                                                        child: SvgPicture.asset(AssetsString.kUser),
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
                                                            width: 126,
                                                            height: 38,
                                                            borderRadius: 6,
                                                            fontColor: ColorTheme.kWhite,
                                                            onTap: () async {
                                                              List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                              await controller.handleFormData(
                                                                key: res["field"],
                                                                value: fileModelList,
                                                                type: res["type"],
                                                              );
                                                            },
                                                            title: ((controller.setDefaultData.formData[res['field']] ?? '').toString().isNullOrEmpty) ? res['uploadtext'] : res['uploadedtext'],
                                                          );
                                                        }).paddingOnly(right: 6),
                                                        CustomButton(
                                                          width: 126,
                                                          height: 38,
                                                          borderRadius: 6,
                                                          buttonColor: ColorTheme.kBlack.withOpacity(0.1),
                                                          fontColor: ColorTheme.kTextColor,
                                                          onTap: () async {
                                                            await controller.handleFormData(
                                                              key: res["field"],
                                                              value: null,
                                                              type: res["type"],
                                                            );
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
                                  case HtmlControls.kFilePicker:
                                    return Builder(builder: (context) {
                                      RxBool docLoading = false.obs;
                                      return Obx(
                                        () {
                                          var field = (controller.setDefaultData.formData)[res["field"]] ?? {};
                                          var textController = TextEditingController(text: (field['name'] ?? '').toString());
                                          if (controller.cursorPos <= textController.text.length) {
                                            textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                          } else {
                                            textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                          }
                                          return constrainedBoxWithPadding(
                                            width: res['gridsize'],
                                            child: CustomTextFormField(
                                              focusNode: controller.focusNodes[focusOrderCode],
                                              // textInputType: TextInputType.number,
                                              controller: textController,
                                              hintText: "No File Chosen",
                                              readOnly: true,
                                              disableField: res["disabled"],
                                              onTap: () async {
                                                List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                docLoading.value = true;
                                                await controller.handleFormData(
                                                  key: res["field"],
                                                  value: fileModelList,
                                                  type: res["type"],
                                                );
                                                docLoading.value = false;
                                              },
                                              onFieldSubmitted: (v) async {
                                                List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                docLoading.value = true;
                                                await controller.handleFormData(
                                                  key: res["field"],
                                                  value: fileModelList,
                                                  type: res["type"],
                                                );
                                                docLoading.value = false;
                                              },
                                              prefixWidget: docLoading.value
                                                  ? const CupertinoActivityIndicator(color: ColorTheme.kBlack).paddingSymmetric(horizontal: 8)
                                                  : const TextWidget(
                                                      text: 'Choose File',
                                                      fontSize: 14,
                                                      fontWeight: FontTheme.notoRegular,
                                                    ).paddingSymmetric(horizontal: 4),
                                              validator: (v) {
                                                var field = (controller.setDefaultData.formData)[res["field"]] ?? {};
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

                                  case HtmlControls.kDatePicker:
                                    return Obx(
                                      () {
                                        var textController = TextEditingController(
                                            text: ((controller.setDefaultData.formData)[res["field"]] ?? "").toString().isNullOrEmpty
                                                ? ""
                                                : DateFormat("dd-MM-yyyy").format(DateTime.parse((controller.setDefaultData.formData)[res["field"]]).toLocal()).toString());
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
                                              initialDate: ((controller.setDefaultData.formData)[res["field"]] ?? "").toString().isNotNullOrEmpty ? DateTime.parse((controller.setDefaultData.formData)[res["field"]]).toLocal() : DateTime.now(),
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
                                                initialDate: (controller.setDefaultData.formData)[res["field"]].toString().isNotNullOrEmpty ? DateTime.parse((controller.setDefaultData.formData)[res["field"]]).toLocal() : DateTime.now(),
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
                                            // showAddButton: masterRights ? res["inpagemasterdata"] ?? false : false,
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
                              Row(
                                children: [
                                  constrainedBoxWithPadding(
                                    child: CustomButton(
                                      height: 40,
                                      title: 'Generate Report',
                                      width: 30,
                                      borderRadius: 6,
                                      onTap: () {
                                        controller.getList();
                                      },
                                    ),
                                  ),
                                  constrainedBoxWithPadding(
                                    child: CustomButton(
                                      width: 30,
                                      height: 40,
                                      borderRadius: 4,
                                      onTap: () {
                                        controller.exportReport();
                                      },
                                      buttonColor: ColorTheme.kBackGroundGrey,
                                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                      widget: Row(
                                        children: [
                                          SvgPicture.asset(
                                            AssetsString.kExport,
                                            colorFilter: const ColorFilter.mode(ColorTheme.kBlack, BlendMode.srcIn),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const TextWidget(
                                            text: StringConst.kExportBtnTxt,
                                            fontSize: 13,
                                            fontWeight: FontTheme.notoSemiBold,
                                            color: ColorTheme.kBlack,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(border: Border.all(color: ColorTheme.kPrimaryColor, width: 1), borderRadius: BorderRadius.circular(4)),
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    ...List.generate(
                                      controller.setDefaultData.data.length,
                                      (index) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                              child: TextWidget(
                                                text: controller.setDefaultData.data[index]['tenantprojectname'],
                                                fontWeight: FontTheme.notoBold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  color: ColorTheme.kTableHeader,
                                                  child: Table(
                                                    // textDirection: TextDirection.LTR,
                                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                    defaultColumnWidth: const FixedColumnWidth(105),
                                                    border: TableBorder.all(width: 1, color: ColorTheme.kBorderColor),
                                                    children: [
                                                      TableRow(
                                                        children: [
                                                          ...List.generate(
                                                            controller.fieldOrder.length,
                                                            (index) => TableCell(child: TextWidget(text: '${controller.fieldOrder[index]['text']}', fontSize: 14, fontWeight: FontTheme.notoSemiBold).paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          ),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Hutment No", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Tenant Name", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Contact No", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "E-mail", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "X-part", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Eligibility", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Locality", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Annex No", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Survey No", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "SRA Card No", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Year of Structure", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Form 3/4", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Serial No", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Voting List Part", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Cluster Name", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Tenant Status", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Hutment Use", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "House Tax No", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Water Connection", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Electric bill", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Measurement", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Common Consent", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Individual Consent", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Individual Agreement", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Hutment Support", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                          // TableCell(
                                                          //     child: const TextWidget(text: "Status Date", fontSize: 14, fontWeight: FontTheme.notoSemiBold)
                                                          //         .paddingSymmetric(vertical: 8, horizontal: 4)),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Table(
                                                  defaultColumnWidth: const FixedColumnWidth(105),
                                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                  border: TableBorder.all(width: 1, color: ColorTheme.kBorderColor),
                                                  children: [
                                                    for (var rowData in List<Map<String, dynamic>>.from(controller.setDefaultData.data[index]['tenants'])) // Iterate through your data
                                                      TableRow(
                                                        children: [
                                                          ...List.generate(
                                                            controller.fieldOrder.length,
                                                            (index) {
                                                              dynamic field;
                                                              if (controller.fieldOrder[index]['field'] == 'statusdate') {
                                                                field = (rowData["${rowData['tenantstatusid'] ?? ""}_date"] ?? '');
                                                              } else {
                                                                field = rowData[controller.fieldOrder[index]['field']];
                                                              }
                                                              if (field is List) {
                                                                field = field.join(', ');
                                                              }
                                                              field = field.toString().toDateFormat();
                                                              return TableCell(
                                                                child: TextWidget(text: field, fontSize: 12, textAlign: TextAlign.left).paddingSymmetric(horizontal: 4, vertical: 8),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                        // children: [
                                                        //
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['hutmentno'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['tenantname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(
                                                        //               text: (rowData['tenantcontactno'] ?? []).join(", ").toString().toDateFormat(),
                                                        //               fontSize: 12,
                                                        //               textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['tenantemail'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['xpartname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['eligibilityname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['localityname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['annexno'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['surveyno'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['sracardno'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['yearofstructure'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['form3_4'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['serialno'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['votinglistpart'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['clustername'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['tenantstatus'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child:
                                                        //           TextWidget(text: rowData['hutmentusetypename'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //               .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['housetax'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['watertaxbill'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['elecricitybill'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(text: rowData['measurement'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child:
                                                        //           TextWidget(text: rowData['commonconsentname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //               .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(
                                                        //               text: rowData['individualconsentname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(
                                                        //               text: rowData['individualagreementname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child:
                                                        //           TextWidget(text: rowData['hutmentsupportname'].toString().toDateFormat(), fontSize: 12, textAlign: TextAlign.left)
                                                        //               .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        //   TableCell(
                                                        //       child: TextWidget(
                                                        //               text: rowData["${rowData['tenantstatusid'] ?? ""}_date"].toString().toDateFormat(),
                                                        //               fontSize: 12,
                                                        //               textAlign: TextAlign.left)
                                                        //           .paddingSymmetric(horizontal: 4, vertical: 8)),
                                                        // ],
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  ],
                                )),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            });
          },
        ));
  }
}
