import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shimmer/shimmer.dart';

import '../../../config/config.dart';
import '../../../style/theme_const.dart';
import '../../components/customs/custom_button.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/customs/text_widget.dart';
import '../../controller/menu/menu_design_controller.dart';
import '../../style/string_const.dart';
import 'darg_and_drop.dart';

class MenuDesign extends StatelessWidget {
  const MenuDesign({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GetBuilder(
      global: false,
      init: Get.put(MenuDesignController()),
      builder: (controller) => ScreenTypeLayout.builder(
        desktop: (p0) => Scaffold(
          backgroundColor: const Color(0xFFF1F1F1),
          body: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 40.0,
                                    right: 40.0,
                                    top: 40,
                                  ),
                                  child: Row(
                                    children: [
                                      TextWidget(
                                        text: "Menu Design",
                                        fontSize: 20,
                                        fontWeight: FontTheme.notoBold,
                                        color: ColorTheme.kPrimaryColor,
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40.0,
                                          right: 40.0,
                                          top: 20.0,
                                        ),
                                        child: Container(
                                          width: size.width,
                                          height: size.height / 1.2,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Obx(() => Padding(
                                                    padding: const EdgeInsets.fromLTRB(4.0, 20.0, 20.0, 0),
                                                    child: Form(
                                                      key: controller.formKey,
                                                      autovalidateMode: controller.validateForm.value ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                                                      child: Column(
                                                        children: [
                                                          if (controller.loadingData.value)
                                                            ...List.generate(
                                                                controller.loadingData.value && controller.dialogBoxData.isEmpty
                                                                    ? (controller.dialogBoxData["formfields"] ?? []).length + 1
                                                                    : (controller.dialogBoxData["formfields"] ?? []).length, (index) {
                                                              return Wrap(
                                                                children: [
                                                                  ...List.generate(
                                                                      controller.loadingData.value
                                                                          ? (controller.dialogBoxData["formfields"][index]["formFields"] ?? []).length
                                                                          : (controller.dialogBoxData["formfields"][index]["formFields"] ?? []).length, (i) {
                                                                    return Shimmer.fromColors(
                                                                      baseColor: Colors.grey.shade300,
                                                                      highlightColor: Colors.grey.shade100,
                                                                      child: constrainedBoxWithPadding(
                                                                        child: Container(
                                                                          height: 35,
                                                                          color: ColorTheme.kWhite,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                                ],
                                                              );
                                                            })
                                                          else
                                                            ...List.generate((controller.dialogBoxData["formfields"] ?? []).length, (index) {
                                                              return Wrap(
                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                children: [
                                                                  ...List.generate(controller.dialogBoxData["formfields"][index]["formFields"].length, (i) {
                                                                    var res = controller.dialogBoxData["formfields"][index]["formFields"][i];
                                                                    if (res.containsKey("condition")) {
                                                                      if (controller.setDefaultData["formData"][res["condition"]["field"]] == res["condition"]["onvalue"]) {
                                                                        res["defaultvisibility"] = true;
                                                                      } else {
                                                                        res["defaultvisibility"] = false;
                                                                      }
                                                                    }
                                                                    if (!res["defaultvisibility"]) {
                                                                      res = {};
                                                                    }
                                                                    if (res["type"] == HtmlControls.kDropDown) {
                                                                      return constrainedBoxWithPadding(
                                                                          width: res['gridsize'],
                                                                          child: DropDownSearchCustom(
                                                                            dropValidator: (p0) {
                                                                              if (controller.validation[res["field"]] ?? false) {
                                                                                if (p0?.isEmpty == true || p0 == null) {
                                                                                  return "Please Select a ${res['text']}";
                                                                                }
                                                                              }
                                                                              return null;
                                                                            },
                                                                            items:
                                                                                List<Map<String, dynamic>>.from(controller.setDefaultData["masterData"][res["masterdata"]] ?? []),
                                                                            isRequire: res["required"],
                                                                            readOnly: res['disabled'],
                                                                            textFieldLabel: res["text"],
                                                                            hintText: "Select ${res["text"]}",
                                                                            isCleanable: res["cleanable"],
                                                                            showAddButton: res["inpagemasterdata"] ?? false,
                                                                            buttonText: res["text"],
                                                                            clickOnCleanBtn: () async {
                                                                              await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: "",
                                                                                type: res["type"],
                                                                              );
                                                                              controller.setDefaultData.refresh();
                                                                            },
                                                                            isSearchable: res["searchable"],
                                                                            initValue: (controller.setDefaultData["masterData"][res["masterdata"]] ?? [])
                                                                                    .where((element) => element["value"] == controller.setDefaultData["formData"][res["field"]])
                                                                                    .toList()
                                                                                    .isNotEmpty
                                                                                ? controller.setDefaultData["masterData"][res["masterdata"]]
                                                                                    .where((element) => element["value"] == controller.setDefaultData["formData"][res["field"]])
                                                                                    .toList()
                                                                                    ?.first
                                                                                : null,
                                                                            onChanged: (v) async {
                                                                              await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: v!["value"],
                                                                                type: res["type"],
                                                                              );
                                                                              controller.setDefaultData.refresh();
                                                                            },
                                                                          ));
                                                                    }
                                                                    return const SizedBox();
                                                                  }),
                                                                ],
                                                              );
                                                            }),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                              Obx(() => Expanded(
                                                    child: AnimatedSwitcher(
                                                      duration: kThemeAnimationDuration,
                                                      child: DefaultIndentGuide(
                                                        guide: const IndentGuide.connectingLines(
                                                          indent: 40,
                                                          color: ColorTheme.kHintColor,
                                                          thickness: 1.5,
                                                          origin: 0.5,
                                                          roundCorners: false,
                                                        ),
                                                        child: controller.loadingMenuData.value
                                                            ? Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: List.generate(10, (i) {
                                                                  return Shimmer.fromColors(
                                                                    baseColor: Colors.grey.shade300,
                                                                    highlightColor: Colors.grey.shade100,
                                                                    child: constrainedBoxWithPadding(
                                                                      child: Row(
                                                                        children: [
                                                                          Container(
                                                                            height: 20,
                                                                            width: 20,
                                                                            color: ColorTheme.kWhite,
                                                                          ),
                                                                          const SizedBox(
                                                                            width: 10,
                                                                          ),
                                                                          Expanded(
                                                                            child: Container(
                                                                              height: 20,
                                                                              color: ColorTheme.kWhite,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                              )
                                                            : DragAndDropTreeView(dataList: List<Map<String, dynamic>>.from(controller.setDefaultData["data"] ?? [])),
                                                      ),
                                                    ),
                                                  )),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                children: [
                                                  if (controller.isAddVisible.value)
                                                    CustomButton(
                                                      title: StringConst.kCreateBtnTxt,
                                                      onTap: () async {
                                                        await controller.handleSaveButtonClick();
                                                      },
                                                      height: 35,
                                                      width: 80,
                                                      borderRadius: 5,
                                                      fontSize: 10,
                                                      fontColor: ColorTheme.kWhite,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        tablet: (p0) => Scaffold(
          backgroundColor: const Color(0xFFF1F1F1),
          body: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 40.0,
                                    right: 40.0,
                                    top: 40,
                                  ),
                                  child: Row(
                                    children: [
                                      TextWidget(
                                        text: "Menu Design",
                                        fontSize: 20,
                                        fontWeight: FontTheme.notoSemiBold,
                                        color: ColorTheme.kPrimaryColor,
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 40.0,
                                          right: 40.0,
                                          top: 20.0,
                                        ),
                                        child: Container(
                                          width: size.width,
                                          height: size.height / 1.4,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Obx(() => Padding(
                                                    padding: const EdgeInsets.fromLTRB(4.0, 20.0, 20.0, 0),
                                                    child: Form(
                                                      key: controller.formKey,
                                                      autovalidateMode: controller.validateForm.value ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
                                                      child: Column(
                                                        children: [
                                                          if (controller.loadingData.value)
                                                            ...List.generate(
                                                                controller.loadingData.value && controller.dialogBoxData.isEmpty
                                                                    ? (controller.dialogBoxData["formfields"] ?? []).length + 1
                                                                    : (controller.dialogBoxData["formfields"] ?? []).length, (index) {
                                                              return Wrap(
                                                                children: [
                                                                  ...List.generate(
                                                                      controller.loadingData.value
                                                                          ? (controller.dialogBoxData["formfields"][index]["formFields"] ?? []).length
                                                                          : (controller.dialogBoxData["formfields"][index]["formFields"] ?? []).length, (i) {
                                                                    return Shimmer.fromColors(
                                                                      baseColor: Colors.grey.shade300,
                                                                      highlightColor: Colors.grey.shade100,
                                                                      child: constrainedBoxWithPadding(
                                                                        child: Container(
                                                                          height: 35,
                                                                          color: ColorTheme.kWhite,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                                ],
                                                              );
                                                            })
                                                          else
                                                            ...List.generate((controller.dialogBoxData["formfields"] ?? []).length, (index) {
                                                              return Wrap(
                                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                                children: [
                                                                  ...List.generate(controller.dialogBoxData["formfields"][index]["formFields"].length, (i) {
                                                                    var res = controller.dialogBoxData["formfields"][index]["formFields"][i];
                                                                    if (res.containsKey("condition")) {
                                                                      if (controller.setDefaultData["formData"][res["condition"]["field"]] == res["condition"]["onvalue"]) {
                                                                        res["defaultvisibility"] = true;
                                                                      } else {
                                                                        res["defaultvisibility"] = false;
                                                                      }
                                                                    }
                                                                    if (!res["defaultvisibility"]) {
                                                                      res = {};
                                                                    }
                                                                    if (res["type"] == HtmlControls.kDropDown) {
                                                                      return constrainedBoxWithPadding(
                                                                          width: res['gridsize'],
                                                                          child: DropDownSearchCustom(
                                                                            dropValidator: (p0) {
                                                                              if (controller.validation[res["field"]] ?? false) {
                                                                                if (p0?.isEmpty == true || p0 == null) {
                                                                                  return "Please Select a ${res['text']}";
                                                                                }
                                                                              }
                                                                              return null;
                                                                            },
                                                                            items:
                                                                                List<Map<String, dynamic>>.from(controller.setDefaultData["masterData"][res["masterdata"]] ?? []),
                                                                            isRequire: res["required"],
                                                                            readOnly: res['disabled'],
                                                                            textFieldLabel: res["text"],
                                                                            hintText: "Select ${res["text"]}",
                                                                            isCleanable: res["cleanable"],
                                                                            showAddButton: res["inpagemasterdata"] ?? false,
                                                                            buttonText: res["text"],
                                                                            clickOnCleanBtn: () async {
                                                                              await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: "",
                                                                                type: res["type"],
                                                                              );
                                                                              controller.setDefaultData.refresh();
                                                                            },
                                                                            isSearchable: res["searchable"],
                                                                            initValue: (controller.setDefaultData["masterData"][res["masterdata"]] ?? [])
                                                                                    .where((element) => element["value"] == controller.setDefaultData["formData"][res["field"]])
                                                                                    .toList()
                                                                                    .isNotEmpty
                                                                                ? controller.setDefaultData["masterData"][res["masterdata"]]
                                                                                    .where((element) => element["value"] == controller.setDefaultData["formData"][res["field"]])
                                                                                    .toList()
                                                                                    ?.first
                                                                                : null,
                                                                            onChanged: (v) async {
                                                                              await controller.handleFormData(
                                                                                key: res["field"],
                                                                                value: v!["value"],
                                                                                type: res["type"],
                                                                              );
                                                                              controller.setDefaultData.refresh();
                                                                            },
                                                                          ));
                                                                    }
                                                                    return const SizedBox();
                                                                  }),
                                                                ],
                                                              );
                                                            }),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                              Obx(() => Expanded(
                                                    child: AnimatedSwitcher(
                                                      duration: kThemeAnimationDuration,
                                                      child: DefaultIndentGuide(
                                                        guide: const IndentGuide.connectingLines(
                                                          indent: 40,
                                                          color: ColorTheme.kHintTextColor,
                                                          thickness: 1.5,
                                                          origin: 0.5,
                                                          roundCorners: false,
                                                        ),
                                                        child: controller.loadingMenuData.value
                                                            ? Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: List.generate(10, (i) {
                                                                  return Shimmer.fromColors(
                                                                    baseColor: Colors.grey.shade300,
                                                                    highlightColor: Colors.grey.shade100,
                                                                    child: constrainedBoxWithPadding(
                                                                      child: Row(
                                                                        children: [
                                                                          Container(
                                                                            height: 20,
                                                                            width: 20,
                                                                            color: ColorTheme.kWhite,
                                                                          ),
                                                                          const SizedBox(
                                                                            width: 10,
                                                                          ),
                                                                          Expanded(
                                                                            child: Container(
                                                                              height: 20,
                                                                              color: ColorTheme.kWhite,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                              )
                                                            : DragAndDropTreeView(dataList: List<Map<String, dynamic>>.from(controller.setDefaultData["data"] ?? [])),
                                                      ),
                                                    ),
                                                  )),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                children: [
                                                  if (controller.isAddVisible.value)
                                                    CustomButton(
                                                      title: StringConst.kCreateBtnTxt,
                                                      onTap: () async {
                                                        await controller.handleSaveButtonClick();
                                                      },
                                                      height: 35,
                                                      width: 80,
                                                      borderRadius: 5,
                                                      fontSize: 10,
                                                      fontColor: ColorTheme.kWhite,
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
