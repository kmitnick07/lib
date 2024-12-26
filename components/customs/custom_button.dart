import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.fontColor,
    this.height,
    this.width,
    this.title,
    this.onTap,
    this.fontWeight,
    this.fontSize,
    this.buttonColor,
    this.gradientColor1,
    this.prefixIcon = "",
    this.gradientColor2,
    this.widget,
    this.padding,
    this.margin,
    this.showBoxBorder = false,
    this.borderRadius,
    this.isLoading = false,
    this.borderWidth,
    this.borderColor,
    this.hoverColor,
    this.prefixIconSize,
    this.prefixIconColor,
    this.circularProgressColor,
    this.focusNode,
  });

  final double? height, width, fontSize, borderRadius;
  final Function()? onTap;
  final String? title;
  final String? prefixIcon;
  final double? prefixIconSize;
  final Color? prefixIconColor;
  final Color? buttonColor, fontColor;
  final FontWeight? fontWeight;
  final String? gradientColor1;
  final String? gradientColor2;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool? showBoxBorder;
  final double? borderWidth;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? circularProgressColor;
  final Widget? widget;
  final bool? isLoading;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: InkWell(
          hoverColor: hoverColor,
          mouseCursor: onTap == null
              ? SystemMouseCursors.disappearing
              : !(isLoading ?? false)
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.forbidden,
          onTap: !(isLoading ?? false) ? onTap : null,
          focusNode: focusNode,
          borderRadius: BorderRadius.circular(borderRadius == null ? 12 : borderRadius!.toDouble()),
          child: Ink(
            height: height ?? 45,
            padding: padding,
            decoration: (gradientColor1 != null && gradientColor2 != null)
                ? BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(int.parse("0xFF$gradientColor1")),
                        Color(int.parse("0xFF$gradientColor2")),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  )
                : BoxDecoration(
                    color: buttonColor ?? ColorTheme.kPrimaryColor,
                    border: showBoxBorder! ? Border.all(width: borderWidth ?? 0.5, color: borderColor ?? ColorTheme.kBorderColor) : null,
                    borderRadius: BorderRadius.circular(borderRadius == null ? 12 : borderRadius!.toDouble()),
                  ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Get.width,
                minWidth: width ?? (Get.width / 3),
              ),
              child: isLoading!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CupertinoActivityIndicator(
                            color: circularProgressColor ?? ColorTheme.kWhite,
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          prefixIcon!.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: prefixIcon!.contains(".png")
                                      ? Image.asset(
                                          prefixIcon.toString(),
                                          height: prefixIconSize ?? 20,
                                          width: prefixIconSize ?? 20,
                                        )
                                      : SvgPicture.asset(
                                          prefixIcon.toString(),
                                          height: prefixIconSize ?? 20,
                                          width: prefixIconSize ?? 20,
                                          colorFilter: ColorFilter.mode(prefixIconColor ?? ColorTheme.kBlack, BlendMode.srcIn),
                                        ),
                                )
                              : const SizedBox(),
                          widget != null
                              ? Container(child: widget)
                              : Flexible(
                                  child: TextWidget(
                                    text: (title ?? '').toString(),
                                    color: fontColor ?? ColorTheme.kWhite,
                                    fontSize: fontSize ?? 15,
                                    fontWeight: fontWeight,
                                    textAlign: TextAlign.center,
                                    textOverflow: TextOverflow.visible,
                                  ),
                                ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
