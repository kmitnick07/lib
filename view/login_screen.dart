import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/prenew_logo.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/login_screen_controller.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../components/customs/custom_dialogs.dart';
import '../style/assets_string.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginScreenController controller = Get.put(LoginScreenController());

  @override
  void initState() {
    if (Settings.isUserLogin) {
      Get.rootDelegate.history.clear();
      navigateTo(RouteNames.kDashboard);
    } else {
      if (kIsWeb) controller.pinPutFocus.requestFocus();
      controller.initilizeVideo();
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.videoPlayerController.dispose();
    controller.chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (kIsWeb) controller.pinPutFocus.requestFocus();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          bool isMobile = sizingInformation.isMobile;
          return Stack(
            children: [
              Obx(() =>
              controller.videoInitialised.value
                  ? Transform.flip(
                flipX: true,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      height: controller.videoPlayerController.value.size.height,
                      width: controller.videoPlayerController.value.size.width,
                      child: Chewie(controller: controller.chewieController!),
                    ),
                  ),
                ),
              )
                  : const SizedBox()),
              Container(
                color: ColorTheme.kWhite.withOpacity(0.6),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery
                              .of(context)
                              .size
                              .height * 0.8,
                          maxWidth: 450,
                        ),
                        decoration: BoxDecoration(
                          color: ColorTheme.kWhite.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: PrenewLogo(
                                        size: 90,
                                      ),
                                    ),
                                    Text(
                                      'WELCOME TO',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isMobile ? 14 : 16,
                                        fontWeight: FontTheme.notoRegular,
                                        height: 1,
                                      ),
                                    ),
                                    Text(
                                      'PRENEW',
                                      style: GoogleFonts.montserrat(
                                        fontSize: isMobile ? 34 : 38,
                                        fontWeight: FontTheme.notoSemiBold,
                                        height: 1,
                                      ),
                                    ),
                                    SizedBox(
                                      height: isMobile ? 8 : 12,
                                    ),
                                    /*controller.pageName.value == "login"
                                                ?*/
                                    Column(
                                      children: [
                                        Obx(() {
                                          return TextWidget(
                                            text: !controller.isOtpSend.value ? 'Employee ID' : "Enter OTP",
                                            fontSize: isMobile ? 12 : 14,
                                            fontWeight: FontTheme.notoRegular,
                                            color: ColorTheme.kBlack,
                                          );
                                        }),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: SizedBox(
                                            width: 218,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: ColorTheme.kBlack.withOpacity(0.2),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(4.0),
                                                    child: SizedBox(
                                                      height: 42,
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                            child: Pinput(
                                                              autofocus: kIsWeb,
                                                              onSubmitted: (val) {
                                                                clearFocus();
                                                              },
                                                              defaultPinTheme: const PinTheme(
                                                                textStyle: TextStyle(
                                                                  color: ColorTheme.kBlack,
                                                                  fontWeight: FontTheme.notoBold,
                                                                  fontSize: 18,
                                                                ),
                                                                width: 18,
                                                                height: 22,
                                                              ),
                                                              focusNode: controller.pinPutFocus,
                                                              controller: controller.pinPutController,
                                                              closeKeyboardWhenCompleted: false,
                                                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                              onCompleted: (value) async {
                                                                controller.isLoading.value = true;
                                                                controller.isLoading.refresh();

                                                                if (!controller.isOtpSend.value) {
                                                                  await controller.sendOtp(value);
                                                                } else {
                                                                  await controller.handleOtp(value);
                                                                }
                                                                controller.isLoading.value = false;
                                                                controller.isLoading.refresh();
                                                              },
                                                              length: 6,
                                                              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          InkWell(
                                                            onTap: !controller.isLoading.value
                                                                ? () async {
                                                              controller.isLoading.value = true;
                                                              controller.isLoading.refresh();
                                                              if (controller.pinPutController.text.isNotNullOrEmpty) {
                                                                if (!controller.isOtpSend.value) {
                                                                  await controller.sendOtp(controller.pinPutController.text);
                                                                } else {
                                                                  await controller.handleOtp(controller.pinPutController.text);
                                                                }
                                                              } else {
                                                                showError((!controller.isOtpSend.value ? 'Employee ID' : "OTP").textFieldErrMsg);
                                                              }
                                                              controller.isLoading.value = false;
                                                              controller.isLoading.refresh();
                                                            }
                                                                : null,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
                                                                color: ColorTheme.kBlack,
                                                              ),
                                                              width: 42,
                                                              height: 42,
                                                              child: Center(
                                                                child: Obx(() {
                                                                  return Visibility(
                                                                    visible: !controller.isLoading.value,
                                                                    replacement: const Padding(
                                                                      padding: EdgeInsets.all(4),
                                                                      child: CupertinoActivityIndicator(
                                                                        color: ColorTheme.kWhite,
                                                                      ),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons.arrow_forward_ios_rounded,
                                                                      color: ColorTheme.kWhite,
                                                                    ),
                                                                  );
                                                                }),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Obx(() {
                                                  return controller.isOtpSend.value
                                                      ? !controller.isResendShow.value
                                                      ? SizedBox(
                                                    width: Get.width,
                                                    child: TextWidget(
                                                      text: "Resend OTP in ${controller.startSecTimer.value} sec",
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  )
                                                      : controller.resendBtn(controller.empId.value)
                                                      : const SizedBox(height: 16);
                                                }).paddingOnly(right: 4),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: isMobile ? 10 : 12,
                                        ),
                                        Obx(() {
                                          return Visibility(
                                            visible: (controller.isMSLoginEnable.value),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const TextWidget(
                                                  text: 'OR',
                                                  fontSize: 14,
                                                ),
                                                SizedBox(
                                                  height: isMobile ? 14 : 18,
                                                ),
                                                InkWell(
                                                  onTap: controller.afterTapOnBtnSignInWith365,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: ColorTheme.kWhite,
                                                        border: Border.all(
                                                          color: ColorTheme.kBorderColor,
                                                        )),
                                                    height: 48,
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        SvgPicture.asset(
                                                          AssetsString.kMicroSoftLogo,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        const TextWidget(
                                                          text: 'Sign in With Microsoft',
                                                          fontWeight: FontTheme.notoSemiBold,
                                                          fontSize: 17,
                                                          color: ColorTheme.kMicrosoftText,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Obx(() {
                                  return Visibility(
                                    visible: (controller.isOtpSend.value || controller.view.value > 1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: controller.isResendShow.value
                                            ? () {
                                          controller.view.value--;
                                          controller.clearTextField();
                                          controller.isOtpSend.value = false;
                                          controller.isOtpSend.refresh();
                                        }
                                            : null,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: controller.isResendShow.value ? ColorTheme.kBlack.withOpacity(0.7) : ColorTheme.kBlack.withOpacity(0.35),
                                          ),
                                          width: 36,
                                          height: 36,
                                          child: Center(
                                            child: Icon(
                                              size: 14,
                                              Icons.arrow_back_ios_new,
                                              color: controller.isResendShow.value ? ColorTheme.kWhite : ColorTheme.kWhite.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ).paddingAll(24),
                        )),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
