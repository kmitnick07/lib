import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';

import '../../style/theme_const.dart';

class CustomTooltip extends StatelessWidget {
  const CustomTooltip({
    super.key,
    this.message,
    this.child,
    this.textAlign = TextAlign.center,
  });

  final String? message;
  final Widget? child;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    if (message.isNullOrEmpty) {
      return child ?? const SizedBox.shrink();
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InfoPopupWidget(
        contentTitle: message,
        popupClickTriggerBehavior: PopupClickTriggerBehavior.onLongPress,
        contentTheme: InfoPopupContentTheme(
          infoContainerBackgroundColor: ColorTheme.kFocusedBorderColor,
          contentPadding: const EdgeInsets.all(4),
          infoTextAlign: textAlign,
          contentBorderRadius: BorderRadius.circular(4),
          infoTextStyle: const TextStyle(
            color: ColorTheme.kWhite,
            fontSize: 12,
          ),
        ),
        arrowTheme: const InfoPopupArrowTheme(
          enabledAutoArrowDirection: true,
          color: ColorTheme.kFocusedBorderColor,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
