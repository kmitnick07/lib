import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../../../style/theme_const.dart';

class DottedHorizontalDivider extends StatelessWidget {
  const DottedHorizontalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: DottedLine(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        lineLength: double.infinity,
        lineThickness: 1.0,
        dashLength: 4.0,
        dashColor: ColorTheme.kBackGroundGrey,
        dashRadius: 0.0,
        dashGapLength: 4.0,
        dashGapColor: Colors.transparent,
        dashGapRadius: 0.0,
      ),
    );
  }
}

class DottedVerticalDivider extends StatelessWidget {
  const DottedVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DottedLine(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        lineLength: double.infinity,
        lineThickness: 1.0,
        dashLength: 4.0,
        dashColor: ColorTheme.kBackGroundGrey,
        dashRadius: 0.0,
        dashGapLength: 4.0,
        dashGapColor: Colors.transparent,
        dashGapRadius: 0.0,
      ),
    );
  }
}

class CustomVerticalDivider extends StatelessWidget {
  final Color? color;

  const CustomVerticalDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DottedLine(
        direction: Axis.vertical,
        alignment: WrapAlignment.center,
        lineLength: double.infinity,
        lineThickness: 1.0,
        dashLength: 4.0,
        dashColor: color ?? ColorTheme.kBackGroundGrey,
        dashRadius: 0.0,
        dashGapLength: 4.0,
        dashGapColor: color ?? ColorTheme.kBackGroundGrey,
        dashGapRadius: 0.0,
      ),
    );
  }
}
