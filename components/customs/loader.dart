import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

BuildContext? _appLoaderContext;

AppLoader() {
  showGeneralDialog(
    context: Get.context!,
    useRootNavigator: false,
    barrierDismissible: false,
    pageBuilder: (_, __, ___) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          statusBarColor: ColorTheme.kWhite,
        ),
        child: Align(
          alignment: Alignment.center,
          child: SizedBox.expand(child: Image.asset(AssetsString.kLoaderGIF)),
        ),
      );
    },
  );
}

void RemoveAppLoader() {
  Get.back();
}
