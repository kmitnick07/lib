import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';

import '../../components/customs/custom_dialogs.dart';
import '../../config/config.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../models/form_data_model.dart';
import '../../routes/route_name.dart';
import '../../style/string_const.dart';

class ProfileController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isEdit = false.obs;
  RxString userName = ''.obs;
  RxString pageName = ''.obs;
  RxInt statusCode = 0.obs;
  RxString message = ''.obs;
  FormDataModel setDefaultData = FormDataModel();
  TextEditingController txtNameController = TextEditingController();

  List<Map<String, dynamic>> profileFieldOrder = List<Map<String, dynamic>>.from([
    {
      'field': 'photo',
      'text': 'Photo',
      'type': HtmlControls.kAvatarPicker,
      'filetypes': ['png', 'jpg', 'jpeg'],
      'uploadtext': "Upload",
      'uploadedtext': "Upload New",
      'resettext': StringConst.kResetBtnTxt,
      'disabled': false,
      'defaultvisibility': true,
      'required': false,
      'gridsize': FieldSize.k400,
      'note': "Allowed JPG or PNG. Max size of 800K",
    },
    {'field': 'name', 'text': 'Name', 'type': HtmlControls.kInputText, 'disabled': false, 'defaultvisibility': true, 'required': false, 'gridsize': FieldSize.k400, 'primaryField': true},
    {'field': 'employeeid', 'text': 'UID', 'type': HtmlControls.kNumberInput, 'maxlength': 6, 'minlength': 6, 'disabled': true, 'defaultvisibility': true, 'required': false, 'gridsize': FieldSize.k400, 'primaryField': true},
    {
      'field': 'userrole',
      'text': 'Role',
      'type': HtmlControls.kInputTextArea,
      'disabled': true,
      'defaultvisibility': true,
      'required': false,
      'gridsize': FieldSize.k400,
      'masterdata': 'userrole',
      'masterdatafield': 'userrole',
      'formdatafield': 'userrole',
      'cleanable': true,
      'searchable': true,
      'masterdatadependancy': false,
      'staticfilter': {'status': 1},
    },
    {
      'field': 'team',
      'text': 'Team',
      'type': HtmlControls.kInputTextArea,
      'disabled': true,
      'defaultvisibility': true,
      'gridsize': FieldSize.k400,
      'required': false,
      'masterdata': 'team',
      'masterdatafield': 'name',
      'formdatafield': 'name',
      'cleanable': true,
      'searchable': false,
      "masterdatadependancy": false,
      'staticfilter': {'status': 1},
    },
    {
      'field': 'contact',
      'text': 'Contact',
      'type': HtmlControls.kNumberInput,
      'disabled': true,
      'defaultvisibility': true,
      'required': false,
      'maxlength': 10,
      'minlength': 10,
      'gridsize': FieldSize.k400,
    },
    {
      'field': 'email',
      'text': 'Email',
      'type': HtmlControls.kInputText,
      'regex': r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      'disabled': true,
      'defaultvisibility': true,
      'required': false,
      'gridsize': FieldSize.k400,
    },
  ]);

  @override
  void onInit() {
    fetchUserProfileData();
    pageName.value == RouteNames.kPostHandOverSRAUnit.split('/').last;
    super.onInit();
  }


  @override
  void dispose() {
    Get.delete<ProfileController>();
    super.dispose();
  }

  Future<FormDataModel> fetchUserProfileData() async {
    isLoading.value = true;
    setDefaultData.fieldOrder.value = profileFieldOrder;
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
      isLoading.value = false;
      jsonPrint(res);
    }
    isLoading.value = false;
    return setDefaultData;
  }

  Future onSaveProfileData({
    required Map reqData,
    int? editeDataIndex = -1,
  }) async {
    var url = '${Config.weburl}user/profile/update';

    var userAction = "updateuser";

    var resBody = await IISMethods().updateData(url: url, reqBody: reqData, userAction: userAction, pageName: "user");

    statusCode.value = resBody["status"];
    if (resBody["status"] == 200) {
      message.value = await resBody["message"];
      devPrint("7891235656435456");
      jsonPrint(resBody);
      try {
        if (resBody.containsKey('data')) {
          devPrint("url: ${(resBody['data'])["photo"]["url"]}");
          Settings.profile = FilesDataModel.fromJson((resBody['data'])["photo"] ?? {});
          Settings.userName = resBody['data']['name'] ?? '';
          setDefaultData.data.refresh();
          showSuccess(message.value);
          isEdit.value = false;
        } else {
          showError(message.value);
        }
      } catch (e) {
        showError(message.value);
      }
      // Get.back();
    } else {
      message.value = resBody['message'];
      showError(message.value);
    }
  }
}
