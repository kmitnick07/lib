import 'package:dotted_border/dotted_border.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_checkbox.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_dialogs.dart';
import 'package:prestige_prenew_frontend/components/customs/loader.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_table.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column hide Row hide Border;
import 'package:universal_html/html.dart' as html;

import '../../components/customs/custom_date_picker.dart';
import '../../components/customs/custom_drag_file_area.dart';
import '../../style/string_const.dart';
import '../../style/theme_const.dart';
import '../config.dart';

class ExcelImport {
  Rx<FilesDataModel> selectedFile = FilesDataModel().obs;
  RxMap<int, ErrorList> errorList = <int, ErrorList>{}.obs;
  RxMap<String, dynamic> importedDataMap = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> fetchedData = <Map<String, dynamic>>[].obs;
  RxInt currentStage = 0.obs;
  RxBool dataLoading = false.obs;
  String? pagename;
  RxBool autoUpdateData = false.obs;
  Map keyMap = {};
  RxInt selectedTab = 0.obs;
  int selectAll = 0;
  RxList<Map<String, dynamic>> tenantproject = <Map<String, dynamic>>[].obs;
  Map<String, dynamic> selectedTenantProject = <String, dynamic>{};

  Future<String> showPickFileDialog({required Map<dynamic, dynamic> dialogBoxData, String? pageName, required String formName, Map<String, dynamic>? selectedTenantProject}) async {
    this.selectedTenantProject = selectedTenantProject ?? {};
    pagename = pageName;
    if (dialogBoxData['pagename'] != 'tenant') {
      dialogBoxData['tabs'] = [{}];
      dialogBoxData['tabs'][0]['formfields'] = dialogBoxData['formfields'];
    }
    var reqBody = {
      "paginationinfo": {
        "pageno": 1,
        "pagelimit": 500000000000,
        "filter": {},
        "projection": {
          '_id': 1,
          'name': 1,
        },
        "sort": {}
      }
    };
    // if (pagename == 'tenant') {
    //   tenantproject = List<Map<String, dynamic>>.from((await IISMethods().listData(userAction: 'tenantproject', pageName: pagename, url: '${Config.weburl}tenantproject', reqBody: reqBody, masterlisting: true) ?? {})['data']).obs;
    // }
    await Get.dialog(
      barrierDismissible: false,
      ResponsiveBuilder(builder: (context, sizingInformation) {
        return Dialog(
          shadowColor: ColorTheme.kBlack,
          backgroundColor: ColorTheme.kWhite,
          surfaceTintColor: ColorTheme.kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding: sizingInformation.isMobile ? EdgeInsets.zero : const EdgeInsets.all(12),
          alignment: Alignment.topCenter,
          child: Obx(() {
            return SizedBox(
              width: 1600,
              height: fetchedData.isEmpty ? 462 : 1000,
              child: Obx(() {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Import ${dialogBoxData['formname']}',
                            fontSize: 16,
                            fontWeight: FontTheme.notoSemiBold,
                            color: ColorTheme.kPrimaryColor,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorTheme.kBlack.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              splashColor: ColorTheme.kWhite,
                              hoverColor: ColorTheme.kWhite.withOpacity(0.1),
                              splashRadius: 20,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close),
                            ).paddingAll(2),
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    if (currentStage.value == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                        child: CustomFileDragArea(
                          fileTypes: FileTypes.excel,
                          disableMultipleFiles: true,
                          child: DottedBorder(
                            borderType: BorderType.Rect,
                            color: ColorTheme.kBorderColor,
                            dashPattern: const [8, 8, 1, 1],
                            child: Container(
                              height: 200,
                              width: 1500,
                              color: ColorTheme.kWhite,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Obx(() {
                                            return Visibility(
                                              visible: selectedFile.value.bytes != null,
                                              replacement: const Icon(
                                                size: 40,
                                                Icons.upload_file_outlined,
                                                color: ColorTheme.kPrimaryColor,
                                              ),
                                              child: const Icon(
                                                size: 40,
                                                Icons.description_outlined,
                                                color: ColorTheme.kPrimaryColor,
                                              ),
                                            );
                                          }),
                                          Obx(() {
                                            return TextWidget(
                                              text: selectedFile.value.bytes == null ? 'Please Select or Drop File Here' : selectedFile.value.name ?? '',
                                              fontSize: 16,
                                              color: ColorTheme.kPrimaryColor,
                                              fontWeight: FontTheme.notoSemiBold,
                                            );
                                          }),
                                          Obx(() {
                                            return Visibility(
                                              visible: selectedFile.value.bytes == null,
                                              child: const TextWidget(
                                                text: '(Only xlsx file supported)',
                                                fontSize: 12,
                                                color: ColorTheme.kPrimaryColor,
                                                fontWeight: FontTheme.notoSemiBold,
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                    // if (pagename == 'tenant') ...[
                                    //   Obx(() {
                                    //     return constrainedBoxWithPadding(
                                    //       width: 200,
                                    //       child: DropDownSearchCustom(
                                    //         focusNode: FocusNode(),
                                    //         canShiftFocus: false,
                                    //         items: List<Map<String, dynamic>>.from(tenantproject.map((element) => {
                                    //               'value': element['_id'],
                                    //               'label': element['name'],
                                    //             })),
                                    //         initValue: selectedTenantProject.isNotNullOrEmpty ? selectedTenantProject : null,
                                    //         hintText: "Select Tenant Project",
                                    //         // textFieldLabel: "Tenant Project",
                                    //         isCleanable: true,
                                    //         isSearchable: true,
                                    //         onChanged: (v) async {
                                    //           selectedTenantProject.value = v!;
                                    //         },
                                    //         clickOnCleanBtn: () {
                                    //           selectedTenantProject.value = {};
                                    //         },
                                    //         dropValidator: (Map<String, dynamic>? v) {
                                    //           return null;
                                    //         },
                                    //       ),
                                    //     );
                                    //   }),
                                    // ],
                                    Obx(() {
                                      var key1 = GlobalKey();
                                      return Visibility(
                                        visible: selectedFile.value.bytes == null,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: CustomButton(
                                            key: key1,
                                            onTap: () async {
                                              await exportSampleExcel(dialogBoxData, formName, selectedTenantProject);
                                            },
                                            title: 'Download Sample File',
                                            width: 50,
                                            borderRadius: 6,
                                            fontWeight: FontTheme.notoSemiBold,
                                            fontSize: 12,
                                            height: 30,
                                            buttonColor: ColorTheme.kPrimaryColor,
                                            fontColor: ColorTheme.kWhite,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          onFilePicked: (files) {
                            selectedFile.value = files.first;
                            importFromExcel(
                              dialogBoxData: dialogBoxData,
                            );
                          },
                        ),
                      ),
                    if (fetchedData.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Note:',
                                fontSize: 16,
                                fontWeight: FontTheme.notoSemiBold,
                                textAlign: TextAlign.left,
                              ),
                              TextWidget(
                                text: 'Please Enter Dates in MM/DD/YYYY format.',
                                fontSize: 14,
                                fontWeight: FontTheme.notoMedium,
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Obx(() {
                          if (currentStage.value == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Obx(() {
                                    List<Map<String, dynamic>> fieldorder = [];
                                    for (var tabs in dialogBoxData['tabs']) {
                                      for (var formFields in tabs['formfields']) {
                                        for (var field in formFields['formFields']) {
                                          {
                                            if (field['disabled'] == true || field['showinexcel'] == false) continue;
                                            switch (field['type']) {
                                              case HtmlControls.kImagePicker:
                                              case HtmlControls.kAvatarPicker:
                                              case HtmlControls.kFilePicker:
                                              case HtmlControls.kMultipleImagePicker:
                                              case HtmlControls.kMultipleFilePickerFieldWithTitle:
                                              case HtmlControls.kMultipleTextFieldWithTitle:
                                                continue;
                                              case HtmlControls.kDropDown:
                                                Map<String, dynamic> fieldData = {
                                                  'text': field['text'],
                                                  'field': field['formdatafield'],
                                                  'tblsize': field['gridsize'] / 20,
                                                  'active': 1,
                                                };
                                                keyMap[field['formdatafield']] = field['text'];

                                                if (field.containsKey('primaryField') && field['primaryField']) {
                                                  fieldData['type'] = HtmlControls.kPrimaryField;
                                                }

                                                int index = fieldorder.indexWhere((element) => element['text'] == fieldData['text']);
                                                if (index == -1) {
                                                  fieldorder.add(fieldData);
                                                }
                                              default:
                                                Map<String, dynamic> fieldData = {
                                                  'text': field['text'],
                                                  'field': field['field'],
                                                  'tblsize': field['gridsize'] / 20,
                                                  'active': 1,
                                                };
                                                keyMap[field['field']] = field['text'];
                                                if (field.containsKey('primaryField') && field['primaryField']) {
                                                  fieldData['type'] = HtmlControls.kPrimaryField;
                                                }
                                                int index = fieldorder.indexWhere((element) => element['text'] == fieldData['text']);
                                                if (index == -1) {
                                                  fieldorder.add(fieldData);
                                                }
                                            }
                                          }
                                        }
                                      }
                                    }
                                    print(fieldorder);
                                    return Visibility(
                                      visible: fetchedData.isNotEmpty,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 48,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor, width: 1)),
                                          child: CommonDataTableWidget(
                                            showPagination: false,
                                            width: 1500,
                                            setDefaultData: FormDataModel(),
                                            data: fetchedData.isNotEmpty ? List<Map<String, dynamic>>.from(fetchedData) : fetchedData,
                                            fieldOrder: fieldorder,
                                            tableScrollController: null,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                Obx(() {
                                  return Visibility(
                                    visible: errorList.values.isNotEmpty && fetchedData.isNotEmpty && false,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 1500,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: 'Errors: ${errorList.values.length}',
                                            fontSize: 16,
                                            fontWeight: FontTheme.notoMedium,
                                            color: ColorTheme.kPrimaryColor,
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxHeight: 100),
                                            child: ListView.builder(
                                              itemBuilder: (context, index) {
                                                return Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.circle,
                                                      color: ColorTheme.kErrorColor,
                                                      size: 12,
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    TextWidget(
                                                      text:
                                                          'Invalid value of ${errorList.values.toList()[index].fields?.join(', ')} in line ${errorList.values.toList()[index].index}',
                                                      fontSize: 12,
                                                      color: ColorTheme.kErrorColor,
                                                      height: 2,
                                                    ),
                                                  ],
                                                );
                                              },
                                              itemCount: errorList.values.length,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                Obx(() {
                                  return Visibility(
                                      visible: fetchedData.isNotEmpty,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 8),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CustomCheckBox(
                                                value: autoUpdateData.value,
                                                onChanged: (value) {
                                                  autoUpdateData.value = value!;
                                                },
                                                fontWeight: FontTheme.notoMedium,
                                                label: 'Over-right existing records',
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              CustomButton(
                                                onTap: () async {
                                                  dataLoading.value = true;
                                                  await sentMassAddRequest(dialogBoxData: dialogBoxData);
                                                  dataLoading.value = false;
                                                },
                                                width: 135,
                                                fontSize: 14,
                                                borderRadius: 4,
                                                height: 40,
                                                widget: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.upload,
                                                      color: ColorTheme.kWhite,
                                                    ).paddingOnly(right: 8),
                                                    const TextWidget(
                                                      text: StringConst.kUploadBtnTxt,
                                                      fontSize: 13,
                                                      fontWeight: FontTheme.notoRegular,
                                                      color: ColorTheme.kWhite,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                })
                              ],
                            );
                          } else {
                            List<Map<String, dynamic>> tabs = [
                              {
                                'name': 'Added Records',
                                'key': 'datainsertarray',
                              },
                              {
                                'name': 'Updated Records',
                                'key': 'duplicateerrArray',
                              },
                              {
                                'name': 'Skipped Records',
                                'key': 'errArray',
                              },
                            ];

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Obx(() {
                                            return InkWell(
                                              onTap: () {
                                                selectedTab.value = index;
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: tabs[index]['key'] == 'errArray' && selectedTab.value == index
                                                      ? ColorTheme.kErrorColor
                                                      : selectedTab.value == index
                                                          ? ColorTheme.kBlack
                                                          : ColorTheme.kBackGroundGrey,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    TextWidget(
                                                      text: tabs[index]['name'],
                                                      fontWeight: FontTheme.notoSemiBold,
                                                      color: selectedTab.value == index
                                                          ? ColorTheme.kWhite
                                                          : tabs[index]['key'] == 'errArray'
                                                              ? ColorTheme.kErrorColor
                                                              : ColorTheme.kBlack,
                                                    ),
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    CircleAvatar(
                                                      backgroundColor: selectedTab.value == index
                                                          ? ColorTheme.kWhite
                                                          : tabs[index]['key'] == 'errArray'
                                                              ? ColorTheme.kErrorColor
                                                              : ColorTheme.kBlack,
                                                      radius: 15,
                                                      child: Center(
                                                        child: TextWidget(
                                                          text: ((importedDataMap[tabs[index]['key']] ?? []) as List).length,
                                                          color: tabs[index]['key'] == 'errArray' && selectedTab.value == index
                                                              ? ColorTheme.kErrorColor
                                                              : selectedTab.value == index
                                                                  ? ColorTheme.kBlack
                                                                  : ColorTheme.kWhite,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            width: 8,
                                          );
                                        },
                                        itemCount: tabs.length),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ColorTheme.kBorderColor,
                                        ),
                                        color: ColorTheme.kWhite,
                                      ),
                                      child: Builder(builder: (context) {
                                        return Obx(() {
                                          List<Map<String, dynamic>> fieldorder = [];
                                          for (var tabs in dialogBoxData['tabs']) {
                                            for (var formFields in tabs['formfields']) {
                                              for (var field in formFields['formFields']) {
                                                {
                                                  if (field['disabled'] == true || field['showinexcel'] == false) continue;
                                                  switch (field['type']) {
                                                    case HtmlControls.kImagePicker:
                                                    case HtmlControls.kAvatarPicker:
                                                    case HtmlControls.kFilePicker:
                                                    case HtmlControls.kMultipleImagePicker:
                                                    case HtmlControls.kMultipleTextFieldWithTitle:
                                                      continue;
                                                    case HtmlControls.kDropDown:
                                                      Map<String, dynamic> fieldData = {
                                                        'text': field['text'],
                                                        'field': field['formdatafield'],
                                                        'tblsize': field['gridsize'] / 20,
                                                        'active': 1,
                                                      };

                                                      int index = fieldorder.indexWhere((element) => element['text'] == fieldData['text']);
                                                      if (index == -1) {
                                                        fieldorder.add(fieldData);
                                                      }
                                                    default:
                                                      Map<String, dynamic> fieldData = {
                                                        'text': field['text'],
                                                        'field': field['field'],
                                                        'tblsize': field['gridsize'] / 20,
                                                        'active': 1,
                                                      };

                                                      int index = fieldorder.indexWhere((element) => element['text'] == fieldData['text']);
                                                      if (index == -1) {
                                                        fieldorder.add(fieldData);
                                                      }
                                                  }
                                                }
                                              }
                                            }
                                          }
                                          if (tabs[selectedTab.value]['key'] == 'errArray') {
                                            Map<String, dynamic> fieldData = {
                                              'text': "Message",
                                              'field': 'message',
                                              'color': 'E55E5E',
                                              'tblsize': 20,
                                              'active': 1,
                                            };
                                            fieldorder.insert(0, fieldData);
                                          }
                                          if (!autoUpdateData.value && tabs[selectedTab.value]['key'] == 'duplicateerrArray') {
                                            Map<String, dynamic> fieldData = {
                                              'text': "Select",
                                              'field': 'isSelected',
                                              'canselectall': 1,
                                              'type': 'checkbox',
                                              'tblsize': 20,
                                              'active': 1,
                                              'selectall': selectAll
                                            };
                                            fieldorder.insert(0, fieldData);
                                          }
                                          Map<String, dynamic> fieldData = {
                                            'text': "Row",
                                            'field': 'row',
                                            'tblsize': 5,
                                            'active': 1,
                                          };
                                          fieldorder.insert(0, fieldData);

                                          return CommonDataTableWidget(
                                              setDefaultData: FormDataModel(),
                                              showPagination: false,
                                              fieldOrder: fieldorder,
                                              handleGridChange: (index, field, type, value, masterfieldname, name) {
                                                if (type == 'checkbox') {
                                                  importedDataMap[tabs[selectedTab.value]['key']][index][field] = value ? 1 : 0;
                                                  if (selectAll == 1 && !value) {
                                                    selectAll = 0;
                                                  }
                                                  importedDataMap.refresh();
                                                } else if (type == 'selectAllCheckbox') {
                                                  for (var element in (importedDataMap[tabs[selectedTab.value]['key']] as List)) {
                                                    element[field] = value ? 1 : 0;
                                                  }
                                                  selectAll = value ? 1 : 0;
                                                  importedDataMap.refresh();
                                                }
                                              },
                                              data: List<Map<String, dynamic>>.from(importedDataMap[tabs[selectedTab.value]['key']] ?? []),
                                              tableScrollController: ScrollController());
                                        });
                                      }),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Visibility(
                                          visible: !autoUpdateData.value && ((importedDataMap['duplicateerrArray'] ?? []) as List).isNotNullOrEmpty,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CustomButton(
                                              onTap: () async {
                                                currentStage++;
                                                dataLoading.value = true;
                                                await sentMassUpdateRequest(dialogBoxData: dialogBoxData);
                                                dataLoading.value = false;
                                              },
                                              width: 135,
                                              fontSize: 13,
                                              borderRadius: 4,
                                              height: 40,
                                              title: 'Update',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        CustomButton(
                                          onTap: () {
                                            Get.back();
                                          },
                                          width: 135,
                                          fontSize: 13,
                                          borderRadius: 4,
                                          height: 40,
                                          buttonColor: ColorTheme.kBackGroundGrey,
                                          fontColor: ColorTheme.kPrimaryColor,
                                          title: StringConst.kCloseBtnTxt,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                        }),
                      ),
                  ],
                );
              }),
            );
          }),
        );
      }),
    );
    return "dynamic";
  }

  sentMassAddRequest({required Map<dynamic, dynamic> dialogBoxData}) async {
    var reqBody = {
      'data': fetchedData.value,
      'overrightexistingrecords': autoUpdateData.value ? 1 : 0,
      'keymap': keyMap,
    };
    var response = await IISMethods().addData(
        url: '${Config.weburl}${dialogBoxData['pagename']}/importcsv',
        reqBody: reqBody,
        pageName: pagename ?? dialogBoxData['pagename'],
        userAction: 'add${pagename ?? dialogBoxData['pagename']}');
    if (response['status'] == 200) {
      importedDataMap.value = Map<String, dynamic>.from(response);
      currentStage++;
      showSuccess('${response['message']}');
    } else {
      showError('${response['message']}');
    }
    importedDataMap.refresh();
  }

  sentMassUpdateRequest({required Map<dynamic, dynamic> dialogBoxData}) async {
    (importedDataMap['duplicateerrArray'] as List).retainWhere((element) => element['isSelected'] == 1);
    if ((importedDataMap['duplicateerrArray'] as List).isNullOrEmpty) {
      Get.back();
      return;
    }

    var reqBody = {
      'data': importedDataMap['duplicateerrArray'],
      'replace': 1,
    };
    var response = await IISMethods().addData(
        url: '${Config.weburl}${dialogBoxData['pagename']}/importcsv',
        reqBody: reqBody,
        pageName: pagename ?? dialogBoxData['pagename'],
        userAction: 'add${pagename ?? dialogBoxData['pagename']}');
    // importedDataMap.value = Map<String, dynamic>.from(response);
    importedDataMap.refresh();
    if (response['status'] == 200) {
      showSuccess(response['message']);
      Get.back();
    } else {
      showError(response['message']);
    }
  }

  Excel parseExcelFile(List<int> bytes) {
    return Excel.decodeBytes(bytes);
  }

  Future<void> importFromExcel({
    required Map<dynamic, dynamic> dialogBoxData,
  }) async {
    try {
      // Read bytes from the file
      List<int> bytes = selectedFile.value.bytes!;

      // Decode Excel file
      // Excel excel = Excel.decodeBytes(bytes);
      Excel excel = await compute(parseExcelFile, bytes);

      // Clear previous row details
      List<List<Data?>> rowDetail = [];

      // Iterate through each row in the Default Sheet
      for (List<Data?> row in excel.sheets[excel.getDefaultSheet()]!.rows) {
        // Convert row to a string and add it to the list
        rowDetail.add(row); // Adjust formatting as needed
      }

      errorList.clear();
      fetchedData.clear();
      List<Data?> title = rowDetail.first;
      int index = 0;
      for (List<Data?> data in rowDetail.sublist(1)) {
        index++;
        devLog("${data.map((e) => e?.value.toString())}    013461434");
        int tempIndex = data.indexWhere((element) => element?.value.toString().isNotNullOrEmpty ?? false);
        if (tempIndex == -1) {
          break;
        }
        Map<String, dynamic> temp = {};
        for (var tabs in dialogBoxData['tabs']) {
          for (var formFields in tabs['formfields']) {
            for (var field in formFields['formFields']) {
              int i = title.indexWhere((Data? element) => element?.value.toString() == field['text']);
              if (i == -1) {
                if (pagename == 'tenant' && field['formdatafield'] == 'tenantprojectname') {
                  temp[field['formdatafield']] = data[0]?.sheetName.toString();
                }
                continue;
              }
              String fieldValue = '';
              if (data[i]?.value.toString() != '-') {
                fieldValue = data[i]?.value.toString() ?? '';
              }
              devPrint('${field['text']} ------> $fieldValue');
              if (field['type'] == HtmlControls.kMultipleTextFieldWithTitle || field['showinexcel'] == false) {
                continue;
              }
              if (field['type'] == HtmlControls.kDropDown) {
                // if (field['field'] == HtmlControls.kStatus) {
                //   temp[field['formdatafield']] = (fieldValue == StringConst.kActive) ? 1 : 0;
                // } else {
                temp[field['formdatafield']] = fieldValue;
                // }

                if (field.containsKey('primaryField') && field['primaryField'] && temp[field['formdatafield']].toString().isNullOrEmpty) {
                  // print('FIELD--->${}');
                  errorList[index] ??= ErrorList();
                  errorList[index]?.index = index;
                  errorList[index]?.fields?.add(field['text']);
                }
              } else if (field['type'] == HtmlControls.kDatePicker) {
                try {
                  temp[field['field']] = dateConvertIntoUTC(DateTime.parse(fieldValue).toLocal());
                } catch (e) {
                  try {
                    if (fieldValue.isNotNullOrEmpty) {
                      temp[field['field']] = dateConvertIntoUTC(DateFormat('yMd').parse(
                        fieldValue,
                      ));
                    }
                  } catch (e) {
                    devPrint('DATE ERROR ----> $fieldValue ---> $e');
                    // errorList[index] ??= ErrorList();
                    // errorList[index]?.index = index;
                    // errorList[index]?.fields?.add(field['text']);
                  }
                }
              } else {
                temp[field['field']] = fieldValue;
                if (field.containsKey('primaryField') && field['primaryField'] && temp[field['field']].toString().isNullOrEmpty) {
                  errorList[index] ??= ErrorList();
                  errorList[index]?.index = index;
                  errorList[index]?.fields?.add(field['text']);
                }
              }
            }
          }
        }
        // if (pagename == 'tenant' && selectedTenantProject.value.isNotNullOrEmpty) {
        //   temp['tenantprojectname'] = selectedTenantProject['label'];
        // }
        bool removeIndex = true;
        for (var key in temp.values) {
          if (key.toString().isNotNullOrEmpty) {
            fetchedData.add(temp);
            removeIndex = false;
            break;
          }
        }
        if (removeIndex) errorList.remove(index);
      }

      // fetchedData.value = fetchedData.toSet().toList();
    } catch (e) {
      showError('SOMETHING WENT WRONG');
    }
    devPrint('ERROR-LIST ____>${errorList.values.map((e) => '${e.index} ---> ${e.fields}')}');
  }

  Future<void> exportSampleExcel(Map<dynamic, dynamic> dialogBoxData, String pagename, Map<String, dynamic>? selectedTenantProject) async {
    try {
      AppLoader();
      final Workbook workbook = Workbook(0);
      final Worksheet sheet1 = workbook.worksheets.addWithName((selectedTenantProject?['label'] ?? pagename).toString().toCamelCase);
      final Worksheet sheet2 = workbook.worksheets.addWithName('ValidValues');
      int columnIndex = 0;
      int dataColumnIndex = 0;
      Map<dynamic, dynamic> dialogData = IISMethods().encryptDecryptObj(dialogBoxData);
      try {
        if (dialogBoxData['pagename'] == 'tenant' && selectedTenantProject.isNotNullOrEmpty) {
          (dialogData['tabs'][0]['formfields'][0]['formFields'] as List).removeWhere((element) => element['field'] == 'tenantprojectid');
        }
      } catch (e) {}

      for (var tab in dialogData['tabs'] ?? [{}]) {
        for (var formFields in tab['formfields']) {
          for (var field in formFields['formFields']) {
            if (field['disabled'] == true || field['showinexcel'] == false) {
              continue;
            } else if (HtmlControls.kImagePicker == field['type'] ||
                HtmlControls.kAvatarPicker == field['type'] ||
                HtmlControls.kFilePicker == field['type'] ||
                HtmlControls.kMultipleImagePicker == field['type'] ||
                HtmlControls.kMultipleTextFieldWithTitle == field['type']) {
            } else if (field.containsKey('text')) {
              columnIndex++;
              sheet1.getRangeByName('${columnIndex.indexToLetters}1').setText(field['text'] ?? "");
              sheet1.getRangeByName('${columnIndex.indexToLetters}1').autoFitColumns();

              if (field['type'] == HtmlControls.kDropDown) {
                dataColumnIndex++;
                String dataColumnName = dataColumnIndex.indexToLetters;
                final DataValidation customValidation = sheet1.getRangeByName('${columnIndex.indexToLetters}2:${columnIndex.indexToLetters}10000').dataValidation;
                sheet2.getRangeByName('${dataColumnName}1').setText(field['text'] ?? "");

                if (field['masterdataarray'] != null) {
                  for (var j = 0; j < field['masterdataarray'].length; j++) {
                    sheet2.getRangeByName('$dataColumnName${(j + 2).toString()}').setText(field['masterdataarray'][j]['label'] ?? "");
                    customValidation.dataRange = sheet2.getRangeByName('${dataColumnName}2:$dataColumnName${(j + 2).toString()}');
                  }
                  if (field['field'] == "attendedgeneralbodyresolution") {
                    var response = await IISMethods().listData(userAction: 'listconsentdocument', pageName: 'tenant', url: '${Config.weburl}gbrdocument', reqBody: {
                      'searchtext': '',
                      'paginationinfo': {
                        'pageno': 1,
                        'pagelimit': 10,
                        'filter': {
                          'tenantprojectid': selectedTenantProject?['value'] ?? '',
                          'societyid': '',
                          'tenantid': '',
                        },
                        'sort': {},
                      },
                    });
                    if (response['status'] == 200 && response["data"] is List) {
                      devPrint(response.toString() + "11445522");
                      for (var i = 0; i < response["data"].length; i++) {
                        columnIndex++;
                        sheet1.getRangeByName('${columnIndex.indexToLetters}1').setText((response["data"][i]['title'] ?? "").toString());
                        sheet1.getRangeByName('${columnIndex.indexToLetters}1').autoFitColumns();
                      }
                    }
                  }
                  if (field['field'] == "attendedcommonconsent") {
                    var response = await IISMethods().listData(userAction: 'listconsentdocument', pageName: 'tenant', url: '${Config.weburl}consentdocument', reqBody: {
                      'searchtext': '',
                      'paginationinfo': {
                        'pageno': 1,
                        'pagelimit': 10,
                        'filter': {
                          'tenantprojectid': selectedTenantProject?['value'] ?? '',
                          'societyid': '',
                          'tenantid': '',
                        },
                        'sort': {},
                      },
                    });
                    if (response['status'] == 200 && response["data"] is List) {
                      for (var i = 0; i < response["data"].length; i++) {
                        columnIndex++;
                        sheet1.getRangeByName('${columnIndex.indexToLetters}1').setText((response["data"][i]['title'] ?? "").toString());
                        sheet1.getRangeByName('${columnIndex.indexToLetters}1').autoFitColumns();
                      }
                    }
                  }
                } else {
                  var url = Config.weburl + field["masterdata"];
                  var userAction = 'list${field["masterdata"]}data';
                  var projection = {};
                  if (field["projection"] != null) {
                    projection = {...field["projection"]};
                  }
                  var filter = field['staticfilter'] ?? {};

                  if (this.pagename == 'tenant') {
                    if (field["dependentfilter"] != null) {
                      for (var key in (field["dependentfilter"] as Map).keys) {
                        if (field["dependentfilter"][key] == 'tenantprojectid') {
                          filter[key] = selectedTenantProject?['value'];
                        }
                      }
                    }
                    if (field['field'] == 'tenantprojectid') {
                      filter['_id'] = selectedTenantProject?['value'];
                    }
                  }

                  var reqBody = {
                    "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": filter, "projection": projection, "sort": {}}
                  };

                  var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pagename, masterlisting: true);
                  List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(resBody['data'] ?? []);

                  for (var k = 0; k < data.length; k++) {
                    if (field['field'] == 'tenantstatusid') {
                      columnIndex++;
                      sheet1.getRangeByName('${columnIndex.indexToLetters}1').setText((data[k][field["masterdatafield"]] ?? "").toString());
                      sheet1.getRangeByName('${columnIndex.indexToLetters}1').autoFitColumns();
                    }

                    sheet2.getRangeByName('$dataColumnName${(k + 2).toString()}').setText((data[k][field["masterdatafield"]] ?? "").toString());
                    sheet2.getRangeByName('$dataColumnName${(k + 2).toString()}').autoFitColumns();
                    customValidation.dataRange = sheet2.getRangeByName('${dataColumnName}2:$dataColumnName${(k + 2).toString()}');
                  }
                }
              }
            }
          }
        }
      }

      // sheet2.visibility = WorksheetVisibility.hidden;
      sheet2.protect('Prenew@2024', ExcelSheetProtectionOption.excelSheetProtectionOption);
      await saveAndLaunchFile(workbook.saveSync(), '${dialogData['formname']}-${DateTime.now()}.xlsx');
      workbook.dispose();
      RemoveAppLoader();
    } catch (e) {
      devPrint("$e    555558");
    }
  }

  static Future<void> saveAndLaunchFile(List<int> bytes, String filename) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      IISMethods().saveFileFromBytes(file: Uint8List.fromList(bytes), filename: filename);
    }
  }
}

class ErrorList {
  int? index;
  List<String>? fields;

  ErrorList({
    this.index,
    this.fields,
  }) {
    fields = fields ?? [];
  }
}
