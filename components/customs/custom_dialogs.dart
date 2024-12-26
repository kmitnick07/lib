import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';
import '../prenew_logo.dart';
import 'custom_button.dart';
import 'loader.dart';

FToast fToast = FToast();

void showCustomToast(Widget child) {
  fToast.init(Get.context!);
  fToast.removeCustomToast();
  fToast.showToast(
    child: child,
    gravity: ToastGravity.TOP_RIGHT,
    toastDuration: const Duration(seconds: 5),
    positionedToastBuilder: (context, child) {
      return Positioned(
        top: 16,
        right: 0,
        child: child,
      );
    },
  );
}

class CustomToast extends StatefulWidget {
  final int type;
  final String? title;
  final String? subTitle;

  const CustomToast({super.key, required this.type, this.title, this.subTitle});

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> with SingleTickerProviderStateMixin {
  double time = 0.0;
  int t = 0;
  Timer? timer;

  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<Offset> _animation = Tween<Offset>(
    begin: const Offset(1.5, 0),
    end: const Offset(0, 0),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void initState() {
    _controller.forward();
    Future.delayed(const Duration(seconds: 5)).then((value) {
      _controller.reverse();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, minWidth: 200),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            border: Border.all(width: 1, color: const Color.fromRGBO(223, 223, 223, 0.81)),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                spreadRadius: 1,
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  widget.type == 1
                      ? AssetsString.kSuccess
                      : widget.type == 3
                          ? AssetsString.kWarning
                          : AssetsString.kError,
                  height: 25,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3, left: 5),
                      child: TextWidget(
                        text: widget.title ??
                            (widget.type == 1
                                ? 'Success!'
                                : widget.type == 3
                                    ? 'Warning!'
                                    : 'Error!'),
                        fontSize: 18,
                        color: widget.type == 1
                            ? const Color(0xFF1AB595)
                            : widget.type == 3
                                ? const Color(0xFFFFB900)
                                : const Color(0xFFF56E6E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Visibility(
                      visible: widget.subTitle.isNotNullOrEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6, left: 5),
                        child: TextWidget(
                          text: widget.subTitle ?? '',
                          textOverflow: TextOverflow.visible,
                          fontSize: 12,
                          color: ColorTheme.kTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: ColorTheme.kGrey.withOpacity(0.25)),
                child: IconButton(
                  onPressed: () {
                    _controller.reverse();
                    Future.delayed(
                      const Duration(seconds: 1),
                      () {
                        fToast.removeCustomToast();
                      },
                    );
                  },
                  hoverColor: Colors.transparent,
                  icon: const Icon(
                    Icons.clear,
                    color: ColorTheme.kBlack,
                    size: 12,
                  ),
                ),
              ).paddingOnly(right: 12, left: 30),
            ],
          ),
        ),
      ),
    );
  }
}

void showError(String message) {
  showCustomToast(CustomToast(
    type: 2,
    subTitle: message,
  ));
  // showCustomDialog(child: StatusDialogScreen(message: message, type: 3));
}

void showSuccess(String message) {
  showCustomToast(CustomToast(
    type: 1,
    subTitle: message,
  ));
  // showCustomDialog(child: StatusDialogScreen(message: message, type: 1));
}

class CustomDialogs {
  statusChangeDialog({required Function()? onTap, required int value}) {
    if (!kIsWeb) {
      CustomDialogs().customDialog(
          buttonCount: 2,
          content: "Are you sure you want to change the status to ${value == 1 ? '"Inactive"' : '"Active"'}",
          onTapPositive: () {
            AppLoader();

            if (onTap != null) {
              onTap();
            }
            RemoveAppLoader();
          });
    } else {
      Get.dialog(Dialog(
        surfaceTintColor: ColorTheme.kWhite,
        backgroundColor: ColorTheme.kWhite,
        alignment: Alignment.topCenter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ResponsiveBuilder(builder: (context, sizingInformation) {
          return Container(
            constraints: const BoxConstraints(minWidth: 300, maxWidth: 450),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Container(
                //     padding: EdgeInsets.zero,
                //     decoration: BoxDecoration(
                //       color: ColorTheme.kBlack.withOpacity(0.1),
                //       borderRadius: BorderRadius.circular(5),
                //     ),
                //     child: IconButton(
                //       onPressed: () {
                //         Get.back();
                //       },
                //       splashColor: ColorTheme.kWhite,
                //       hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                //       splashRadius: 20,
                //       constraints: const BoxConstraints(),
                //       padding: EdgeInsets.zero,
                //       icon: const Icon(Icons.clear_rounded),
                //     ),
                //   ),
                // ).paddingOnly(bottom: 16),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!sizingInformation.isMobile)
                        const PrenewLogo(
                          size: 120,
                        ).paddingOnly(right: 7),
                      if (!sizingInformation.isMobile) const VerticalDivider().paddingOnly(right: 7),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: "Are you sure you want to change the status to ${value == 1 ? '"Inactive"' : '"Active"'}",
                              fontSize: 15,
                              color: ColorTheme.kBlack,
                              fontWeight: FontTheme.notoMedium,
                            ).paddingOnly(bottom: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomButton(
                                  title: "Yes",
                                  buttonColor: ColorTheme.kBlack,
                                  fontColor: ColorTheme.kWhite,
                                  height: 40,
                                  width: 90,
                                  borderRadius: 5,
                                  onTap: () {
                                    AppLoader();

                                    if (onTap != null) {
                                      onTap();
                                    }
                                    RemoveAppLoader();
                                  },
                                ),
                                CustomButton(
                                  title: "No",
                                  buttonColor: ColorTheme.kWhite,
                                  fontColor: ColorTheme.kHintTextColor,
                                  showBoxBorder: true,
                                  height: 40,
                                  width: 70,
                                  borderRadius: 5,
                                  onTap: () {
                                    Get.back();
                                  },
                                ).paddingOnly(left: 12),
                              ],
                            ).paddingOnly(bottom: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).paddingOnly(bottom: 20),
              ],
            ),
          );
        }),
      ));
    }
  }

  static Widget alertDialog({Function()? onYes, Function()? onNo, required String message}) {
    var deviceType = getDeviceType(MediaQuery.of(Get.context!).size);
    if (deviceType == DeviceScreenType.mobile) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        title: const TextWidget(
          text: "Alert",
          fontSize: 18,
          color: ColorTheme.kBlack,
          fontWeight: FontTheme.notoMedium,
        ),
        content: TextWidget(
          text: message,
          fontSize: 18,
          color: ColorTheme.kBlack,
          fontWeight: FontTheme.notoMedium,
        ),
        actions: [
          CustomButton(
            title: "Yes",
            buttonColor: ColorTheme.kBlack,
            fontColor: ColorTheme.kWhite,
            height: 40,
            width: 90,
            borderRadius: 5,
            onTap: onYes,
          ),
          CustomButton(
            title: "No",
            buttonColor: ColorTheme.kWhite,
            fontColor: ColorTheme.kHintTextColor,
            showBoxBorder: true,
            height: 40,
            width: 70,
            borderRadius: 5,
            onTap: onNo,
          ),
        ],
      );
    }
    return Dialog(
      surfaceTintColor: ColorTheme.kWhite,
      backgroundColor: ColorTheme.kWhite,
      alignment: Alignment.topCenter,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ResponsiveBuilder(builder: (context, sizingInformation) {
        return Container(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 450),
          padding: const EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (!sizingInformation.isMobile)
                  const PrenewLogo(
                    size: 120,
                  ).paddingOnly(right: 7),
                if (!sizingInformation.isMobile) const VerticalDivider().paddingOnly(right: 7),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: sizingInformation.isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: message,
                        fontSize: 15,
                        color: ColorTheme.kBlack,
                        fontWeight: FontTheme.notoMedium,
                      ).paddingOnly(bottom: 16),
                      Row(
                        mainAxisAlignment: sizingInformation.isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          CustomButton(
                            title: "Yes",
                            buttonColor: ColorTheme.kBlack,
                            fontColor: ColorTheme.kWhite,
                            height: 40,
                            width: 90,
                            borderRadius: 5,
                            onTap: onYes,
                          ),
                          CustomButton(title: "No", buttonColor: ColorTheme.kWhite, fontColor: ColorTheme.kHintTextColor, showBoxBorder: true, height: 40, width: 70, borderRadius: 5, onTap: onNo).paddingOnly(left: 12),
                        ],
                      ).paddingOnly(bottom: 8),
                    ],
                  ),
                ),
              ],
            ),
          ).paddingOnly(bottom: 20),
        );
      }),
    );
  }

  Future<void> customFilterDialogs({required BuildContext context, required Widget widget, EdgeInsetsGeometry? padding}) async {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    if (deviceType == DeviceScreenType.mobile) {
      showBottomBar.value = false;

      await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          expand: false,
          maxChildSize: 1,
          minChildSize: 0.8,
          initialChildSize: 0.8,
          builder:  (context, scrollController) {
            return Padding(
              padding: padding ?? EdgeInsets.zero,
              child: widget,
            );
          }
        ),
        isDismissible: false,

        // isScrollControlled: true,
      );
      showBottomBar.value = true;
    } else {
      await Get.dialog(
        widget,
        barrierDismissible: false,
      );
    }
  }

  Future<void> customPopDialog({required Widget child, AlignmentGeometry? alignment}) async {
    if (getDeviceType(MediaQuery.sizeOf(Get.context!)) == DeviceScreenType.mobile) {
      showBottomBar.value = false;
      await showModalBottomSheet(
        context: Get.context!,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        isScrollControlled: true,
        constraints: BoxConstraints.tight(Size(MediaQuery.of(Get.context!).size.width, MediaQuery.of(Get.context!).size.height * .8)),
        builder: (context) => SizedBox(height: MediaQuery.of(context).size.height - 80, child: child),
        isDismissible: false,

        // isScrollControlled: true,
      );
      showBottomBar.value = true;
    } else {
      await Get.dialog(Dialog(
        surfaceTintColor: ColorTheme.kWhite,
        alignment: alignment ?? Alignment.centerRight,
        insetPadding: EdgeInsets.zero,
        child: child,
      ));
    }
  }

  customDialog({
    required String content,
    required int buttonCount,
    String positiveText = "Yes",
    required Function()? onTapPositive,
    String negativeText = "No",
    Function()? onTapNegative,
  }) {
    return Get.dialog(SimpleDialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.only(top: 50),
              decoration: BoxDecoration(
                color: ColorTheme.kWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 30),
                    child: TextWidget(text: content, textAlign: TextAlign.center, fontSize: 16),
                  ),
                  Row(children: [
                    if (buttonCount == 2)
                      Expanded(
                          child: InkWell(
                        onTap: onTapNegative ??
                            () {
                              Get.back();
                            },
                        child: Container(
                            decoration: const BoxDecoration(
                              color: ColorTheme.kTableHeader,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
                            ),
                            child: SizedBox(
                              height: 50,
                              child: Center(
                                child: TextWidget(
                                  text: negativeText,
                                  fontSize: 16,
                                  color: ColorTheme.kPrimaryColor,
                                ),
                              ),
                            )),
                      )),
                    Expanded(
                        child: InkWell(
                      onTap: onTapPositive ??
                          () {
                            Get.back();
                          },
                      child: Container(
                          decoration: const BoxDecoration(
                            color: ColorTheme.kPrimaryColor,
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
                          ),
                          child: SizedBox(
                            height: 50,
                            child: Center(
                              child: TextWidget(
                                text: positiveText,
                                fontSize: 16,
                                color: ColorTheme.kWhite,
                              ),
                            ),
                          )),
                    ))
                  ]),
                ],
              ),
            ),
            const PrenewLogo(size: 100),
          ],
        ),
      ],
    ));
  }
}
