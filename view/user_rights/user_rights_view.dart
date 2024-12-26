import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_shimmer.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:shimmer/shimmer.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_text_form_field.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/customs/text_widget.dart';
import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../controller/userrights/user_rights_controller.dart';
import '../../style/string_const.dart';
import '../../style/theme_const.dart';

class UserRightsMaster extends StatelessWidget {
  const UserRightsMaster({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return GetBuilder(
      global: false,
      init: Get.put(UserRightController()),
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF1F1F1),
        body: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            right: 20.0,
                            top: 15,
                          ),
                          child: Row(
                            children: [
                              TextWidget(
                                text: controller.dialogBoxData["formname"] ?? "",
                                fontSize: 20,
                                fontWeight: FontTheme.notoSemiBold,
                                color: ColorTheme.kBlack,
                              ),
                            ],
                          ),
                        ),
                        dataTable(size, context, size.width, controller),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget dataTable(
    Size size,
    BuildContext context,
    double boxSize,
    UserRightController controller,
  ) {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 15,
              ),
              child: Container(
                width: size.width,
                height: size.height / 1.1,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                      child: Column(
                        children: [
                          ...List.generate((controller.dialogBoxData["formfields"] ?? []).length, (index) {
                            return Obx(() {
                              return CustomShimmer(
                                isLoading: controller.loadingData.value,
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.end,
                                  children: [
                                    ...List.generate((controller.dialogBoxData["formfields"][index]["formFields"] ?? []).length, (i) {
                                      var res = (controller.dialogBoxData["formfields"][index]["formFields"][i]);
                                      var focusOrderCode = generateUniqueFieldId(index, i, null, null);
                                      if (!controller.focusNodes.containsKey(focusOrderCode)) {
                                        controller.focusNodes[focusOrderCode] = FocusNode();
                                      }
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

                                      if (res.containsKey('defaultvisibility') &&
                                          (res["defaultvisibility"] ?? true) &&
                                          !(res['disabled'] ?? false) &&
                                          !controller.focusAssigned.value) {
                                        controller.focusAssigned.value = true;
                                        controller.focusNodes[focusOrderCode]?.requestFocus();
                                      }
                                      return FocusTraversalOrder(
                                        order: NumericFocusOrder(focusOrderCode.toString().converttoDouble),
                                        child: Builder(
                                          builder: (context) {
                                            if (res["type"] == HtmlControls.kDropDown) {
                                              return constrainedBoxWithPadding(
                                                  width: res['gridsize'],
                                                  child: DropDownSearchCustom(
                                                    focusNode: controller.focusNodes[focusOrderCode],
                                                    width: res['gridsize'],
                                                    dropValidator: (p0) {
                                                      return null;
                                                    },
                                                    items: List<Map<String, dynamic>>.from(controller.setDefaultData["masterData"][res["masterdata"]] ?? []),
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
                                            if (res["type"] == HtmlControls.kText) {
                                              return SizedBox(
                                                height: 50,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                                  child: TextWidget(
                                                    textAlign: TextAlign.center,
                                                    text: res['text'],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                        ),
                                      );
                                    }),
                                    constrainedBoxWithPadding(
                                      child: CustomTextFormField(
                                        focusNode: controller.focusNodes[999999999999],
                                        controller: controller.searchController,
                                        isRequire: false,
                                        showPrefixDivider: false,
                                        hintText: "Search",
                                        prefixIconConstraints: const BoxConstraints(maxHeight: 38),
                                        onChanged: (v) async {
                                          controller.searchValue = v;
                                          await controller.handleSearch(v);
                                          controller.setDefaultData.refresh();
                                        },
                                        prefixWidget: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(Icons.search),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: CustomButton(
                                        title: StringConst.kCreateBtnTxt,
                                        onTap: () async {
                                          await controller.handleSaveButtonClick();
                                        },
                                        width: 100,
                                        height: 38,
                                        borderRadius: 5,
                                        buttonColor: ColorTheme.kPrimaryColor,
                                        fontColor: ColorTheme.kWhite,
                                        fontWeight: FontTheme.notoMedium,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: CustomButton(
                                        title: StringConst.kResetBtnTxt,
                                        onTap: () async {
                                          await controller.handleResetButtonClick();
                                        },
                                        buttonColor: ColorTheme.kGrey,
                                        height: 38,
                                        width: 100,
                                        fontColor: ColorTheme.kWhite,
                                        fontWeight: FontTheme.notoMedium,
                                        borderRadius: 5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          }),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width - 135,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.2,
                            color: ColorTheme.kHintTextColor,
                          ),
                        ),
                        margin: const EdgeInsets.all(20),
                        child: controller.setDefaultData["fieldOrder"].isNotEmpty
                            ? AdaptiveScrollbar(
                                controller: controller.verticalScroll,
                                width: 10,
                                underDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                sliderDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: ColorTheme.kBorderColor,
                                ),
                                sliderActiveColor: Colors.transparent,
                                underSpacing: const EdgeInsets.only(
                                  top: 45,
                                ),
                                child: AdaptiveScrollbar(
                                  controller: controller.horizontalScroll,
                                  width: 10,
                                  underDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  sliderDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: ColorTheme.kBorderColor,
                                  ),
                                  sliderActiveColor: Colors.transparent,
                                  position: ScrollbarPosition.bottom,
                                  underSpacing: const EdgeInsets.only(
                                    bottom: 10,
                                  ),
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                    child: SingleChildScrollView(
                                      controller: controller.horizontalScroll,
                                      scrollDirection: Axis.horizontal,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width - 135,
                                            constraints: BoxConstraints(
                                              minWidth: (200 * (controller.setDefaultData["fieldOrder"] ?? []).length).toDouble(),
                                            ),
                                            decoration: const BoxDecoration(
                                                border: Border(
                                              bottom: BorderSide(
                                                width: 0.2,
                                                color: ColorTheme.kHintTextColor,
                                              ),
                                            )),
                                            height: 100,
                                            padding: const EdgeInsets.all(16),
                                            child: GridView.builder(
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: controller.showShimmer.value && controller.setDefaultData["fieldOrder"].isEmpty
                                                    ? 1
                                                    : controller.setDefaultData["fieldOrder"].length,
                                                mainAxisExtent: 70,
                                              ),
                                              shrinkWrap: true,
                                              scrollDirection: Axis.vertical,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: controller.showShimmer.value && controller.setDefaultData["fieldOrder"].isEmpty
                                                  ? 1
                                                  : controller.setDefaultData["fieldOrder"].length,
                                              itemBuilder: (context, index) {
                                                return controller.showShimmer.value && controller.setDefaultData["fieldOrder"].isEmpty
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child: SizedBox(
                                                              height: 40,
                                                              width: 100,
                                                              child: Shimmer.fromColors(
                                                                baseColor: ColorTheme.kShimmerBaseColor,
                                                                highlightColor: ColorTheme.kShimmerHighlightColor,
                                                                enabled: true,
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    if (index == 0)
                                                                      Container(
                                                                        height: 20,
                                                                        width: 20,
                                                                        color: ColorTheme.kBlack,
                                                                      ),
                                                                    const SizedBox(
                                                                      width: 20,
                                                                    ),
                                                                    Expanded(
                                                                      child: Container(
                                                                        height: 20,
                                                                        width: 20,
                                                                        color: ColorTheme.kBlack,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : ConstrainedBox(
                                                        constraints: const BoxConstraints(
                                                          minWidth: 150,
                                                          maxWidth: 350,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: controller.setDefaultData["fieldOrder"][index].containsKey("htmlcontrols") &&
                                                                      controller.setDefaultData["fieldOrder"][index]["htmlcontrols"].length == 1
                                                                  ? CrossAxisAlignment.start
                                                                  : CrossAxisAlignment.center,
                                                              children: [
                                                                TextWidget(
                                                                  text: controller.setDefaultData["fieldOrder"][index]["text"] ?? "",
                                                                  textOverflow: TextOverflow.ellipsis,
                                                                  fontWeight: FontTheme.notoSemiBold,
                                                                  fontSize: 15,
                                                                  color: ColorTheme.kTextColor,
                                                                ),
                                                                if (controller.setDefaultData["fieldOrder"][index].containsKey("htmlcontrols"))
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    children: List.generate(controller.setDefaultData["fieldOrder"][index]["htmlcontrols"].length, (j) {
                                                                      var field = controller.setDefaultData["fieldOrder"][index]["htmlcontrols"][j];
                                                                      return Padding(
                                                                        padding: const EdgeInsets.only(right: 10.0, top: 10),
                                                                        child: Row(
                                                                          children: [
                                                                            Obx(() {
                                                                              return Checkbox(
                                                                                value: controller.state[field["field"]] ?? false,
                                                                                activeColor: ColorTheme.kPrimaryColor,
                                                                                onChanged: (v) async {
                                                                                  await controller.handleSelectAll(e: v, field: field["field"]);
                                                                                  controller.setDefaultData.refresh();
                                                                                },
                                                                              );
                                                                            }),
                                                                            TextWidget(
                                                                              text: field["text"],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    }),
                                                                  )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              controller: controller.verticalScroll,
                                              scrollDirection: Axis.vertical,
                                              child: Obx(() => Column(
                                                      children: List.generate(
                                                    controller.showShimmer.value && controller.setDefaultData["data"].isEmpty
                                                        ? 5
                                                        : controller.setDefaultData["data"].where((data) {
                                                            if (controller.searchValue.trim().isEmpty) {
                                                              return true;
                                                            } else {
                                                              return data["formname"].toString().toLowerCase().contains(controller.searchValue.toLowerCase());
                                                            }
                                                          }).length,
                                                    (index) {
                                                      var res = controller.setDefaultData["data"].where((data) {
                                                        if (controller.searchValue.trim().isEmpty) {
                                                          return true;
                                                        } else {
                                                          return data["formname"].toString().toLowerCase().contains(controller.searchValue.toLowerCase());
                                                        }
                                                      }).toList();
                                                      return Container(
                                                        decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor, width: 0.5)),
                                                        width: MediaQuery.of(context).size.width - 135,
                                                        constraints: BoxConstraints(
                                                          minWidth: (200 * controller.setDefaultData["fieldOrder"].length).toDouble(),
                                                        ),
                                                        child: GridView.builder(
                                                          itemCount: controller.loadingData.value && controller.setDefaultData["fieldOrder"].isEmpty
                                                              ? 1
                                                              : controller.setDefaultData["fieldOrder"].length,
                                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: controller.loadingData.value && controller.setDefaultData["fieldOrder"].isEmpty
                                                                  ? controller.setDefaultData["fieldOrder"].length + 1
                                                                  : controller.setDefaultData["fieldOrder"].length,
                                                              mainAxisExtent: 20),
                                                          scrollDirection: Axis.vertical,
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                                          itemBuilder: (context, i) {
                                                            return Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                                              decoration:
                                                                  const BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: ColorTheme.kBorderColor, width: 0.5))),
                                                              constraints: const BoxConstraints(
                                                                minWidth: 100,
                                                                maxWidth: 350,
                                                              ),
                                                              child: controller.showShimmer.value
                                                                  ? Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: SizedBox(
                                                                            height: 40,
                                                                            child: Shimmer.fromColors(
                                                                              baseColor: ColorTheme.kShimmerBaseColor,
                                                                              highlightColor: ColorTheme.kShimmerHighlightColor,
                                                                              enabled: true,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                children: [
                                                                                  if (i == 0)
                                                                                    Container(
                                                                                      height: 20,
                                                                                      width: 20,
                                                                                      color: Colors.white,
                                                                                      margin: const EdgeInsets.only(left: 10),
                                                                                    ),
                                                                                  if (i == 0)
                                                                                    const SizedBox(
                                                                                      width: 10,
                                                                                    ),
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      height: 20,
                                                                                      width: 20,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width: 10,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        if (!controller.setDefaultData["fieldOrder"][i].containsKey("htmlcontrols") &&
                                                                            (controller.setDefaultData["fieldOrder"][i]["type"] == "text"))
                                                                          Expanded(
                                                                            child: TextWidget(
                                                                              text: res[index]['${controller.setDefaultData["fieldOrder"][i]["field"]}'] ?? "-",
                                                                              textOverflow: TextOverflow.ellipsis,
                                                                              fontSize: 14,
                                                                              fontWeight: FontTheme.notoRegular,
                                                                            ),
                                                                          )
                                                                        else
                                                                          Row(
                                                                            children: List.generate(controller.setDefaultData["fieldOrder"][i]["htmlcontrols"].length, (j) {
                                                                              var field = controller.setDefaultData["fieldOrder"][i]["htmlcontrols"][j];
                                                                              return Padding(
                                                                                padding: const EdgeInsets.only(right: 10.0, top: 0),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Checkbox(
                                                                                      value: res[index]['${field["field"]}'] == 1,
                                                                                      activeColor: ColorTheme.kPrimaryColor,
                                                                                      onChanged: (v) async {
                                                                                        await controller.handleSwitches(e: v, field: field["field"], id: res[index]["_id"]);
                                                                                        controller.setDefaultData.refresh();
                                                                                      },
                                                                                    ),
                                                                                    TextWidget(
                                                                                      text: field["text"],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            }),
                                                                          )
                                                                      ],
                                                                    ),
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Column textFieldLabel({
    required String label,
    bool? isRequire,
  }) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontWeight: FontTheme.notoRegular,
                  color: ColorTheme.kHintColor,
                  fontSize: 12,
                ),
              ),
              if (isRequire ?? false)
                const TextSpan(
                  text: " *",
                  style: TextStyle(
                    color: ColorTheme.kRed,
                    fontSize: 12,
                    fontWeight: FontTheme.notoRegular,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(
          height: 4,
        )
      ],
    );
  }

  inPageClickEvent(res) async {}
}
