import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_date_picker.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/config.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/utils/aws_service/file_data_model.dart';
import 'package:url_launcher/link.dart';

import 'customs/custom_date_range_picker.dart';

Map<String, dynamic> getObjectFromFormData(formData, String field) {
  Map<String, dynamic> object = {};
  for (var data in formData) {
    if (object.isEmpty) {
      data["formFields"].forEach((e) {
        if (e['field'] == field) {
          object.addAll(e);
        }
      });
    } else {
      object = object;
    }
  }
  return object;
}

Map<String, dynamic> getFilterData(data, String field) {
  Map<String, dynamic> object = {};

  data[""].forEach((e) {
    if (e['outsidefilterfields'] == field) {
      object.addAll(e);
    }
  });

  return object;
}

openBrowserContextMenu({alias, child}) {
  if (alias.toString().isNullOrEmpty) {
    return child;
  }
  return Link(
    uri: Uri.parse("${kDebugMode ? "http://${Uri.base.authority}" : ""}/$alias"),
    builder: (context, followLink) => child,
  );
}

Widget linkBuilder({uri, child}) {
  return Link(
    uri: Uri.parse(uri),
    builder: (context, followLink) => child,
  );
}

validationForm({
  formData,
  validation,
  key,
  tableField,
  isTableVal = false,
}) {
  var hasError = false;
  var message = "";
  var validationTemp = {};
  if (key != null) {
    var value = formData[key];
    validation = getObjectFromFormData(validation, key);
    if (validation["required"] && !validation.containsKey("istablefield") && validation?['defaultvisibility'] == true) {
      switch (validation['type']) {
        case HtmlControls.kInputText:
        case HtmlControls.kNumberInput:
        case HtmlControls.kRadio:
        case HtmlControls.kPassword:
        case HtmlControls.kInputTextArea:
          try {
            value as String;
            if (value.isNullOrEmpty) {
              hasError = value.isNullOrEmpty;
              message = "Please Enter a ${validation["text"]}";
            } else if (validation.containsKey('regex')) {
              hasError = !RegExp(validation['regex']).hasMatch(value);
              message = "Please Enter a valid ${validation["text"]}";
            } else if (validation.containsKey('minvalue')) {
              hasError = double.parse(value) < validation['minvalue'];
            } else if (validation.containsKey('maxvalue')) {
              hasError = double.parse(value) > validation['maxvalue'];
            } else if (validation.containsKey('minlength')) {
              devPrint(' --> MIN VALUE ERROR CALLED');
              hasError = value.length < validation['minlength'];
            } else if (validation.containsKey('maxlength')) {
              hasError = value.length > validation['maxlength'];
            } else if (validation.containsKey('shouldgreaterthan')) {
              hasError = double.parse(value) <= double.parse(formData[validation['shouldgreaterthan']]);
            }
          } catch (e) {
            hasError = true;
          }
        case HtmlControls.kDropDown:
          try {
            hasError = value == null || value.toString().isEmpty;
            message = "Please Select a ${validation["text"]}";
          } catch (e) {
            hasError = true;
            message = "Please Select a ${validation["text"]}";
          }
        case HtmlControls.kMultiSelectDropDown:
        case HtmlControls.kDateRangePicker:
        case HtmlControls.kTimeRangePicker:
          value as List;
          try {
            hasError = value.isEmpty;
            hasError = (value.isEmpty && validation['required']);
            hasError = (value.isNotEmpty || validation['required']);
          } catch (e) {
            hasError = validation['required'];
          }
        case HtmlControls.kMultipleContactSelection:
          try {
            value as List;
            hasError = value.indexWhere((element) => element.toString().isNullOrEmpty) != -1;
            validationTemp[validation["field"]] = hasError;
          } catch (e) {
            hasError = validation['required'];
            validationTemp[validation["field"]] = hasError;
          }
          break;
        case HtmlControls.kTimePicker:
        case HtmlControls.kDatePicker:
          try {
            hasError = value.toString().isNullOrEmpty;
            message = "Please Select a ${validation["text"]}";
          } catch (e) {
            hasError = validation['required'];
            message = "Please Select a ${validation["text"]}";
          }
        case HtmlControls.kFilePicker:
        case HtmlControls.kImagePicker:
        case HtmlControls.kAvatarPicker:
          try {
            FilesDataModel file = FilesDataModel.fromJson(Map<String, dynamic>.from(value));
            hasError = (file.url.isNullOrEmpty);
            message = "Please Select a ${validation["text"]}";
          } catch (e) {
            hasError = validation['required'];
            message = "Please Select a ${validation["text"]}";
          }
          break;
        default:
          hasError = value.toString().isEmpty && validation['required'];
          message = "Please Enter a ${validation["text"]}";
      }
      return hasError;
    }
    return hasError;
  } else {
    if (!isTableVal) {
      validation.forEach((data) {
        if (!(data?['defaultvisibility'] == false)) {
          data["formFields"].forEach((field) {
            if (field["required"] && !field.containsKey("istablefield") && field?['defaultvisibility'] == true) {
              var value = formData[field["field"]];
              switch (field['type']) {
                case HtmlControls.kInputText:
                case HtmlControls.kNumberInput:
                case HtmlControls.kRadio:
                case HtmlControls.kPassword:
                case HtmlControls.kInputTextArea:
                  try {
                    value = value.toString();
                    value as String;
                    if (field.containsKey('regex')) {
                      hasError = !RegExp(field['regex']).hasMatch(value);
                    } else if (field.containsKey('minvalue')) {
                      hasError = double.parse(value.toString().isEmpty ? '0' : value.toString()) < field['minvalue'];
                    } else if (field.containsKey('maxvalue')) {
                      hasError = double.parse(value) > field['maxvalue'];
                    } else if (field.containsKey('minlength')) {
                      hasError = value.length < field['minlength'];
                    } else if (field.containsKey('maxlength')) {
                      hasError = value.length > field['maxlength'];
                    } else if (field.containsKey('shouldgreaterthan')) {
                      hasError = double.parse(value) <= double.parse(formData[field['shouldgreaterthan']]);
                    } else {
                      hasError = value.isEmpty || value == 'null';
                    }

                    validationTemp[field["field"]] = hasError;
                  } catch (e) {
                    hasError = true;
                    validationTemp[field["field"]] = hasError;
                  }
                  break;
                case HtmlControls.kDropDown:
                  try {
                    hasError = value == null || value.toString().isEmpty;
                    validationTemp[field["field"]] = hasError;
                  } catch (e) {
                    hasError = true;
                    validationTemp[field["field"]] = hasError;
                  }
                  break;
                case HtmlControls.kMultiSelectDropDown:
                case HtmlControls.kDateRangePicker:
                case HtmlControls.kTimeRangePicker:
                  try {
                    value as List;
                    hasError = value.isEmpty;
                    validationTemp[field["field"]] = hasError;
                  } catch (e) {
                    hasError = field['required'];
                    validationTemp[field["field"]] = hasError;
                  }
                  break;
                case HtmlControls.kMultipleContactSelection:
                  devPrint('VAILDATED 2');

                  try {
                    value as List;
                    hasError = value.indexWhere((element) => element.toString().isNullOrEmpty) != -1;
                    validationTemp[field["field"]] = hasError;
                  } catch (e) {
                    hasError = field['required'];
                    validationTemp[field["field"]] = hasError;
                  }
                  break;
                case HtmlControls.kTimePicker:
                case HtmlControls.kDatePicker:
                  try {
                    hasError = value.toString().isNullOrEmpty;
                    validationTemp[field["field"]] = hasError;
                  } catch (e) {
                    hasError = field['required'];
                    validationTemp[field["field"]] = hasError;
                  }
                  break;
                case HtmlControls.kFilePicker:
                case HtmlControls.kImagePicker:
                case HtmlControls.kAvatarPicker:
                  try {
                    FilesDataModel file = FilesDataModel.fromJson(Map<String, dynamic>.from(value ?? {}));
                    hasError = (file.url.isNullOrEmpty);
                    message = "Please Select a ${field["text"]}";
                    validationTemp[field["field"]] = hasError;
                  } catch (e) {
                    hasError = validation['required'];
                    message = "Please Select a ${field["text"]}";
                    validationTemp[field["field"]] = hasError;
                  }
                  break;
                default:
                  hasError = value.toString().isEmpty && field['required'];
                  validationTemp[field["field"]] = hasError;
              }
            }
          });
        }
      });
    } else {
      var obj = getObjectFromFormData(validation, tableField);
      for (var data in validation) {
        for (var field in data["formFields"]) {
          for (var tabFiled in obj["fieldorder"]) {
            if (tabFiled["field"] == field["field"]) {
              if (field["required"] && field.containsKey("istablefield") && field?['defaultvisibility'] == true) {
                var value = formData[field["field"]];
                switch (field['type']) {
                  case HtmlControls.kInputText:
                  case HtmlControls.kNumberInput:
                  case HtmlControls.kRadio:
                  case HtmlControls.kPassword:
                  case HtmlControls.kInputTextArea:
                    value = value?.toString() ?? '';
                    try {
                      if (field?["defaultvisibility"] == true) {
                        value as String;
                        if (field.containsKey('regex')) {
                          hasError = !RegExp(field['regex']).hasMatch(value);
                        } else if (field.containsKey('minvalue')) {
                          hasError = double.parse(value) < field['minvalue'];
                        } else if (field.containsKey('maxvalue')) {
                          hasError = double.parse(value) > field['maxvalue'];
                        } else if (field.containsKey('minlength')) {
                          hasError = value.length < field['minlength'];
                        } else if (field.containsKey('maxlength')) {
                          hasError = value.length > field['maxlength'];
                        } else if (field.containsKey('shouldgreaterthan')) {
                          hasError = double.parse(value) <= double.parse(formData[field['shouldgreaterthan']]);
                        } else {
                          hasError = value.isEmpty;
                        }
                      }
                      validationTemp[field["field"]] = hasError;
                    } catch (e) {
                      hasError = true;
                      validationTemp[field["field"]] = hasError;
                    }
                    break;
                  case HtmlControls.kDropDown:
                    try {
                      hasError = value == null || value.toString().isEmpty;
                      validationTemp[field["field"]] = hasError;
                    } catch (e) {
                      hasError = true;
                      validationTemp[field["field"]] = hasError;
                    }
                    break;

                  case HtmlControls.kDatePicker:
                    if (kDebugMode) {
                      devPrint(value);
                    }
                    hasError = value == null || value.toString().isEmpty;
                    validationTemp[field["field"]] = hasError;
                    break;
                  case HtmlControls.kFilePicker:
                  case HtmlControls.kImagePicker:
                  case HtmlControls.kAvatarPicker:
                    try {
                      FilesDataModel file = FilesDataModel.fromJson(Map<String, dynamic>.from(value));
                      hasError = (file.url.isNullOrEmpty);
                      message = "Please Select a ${field["text"]}";
                      validationTemp[field["field"]] = hasError;
                    } catch (e) {
                      hasError = validation['required'];
                      message = "Please Select a ${field["text"]}";
                      validationTemp[field["field"]] = hasError;
                    }
                    break;
                }
              }
            }
          }
        }
      }
    }
    if (kDebugMode) {
      devPrint("Validation:----$validationTemp");
    }
    return validationTemp;
  }
}

showCustomDatePicker({
  DateTime? initialDate,
  String? minDate,
  Function(String)? onDateSelected,
  bool? isFutureDateSelected,
  bool? isPastDateSelected = true,
}) async {
  await Get.dialog(
    CustomDatePicker(
      initialDate: initialDate,
      onDateSelected: onDateSelected,
      isFutureDateSelected: isFutureDateSelected ?? true,
      isPastDateSelected: isPastDateSelected ?? true,
      minDate: minDate,
    ),
  );
}

showCustomDateRangePicker({
  Function(String startDate, String endDate)? onDateSelected,
  Function()? onCancel,
  bool? isFutureDateSelected,
  String? initialStartDate,
  String? initialEndDate,
}) async {
  await Get.dialog(CustomDateRangePicker(
    onDateSelected: onDateSelected,
    onCancel: onCancel,
    isFutureDateSelected: isFutureDateSelected,
    initialEndDate: initialEndDate.isNotNullOrEmpty ? DateTime.parse(initialEndDate!).toLocal() : DateTime.now(),
    initialStartDate: initialStartDate.isNotNullOrEmpty ? DateTime.parse(initialStartDate!).toLocal() : DateTime.now(),
  ));
}

int generateUniqueFieldId(int w, int x, int? y, int? z) {
  String wString = w.toString().padLeft(3, '0');
  String xString = x.toString().padLeft(3, '0');
  String yString = y != null ? y.toString().padLeft(3, '0') : '000';
  String zString = z != null ? z.toString().padLeft(3, '0') : '000';
  return int.parse('$wString$xString$yString$zString');
}

int generateSubFieldId(int parentId, int y, int z) {
  return parentId + (y * 1000) + z;
}

class LimitRange extends TextInputFormatter {
  LimitRange(
    this.minRange,
    this.maxRange,
  ) : assert(
          minRange < maxRange,
        );

  final double minRange;
  final double maxRange;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      var value = double.tryParse(newValue.text.isNotEmpty ? newValue.text : "0") ?? 0;
      if (value < minRange) {
        if (kDebugMode) {
          devPrint('value print in between 1 - 20');
        }

        return TextEditingValue(text: minRange.toString(), selection: TextSelection.fromPosition(TextPosition(offset: minRange.toString().length)));
      } else if (value > maxRange) {
        if (kDebugMode) {
          devPrint('not more 20');
        }
        return TextEditingValue(text: maxRange.toString(), selection: TextSelection.fromPosition(TextPosition(offset: maxRange.toString().length)));
      }
    }
    return newValue;
  }
}
