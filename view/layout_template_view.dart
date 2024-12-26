import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/components/hover_builder.dart';
import 'package:prestige_prenew_frontend/components/prenew_logo.dart';
import 'package:prestige_prenew_frontend/components/repo/auth/auth_repo.dart';
import 'package:prestige_prenew_frontend/config/helper/offline_data.dart';
import 'package:prestige_prenew_frontend/config/settings.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/style/string_const.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';
import "package:universal_html/html.dart";

import '../components/customs/custom_dialogs.dart';
import '../components/funtions.dart';
import '../controller/dashboard/dashboard_controller.dart';
import '../models/Menu/menu_model.dart';
import '../style/assets_string.dart';
import 'notification_list/notification_list.dart';

// devPrint("=========================> ${html.window.localStorage.isNotEmpty}");
//
// if(html.window.localStorage.isEmpty){
// Get.offAllNamed(RouteNames.kLoginScreen);
// }

class LayoutTemplateView extends StatefulWidget {
  const LayoutTemplateView({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<LayoutTemplateView> createState() => _LayoutTemplateViewState();
}

class _LayoutTemplateViewState extends State<LayoutTemplateView> {
  @override
  void initState() {
    super.initState();
    document.addEventListener("visibilitychange", onVisibilityChange);
  }

  @override
  void dispose() {
    document.removeEventListener("visibilitychange", onVisibilityChange);
    super.dispose();
  }

// For Reload after login or logout
  Future<void> onVisibilityChange(Event e) async {
    if (document.visibilityState == "visible") {
      if (Settings.isUserLogin && "/${getCurrentPageName()}" == RouteNames.kLoginScreen) {
        await AuthRepo().getLoginData();
        await Get.find<LayoutTemplateController>().getMenuList();
        Get.find<LayoutTemplateController>().getBottomBarRights();
        Get.find<LayoutTemplateController>().showDrawer.value = true;
        // await Future.delayed(const Duration(seconds: 1));
        navigateTo(RouteNames.kDashboard);
        bool test = Get.isRegistered<DashBoardController>();
        if (!test) {
          Get.put(DashBoardController());
          await Future.delayed(const Duration(seconds: 1));
          await Get.find<DashBoardController>().onInitl();
        } else {
          Get.find<DashBoardController>().onInitl();
        }
      }
      if (!Settings.isUserLogin && "/${getCurrentPageName()}" != RouteNames.kLoginScreen) {
        await Get.delete<DashBoardController>(force: true);
        Get.rootDelegate.history.clear();
        await Future.delayed(const Duration(seconds: 1));
        Get.find<LayoutTemplateController>().scaffoldkey.currentState?.closeDrawer();
        Get.find<LayoutTemplateController>().showDrawer.value = false;
        Get.find<LayoutTemplateController>().showDrawer.refresh();
        showBottomBar.value = false;
        navigateTo(RouteNames.kLoginScreen);
      }
      // if ((window.localStorage['flutter.token'] != null && "/${getCurrentPageName()}" == RouteNames.kLoginScreen)) {
      //   window.location.reload();
      // }
      // if ((window.localStorage['flutter.token'] == null && "/${getCurrentPageName()}" != RouteNames.kLoginScreen)) {
      //   Settings.clear();
      //   window.location.reload();
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LayoutTemplateController>(
        init: LayoutTemplateController(),
        builder: (controller) {
          return Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) {
                  return ResponsiveBuilder(builder: (context, sizingInformation) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                      if (!Settings.isUserLogin) {
                        if (getCurrentPageName() != "login" && getCurrentPageName() != "splash" && getCurrentPageName() != "deleteaccount") {
                          navigateTo(RouteNames.kLoginScreen);
                        } else if (!kIsWeb && (selectedBottombar.value.alias ?? "").toLowerCase() != getCurrentPageName().toLowerCase()) {
                          List<MenuData> searchField = menuList.where((element) => element.alias?.toLowerCase() == getCurrentPageName().toLowerCase()).toList();
                          if (searchField.isNotEmpty) {
                            setSelectedBottombar(searchField.first);
                          }
                        }
                      }
                    });
                    return SafeArea(
                      child: Scaffold(
                        key: controller.scaffoldkey,
                        drawer: Obx(() {
                          return SizedBox(
                            child: menuList.isNotEmpty && (sizingInformation.isMobile || sizingInformation.isTablet)
                                ? Drawer(
                                    child: SafeArea(
                                      child: Container(
                                        color: ColorTheme.kBlack,
                                        child: sideBar(true, true.obs, true, Get.find<LayoutTemplateController>()),
                                      ),
                                    ),
                                  )
                                : null,
                          );
                        }),
                        body: Stack(
                          children: [
                            Row(
                              children: [
                                Visibility(
                                  visible: (!(sizingInformation.isMobile || sizingInformation.isTablet)),
                                  child: Obx(() {
                                    return Visibility(
                                      visible: controller.showDrawer.value,
                                      child: Obx(() {
                                        return AnimatedContainer(
                                          duration: Duration.zero,
                                          color: ColorTheme.kBlack,
                                          width: (isHoverDisable.value) ? 250 : 75,
                                        );
                                      }),
                                    );
                                  }),
                                ),
                                Flexible(
                                  child: SelectionArea(
                                    child: widget.child,
                                  ),
                                )
                              ],
                            ),
                            Obx(() {
                              return Visibility(
                                visible: controller.showDrawer.value && !(sizingInformation.isMobile || sizingInformation.isTablet),
                                child: HoverBuilder(builder: (isHovered) {
                                  if (!(isHovered || isHoverDisable.value)) expandedIndex.value = -1;
                                  isHovered == false ? controller.sideBarFocus.value = false : controller.sideBarFocus.value;
                                  return TapRegion(
                                    onTapOutside: (event) {
                                      controller.sideBarFocus.value = false;
                                    },
                                    onTapInside: (event) {
                                      controller.sideBarFocus.value = true;
                                    },
                                    child: Obx(() {
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        color: ColorTheme.kBlack,
                                        width: (controller.sideBarFocus.value || isHovered || isHoverDisable.value) ? 250 : 75,
                                        child: SizedBox(
                                          width: (controller.sideBarFocus.value || isHovered || isHoverDisable.value) ? 250 : 75,
                                          child: sideBar(controller.sideBarFocus.value || isHovered, isHoverDisable, sizingInformation.isMobile || sizingInformation.isTablet, controller),
                                        ),
                                      );
                                    }),
                                  );
                                }),
                              );
                            }),
                          ],
                        ),
                        bottomNavigationBar: Obx(() {
                          return isoffline.value || kIsWeb || !Settings.isUserLogin || !showBottomBar.value ? const SizedBox.shrink() : bottomBarView(context);
                          return isoffline.value || kIsWeb || !Settings.isUserLogin || !showBottomBar.value ? const SizedBox.shrink() : bottomBarView(context);
                        }),
                      ),
                    );
                  });
                },
              )
            ],
          );
        });
  }
}

Widget bottomBarView(BuildContext context) {
  return Obx(() {
    return Visibility(
      visible: !isDialogOpen.value && (bottomBarList.isNotEmpty && Get.find<LayoutTemplateController>().checkMenu(selectedBottombar.value.alias) && showBottomBar.value),
      child: Obx(() {
        return Container(
          decoration: const BoxDecoration(
            color: ColorTheme.kWhite,
            boxShadow: [
              BoxShadow(
                spreadRadius: 1.0,
                color: Colors.black12,
                blurRadius: 5.0,
              ),
            ],
            // borderRadius: BorderRadius.only(
            //   topLeft: Radius.circular(20),
            //   topRight: Radius.circular(20),
            // ),
          ),
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...List.generate(
                bottomBarList.length,
                (index) => Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.find<LayoutTemplateController>().currentAlias.value = bottomBarList[index].alias!;
                      setSelectedBottombar(bottomBarList[index]);
                      navigateTo('/${Get.find<LayoutTemplateController>().currentAlias.value}');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.network(
                          bottomBarList[index].iconimage?.url ?? "",
                          colorFilter: ColorFilter.mode(getCurrentPageName() == bottomBarList[index].alias ? ColorTheme.kWarnColor : Theme.of(context).primaryColor, BlendMode.srcIn),
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(height: 2),
                        TextWidget(
                          text: "${bottomBarList[index].menuname}",
                          color: getCurrentPageName() == bottomBarList[index].alias ? ColorTheme.kWarnColor : Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        Visibility(
                          visible: getCurrentPageName() == bottomBarList[index].alias,
                          child: Center(
                            child: Container(
                              height: 4,
                              constraints: const BoxConstraints(maxWidth: 40),
                              decoration: BoxDecoration(
                                color: ColorTheme.kWarnColor,
                                borderRadius: BorderRadius.circular(1000),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  });
}

Widget sideBar(isHovered, isHoverDisable, isMobile, LayoutTemplateController controller) {
  String userName = Settings.userName;
  String firstLetters = "";
  String picture = Settings.profile.url ?? "";
  List<String> words = userName.split(" ");
  if (words.length > 1) {
    firstLetters = "${words[0][0].toUpperCase()}${words[1][0].toUpperCase()}";
  } else if (words.isNotEmpty) {}
  return ResponsiveBuilder(builder: (context, sizingInformation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !sizingInformation.isMobile,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                PrenewLogo(
                  color: ColorTheme.kWhite,
                  size: 50,
                  showName: (isHovered || isHoverDisable.value),
                ),
                if (!isMobile)
                  (isHovered || isHoverDisable.value)
                      ? InkWell(
                              onTap: () async {
                                isHoverDisable.value = !isHoverDisable.value;
                                globalTableWidth.value = globalTableWidth.value == 125 ? 299 : 125;
                                globalTableWidth.refresh();
                              },
                              child: isHoverDisable.value ? SvgPicture.asset(AssetsString.kCircleDotSvg) : SvgPicture.asset(AssetsString.kCircleSvg))
                          .paddingOnly(left: 40)
                      : const SizedBox.shrink(),
              ],
            ).paddingOnly(left: 12, top: 12),
          ),
        ),
        Visibility(
          visible: sizingInformation.isMobile,
          child: InkWell(
            onTap: !sizingInformation.isMobile
                ? null
                : () {
                    isDialogOpen.value = true;
                    controller.showProfileForm();
                  },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  profilePictureTile(picture, firstLetters, radius: 25, fontSize: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: Settings.userName,
                          color: ColorTheme.kWhite,
                          fontSize: 18,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                        TextWidget(
                          text: Settings.email,
                          fontWeight: FontTheme.notoRegular,
                          color: ColorTheme.kWhite.withOpacity(0.7),
                          fontSize: 12,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!sizingInformation.isMobile) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        controller.scaffoldkey.currentState?.closeDrawer();
                        CustomDialogs().customDialog(
                            buttonCount: 2,
                            content: 'Are you sure? want to "Log out" !',
                            onTapPositive: () {
                              AuthRepo().onLogOut();
                            });
                      },
                      child: SvgPicture.asset(
                        AssetsString.kSignOutAlt,
                        height: 25,
                        colorFilter: const ColorFilter.mode(ColorTheme.kWarnColor, BlendMode.srcIn),
                      ).paddingOnly(right: 8),
                    )
                  ],
                ],
              ),
            ),
          ),
        ),
        Visibility(visible: sizingInformation.isMobile, child: const Divider(color: Colors.white24)),
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: menuList.length,
                itemBuilder: (ctx, index) {
                  MenuData obj = menuList[index];
                  return openBrowserContextMenu(
                    alias: obj.children.isNotNullOrEmpty ? null : obj.alias,
                    child: mainMenu(obj, (isHovered || isHoverDisable.value), index, controller),
                  );
                }),
          ),
        ),
        //Notifications
        if (!sizingInformation.isMobile) ...[
          Obx(() {
            return InkWell(
              onTap: isDialogOpen.value
                  ? null
                  : () async {
                      isDialogOpen.value = true;
                      Get.dialog(
                        Dialog(
                            backgroundColor: ColorTheme.kWhite,
                            alignment: Alignment.centerRight,
                            shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            insetPadding: EdgeInsets.zero,
                            child: const SizedBox(width: 600, child: NotificationList())),
                      ).then((value) {
                        isDialogOpen.value = false;
                      });
                    },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: ((isHovered || isHoverDisable.value))
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetsString.kBellCountSvg,
                            colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                            height: 25,
                            width: 25,
                          ).paddingOnly(right: 8),
                          const TextWidget(
                            text: "Notifications",
                            fontSize: 13,
                            color: ColorTheme.kWhite,
                          ).paddingOnly(right: 65),
                          Container(
                            decoration: BoxDecoration(color: ColorTheme.kRed, borderRadius: BorderRadius.circular(14)),
                            child: const TextWidget(text: "0", fontSize: 12, color: ColorTheme.kWhite).paddingSymmetric(vertical: 1.5, horizontal: 6),
                          ),
                        ],
                      )
                    : SvgPicture.asset(
                        AssetsString.kBellCountSvg,
                        colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                        height: 25,
                        width: 25,
                      ),
              ).paddingOnly(left: 26, bottom: 24),
            );
          }),
        ],
        //LogOut for web
        if (!sizingInformation.isMobile)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: ((isHovered || isHoverDisable.value))
                    ? SizedBox(
                        width: 208,
                        child: Row(
                          children: [
                            Obx(() {
                              return InkResponse(
                                onTap: isDialogOpen.value
                                    ? null
                                    : () {
                                        isDialogOpen.value = true;
                                        controller.scaffoldkey.currentState?.closeDrawer();
                                        controller.showProfileForm();
                                      },
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                  profilePictureTile(picture, firstLetters).paddingOnly(right: 8),
                                  TextWidget(
                                    text: Settings.userName,
                                    color: ColorTheme.kWhite,
                                  ),
                                ]),
                              );
                            }),
                            const Spacer(),
                            InkResponse(
                              hoverColor: ColorTheme.kWhite,
                              onTap: () {
                                controller.scaffoldkey.currentState?.closeDrawer();
                                CustomDialogs().customDialog(
                                    buttonCount: 2,
                                    content: 'Are you sure? want to "Log out" !',
                                    onTapPositive: () {
                                      AuthRepo().onLogOut();
                                    });
                              },
                              child: const Icon(
                                Icons.logout_rounded,
                                size: 20,
                                color: ColorTheme.kWhite,
                              ).paddingOnly(right: 4),
                            ),
                          ],
                        ),
                      )
                    : profilePictureTile(picture, firstLetters),
              ).paddingOnly(left: 8, bottom: 12),
            ),
          ),
        // if (isHovered || isHoverDisable.value)
          SizedBox(
            width: 400,
            height: 18,
            child: Center(
              child: TextWidget(
                text: 'v${controller.appVersion}',
                color: ColorTheme.kWhite,
              ),
            ),
          )
        // else
        //   const SizedBox(
        //     height: 18,
        //
        //   )
      ],
    );
  });
}

Widget profilePictureTile(String picture, String firstLetters, {double? radius, double? fontSize}) {
  return Visibility(
    visible: picture.isNotNullOrEmpty,
    replacement: CircleAvatar(
      backgroundColor: ColorTheme.kWhite,
      radius: radius ?? 14,
      child: TextWidget(
        text: firstLetters,
        fontSize: fontSize ?? 12,
      ),
    ),
    child: Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ColorTheme.kWarnColor),
      ),
      child: CircleAvatar(
        backgroundImage: NetworkImage(picture),
        radius: radius ?? 14,
      ),
    ),
  );
}

class mainMenu extends StatefulWidget {
  MenuData obj;
  bool isHovered;
  int index;
  LayoutTemplateController controller;

  mainMenu(this.obj, this.isHovered, this.index, this.controller, {super.key});

  @override
  State<mainMenu> createState() => _mainMenuState();
}

class _mainMenuState extends State<mainMenu> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      if (!sizingInformation.isDesktop) {
        return Obx(
          () => Container(
              decoration: widget.obj.children.isNullOrEmpty && widget.controller.currentAlias.value == widget.obj.alias
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: widget.controller.currentAlias.value == widget.obj.alias ? ColorTheme.kWarnColor.withOpacity(0.3) : Colors.transparent,
                    )
                  : (expandedIndex.value == widget.index)
                      ? BoxDecoration(borderRadius: BorderRadius.circular(6), color: ColorTheme.kWhite.withOpacity(0.2))
                      : null,
              child: Column(
                children: [
                  InkWell(
                    onTap: () async {
                      if (widget.obj.alias == StringConst.kLogout) {
                        Get.find<LayoutTemplateController>().scaffoldkey.currentState?.closeDrawer();
                        await CustomDialogs().customDialog(
                            buttonCount: 2,
                            content: 'Are you sure? want to "Log out" !',
                            onTapPositive: () {
                              AuthRepo().onLogOut();
                            });
                        return;
                      }
                      if (widget.obj.children.isNotNullOrEmpty) {
                        if (expandedIndex.value == widget.index) {
                          expandedIndex.value = -1;
                        } else {
                          expandedIndex.value = widget.index;
                        }
                      } else {
                        isDialogOpen.value = false;
                        Get.find<LayoutTemplateController>().scaffoldkey.currentState?.closeDrawer();
                        navigateTo('/${widget.obj.alias!}');
                        widget.controller.currentAlias.value = widget.obj.alias!;
                        setSelectedBottombar(widget.obj);
                        widget.controller.currentAlias.refresh();
                        expandedIndex.value = widget.index;
                      }
                      setState(() {});
                    },
                    child: ListTile(
                      leading: SvgPicture.network(widget.obj.iconimage?.url ?? "", colorFilter: const ColorFilter.mode(ColorTheme.kWarnColor, BlendMode.srcIn), height: 25, width: 25),
                      title: TextWidget(text: widget.obj.menuname ?? "", fontSize: 14, color: ColorTheme.kWhite.withOpacity(0.6)),
                      horizontalTitleGap: 0,
                      trailing: Visibility(
                        visible: widget.isHovered && widget.obj.children.isNotNullOrEmpty,
                        child: Icon(
                          (expandedIndex.value == widget.index) ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_right_rounded,
                          color: ColorTheme.kWhite,
                        ),
                      ),
                    ),
                  ),
                  if ((expandedIndex.value == widget.index) && widget.isHovered && widget.obj.children.isNotNullOrEmpty)
                    ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.obj.children!.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          MenuData innerObj = widget.obj.children![index];
                          return openBrowserContextMenu(
                            alias: innerObj.alias,
                            child: innerMenu(innerObj, widget.controller).paddingSymmetric(horizontal: 20),
                          );
                        }).paddingOnly(bottom: 8),
                ],
              )).paddingSymmetric(horizontal: 8),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: widget.obj.children.isNullOrEmpty && widget.controller.currentAlias.value == widget.obj.alias
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: widget.controller.currentAlias.value == widget.obj.alias ? ColorTheme.kWarnColor.withOpacity(0.5) : Colors.transparent,
                )
              : (expandedIndex.value == widget.index)
                  ? BoxDecoration(borderRadius: BorderRadius.circular(6), color: ColorTheme.kWhite.withOpacity(0.2))
                  : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: ((widget.isHovered || isHoverDisable.value))
                    ? InkWell(
                        onTap: () {
                          if (widget.obj.children.isNotNullOrEmpty) {
                            if (expandedIndex.value == widget.index) {
                              expandedIndex.value = -1;
                            } else {
                              expandedIndex.value = widget.index;
                            }
                          } else {
                            navigateTo('/${widget.obj.alias!}');
                            widget.controller.currentAlias.value = widget.obj.alias!;
                            setSelectedBottombar(widget.obj);
                            widget.controller.currentAlias.refresh();
                          }
                          setState(() {});
                        },
                        child: SizedBox(
                          width: 200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.network(
                                widget.obj.iconimage?.url ?? "",
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                height: 20,
                                width: 20,
                              ).paddingOnly(right: 8),
                              TextWidget(
                                text: widget.obj.menuname ?? "",
                                fontSize: 14,
                                color: ColorTheme.kWhite,
                              ),
                              const Spacer(),
                              if (widget.isHovered && widget.obj.children.isNotNullOrEmpty)
                                Icon(
                                  (expandedIndex.value == widget.index) ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_right_rounded,
                                  size: 20,
                                  color: ColorTheme.kWhite,
                                )
                            ],
                          ),
                        ),
                      )
                    : SvgPicture.network(
                        widget.obj.iconimage?.url ?? "",
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                        height: 20,
                        width: 20,
                      ),
              ),
              if ((expandedIndex.value == widget.index) && widget.isHovered && widget.obj.children.isNotNullOrEmpty)
                ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: widget.obj.children!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, index) {
                      MenuData innerObj = widget.obj.children![index];
                      return openBrowserContextMenu(
                        alias: innerObj.alias,
                        child: innerMenu(innerObj, widget.controller),
                      );
                    }).paddingOnly(top: 6),
            ],
          ),
        ),
      );
    });
  }
}

Widget innerMenu(MenuData obj, LayoutTemplateController controller) {
  return Obx(() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: controller.currentAlias.value == obj.alias ? ColorTheme.kWarnColor.withOpacity(0.5) : Colors.transparent,
      ),
      child: InkWell(
        onTap: () {
          isDialogOpen.value = false;

          Get.find<LayoutTemplateController>().scaffoldkey.currentState?.closeDrawer();
          controller.currentAlias.value = obj.alias!;
          setSelectedBottombar(obj);
          navigateTo('/${obj.alias!}');
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: 168,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(AssetsString.kCircleSmallSvg).paddingOnly(right: 14),
                Flexible(
                  child: TextWidget(
                    text: obj.menuname ?? "",
                    textOverflow: TextOverflow.visible,
                    fontSize: 14,
                    height: 1.5,
                    color: ColorTheme.kWhite,
                  ),
                ),
              ],
            ),
          ),
        ).paddingOnly(left: 32, bottom: 8, top: 8),
      ),
    );
  });
}
