import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/controller/layout_templete_controller.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';
import 'package:prestige_prenew_frontend/routes/route_name.dart';
import 'package:prestige_prenew_frontend/style/string_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/filter_button.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_search_box.dart';
import '../../components/customs/drop_down_search_custom.dart';
import '../../components/customs/multi_drop_down_custom.dart';
import '../../components/customs/text_widget.dart';
import '../../components/funtions.dart';
import '../../config/config.dart';
import '../../config/dev/dev_helper.dart';
import '../../config/helper/offline_data.dart';
import '../../config/iis_method.dart';
import '../../config/settings.dart';
import '../../style/assets_string.dart';
import '../../style/theme_const.dart';

RxBool isSearching = false.obs;
Map<int, FocusNode> focusNodes = {};
FocusNode searchFocusNode = FocusNode();

class CommonHeaderFooter extends StatefulWidget {
  const CommonHeaderFooter({
    super.key,
    required this.child,
    required this.title,
    this.hasSearch,
    this.onTapAddNew,
    this.onTapFilter,
    this.onSearch,
    this.actions,
    this.path,
    this.onTapPath,
    this.showFilterInHeader,
    this.setDefaultData,
    this.onFilterInHeaderChange,
    this.headerWidgets,
    this.filterData,
    required this.txtSearchController,
    this.onSearchChange,
    this.addBtnText,
  });

  final Widget child;
  final List<Widget>? actions;
  final Map<String, dynamic>? filterData;
  final String title;
  final String? addBtnText;
  final String? path;
  final bool? hasSearch;

  final bool? showFilterInHeader;
  final Widget? headerWidgets;
  final FormDataModel? setDefaultData;
  final Function()? onTapAddNew;
  final Function()? onFilterInHeaderChange;
  final Function()? onTapFilter;
  final Function()? onTapPath;
  final Function(String)? onSearch;
  final Function(String)? onSearchChange;
  final TextEditingController txtSearchController;

  @override
  State<CommonHeaderFooter> createState() => _CommonHeaderFooterState();
}

class _CommonHeaderFooterState extends State<CommonHeaderFooter> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isSearching.value = false;
      if (!isSearching.value) {
        widget.txtSearchController.text = "";
        if (widget.onSearch != null) {
          widget.onSearch!(widget.txtSearchController.text);
        }
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      // breakpoints: const ScreenBreakpoints(desktop: 850, tablet: 600, watch: 200),
      builder: (context, sizingInformation) {
        return Obx(() {
          return Scaffold(
              backgroundColor: ColorTheme.kScaffoldColor,
              appBar: sizingInformation.isMobile || sizingInformation.isTablet
                  ? AppBar(
                      backgroundColor: ColorTheme.kBlack,
                      automaticallyImplyLeading: !isoffline.value && (sizingInformation.isMobile || sizingInformation.isTablet) && !isSearching.value,
                      foregroundColor: ColorTheme.kWhite,
                      title: !isoffline.value && (widget.hasSearch ?? false) && isSearching.value
                          ? TextFormField(
                              focusNode: searchFocusNode,
                              controller: widget.txtSearchController,
                              autocorrect: true,
                              style: TextStyle(
                                color: ColorTheme.kWhite,
                                fontFamily: FontTheme.themeFontFamily,
                                fontWeight: FontTheme.notoMedium,
                                fontSize: 16,
                              ),
                              onChanged: (value) {
                                if (widget.onSearchChange != null) {
                                  widget.onSearchChange!(value);
                                }
                              },
                              onFieldSubmitted: (value) {
                                if (widget.onSearch != null) {
                                  widget.onSearch!(value);
                                }
                                // Future.delayed(
                                //   const Duration(milliseconds: 300),
                                //   () {
                                //     searchFocusNode.requestFocus(searchFocusNode);
                                //   },
                                // );
                              },
                              textAlign: TextAlign.start,
                              cursorColor: ColorTheme.kWhite,
                              decoration: InputDecoration(
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                filled: false,
                                fillColor: ColorTheme.kBackGroundGrey.withOpacity(0.9),
                                counterText: "",
                                errorStyle: TextStyle(color: ColorTheme.kRed, fontSize: 11, fontFamily: FontTheme.themeFontFamily),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: ColorTheme.kFocusedBorderColor, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: ColorTheme.kBorderColor, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: ColorTheme.kBorderColor, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.all(8),
                                isDense: true,
                                hintText: "Search",
                                suffixIcon: InkResponse(
                                  focusNode: FocusNode(skipTraversal: true),
                                  radius: 7,
                                  onTap: () {
                                    if (widget.onSearch != null) {
                                      widget.onSearch!(widget.txtSearchController.text);
                                    }
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Icon(
                                        Icons.search,
                                        color: ColorTheme.kWhite,
                                      )),
                                ),
                                labelStyle: TextStyle(
                                  fontFamily: FontTheme.themeFontFamily,
                                  fontWeight: FontTheme.notoRegular,
                                  color: ColorTheme.kTextColor,
                                  overflow: TextOverflow.visible,
                                ),
                                hintStyle: TextStyle(
                                  fontFamily: FontTheme.themeFontFamily,
                                  fontWeight: FontTheme.notoRegular,
                                  color: ColorTheme.kBorderColor,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : TextWidget(
                              text: widget.title,
                              color: ColorTheme.kWhite,
                            ),
                      titleSpacing: 0,
                      centerTitle: isoffline.value,
                      actions: isoffline.value
                          ? null
                          : [
                              if (widget.headerWidgets != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: widget.headerWidgets!,
                                ),
                              if (widget.hasSearch ?? false)
                                InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    if (isSearching.value) {
                                      isSearching.value = false;
                                      if (!isSearching.value) {
                                        widget.txtSearchController.text = "";
                                        if (widget.onSearch != null) {
                                          widget.onSearch!(widget.txtSearchController.text);
                                        }
                                      }
                                    } else {
                                      isSearching.value = true;
                                    }
                                  },
                                  child: Obx(() {
                                    return Icon(
                                      isSearching.value ? Icons.close : Icons.search,
                                      color: ColorTheme.kWhite,
                                    );
                                  }).paddingOnly(right: 8),
                                ),
                              if (!isSearching.value) ...(widget.actions ?? [])
                            ],
                      leading: !isoffline.value && sizingInformation.isMobile || sizingInformation.isTablet
                          ? IconButton(
                              onPressed: () {
                                // Get.back();
                                Get.find<LayoutTemplateController>().scaffoldkey.currentState?.openDrawer();
                              },
                              icon: const Icon(Icons.menu))
                          : null,
                    )
                  : null,

              // drawer: sizingInformation.isMobile || sizingInformation.isTablet
              //     ? Drawer(
              //         child: Container(color: ColorTheme.kBlack, child: sideBar(true, true.obs, true, Get.find<LayoutTemplateController>())),
              //       )
              //     : null,
              floatingActionButton: !isoffline.value && sizingInformation.isMobile || sizingInformation.isTablet
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.onTapAddNew != null)
                          FloatingActionButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onPressed: widget.onTapAddNew ?? () {},
                            backgroundColor: ColorTheme.kBlack,
                            child: const Icon(
                              Icons.add,
                              color: ColorTheme.kWhite,
                            ),
                          ).paddingOnly(bottom: sizingInformation.isTablet ? 24 : 4, right: 8),
                        if (widget.onTapFilter != null)
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              FloatingActionButton(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                onPressed: widget.onTapFilter ?? () {},
                                backgroundColor: ColorTheme.kBlack,
                                child: SvgPicture.asset(
                                  AssetsString.kFilter,
                                  colorFilter: const ColorFilter.mode(ColorTheme.kWhite, BlendMode.srcIn),
                                ),
                              ).paddingOnly(right: 8, top: 2),
                              if (widget.filterData.isNotNullOrEmpty)
                                const Positioned(
                                  top: 0,
                                  right: 4,
                                  child: Icon(
                                    Icons.circle,
                                    color: ColorTheme.kSuccessColor,
                                    size: 14,
                                  ),
                                )
                            ],
                          ),
                        // const SizedBox(
                        //   height: 80
                        // )
                      ],
                    )
                  : null,
              body: Center(
                child: (!(sizingInformation.isMobile || sizingInformation.isTablet))
                    ? Container(
                        decoration: BoxDecoration(
                            color: ColorTheme.kWhite,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: ColorTheme.kBorderColor,
                              width: 1,
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isSearching.value) const SizedBox(),
                            headerView(sizingInformation, widget.addBtnText),
                            const Divider(
                              height: 0.1,
                            ),
                            Flexible(
                              child: widget.child,
                            ),
                          ],
                        ),
                      ).paddingAll(24)
                    : Column(
                        children: [
                          syncNowView(),
                          Expanded(
                            child: isoffline.value
                                ? Column(
                                    children: [
                                      Icon(
                                        Icons.wifi_off_rounded,
                                        size: Get.width * 0.5,
                                        color: ColorTheme.kBlack.withOpacity(0.5),
                                      ),
                                      TextWidget(
                                        text: "You are offline.",
                                        color: ColorTheme.kBlack.withOpacity(0.5),
                                        fontSize: Get.width * 0.07,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          navigateTo(RouteNames.kOfflineTenants);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(color: ColorTheme.kBlack, borderRadius: BorderRadius.circular(4)),
                                          child: const TextWidget(
                                            text: "Add tenant in offline",
                                            color: ColorTheme.kWhite,
                                            fontSize: 14,
                                          ).paddingSymmetric(horizontal: 12, vertical: 6),
                                        ).paddingOnly(top: 16),
                                      )
                                    ],
                                  ).paddingOnly(top: Get.height * 0.25)
                                : widget.child,
                          ),
                        ],
                      ),
              ));
        });
      },
    );
  }

  Widget headerView(SizingInformation sizingInformation, String? addBtnText) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Row(
            children: [
              InkWell(
                onTap: widget.onTapPath,
                child: TextWidget(
                  fontSize: 18,
                  color: ColorTheme.kPrimaryColor.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                  text: widget.path ?? "",
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    TextWidget(
                      fontSize: 18,
                      color: ColorTheme.kPrimaryColor,
                      fontWeight: FontWeight.w500,
                      text: widget.title,
                    ),
                    if (widget.showFilterInHeader == true)
                      Expanded(
                        child: Visibility(
                          visible: (widget.showFilterInHeader ?? false),
                          child: Wrap(
                            children: [
                              ...List.generate((widget.setDefaultData?.fieldOrder ?? []).length, (i) {
                                Map<String, dynamic> res = widget.setDefaultData?.fieldOrder[i] ?? {};
                                var focusOrderCode = generateUniqueFieldId(0, i, null, null);
                                if (!focusNodes.containsKey(focusOrderCode)) {
                                  focusNodes[focusOrderCode] = FocusNode();
                                }
                                if (res['filter'] != 1 || res['enableheraderfilter'] == 0) {
                                  return const SizedBox.shrink();
                                }
                                switch (res["filterfieldtype"]) {
                                  case HtmlControls.kDropDown:
                                    return Obx(() {
                                      var masterdatakey = res["masterdata"] ?? '';
                                      var list = IISMethods().encryptDecryptObj(widget.setDefaultData?.masterData[masterdatakey] ?? []);
                                      return constrainedBoxWithPadding(
                                          width: 200,
                                          child: DropDownSearchCustom(
                                            width: 200,
                                            focusNode: focusNodes[focusOrderCode],
                                            dropValidator: (p0) {
                                              return null;
                                            },
                                            hintColor: ColorTheme.kBlack,
                                            borderColor: ColorTheme.kBlack,
                                            // borderWidth: 1.25,
                                            isSearchable: true,
                                            isCleanable: res['cleanable'] != false,
                                            clickOnCleanBtn: () async {
                                              widget.setDefaultData?.filterData[res['filterfield']] = null;
                                              widget.setDefaultData?.filterData[res['formdatafield']] = null;
                                              await getMasterData(res: res);
                                              if (widget.onFilterInHeaderChange != null) {
                                                widget.onFilterInHeaderChange!();
                                              }
                                            },
                                            // hintColor: ColorTheme.kBlack,
                                            // borderColor: ColorTheme.kHeaderFieldBorderColor,
                                            items: List<Map<String, dynamic>>.from(list ?? []),
                                            // textFieldLabel: res["text"],
                                            hintText: "Select ${res["text"]}",
                                            buttonText: res["text"],
                                            initValue: (list ?? []).where((element) => element["value"] == widget.setDefaultData?.filterData[res["filterfield"]]).toList().isNotEmpty
                                                ? list.where((element) => element["value"] == widget.setDefaultData?.filterData[res["filterfield"]]).toList()?.first ?? {}
                                                : null,
                                            onChanged: (v) async {
                                              widget.setDefaultData?.filterData[res['filterfield']] = v?['value'];
                                              widget.setDefaultData?.filterData[res['formdatafield']] = v?['label'];
                                              if (widget.onFilterInHeaderChange != null) {
                                                widget.onFilterInHeaderChange!();
                                              }
                                              await getMasterData(res: res);
                                            },
                                          ));
                                    });
                                  case HtmlControls.kMultiSelectDropDown:
                                    var masterdatakey = res["masterdata"] /*?? res?["storemasterdatabyfield"] == true || res?['inPageMasterData'] == true ? res["field"] : res["masterdata"]*/;
                                    return Obx(() {
                                      return constrainedBoxWithPadding(
                                        width: 200,
                                        child: MultiDropDownSearchCustom(
                                          selectedItems: List<Map<String, dynamic>>.from(List<Map<String, dynamic>>.from(widget.setDefaultData?.masterData[masterdatakey] ?? []).map((e) => <String, dynamic>{
                                                res["filterfield"]: e['label'],
                                                '${res["filterfield"]}id': e['value'],
                                              })).where((element) {
                                            try {
                                              return (widget.setDefaultData?.filterData[res['filterfield']] as List?)?.contains(element['${res["filterfield"]}id']) ?? false;
                                            } catch (e) {
                                              devPrint('ERROR --->${(widget.setDefaultData?.filterData[res['filterfield']])}');
                                              return false;
                                            }
                                          }).toList(),
                                          field: res["filterfield"],
                                          width: 200,
                                          focusNode: focusNodes[focusOrderCode],
                                          borderColor: ColorTheme.kBlack,
                                          hintColor: ColorTheme.kBlack,
                                          dropValidator: (p0) {
                                            return null;
                                          },
                                          items: List<Map<String, dynamic>>.from(widget.setDefaultData?.masterData[masterdatakey] ?? []),
                                          // initValue: ((widget.setDefaultData?.filterData[res["filterfield"]] ?? []) as List?).isNullOrEmpty ? null : widget.setDefaultData?.filterData[res["filterfield"]]?.last,
                                          isRequire: res["required"],
                                          // textFieldLabel: res["text"],
                                          hintText: "Select ${res["text"]}",
                                          isCleanable: true,
                                          buttonText: res["text"],
                                          clickOnCleanBtn: () async {
                                            widget.setDefaultData?.filterData[res['filterfield']] = [];
                                            widget.setDefaultData?.filterData.removeNullValues();
                                            if (widget.onFilterInHeaderChange != null) {
                                              widget.onFilterInHeaderChange!();
                                            }
                                            await getMasterData(res: res);
                                          },
                                          isSearchable: res["searchable"],
                                          onChanged: (v) async {
                                            widget.setDefaultData?.filterData[res['filterfield']] = v;
                                            widget.setDefaultData?.filterData.removeNullValues();
                                            devPrint(widget.setDefaultData?.filterData[res['filterfield']]);
                                            if (widget.onFilterInHeaderChange != null) {
                                              widget.onFilterInHeaderChange!();
                                            }
                                            await getMasterData(res: res);
                                          },
                                        ),
                                      );
                                    });
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                        ),
                      ),
                    if (widget.headerWidgets != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: widget.headerWidgets!,
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (widget.hasSearch ?? false)
                    SearchBox(
                      txtSearch: widget.txtSearchController,
                      // focusNode: searchFocusNode,
                      onSearch: (p1) {
                        if (widget.onSearch != null) {
                          widget.onSearch!(p1);
                        }
                        // Future.delayed(
                        //   const Duration(milliseconds: 500),
                        //   () {
                        //     searchFocusNode.requestFocus();
                        //   },
                        // );
                      },
                      isSearching: isSearching.value,
                      onTap: () {
                        isSearching.value = false;
                        widget.txtSearchController.text = "";
                        if (!isSearching.value) {
                          if (widget.onSearch != null) {
                            widget.onSearch!(widget.txtSearchController.text);
                          }
                        }
                      },
                      onChanged: (value) {
                        value.isNullOrEmpty ? widget.onSearch!(widget.txtSearchController.text) : null;
                        isSearching.value = value.isNotNullOrEmpty;
                        if (widget.onSearchChange != null) {
                          widget.onSearchChange!(value);
                        }
                      },
                    ),
                  const SizedBox(
                    width: 12,
                  ),
                  ...(widget.actions ?? []),
                  if (widget.onTapFilter != null)
                    fltButton(onTap: widget.onTapFilter, filterData: widget.filterData).paddingOnly(
                      right: 12,
                    ),
                  if (widget.onTapAddNew != null)
                    CustomButton(
                      onTap: widget.onTapAddNew,
                      width: 135,
                      fontSize: 14,
                      borderRadius: 4,
                      height: 40,
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            color: ColorTheme.kWhite,
                          ).paddingOnly(right: 8),
                          TextWidget(
                            text: addBtnText ?? StringConst.kAddNewBtnTxt,
                            fontSize: 13,
                            fontWeight: FontTheme.notoRegular,
                            color: ColorTheme.kWhite,
                          ),
                        ],
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  getMasterData({res}) async {
    if (List<String>.from(res['onchangefill'] ?? []).isNotNullOrEmpty) {
      for (String field in List<String>.from(res['onchangefill'])) {
        {
          var obj = widget.setDefaultData?.fieldOrder.firstWhere((element) => element['filterfield'] == field) ?? {};
          if (obj.isNotNullOrEmpty) {
            Map<String, dynamic> dependentFilter = Map<String, dynamic>.from(obj['dependentfilter'] ?? {});
            var filter = {};
            for (var key in dependentFilter.keys) {
              filter[key] = widget.setDefaultData?.filterData[dependentFilter[key]] ?? '';
            }
            Map<String, dynamic> staticFilter = Map<String, dynamic>.from(obj['staticfilter'] ?? {});
            for (var key in staticFilter.keys) {
              filter[key] = staticFilter[key] ?? '';
            }
            widget.setDefaultData?.filterData[obj['filterfield']] = null;
            widget.setDefaultData?.filterData[obj['formdatafield']] = null;
            var url = Config.weburl + obj["masterdata"];
            var userAction = 'list${obj["masterdata"]}data';
            var reqBody = {
              "paginationinfo": {"pageno": 1, "pagelimit": 500000000000, "filter": filter, "projection": {}, "sort": {}}
            };
            var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: widget.setDefaultData!.pageName, masterlisting: true);
            var masterDataKey = obj["masterdata"];
            widget.setDefaultData?.masterData[masterDataKey] = [];
            for (var data in resBody["data"]) {
              widget.setDefaultData?.masterData[masterDataKey].add({"label": data[obj["masterdatafield"]], "value": data["_id"].toString()});
            }
          }
          await getMasterData(res: obj);
        }
      }
    }
  }
}

Widget syncNowView() {
  return Obx(() {
    if (!isoffline.value && Settings.offlineTenantDataList.isNotNullOrEmpty) {
      return InkWell(
        onTap: () {
          if (!isUploading.value) navigateTo(RouteNames.kOfflineTenants);
        },
        child: Container(
          color: ColorTheme.kGreen,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: TextWidget(
                text: "${Settings.offlineTenantDataList.length} tenant details to sync.",
                fontSize: 16,
                color: const Color(0xFF155724),
              ).paddingAll(6)),
              InkWell(
                onTap: () {
                  if (!isUploading.value) Offline().syncTenantsData();
                },
                child: Container(
                  decoration: BoxDecoration(color: ColorTheme.kBlack, borderRadius: BorderRadius.circular(4)),
                  child: isUploading.value
                      ? const CupertinoActivityIndicator(
                          color: ColorTheme.kWhite,
                        ).paddingAll(8)
                      : const TextWidget(
                          text: "Sync Now",
                          color: ColorTheme.kWhite,
                          fontSize: 14,
                        ).paddingSymmetric(horizontal: 12, vertical: 6),
                ).paddingAll(6),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  });
}
