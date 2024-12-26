import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_checkbox.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_shimmer.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_text_form_field.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/controller/menu/menu_assign_controller.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/drop_down_search_custom.dart';
import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../config/iis_method.dart';
import '../../models/form_data_model.dart';
import '../../style/string_const.dart';

class MenuAssign extends StatelessWidget {
  const MenuAssign({super.key, this.pageName});

  final String? pageName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorTheme.kScaffoldColor,
        body: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            double width = sizingInformation.isMobile ? MediaQuery.sizeOf(context).width : MediaQuery.sizeOf(context).width - 120;
            return GetBuilder(
              global: false,
              init: Get.put(MenuAssignController()),
              builder: (controller) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      width: width,
                      height: MediaQuery.sizeOf(context).height,
                      decoration: BoxDecoration(
                          color: ColorTheme.kWhite,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: ColorTheme.kBorderColor,
                            width: 1,
                          )),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            return TextWidget(
                              fontSize: 18,
                              color: ColorTheme.kPrimaryColor,
                              fontWeight: FontWeight.w500,
                              text: controller.formName.value,
                            );
                          }).paddingSymmetric(vertical: 32, horizontal: 24),
                          Obx(() {
                            return CustomShimmer(
                              isLoading: controller.formLoadingData.value,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const ScrollPhysics(),
                                itemCount: controller.dialogBoxData['formfields'].length,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                itemBuilder: (context, index) {
                                  return Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    children: [
                                      ...List.generate(controller.dialogBoxData["formfields"][index]["formFields"].length, (i) {
                                        var res = controller.dialogBoxData["formfields"][index]["formFields"][i];
                                        var focusOrderCode = generateUniqueFieldId(index, i, null, null);
                                        if (!controller.focusNodes.containsKey(focusOrderCode)) {
                                          controller.focusNodes[focusOrderCode] = FocusNode();
                                        }
                                        switch (res["type"]) {
                                          case HtmlControls.kDropDown:
                                            return Obx(() {
                                              var masterdatakey = res?["storemasterdatabyfield"] == true ? res["field"] : res["masterdata"];
                                              var list = IISMethods().encryptDecryptObj(controller.setDefaultData.masterData[masterdatakey]);
                                              if (res.containsKey("isselfrefernce") &&
                                                  res["isselfrefernce"] &&
                                                  controller.setDefaultData.formData[res["isselfreferncefield"]].toString().isNotEmpty) {
                                                list = controller.setDefaultData.masterData[masterdatakey].map((e) {
                                                  if (controller.setDefaultData.formData[res["isselfreferncefield"]] != e["label"]) {
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
                                                    initValue:
                                                        (list ?? []).where((element) => element["value"] == controller.setDefaultData.formData[res["field"]]).toList().isNotEmpty
                                                            ? list.where((element) => element["value"] == controller.setDefaultData.formData[res["field"]]).toList()?.first ?? {}
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
                                      constrainedBoxWithPadding(
                                        width: 200,
                                        child: CustomTextFormField(
                                          hintColor: ColorTheme.kPrimaryColor,
                                          controller: controller.searchController,
                                          hintText: 'Search',
                                          onFieldSubmitted: (value) async {
                                            await controller.getList(
                                              moduletypeid: controller.setDefaultData.formData["moduletypeid"],
                                              moduleid: controller.setDefaultData.formData["moduleid"],
                                              searchtext: controller.searchController.text,
                                            );
                                          },
                                        ),
                                      ).paddingOnly(right: 12),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                                        child: CustomButton(
                                          onTap: () async {
                                            await controller.handleResetButtonClick();
                                          },
                                          width: 135,
                                          fontSize: 14,
                                          borderRadius: 4,
                                          buttonColor: ColorTheme.kBackGroundGrey,
                                          height: 40,
                                          fontWeight: FontTheme.notoRegular,
                                          fontColor: ColorTheme.kPrimaryColor,
                                          title: StringConst.kResetBtnTxt,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: CustomButton(
                                          onTap: () async {
                                            await controller.handleSaveButtonClick();
                                          },
                                          width: 135,
                                          fontSize: 14,
                                          borderRadius: 4,
                                          height: 40,
                                          widget: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              TextWidget(
                                                text: 'Update',
                                                fontSize: 13,
                                                fontWeight: FontTheme.notoRegular,
                                                color: ColorTheme.kWhite,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          }),
                          Expanded(
                            child: CustomShimmer(
                              isLoading: controller.loadingData.value,
                              child: dataTable(
                                width: width,
                                setDefaultData: controller.setDefaultData,
                                controller: controller,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }

  dataTable({
    required final FormDataModel setDefaultData,
    required final double width,
    final List<PopupMenuItem<dynamic>>? popupMenuItems,
    final String? pageName,
    required MenuAssignController controller,
  }) {
    return Obx(
      () {
        double totalFlex = 0;

        for (var element in setDefaultData.fieldOrder) {
          totalFlex += (element['tblsize'] ?? 20);
        }
        double ratio = 1;
        if (totalFlex * 10 < (width)) {
          ratio = (width) / (totalFlex * 10);
        }
        Map<int, TableColumnWidth> sizeMap = Map.from(
          setDefaultData.fieldOrder.map((element) => FixedColumnWidth((element['tblsize'] ?? 20) * 10 * ratio)).toList().asMap(),
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Obx(() {
                return Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: sizeMap,
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: ColorTheme.kTableHeader),
                      children: List.generate(controller.loadingData.value ? 5 : setDefaultData.fieldOrder.length, (index) {
                        if (controller.loadingData.value) {
                          return const SizedBox(
                            width: double.maxFinite,
                            height: 20,
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: controller.loadingData.value
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  height: 12,
                                ).paddingAll(8)
                              : Row(
                                  children: [
                                    Visibility(
                                      visible: setDefaultData.fieldOrder[index]['type'] == 'checkbox',
                                      replacement: TextWidget(
                                        text: setDefaultData.fieldOrder[index]['text'].toUpperCase(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: ColorTheme.kBlack,
                                      ),
                                      child: CustomCheckBox(
                                        value: setDefaultData.fieldOrder[index]['selectall'] == 1,
                                        onChanged: (value) async {
                                          setDefaultData.fieldOrder[index]['selectall'] = value! ? 1 : 0;
                                          for (var data in controller.setDefaultData.data) {
                                            await controller.handleSwitches(
                                              value,
                                              data['_id'],
                                              'isassigned',
                                            );
                                          }
                                          setDefaultData.fieldOrder.refresh();
                                        },
                                        label: setDefaultData.fieldOrder[index]['text'].toUpperCase(),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (setDefaultData.fieldOrder[index]['sorttable'] == 1)
                                      SvgPicture.asset(
                                        AssetsString.kVerticalDotsMenu,
                                        colorFilter: const ColorFilter.mode(ColorTheme.kBlack, BlendMode.srcIn),
                                      ),
                                  ],
                                ),
                        );
                      }),
                    )
                  ],
                );
              }),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() {
                    return Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: sizeMap,
                      children: List.generate(
                        controller.loadingData.value ? 5 : (setDefaultData.data).length,
                        (index) => TableRow(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: ColorTheme.kBorderColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                          children: List.generate(
                            controller.loadingData.value ? 5 : setDefaultData.fieldOrder.length,
                            (i) {
                              if (controller.loadingData.value) {
                                return CustomShimmer(
                                  isLoading: controller.loadingData.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ColorTheme.kBlack,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    height: 20,
                                  ),
                                ).paddingAll(8);
                              }
                              Map<String, dynamic> obj = setDefaultData.data[index];
                              Map<String, dynamic> innerObj = setDefaultData.fieldOrder[i];

                              return projectListTile(
                                obj,
                                innerObj,
                                controller,
                              ).paddingAll(8);
                            },
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget projectListTile(obj, innerObj, MenuAssignController controller) {
    switch (innerObj['type']) {
      case HtmlControls.kCheckBox:
        return CustomCheckBox(
            value: obj[innerObj['field']] == 1,
            onChanged: (value) async {
              await controller.handleSwitches(
                value,
                obj["_id"],
                innerObj["field"],
              );
              controller.setDefaultData.data.refresh();
            });
      case HtmlControls.kRadio:
        return CustomCheckBox(
          value: obj[innerObj['field']] == 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          onChanged: (value) async {
            await controller.handleGridSwitches(
              value,
              obj["_id"],
              innerObj["field"],
            );
            controller.setDefaultData.data.refresh();
          },
        );
      default:
        return TextWidget(
          text: obj[innerObj['field']].toString(),
          fontSize: 14,
          fontWeight: FontTheme.notoRegular,
          color: ColorTheme.kBlack,
        );
    }
  }
}
