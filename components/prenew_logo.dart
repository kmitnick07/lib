import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../config/helper/offline_data.dart';
import '../config/iis_method.dart';
import '../style/assets_string.dart';
import '../style/theme_const.dart';

class PrenewLogo extends StatelessWidget {
  const PrenewLogo({
    super.key,
    required this.size,
    this.showName = false,
    this.color,
  });

  final double size;
  final bool showName;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size,
            width: size,
            child: Stack(
              children: [
                Center(
                  child: SvgPicture.asset(
                    AssetsString.kLogoBackground,
                    colorFilter: ColorFilter.mode(color ?? ColorTheme.kBlack, BlendMode.srcIn),
                    height: size * 3 / 5,
                  ),
                ),
                Positioned(
                  right: size / 5,
                  child: SvgPicture.asset(
                    AssetsString.kLogoEagle,
                    height: size * 3.5 / 5,
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: showName,
            child: InkWell(
              onTap: () {
              },
              child: SizedBox(
                height: size,
                child: SvgPicture.asset(
                  AssetsString.kLogoPrenew,
                  height: size * 2.5 / 7,
                  colorFilter: ColorFilter.mode(color ?? ColorTheme.kBlack, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
