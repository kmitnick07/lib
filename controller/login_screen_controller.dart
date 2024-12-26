import 'dart:async';
import 'dart:io';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/repo/auth/auth_repo.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/routes/route_generator.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:video_player/video_player.dart';

import '../components/customs/custom_dialogs.dart';
import '../components/customs/loader.dart';
import '../config/api_constant.dart';
import '../config/api_provider.dart';
import '../config/dev/dev_helper.dart';
import '../config/iis_method.dart';
import '../models/auth_model.dart';
import '../style/assets_string.dart';
import '../utils/aws_service/file_data_model.dart';
import 'layout_templete_controller.dart';

class jsonLoginScreenController extends GetxController {
  RxString pageName = ''.obs;
  RxString empId = ''.obs;
  RxInt view = 1.obs;
  RxBool isOtpSend = false.obs;
  RxBool showPwd = true.obs;
  RxBool otpSent = false.obs;
  RxBool isCheckBoxFill = false.obs;
  RxBool isForgotPassword = false.obs;
  RxBool isOtpScreen = false.obs;
  RxBool isResendShow = false.obs;
  RxInt startSecTimer = 0.obs;
  FocusNode pinPutFocus = FocusNode();
  RxBool isLoading = false.obs;
  TextEditingController pinPutController = TextEditingController();
  TextEditingController txtPasswordController = TextEditingController();
  TextEditingController txtEmailController = TextEditingController();
  TextEditingController txtOtpController = TextEditingController();
  TextEditingController txtNewPasswordController = TextEditingController();
  TextEditingController txtConfirmPasswordController = TextEditingController();
  RxBool videoInitialised = false.obs;
  RxBool isMSLoginDataLoading = true.obs;
  RxBool isMSLoginEnable = false.obs;
  RxBool isSendRequest = false.obs;
  RxBool isSendOtp = false.obs;
  RxMap<String, dynamic> appInitData = <String, dynamic>{}.obs;

  VideoPlayerController videoPlayerController = VideoPlayerController.asset(AssetsString.kLoginBackgroundMp4);

  ChewieController? chewieController;

  RxBool controllerInitialized = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    tapOnBtnSignInWith365();
    showPwd.value = true;
    pageName.value = "login" /*getCurrentName()*/;
    setPageTitle('PRENEW by Prestige Group', Get.context!);
    devPrint(pageName.value);
    isLoading.listen(
      (p0) {
        pinPutFocus.requestFocus();
      },
    );
  }

  @override
  void dispose() {
    Get.delete<LoginScreenController>();
    super.dispose();
  }

  Future<void> initilizeVideo() async {
    if (Get.rootDelegate.history.last.locationString == RouteNames.kLoginScreen) {
      await initializeVideoPlayer();

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: false,
        autoInitialize: true,
      );
      controllerInitialized.value = true;
    }
  }

  @override
  onClose() {
    videoPlayerController.removeListener(() {});
    // videoPlayerController.dispose();
    // chewieController?.dispose();
  }

  Future<void> initializeVideoPlayer() async {
    await videoPlayerController.initialize();
    videoPlayerController.setLooping(true);
    videoPlayerController.setVolume(0.0);
    videoPlayerController.addListener(() {
      if (videoPlayerController.value.isInitialized) {
        videoInitialised.value = true;
      }
    });
  }

  final formKey = GlobalKey<FormState>();

  RxInt seconds = 00.obs;
  Timer timer = Timer(const Duration(seconds: 0), () {});

  Widget resendBtn(String empId) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        sendOtp(empId);
      },
      child: const SizedBox(
        width: double.infinity,
        child: TextWidget(
          text: "Resend OTP",
          fontWeight: FontTheme.notoSemiBold,
          textAlign: TextAlign.end,
        ),
      ),
    );
  }

  void startTimer() {
    isResendShow.value = false;
    if (kDebugMode) {
      startSecTimer.value = 5;
    } else {
      startSecTimer.value = 30;
    }
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (startSecTimer.value == 0) {
          timer.cancel();
          isResendShow.value = true;
        } else {
          startSecTimer--;
        }
      },
    );
  }

  Future<GetAccessTokenModel?> getAccessToken() async {
    GetAccessTokenModel? response = await AuthRepo().getAccToken();
    Settings.uid = response?.data?.uid ?? '';
    Settings.unqKey = response?.data?.unqkey ?? '';
    return response;
  }

  void handleFormSubmission() {
    if (formKey.currentState!.validate()) {
      if (view.value == 1) {
        onLogin(
          email: txtEmailController.text,
          password: txtPasswordController.text,
        );
      } else if (view.value == 2) {
        getAccessToken();
        if (!(seconds.value > 0)) {
          AuthRepo().forgetPasswordRequest(email: txtEmailController.text, isResend: true);
        }
      } else if (view.value == 3) {
        getAccessToken();
        AuthRepo().resetPassword(
          email: txtEmailController.text,
          otp: txtOtpController.text,
          password: txtConfirmPasswordController.text,
        );
      }
    }
  }

  Future<void> onLogin({String? empId, String? email, String? password, String? accessToken, bool? isEmployee, bool? isms}) async {
    GetAccessTokenModel? accessTokenResponse = await getAccessToken();
    if (accessTokenResponse?.status == 200) {
      Map<String, dynamic> reqBody = {};
      if (!(isEmployee ?? false) && email.isNotNullOrEmpty) {
        reqBody['email'] = email;
        reqBody['password'] = password;
        reqBody['is_ms'] = 0;
      } else if (isms ?? false) {
        reqBody['accessToken'] = accessToken;
        reqBody['is_ms'] = 1;
      } else {
        reqBody['employeeid'] = empId;
        reqBody['otp'] = password;
        reqBody['is_ms'] = 0;
      }
      LoginUserModel? loginResponse = await AuthRepo().sendLoginRequest(reqBody: reqBody);
      if (loginResponse != null) {
        if (isCheckBoxFill.value) {
          Settings.adminEmail = txtEmailController.text;
          Settings.adminPassword = txtPasswordController.text;
        }
        Settings.email = loginResponse.email ?? '';
        Settings.isMSLogin = isms ?? false;
        Settings.profile = loginResponse.photo ?? FilesDataModel();
        Settings.isUserLogin = true;
        txtEmailController.text = "";
        txtPasswordController.text = "";
        isOtpSend.value = false;
        // videoPlayerController.removeListener(() {});
        // videoPlayerController.dispose();
        // chewieController?.dispose();
        Get.rootDelegate.history.clear();
        showBottomBar.value = true;
        navigateTo(RouteNames.kDashboard);
      }
    }
    view.value = 1;
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  onChangeCheckBox(bool? val) {
    isCheckBoxFill.value = val ?? true;
  }

  clearTextField() {
    txtPasswordController.text = "";
    txtOtpController.text = "";
    txtNewPasswordController.text = "";
    txtConfirmPasswordController.text = "";
    pinPutController.clear();
  }

  Future<void> handleOtp(String otp) async {
    if (!isSendOtp.value) {
      isSendOtp.value = true;
      if (otp.isNotNullOrEmpty) {
        await onLogin(empId: empId.value, password: otp);
        clearTextField();
      }
      isSendOtp.value = false;
    }
  }

  Future<void> sendOtp(String employeeId) async {
    if (!isSendRequest.value) {
      isSendRequest.value = true;
      await getAccessToken().then(
        (val) async {
          var data = await AuthRepo().sendLoginOtp(employeeId);
          if (data != null) {
            pinPutController.clear();
            empId.value = employeeId;
            isOtpSend.value = true;
            if (kDebugMode) {
              Future.delayed(
                const Duration(milliseconds: 500),
                () {
                  pinPutController.text = '111111';
                },
              );
            }
            startTimer();
          }
        },
      );
      isSendRequest.value = false;
    }
  }

  afterTapOnBtnSignInWith365() async {
    isSessionExpired = false;
    AppLoader();
    // int platform = kIsWeb
    //     ? 1
    //     : Platform.isAndroid
    //     ? 2
    //     : Platform.isIOS
    //     ? 3
    //     : 3;
    // Map<String, String> headers = IISMethods().defaultHeaders(userAction: 'logindata', pageName: 'home', masterListing: false);
    // final response = await ApiProvider().httpMethod(url: ApiConstant.appInit, method: "POST", headers: headers, requestBody: {"os": platform});
    //
    // devPrint("MS login ---> 85241468868784");
    // if (response != null && response['status'] == 200) {
    final data = appInitData.value;
    devPrint("5632416534165341653    ${data['ms_clientid']}");
    Config config = Config(
        tenant: data['ms_tenantid'] ?? "", clientId: data['ms_clientid'] ?? "", scope: data['ms_scope'] ?? "", clientSecret: data['ms_clientsecret'] ?? "", redirectUri: data['ms_redirecturi'] ?? "", navigatorKey: Get.rootDelegate.navigatorKey);

    try {
      AadOAuth oauth = AadOAuth(config);

      String accessToken = "";
      final result = await oauth.login();
      result.fold(
        (failure) => devPrint(failure.toString()),
        (token) {
          accessToken = token.accessToken ?? '';
          devPrint('Logged in successfully, your access token: $token');
        },
      );

      devPrint('=========$accessToken');

      if (accessToken.isNotNullOrEmpty) {
        onLogin(isms: true, accessToken: accessToken);
        devPrint("$accessToken    466561165161");
      } else {
        showError("Something went wrong.");
      }
    } catch (e) {
      devPrint('=====error====${e.toString()}');
    }
    // }
    // devPrint(response);
    RemoveAppLoader();
  }

  tapOnBtnSignInWith365() async {
    isSessionExpired = false;
    // AppLoader();
    isMSLoginDataLoading.value = true;
    int platform = kIsWeb
        ? 1
        : Platform.isAndroid
            ? 2
            : Platform.isIOS
                ? 3
                : 3;
    Map<String, String> headers = IISMethods().defaultHeaders(userAction: 'logindata', pageName: 'home', masterListing: false);
    final response = await ApiProvider().httpMethod(url: ApiConstant.appInit, method: "POST", headers: headers, requestBody: {"os": platform});

    devPrint("MS login ---> 85241468868784");
    if (response != null && response['status'] == 200) {
      // final data = response['data'];
      appInitData.value = response?['data'] ?? {};
      isMSLoginEnable.value = response?['data']?['showmslogin'] ?? false;
      devPrint("$appInitData    68512465465");
      // Config config = Config(
      //     tenant: data['ms_tenantid'] ?? "",
      //     clientId: data['ms_clientid'] ?? "",
      //     scope: data['ms_scope'] ?? "",
      //     clientSecret: data['ms_clientsecret'] ?? "",
      //     redirectUri: data['ms_redirecturi'] ?? "",
      //     navigatorKey: Get.rootDelegate.navigatorKey);
      //
      // try {
      //   AadOAuth oauth = AadOAuth(config);
      //
      //   String accessToken = "";
      //   final result = await oauth.login();
      //   result.fold(
      //     (failure) => devPrint(failure.toString()),
      //     (token) {
      //       accessToken = token.accessToken ?? '';
      //       devPrint('Logged in successfully, your access token: $token');
      //     },
      //   );
      //
      //   devPrint('=========$accessToken');
      //
      //   if (accessToken.isNotNullOrEmpty) {
      //     onLogin(isms: true, accessToken: accessToken);
      //     devPrint("$accessToken    466561165161");
      //   } else {
      //     showError("Something went wrong.");
      //   }
      // } catch (e) {
      //   devPrint('=====error====${e.toString()}');
      // }
    }
    devPrint(response);
    // RemoveAppLoader();
    isMSLoginDataLoading.value = false;
  }
}
