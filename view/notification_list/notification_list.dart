// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../controller/notification/notification_list_controller.dart';
import '../../models/notification/notification_list_model.dart';
import '../no_data_found_screen.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: TextWidget(
                  text: "Notifications",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                splashColor: ColorTheme.kRed,
                hoverColor: ColorTheme.kRed.withOpacity(0.4),
                splashRadius: 18,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ).paddingAll(16),
        const Divider(),
        Expanded(
          child: GetBuilder(
              init: Get.put(NotificationListController()),
              builder: (controller) {
                return Scaffold(
                  body: Obx(() {
                    return SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      controller: controller.refreshController,
                      onRefresh: controller.onRefresh,
                      onLoading: controller.onLoading,
                      child: controller.loadingData.value
                          ? const NoDataFoundScreen()
                          : controller.notificationList.isEmpty
                              ? const NoDataFoundScreen()
                              : ListView.separated(
                                  itemCount: controller.notificationList.length,
                                  physics: const ClampingScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index) {
                                    NotificationListModel obj = controller.notificationList[index];
                                    return InkWell(
                                      onTap: () {
                                        onTapNotification(pagename: obj.pagename);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(color: obj.noticolor.toColor().withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                        width: double.infinity,
                                        child: ListTile(
                                          leading: Container(
                                            decoration: BoxDecoration(color: obj.noticolor.toColor(), shape: BoxShape.circle),
                                            alignment: Alignment.center,
                                            height: 50,
                                            width: 50,
                                            child: SvgPicture.network(
                                              obj.iconimg ?? "",
                                              height: 25,
                                              color: ColorTheme.kWhite,
                                            ),
                                          ),
                                          title: TextWidget(
                                            text: obj.title ?? "",
                                          ),
                                          subtitle: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(obj.body ?? ""),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: TextWidget(
                                                  text: obj.time.toDateTimeFormat(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ).paddingAll(7),
                                      ).paddingOnly(top: index == 0 ? 10 : 0, left: 10, right: 10),
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) {
                                    return const SizedBox(
                                      height: 8,
                                    );
                                  },
                                ),
                    );
                  }),
                );
              }),
        ),
      ],
    );
  }
}
