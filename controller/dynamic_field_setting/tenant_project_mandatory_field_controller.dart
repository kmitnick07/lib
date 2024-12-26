import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../components/json/tenants_sra_json.dart';
import '../../config/config.dart';
import '../../config/iis_method.dart';

class TenantProjectMandatoryFieldController extends GetxController {
  RxList<Map<String, dynamic>> tableHeader = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> tenantFields = <Map<String, dynamic>>[].obs;
  RxMap dialogBoxData = {}.obs;
  RxString pageName = ''.obs;
  String objectId = '';
  RxMap<String, dynamic> fieldSetting = <String, dynamic>{}.obs;
  LinkedScrollControllerGroup verticalScrollController = LinkedScrollControllerGroup();

  // Map<String, ScrollController> scrollcontrollers = {};

  late ScrollController verticalHeaderController;
  late ScrollController verticalBodyController;
  LinkedScrollControllerGroup horizontalScrollController = LinkedScrollControllerGroup();
  RxBool formButtonLoading = false.obs;
  RxBool isLoading = false.obs;

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
    await getFieldList();
    await getTableHeader();
    await getFieldSetting();
    isLoading.value = false;
  }

  getTableHeader() async {
    tableHeader.add({'title': 'Mandatory', 'field': 'required'});
  }

  getFieldSetting() async {
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 500000000000,
        "filter": {
          'fortenant': 0,
        },
        "projection": {},
        "sort": {}
      }
    };
    var url = '${Config.weburl}${pageName.value}';
    var userAction = 'list${pageName.value}';

    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: 'tenant', masterlisting: true);
    fieldSetting.value = Map<String, dynamic>.from(resBody['data']['fields']);
    objectId = resBody['data']['_id'].toString();
  }

  getFieldList() {
    dialogBoxData.value = TenantsSRAJson.designationFormFields('tenantproject');
    (dialogBoxData['formfields'] as List).retainWhere(
      (element) {
        return element['field'] == 'tenantproject' || element['field'] == 'society' || element['field'] == 'srabody';
      },
    );
    for (var formFields in dialogBoxData['formfields']) {
      List<Map<String, dynamic>> tabFields = [];
      Map<String, dynamic> tab = {};
      for (var field in formFields['formFields']) {
        if (field['type'] != HtmlControls.kTableAddButton && field['type'] != HtmlControls.kTable&& field['type'] != HtmlControls.kMultipleTextFieldWithTitle) {
          devPrint('${tab['field']}--->$field');
          if (formFields['field'] == 'tenantproject' && (field['field'] == 'pincodeid' || field['field'] == 'cityid')) {
            continue;
          }

          tabFields.add(Map<String, dynamic>.from(field));
        }
      }
      tab['title'] = '${formFields['title'].toString().replaceAll('{{index}}', '')} Details';
      tab['field'] = formFields['field'];
      tab['fields'] = tabFields;
      tenantFields.add(tab);
    }
  }

  Future addData({
    reqData,
  }) async {
    try {
      Map<String, dynamic> reqBody = {
        '_id': objectId,
        'fields': fieldSetting.value,
      };
      RxInt statusCode = 0.obs;
      var url = '${Config.weburl}${pageName.value}/add';
      var userAction = "add$pageName";
      var resBody = await IISMethods().addData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);
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
