import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/customs/text_widget.dart';
import '../../components/funtions.dart';
import '../../components/repo/auth/auth_repo.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';
import '../../utils/aws_service/file_data_model.dart';
import '../api_constant.dart';
import '../api_provider.dart';
import '../dev/dev_helper.dart';
import '../iis_method.dart';
import '../settings.dart';

class DeviceData {
  // FirebaseMessaging? firebaseMessaging;
  int isforcefully = 0, isforcelogout = 0;

  String updateAppMsg = "";

  AppUpdateInfo? _updateInfo;

  DeviceData() {
    // firebaseMessaging = FirebaseMessaging.instance;
  }

  //<editor-fold desc = "Send Device Data">

  Future<Map<String, dynamic>> getDeviceData() async {
    Map<String, dynamic> deviceData = <String, dynamic>{};

    String os = "";
    String deviceModelName = "";
    String browserName = "";
    String macAddress = "";
    String deviceID = "";
    String osVersion = "";
    String appVersion = "";

    try {
      // try {
      //   await FirebaseMessaging.instance.getToken().then((value) {
      //     // print(value);
      //     deviceID = value!;
      //   }).onError((error, stackTrace) {
      //     deviceID = "";
      //   });
      // } catch (e) {
      //   deviceID = "";
      // }

      PackageInfo info = await PackageInfo.fromPlatform();
      appVersion = info.version;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        os = "w";
        deviceModelName = webInfo.platform ?? "";
        browserName = webInfo.browserName.name;
        osVersion = webInfo.appVersion.toString();
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        os = "i";
        osVersion = iosInfo.systemVersion;
        deviceModelName = iosInfo.model;
        macAddress = iosInfo.identifierForVendor ?? "";
      } else if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        os = "a";
        osVersion = androidInfo.version.release;
        deviceModelName = androidInfo.model;
        macAddress = androidInfo.id;
      }
    } catch (e) {
      devPrint(e);
    }
    Settings.updatenotnow = false;
    deviceData['appversion'] = appVersion;
    deviceData['devicemodelname'] = deviceModelName;
    deviceData['macaddress'] = macAddress;
    deviceData['deviceid'] = deviceID;
    deviceData['os'] = os;
    deviceData['osversion'] = osVersion;
    deviceData['devicename'] = deviceModelName;
    deviceData['browsername'] = browserName;
    return deviceData;
  }

  Future<void> sendDeviceData() async {
    Map<String, String> reqHeaders = IISMethods().defaultHeaders(
      userAction: "adddevicedata",
      pageName: "home",
    );
    Map<String, dynamic> data = await getDeviceData();
    final responseData = await ApiProvider().httpMethod(url: ApiConstant.appVersion, method: "POST", headers: reqHeaders, requestBody: data);
    if (!kIsWeb && responseData!['data']['isappupdateavailable'] == 1) {
      updateAppMsg = responseData['message'];
      isforcefully = responseData['data']['isforcefully'];
      isforcelogout = responseData['data']['isforcelogout'];
      inAppUpdateDialog();
    }
  }

  //</editor-fold>

  //<editor-fold desc = "In App Update">
  inAppUpdateDialog() async {
    if (Settings.updatenotnow != true) {
      if (Platform.isAndroid) {
        InAppUpdate.checkForUpdate().then((info) async {
          //
          _updateInfo = info;
          //
          if (Platform.isAndroid) {
            if (isforcefully == 1 && isforcelogout == 1) {
              if (Settings.isUserLogin) {
                AuthRepo().onLogOut();
              }
            }
            if (isforcefully == 0) {
              flexibleUpdate();
            } else {
              immediateUpdate();
            }
          }
        }).catchError((e) {
          //
        });
      } else {
        showAlertDialog(isforcefully, isforcelogout, updateAppMsg);
      }
    }
  }

  immediateUpdate() {
    _updateInfo!.updateAvailability == UpdateAvailability.updateAvailable
        ? InAppUpdate.performImmediateUpdate().then((result) {
            //
            if (result == AppUpdateResult.success) {
              //
            } else if (result == AppUpdateResult.userDeniedUpdate) {
              //
              inAppUpdateDialog();
            } else if (result == AppUpdateResult.inAppUpdateFailed) {
              //
            }
          }).catchError((e) {
            //
          })
        : null;
  }

  flexibleUpdate() {
    _updateInfo!.updateAvailability == UpdateAvailability.updateAvailable
        ? InAppUpdate.startFlexibleUpdate().then((result) {
            if (result == AppUpdateResult.success) {
            } else if (result == AppUpdateResult.userDeniedUpdate) {
              Settings.updatenotnow = true;
              // ImmediateUpdate();
            } else if (result == AppUpdateResult.inAppUpdateFailed) {}
            InAppUpdate.completeFlexibleUpdate().then((_) {}).catchError((e) {});
          }).catchError((e) {})
        : null;
  }

  //</editor-fold>

  //<editor-fold desc = "Show Dialog Box">

  void showAlertDialog(int forceUpdate, int forceLogout, String message) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: SimpleDialog(
            backgroundColor: Colors.transparent,
            children: [
              Container(
                width: Get.width,
                padding: const EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
                // height: Get.height ,
                decoration: const BoxDecoration(
                  color: ColorTheme.kWhite,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // ClipRRect(
                    //   child: Image.asset(
                    //     APP_LOGO_ICON,
                    //     height: 80,
                    //     width: 80,
                    //     color: HexColor("#F8BB86"),
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    const TextWidget(
                      text: "New Update Available",
                      textAlign: TextAlign.center,
                      fontSize: 16,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextWidget(
                      text: message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 25,
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (forceUpdate == 0)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Settings.updatenotnow = true;
                                Get.back();
                              },
                              child: const TextWidget(
                                text: "Later",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // height: Get.height,
                            // width: Get.width,

                            // bgColor: AppColor.RED,
                          ),
                        if (forceUpdate == 0)
                          const SizedBox(
                            width: 10,
                          ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (forceUpdate == 1 && forceLogout == 1) {
                                if (Settings.isUserLogin) {
                                  await AuthRepo().onLogOut();
                                }
                                onUpdate();
                              } else {
                                onUpdate();
                              }
                            },
                            child: const TextWidget(
                              text: "Update Now",
                              textAlign: TextAlign.center,
                            ),

                            // bgColor: AppColor.DARK_ORANGE,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  //</editor-fold>

//</editor-fold>
//<editor-fold desc = "In App Update">
  onUpdate() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    String appID = info.packageName;
    String url = "";
    if (Platform.isIOS) {
      url = "https://apps.apple.com/id/app/";
    } else if (Platform.isAndroid) {
      url = 'https://play.google.com/store/apps/details?id=$appID';
    }

    await urlLauncher(url);
  }

  urlLauncher(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

///////////////////////////////////////////////////////////////////

urlLauncher(String url) async {
  await launchUrl(Uri.parse(url));
}

Future<void> sendEmail({String email = "", String subject = "", String body = ""}) async {
  String mail = "mailto:$email?subject=$subject&body=${Uri.encodeFull(body)}";
  launchUrl(Uri.parse(mail));
}

documentDownload({required FilesDataModel imageList}) async {
  if (imageList.extension == 'pdf' && imageList.url != null) {
    RxBool isLoading = false.obs;
    showBottomBar.value = false;
    await CustomDialogs().customPopDialog(
      child: SizedBox(
        width: 800,
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
                    Expanded(
                      child: TextWidget(
                        text: imageList.name ?? '',
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.kPrimaryColor,
                        textOverflow: TextOverflow.ellipsis,
                        fontSize: 18,
                      ),
                    ),
                    InkResponse(
                      onTap: () async {
                        await launchUrl(Uri.parse(imageList.url.toString()));
                      },
                      radius: 16,
                      child: const Icon(
                        Icons.download_for_offline,
                        size: 32,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
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
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SfPdfViewer.network(
                imageList.url!,
                initialZoomLevel: 1,
                pageLayoutMode: PdfPageLayoutMode.continuous,
                canShowPageLoadingIndicator: true,
                interactionMode: PdfInteractionMode.pan,
                enableTextSelection: true,
                enableDoubleTapZooming: true,
                onDocumentLoaded: (details) {
                  isLoading.value = true;
                },
                controller: PdfViewerController(),
                canShowScrollStatus: true,
              ),
            ),
          ],
        ),
      ),
    );
    showBottomBar.value = true;
  } else if (imageList.url != null && FileTypes.image.contains(imageList.extension)) {
    Get.dialog(barrierDismissible: true, ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Dialog(
          surfaceTintColor: ColorTheme.kBackGroundGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              linkBuilder(
                uri: imageList.url ?? "",
                child: Container(
                  margin: sizingInformation.isMobile ? null : const EdgeInsets.all(2),
                  constraints: const BoxConstraints(minHeight: 400, minWidth: 400),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  clipBehavior: Clip.hardEdge,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageList.url ?? "",
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return SvgPicture.asset(
                          AssetsString.kUser,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    // InkWell(
                    //   onTap: () async {
                    //     await launchUrl(Uri.parse(imageList.url.toString()));
                    //   },
                    //
                    //   child: Container(
                    //     width: 32,
                    //     height: 32,
                    //     decoration: BoxDecoration(
                    //       color: ColorTheme.kBackGroundGrey,
                    //       borderRadius: BorderRadius.circular(6),
                    //     ),
                    //     child: const Icon(
                    //       Icons.download,
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   width: 4,
                    // ),
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ));
  } else {
    await launchUrl(Uri.parse(imageList.url.toString()));
  }
}
