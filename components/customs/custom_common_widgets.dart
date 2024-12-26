import 'package:flutter/material.dart';

Widget expandedRowColumn(bool isRow, Widget child) {
  if (isRow) {
    return Expanded(child: child);
  } else {
    return child;
  }
}