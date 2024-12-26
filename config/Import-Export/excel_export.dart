import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/models/form_data_model.dart';

import '../config.dart';
import '../iis_method.dart';

class ExcelExport {
  String pagename = '';
  // FormDataModel setDefaultData = FormDataModel();

  Future<void> exportData({required Map<dynamic, dynamic> dialogBoxData, String? pageName, required String formName, required Map<String, dynamic> filter, required FormDataModel setDefaultData}) async {
    pagename = pageName ?? '';
    // setDefaultData = setdefaultdata ?? FormDataModel();
    if (pagename != 'tenant') {
      dialogBoxData['tabs'] = [{}];
      dialogBoxData['tabs'][0]['formfields'] = dialogBoxData['formfields'];
    }
    List<Map<String, dynamic>> fieldorder = [];
    for (var tabs in dialogBoxData['tabs']) {
      for (var formFields in tabs['formfields']) {
        for (var field in formFields['formFields']) {
          int index = fieldorder.indexWhere(
            (element) {
              return element['text'] == field['text'];
            },
          );
          if (index != -1) continue;
          {
            if (field['field'] == 'status') {
              jsonPrint(field, tag: "856489654986548645");
            }
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
                  'type': HtmlControls.kDropDown,
                };
                int index = fieldorder.indexWhere((element) => element['field'] == fieldData['formdatafield']);
                if (index == -1) {
                  fieldorder.add(fieldData);
                }

              default:
                Map<String, dynamic> fieldData = {
                  'text': field['text'],
                  'field': field['field'],
                  'tblsize': field['gridsize'] / 20,
                  'active': 1,
                  'type': field['type'],
                };

                int index = fieldorder.indexWhere((element) => element['field'] == fieldData['field']);
                if (index == -1) {
                  fieldorder.add(fieldData);
                }
            }
          }
        }
      }
    }
    Map<String, dynamic> temp = {};
    for (var entry in filter.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value.toString().isNotNullOrEmpty) {
        temp[key] = value;
      }
    }

    Map<String, dynamic> reqBody = {
      'searchtext': '',
      'paginationinfo': {
        'pageno': 1,
        'pagelimit': 1000000000000000000,
        'filter': temp,
        'sort': {},
      },
    };
    final url = Config.weburl + (pageName ?? '');
    final userAction = "list${pageName ?? ''}";
    var resBody = await IISMethods().listData(url: url, reqBody: reqBody, userAction: userAction, pageName: pageName ?? '');
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(resBody['data']);
    final excel = Excel.createExcel();

    ///ADD SHEET DATA TO EXCEL
    final sheet = excel[formName];
    excel.setDefaultSheet(formName);
    excel.delete('Sheet1');

    sheet.appendRow(fieldorder.map((e) => TextCellValue(e['text'] ?? '')).toList());
    for (var data in data) {
      sheet.appendRow(fieldorder.map((e) {
        if (e['field'] == 'status') {
          return TextCellValue(
              data[e['field']] == 1 ? 'Active' : 'Inactive'
          );
        }
        switch (e['type']) {
          case HtmlControls.kMultiSelectDropDown:
            return TextCellValue(((data[e['field']] ?? []) as List).map((obj) => obj[e['field']]).toList().join(', '));
          case HtmlControls.kMultipleContactSelection:
            return TextCellValue(((data[e['field']] ?? []) as List).join(', '));
          default:
            return TextCellValue(data[e['field']].toString().toDateFormat(format: 'yMd'));
        }
      }).toList());
    }
    for (int i = 0; i < sheet.maxColumns; i++) {
      sheet.setColumnAutoFit(i);
    }

    ///ADD SHEET DATA TO EXCEL
    ///ADD FILTER SHEET TO EXCEL

    final sheet2 = excel['Filter'];
    List<Map<String, dynamic>> filterFields = setDefaultData.fieldOrder.where(
      (p0) {
        return p0['filter'] == 1;
      },
    ).toList();
    for (int columnIndex = 0; columnIndex < filterFields.length; columnIndex++) {
      {
        var fields = filterFields[columnIndex];
        if (setDefaultData.filterData[fields['filterfield'] ?? ''] == null) {
          continue;
        }
        sheet2.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0)).value = TextCellValue(fields['text']);
        switch (fields['filterfieldtype']) {
          case HtmlControls.kDropDown:
            devPrint(fields['formdatafield']);
            devPrint(setDefaultData.masterData);
            // try{
            // if (fields.containsKey('masterdataarray')) {
            if (setDefaultData.filterData[fields['filterfield']].toString().isNotNullOrEmpty) {
              String value = (setDefaultData.masterData[fields['masterdata']]).firstWhere(
                (element) {
                  devPrint(element['value'] == setDefaultData.filterData[fields['filterfield']]);
                  return element['value'] == setDefaultData.filterData[fields['filterfield']];
                },
                orElse: () {
                  return {};
                },
              )['label'].toString();
              sheet2.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 1)).value = TextCellValue(value);
            }
            break;
          // } else {
          //   sheet2.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 1)).value = TextCellValue(setDefaultData.filterData[fields['formdatafield'] ?? ''] ?? '');
          // }
          // }catch(e){}
          case HtmlControls.kMultiSelectDropDown:
            List filterValues = List<Map<String, dynamic>>.from(List<Map<String, dynamic>>.from(setDefaultData.masterData[fields["masterdata"]] ?? []))
                .where((element) {
                  try {
                    return (setDefaultData.filterData[fields['filterfield']] as List?)?.contains(element['value']) ?? false;
                  } catch (e) {
                    return false;
                  }
                })
                .toList()
                .map(
                  (e) {
                    return e['label'];
                  },
                )
                .toList();
            devPrint(filterValues);
            for (int rowIndex = 0; rowIndex < filterValues.length; rowIndex++) {
              sheet2.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: rowIndex + 1)).value = TextCellValue(filterValues[rowIndex]);
            }
            break;
          default:
            sheet2.cell(CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 1)).value = TextCellValue(setDefaultData.filterData[fields['filterfield']].toString().toDateFormat());
            break;
        }
      }
    }
    for (int i = 0; i < sheet2.maxColumns; i++) {
      sheet2.setColumnAutoFit(i);
    }

    ///ADD FILTER SHEET TO EXCEL

    if (kIsWeb) {
      excel.save(fileName: '$pagename-${DateTime.now()}.xlsx');
    } else {
      Permission.manageExternalStorage.request();

      var fileBytes = excel.save();
      var directory = Platform.isAndroid ? await getDownloadsDirectory() : await getApplicationDocumentsDirectory();

      devPrint(directory?.path);

      File savedFile = File('${directory?.path}/$pagename-${DateTime.now().toIso8601String()}.xlsx');
      await savedFile.writeAsBytes(fileBytes!);

      devPrint("=============> ${savedFile.path}");
      OpenFile.open(savedFile.path);
    }
  }
}
