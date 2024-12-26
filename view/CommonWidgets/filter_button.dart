import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';

import '../../style/assets_string.dart';
import '../../style/theme_const.dart';

Widget fltButton({Function()? onTap, Map<String, dynamic>? filterData}) {
  filterData.removeNullValues();
  return InkWell(
    onTap: onTap,
    child: Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          decoration: BoxDecoration(color: ColorTheme.kNameTextBG.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
          child: SvgPicture.asset(
            AssetsString.kFilter,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(ColorTheme.kBlack, BlendMode.srcIn),
          ).paddingAll(10),
        ).paddingOnly(right: 8, top: 2),
        if (filterData.isNotNullOrEmpty)
          const Positioned(
            top: 0,
            right: 4,
            child: Icon(
              Icons.circle,
              color: ColorTheme.kSuccessColor,
              size: 12,
            ),
          )
      ],
    ),
  );
}
