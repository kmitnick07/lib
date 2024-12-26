import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../config/dev/dev_helper.dart';
import '../../style/theme_const.dart';
import 'custom_date_picker.dart';

class CustomDateRangePicker extends StatelessWidget {
  const CustomDateRangePicker({
    super.key,
    this.initialStartDate,
    this.onDateSelected,
    this.isFutureDateSelected,
    this.onCancel,
    this.initialEndDate,
  });

  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool? isFutureDateSelected;
  final Function(String startDate, String endDate)? onDateSelected;
  final Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    String selectedDateRange = '';

    return Dialog(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: ColorTheme.kWhite,
      child: Container(
        width: 400,
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SfDateRangePicker(
          initialSelectedDate: initialStartDate,
          initialSelectedRange: PickerDateRange(initialStartDate, initialEndDate),
          selectionMode: DateRangePickerSelectionMode.range,
          rangeSelectionColor: ColorTheme.kBlack.withOpacity(0.1),
          startRangeSelectionColor: ColorTheme.kGrey,
          endRangeSelectionColor: ColorTheme.kBlack.withOpacity(0.8),
          selectionColor: ColorTheme.kPrimaryColor,
          todayHighlightColor: ColorTheme.kPrimaryColor,
          backgroundColor: ColorTheme.kWhite,
          showActionButtons: true,
          maxDate: (isFutureDateSelected ?? false) ? null : DateTime.now(),
          onSubmit: (Object? value) {
            if (value is PickerDateRange) {
              final startDate = dateConvertIntoUTC(value.startDate!);
              final endDate = dateConvertIntoUTC(value.endDate!);
              selectedDateRange = '$startDate to $endDate';
              devPrint("$selectedDateRange   4784645564");
              if (onDateSelected != null) {
                onDateSelected!(startDate, endDate);
              }
            }
            Get.back();
          },
          onCancel: () {
            if (onCancel != null) {
              onCancel!();
            }
            Get.back();
          },
          showNavigationArrow: true,
          confirmText: 'SELECT',
        ),
      ),
    );
  }
}
