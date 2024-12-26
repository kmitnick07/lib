import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';

import '../components/customs/text_widget.dart';
import '../style/theme_const.dart';

class NoDataFoundScreen extends StatelessWidget {
  const NoDataFoundScreen({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            AssetsString.kNoDataFound,
            height: height ?? 400,
            width: width ?? 400,
          ),
          const TextWidget(
            text: "NO DATA FOUND",
            fontWeight: FontTheme.notoBold,
            fontSize: 30,
            color: ColorTheme.kGrey,
          ),
        ],
      ),
    );
  }
}
