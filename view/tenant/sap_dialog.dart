import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';
import 'package:prestige_prenew_frontend/view/tenant/rent_history_dialog.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../components/customs/custom_button.dart';
import '../../components/customs/custom_dialogs.dart';
import '../../controller/layout_templete_controller.dart';
import '../../models/form_data_model.dart';
import '../../style/assets_string.dart';
import '../../style/string_const.dart';
import '../../style/theme_const.dart';
import '../user_role_hierarchy/member_show.dart';

class SapDialog extends StatelessWidget {
  final RxList<Map<String, dynamic>> fieldOrder;
  final RxList<Map<String, dynamic>> data;
  final Map<String, dynamic> rentMap;
  final RxBool isLoading;
  final FormDataModel setDefaultData;
  final Function()? onSubmitToSAP;
  final RxInt stage;
  final String title;

  const SapDialog({super.key, required this.fieldOrder, required this.data, required this.isLoading, required this.setDefaultData, required this.rentMap, this.onSubmitToSAP, required this.stage, required this.title});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        // List<Map<String, dynamic>> activeFieldOrder = fieldOrder.where((field) => field['active'] == 1).toList();
        // double totalColumnWidth = activeFieldOrder.fold(0, (sum, field) => sum + (field['tblsize'] * 20));

        //
        // RxDouble columnWidth = (0.0).obs;
        // if (availableWidth > totalColumnWidth) {
        //   columnWidth.value = availableWidth / activeFieldOrder.length;
        // } else {
        //   columnWidth.value = (activeFieldOrder[0]['tblsize']) * 20;
        // }

        return Obx(() {
          double availableWidth = (sizingInformation.isMobile ? MediaQuery.sizeOf(context).width : MediaQuery.sizeOf(context).width - globalTableWidth.value);
          double totalFlex = 0;
          double totalFix = 0;
          const double srNoWidth = 0;
          List<Map<String, dynamic>> activeFieldOrder = fieldOrder.where((element) => element['active'] == 1.0).toList();

          for (var element in activeFieldOrder) {
            if (element['disableflex'] == 1) {
              totalFix += (element['tblsize'] ?? 20);
            } else {
              totalFlex += (element['tblsize'] ?? 20);
            }
          }
          double ratio = 1;
          if (totalFlex * 10 < (availableWidth - srNoWidth - totalFix)) {
            ratio = (availableWidth - srNoWidth - totalFix) / (totalFlex * 10);
          }
          Map<int, TableColumnWidth> sizeMap = Map.from(
            // field.map((element) => FixedColumnWidth((element['tblsize'] ?? 20).toString().converttoInt * ((element['disableflex']).toString().converttoInt == 1 ? 1 : 10 * ratio))).toList().asMap(),
            activeFieldOrder.map((element) => FixedColumnWidth(((element['tblsize'] ?? 20) * (element['disableflex'] == 1 ? 1 : 10 * ratio)).toDouble())).toList().asMap(),
          );
          List<TableColumnWidth> temp = [];
          sizeMap.forEach((key, value) {
            temp.add(value);
          });
          // temp.insert(0, const FixedColumnWidth(srNoWidth));
          sizeMap = temp.asMap();
          return Dialog(
            surfaceTintColor: ColorTheme.kWhite,
            backgroundColor: ColorTheme.kWhite,
            alignment: Alignment.topRight,
            insetPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: SizedBox(
              child: Column(
                children: [
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextWidget(
                          text: "$title Primary Details ${getDeviceType(MediaQuery.sizeOf(context)) == DeviceScreenType.mobile ? '\n' : ''}(${data.length} $title Selected)",
                          fontSize: 16,
                          textAlign: TextAlign.left,
                          color: ColorTheme.kBlack,
                          fontWeight: FontTheme.notoSemiBold,
                        ).paddingOnly(left: 4),
                      ),
                      CustomButton(
                        width: 30,
                        height: 40,
                        borderRadius: 4,
                        onTap: () {
                          exportExcelData();
                        },
                        buttonColor: ColorTheme.kBackGroundGrey,
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                        widget: Row(
                          children: [
                            SvgPicture.asset(
                              AssetsString.kExport,
                              colorFilter: const ColorFilter.mode(ColorTheme.kBlack, BlendMode.srcIn),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const TextWidget(
                              text: StringConst.kExportBtnTxt,
                              fontSize: 13,
                              fontWeight: FontTheme.notoSemiBold,
                              color: ColorTheme.kBlack,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        padding: EdgeInsets.zero,
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
                          icon: const Icon(Icons.clear_rounded),
                        ),
                      ),
                    ],
                  ).paddingAll(20),
                  // const SizedBox(height: 8),
                  // Expanded(
                  //   child: Obx(() {
                  //     return CommonDataTableWidget(
                  //         setDefaultData: setDefaultData,
                  //         width: Get.width,
                  //         showPagination: false,
                  //         isLoading: isLoading.value,
                  //         fieldOrder: fieldOrder,
                  //         rentDataFun: (id, index, field, type, listData) {
                  //           jsonPrint(tag: "56461531563415695626", List<Map<String, dynamic>>.from(data)[index][listData]);
                  //           CustomDialogs().customFilterDialogs(
                  //               context: Get.context!,
                  //               widget: InfoForm(
                  //                 widthOfDialog: 500,
                  //                 infoPopUpWidget: RentHistoryDialog(data: List<Map<String, dynamic>>.from(data)[index][listData] ?? []),
                  //                 isHeaderShow: false,
                  //               ));
                  //         },
                  //         data: data,
                  //         tableScrollController: null);
                  //   }),
                  // ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: ColorTheme.kBorderColor, width: 1), borderRadius: BorderRadius.circular(4)),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              Table(
                                // textDirection: TextDirection.LTR,
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                columnWidths: sizeMap,
                                children: [
                                  TableRow(
                                    decoration: const BoxDecoration(color: ColorTheme.kTableHeader),
                                    children: [
                                      ...List.generate(
                                        activeFieldOrder.length,
                                        (index) {
                                          return TableCell(child: TextWidget(text: "${activeFieldOrder[index]['text']}", fontSize: 14, fontWeight: FontTheme.notoSemiBold).paddingSymmetric(vertical: 8, horizontal: 4));
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Obx(() {
                                return Expanded(
                                  child: SingleChildScrollView(
                                    child: Table(
                                      // textDirection: TextDirection.LTR,
                                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                      columnWidths: sizeMap,
                                      children: [
                                        ...List.generate(
                                          data.length,
                                          (mainIndex) {
                                            return TableRow(
                                              decoration: BoxDecoration(
                                                color: /* data[mainIndex]['iserror'] == true
                                                    ? ColorTheme.kRedError
                                                    :*/
                                                    mainIndex % 2 == 0 ? ColorTheme.kWhite : ColorTheme.kBlack.withOpacity(0.03), // Alternate row colors
                                              ),
                                              children: [
                                                ...List.generate(
                                                  activeFieldOrder.length,
                                                  (index) {
                                                    // if (activeFieldOrder[index]['type'] == 'rent-details') {
                                                    //   num sum = 0;
                                                    //   for(var i in data[mainIndex][[activeFieldOrder][index] ?? []){
                                                    //
                                                    //   }
                                                    //   // final rentList = data[mainIndex][activeFieldOrder[index]['field']?['sum']] ?? "";
                                                    //   // for (var item in rentList) {
                                                    //   //   if (item['totalrent'] != null) {
                                                    //   //     sum += item['totalrent'];
                                                    //   //   }
                                                    //   // }
                                                    //   jsonPrint(tag: "87654218645846514865", sum);
                                                    // }
                                                    // // activeFieldOrder[index]['type'] == 'rent-details' ? devPrint("kbedfjbvnukdsjnv86451      ${List<Map<String, dynamic>>.from(data)[mainIndex][activeFieldOrder[index]['field']?['sum']].toString()}") : null;
                                                    if (activeFieldOrder[index]['type'] == 'bullet') {
                                                      return TableCell(
                                                          child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          ...List.generate(
                                                            (data[mainIndex][activeFieldOrder[index]['field']] ?? []).length,
                                                            (fieldindex) {
                                                              return Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
                                                                    child: Icon(
                                                                      (data[mainIndex][activeFieldOrder[index]['field']] ?? [])[fieldindex]['iserror'] == 0
                                                                          ? Icons.error_outline_rounded
                                                                          : (data[mainIndex][activeFieldOrder[index]['field']] ?? [])[fieldindex]['iserror'] == 1
                                                                              ? Icons.check_circle_outline_rounded
                                                                              : Icons.warning_amber_rounded,
                                                                      color: (data[mainIndex][activeFieldOrder[index]['field']] ?? [])[fieldindex]['iserror'] == 0
                                                                          ? ColorTheme.kErrorColor
                                                                          : (data[mainIndex][activeFieldOrder[index]['field']] ?? [])[fieldindex]['iserror'] == 1
                                                                              ? ColorTheme.kSuccessColor
                                                                              : ColorTheme.kWarnColor,
                                                                      size: 18,
                                                                    ),
                                                                  ).marginOnly(top: 1.6),
                                                                  Expanded(
                                                                    child: TextWidget(
                                                                      text: "${(data[mainIndex][activeFieldOrder[index]['field']] ?? [])[fieldindex]['message']}".toDateFormat(),
                                                                      fontSize: 14,
                                                                      color: (data[mainIndex][activeFieldOrder[index]['field']] ?? [])[fieldindex]['iserror'] == 0
                                                                          ? ColorTheme.kErrorColor
                                                                          : (data[mainIndex][activeFieldOrder[index]['field']] ?? [])[fieldindex]['iserror'] == 1
                                                                              ? ColorTheme.kSuccessColor
                                                                              : ColorTheme.kWarnColor,
                                                                      fontWeight: FontTheme.notoRegular,
                                                                    ).paddingSymmetric(vertical: 4, horizontal: 4),
                                                                  )
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ));
                                                    }
                                                    return activeFieldOrder[index]['type'] == 'rent-details'
                                                        ? TableCell(
                                                            child: InkWell(
                                                            splashColor: Colors.transparent,
                                                            hoverColor: Colors.transparent,
                                                            focusColor: Colors.transparent,
                                                            highlightColor: Colors.transparent,
                                                            overlayColor: WidgetStateColor.transparent,
                                                            onTap: /*(((data[mainIndex])[activeFieldOrder[index]['field']?['list']]).toString().isNullOrEmpty)
                                                          ? null
                                                          :*/
                                                                () {
                                                              jsonPrint(tag: "56461531563415695626", data);
                                                              CustomDialogs().customFilterDialogs(
                                                                  context: Get.context!,
                                                                  widget: InfoForm(
                                                                    widthOfDialog: 500,
                                                                    infoPopUpWidget: RentHistoryDialog(data: List<Map<String, dynamic>>.from(data)[mainIndex][activeFieldOrder[index]['field']?['list']] ?? []),
                                                                    isHeaderShow: false,
                                                                  ));
                                                            },
                                                            child: Wrap(
                                                              children: [
                                                                TextWidget(
                                                                  text: "${data[mainIndex][activeFieldOrder[index]['field']?['sum']]}".toString().toAmount(),
                                                                  fontSize: 14,
                                                                  fontWeight: FontTheme.notoRegular,
                                                                  textOverflow: TextOverflow.visible,
                                                                ).paddingOnly(right: 4),
                                                                const Icon(Icons.info_outline_rounded, size: 18)
                                                              ],
                                                            ),
                                                          ).paddingSymmetric(vertical: 8, horizontal: 4))
                                                        : TableCell(
                                                            child: TextWidget(text: "${data[mainIndex][activeFieldOrder[index]['field']]}".toDateFormat(), fontSize: 14, fontWeight: FontTheme.notoRegular).paddingSymmetric(vertical: 8, horizontal: 4));
                                                  },
                                                ),
                                                // ...List.generate(
                                                //   tenantRentDataList[0].length,
                                                //       (index) => TableCell(child: TextWidget(text: "${tenantRentDataList[0][index]['paymenttypename']}", fontSize: 14, fontWeight: FontTheme.notoRegular).paddingSymmetric(vertical: 8, horizontal: 4)),
                                                // ),
                                              ],
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              if (rentMap.isNotNullOrEmpty)
                                Table(
                                  // textDirection: TextDirection.LTR,
                                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                  columnWidths: sizeMap,
                                  // border: const TableBorder.symmetric(outside: BorderSide(width: 2, color: ColorTheme.kTableHeader)),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(color: ColorTheme.kTableHeader),
                                      children: [
                                        ...List.generate(
                                          activeFieldOrder.length,
                                          (index) {
                                            return activeFieldOrder[index]['type'] == 'rent-details'
                                                ? TableCell(
                                                    child: TextWidget(
                                                    text: "${rentMap[activeFieldOrder[index]['field']?['total']]}".toString().toAmount(),
                                                    fontSize: 14,
                                                    fontWeight: FontTheme.notoRegular,
                                                    textOverflow: TextOverflow.visible,
                                                  ).paddingSymmetric(vertical: 8, horizontal: 4))
                                                : TableCell(child: const TextWidget(text: "", fontSize: 14).paddingSymmetric(vertical: 8, horizontal: 4));
                                          },
                                        ),
                                        // ...List.generate(
                                        //   tenantRentDataList[0].length,
                                        //       (index) => TableCell(child: TextWidget(text: "${tenantRentDataList[0][index]['paymenttypename']}", fontSize: 14, fontWeight: FontTheme.notoRegular).paddingSymmetric(vertical: 8, horizontal: 4)),
                                        // ),
                                      ],
                                    )
                                  ],
                                ),
                            ],
                          )),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (stage.value == 0)
                        CustomButton(
                          title: 'Submit to SAP',
                          buttonColor: ColorTheme.kBlack,
                          fontColor: ColorTheme.kWhite,
                          // showBoxBorder: true,
                          height: 34,
                          width: 80,
                          borderRadius: 5,
                          onTap: onSubmitToSAP,
                        )
                      else
                        CustomButton(
                          title: 'Close',
                          buttonColor: ColorTheme.kBackGroundGrey,
                          fontColor: ColorTheme.kPrimaryColor,
                          // showBoxBorder: true,
                          height: 34,
                          width: 80,
                          borderRadius: 5,
                          onTap: () {
                            Get.back();
                          },
                        ),
                    ],
                  ).paddingAll(20),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  exportExcelData() async {
    List<Map<String, dynamic>> fieldOrder = List<Map<String, dynamic>>.from(IISMethods().encryptDecryptObj(this.fieldOrder.value));
    final excel = Excel.createExcel();
    String pagename = '$title Submit To Sap';

    final sheet = excel['$title Submit To Sap'];
    excel.setDefaultSheet('$title Submit To Sap');
    excel.delete('Sheet1');
    // var boldStyle = CellStyle(
    //   bold: true,
    //   fontSize: 18,
    // );
    fieldOrder.retainWhere(
      (element) {
        return element['active'] == 1;
      },
    );
    sheet.appendRow(fieldOrder.map((e) => TextCellValue(e['text'] ?? '')).toList());

    for (int rowIndex = 0; rowIndex < setDefaultData.data.length; rowIndex++) {
      Map<String, dynamic> data = setDefaultData.data[rowIndex];
      for (int columnIndex = 0; columnIndex < fieldOrder.length; columnIndex++) {
        CellValue cellValue = const TextCellValue('');
        Map<String, dynamic> field = fieldOrder[columnIndex];
        Data cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: rowIndex + 1));
        if (field['type'] == 'bullet') {
          cell.value = TextCellValue((((data[field['field']] ?? []) as List).map(
            (e) {
              return e['message'];
            },
          ).join('\n'))
              .toString()
              .toDateFormat());
          cell.cellStyle = CellStyle(
            textWrapping: TextWrapping.WrapText,
          );
          sheet.setRowHeight(rowIndex + 1, ((data[field['field']] ?? []) as List).length * 12);
        } else if (field['type'] == 'rent-details') {
          cell.value = TextCellValue((data[field['field']?['sum'] ?? ''] ?? '').toString().toAmount());
          cell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right);
        } else {
          cell.value = TextCellValue((data[field['field'] ?? ''] ?? '').toString().toDateFormat());
        }
      }
    }
    sheet.appendRow(fieldOrder.map((e) {
      if (e['type'] == 'rent-details') {
        return TextCellValue((rentMap[e['field']?['total'] ?? ''] ?? '').toString().toAmount());
      }
      return const TextCellValue((''));
    }).toList());
    for (int i = 0; i < fieldOrder.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: sheet.maxRows - 1)).cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Right, bold: true);
    }

    // for (int i = 0; i < fieldOrder.length; i++) {
    //   sheet.setColumnAutoFit(i);
    // }

    if (kIsWeb) {
      excel.save(fileName: '$pagename-${DateTime.now()}.xlsx');
    } else {
      Permission.manageExternalStorage.request();

      var fileBytes = excel.save();
      var directory = Platform.isAndroid ? await getDownloadsDirectory() : await getApplicationDocumentsDirectory();
      devPrint(directory?.path);
      File savedFile = File('${directory?.path}/$pagename-${DateTime.now()}.xlsx');
      await savedFile.writeAsBytes(fileBytes!);
      OpenFile.open(savedFile.path);
    }
  }
}
