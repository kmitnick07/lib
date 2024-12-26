import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomDatePicker extends StatelessWidget {
  const CustomDatePicker({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.isFutureDateSelected = true,
    this.isPastDateSelected = true,
    this.minDate,
  });

  final DateTime? initialDate;
  final String? minDate;
  final bool isFutureDateSelected;
  final bool isPastDateSelected;
  final Function(String date)? onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.hardEdge,
      backgroundColor: ColorTheme.kWhite,
      child: Container(
        width: 400,
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SfDateRangePicker(
          initialSelectedDate: initialDate,
          initialDisplayDate: initialDate,
          selectionColor: ColorTheme.kPrimaryColor,
          todayHighlightColor: ColorTheme.kPrimaryColor,
          backgroundColor: ColorTheme.kWhite,
          showActionButtons: true,
          maxDate: isFutureDateSelected ? null : DateTime.now(),
          minDate: isPastDateSelected
              ? minDate.isNotNullOrEmpty
                  ? DateTime.parse(minDate!)
                  : null
              : minDate.isNotNullOrEmpty
                  ? DateTime.parse(minDate!)
                  : DateTime.now(),
          onSubmit: (p0) {
            if (onDateSelected != null) {
              DateTime date = DateTime.parse(p0.toString());
              onDateSelected!(dateConvertIntoUTC(DateTime(date.year, date.month, date.day)));
            }
            Get.back();
          },
          onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
            if (onDateSelected != null) {
              DateTime date = DateTime.parse(dateRangePickerSelectionChangedArgs.value.toString());
              onDateSelected!(dateConvertIntoUTC(DateTime(date.year, date.month, date.day)));
            }
            Get.back();
          },
          onCancel: () {
            Get.back();
          },
          showNavigationArrow: true,
          confirmText: 'SELECT',
        ),
      ),
    );
  }
}

String dateConvertIntoUTC(
  DateTime date,
) {
  devPrint(date.toIso8601String());
  return date.toIso8601String();
}

DateTime UTCConvertDateTime(
  String date,
) {
  return DateTime.parse(date).toLocal();
}
