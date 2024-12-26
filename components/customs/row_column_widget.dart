import 'package:flutter/material.dart';

class RowColumnWidget extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final GroupType grouptype;

  const RowColumnWidget({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.grouptype,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    if (grouptype == GroupType.row) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      );
    }
  }
}

enum GroupType { column, row }
