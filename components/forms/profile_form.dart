import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config/helper/device_service.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../style/assets_string.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../customs/custom_dialogs.dart';
import '../customs/custom_text_form_field.dart';
import '../customs/custom_tooltip.dart';
import '../funtions.dart';
import '../repo/auth/auth_repo.dart';

class ProfileForm extends StatelessWidget {
  ProfileForm({
    super.key,
    this.isMasterForm = false,
    this.title = "Profile",
    required this.setDefaultData,
    this.btnName = "Save",
  });

  final bool isMasterForm;
  final String title;
  final String btnName;
  final FormDataModel setDefaultData;
  RxBool isEdit = false.obs;
  RxString userName = ''.obs;

  final Map<int, FocusNode> focusNodes = {};

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);

    Widget filterForm() {
      return ResponsiveBuilder(builder: (context, sizeInformation) {
        return Form(
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
                        text: title,
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.kPrimaryColor,
                        fontSize: 18,
                      ),
                      const Spacer(),
                      Obx(() {
                        return CustomTooltip(
                          message: !isEdit.value ? 'Edit' : 'Reset',
                          child: IconButton(
                            focusNode: FocusNode(canRequestFocus: false),
                            onPressed: () {
                              setDefaultData.formData.value = IISMethods().encryptDecryptObj(setDefaultData.oldFormData.value);
                              isEdit.value = !isEdit.value;
                            },
                            icon: Obx(() {
                              return Icon(!isEdit.value ? Icons.edit : Icons.lock_reset);
                            }),
                          ),
                        );
                      }),
                      InkWell(
                        onTap: () {
                          setDefaultData.filterData.value = IISMethods().encryptDecryptObj(setDefaultData.oldFormData.value);
                          setDefaultData.filterData.removeNullValues();

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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(() {
                    return Wrap(
                      children: [
                        ...List.generate(setDefaultData.fieldOrder.length, (i) {
                          Map<String, dynamic> res = IISMethods().encryptDecryptObj(setDefaultData.fieldOrder[i]);

                          var focusOrderCode = generateUniqueFieldId(0, i, null, null);
                          if (!focusNodes.containsKey(focusOrderCode)) {
                            focusNodes[focusOrderCode] = FocusNode();
                          }
                          if (!isEdit.value) {
                            res['disabled'] = true;
                          }
                          switch (res["type"]) {
                            case HtmlControls.kNumberInput:
                              int cursorPos = 0;
                              return Obx(() {
                                var textController = TextEditingController(
                                    text: (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]].toString().isEmpty || (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] == null
                                        ? ""
                                        : (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]].toString());
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
                                        (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] = v;
                                        cursorPos = textController.selection.extent.offset;
                                      },
                                    ));
                              });

                            case HtmlControls.kAvatarPicker:
                              return Builder(builder: (context) {
                                RxBool docLoading = false.obs;
                                return Obx(
                                  () {
                                    int cursorPos = 0;
                                    var field = (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] ?? {};
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
                                        Obx(() {
                                          return Row(
                                            children: [
                                              docLoading.value
                                                  ? const CupertinoActivityIndicator(color: ColorTheme.kBlack).paddingSymmetric(horizontal: 8)
                                                  : setDefaultData.formData[res['field']] != null
                                                      ? InkWell(
                                                          onTap: () {
                                                            documentDownload(imageList: FilesDataModel.fromJson(setDefaultData.formData[res['field']] ?? {}));
                                                          },
                                                          child: Container(
                                                            height: 64,
                                                            width: 64,
                                                            clipBehavior: Clip.hardEdge,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                            child: Image.network(
                                                              FilesDataModel.fromJson(setDefaultData.formData[res['field']] ?? {}).name ?? "",
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return SvgPicture.asset(
                                                                  AssetsString.kUser,
                                                                );
                                                              },
                                                            ),
                                                          ).paddingOnly(right: 12),
                                                        )
                                                      : SvgPicture.asset(
                                                          AssetsString.kUser,
                                                        ).paddingOnly(right: 12),
                                              if (isEdit.value)
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
                                                              docLoading.value = true;
                                                              List<FilesDataModel> fileModelList = await IISMethods().pickSingleFile(fileType: res["filetypes"]);
                                                              fileModelList = await IISMethods().uploadFiles(fileModelList);
                                                              (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] = fileModelList.first.toJson();
                                                              docLoading.value = false;
                                                            },
                                                            title: ((setDefaultData.formData[res['field']] ?? '').toString().isNullOrEmpty) ? res['uploadtext'] : res['uploadedtext'],
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
                                          );
                                        }),
                                      ],
                                    ).paddingSymmetric(horizontal: 6, vertical: 8);
                                  },
                                );
                              });

                            case HtmlControls.kInputText:
                              int cursorPos = 0;
                              return Obx(() {
                                var textController = TextEditingController(
                                    text: (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]].toString().isEmpty || (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] == null
                                        ? ""
                                        : (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]].toString());
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
                                        (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] = v;
                                        cursorPos = textController.selection.extent.offset;
                                        userName.value = v.toCamelCase;
                                      },
                                    ));
                              });

                            case HtmlControls.kInputTextArea:
                              int cursorPos = 0;
                              return Obx(() {
                                var textController = TextEditingController(
                                    text: (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]].toString().isEmpty || (isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] == null
                                        ? ""
                                        : (((isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]]) ?? []).map((e) {
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
                                        text: res['text'],
                                        fontFamily: FontTheme.themeFontFamily,
                                        fontWeight: FontTheme.notoRegular,
                                        color: ColorTheme.kBlack,
                                        fontSize: 12,
                                      ).paddingOnly(bottom: 4),
                                      (((isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]] ?? []) as List).map((e) {
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
                                                  (((isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]]) as List).map((e) {
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
                                                        text: (((isMasterForm ? setDefaultData.masterFormData : setDefaultData.formData)[res["field"]]) as List).map((e) {
                                                          return e[res['field']];
                                                        }).toList()[index],
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
                                var textController = TextEditingController(text: setDefaultData.filterData[res["field"]].toString().isNotNullOrEmpty ? setDefaultData.filterData[res["field"]].toString() : '');
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
                                        setDefaultData.formData[res["field"]] = v;
                                      },
                                    ));
                              });
                          }
                        }),
                      ],
                    );
                  }),
                ),
              ),
              Visibility(
                child: Align(
                  alignment: FractionalOffset.centerLeft,
                  child: Obx(() {
                    return isEdit.value
                        ? Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  child: CustomButton(
                                    onTap: () async {
                                      setDefaultData.formData.removeNullValues();
                                      await onSaveProfileData(reqData: setDefaultData.formData);
                                    },
                                    height: 40,
                                    width: 70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    buttonColor: ColorTheme.kPrimaryColor,
                                    fontColor: ColorTheme.kWhite,
                                    borderRadius: 4,
                                    title: btnName,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 4),
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
                                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 24),
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
                          );
                  }),
                ),
              )
            ],
          ),
        );
      });
    }

    if (deviceType == DeviceScreenType.mobile) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: ColorTheme.kWhite,
        ),
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        child: filterForm(),
      );
    }

    return Dialog(
      backgroundColor: ColorTheme.kWhite,
      alignment: Alignment.centerRight,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
      insetPadding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: ColorTheme.kWhite,
        ),
        width: 400,
        child: filterForm(),
      ),
    );
  }

  RxInt statusCode = 0.obs;
  RxString message = ''.obs;

  Future onSaveProfileData({
    required Map reqData,
    int? editeDataIndex = -1,
  }) async {
    var url = '${Config.weburl}user/profile/update';

    var userAction = "updateprofile";

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: userAction, pageName: "profile");

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = await resBody["message"];
      try {
        if (resBody.containsKey('data')) {
          Settings.profile = (resBody['data']['photo'])?['url'] ?? '';
          Settings.userName = resBody['data']['name'] ?? '';
          setDefaultData.data.refresh();
          showSuccess(message.value);
        } else {
          showSuccess(message.value);
        }
      } catch (e) {
        showSuccess(message.value);
      }
      Get.back();
    } else {
      message.value = resBody['message'];
      showError(message.value);
    }
  }
}
