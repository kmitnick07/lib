import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prestige_prenew_frontend/config/iis_method.dart';

extension StringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty || this == "null";

  bool get isNotNullOrEmpty => !(this == null || this!.trim().isEmpty || this == "null");

  String get toCamelCase => IISMethods().convertToCamelCase(this ?? "");

  String get textFieldErrMsg => "Please Enter $this";

  String get dropDownErrMsg => "Please Select $this";

  String get invalidTextFieldErrMsg => "Please Enter Valid $this";

  String toAmount() {
    try {
      double amount = double.parse(this ?? '');
      NumberFormat format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
      return format.format(amount);
    } catch (e) {
      return toString();
    }
  }

  double get converttoDouble => double.tryParse((this ?? "0").toString()) ?? 0;

  int get converttoInt => (double.tryParse((this ?? "0").toString()) ?? 0).ceil();

  Color toColor() {
    var hexColor = (this ?? 'FFFFFF').replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.transparent;
  }

  String toDateFormat({String? format}) {
    if (isNullOrEmpty) {
      return '-';
    }
    try {
      if ((toString().contains('/') || toString().contains('-'))) {
        DateTime parsedDateTime = DateTime.parse(this ?? '').toLocal();

        if (parsedDateTime.year > 0 && parsedDateTime.month > 0 && parsedDateTime.day > 0) {
          return DateFormat(format ?? "dd MMM yyyy").format(parsedDateTime).toString();
        } else {
          return toString();
        }
      } else {
        return toString().isNotEmpty ? toString() : '-';
      }
    } catch (e) {
      return toString().isNotEmpty ? toString() : '-';
    }
  }

  String toDateTimeFormat({String? format}) {
    if (isNullOrEmpty) {
      return '-';
    }
    try {
      if ((toString().contains('/') || toString().contains('-'))) {
        // Check id valid DateTime Format
        DateTime parsedDateTime = DateTime.parse(this ?? '').toLocal();

        // Check if the parsed date has year, month, and day components
        if (parsedDateTime.year > 0 && parsedDateTime.month > 0 && parsedDateTime.day > 0) {
          return DateFormat(format ?? 'dd MMM yyyy, hh:mm a').format(parsedDateTime).toString();
        } else {
          return toString();
        }
      } else {
        return toString().isNotEmpty ? toString() : '-';
      }
    } catch (e) {
      return toString().isNotEmpty ? toString() : '-';
    }
  }

  String toTimeFormat({String? format}) {
    if (isNullOrEmpty) {
      return '-';
    }
    try {
      if ((toString().contains('/') || toString().contains('-'))) {
        DateTime parsedDateTime = DateTime.parse(this ?? '').toLocal();
        if (parsedDateTime.year > 0 && parsedDateTime.month > 0 && parsedDateTime.day > 0) {
          return DateFormat(format ?? 'hh:mm a').format(parsedDateTime).toString();
        } else {
          return toString();
        }
      } else {
        return toString().isNotEmpty ? toString() : '-';
      }
    } catch (e) {
      return toString().isNotEmpty ? toString() : '-';
    }
  }
}

extension IntExtension on int? {
  String get indexToLetters => indexToLettersForXL(this ?? 0);
}

extension ListExtension on List? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => !(this == null || this!.isEmpty);
}

extension MapExtension on Map? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  bool get isNotNullOrEmpty => !(this == null || this!.isEmpty);

  void removeNullValues() {
    if (this == null || this!.isEmpty) {
      return;
    }

    this?.removeWhere((key, value) {
      if (value == null) {
        return true;
      }
      if (value is String || value is int) {
        return value.toString().isNullOrEmpty;
      }
      if (value is List) {
        return value.isNullOrEmpty;
      }
      if (value is Map) {
        value.isEmpty;
      }
      return value == {};
    });
  }
}
extension IntegerExtension on int?{
  Widget get kH => SizedBox(
    height: (this ?? 0).toDouble(),
  );

  Widget get kW => SizedBox(
    width: (this ?? 0).toDouble(),
  );
}
extension DoubleExtension on double? {


  String get toAmount => "₹${(double.tryParse((this ?? "0").toString()) ?? 0).toStringAsFixed(1)}";
}

String indexToLettersForXL(int index) {
  var letters = '';
  do {
    final r = index % 26;
    letters = '${String.fromCharCode(64 + r)}$letters';
    index = (index - r) ~/ 26;
  } while (index > 0);
  return letters;
}
