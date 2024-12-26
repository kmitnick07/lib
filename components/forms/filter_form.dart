import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_button.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_checkbox.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_tooltip.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config/iis_method.dart';
import '../../style/assets_string.dart';
import '../../style/string_const.dart';
import '../customs/custom_text_form_field.dart';
import '../customs/drop_down_search_custom.dart';
import '../customs/multi_drop_down_custom.dart';
import '../funtions.dart';

class FilterForm extends StatelessWidget {
  FilterForm({
    super.key,
    this.isMasterForm = false,
    this.title = "Add",
    required this.setDefaultData,
    this.btnName = StringConst.kAddBtnTxt,
    required this.onFilterApply,
    required this.onResetFilter,
  });

  final bool isMasterForm;
  final String title;
  final String btnName;
  final FormDataModel setDefaultData;
  final Function() onFilterApply;
  final Function() onResetFilter;
  final Map<int, FocusNode> focusNodes = {};
  RxBool isAdvanceEnabled = false.obs;
  RxBool seeAllFilterButton = false.obs;

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    int index = setDefaultData.fieldOrder.indexWhere((element) => element['isadvancedfilter'] == 1);
    if (index != -1) {
      seeAllFilterButton.value = true;
    }

    Widget filterForm() {
      return ResponsiveBuilder(builder: (context, sizeInformation) {
        return Form(
          child: Column(
            children: [
              Container(
                height: sizeInformation.isMobile ? null : 85,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: ColorTheme.kBorderColor,
                      width: 0.5,
                    ),
                  ),
                ),
                padding: EdgeInsets.all(sizeInformation.isMobile ? 8 : 24),
                child: Center(
                  child: Row(
                    children: [
                      TextWidget(
                        text: title,
                        fontWeight: FontWeight.w500,
                        color: ColorTheme.kPrimaryColor,
                        fontSize: 18,
                      ),
                      const Spacer(),
                      CustomTooltip(
                        message: 'Clear Filter',
                        child: IconButton(
                          focusNode: FocusNode(canRequestFocus: false),
                          onPressed: () {
                            setDefaultData.filterData.value = {};
                            setDefaultData.pageNo.value = 1;
                            onResetFilter();
                          },
                          icon: const Icon(Icons.restart_alt_outlined),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setDefaultData.filterData.value = IISMethods().encryptDecryptObj(setDefaultData.oldFilterData.value);
                          setDefaultData.filterData.removeNullValues();
                          Get.back();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ColorTheme.kBackGroundGrey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.clear,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ).paddingOnly(bottom: 4),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: sizeInformation.isMobile ? 2 : 16.0),
                  child: Obx(() {
                    return Wrap(
                      children: List.generate(setDefaultData.fieldOrder.length, (i) {
                        Map<String, dynamic> res = setDefaultData.fieldOrder[i];

                        var focusOrderCode = generateUniqueFieldId(0, i, null, null);
                        if (!focusNodes.containsKey(focusOrderCode)) {
                          focusNodes[focusOrderCode] = FocusNode();
                        }
                        if (res['filter'] != 1 || (res['isadvancedfilter'] == 1 && !isAdvanceEnabled.value)) {
                          return const SizedBox.shrink();
                        }

                        switch (res["filterfieldtype"]) {
                          case HtmlControls.kCheckBox:
                            return Obx(() {
                              return constrainedBoxWithPadding(
                                  width: res['gridsize'],
                                  child: CustomCheckBox(
                                    focusNode: focusNodes[focusOrderCode],
                                    label: res["text"],
                                    value: setDefaultData.filterData[res["filterfield"]] == 1,
                                    onChanged: (v) async {
                                      setDefaultData.filterData[res["filterfield"]] = v! ? 1 : 0;
                                      setDefaultData.filterData.refresh();
                                    },
                                  ));
                            });
                          case HtmlControls.kMultiSelectDropDown:
                            var masterdatakey = res["masterdata"] /*?? res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["filterfield"] : res["masterdata"]*/;
                            return Obx(() {
                              return constrainedBoxWithPadding(
                                width: res['gridsize'],
                                child: MultiDropDownSearchCustom(
                                  selectedItems: List<Map<String, dynamic>>.from(List<Map<String, dynamic>>.from(setDefaultData.masterData[masterdatakey] ?? []).map((e) => <String, dynamic>{
                                        res["filterfield"]: e['label'],
                                        '${res["filterfield"]}id': e['value'],
                                      })).where((element) {
                                    try {
                                      return (setDefaultData.filterData[res['filterfield']] as List?)?.contains(element['${res["filterfield"]}id']) ?? false;
                                    } catch (e) {
                                      return false;
                                    }
                                  }).toList(),
                                  field: res["filterfield"],
                                  width: (double.tryParse(res['gridsize'].toString())),
                                  focusNode: focusNodes[focusOrderCode],
                                  dropValidator: (p0) {
                                    return null;
                                  },
                                  items: List<Map<String, dynamic>>.from(setDefaultData.masterData[masterdatakey] ?? []),
                                  // initValue: ((setDefaultData.filterData[res["filterfield"]] ?? []) as List?).isNullOrEmpty ? null : setDefaultData.filterData[res["filterfield"]]?.last,
                                  isRequire: res["required"],
                                  textFieldLabel: res["text"],
                                  hintText: "Select ${res["text"]}",
                                  isCleanable: true,
                                  buttonText: res["text"],
                                  clickOnCleanBtn: () async {
                                    setDefaultData.filterData[res['filterfield']] = [];
                                    await getMasterData(res: res);
                                  },
                                  isSearchable: res["searchable"],
                                  onChanged: (v) async {
                                    setDefaultData.filterData[res['filterfield']] = v;
                                    getMasterData(res: res);
                                    devPrint(setDefaultData.filterData[res['filterfield']]);
                                  },
                                ),
                              );
                            });
                          case HtmlControls.kDropDown:
                            return Obx(() {
                              if ((res['isadvancedfilter'] == 1 && !isAdvanceEnabled.value)) {
                                seeAllFilterButton.value = true;
                                seeAllFilterButton.refresh();
                                return const SizedBox.shrink();
                              }
                              var masterdatakey = res["masterdata"];
                              List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(IISMethods().encryptDecryptObj(setDefaultData.masterData[masterdatakey] ?? []));
                              return constrainedBoxWithPadding(
                                  width: 400,
                                  child: DropDownSearchCustom(
                                    width: 400,
                                    focusNode: focusNodes[focusOrderCode],
                                    dropValidator: (p0) {
                                      return null;
                                    },
                                    isCleanable: res['cleanable'] != false,
                                    clickOnCleanBtn: () async {
                                      setDefaultData.filterData[res['filterfield']] = null;
                                      setDefaultData.filterData[res['formdatafield']] = null;
                                      await getMasterData(res: res);
                                    },
                                    items: list,
                                    textFieldLabel: res["text"],
                                    hintText: "Select ${res["text"]}",
                                    buttonText: res["text"],
                                    initValue: list.firstWhereOrNull((element) => element["value"] == setDefaultData.filterData[res["filterfield"]]),
                                    isSearchable: true,
                                    onChanged: (v) async {
                                      devPrint(v);
                                      setDefaultData.filterData[res['formdatafield']] = v?['label'];
                                      setDefaultData.filterData[res['filterfield']] = v?['value'];

                                      await getMasterData(res: res);
                                    },
                                  ));
                            });
                          case HtmlControls.kDateRangePicker:
                            return Obx(
                              () {
                                List<String> selectedDateRange = List<String>.from((setDefaultData.filterData)[res["filterfield"]] ?? []);
                                var textController = TextEditingController(
                                  text: selectedDateRange.isNullOrEmpty
                                      ? ""
                                      : selectedDateRange.map(
                                          (date) {
                                            return DateFormat("dd-MM-yyyy")
                                                .format(
                                                  DateTime.parse(date).toLocal(),
                                                )
                                                .toString();
                                          },
                                        ).join(' - '),
                                );
                                // if (cursorPos <= textController.text.length) {
                                //   textController.selection = TextSelection.collapsed(offset: cursorPos);
                                // } else {
                                //   textController.selection = TextSelection.collapsed(offset: textController.text.length);
                                // }
                                void onTap() {
                                  showCustomDateRangePicker(
                                    initialStartDate: ((setDefaultData.filterData)[res["filterfield"]] ?? []).length == 2 ? ((setDefaultData.filterData)[res["filterfield"]] ?? [])[0] : null,
                                    initialEndDate: ((setDefaultData.filterData)[res["filterfield"]] ?? []).length == 2 ? ((setDefaultData.filterData)[res["filterfield"]] ?? [])[1] : null,
                                    onDateSelected: (startDate, endDate) async {
                                      setDefaultData.filterData[res['field']] = [startDate, endDate];
                                      setDefaultData.filterData.refresh();
                                      // await handleFormData(
                                      //   key: res["filterfield"],
                                      //   value: [startDate, endDate],
                                      //   type: res["type"],
                                      // );
                                    },
                                  );
                                }

                                return constrainedBoxWithPadding(
                                  width: res['gridsize'],
                                  child: CustomTextFormField(
                                    focusNode: focusNodes[focusOrderCode],
                                    controller: textController,
                                    hintText: "Enter ${res["text"]}",
                                    readOnly: true,
                                    disableField: false,
                                    onTap: () {
                                      onTap();
                                    },
                                    onFieldSubmitted: (v) async {
                                      onTap();
                                    },
                                    suffixIcon: AssetsString.kCalender,
                                    validator: (v) {
                                      // if (validator[res["filterfield"]] ?? false || res.containsKey("regex")) {
                                      //   if (v.toString().isEmpty) {
                                      //     return "Please Enter ${res["text"]}";
                                      //   } else if (res.containsKey("regex")) {
                                      //     if (!RegExp(res["regex"]).hasMatch(v)) {
                                      //       return "Please Enter a valid ${res["text"]}";
                                      //     }
                                      //   }
                                      // }
                                      return null;
                                    },
                                    suffixWidget: textController.text.isNotNullOrEmpty
                                        ? InkResponse(
                                            onTap: () {
                                              setDefaultData.filterData.remove(res["filterfield"]);
                                            },
                                            child: const Icon(
                                              Icons.close,
                                            ),
                                          ).paddingOnly(right: 4)
                                        : null,
                                    showSuffixDivider: false,
                                    isRequire: res["required"],
                                    textFieldLabel: res["text"],
                                  ),
                                );
                              },
                            );

                          default:
                            return Builder(builder: (context) {
                              var textController = TextEditingController(text: setDefaultData.filterData[res["filterfield"]].toString().isNotNullOrEmpty ? setDefaultData.filterData[res["filterfield"]].toString() : '');
                              return constrainedBoxWithPadding(
                                  width: res['gridsize'],
                                  child: CustomTextFormField(
                                    focusNode: focusNodes[focusOrderCode],
                                    textInputType: TextInputType.text,
                                    controller: textController,
                                    hintText: "Enter ${res["text"]}",
                                    inputFormatters: [if (res['field'] == 'email' || res['field'] == 'person_email' || res['field'] == 'personemail') inputTextEmailRegx else inputTextRegx],
                                    showSuffixDivider: (res.containsKey('suffixtext') && res['suffixtext'] != null),
                                    suffixWidget: (res.containsKey('suffixtext') && res['suffixtext'] != null)
                                        ? TextWidget(
                                            text: res['suffixtext'],
                                          ).paddingSymmetric(horizontal: 4)
                                        : null,
                                    validator: (v) {
                                      return null;
                                    },
                                    textFieldLabel: res["text"],
                                    onChanged: (v) async {
                                      setDefaultData.filterData[res["filterfield"]] = v;
                                    },
                                  ));
                            });
                        }
                      }),
                    );
                  }),
                ),
              ),
              Visibility(
                visible: sizeInformation.isMobile,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          onTap: () async {
                            setDefaultData.filterData.removeNullValues();
                            setDefaultData.pageNo.value = 1;
                            await onFilterApply();
                            Get.back();
                          },
                          height: 50,
                          width: 70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          buttonColor: ColorTheme.kPrimaryColor,
                          fontColor: ColorTheme.kWhite,
                          borderRadius: 4,
                          title: btnName,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          onTap: () async {
                            setDefaultData.filterData.value = IISMethods().encryptDecryptObj(setDefaultData.oldFilterData.value);
                            setDefaultData.filterData.removeNullValues();
                          },
                          height: 50,
                          width: 70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          buttonColor: ColorTheme.kBackGroundGrey,
                          fontColor: ColorTheme.kPrimaryColor,
                          borderRadius: 4,
                          title: StringConst.kResetBtnTxt,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !sizeInformation.isMobile,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 8),
                      child: CustomButton(
                        onTap: () async {
                          setDefaultData.filterData.removeNullValues();
                          setDefaultData.pageNo.value = 1;
                          await onFilterApply();
                          Get.back();
                        },
                        height: 40,
                        width: 70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        buttonColor: ColorTheme.kPrimaryColor,
                        fontColor: ColorTheme.kWhite,
                        borderRadius: 4,
                        title: btnName,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 24, left: 8),
                      child: CustomButton(
                        onTap: () async {
                          setDefaultData.filterData.value = IISMethods().encryptDecryptObj(setDefaultData.oldFilterData.value);
                          setDefaultData.filterData.removeNullValues();
                        },
                        height: 40,
                        width: 70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        buttonColor: ColorTheme.kBackGroundGrey,
                        fontColor: ColorTheme.kPrimaryColor,
                        borderRadius: 4,
                        title: StringConst.kResetBtnTxt,
                      ),
                    ),
                    const Spacer(),
                    Visibility(
                      visible: seeAllFilterButton.value && !isAdvanceEnabled.value,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CustomButton(
                          borderColor: ColorTheme.kBlack,
                          borderWidth: 1,
                          showBoxBorder: false,
                          fontColor: ColorTheme.kBlack,
                          buttonColor: ColorTheme.kWhite,
                          width: 30,
                          borderRadius: 6,
                          title: 'Show Advance Filter',
                          fontSize: 14,
                          fontWeight: FontTheme.notoMedium,
                          onTap: () {
                            isAdvanceEnabled.value = true;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      });
    }

    if (deviceType == DeviceScreenType.mobile) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: ColorTheme.kWhite,
        ),
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        child: filterForm(),
      );
    }

    return Dialog(
      backgroundColor: ColorTheme.kWhite,
      alignment: Alignment.centerRight,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
      insetPadding: EdgeInsets.zero,
      child: Obx(() {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: ColorTheme.kWhite,
          ),
          width: isAdvanceEnabled.value ? 850 : 400,
          child: filterForm(),
        );
      }),
    );
  }

  getMasterData({res}) async {
    if (List<String>.from(res['onchangefill'] ?? []).isNotNullOrEmpty) {
      for (String field in List<String>.from(res['onchangefill'])) {
        {
          var obj = setDefaultData.fieldOrder.firstWhere((element) => element['filterfield'] == field);
          if (obj.isNotNullOrEmpty) {
            Map<String, dynamic> dependentFilter = Map<String, dynamic>.from(obj['dependentfilter'] ?? {});
            var filter = {};
            for (var key in dependentFilter.keys) {
              filter[key] = setDefaultData.filterData[dependentFilter[key]] ?? '';
            }
            Map<String, dynamic> staticFilter = Map<String, dynamic>.from(obj['staticfilter'] ?? {});
            for (var key in staticFilter.keys) {
              filter[key] = staticFilter[key] ?? '';
            }
            setDefaultData.filterData[obj['filterfield']] = null;
            setDefaultData.filterData[obj['formdatafield']] = null;
            var url = Config.weburl + obj["masterdata"];
            var userAction = 'list${obj["masterdata"]}data';
            var reqBody = {
              "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": filter, "projection": {}, "sort": {}}
            };
            var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: setDefaultData.pageName, masterlisting: true);
            var masterDataKey = obj["masterdata"];
            setDefaultData.masterData[masterDataKey] = [];
            for (var data in resBody["data"]) {
              setDefaultData.masterData[masterDataKey].add({"label": data[obj["masterdatafield"]], "value": data["_id"].toString()});
            }
          }
          await getMasterData(res: obj);
        }
      }
    }
  }
}
