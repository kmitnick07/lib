import 'dart:async';
import 'dart:io';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/dashboard/dashboard_controller.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:prestige_prenew_frontend/controller/login_screen_controller.dart';
import 'package:prestige_prenew_frontend/global_screen_bindings.dart';
import 'package:prestige_prenew_frontend/models/Menu/menu_model.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/api_constant.dart';
import '../../../config/api_provider.dart';
import '../../../models/auth_model.dart';
import '../../../utils/aws_service/aws_manager.dart';
import '../../customs/custom_dialogs.dart';

class AuthRepo {
  Map<String, String> commonHeaders = {
    'token': Settings.authToken,
    'issuer': HeaderConstant.issuer,
    'unqkey': Settings.unqKey,
    'uid': Settings.uid,
    'platform': IISMethods.platform,
  };

  // LoginScreenController loginScreenController = Get.find<LoginScreenController>();

  Future<GetAccessTokenModel?> getAccToken() async {
    isSessionExpired = false;
    try {
      String issuer = HeaderConstant.issuer;
      Map<String, String> headers = {
        'key': HeaderConstant.apiKey,
        'issuer': issuer,
      };
      final response = await ApiProvider().httpMethod(url: ApiConstant.getAccTokenUrl, method: "POST", headers: headers);
      return GetAccessTokenModel.fromJson(response);
    } catch (er) {
      // rethrow;
      devPrint(er);
    }
    return null;
  }

  Future<LoginUserModel?> sendLoginRequest({reqBody}) async {
    isSessionExpired = false;
    try {
      Map<String, String> headers = IISMethods().defaultHeaders(userAction: 'logindata', pageName: 'home', masterListing: false);
      final response = await ApiProvider().httpMethod(url: ApiConstant.login, method: "POST", headers: headers, requestBody: reqBody);
      if (response['status'] == 200) {
        LoginUserModel? data = LoginUserModel.fromJson(Map<String, dynamic>.from(response['data']));
        try {
          Settings.userName = data.name ?? '';
          Settings.userRoleId = data.userrole?.first.userroleid ?? '';
          Settings.userRole = data.userrole?.first.userrole ?? '';
          Settings.uid = data.id ?? '';
          Settings.isUserLogin = true;
          await getLoginData();
          await Get.find<LayoutTemplateController>().getMenuList();
          Get.find<LayoutTemplateController>().getBottomBarRights();
          Get.find<LayoutTemplateController>().showDrawer.value = true;
          // showSuccess(response["message"]);
        } catch (e) {
          devPrint(e);
        }
        return data;
      } else {
        showError(response["message"]);
      }

      return null;
    } catch (er) {
      rethrow;
    }
  }

  bool islogingOut = false;

  onLogOut() async {
    if (!islogingOut) {
      devPrint("object logout");
      if (Settings.isUserLogin) {
        try {
          islogingOut = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            int platform = kIsWeb
                ? 1 //Web
                : Platform.isAndroid
                    ? 2 //Android
                    : Platform.isIOS
                        ? 3 //iOS
                        : 3;
            Map<String, String> headers = IISMethods().defaultHeaders(userAction: 'logindata', pageName: 'home', masterListing: false);

            final response = await ApiProvider().httpMethod(url: ApiConstant.logOut, method: "POST", headers: headers, requestBody: {"os": platform});
            if (response['status'] == 200) {
              final data = response['data'];
              if (Settings.isMSLogin) {
                GlobalScreenBindings().dependencies();
                Config config = Config(
                  tenant: data['ms_tenantid'] ?? "",
                  clientId: data['ms_clientid'] ?? "",
                  scope: data['ms_scope'] ?? "",
                  clientSecret: data['ms_clientsecret'] ?? "",
                  redirectUri: data['ms_redirecturi'] ?? "",
                  navigatorKey: Get.rootDelegate.navigatorKey,
                );
                AadOAuth oauth = AadOAuth(config);
                await oauth.logout(showWebPopup: false).onError((e, s) {
                  devPrint(e.toString());
                });
              }
              Settings.clear();
              Get.rootDelegate.history.clear();
              await Get.delete<DashBoardController>(force: true);
              await Future.delayed(const Duration(seconds: 1));
              Get.find<LayoutTemplateController>().scaffoldkey.currentState?.closeDrawer();
              Get.find<LayoutTemplateController>().showDrawer.value = false;
              Get.find<LayoutTemplateController>().showDrawer.refresh();
              showBottomBar.value = false;
              expandedIndex.value = -1;
              navigateTo(RouteNames.kLoginScreen);
            }
          });
        } catch (er) {
          rethrow;
        }
        islogingOut = false;
      }
    }
  }

  onDeleteAccount() async {
    await onLogOut();
    launchUrl(Uri.parse('https://prenew.in/deleteaccount'));
  }

  Future forgetPasswordRequest({email, required bool isResend}) async {
    try {
      isSessionExpired = false;
      Map<String, String> headers = commonHeaders;
      Map<String, String> reqBody = {
        'email': email,
      };

      final response = await ApiProvider().httpMethod(url: ApiConstant.forgetPassword, method: "POST", headers: headers, requestBody: reqBody);
      if (response['status'] == 200) {
        if (Get.find<LoginScreenController>().timer.isActive) {
          Get.find<LoginScreenController>().timer.cancel();
        }
        Get.find<LoginScreenController>().seconds.value = 60;
        Get.find<LoginScreenController>().view.value = 3;
        Get.find<LoginScreenController>().otpSent.value = true;
        showSuccess(response["message"]);

        return response;
      } else {
        showError(response["message"]);
      }
      return null;
    } catch (er) {
      rethrow;
    }
  }

  Future sendLoginOtp(String employeeid) async {
    try {
      isSessionExpired = false;
      Map<String, String> headers = IISMethods().defaultHeaders(userAction: 'login', pageName: 'login');
      Map<String, String> reqBody = {"employeeid": employeeid};

      final response = await ApiProvider().httpMethod(url: ApiConstant.employeeLogin, method: "POST", headers: headers, requestBody: reqBody);

      if (response['status'] == 200) {
        showSuccess(response["message"]);
        return response;
      } else {
        showError(response["message"]);
      }
      return null;
    } catch (er) {
    }
  }

  Future resetPassword({otp, email, password}) async {
    try {
      isSessionExpired = false;
      Map<String, String> headers = commonHeaders;
      Map<String, String> reqBody = {
        "email": email,
        "newpassword": password,
        "otp": otp,
      };
      final response = await ApiProvider().httpMethod(url: ApiConstant.resetPassword, method: "POST", headers: headers, requestBody: reqBody);
      if (response['status'] == 200) {
        Get.find<LoginScreenController>().view.value = 1;
        // showSuccess(response["message"]);
        return response;
      } else {
        showError(response["message"]);
      }
      return null;
    } catch (er) {
      rethrow;
    }
  }

  Future<LoginDataModel?> getLoginData() async {
    try {
      Map<String, String> headers = IISMethods().defaultHeaders(userAction: 'logindata', pageName: 'home', masterListing: false);
      final response = await ApiProvider().httpMethod(
        url: ApiConstant.loginData,
        method: "POST",
        headers: headers,
      );
      if (response['status'] == 200) {
        LoginDataModel data = LoginDataModel.fromJson(response);
        Settings.loginData = data;
        AwsManager().init();
        return data;
      }
      IISMethods().sessionExpiry(response);
      return null;
    } catch (er) {
      rethrow;
    }
  }
}
