import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prestige_prenew_frontend/components/forms/profile_form.dart';
import 'package:prestige_prenew_frontend/components/repo/auth/auth_repo.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/profile/profile_controller.dart';
import 'package:prestige_prenew_frontend/models/Menu/menu_model.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';

import '../components/customs/custom_dialogs.dart';
import '../config/config.dart';
import '../config/dev/dev_helper.dart';

RxBool isHoverDisable = false.obs;
RxBool isSessionTimeOut = false.obs;
RxBool isDialogOpen = false.obs;
RxInt expandedIndex = (-1).obs;
RxList<MenuData> menuList = <MenuData>[].obs;

RxInt globalTableWidth = 125.obs;
RxBool showBottomBar = true.obs;
BuildContext? globalContext;

RxList<MenuData> bottomBarList = <MenuData>[].obs;
Rx<MenuData> selectedBottombar = MenuData().obs;

setSelectedBottombar(MenuData menu) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    if (Settings.isUserLogin) {
      selectedBottombar.value = menu;
      selectedBottombar.refresh();
      showBottomBar.value = true;
      Get.find<LayoutTemplateController>().currentAlias.value = menu.alias!;
    } else {
      selectedBottombar.value = MenuData();
      selectedBottombar.refresh();
      bottomBarList.clear();
      showBottomBar.value = false;
    }
    bottomBarList.refresh();
  });
}

class MenuConstant {
  static const String dashboarMenu = "dashboard";
  static const String tenantsMenu = "tenant";
  static const String approvalMenu = "approval";
  static const String profileMenu = "profile";
}

class LayoutTemplateController extends GetxController {
  RxString currentAlias = 'dashboard'.obs;
  RxBool showDrawer = false.obs;
  RxBool sideBarFocus = false.obs;
  RxString appVersion = ''.obs;

  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  FocusNode textSelectionFocus = FocusNode();

  @override
  Future<void> onInit() async {
    super.onInit();

    if (Settings.isUserLogin) {
      await AuthRepo().getLoginData();
      await getMenuList();
      getBottomBarRights();
      showDrawer.value = true;
      appVersion.value = (await PackageInfo.fromPlatform()).version;
      /*if (!kDebugMode)*/
      // AwsManager().init();
    }
  }

  @override
  void dispose() {
    Get.delete<LayoutTemplateController>();
    super.dispose();
  }

  onChangeHover() {
    isHoverDisable.value = !isHoverDisable.value;
  }

  getMenuList() {
    menuList.value = Settings.loginData.menudata!;
    update();
    menuList.refresh();
  }

  bool checkMenu(String? alias) => (alias?.toLowerCase() == MenuConstant.dashboarMenu || alias?.toLowerCase() == MenuConstant.approvalMenu || alias?.toLowerCase() == MenuConstant.profileMenu || alias?.toLowerCase() == MenuConstant.tenantsMenu);

  int menuIndex(String? alias) => alias?.toLowerCase() == MenuConstant.dashboarMenu
      ? 0
      : alias?.toLowerCase() == MenuConstant.approvalMenu
          ? 2
          : alias?.toLowerCase() == MenuConstant.profileMenu
              ? 3
              : 1;

  void getBottomBarRights() {
    List<MenuData> matchedRights = [];
    bottomBarList.clear();
    for (var i = 0; i < menuList.length; i++) {
      if (checkMenu(menuList[i].alias)) {
        matchedRights.add(menuList[i]);
      }
      for (var j = 0; j < (menuList[i].children?.length ?? 0); j++) {
        MenuData? childernData = menuList[i].children?[j];
        if (checkMenu(childernData?.alias)) {
          matchedRights.add(childernData!);
        }
      }
    }

    bottomBarList.addAll(matchedRights);

    List<MenuData> searchField = matchedRights.where((element) => element.alias == MenuConstant.dashboarMenu).toList();
    if (searchField.isNotEmpty) {
      setSelectedBottombar(searchField.first);
    }
    update();
  }

  showProfileForm() async {
    FormDataModel setDefaultData = FormDataModel();
    setDefaultData.fieldOrder.value = Get.find<ProfileController>().profileFieldOrder;
    var res = await IISMethods().listData(
      userAction: "listprofile",
      pageName: "profile",
      url: "${Config.weburl}user/profile",
      reqBody: {
        "paginationinfo": {
          "pageno": 1,
          "pagelimit": 5000000000000,
          "filter": {},
          "projection": {},
          "sort": {},
        },
      },
    );
    if (res['status'] == 200) {
      setDefaultData.formData = Map<String, dynamic>.from(res['data']).obs;
      setDefaultData.oldFormData = Map<String, dynamic>.from(res['data']).obs;
      jsonPrint(res);
    }
    scaffoldkey.currentState?.closeDrawer();
    await CustomDialogs().customFilterDialogs(context: Get.context!, widget: ProfileForm(title: "Profile", btnName: "Save", setDefaultData: setDefaultData));
    isDialogOpen.value = false;
  }
}
