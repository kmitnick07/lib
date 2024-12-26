import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:prestige_prenew_frontend/view/CommonWidgets/common_header_footer.dart';

class NoPageFoundScreen extends StatelessWidget {
  NoPageFoundScreen({super.key});

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.kWhite,
      body: CommonHeaderFooter(
          title: "No Page Found",
          txtSearchController: searchController,
          child: Center(
            child: SvgPicture.asset(
              AssetsString.kNoPageFoundSvg,
              height: 400,
              width: 400,
            ),
          )),
    );
  }
}
