import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/json/tenants_sra_json.dart';
import '../../config/config.dart';
import '../../config/iis_method.dart';

class MandatoryFieldMapping extends GetxController {
  RxList<Map<String, dynamic>> tenantStatusList = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> tenantFields = <Map<String, dynamic>>[].obs;
  RxMap dialogBoxData = {}.obs;
  RxString pageName = ''.obs;
  RxMap<String, dynamic> fieldSetting = <String, dynamic>{}.obs;
  LinkedScrollControllerGroup verticalScrollController = LinkedScrollControllerGroup();

  // Map<String, ScrollController> scrollcontrollers = {};

  late ScrollController verticalHeaderController;
  late ScrollController verticalBodyController;
  LinkedScrollControllerGroup horizontalScrollController = LinkedScrollControllerGroup();
  RxBool formButtonLoading = false.obs;
  RxBool isLoading = false.obs;
  String objectId = '';
  RxInt selectedTab = 0.obs;

  // Map<String, ScrollController> scrollcontrollers = {};

  late ScrollController horizontalHeaderController;
  late ScrollController horizontalBodyController;

  @override
  onInit() async {
    super.onInit();
    verticalHeaderController = verticalScrollController.addAndGet();
    verticalBodyController = verticalScrollController.addAndGet();
    horizontalHeaderController = horizontalScrollController.addAndGet();
    horizontalBodyController = horizontalScrollController.addAndGet();
    pageName.value = 'mandatoryfieldmapping';
    isLoading.value = true;
    await getTenantStatus();
    await getFieldSetting();
    await getFieldList();
    isLoading.value = false;
  }

  getTenantStatus() async {
    var reqBody = {
      "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": {}, "projection": {}, "sort": {}}
    };
    var url = '${Config.weburl}tenantstatus';
    var userAction = 'listtenantstatusdata';

    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: 'tenant', masterlisting: true);
    tenantStatusList.value = List<Map<String, dynamic>>.from(resBody['data']);
  }

  getFieldSetting() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 500000000000,
        "filter": {
          'fortenant': 1,
        },
        "projection": {},
        "sort": {}
      }
    };
    var url = '${Config.weburl}${pageName.value}';
    var userAction = 'list${pageName.value}';

    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: 'tenant', masterlisting: true);
    fieldSetting.value = Map<String, dynamic>.from(resBody['data']['fields']);
    objectId = resBody['data']['_id'];
  }

  getFieldList() {
    dialogBoxData.value = TenantsSRAJson.designationFormFields('tenant');
    for (var tabs in dialogBoxData['tabs']) {
      Map<String, dynamic> tab = {};
      List<Map<String, dynamic>> tabFields = [];
      for (var formFields in tabs['formfields']) {
        for (var field in formFields['formFields']) {
          switch (field['field']) {
            case 'tenantprojectid':
            case 'tenantstatusid':
            case 'tenant_status_date':
            case 'private_survey_date':
            case 'government_survey_date':
            case 'draft_annexure_date':
            case 'final_annexure_date':
            case 'supplementary_annexure_date':
            case 'inspection_date':
            case 'rent_payment_date':
            case 'key_handover_date':
            case 'evacuation_date':
            case 'demolition_date':
            case 'unit_handover_date':
              continue;
          }
          if (field['type'] != HtmlControls.kText) {
            tabFields.add(Map<String, dynamic>.from(field));
          }
        }
      }
      tab['title'] = '${tabs['title'].toString().replaceAll('{{index}}', '')} Details';
      tab['fields'] = tabFields;
      tenantFields.add(tab);
    }
  }

  Future addData({
    reqData,
  }) async {
    try {
      RxInt statusCode = 0.obs;
      Map<String, dynamic> reqData = {
        '_id': objectId,
        'fields': fieldSetting.value,
      };
      var url = '${Config.weburl}${pageName.value}/add';
      var userAction = "add$pageName";
      var resBody = await IISMethods().addData(url: url, reqBody: reqData, userAction: userAction, pageName: pageName.value);
      statusCode.value = resBody["status"] ?? 0;
      String message = resBody["message"] ?? '';
      if (statusCode.value == 200) {
        getFieldSetting();
        showSuccess(message);
      } else {
        showError(message);
      }
    } catch (e) {}
  }
}
