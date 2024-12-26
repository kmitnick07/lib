import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

class CommonBackArrow extends StatelessWidget {
  final Color? color;
  final void Function()? onTap;
  const CommonBackArrow({super.key, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap ??
              () {
            Get.back();
          },
      child: Container(
        margin: const EdgeInsets.all(8),
        height: 40,
        width: 40,
        decoration: color == Colors.transparent
            ? null
            : BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorTheme.kBackGroundGrey,width: 1.5),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 26, color: color ?? ColorTheme.kBlack),
      ),
    );
  }
}