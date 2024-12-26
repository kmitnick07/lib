import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../config/config.dart';

class InfoForm extends StatelessWidget {
  const InfoForm({super.key, required this.infoPopUpWidget, this.title, this.isHeaderShow = true, this.widthOfDialog = ModelClassSize.xs});

  final Widget infoPopUpWidget;
  final String? title;
  final double widthOfDialog;
  final bool isHeaderShow;

  @override
  Widget build(BuildContext context) {
    var deviceType = getDeviceType(MediaQuery.of(context).size);

    Widget masterFormView() {
      return ResponsiveBuilder(builder: (context, sizeInformation) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: ColorTheme.kWhite,
          ),
          width: widthOfDialog,
          child: Column(
            children: [
              if (isHeaderShow)
                Container(
                  height: 85,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ColorTheme.kBorderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Row(
                      children: [
                        TextWidget(
                          text: title ?? '',
                          fontWeight: FontWeight.w500,
                          color: ColorTheme.kPrimaryColor,
                          fontSize: 18,
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: ColorTheme.kBackGroundGrey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.clear,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              Expanded(child: infoPopUpWidget),
            ],
          ),
        );
      });
    }

    if (deviceType == DeviceScreenType.mobile) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: ColorTheme.kWhite),
        constraints: BoxConstraints(maxHeight: Get.height * 0.6),
        child: masterFormView(),
      );
    }

    return Dialog(
      backgroundColor: ColorTheme.kWhite,
      alignment: Alignment.centerRight,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
      insetPadding: EdgeInsets.zero,
      child: masterFormView(),
    );
  }
}
