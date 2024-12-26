import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_tooltip.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

import '../../config/config.dart';
import '../../config/iis_method.dart';
import '../../routes/route_generator.dart';

class SapLogHistoryController extends GetxController {
  RxInt statusCode = 0.obs;
  RxString pageName = ''.obs;
  String searchText = '';
  TextEditingController searchTextController = TextEditingController();
  RxBool loadingData = false.obs;
  RxBool loadingPaginationData = false.obs;
  FormDataModel setDefaultData = FormDataModel();

  @override
  Future<void> onInit() async {
    pageName.value = getCurrentPageName();
    await getList();
    setPageTitle('SAP LOG History | PRENEW', Get.context!);

    super.onInit();
  }


  @override
  void dispose() {
    Get.delete<SapLogHistoryController>();
    super.dispose();
  }

  handleGridChange({required int index, required String field, required String type, dynamic value}) {
    switch (type) {
      case 'open':
        List rowList = [
          {
            'text': 'Request Body',
            'field': 'req_body',
          },
          {
            'text': 'Response Body',
            'field': 'res_body',
          },
        ];
        Map<String, dynamic> data = setDefaultData.data[index];
        Get.dialog(Dialog(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const TextWidget(
                              text: "REQUEST URL : ",
                              fontSize: 14,
                              fontWeight: FontTheme.notoBold,
                            ),
                            SelectableTextWidget(
                              text: '${data['req_url']}',
                              fontSize: 14,
                            )
                          ],
                        ),
                        Row(
                          children: [
                            const TextWidget(
                              text: "REQUEST FOR : ",
                              fontSize: 14,
                              fontWeight: FontTheme.notoBold,
                            ),
                            SelectableTextWidget(
                              text: '${data['req_for']} ',
                              fontSize: 14,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            const TextWidget(
                              text: "REQUEST OPERATION : ",
                              fontSize: 14,
                              fontWeight: FontTheme.notoBold,
                            ),
                            SelectableTextWidget(
                              text: '${data['req_operation']} ',
                              fontSize: 14,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            const TextWidget(
                              text: "RESPONSE STATUS : ",
                              fontSize: 14,
                              fontWeight: FontTheme.notoBold,
                            ),
                            SelectableTextWidget(
                              text: data['res_status'].toString().toDateTimeFormat(),
                              fontSize: 14,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const TextWidget(
                              text: "REQUEST TIME : ",
                              fontSize: 14,
                              fontWeight: FontTheme.notoBold,
                            ),
                            SelectableTextWidget(
                              text: data['req_time'].toString().toDateTimeFormat(),
                              fontSize: 14,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            const TextWidget(
                              text: "RESPONSE TIME : ",
                              fontSize: 14,
                              fontWeight: FontTheme.notoBold,
                            ),
                            SelectableTextWidget(
                              text: data['res_time'].toString().toDateTimeFormat(),
                              fontSize: 14,
                            ),
                            const SizedBox(
                              width: 16,
                            ),
                            const TextWidget(
                              text: "EXECUTION TIME : ",
                              fontSize: 14,
                              fontWeight: FontTheme.notoBold,
                            ),
                            SelectableTextWidget(
                              text: '${data['execution_time']} ms',
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () async {
                        Get.back();
                      },
                      hoverColor: Colors.transparent,
                      child: Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: ColorTheme.kBackGroundGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.clear),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: ColorTheme.kBackgroundColor, borderRadius: BorderRadius.circular(10)),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          ...List.generate(
                            rowList.length,
                            (i) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: i != 0
                                    ? null
                                    : const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Colors.black26,
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget(
                                          text: rowList[i]['text'],
                                          fontWeight: FontTheme.notoSemiBold,
                                          fontSize: 16,
                                        ),
                                        IconButton(
                                            splashRadius: 15,
                                            onPressed: () {
                                              FlutterClipboard.copy(convertBody(data[rowList[i]['field']].toString())).then((value) {
                                                showSuccess('${rowList[i]['text']} Copied');
                                              });
                                            },
                                            icon: const CustomTooltip(
                                              message: 'Copy',
                                              child: Icon(
                                                Icons.copy,
                                              ),
                                            ))
                                      ],
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: SizedBox(
                                          width: 1000,
                                          child: SelectableTextWidget(
                                            text: convertBody(data[rowList[i]['field']].toString()),
                                            fontSize: 14,
                                            fontWeight: FontTheme.notoMedium,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
    }
  }

  String convertBody(String json) {
    var encoder = const JsonEncoder.withIndent("     ");

    try {
      return encoder.convert(jsonDecode(json));
    } catch (error) {
      return json;
    }
  }

  Future<void> getList([bool appendData = false]) async {
    if (!appendData) {
      setDefaultData.data.value = [];
      loadingData.value = true;
    } else {
      loadingPaginationData.value = true;
    }
    setDefaultData.filterData.removeNullValues();
    final url = Config.weburl + pageName.value;
    final userAction = "list$pageName";
    var filter = {};
    for (var entry in setDefaultData.filterData.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.toString().isNotNullOrEmpty) {
        filter[key] = value;
      }
    }
    filter.remove('searchtext');
    final reqBody = {
      'searchtext': searchText,
      'paginationinfo': {
        'pageno': setDefaultData.pageNo.value,
        'pagelimit': setDefaultData.pageLimit,
        'filter': filter,
        'sort': setDefaultData.sortData,
      },
    };
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName.value);

    statusCode.value = resBody["status"] ?? 0;

    if (resBody["status"] == 200) {
      if (!appendData) {
        setDefaultData.data.value = List<Map<String, dynamic>>.from(resBody['data']);
      } else {
        setDefaultData.data.addAll(List<Map<String, dynamic>>.from(resBody['data']));
      }
      setDefaultData.fieldOrder.value = List<Map<String, dynamic>>.from(resBody['fieldorder']["fields"]);
      setDefaultData.nextPage = resBody['nextpage'];
      setDefaultData.pageName = resBody['pagename'];

      setDefaultData.contentLength = resBody['totaldocs'] ?? 0;
      setDefaultData.noOfPages.value = (setDefaultData.contentLength / setDefaultData.pageLimit).ceil();
    }
    loadingData.value = false;
    loadingPaginationData.value = false;
    setDefaultData.fieldOrder.refresh();
    setDefaultData.data.refresh();
    update();
  }
}
