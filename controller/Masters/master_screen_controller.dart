import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/Menu/menu_model.dart';

import '../../routes/route_generator.dart';
import '../../routes/route_name.dart';
import '../../view/CommonWidgets/common_header_footer.dart';

class MasterListScreenController extends GetxController {
  RxString pageName = ''.obs;
  RxBool isLoading = false.obs;
  RxString searchText = ''.obs;
  TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    pageName.value = getCurrentPageName();
    super.onInit();
    setPageTitle('Masters | PRENEW', Get.context!);
    getMasterList();
  }

  @override
  void dispose() {
    Get.delete<MasterListScreenController>();
    super.dispose();
  }

  RxList<MenuData> masterList = <MenuData>[].obs;

  getMasterList() async {
    isLoading.value = true;
    var res = await IISMethods()
        .listData(userAction: "list${pageName.value}", pageName: pageName.value, url: "${Config.weburl}mastermenu", reqBody: <String, dynamic>{'searchtext': searchText.value});
    if (res['status'] == 200) {
      masterList.value = (List<Map<String, dynamic>>.from(res["data"]))
          .map(
            (e) => MenuData.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    isLoading.value = false;
  }
}
