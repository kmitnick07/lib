import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_checkbox.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../config/dev/dev_helper.dart';
import '../../config/helper/device_service.dart';
import '../../config/iis_method.dart';
import '../../controller/tenant/tenant_sra_controller.dart';
import '../../routes/route_name.dart';
import '../../style/assets_string.dart';
import '../../style/string_const.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../../view/CommonWidgets/common_table.dart';
import '../customs/custom_text_form_field.dart';
import '../customs/drop_down_search_custom.dart';
import '../customs/multi_drop_down_custom.dart';
import '../funtions.dart';

class TenantSRAForm extends StatelessWidget {
  const TenantSRAForm({super.key, this.isMasterForm = false, this.title = "Add", this.btnName = StringConst.kAddBtnTxt, this.pagename});

  final bool isMasterForm;
  final String title;
  final String btnName;
  final String? pagename;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      Widget userForm() {
        return GetBuilder(
            init: Get.put(TenantSRAController()),
            builder: (TenantSRAController controller) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: ColorTheme.kWhite,
                ),
                width: controller.dialogBoxData['rightsidebarsize'],
                child: Obx(() {
                  return Form(
                    key: controller.formKey0,
                    autovalidateMode: controller.validateForm.value ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: ColorTheme.kBorderColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: controller.dialogBoxData['dataview'] == 'tab' ? 12 : 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text:
                                                '$title ${controller.dialogBoxData['pagename'] == 'tenantproject' ? (controller.setDefaultData.formData['name'].toString().isNullOrEmpty ? 'Tenant Project' : controller.setDefaultData.formData['name']) : controller.dialogBoxData['pagename'] == 'posthandoversra' ? (controller.setDefaultData.formData['tenantname'].toString().isNotNullOrEmpty ? controller.setDefaultData.formData['tenantname'] : 'Post-HandOver SRA') : ''}',
                                            fontWeight: FontWeight.w500,
                                            color: ColorTheme.kPrimaryColor,
                                            textOverflow: TextOverflow.ellipsis,
                                            fontSize: 18,
                                          ),
                                        ],
                                      ),
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
                              Visibility(
                                visible: controller.dialogBoxData['dataview'] == 'tab',
                                child: Container(
                                  height: 52,
                                  padding: sizingInformation.isMobile ? const EdgeInsets.symmetric(horizontal: 0) : const EdgeInsets.symmetric(vertical: 4),
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    interactive: true,
                                    controller: controller.tabScrollController,
                                    child: Obx(() {
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        controller: controller.tabScrollController,
                                        shrinkWrap: true,
                                        // padding: const EdgeInsets.all(4),
                                        itemBuilder: (context, index) {
                                          var tab = controller.dialogBoxData['formfields'][index];
                                          if (tab['defaultvisibility'] == false) {
                                            return const SizedBox.shrink();
                                          }
                                          return AutoScrollTag(
                                            index: index,
                                            controller: controller.tabScrollController,
                                            key: ValueKey(index),
                                            child: SizedBox(
                                              height: 52,
                                              child: InkWell(
                                                focusNode: FocusNode(skipTraversal: true),
                                                onTap: isMasterForm || controller.setDefaultData.formData.containsKey('_id')
                                                    ? () {
                                                        controller.selectedTab.value = index;
                                                        // controller.formScrollController.jumpTo(0);
                                                        controller.dialogBoxData.refresh();
                                                        controller.selectedTab.refresh();
                                                        controller.update();
                                                      }
                                                    : null,
                                                child: Obx(
                                                  () => sizingInformation.isMobile || sizingInformation.isTablet
                                                      ? Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              width: 30,
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                color: controller.selectedTab.value == index ? ColorTheme.kPrimaryColor : ColorTheme.kBackgroundColor,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Center(
                                                                child: TextWidget(
                                                                  text: tab['order'],
                                                                  fontSize: 14,
                                                                  fontWeight: FontTheme.notoMedium,
                                                                  color: controller.selectedTab.value == index ? ColorTheme.kWhite : ColorTheme.kPrimaryColor,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            TextWidget(
                                                              text: tab['title'].toString().replaceAll('{{index}}', ''),
                                                              fontSize: 14,
                                                              fontWeight: FontTheme.notoMedium,
                                                              color: ColorTheme.kPrimaryColor,
                                                              height: 1.2,
                                                            ),
                                                          ],
                                                        )
                                                      : Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              width: 40,
                                                              height: 40,
                                                              decoration: BoxDecoration(
                                                                color: controller.selectedTab.value == index ? ColorTheme.kPrimaryColor : ColorTheme.kBackgroundColor,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Center(
                                                                child: TextWidget(
                                                                  text: tab['order'],
                                                                  fontSize: 18,
                                                                  fontWeight: FontTheme.notoMedium,
                                                                  color: controller.selectedTab.value == index ? ColorTheme.kWhite : ColorTheme.kPrimaryColor,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: sizingInformation.isMobile ? 8 : 16,
                                                            ),
                                                            Obx(() {
                                                              return Visibility(
                                                                visible: (controller.selectedTab.value == index) || sizingInformation.isDesktop,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    TextWidget(
                                                                      text: tab['title'].toString().replaceAll('{{index}}', ''),
                                                                      fontSize: 16,
                                                                      fontWeight: FontTheme.notoMedium,
                                                                      color: ColorTheme.kPrimaryColor,
                                                                      height: 1.1,
                                                                    ),
                                                                    TextWidget(
                                                                      text: tab['subtitle'],
                                                                      fontSize: 12,
                                                                      fontWeight: FontTheme.notoRegular,
                                                                      color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                                                      height: 1.1,
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }),
                                                          ],
                                                        ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          var tab = controller.dialogBoxData['formfields'][index];
                                          if (tab['defaultvisibility'] == false) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: sizingInformation.isMobile ? const EdgeInsets.all(8) : const EdgeInsets.all(12),
                                            child: const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                              ),
                                            ),
                                          );
                                        },
                                        itemCount: controller.dialogBoxData['formfields'].length,
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).paddingOnly(bottom: 4),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            physics: const ScrollPhysics(),
                            itemCount: controller.dialogBoxData['dataview'] == 'tab' ? 1 : controller.dialogBoxData['formfields'].length,
                            padding: EdgeInsets.symmetric(horizontal: sizingInformation.isMobile ? 2 : 16),
                            itemBuilder: (context, index) {
                              jsonPrint(tag: "9864534156324165341", (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData));

                              return Obx(
                                () {
                                  int tabIndex = controller.dialogBoxData['dataview'] == 'tab' ? controller.selectedTab.value : index;
                                  if (controller.dialogBoxData["formfields"][tabIndex]['type'] == HtmlControls.kFieldGroupList) {
                                    // List<Map<String, dynamic>> valueList = List<Map<String, dynamic>>.from(List
                                    //     .from(controller.setDefaultData.formData[tab['field']] ?? [])
                                    //     .isNullOrEmpty ? [<String, dynamic>{}] : controller.setDefaultData.formData[tab['field']]);
                                    // // controller.setDefaultData.formData[tab['field']] = valueList;
                                    //
                                    var tab = controller.dialogBoxData["formfields"][tabIndex];
                                    String groupKey = tab['field'];
                                    return Obx(() {
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: (((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[tab['field']]) ?? []).length,
                                        itemBuilder: (context, listIndex) {
                                          String title = controller.dialogBoxData["formfields"][tabIndex]['title'];
                                          // if (groupKey == 'coapplicant') {
                                          //   if (controller.setDefaultData.formData['coapplicant'][listIndex]['name'].toString().isNotNullOrEmpty) {
                                          //     title = controller.setDefaultData.formData['coapplicant'][listIndex]['name'];
                                          //   }
                                          // }
                                          title = title.replaceAll('{{index}}', '${listIndex + 1}');

                                          return InkWell(
                                            onTap: () {
                                              controller.currentExpandedIndex.value = controller.currentExpandedIndex.value == listIndex ? -1 : listIndex;
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 75,
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Row(
                                                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TextWidget(
                                                              text: '$title Details',
                                                              fontWeight: FontTheme.notoSemiBold,
                                                              fontSize: 18,
                                                              color: ColorTheme.kPrimaryColor,
                                                            ),
                                                            TextWidget(
                                                              text: 'Enter $title Details',
                                                              fontWeight: FontTheme.notoRegular,
                                                              fontSize: 12,
                                                              color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                                            ),
                                                          ],
                                                        ),
                                                        const Spacer(),
                                                        Obx(() {
                                                          return Visibility(
                                                            visible: controller.currentExpandedIndex.value == listIndex && (groupKey != 'rentdetails' || listIndex != 0),
                                                            child: CustomButton(
                                                              focusNode: FocusNode(skipTraversal: true),
                                                              showBoxBorder: true,
                                                              title: 'DELETE',
                                                              borderRadius: 6,
                                                              width: 30,
                                                              height: 36,
                                                              buttonColor: Colors.transparent,
                                                              onTap: () {
                                                                (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[groupKey]
                                                                    .removeAt(listIndex);
                                                                if (isMasterForm) {
                                                                  controller.setDefaultData.masterFormData.refresh();
                                                                } else {
                                                                  controller.setDefaultData.formData.refresh();
                                                                }
                                                              },
                                                              borderColor: ColorTheme.kErrorColor,
                                                              fontColor: ColorTheme.kErrorColor,
                                                              fontSize: 16,
                                                            ),
                                                          );
                                                        }),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),
                                                        Obx(() {
                                                          return Icon(
                                                            controller.currentExpandedIndex.value == listIndex ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                            size: 25,
                                                          );
                                                        })
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Obx(() {
                                                  return Visibility(
                                                    visible: controller.currentExpandedIndex.value == listIndex,
                                                    child: Wrap(
                                                      alignment: WrapAlignment.start,
                                                      children: [
                                                        ...List.generate(controller.dialogBoxData["formfields"][tabIndex]["formFields"].length, (i) {
                                                          var res = IISMethods().encryptDecryptObj(controller.dialogBoxData['formfields'][tabIndex]["formFields"][i]);
                                                          var groupFocusOrderCode = generateUniqueFieldId(listIndex, index, i, null);
                                                          if (!controller.focusNodes.containsKey(groupFocusOrderCode)) {
                                                            controller.focusNodes[groupFocusOrderCode] = FocusNode();
                                                          }
                                                          if (res.containsKey('condition')) {
                                                            Map condition = res['condition'];
                                                            res['defaultvisibility'] = false;
                                                            List<String> fields = List<String>.from(condition.keys.toList());
                                                            for (String field in fields) {
                                                              for (var value in condition[field]) {
                                                                if ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[groupKey]
                                                                        ?[listIndex]?[field] ==
                                                                    value) {
                                                                  res['defaultvisibility'] = true;
                                                                  break;
                                                                }
                                                              }
                                                            }
                                                          }
                                                          if (groupKey == 'rentdetails' &&
                                                              listIndex !=
                                                                  ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[tab['field']] ??
                                                                              [])
                                                                          .length -
                                                                      1) {
                                                            res['disabled'] = true;
                                                          }

                                                          var fieldWidth = res['gridsize'].toString().converttoInt;

                                                          if (res['defaultvisibility'] == false) {
                                                            return const SizedBox.shrink();
                                                          }
                                                          return FocusTraversalOrder(
                                                            order: NumericFocusOrder(groupFocusOrderCode.toString().converttoDouble),
                                                            child: Builder(
                                                              builder: (context) {
                                                                switch (res["type"]) {
                                                                  case HtmlControls.kText:
                                                                    return constrainedBoxWithPadding(
                                                                      width: fieldWidth,
                                                                      child: SizedBox(
                                                                        width: fieldWidth.toString().converttoDouble,
                                                                        child: Align(
                                                                          alignment: Alignment.centerLeft,
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              TextWidget(
                                                                                text: '${res['title']}',
                                                                                fontWeight: FontTheme.notoSemiBold,
                                                                                fontSize: 18,
                                                                                color: ColorTheme.kPrimaryColor,
                                                                              ),
                                                                              TextWidget(
                                                                                text: '${res['subtitle']}',
                                                                                fontWeight: FontTheme.notoRegular,
                                                                                fontSize: 12,
                                                                                color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  case HtmlControls.kInputText:
                                                                    return Obx(
                                                                      () {
                                                                        var textController = TextEditingController(
                                                                            text: (isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                    .toString()
                                                                                    .isNullOrEmpty
                                                                                ? ""
                                                                                : (isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                    .toString());
                                                                        if (controller.cursorPos <= textController.text.length) {
                                                                          textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                        } else {
                                                                          textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                        }
                                                                        return constrainedBoxWithPadding(
                                                                            width: fieldWidth,
                                                                            child: CustomTextFormField(
                                                                              textWidth: fieldWidth.toString().converttoDouble,
                                                                              focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                              textInputType: TextInputType.text,
                                                                              controller: textController,
                                                                              headerRadioLabel: res['radiolabel'],
                                                                              headerRadioValue: res.containsKey('radiofield')
                                                                                  ? (isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[groupKey][listIndex][res['radiofield']] ==
                                                                                      1
                                                                                  : null,
                                                                              headerRadioOnChange: (value) async {
                                                                                isMasterForm
                                                                                    ? await controller.handleMasterFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["radiofield"],
                                                                                        value: value,
                                                                                        type: HtmlControls.kRadio,
                                                                                      )
                                                                                    : await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["radiofield"],
                                                                                        value: value,
                                                                                        type: HtmlControls.kRadio,
                                                                                      );
                                                                              },
                                                                              hintText: "Enter ${res["text"]}",
                                                                              inputFormatters: [
                                                                                if (res['field'].toString().contains('email')) inputTextEmailRegx else inputTextRegx
                                                                              ],
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
                                                                              disableField: res["disabled"],
                                                                              onChanged: (v) async {
                                                                                isMasterForm
                                                                                    ? await controller.handleMasterFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: v,
                                                                                        type: res["type"],
                                                                                      )
                                                                                    : await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: v,
                                                                                        type: res["type"],
                                                                                      );
                                                                                controller.cursorPos = textController.selection.extent.offset;
                                                                              },
                                                                            ));
                                                                      },
                                                                    );
                                                                  case HtmlControls.kDatePicker:
                                                                    return Obx(
                                                                      () {
                                                                        var textController = TextEditingController(
                                                                            text: (isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                    .toString()
                                                                                    .isNullOrEmpty
                                                                                ? ""
                                                                                : (isMasterForm
                                                                                        ? controller.setDefaultData.masterFormData
                                                                                        : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                    .toString());
                                                                        if (controller.cursorPos <= textController.text.length) {
                                                                          textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                        } else {
                                                                          textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                        }
                                                                        return constrainedBoxWithPadding(
                                                                          width: fieldWidth,
                                                                          child: CustomTextFormField(
                                                                            focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                            controller: TextEditingController(
                                                                              text: (isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                      .toString()
                                                                                      .isNullOrEmpty
                                                                                  ? ""
                                                                                  : DateFormat("dd-MM-yyyy")
                                                                                      .format(DateTime.parse((isMasterForm
                                                                                              ? controller.setDefaultData.masterFormData
                                                                                              : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                          .toLocal())
                                                                                      .toString(),
                                                                            ),
                                                                            hintText: "Enter ${res["text"]}",
                                                                            readOnly: true,
                                                                            disableField: res["disabled"],
                                                                            onTap: () => showCustomDatePicker(
                                                                              initialDate: (isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                      .toString()
                                                                                      .isNotNullOrEmpty
                                                                                  ? DateTime.parse((isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                      .toLocal()
                                                                                  : DateTime.now(),
                                                                              onDateSelected: (p0) async {
                                                                                isMasterForm
                                                                                    ? await controller.handleMasterFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: p0,
                                                                                        type: res['type'],
                                                                                      )
                                                                                    : await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: p0,
                                                                                        type: res['type'],
                                                                                      );
                                                                              },
                                                                            ),
                                                                            onFieldSubmitted: (v) async {
                                                                              showCustomDatePicker(
                                                                                initialDate: (isMasterForm
                                                                                            ? controller.setDefaultData.masterFormData
                                                                                            : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                        .toString()
                                                                                        .isNotNullOrEmpty
                                                                                    ? DateTime.parse((isMasterForm
                                                                                            ? controller.setDefaultData.masterFormData
                                                                                            : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                        .toLocal()
                                                                                    : DateTime.now(),
                                                                                onDateSelected: (p0) async {
                                                                                  isMasterForm
                                                                                      ? await controller.handleMasterFormGroupField(
                                                                                          groupKey: groupKey,
                                                                                          index: listIndex,
                                                                                          key: res["field"],
                                                                                          value: p0,
                                                                                          type: res['type'],
                                                                                        )
                                                                                      : await controller.handleFormGroupField(
                                                                                          groupKey: groupKey,
                                                                                          index: listIndex,
                                                                                          key: res["field"],
                                                                                          value: p0,
                                                                                          type: res['type'],
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
                                                                  case HtmlControls.kNumberInput:
                                                                    return Obx(() {
                                                                      var textController = TextEditingController(
                                                                          text: ((isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                                      '')
                                                                                  .toString()
                                                                                  .isNullOrEmpty
                                                                              ? ""
                                                                              : (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                  .toString());
                                                                      if (controller.cursorPos <= textController.text.length) {
                                                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                      } else {
                                                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                      }
                                                                      return constrainedBoxWithPadding(
                                                                          width: fieldWidth,
                                                                          child: CustomTextFormField(
                                                                            focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                            textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                            inputFormatters: [
                                                                              IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                              if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                                LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                              if (res.containsKey("minvalue") && res.containsKey("maxvalue"))
                                                                                LimitRange(res["minvalue"], res["maxvalue"]),
                                                                            ],
                                                                            readOnly: res["disabled"],
                                                                            controller: textController,
                                                                            hintText: "Enter ${res["text"]}",
                                                                            disableField: res["disabled"],
                                                                            suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                ? TextWidget(
                                                                                    text: res['suffixtext'],
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontTheme.notoRegular,
                                                                                  ).paddingSymmetric(
                                                                                    horizontal: 12,
                                                                                  )
                                                                                : null,
                                                                            prefixWidget: (res['prefixtext'] ?? '').toString().isNotNullOrEmpty
                                                                                ? TextWidget(
                                                                                    text: res['prefixtext'],
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontTheme.notoRegular,
                                                                                  ).paddingSymmetric(
                                                                                    horizontal: 12,
                                                                                  )
                                                                                : null,
                                                                            validator: (v) {
                                                                              devPrint(v);
                                                                              if (controller.validator[res["field"]] ?? false) {
                                                                                if (v.toString().isEmpty) {
                                                                                  return "Please Enter ${res["text"]}";
                                                                                } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                                  if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                                    return "Please Enter a valid ${res["text"]}";
                                                                                  }
                                                                                }
                                                                                /*else if (res['minlength'] != null && v.length < res['minlength']) {
                                                                                              return "Please Enter a valid ${res["text"]}";
                                                                                            }*/
                                                                                else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
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
                                                                              isMasterForm
                                                                                  ? await controller.handleMasterFormGroupField(
                                                                                      groupKey: groupKey,
                                                                                      index: listIndex,
                                                                                      key: res["field"],
                                                                                      value: v,
                                                                                      type: res["type"],
                                                                                    )
                                                                                  : await controller.handleFormGroupField(
                                                                                      groupKey: groupKey,
                                                                                      index: listIndex,
                                                                                      key: res["field"],
                                                                                      value: v,
                                                                                      type: res["type"],
                                                                                    );
                                                                              controller.cursorPos = textController.selection.extent.offset;
                                                                            },
                                                                          ));
                                                                    });
                                                                  case HtmlControls.kInputTextArea:
                                                                    return Obx(() {
                                                                      var textController = TextEditingController(
                                                                          text: (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                  .toString()
                                                                                  .isNullOrEmpty
                                                                              ? ""
                                                                              : (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                  .toString());
                                                                      if (controller.cursorPos <= textController.text.length) {
                                                                        textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                      } else {
                                                                        textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                      }
                                                                      return constrainedBoxWithPadding(
                                                                          width: fieldWidth,
                                                                          child: CustomTextFormField(
                                                                            focusNode: controller.focusNodes[groupFocusOrderCode],
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
                                                                              isMasterForm
                                                                                  ? await controller.handleMasterFormGroupField(
                                                                                      groupKey: groupKey,
                                                                                      index: listIndex,
                                                                                      key: res["field"],
                                                                                      value: v,
                                                                                      type: res["type"],
                                                                                    )
                                                                                  : await controller.handleFormGroupField(
                                                                                      groupKey: groupKey,
                                                                                      index: listIndex,
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
                                                                      if (res.containsKey("isselfrefernce") &&
                                                                          res["isselfrefernce"] &&
                                                                          (isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[res["isselfreferncefield"]]
                                                                              .toString()
                                                                              .isNotEmpty) {
                                                                        list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                                                          if ((isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[res["isselfreferncefield"]] !=
                                                                              e["label"]) {
                                                                            return e;
                                                                          }
                                                                        }).toList();
                                                                        list.remove(null);
                                                                      }
                                                                      return constrainedBoxWithPadding(
                                                                        width: fieldWidth,
                                                                        child: DropDownSearchCustom(
                                                                          width: fieldWidth,
                                                                          focusNode: controller.focusNodes[groupFocusOrderCode],
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
                                                                            isMasterForm
                                                                                ? await controller.handleMasterFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: '',
                                                                                    type: res["type"],
                                                                                  )
                                                                                : await controller.handleFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: '',
                                                                                    type: res["type"],
                                                                                  );
                                                                          },
                                                                          isSearchable: res["searchable"],
                                                                          initValue: (list ?? [])
                                                                                  .where((element) =>
                                                                                      element["value"] ==
                                                                                      (isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                  .toList()
                                                                                  .isNotEmpty
                                                                              ? list
                                                                                      .where((element) =>
                                                                                          element["value"] ==
                                                                                          (isMasterForm
                                                                                              ? controller.setDefaultData.masterFormData
                                                                                              : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]])
                                                                                      .toList()
                                                                                      ?.first ??
                                                                                  {}
                                                                              : null,
                                                                          onChanged: (v) async {
                                                                            isMasterForm
                                                                                ? await controller.handleMasterFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: v?['value'],
                                                                                    type: res["type"],
                                                                                  )
                                                                                : await controller.handleFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: v?['value'],
                                                                                    type: res["type"],
                                                                                  );
                                                                          },
                                                                        ),
                                                                      );
                                                                    });
                                                                  case HtmlControls.kFilePicker:
                                                                    return Builder(builder: (context) {
                                                                      RxBool docLoading = false.obs;
                                                                      return Obx(
                                                                        () {
                                                                          FilesDataModel field = FilesDataModel.fromJson((isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                              {});
                                                                          var textController = TextEditingController(text: field.name ?? '');
                                                                          if (controller.cursorPos <= textController.text.length) {
                                                                            textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                          } else {
                                                                            textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                          }
                                                                          if (field.url.toString().isNotNullOrEmpty && field.old == null) {
                                                                            field.old = IISMethods().encryptDecryptObj(field);
                                                                          }
                                                                          return constrainedBoxWithPadding(
                                                                            width: fieldWidth,
                                                                            child: CustomTextFormField(
                                                                              showTitleRowWidget: Map?.from(field.old ?? {}).isNotNullOrEmpty,
                                                                              titleRowWidget: InkWell(
                                                                                  onTap: () {
                                                                                    documentDownload(
                                                                                        imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(field.old ?? {})));
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.visibility_rounded,
                                                                                    size: 15,
                                                                                  )),
                                                                              titleRowWidgetToolTipText: "View ${res["text"]}",
                                                                              focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                              // textInputType: TextInputType.number,
                                                                              controller: textController,
                                                                              hintText: "No File Chosen",
                                                                              readOnly: true,
                                                                              disableField: res["disabled"],
                                                                              onTap: () async {
                                                                                List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                                docLoading.value = true;
                                                                                controller.uploadDocCount.value++;
                                                                                isMasterForm
                                                                                    ? await controller.handleMasterFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: fileModelList,
                                                                                        type: res["type"],
                                                                                      )
                                                                                    : await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
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
                                                                                isMasterForm
                                                                                    ? await controller.handleMasterFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: fileModelList,
                                                                                        type: res["type"],
                                                                                      )
                                                                                    : await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
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
                                                                                      height: 1,
                                                                                      fontWeight: FontTheme.notoRegular,
                                                                                    ).paddingSymmetric(horizontal: 4),
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
                                                                    });
                                                                  case HtmlControls.kImagePicker:
                                                                    return Builder(builder: (context) {
                                                                      RxBool docLoading = false.obs;
                                                                      return Obx(
                                                                        () {
                                                                          FilesDataModel field = FilesDataModel.fromJson((isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                              {});
                                                                          var textController = TextEditingController(text: field.name ?? '');
                                                                          if (controller.cursorPos <= textController.text.length) {
                                                                            textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                          } else {
                                                                            textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                                          }
                                                                          if (field.url.isNotNullOrEmpty && field.old == null) {
                                                                            field.old = IISMethods().encryptDecryptObj(field);
                                                                          }
                                                                          return constrainedBoxWithPadding(
                                                                            width: fieldWidth,
                                                                            child: CustomTextFormField(
                                                                              showTitleRowWidget: Map?.from(field.old ?? {}).isNotNullOrEmpty,
                                                                              titleRowWidget: InkWell(
                                                                                  onTap: () {
                                                                                    documentDownload(
                                                                                        imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(field.old ?? {})));
                                                                                  },
                                                                                  child: const Icon(
                                                                                    Icons.visibility_rounded,
                                                                                    size: 15,
                                                                                  )),
                                                                              titleRowWidgetToolTipText: "View ${res["text"]}",
                                                                              focusNode: controller.focusNodes[groupFocusOrderCode],
                                                                              // textInputType: TextInputType.number,
                                                                              controller: textController,
                                                                              hintText: "No File Chosen",
                                                                              readOnly: true,
                                                                              disableField: res["disabled"],
                                                                              onTap: () async {
                                                                                List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                                docLoading.value = true;
                                                                                controller.uploadDocCount.value++;
                                                                                isMasterForm
                                                                                    ? await controller.handleMasterFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: fileModelList,
                                                                                        type: res["type"],
                                                                                      )
                                                                                    : await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
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
                                                                                isMasterForm
                                                                                    ? await controller.handleMasterFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
                                                                                        key: res["field"],
                                                                                        value: fileModelList,
                                                                                        type: res["type"],
                                                                                      )
                                                                                    : await controller.handleFormGroupField(
                                                                                        groupKey: groupKey,
                                                                                        index: listIndex,
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
                                                                                      text: 'Choose Image',
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontTheme.notoRegular,
                                                                                    ).paddingSymmetric(horizontal: 4),
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
                                                                    });
                                                                  case HtmlControls.kMultiSelectDropDown:
                                                                    var masterdatakey = res[
                                                                        "masterdata"] /*?? res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["field"] : res["masterdata"]*/;
                                                                    return Obx(() {
                                                                      return constrainedBoxWithPadding(
                                                                        width: fieldWidth,
                                                                        child: MultiDropDownSearchCustom(
                                                                          selectedItems: List<Map<String, dynamic>>.from(((isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]) ??
                                                                              []),
                                                                          field: res["field"],
                                                                          width: fieldWidth.toDouble(),
                                                                          focusNode: controller.focusNodes[groupFocusOrderCode],
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
                                                                          initValue: ((isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]] ??
                                                                                      "")
                                                                                  .toString()
                                                                                  .isNotNullOrEmpty
                                                                              ? null
                                                                              : (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[groupKey][listIndex][res["field"]]
                                                                                  ?.last,
                                                                          isRequire: res["required"],
                                                                          textFieldLabel: res["text"],
                                                                          hintText: "Select ${res["text"]}",
                                                                          isCleanable: res["cleanable"],
                                                                          buttonText: res["text"],
                                                                          clickOnCleanBtn: () async {
                                                                            isMasterForm
                                                                                ? await controller.handleMasterFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: '',
                                                                                    type: res["type"],
                                                                                  )
                                                                                : await controller.handleFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: '',
                                                                                    type: res["type"],
                                                                                  );
                                                                          },
                                                                          isSearchable: res["searchable"],
                                                                          onChanged: (v) async {
                                                                            isMasterForm
                                                                                ? await controller.handleMasterFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: v,
                                                                                    type: res["type"],
                                                                                  )
                                                                                : await controller.handleFormGroupField(
                                                                                    groupKey: groupKey,
                                                                                    index: listIndex,
                                                                                    key: res["field"],
                                                                                    value: v,
                                                                                    type: res["type"],
                                                                                  );
                                                                          },
                                                                        ),
                                                                      );
                                                                    });
                                                                  default:
                                                                    return Container(
                                                                      color: ColorTheme.kRed,
                                                                      width: 100,
                                                                      height: 200,
                                                                    );
                                                                }
                                                              },
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                                const Divider(),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox.shrink();
                                        },
                                      );
                                    });
                                  }

                                  ///
                                  return Wrap(
                                    children: [
                                      ...List.generate(controller.dialogBoxData["formfields"][tabIndex]["formFields"].length, (i) {
                                        var res = controller.dialogBoxData["formfields"][tabIndex]["formFields"][i];
                                        var focusOrderCode = generateUniqueFieldId(tabIndex, i, null, null);
                                        if (!controller.focusNodes.containsKey(focusOrderCode)) {
                                          controller.focusNodes[focusOrderCode] = FocusNode();
                                        }
                                        if (res.containsKey('condition')) {
                                          Map condition = res['condition'];
                                          res['defaultvisibility'] = false;
                                          List<String> fields = List<String>.from(condition.keys.toList());
                                          for (String field in fields) {
                                            for (var value in condition[field]) {
                                              if ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[field] == value) {
                                                res['defaultvisibility'] = true;
                                                break;
                                              }
                                            }
                                          }
                                        }
                                        if (res['defaultvisibility'] == false) {
                                          return const SizedBox.shrink();
                                        }
                                        switch (res["type"]) {
                                          case HtmlControls.kEmptyBlock:
                                            return SizedBox(
                                              height: res['height'].toString().converttoDouble,
                                            );
                                          case HtmlControls.kInputTextArea:
                                            return Obx(() {
                                              var textController = TextEditingController(
                                                  text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]
                                                              .toString()
                                                              .isEmpty ||
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
                                                      isMasterForm
                                                          ? await controller.handleMasterFormData(
                                                              key: res["field"],
                                                              value: v,
                                                              type: res["type"],
                                                            )
                                                          : await controller.handleFormData(
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
                                                  text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]
                                                              .toString()
                                                              .isEmpty ||
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
                                                    inputFormatters: [
                                                      if (res['field'].toString().contains('email'))
                                                        inputTextEmailRegx
                                                      else if (getCurrentPageName() == 'tenantproject' && (res['field'] == 'latitude' || res['field'] == 'longitude'))
                                                        FilteringTextInputFormatter.deny(RegExp("[+,;:!#\$%^&*=_/<>?~]"))
                                                      else
                                                        inputTextRegx
                                                    ],
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
                                                          if (!RegExp(res["regex"]).hasMatch(v)) {
                                                            return "Please Enter a valid ${res["text"]}";
                                                          }
                                                        }
                                                      }
                                                      return null;
                                                    },
                                                    isRequire: res["required"],
                                                    showToolTip: res["tooltip"].toString().isNotNullOrEmpty,
                                                    toolTipText: res["tooltip"] ?? "",
                                                    textFieldLabel: res["text"],
                                                    disableField: res["disabled"],
                                                    onChanged: (v) async {
                                                      isMasterForm
                                                          ? await controller.handleMasterFormData(
                                                              key: res["field"],
                                                              value: res["field"].toString().toLowerCase().contains("name") ? v.toCamelCase : v,
                                                              type: res["type"],
                                                            )
                                                          : await controller.handleFormData(
                                                              key: res["field"],
                                                              value: res["field"].toString().toLowerCase().contains("name") ? v.toCamelCase : v,
                                                              type: res["type"],
                                                            );
                                                      controller.cursorPos = textController.selection.extent.offset;
                                                    },
                                                  ));
                                            });

                                          case HtmlControls.kCheckBox:
                                            return Obx(() {
                                              var textController = TextEditingController(
                                                  text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]
                                                              .toString()
                                                              .isEmpty ||
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
                                                      isMasterForm
                                                          ? await controller.handleMasterFormData(
                                                              key: res["field"],
                                                              value: v,
                                                              type: res["type"],
                                                            )
                                                          : await controller.handleFormData(
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
                                                  text: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]
                                                              .toString()
                                                              .isEmpty ||
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
                                                        }
                                                        /*else if (res.containsKey('minlength') && res['minlength'] > v.toString().length) {
                                                      return "Please Enter a valid ${res["text"]}";
                                                    }*/
                                                        else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
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
                                                      isMasterForm
                                                          ? await controller.handleMasterFormData(
                                                              key: res["field"],
                                                              value: v,
                                                              type: res["type"],
                                                            )
                                                          : await controller.handleFormData(
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
                                                FilesDataModel field = FilesDataModel.fromJson(
                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? {});
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
                                                                  image: DecorationImage(
                                                                    image: NetworkImage(field.url ?? ""),
                                                                    fit: BoxFit.fill,
                                                                  ),
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
                                                                    width: 126,
                                                                    height: 38,
                                                                    borderRadius: 6,
                                                                    fontColor: ColorTheme.kWhite,
                                                                    onTap: () async {
                                                                      List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                      isMasterForm
                                                                          ? await controller.handleMasterFormData(
                                                                              key: res["field"],
                                                                              value: fileModelList,
                                                                              type: res["type"],
                                                                            )
                                                                          : await controller.handleFormData(
                                                                              key: res["field"],
                                                                              value: fileModelList,
                                                                              type: res["type"],
                                                                            );
                                                                    },
                                                                    title: ((controller.setDefaultData.formData[res['field']] ?? '').toString().isNullOrEmpty)
                                                                        ? res['uploadtext']
                                                                        : res['uploadedtext'],
                                                                  );
                                                                }).paddingOnly(right: 6),
                                                                CustomButton(
                                                                  width: 126,
                                                                  height: 38,
                                                                  borderRadius: 6,
                                                                  buttonColor: ColorTheme.kBlack.withOpacity(0.1),
                                                                  fontColor: ColorTheme.kTextColor,
                                                                  onTap: () async {
                                                                    isMasterForm
                                                                        ? await controller.handleMasterFormData(
                                                                            key: res["field"],
                                                                            value: null,
                                                                            type: res["type"],
                                                                          )
                                                                        : await controller.handleFormData(
                                                                            key: res["field"],
                                                                            value: null,
                                                                            type: res["type"],
                                                                          );
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
                                                  FilesDataModel field = FilesDataModel.fromJson(
                                                      (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? {});
                                                  var textController = TextEditingController(text: field.name ?? '');
                                                  if (controller.cursorPos <= textController.text.length) {
                                                    textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                  } else {
                                                    textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                  }
                                                  if (field.url.isNotNullOrEmpty && field.old == null) {
                                                    field.old = IISMethods().encryptDecryptObj(field);
                                                  }
                                                  return constrainedBoxWithPadding(
                                                    width: res['gridsize'],
                                                    child: CustomTextFormField(
                                                      showTitleRowWidget: Map?.from(field.old ?? {}).isNotNullOrEmpty,
                                                      titleRowWidget: InkWell(
                                                          onTap: () {
                                                            documentDownload(imageList: FilesDataModel.fromJson(Map<String, dynamic>.from(field.old ?? {})));
                                                          },
                                                          child: const Icon(
                                                            Icons.visibility_rounded,
                                                            size: 15,
                                                          )),
                                                      titleRowWidgetToolTipText: "View ${res["text"]}",
                                                      focusNode: controller.focusNodes[focusOrderCode],
                                                      // textInputType: TextInputType.number,
                                                      controller: textController,
                                                      hintText: "No File Chosen",
                                                      readOnly: true,
                                                      disableField: res["disabled"],
                                                      onTap: () async {
                                                        List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                        docLoading.value = true;
                                                        controller.uploadDocCount.value++;
                                                        isMasterForm
                                                            ? await controller.handleMasterFormData(
                                                                key: res["field"],
                                                                value: fileModelList,
                                                                type: res["type"],
                                                              )
                                                            : await controller.handleFormData(
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
                                                        isMasterForm
                                                            ? await controller.handleMasterFormData(
                                                                key: res["field"],
                                                                value: fileModelList,
                                                                type: res["type"],
                                                              )
                                                            : await controller.handleFormData(
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
                                                        var field =
                                                            (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? {};
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
                                            var masterdatakey = res[
                                                "masterdata"] /*?? res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["field"] : res["masterdata"]*/;
                                            devPrint('DATA ${controller.setDefaultData.masterData[masterdatakey]}');
                                            devPrint(
                                                'SELECTED ${List<Map<String, dynamic>>.from(((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]) ?? [])}');
                                            return Obx(() {
                                              return constrainedBoxWithPadding(
                                                width: res['gridsize'].toString().converttoInt,
                                                child: MultiDropDownSearchCustom(
                                                  selectedItems: List<Map<String, dynamic>>.from(
                                                    ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]) ?? [],
                                                  ),
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
                                                  initValue: ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? "")
                                                          .toString()
                                                          .isNotNullOrEmpty
                                                      ? null
                                                      : (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]?.last,
                                                  isRequire: res["required"],
                                                  textFieldLabel: res["text"],
                                                  hintText: "Select ${res["text"]}",
                                                  isCleanable: res["cleanable"],

                                                  buttonText: res["text"],
                                                  clickOnCleanBtn: () async {
                                                    isMasterForm
                                                        ? await controller.handleMasterFormData(
                                                            key: res["field"],
                                                            value: "",
                                                            type: res["type"],
                                                          )
                                                        : await controller.handleFormData(
                                                            key: res["field"],
                                                            value: "",
                                                            type: res["type"],
                                                          );
                                                  },
                                                  isSearchable: res["searchable"],
                                                  onChanged: (v) async {
                                                    isMasterForm
                                                        ? await controller.handleMasterFormData(
                                                            key: res["field"],
                                                            value: v,
                                                            type: res["type"],
                                                          )
                                                        : await controller.handleFormData(
                                                            key: res["field"],
                                                            value: v,
                                                            type: res["type"],
                                                          );
                                                    devPrint(controller.setDefaultData.formData[res["field"]]);
                                                  },
                                                  // initValue: controller.setDefaultData[widget.formKey][res["field"]].join(","),
                                                  // onChanged: (v) async {
                                                  //   print(v);
                                                  //   await widget.handleFormData(
                                                  //     key: res["field"],
                                                  //     value: v,
                                                  //     type: res["type"],
                                                  //   );
                                                  //   await Future.delayed(
                                                  //       const Duration(milliseconds: 500));
                                                  //   setState(() {});
                                                  // },
                                                ),
                                              );
                                            });

                                          case HtmlControls.kDatePicker:
                                            return Obx(
                                              () {
                                                var textController = TextEditingController(
                                                    text: ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? "")
                                                            .toString()
                                                            .isNullOrEmpty
                                                        ? ""
                                                        : DateFormat("dd MMM yyyy")
                                                            .format(DateTime.parse(
                                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]])
                                                                .toLocal())
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
                                                          ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? "")
                                                                  .toString()
                                                                  .isNotNullOrEmpty
                                                              ? DateTime.parse(
                                                                      (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]])
                                                                  .toLocal()
                                                              : DateTime.now(),
                                                      onDateSelected: (p0) async {
                                                        isMasterForm
                                                            ? await controller.handleMasterFormData(
                                                                key: res["field"],
                                                                value: p0,
                                                                type: res["type"],
                                                              )
                                                            : await controller.handleFormData(
                                                                key: res["field"],
                                                                value: p0,
                                                                type: res["type"],
                                                              );
                                                      },
                                                    ),
                                                    onFieldSubmitted: (v) async {
                                                      showCustomDatePicker(
                                                        initialDate: (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]]
                                                                .toString()
                                                                .isNotNullOrEmpty
                                                            ? DateTime.parse(
                                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]])
                                                                .toLocal()
                                                            : DateTime.now(),
                                                        onDateSelected: (p0) async {
                                                          isMasterForm
                                                              ? await controller.handleMasterFormData(
                                                                  key: res["field"],
                                                                  value: p0,
                                                                  type: res["type"],
                                                                )
                                                              : await controller.handleFormData(
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
                                                        if (v.toString().isNullOrEmpty) {
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
                                                  (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["isselfreferncefield"]]
                                                      .toString()
                                                      .isNotEmpty) {
                                                list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                                  if ((isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["isselfreferncefield"]] !=
                                                      e["label"]) {
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
                                                      isMasterForm
                                                          ? await controller.handleMasterFormData(
                                                              key: res["field"],
                                                              value: "",
                                                              type: res["type"],
                                                            )
                                                          : await controller.handleFormData(
                                                              key: res["field"],
                                                              value: "",
                                                              type: res["type"],
                                                            );
                                                    },
                                                    isSearchable: res["searchable"],
                                                    initValue: (list ?? [])
                                                            .where((element) =>
                                                                element["value"] ==
                                                                (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]])
                                                            .toList()
                                                            .isNotEmpty
                                                        ? list
                                                                .where((element) =>
                                                                    element["value"] ==
                                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]])
                                                                .toList()
                                                                ?.first ??
                                                            {}
                                                        : null,
                                                    onChanged: (v) async {
                                                      isMasterForm
                                                          ? await controller.handleMasterFormData(
                                                              key: res["field"],
                                                              value: v!["value"],
                                                              type: res["type"],
                                                            )
                                                          : await controller.handleFormData(
                                                              key: res["field"],
                                                              value: v!["value"],
                                                              type: res["type"],
                                                            );
                                                    },
                                                  ));
                                            });

                                          case HtmlControls.kTable:
                                            return Builder(builder: (context) {
                                              RxString searchText = ''.obs;
                                              TextEditingController searchController = TextEditingController();

                                              return StatefulBuilder(builder: (ctx, setState) {
                                                // devPrint('SEARCHED');
                                                return constrainedBoxWithPadding(
                                                  width: controller.dialogBoxData['rightsidebarsize'].toString().converttoInt,
                                                  child: SizedBox(
                                                    height: 650,
                                                    child: Column(
                                                      children: [
                                                        // Visibility(
                                                        //     visible: sizingInformation.isMobile,
                                                        //     child: Column(
                                                        //       mainAxisAlignment: MainAxisAlignment.start,
                                                        //       crossAxisAlignment: CrossAxisAlignment.start,
                                                        //       children: [
                                                        //         const SizedBox(height: 5),
                                                        //         TextWidget(text: res['text'] ?? '', fontSize: 14, fontWeight: FontTheme.notoMedium),
                                                        //         const SizedBox(height: 10),
                                                        //         CustomTextFormField(
                                                        //           controller: searchController,
                                                        //           showSuffixDivider: false,
                                                        //           suffixWidget: const Padding(
                                                        //             padding: EdgeInsets.all(8.0),
                                                        //             child: Icon(
                                                        //               Icons.search,
                                                        //             ),
                                                        //           ),
                                                        //           hintText: 'Search',
                                                        //           onChanged: (value) {
                                                        //             searchText.value = value;
                                                        //             setState(
                                                        //               () {},
                                                        //             );
                                                        //           },
                                                        //         ),
                                                        //       ],
                                                        //     )),
                                                        if (pagename == 'managerassign') ...[
                                                          Visibility(
                                                            visible: !sizingInformation.isMobile,
                                                            replacement: Column(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              children: [
                                                                Obx(() {
                                                                  var res = controller.dialogBoxData["formfields"][tabIndex]["formFields"][0];
                                                                  var masterdatakey = res?["storemasterdatabyfield"] == true ? res["field"] : res["masterdata"];
                                                                  var list = IISMethods().encryptDecryptObj(controller.setDefaultData.masterData[masterdatakey]);
                                                                  if (res.containsKey("isselfrefernce") &&
                                                                      res["isselfrefernce"] &&
                                                                      (isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["isselfreferncefield"]]
                                                                          .toString()
                                                                          .isNotEmpty) {
                                                                    list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                                                      if ((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["isselfreferncefield"]] !=
                                                                          e["label"]) {
                                                                        return e;
                                                                      }
                                                                    }).toList();
                                                                    list.remove(null);
                                                                  }
                                                                  return SizedBox(
                                                                    width: res['gridsize'].toDouble(),
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
                                                                        isMasterForm
                                                                            ? await controller.handleMasterFormData(
                                                                                key: res["field"],
                                                                                value: "",
                                                                                type: res["type"],
                                                                              )
                                                                            : await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: "",
                                                                                type: res["type"],
                                                                              );
                                                                      },
                                                                      isSearchable: res["searchable"],
                                                                      initValue: (list ?? [])
                                                                              .where((element) =>
                                                                                  element["value"] ==
                                                                                  (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]])
                                                                              .toList()
                                                                              .isNotEmpty
                                                                          ? list
                                                                                  .where((element) =>
                                                                                      element["value"] ==
                                                                                      (isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[res["field"]])
                                                                                  .toList()
                                                                                  ?.first ??
                                                                              {}
                                                                          : null,
                                                                      onChanged: (v) async {
                                                                        isMasterForm
                                                                            ? await controller.handleMasterFormData(
                                                                                key: res["field"],
                                                                                value: v!["value"],
                                                                                type: res["type"],
                                                                              )
                                                                            : await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: v!["value"],
                                                                                type: res["type"],
                                                                              );
                                                                      },
                                                                    ),
                                                                  );
                                                                }),
                                                                const SizedBox(
                                                                  height: 8,
                                                                ),
                                                                SizedBox(
                                                                  width: 600,
                                                                  child: CustomTextFormField(
                                                                    controller: searchController,
                                                                    showSuffixDivider: false,
                                                                    suffixWidget: const Padding(
                                                                      padding: EdgeInsets.all(8.0),
                                                                      child: Icon(
                                                                        Icons.search,
                                                                      ),
                                                                    ),
                                                                    hintText: 'Search',
                                                                    onChanged: (value) {
                                                                      searchText.value = value;
                                                                      setState(
                                                                        () {},
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.end,
                                                              children: [
                                                                Obx(() {
                                                                  var res = controller.dialogBoxData["formfields"][tabIndex]["formFields"][0];
                                                                  var masterdatakey = res?["storemasterdatabyfield"] == true ? res["field"] : res["masterdata"];
                                                                  var list = IISMethods().encryptDecryptObj(controller.setDefaultData.masterData[masterdatakey]);
                                                                  if (res.containsKey("isselfrefernce") &&
                                                                      res["isselfrefernce"] &&
                                                                      (isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["isselfreferncefield"]]
                                                                          .toString()
                                                                          .isNotEmpty) {
                                                                    list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                                                      if ((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res["isselfreferncefield"]] !=
                                                                          e["label"]) {
                                                                        return e;
                                                                      }
                                                                    }).toList();
                                                                    list.remove(null);
                                                                  }
                                                                  return SizedBox(
                                                                    width: res['gridsize'].toDouble(),
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
                                                                        isMasterForm
                                                                            ? await controller.handleMasterFormData(
                                                                                key: res["field"],
                                                                                value: "",
                                                                                type: res["type"],
                                                                              )
                                                                            : await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: "",
                                                                                type: res["type"],
                                                                              );
                                                                      },
                                                                      isSearchable: res["searchable"],
                                                                      initValue: (list ?? [])
                                                                              .where((element) =>
                                                                                  element["value"] ==
                                                                                  (isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res["field"]])
                                                                              .toList()
                                                                              .isNotEmpty
                                                                          ? list
                                                                                  .where((element) =>
                                                                                      element["value"] ==
                                                                                      (isMasterForm
                                                                                          ? controller.setDefaultData.masterFormData
                                                                                          : controller.setDefaultData.formData)[res["field"]])
                                                                                  .toList()
                                                                                  ?.first ??
                                                                              {}
                                                                          : null,
                                                                      onChanged: (v) async {
                                                                        isMasterForm
                                                                            ? await controller.handleMasterFormData(
                                                                                key: res["field"],
                                                                                value: v!["value"],
                                                                                type: res["type"],
                                                                              )
                                                                            : await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: v!["value"],
                                                                                type: res["type"],
                                                                              );
                                                                      },
                                                                    ),
                                                                  );
                                                                }),
                                                                SizedBox(
                                                                  width: 300,
                                                                  child: CustomTextFormField(
                                                                    controller: searchController,
                                                                    showSuffixDivider: false,
                                                                    suffixWidget: const Padding(
                                                                      padding: EdgeInsets.all(8.0),
                                                                      child: Icon(
                                                                        Icons.search,
                                                                      ),
                                                                    ),
                                                                    hintText: 'Search',
                                                                    onChanged: (value) {
                                                                      searchText.value = value;
                                                                      setState(
                                                                        () {},
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 4, top: 8),
                                                            child: Container(
                                                              height: 24,
                                                              width: Get.width,
                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                              decoration: ShapeDecoration(
                                                                color: ColorTheme.kBackGroundGrey,
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                                              ),
                                                              child: TextWidget(
                                                                text: res['text'] ?? '',
                                                                color: ColorTheme.kBlack,
                                                                fontSize: 14,
                                                                fontWeight: FontTheme.notoSemiBold,
                                                                height: 1,
                                                              ).paddingOnly(top: 2),
                                                            ),
                                                          ),
                                                        ],
                                                        Expanded(
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                              color: ColorTheme.kBorderColor,
                                                            )),
                                                            child: Obx(() {
                                                              return CommonDataTableWidget(
                                                                width: (sizingInformation.isMobile
                                                                        ? MediaQuery.of(context).size.width
                                                                        : controller.dialogBoxData['rightsidebarsize']) -
                                                                    65,
                                                                setDefaultData: controller.setDefaultData,
                                                                handleGridChange: (index, field, type, value, masterfieldname, name) {
                                                                  if (type == 'checkbox') {
                                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res['field']]
                                                                        [index][field] = value ? 1 : 0;
                                                                    if (!value && res['field'] == 'paymentconfiguration') {
                                                                      (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res['field']]
                                                                          [index]['paymentto'] = null;
                                                                      ((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res['field']] ??
                                                                          [])[index]['wbscode'] = '';
                                                                    }
                                                                  } else if (type == HtmlControls.kMultiSelectDropDown) {
                                                                    Map<String, dynamic> field1 =
                                                                        List<Map<String, dynamic>>.from(res['fieldorder']).firstWhere((element) => element['field'] == field);
                                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res['field']]
                                                                        [index]['isSelected'] = 1;
                                                                    (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res['field']]
                                                                        [index][field] = List<String>.from(value ?? []).map((e) {
                                                                      return {
                                                                        '${field1['field']}id': e,
                                                                        field1['field']: List<Map<String, dynamic>>.from(controller.setDefaultData.masterData[res['masterdata']])
                                                                            .firstWhere((element) => element['value'] == e)['label']
                                                                      };
                                                                    }).toList();
                                                                    int i = ((((isMasterForm
                                                                                    ? controller.setDefaultData.masterFormData
                                                                                    : controller.setDefaultData.formData)[res['field']] ??
                                                                                [])[index]['paymentto'] as List?) ??
                                                                            [])
                                                                        .indexWhere(
                                                                      (element) {
                                                                        return element['paymenttoid'] == '6639aaed2a3062b9e51b015f';
                                                                      },
                                                                    );
                                                                    if (i == -1) {
                                                                      ((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res['field']] ??
                                                                          [])[index]['wbscode'] = '';
                                                                    }
                                                                  }
                                                                  if (isMasterForm) {
                                                                    controller.setDefaultData.masterFormData.refresh();
                                                                  } else {
                                                                    controller.setDefaultData.formData.refresh();
                                                                  }
                                                                },
                                                                widgetBuilder: (index, field, context) {
                                                                  TextEditingController texteditingcontroller = TextEditingController(
                                                                      text: ((isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res['field']] ??
                                                                                  [])[index][field]
                                                                              .toString()
                                                                              .isNullOrEmpty
                                                                          ? ''
                                                                          : ((isMasterForm
                                                                                      ? controller.setDefaultData.masterFormData
                                                                                      : controller.setDefaultData.formData)[res['field']] ??
                                                                                  [])[index][field]
                                                                              .toString());
                                                                  if (controller.cursorPos <= texteditingcontroller.text.length) {
                                                                    texteditingcontroller.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                                  } else {
                                                                    texteditingcontroller.selection = TextSelection.collapsed(offset: texteditingcontroller.text.length);
                                                                  }
                                                                  int i = ((((isMasterForm
                                                                                  ? controller.setDefaultData.masterFormData
                                                                                  : controller.setDefaultData.formData)[res['field']] ??
                                                                              [])[index]['paymentto'] as List?) ??
                                                                          [])
                                                                      .indexWhere(
                                                                    (element) {
                                                                      return element['paymenttoid'] == '6639aaed2a3062b9e51b015f';
                                                                    },
                                                                  );

                                                                  return CustomTextFormField(
                                                                    controller: texteditingcontroller,
                                                                    disableField: i == -1,
                                                                    hintText: 'WBS Code',
                                                                    onChanged: (p0) {
                                                                      ((isMasterForm
                                                                              ? controller.setDefaultData.masterFormData
                                                                              : controller.setDefaultData.formData)[res['field']] ??
                                                                          [])[index][field] = p0;
                                                                      if (isMasterForm) {
                                                                        controller.setDefaultData.masterFormData.refresh();
                                                                      } else {
                                                                        controller.setDefaultData.formData.refresh();
                                                                        jsonPrint(controller.setDefaultData.formData);
                                                                      }
                                                                      controller.cursorPos = texteditingcontroller.selection.extent.offset;
                                                                    },
                                                                  );
                                                                },
                                                                fieldOrder: List<Map<String, dynamic>>.from(res['fieldorder']),
                                                                data: List<Map<String, dynamic>>.from(
                                                                  IISMethods().encryptDecryptObj(List<Map<String, dynamic>>.from((isMasterForm
                                                                          ? controller.setDefaultData.masterFormData
                                                                          : controller.setDefaultData.formData)[res['field']] ??
                                                                      [])),
                                                                ).where((element) {
                                                                  // for (var field in List<Map<String, dynamic>>.from(res['fieldorder'])) {
                                                                  //   // devPrint('$field ---> ${element[field['field']]} ---> $searchText ---->${element[field['field']].toString().toLowerCase().contains( searchText.toString().toLowerCase())}');
                                                                  //   return element[field['field']].toString().toLowerCase().contains( searchText.toString().toLowerCase());
                                                                  // }

                                                                  devPrint('FIELD--->${res['field'] == 'paymentconfiguration'}');
                                                                  if (res['field'] == 'paymentconfiguration') {
                                                                    return true;
                                                                  }
                                                                  if (element['name'].toString().toLowerCase().contains(searchText.toString().toLowerCase())) {
                                                                    return true;
                                                                  }
                                                                  if (element['teamleadname'].toString().toLowerCase().contains(searchText.toString().toLowerCase())) {
                                                                    return true;
                                                                  }
                                                                  if ((element['teammember'] as List)
                                                                      .map((e) => e['teammember'])
                                                                      .toList()
                                                                      .join(',')
                                                                      .toLowerCase()
                                                                      .contains(searchText.toString().toLowerCase())) {
                                                                    return true;
                                                                  }
                                                                  return false;
                                                                }).toList(),
                                                                showPagination: false,
                                                                tableScrollController: controller.tableScrollController,
                                                                infoPopUpWidget: (index) {
                                                                  var data = List<Map<String, dynamic>>.from(
                                                                    IISMethods().encryptDecryptObj(List<Map<String, dynamic>>.from((isMasterForm
                                                                            ? controller.setDefaultData.masterFormData
                                                                            : controller.setDefaultData.formData)[res['field']] ??
                                                                        [])),
                                                                  ).where((element) {
                                                                    if (element['name'].toString().toLowerCase().contains(searchText.toString().toLowerCase())) {
                                                                      return true;
                                                                    }
                                                                    if (element['teamleadname'].toString().toLowerCase().contains(searchText.toString().toLowerCase())) {
                                                                      return true;
                                                                    }
                                                                    if ((element['teammember'] as List)
                                                                        .map((e) => e['teammember'])
                                                                        .toList()
                                                                        .join(',')
                                                                        .toLowerCase()
                                                                        .contains(searchText.toString().toLowerCase())) {
                                                                      return true;
                                                                    }
                                                                    return false;
                                                                  }).toList()[index];

                                                                  return ListView.separated(
                                                                    itemBuilder: (context, index) {
                                                                      var memberId = (data['teammember'] as List)[index]['employeeid'];
                                                                      var member = (data['teammember'] as List)[index]['teammember'];
                                                                      return Row(
                                                                        children: [
                                                                          Container(
                                                                            height: 45,
                                                                            width: 45,
                                                                            clipBehavior: Clip.hardEdge,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(24),
                                                                            ),
                                                                            child: Image.network(
                                                                              FilesDataModel.fromJson((data['teammember'] as List)[index]['photo'] ?? {}).url ?? "",
                                                                              fit: BoxFit.cover,
                                                                              errorBuilder: (context, error, stackTrace) {
                                                                                return SvgPicture.asset(
                                                                                  AssetsString.kUser,
                                                                                );
                                                                              },
                                                                            ),
                                                                          ).paddingSymmetric(horizontal: 12),
                                                                          Expanded(
                                                                            child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                TextWidget(
                                                                                  text: member ?? "",
                                                                                  color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontTheme.notoSemiBold,
                                                                                ).paddingOnly(bottom: 2),
                                                                                SelectableText(
                                                                                  "EMP. ID: $memberId",
                                                                                  style: TextStyle(
                                                                                    color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontTheme.notoSemiBold,
                                                                                  ),
                                                                                ).paddingOnly(bottom: 4),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                    shrinkWrap: true,
                                                                    separatorBuilder: (context, index) {
                                                                      return const Divider(
                                                                        color: ColorTheme.kBorderColor,
                                                                        thickness: 0.5,
                                                                      );
                                                                    },
                                                                    itemCount: (data['teammember'] as List).length,
                                                                  );
                                                                },
                                                              );
                                                            }),
                                                          ).paddingOnly(top: 10),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                            });
                                          case HtmlControls.kMultipleTextFieldWithTitle:
                                            return Obx(() {
                                              List list = (isMasterForm ? controller.setDefaultData.masterFormData : controller.setDefaultData.formData)[res["field"]] ?? [];
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (list.isNotNullOrEmpty)
                                                    constrainedBoxWithPadding(
                                                      child: TextWidget(
                                                        textAlign: TextAlign.left,
                                                        text: res['text'],
                                                        textOverflow: TextOverflow.visible,
                                                        fontFamily: FontTheme.themeFontFamily,
                                                        fontWeight: FontTheme.notoRegular,
                                                        color: ColorTheme.kBlack,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  Wrap(children: [
                                                    ...List.generate(
                                                      list.length,
                                                      (index) {
                                                        return Builder(builder: (ctx) {
                                                          String title =
                                                              (list[index][res['titlefield']] ?? '').toString().isNullOrEmpty ? "" : list[index][res['titlefield']].toString();
                                                          var textController = TextEditingController(
                                                              text:
                                                                  (list[index][res['inputfield']] ?? '').toString().isNullOrEmpty ? "" : list[index][res['inputfield']].toString());
                                                          if (controller.cursorPos <= textController.text.length) {
                                                            textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                          } else {
                                                            textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                          }
                                                          int unqKey = generateSubFieldId(focusOrderCode, index, 0);
                                                          if (!controller.focusNodes.containsKey(unqKey)) {
                                                            controller.focusNodes[unqKey] = FocusNode();
                                                          }
                                                          return constrainedBoxWithPadding(
                                                              width: res['gridsize'],
                                                              child: CustomTextFormField(
                                                                focusNode: controller.focusNodes[unqKey],
                                                                // textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                                // inputFormatters: [
                                                                //   IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                                //   if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                                //     LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                                //   if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                                                // ],
                                                                readOnly: res["disabled"],
                                                                controller: textController,
                                                                hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                                disableField: res["disabled"],
                                                                suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                                    ? TextWidget(
                                                                        text: res['suffixtext'],
                                                                        fontSize: 14,
                                                                        fontWeight: FontTheme.notoRegular,
                                                                      ).paddingSymmetric(
                                                                        horizontal: 12,
                                                                      )
                                                                    : null,
                                                                prefixIconConstraints: BoxConstraints.tightFor(width: res['gridsize'] / 2, height: 40),
                                                                prefixWidget: title.isNotNullOrEmpty
                                                                    ? ConstrainedBox(
                                                                        constraints: BoxConstraints.tightFor(
                                                                          width: res['gridsize'] / 2,
                                                                        ),
                                                                        child: TextWidget(
                                                                          text: title,
                                                                          fontSize: 14,
                                                                          fontWeight: FontTheme.notoRegular,
                                                                        ).paddingSymmetric(
                                                                          horizontal: 12,
                                                                        ),
                                                                      )
                                                                    : null,
                                                                validator: (v) {
                                                                  // if (controller.validator[res["field"]] ?? false) {
                                                                  if (v.toString().isEmpty) {
                                                                    if (res['required'] == false) {
                                                                      return null;
                                                                    }
                                                                    return "Please Enter ${res["text"]}";
                                                                  } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                                    if (!RegExp(res["regex"]).hasMatch(v)) {
                                                                      return "Please Enter a valid ${res["text"]}";
                                                                    }
                                                                  }
                                                                  /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                                                      return "Please Enter a valid ${res["text"]}";
                                                                                    }*/
                                                                  else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                                    return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                                  }
                                                                  // }
                                                                  return null;
                                                                },
                                                                isRequire: res["required"],
                                                                onChanged: (v) async {
                                                                  list[index][res['inputfield']] = v;
                                                                  isMasterForm
                                                                      ? await controller.handleMasterFormData(
                                                                          key: res["field"],
                                                                          value: list,
                                                                          type: res["type"],
                                                                        )
                                                                      : await controller.handleFormData(
                                                                          key: res["field"],
                                                                          value: list,
                                                                          type: res["type"],
                                                                        );
                                                                  controller.cursorPos = textController.selection.extent.offset;
                                                                },
                                                              ));
                                                          // return constrainedBoxWithPadding(
                                                          //     width: fieldWidth,
                                                          //     child: Row(
                                                          //       children: [
                                                          //         Expanded(
                                                          //           child: CustomTextFormField(
                                                          //             focusNode:FocusNode(skipTraversal: true),
                                                          //             textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                          //             readOnly: true,
                                                          //             controller: TextEditingController(text: title),
                                                          //             hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                          //             disableField: res["disabled"],
                                                          //             suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                          //                 ? TextWidget(
                                                          //                     text: res['suffixtext'],
                                                          //                     fontSize: 14,
                                                          //                     fontWeight: FontTheme.notoRegular,
                                                          //                   ).paddingSymmetric(
                                                          //                     horizontal: 12,
                                                          //                   )
                                                          //                 : null,
                                                          //             // prefixIconConstraints: BoxConstraints.tightFor(width: fieldWidth / 2, height: 40),
                                                          //             // prefixWidget: title.isNotNullOrEmpty
                                                          //             //     ? ConstrainedBox(
                                                          //             //         constraints: BoxConstraints.tightFor(
                                                          //             //           width: fieldWidth / 2,
                                                          //             //         ),
                                                          //             //         child: TextWidget(
                                                          //             //           text: title,
                                                          //             //           fontSize: 14,
                                                          //             //           fontWeight: FontTheme.notoRegular,
                                                          //             //         ).paddingSymmetric(
                                                          //             //           horizontal: 12,
                                                          //             //         ),
                                                          //             //       )
                                                          //             //     : null,
                                                          //             validator: (v) {
                                                          //               // if (controller.validator[res["field"]] ?? false) {
                                                          //               if (v.toString().isEmpty) {
                                                          //                 if (res['required'] == false) {
                                                          //                   return null;
                                                          //                 }
                                                          //                 return "Please Enter ${res["text"]}";
                                                          //               } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                          //                 if (!RegExp(res["regex"]).hasMatch(v)) {
                                                          //                   return "Please Enter a valid ${res["text"]}";
                                                          //                 }
                                                          //               }
                                                          //               /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                          //                 return "Please Enter a valid ${res["text"]}";
                                                          //               }*/
                                                          //               else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                          //                 return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                          //               }
                                                          //               // }
                                                          //               return null;
                                                          //             },
                                                          //             isRequire: res["required"],
                                                          //             onChanged: (v) async {
                                                          //               list[index][res['inputfield']] = v;
                                                          //               await controller.handleFormData(
                                                          //                 key: res["field"],
                                                          //                 value: list,
                                                          //                 type: res["type"],
                                                          //               );
                                                          //               controller.cursorPos = textController.selection.extent.offset;
                                                          //             },
                                                          //           ),
                                                          //         ),
                                                          //         const SizedBox(width: 8,),
                                                          //         Expanded(
                                                          //           child: CustomTextFormField(
                                                          //             focusNode: controller.focusNodes[unqKey],
                                                          //             textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                          //             inputFormatters: [
                                                          //               IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                          //               if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                          //                 LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                          //               if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                                          //             ],
                                                          //             readOnly: res["disabled"],
                                                          //             controller: textController,
                                                          //             hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                          //             disableField: res["disabled"],
                                                          //             // suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                          //             //     ? TextWidget(
                                                          //             //         text: res['suffixtext'],
                                                          //             //         fontSize: 14,
                                                          //             //         fontWeight: FontTheme.notoRegular,
                                                          //             //       ).paddingSymmetric(
                                                          //             //         horizontal: 12,
                                                          //             //       )
                                                          //             //     : null,
                                                          //             // prefixIconConstraints: BoxConstraints.tightFor(width: fieldWidth / 2, height: 40),
                                                          //             // prefixWidget: title.isNotNullOrEmpty
                                                          //             //     ? ConstrainedBox(
                                                          //             //         constraints: BoxConstraints.tightFor(
                                                          //             //           width: fieldWidth / 2,
                                                          //             //         ),
                                                          //             //         child: TextWidget(
                                                          //             //           text: title,
                                                          //             //           fontSize: 14,
                                                          //             //           fontWeight: FontTheme.notoRegular,
                                                          //             //         ).paddingSymmetric(
                                                          //             //           horizontal: 12,
                                                          //             //         ),
                                                          //             //       )
                                                          //             //     : null,
                                                          //             validator: (v) {
                                                          //               // if (controller.validator[res["field"]] ?? false) {
                                                          //               if (v.toString().isEmpty) {
                                                          //                 if (res['required'] == false) {
                                                          //                   return null;
                                                          //                 }
                                                          //                 return "Please Enter ${res["text"]}";
                                                          //               } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                          //                 if (!RegExp(res["regex"]).hasMatch(v)) {
                                                          //                   return "Please Enter a valid ${res["text"]}";
                                                          //                 }
                                                          //               }
                                                          //               /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                          //                 return "Please Enter a valid ${res["text"]}";
                                                          //               }*/
                                                          //               else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                          //                 return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                          //               }
                                                          //               // }
                                                          //               return null;
                                                          //             },
                                                          //             isRequire: res["required"],
                                                          //             onChanged: (v) async {
                                                          //               list[index][res['inputfield']] = v;
                                                          //               await controller.handleFormData(
                                                          //                 key: res["field"],
                                                          //                 value: list,
                                                          //                 type: res["type"],
                                                          //               );
                                                          //               controller.cursorPos = textController.selection.extent.offset;
                                                          //             },
                                                          //           ),
                                                          //         ),
                                                          //       ],
                                                          //     ));
                                                        });
                                                      },
                                                    )
                                                  ]),
                                                  // ListView.builder(
                                                  //   itemCount: list.length,
                                                  //   physics: const NeverScrollableScrollPhysics(),
                                                  //   shrinkWrap: true,
                                                  //   itemBuilder: (context, index) {
                                                  //     return Builder(builder: (ctx) {
                                                  //       String title = (list[index][res['titlefield']] ?? '').toString().isNullOrEmpty ? "" : list[index][res['titlefield']].toString();
                                                  //       var textController =
                                                  //           TextEditingController(text: (list[index][res['inputfield']] ?? '').toString().isNullOrEmpty ? "" : list[index][res['inputfield']].toString());
                                                  //       if (controller.cursorPos <= textController.text.length) {
                                                  //         textController.selection = TextSelection.collapsed(offset: controller.cursorPos);
                                                  //       } else {
                                                  //         textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                                  //       }
                                                  //       int unqKey = generateSubFieldId(focusOrderCode, index, 0);
                                                  //       if (!controller.focusNodes.containsKey(unqKey)) {
                                                  //         controller.focusNodes[unqKey] = FocusNode();
                                                  //       }
                                                  //       return constrainedBoxWithPadding(
                                                  //           width: res['gridsize'],
                                                  //           child: CustomTextFormField(
                                                  //             focusNode: controller.focusNodes[unqKey],
                                                  //             textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                  //             inputFormatters: [
                                                  //               IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                  //               if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                  //                 LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                  //               if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                                  //             ],
                                                  //             readOnly: res["disabled"],
                                                  //             controller: textController,
                                                  //             hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                  //             disableField: res["disabled"],
                                                  //             suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                  //                 ? TextWidget(
                                                  //                     text: res['suffixtext'],
                                                  //                     fontSize: 14,
                                                  //                     fontWeight: FontTheme.notoRegular,
                                                  //                   ).paddingSymmetric(
                                                  //                     horizontal: 12,
                                                  //                   )
                                                  //                 : null,
                                                  //             prefixIconConstraints: BoxConstraints.tightFor(width: res['gridsize'] / 2, height: 40),
                                                  //             prefixWidget: title.isNotNullOrEmpty
                                                  //                 ? ConstrainedBox(
                                                  //                     constraints: BoxConstraints.tightFor(
                                                  //                       width: res['gridsize'] / 2,
                                                  //                     ),
                                                  //                     child: TextWidget(
                                                  //                       text: title,
                                                  //                       fontSize: 14,
                                                  //                       fontWeight: FontTheme.notoRegular,
                                                  //                     ).paddingSymmetric(
                                                  //                       horizontal: 12,
                                                  //                     ),
                                                  //                   )
                                                  //                 : null,
                                                  //             validator: (v) {
                                                  //               // if (controller.validator[res["field"]] ?? false) {
                                                  //               if (v.toString().isEmpty) {
                                                  //                 if (res['required'] == false) {
                                                  //                   return null;
                                                  //                 }
                                                  //                 return "Please Enter ${res["text"]}";
                                                  //               } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                  //                 if (!RegExp(res["regex"]).hasMatch(v)) {
                                                  //                   return "Please Enter a valid ${res["text"]}";
                                                  //                 }
                                                  //               }
                                                  //               /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                  //                                         return "Please Enter a valid ${res["text"]}";
                                                  //                                       }*/
                                                  //               else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                  //                 return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                  //               }
                                                  //               // }
                                                  //               return null;
                                                  //             },
                                                  //             isRequire: res["required"],
                                                  //             onChanged: (v) async {
                                                  //               list[index][res['inputfield']] = v;
                                                  //               await controller.handleFormData(
                                                  //                 key: res["field"],
                                                  //                 value: list,
                                                  //                 type: res["type"],
                                                  //               );
                                                  //               controller.cursorPos = textController.selection.extent.offset;
                                                  //             },
                                                  //           ));
                                                  //       // return constrainedBoxWithPadding(
                                                  //       //     width: fieldWidth,
                                                  //       //     child: Row(
                                                  //       //       children: [
                                                  //       //         Expanded(
                                                  //       //           child: CustomTextFormField(
                                                  //       //             focusNode:FocusNode(skipTraversal: true),
                                                  //       //             textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                  //       //             readOnly: true,
                                                  //       //             controller: TextEditingController(text: title),
                                                  //       //             hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                  //       //             disableField: res["disabled"],
                                                  //       //             suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                  //       //                 ? TextWidget(
                                                  //       //                     text: res['suffixtext'],
                                                  //       //                     fontSize: 14,
                                                  //       //                     fontWeight: FontTheme.notoRegular,
                                                  //       //                   ).paddingSymmetric(
                                                  //       //                     horizontal: 12,
                                                  //       //                   )
                                                  //       //                 : null,
                                                  //       //             // prefixIconConstraints: BoxConstraints.tightFor(width: fieldWidth / 2, height: 40),
                                                  //       //             // prefixWidget: title.isNotNullOrEmpty
                                                  //       //             //     ? ConstrainedBox(
                                                  //       //             //         constraints: BoxConstraints.tightFor(
                                                  //       //             //           width: fieldWidth / 2,
                                                  //       //             //         ),
                                                  //       //             //         child: TextWidget(
                                                  //       //             //           text: title,
                                                  //       //             //           fontSize: 14,
                                                  //       //             //           fontWeight: FontTheme.notoRegular,
                                                  //       //             //         ).paddingSymmetric(
                                                  //       //             //           horizontal: 12,
                                                  //       //             //         ),
                                                  //       //             //       )
                                                  //       //             //     : null,
                                                  //       //             validator: (v) {
                                                  //       //               // if (controller.validator[res["field"]] ?? false) {
                                                  //       //               if (v.toString().isEmpty) {
                                                  //       //                 if (res['required'] == false) {
                                                  //       //                   return null;
                                                  //       //                 }
                                                  //       //                 return "Please Enter ${res["text"]}";
                                                  //       //               } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                  //       //                 if (!RegExp(res["regex"]).hasMatch(v)) {
                                                  //       //                   return "Please Enter a valid ${res["text"]}";
                                                  //       //                 }
                                                  //       //               }
                                                  //       //               /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                  //       //                 return "Please Enter a valid ${res["text"]}";
                                                  //       //               }*/
                                                  //       //               else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                  //       //                 return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                  //       //               }
                                                  //       //               // }
                                                  //       //               return null;
                                                  //       //             },
                                                  //       //             isRequire: res["required"],
                                                  //       //             onChanged: (v) async {
                                                  //       //               list[index][res['inputfield']] = v;
                                                  //       //               await controller.handleFormData(
                                                  //       //                 key: res["field"],
                                                  //       //                 value: list,
                                                  //       //                 type: res["type"],
                                                  //       //               );
                                                  //       //               controller.cursorPos = textController.selection.extent.offset;
                                                  //       //             },
                                                  //       //           ),
                                                  //       //         ),
                                                  //       //         const SizedBox(width: 8,),
                                                  //       //         Expanded(
                                                  //       //           child: CustomTextFormField(
                                                  //       //             focusNode: controller.focusNodes[unqKey],
                                                  //       //             textInputType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                  //       //             inputFormatters: [
                                                  //       //               IISMethods().decimalPointRgex(res?['decimalpoint']),
                                                  //       //               if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue")))
                                                  //       //                 LengthLimitingTextInputFormatter(res?['maxlength'] ?? 10),
                                                  //       //               if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                                  //       //             ],
                                                  //       //             readOnly: res["disabled"],
                                                  //       //             controller: textController,
                                                  //       //             hintText: res['hinttext'] ?? "Enter ${res["text"]}",
                                                  //       //             disableField: res["disabled"],
                                                  //       //             // suffixWidget: (res['suffixtext'] ?? '').toString().isNotNullOrEmpty
                                                  //       //             //     ? TextWidget(
                                                  //       //             //         text: res['suffixtext'],
                                                  //       //             //         fontSize: 14,
                                                  //       //             //         fontWeight: FontTheme.notoRegular,
                                                  //       //             //       ).paddingSymmetric(
                                                  //       //             //         horizontal: 12,
                                                  //       //             //       )
                                                  //       //             //     : null,
                                                  //       //             // prefixIconConstraints: BoxConstraints.tightFor(width: fieldWidth / 2, height: 40),
                                                  //       //             // prefixWidget: title.isNotNullOrEmpty
                                                  //       //             //     ? ConstrainedBox(
                                                  //       //             //         constraints: BoxConstraints.tightFor(
                                                  //       //             //           width: fieldWidth / 2,
                                                  //       //             //         ),
                                                  //       //             //         child: TextWidget(
                                                  //       //             //           text: title,
                                                  //       //             //           fontSize: 14,
                                                  //       //             //           fontWeight: FontTheme.notoRegular,
                                                  //       //             //         ).paddingSymmetric(
                                                  //       //             //           horizontal: 12,
                                                  //       //             //         ),
                                                  //       //             //       )
                                                  //       //             //     : null,
                                                  //       //             validator: (v) {
                                                  //       //               // if (controller.validator[res["field"]] ?? false) {
                                                  //       //               if (v.toString().isEmpty) {
                                                  //       //                 if (res['required'] == false) {
                                                  //       //                   return null;
                                                  //       //                 }
                                                  //       //                 return "Please Enter ${res["text"]}";
                                                  //       //               } else if (v.toString().isNotEmpty && res.containsKey("regex")) {
                                                  //       //                 if (!RegExp(res["regex"]).hasMatch(v)) {
                                                  //       //                   return "Please Enter a valid ${res["text"]}";
                                                  //       //                 }
                                                  //       //               }
                                                  //       //               /*else if (res.containsKey("minlength") && res['minlength'] > v.toString().length) {
                                                  //       //                 return "Please Enter a valid ${res["text"]}";
                                                  //       //               }*/
                                                  //       //               else if ((res.containsKey('minlength') && v.length < res['minlength'])) {
                                                  //       //                 return "${res["text"]} should be minimum ${res["minlength"]} digit long";
                                                  //       //               }
                                                  //       //               // }
                                                  //       //               return null;
                                                  //       //             },
                                                  //       //             isRequire: res["required"],
                                                  //       //             onChanged: (v) async {
                                                  //       //               list[index][res['inputfield']] = v;
                                                  //       //               await controller.handleFormData(
                                                  //       //                 key: res["field"],
                                                  //       //                 value: list,
                                                  //       //                 type: res["type"],
                                                  //       //               );
                                                  //       //               controller.cursorPos = textController.selection.extent.offset;
                                                  //       //             },
                                                  //       //           ),
                                                  //       //         ),
                                                  //       //       ],
                                                  //       //     ));
                                                  //     });
                                                  //   },
                                                  // ),
                                                ],
                                              );
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
                              );
                            },
                          ),
                        ),
                        Visibility(
                          visible: sizingInformation.isMobile,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Obx(() {
                                  return Visibility(
                                    visible: controller.dialogBoxData['formfields'][controller.selectedTab.value]['type'] == HtmlControls.kFieldGroupList,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
                                      child: CustomButton(
                                        borderWidth: 1,
                                        buttonColor: Colors.transparent,
                                        borderColor: ColorTheme.kBlack,
                                        height: 38,
                                        showBoxBorder: true,
                                        width: sizingInformation.isDesktop ? 50 : 30,
                                        onTap: () {
                                          (isMasterForm
                                                  ? controller.setDefaultData.masterFormData
                                                  : controller.setDefaultData.formData)[controller.dialogBoxData['formfields'][controller.selectedTab.value]['field']]
                                              .add(<String, dynamic>{});
                                          controller.currentExpandedIndex.value = ((isMasterForm
                                                      ? controller.setDefaultData.masterFormData
                                                      : controller.setDefaultData.formData)[controller.dialogBoxData['formfields'][controller.selectedTab.value]['field']])
                                                  .length -
                                              1;
                                          if (isMasterForm) {
                                            controller.setDefaultData.masterFormData.refresh();
                                          } else {
                                            controller.setDefaultData.formData.refresh();
                                          }
                                        },
                                        borderRadius: 4,
                                        widget: Row(
                                          children: [
                                            if (sizingInformation.isDesktop)
                                              const Icon(
                                                Icons.add,
                                                color: ColorTheme.kBlack,
                                              ),
                                            if (sizingInformation.isDesktop)
                                              const SizedBox(
                                                width: 4,
                                              ),
                                            TextWidget(
                                              text: 'ADD ${controller.dialogBoxData['formfields'][controller.selectedTab.value]['addbuttontext'].toString().toUpperCase()}',
                                              color: ColorTheme.kBlack,
                                              fontWeight: FontTheme.notoMedium,
                                              fontSize: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
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
                                              if (isMasterForm) {
                                                controller.handleMasterAddButtonClick(pagename: pagename);
                                              } else {
                                                if (pagename == 'tenantproject' && controller.selectedTab.value == 1) {
                                                  int selectedCount = 0;
                                                  int errorIndex = (controller.setDefaultData.formData['paymentconfiguration'] as List).indexWhere(
                                                    (element) {
                                                      if (element['isSelected'] == 1) {
                                                        selectedCount++;
                                                      }
                                                      devPrint('element--->$element');
                                                      return (element['isSelected'] == 1 && (element['paymentto'] as List?).isNullOrEmpty);
                                                    },
                                                  );
                                                  devPrint('selectedCount $selectedCount');
                                                  devPrint('errorIndex $errorIndex');
                                                  if (selectedCount == 0 || errorIndex != -1) {
                                                    showError('Select Atleast 1 Payment Type');
                                                    controller.addButtonLoading.value = false;
                                                    return;
                                                  }
                                                }
                                                await controller.handleAddButtonClick();
                                              }
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
                                  );
                                }),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomButton(
                                    onTap: () async {
                                      controller.formKey0.currentState?.reset();
                                      if (isMasterForm) {
                                        controller.setMasterFormData(
                                          id: controller.setDefaultData.masterData['_id'],
                                          editeDataIndex:
                                              controller.setDefaultData.masterData['_id'].toString().isNotNullOrEmpty ? controller.initialStateData['lastEditedDataIndex'] : null,
                                          parentId: controller.setDefaultData.masterData['tenantprojectid'],
                                          page: controller.dialogBoxData['pagename'],
                                          canSwitchTab: false,
                                        );
                                      } else if (pagename == "managerassign") {
                                        controller.setMasterFormData(parentId: controller.setDefaultData.formData['_id'], page: 'managerassign');
                                        await controller.setUserInTable(controller.setDefaultData.formData['_id']);
                                        controller.setDefaultData.masterFormData.refresh();
                                      } else if (pagename == "paymentconfiguration") {
                                        controller.setMasterFormData(parentId: controller.setDefaultData.formData['_id'], page: 'managerassign');
                                        await controller.setPaymentInTable(controller.setDefaultData.formData['_id']);
                                        controller.setDefaultData.masterFormData.refresh();
                                      } else {
                                        controller.setFormData(
                                          canSwitchTab: false,
                                          id: controller.setDefaultData.formData['_id'],
                                          editeDataIndex:
                                              controller.setDefaultData.formData['_id'].toString().isNotNullOrEmpty ? controller.initialStateData['lastEditedDataIndex'] : null,
                                        );
                                      }
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
                          visible: !sizingInformation.isMobile,
                          child: Align(
                            alignment: FractionalOffset.centerRight,
                            child: Row(
                              children: [
                                Obx(() {
                                  return Visibility(
                                    visible: controller.dialogBoxData['formfields'][controller.selectedTab.value]['type'] == HtmlControls.kFieldGroupList,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
                                      child: CustomButton(
                                        borderWidth: 1,
                                        buttonColor: Colors.transparent,
                                        borderColor: ColorTheme.kBlack,
                                        height: 38,
                                        showBoxBorder: true,
                                        width: sizingInformation.isDesktop ? 50 : 30,
                                        onTap: () {
                                          if ((isMasterForm
                                                  ? controller.setDefaultData.masterFormData
                                                  : controller.setDefaultData.formData)[controller.dialogBoxData['formfields'][controller.selectedTab.value]['field']] ==
                                              null) {
                                            (isMasterForm
                                                ? controller.setDefaultData.masterFormData
                                                : controller.setDefaultData.formData)[controller.dialogBoxData['formfields'][controller.selectedTab.value]['field']] = [];
                                          }
                                          (isMasterForm
                                                  ? controller.setDefaultData.masterFormData
                                                  : controller.setDefaultData.formData)[controller.dialogBoxData['formfields'][controller.selectedTab.value]['field']]
                                              .add(<String, dynamic>{});
                                          controller.currentExpandedIndex.value = ((isMasterForm
                                                      ? controller.setDefaultData.masterFormData
                                                      : controller.setDefaultData.formData)[controller.dialogBoxData['formfields'][controller.selectedTab.value]['field']])
                                                  .length -
                                              1;
                                          if (isMasterForm) {
                                            controller.setDefaultData.masterFormData.refresh();
                                          } else {
                                            controller.setDefaultData.formData.refresh();
                                          }
                                        },
                                        borderRadius: 4,
                                        widget: Row(
                                          children: [
                                            if (sizingInformation.isDesktop)
                                              const Icon(
                                                Icons.add,
                                                color: ColorTheme.kBlack,
                                              ),
                                            if (sizingInformation.isDesktop)
                                              const SizedBox(
                                                width: 4,
                                              ),
                                            TextWidget(
                                              text: 'ADD ${controller.dialogBoxData['formfields'][controller.selectedTab.value]['addbuttontext'].toString().toUpperCase()}',
                                              color: ColorTheme.kBlack,
                                              fontWeight: FontTheme.notoMedium,
                                              fontSize: 14,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
                                  child: Obx(() {
                                    return CustomButton(
                                      isLoading: controller.addButtonLoading.value,
                                      onTap: (!controller.addButtonLoading.value && controller.uploadDocCount.value == 0)
                                          ? () async {
                                              devPrint('pagename -->$pagename');

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

                                              if (isMasterForm) {
                                                controller.handleMasterAddButtonClick(pagename: pagename);
                                              } else {
                                                if (pagename == 'tenantproject' && controller.selectedTab.value == 1) {
                                                  int selectedCount = 0;
                                                  int errorIndex = (controller.setDefaultData.formData['paymentconfiguration'] as List).indexWhere(
                                                    (element) {
                                                      if (element['isSelected'] == 1) {
                                                        selectedCount++;
                                                      }
                                                      devPrint('element--->$element');
                                                      return (element['isSelected'] == 1 && (element['paymentto'] as List?).isNullOrEmpty);
                                                    },
                                                  );
                                                  devPrint('selectedCount $selectedCount');
                                                  devPrint('errorIndex $errorIndex');
                                                  if (selectedCount == 0 || errorIndex != -1) {
                                                    showError('Select Atleast 1 Payment Type');
                                                    controller.addButtonLoading.value = false;
                                                    return;
                                                  }
                                                }
                                                await controller.handleAddButtonClick();
                                              }
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
                                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 12),
                                  child: CustomButton(
                                    onTap: () async {
                                      controller.formKey0.currentState?.reset();
                                      if (isMasterForm) {
                                        devPrint("58934674699348603");
                                        devPrint(controller.dialogBoxData['pagename']);
                                        if (controller.dialogBoxData['pagename'] == "managerassign") {
                                          await controller.setUserInTable(controller.setDefaultData.masterFormData['tenantprojectid']);
                                        } else {
                                          controller.setMasterFormData(
                                            id: controller.setDefaultData.masterFormData['_id'],
                                            editeDataIndex: controller.setDefaultData.masterFormData['_id'].toString().isNotNullOrEmpty
                                                ? controller.initialStateData['lastEditedDataIndex']
                                                : null,
                                            parentId: controller.setDefaultData.masterFormData['tenantprojectid'],
                                            page: controller.dialogBoxData['pagename'],
                                            canSwitchTab: false,
                                          );
                                        }
                                      } else {
                                        controller.setFormData(
                                          canSwitchTab: false,
                                          id: controller.setDefaultData.formData['_id'],
                                          editeDataIndex:
                                              controller.setDefaultData.formData['_id'].toString().isNotNullOrEmpty ? controller.initialStateData['lastEditedDataIndex'] : null,
                                        );
                                      }
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
                }),
              );
            });
      }

      if (sizingInformation.isMobile) {
        return Container(
          child: userForm(),
        );
      }

      return Dialog(
        backgroundColor: ColorTheme.kWhite,
        alignment: Alignment.centerRight,
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
        insetPadding: EdgeInsets.zero,
        child: userForm(),
      );
    });
  }
}
