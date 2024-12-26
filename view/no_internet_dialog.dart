import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';

import '../components/customs/custom_button.dart';
import '../style/theme_const.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({
    super.key,
    this.onRetry,
  });

  final Function? onRetry;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      surfaceTintColor: ColorTheme.kWhite,
      backgroundColor: ColorTheme.kWhite,
      alignment: Alignment.center,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 600),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AssetsString.kNoInternetGIF,
              height: 200,
              width: 600,
            ),
            const TextWidget(
              text: "Oops!",
              fontWeight: FontTheme.notoBold,
              fontSize: 24,
            ).paddingOnly(bottom: 20),
            const TextWidget(
              text: "No internet connection.\nPlease check your internet connection and try again",
              textAlign: TextAlign.center,
              fontSize: 16,
            ).paddingOnly(bottom: 50),
            CustomButton(
              title: "Retry",
              buttonColor: ColorTheme.kBlack,
              fontColor: ColorTheme.kWhite,
              height: 40,
              width: 90,
              borderRadius: 5,
              onTap: () async {
                await onRetry!();
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
