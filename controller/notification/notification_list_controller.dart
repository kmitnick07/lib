import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../config/api_provider.dart';
import '../../config/config.dart';
import '../../config/dev/dev_helper.dart';
import '../../models/notification/notification_list_model.dart';

class NotificationListController extends GetxController {
  RxList<NotificationListModel> notificationList = <NotificationListModel>[].obs;

  @override
  Future<void> onInit() async {
    pageCount.value = 1;
    loadmore.value = 0;
    getNotifications();
    super.onInit();
  }

  RefreshController refreshController = RefreshController(initialRefresh: false);
  RxInt pageCount = 1.obs;
  RxInt loadmore = 0.obs;
  RxBool loadingData = true.obs;
  void onRefresh() async {
    pageCount.value = 1;
    await getNotifications();
    refreshController.refreshCompleted();
  }

  void onLoading() async {
    try {
      if (loadmore.value == 1) {
        pageCount.value++;
        loadmore.value = 0;
        await getNotifications();
        refreshController.loadComplete();
      } else {
        refreshController.loadComplete();
      }
    } catch (e) {
      refreshController.loadFailed();
    }
  }

  Future<void> getNotifications() async {
    if (pageCount.value == 1) {
      loadingData.value = true;
    }

    try {
      Map<String, String> reqHeaders = IISMethods().defaultHeaders(
        userAction: "listnotification",
        pageName: "notification",
      );
      Map<String, dynamic> reqBody = {
        "paginationinfo": {"pageno": pageCount.value, "pagelimit": 20, "filter": {}, "sort": {}}
      };

      var response = await ApiProvider().httpMethod(
        url: Config.weburl + "notification",
        requestBody: reqBody,
        method: "POST",
        headers: reqHeaders,
        showSuccessToast: true,
      );

      if (response?['status'] == 200) {
        loadmore.value = response?['totaldocs'] > notificationList.length ? 1 : 0;

        List responseList = response['data'] ?? [];
        if (pageCount.value == 1) {
          notificationList.clear();
          notificationList.value = List<NotificationListModel>.from(responseList.map(
            (e) => NotificationListModel.fromJson(e),
          ));
        } else {
          notificationList.addAll(List<NotificationListModel>.from(responseList.map(
            (e) => NotificationListModel.fromJson(e),
          )));
        }
      } else {
        loadmore.value = response?['totaldocs'] > notificationList.length ? 1 : 0;
      }
    } catch (e) {
      devPrint(e);
    }
    loadingData.value = false;
  }
}

onTapNotification({String? pagename}) {
  if (pagename.isNotNullOrEmpty) {
    navigateTo(pagename);
  }
}
