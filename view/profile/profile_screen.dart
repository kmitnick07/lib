import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_shimmer.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/helper/device_service.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_dialogs.dart';
import '../../components/customs/custom_text_form_field.dart';
import '../../components/funtions.dart';
import '../../components/repo/auth/auth_repo.dart';
import '../../config/config.dart';
import '../../config/iis_method.dart';
import '../../controller/profile/profile_controller.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.kWhite,
      body: GetBuilder(
        init: Get.put(ProfileController()),
        builder: (controller) {
          return CommonHeaderFooter(
              title: "Profile",
              actions: [
                IconButton(
                  onPressed: () {
                    controller.isEdit.value = true;
                  },
                  icon: Obx(() {
                    return Visibility(visible: !controller.isEdit.value, child: const Icon(Icons.edit));
                  }),
                ),
              ],
              txtSearchController: TextEditingController(),
              child: ResponsiveBuilder(builder: (context, sizeInformation) {
                return Form(
                  child: Obx(() {
                    return CustomShimmer(
                      isLoading: controller.isLoading.value,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Obx(() {
                                return Wrap(
                                  children: [
                                    ...List.generate(controller.setDefaultData.fieldOrder.length, (i) {
                                      Map<String, dynamic> res = IISMethods().encryptDecryptObj(controller.setDefaultData.fieldOrder[i]);
                                      var focusOrderCode = generateUniqueFieldId(0, i, null, null);
                                      if (!focusNodes.containsKey(focusOrderCode)) {
                                        focusNodes[focusOrderCode] = FocusNode();
                                      }
                                      if (!controller.isEdit.value) {
                                        res['disabled'] = true;
                                      }
                                      switch (res["type"]) {
                                        case HtmlControls.kNumberInput:
                                          int cursorPos = 0;
                                          return Obx(() {
                                            var textController = TextEditingController(
                                                text: (controller.setDefaultData.formData)[res["field"]].toString().isEmpty || (controller.setDefaultData.formData)[res["field"]] == null
                                                    ? ""
                                                    : (controller.setDefaultData.formData)[res["field"]].toString());
                                            if (cursorPos <= textController.text.length) {
                                              textController.selection = TextSelection.collapsed(offset: cursorPos);
                                            } else {
                                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                            }
                                            return constrainedBoxWithPadding(
                                                width: res['gridsize'],
                                                child: CustomTextFormField(
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
                                                    IISMethods().decimalPointRgex(res['decimalpoint']),
                                                    if (res.containsKey("maxlength") || (res.containsKey("minvalue") && res.containsKey("maxvalue"))) LengthLimitingTextInputFormatter(res['maxlength'] ?? 10),
                                                    if (res.containsKey("minvalue") && res.containsKey("maxvalue")) LimitRange(res["minvalue"], res["maxvalue"]),
                                                  ],
                                                  disableField: res["disabled"],
                                                  readOnly: res["disabled"],
                                                  controller: textController,
                                                  hintText: "Enter ${res["text"]}",
                                                  isRequire: res["required"],
                                                  textFieldLabel: res["text"],
                                                  onChanged: (v) async {
                                                    (controller.setDefaultData.formData)[res["field"]] = v;
                                                    cursorPos = textController.selection.extent.offset;
                                                  },
                                                ));
                                          });

                                        case HtmlControls.kAvatarPicker:
                                          return Obx(
                                            () {
                                              int cursorPos = 0;
                                              var field = (controller.setDefaultData.formData)[res["field"]] ?? {};
                                              var textController = TextEditingController(text: field['name'] ?? '');
                                              if (cursorPos <= textController.text.length) {
                                                textController.selection = TextSelection.collapsed(offset: cursorPos);
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
                                                      InkWell(
                                                        onTap: () {
                                                          documentDownload(imageList: FilesDataModel.fromJson(controller.setDefaultData.formData[res['field']] ?? {}));
                                                        },
                                                        child: Container(
                                                          height: 64,
                                                          width: 64,
                                                          clipBehavior: Clip.hardEdge,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          child: Image.network(
                                                            FilesDataModel.fromJson(controller.setDefaultData.formData[res['field']] ?? {}).url ?? "",
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context, error, stackTrace) {
                                                              return SvgPicture.asset(
                                                                AssetsString.kUser,
                                                                fit: BoxFit.contain,
                                                              );
                                                            },
                                                          ),
                                                        ).paddingOnly(right: 12),
                                                      ),
                                                      if (controller.isEdit.value)
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
                                                                    fontColor: ColorTheme.kWhite,
                                                                    onTap: () async {
                                                                      List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                                      fileModelList = await IISMethods().uploadFiles(fileModelList);
                                                                      (controller.setDefaultData.formData)[res["field"]] = fileModelList.first.toJson();
                                                                    },
                                                                    title: ((controller.setDefaultData.formData[res['field']] ?? '').toString().isNullOrEmpty) ? res['uploadtext'] : res['uploadedtext'],
                                                                  );
                                                                }).paddingOnly(right: 6),
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

                                        case HtmlControls.kInputText:
                                          int cursorPos = 0;
                                          return Obx(() {
                                            var textController = TextEditingController(
                                                text: (controller.setDefaultData.formData)[res["field"]].toString().isEmpty || (controller.setDefaultData.formData)[res["field"]] == null
                                                    ? ""
                                                    : (controller.setDefaultData.formData)[res["field"]].toString());
                                            if (cursorPos <= textController.text.length) {
                                              textController.selection = TextSelection.collapsed(offset: cursorPos);
                                            } else {
                                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                            }
                                            return constrainedBoxWithPadding(
                                                width: res['gridsize'],
                                                child: CustomTextFormField(
                                                  focusNode: focusNodes[focusOrderCode],
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
                                                  isRequire: res["required"],
                                                  textFieldLabel: res["text"],
                                                  disableField: res["disabled"],
                                                  readOnly: res["disabled"],
                                                  onChanged: (v) async {
                                                    (controller.setDefaultData.formData)[res["field"]] = v;
                                                    cursorPos = textController.selection.extent.offset;
                                                    controller.userName.value = v.toCamelCase;
                                                  },
                                                ));
                                          });

                                        case HtmlControls.kInputTextArea:
                                          int cursorPos = 0;
                                          return Obx(() {
                                            var textController = TextEditingController(
                                                text: (controller.setDefaultData.formData)[res["field"]].toString().isEmpty || (controller.setDefaultData.formData)[res["field"]] == null
                                                    ? ""
                                                    : (((controller.setDefaultData.formData)[res["field"]]) as List).map((e) {
                                                        return e[res['field']];
                                                      }).join(', '));
                                            if (cursorPos <= textController.text.length) {
                                              textController.selection = TextSelection.collapsed(offset: cursorPos);
                                            } else {
                                              textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                            }
                                            return constrainedBoxWithPadding(
                                              width: res['gridsize'],
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  TextWidget(
                                                    text: res['text'] ?? [],
                                                    fontFamily: FontTheme.themeFontFamily,
                                                    fontWeight: FontTheme.notoRegular,
                                                    color: ColorTheme.kBlack,
                                                    fontSize: 12,
                                                  ).paddingOnly(bottom: 4),
                                                  ((((controller.setDefaultData.formData)[res["field"]]) ?? []) as List).map((e) {
                                                    return e[res['field']];
                                                  }).isEmpty
                                                      ? Padding(
                                                          padding: const EdgeInsets.only(right: 4, bottom: 4),
                                                          child: Container(
                                                            height: 24,
                                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                            decoration: BoxDecoration(
                                                                color: ColorTheme.kBackGroundGrey,
                                                                borderRadius: BorderRadius.circular(4),
                                                                border: Border.all(
                                                                  color: ColorTheme.kBorderColor,
                                                                  width: 1,
                                                                )),
                                                            child: TextWidget(
                                                              text: 'No ${res['text']} Assigned',
                                                              color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                              fontSize: 12,
                                                              fontWeight: FontTheme.notoSemiBold,
                                                              height: 1,
                                                            ),
                                                          ),
                                                        )
                                                      : Wrap(
                                                          children: [
                                                            ...List.generate(
                                                              (((controller.setDefaultData.formData)[res["field"]]) as List).map((e) {
                                                                return e[res['field']];
                                                              }).length,
                                                              (index) => Padding(
                                                                padding: const EdgeInsets.only(right: 4, bottom: 4),
                                                                child: Container(
                                                                  height: 24,
                                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                                  decoration: BoxDecoration(
                                                                      color: ColorTheme.kBackGroundGrey,
                                                                      borderRadius: BorderRadius.circular(4),
                                                                      border: Border.all(
                                                                        color: ColorTheme.kBorderColor,
                                                                        width: 1,
                                                                      )),
                                                                  child: TextWidget(
                                                                    text: (((controller.setDefaultData.formData)[res["field"]]) as List).map((e) {
                                                                          return e[res['field']];
                                                                        }).toList()[index] ??
                                                                        "",
                                                                    color: ColorTheme.kPrimaryColor.withOpacity(0.8),
                                                                    fontSize: 12,
                                                                    fontWeight: FontTheme.notoSemiBold,
                                                                    height: 1,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                ],
                                              ),
                                            );
                                          });

                                        default:
                                          return Builder(builder: (context) {
                                            var textController = TextEditingController(text: controller.setDefaultData.filterData[res["field"]].toString().isNotNullOrEmpty ? controller.setDefaultData.filterData[res["field"]].toString() : '');
                                            return constrainedBoxWithPadding(
                                                width: res['gridsize'],
                                                child: CustomTextFormField(
                                                  focusNode: focusNodes[focusOrderCode],
                                                  textInputType: TextInputType.text,
                                                  controller: textController,
                                                  hintText: "Enter ${res["text"]}",
                                                  inputFormatters: [if (res['field'] == 'email' || res['field'] == 'person_email' || res['field'] == 'personemail') inputTextEmailRegx else inputTextRegx],
                                                  showSuffixDivider: (res.containsKey('suffixtext') && res['suffixtext'] != null),
                                                  suffixWidget: (res.containsKey('suffixtext') && res['suffixtext'] != null)
                                                      ? TextWidget(
                                                          text: res['suffixtext'],
                                                        ).paddingSymmetric(horizontal: 4)
                                                      : null,
                                                  validator: (v) {
                                                    return null;
                                                  },
                                                  textFieldLabel: res["text"],
                                                  onChanged: (v) async {
                                                    controller.setDefaultData.formData[res["field"]] = v;
                                                  },
                                                ));
                                          });
                                      }
                                    }),
                                    if (controller.isEdit.value)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: CustomButton(
                                          onTap: () async {
                                            await controller.onSaveProfileData(reqData: controller.setDefaultData.formData);
                                          },
                                          height: 40,
                                          width: 140,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          buttonColor: ColorTheme.kPrimaryColor,
                                          fontColor: ColorTheme.kWhite,
                                          borderRadius: 4,
                                          title: 'Save',
                                        ).paddingSymmetric(vertical: 12, horizontal: 8),
                                      ),
                                  ],
                                );
                              }),
                            ),
                          ),
                          Visibility(
                            visible: !kIsWeb,
                            child: Align(
                              alignment: FractionalOffset.centerLeft,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 8),
                                      child: CustomButton(
                                        onTap: () async {
                                          CustomDialogs().customDialog(
                                              buttonCount: 2,
                                              content: 'Are you sure? want to "Log out" !',
                                              onTapPositive: () {
                                                AuthRepo().onLogOut();
                                              });
                                        },
                                        height: 40,
                                        width: 70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        buttonColor: ColorTheme.kBackGroundGrey,
                                        fontColor: ColorTheme.kPrimaryColor,
                                        borderRadius: 4,
                                        title: 'Log Out',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 8),
                                      child: CustomButton(
                                        onTap: () {
                                          AuthRepo().onDeleteAccount();
                                        },
                                        height: 40,
                                        width: 70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        buttonColor: ColorTheme.kPrimaryColor,
                                        fontColor: ColorTheme.kWhite,
                                        borderRadius: 4,
                                        title: 'Delete Account',
                                      ),
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
              }));
        },
      ),
    );
  }
}
