import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/config/helper/offline_data.dart';

import '../../style/theme_const.dart';
import 'custom_tooltip.dart';

class CustomTextFormField extends StatelessWidget {
  final String? labelText;
  final FormFieldSetter? onSaved;
  final FormFieldValidator? validator;
  final Function(String)? onChanged;
  final TextEditingController controller;
  final TextInputType? textInputType;
  final bool obscureText;
  final bool showSuffixIcon;
  final bool readOnly;
  final bool disableField;
  final String? suffixIcon;
  final String? prefixIcon;
  final String? hintText;
  final FontWeight? hintWeight;
  final Color? hintColor;
  final Color? fontColor;

  final double? hintSize;
  final Function()? onTap;
  final Function(String value)? onFieldSubmitted;
  final Function()? suffixOnTap;
  final String? initValue;
  final int? maxLine;
  final int? maxInput;
  final double? width;
  final double? height;
  final EdgeInsets? contentPadding;
  final BoxConstraints? prefixIconConstraints;
  final TextCapitalization? textCapitalization;
  final Widget? suffixWidget;
  final Widget? prefixWidget;
  final Widget? titleRowWidget;
  final bool showPrefix;
  final bool hideCursor;
  final bool underlineBorder;
  final bool hideBorder;
  final Color? borderColor;
  final List<TextInputFormatter>? inputFormatters;
  final double? fontSize;
  final double? textWidth;
  final FontWeight? fontWeight;
  final String? textFieldLabel;
  final bool? isRequire;
  final bool? filled;
  final bool showSuffixDivider;
  final bool showPrefixDivider;
  final bool? autofocus;
  final Color? fillColor;
  final bool? showToolTip;
  final bool? showTitleRowWidget;
  final bool? isCopyPasteEnable;
  final String? toolTipText;
  final String? titleRowWidgetToolTipText;
  final FocusNode? focusNode;
  final double? borderRadius;
  final AutovalidateMode? autoValidateMode;
  final TextAlign? textAlign;
  final Function(PointerDownEvent)? onTapOutside;
  final bool disableFocusShift;
  final bool? headerRadioValue;
  final Function(bool value)? headerRadioOnChange;
  final String? headerRadioLabel;
  final MouseCursor? mouseCursor;
  final Key? fieldKey;

  const CustomTextFormField({
    required this.controller,
    this.contentPadding,
    this.obscureText = false,
    this.headerRadioValue,
    this.suffixOnTap,
    this.textWidth,
    this.maxLine = 1,
    this.maxInput,
    this.textInputType,
    this.borderRadius,
    this.autofocus,
    this.labelText,
    this.disableField = false,
    this.validator,
    this.initValue,
    this.readOnly = false,
    this.onSaved,
    this.showSuffixIcon = false,
    this.underlineBorder = false,
    this.suffixIcon = "",
    this.onTap,
    super.key,
    this.onChanged,
    this.fontSize = 12,
    this.fontWeight,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.hintText,
    this.suffixWidget,
    this.prefixIcon,
    this.showPrefix = false,
    this.prefixWidget,
    this.hideCursor = false,
    this.textFieldLabel,
    this.isRequire = false,
    this.filled = true,
    this.fillColor,
    this.showToolTip = false,
    this.showTitleRowWidget = false,
    this.isCopyPasteEnable = true,
    this.toolTipText,
    this.titleRowWidgetToolTipText,
    this.focusNode,
    this.autoValidateMode,
    this.onFieldSubmitted,
    this.onTapOutside,
    this.hideBorder = false,
    this.hintWeight,
    this.hintSize,
    this.textAlign = TextAlign.start,
    this.disableFocusShift = false,
    this.width,
    this.showSuffixDivider = true,
    this.showPrefixDivider = true,
    this.hintColor,
    this.height,
    this.borderColor,
    this.prefixIconConstraints,
    this.headerRadioOnChange,
    this.headerRadioLabel,
    this.titleRowWidget,
    this.fontColor,
    this.mouseCursor,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    final isPng = suffixIcon!.split(".").last;
    return CustomTooltip(
      // message: toolTipText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
              visible: textFieldLabel != null,
              child: SizedBox(
                width: textWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: textFieldLabel,
                                      style: TextStyle(
                                        overflow: TextOverflow.visible,
                                        fontFamily: FontTheme.themeFontFamily,
                                        fontWeight: FontTheme.notoRegular,
                                        color: ColorTheme.kBlack,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (isRequire ?? false)
                                      const TextSpan(
                                        text: " *",
                                        style: TextStyle(
                                          color: ColorTheme.kPrimaryColor,
                                          fontSize: 12,
                                          fontWeight: FontTheme.notoRegular,
                                        ),
                                      ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ).paddingOnly(right: 5),
                            ),
                          ),
                          if (showTitleRowWidget!)
                            CustomTooltip(
                              message: titleRowWidgetToolTipText ?? "",
                              child: titleRowWidget,
                            ),
                          if (showToolTip!)
                            CustomTooltip(
                              message: toolTipText,
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 15,
                                color: ColorTheme.kPrimaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (headerRadioValue != null && !isoffline.value) ...[
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.75,
                              child: Switch(
                                focusNode: FocusNode(skipTraversal: true),
                                activeTrackColor: ColorTheme.kBlack,
                                thumbColor: const MaterialStatePropertyAll(ColorTheme.kWhite),
                                value: headerRadioValue ?? false,
                                onChanged: (value) {
                                  if (headerRadioOnChange != null) {
                                    headerRadioOnChange!(value);
                                  }
                                },
                              ),
                            ),
                            TextWidget(
                              text: headerRadioLabel ?? '',
                              fontFamily: FontTheme.themeFontFamily,
                              fontWeight: FontTheme.notoRegular,
                              color: ColorTheme.kBlack,
                              fontSize: 12,
                            )
                          ],
                        ),
                      )
                    ],
                  ],
                ).paddingOnly(
                  bottom: 2,
                ),
              )),
          TextFormField(
            key: fieldKey,
            mouseCursor: mouseCursor,
            controller: controller,
            enableInteractiveSelection: isCopyPasteEnable,
            obscureText: obscureText,
            autofocus: autofocus ?? false,
            validator: validator,
            autocorrect: true,
            showCursor: readOnly ? false : !hideCursor,
            readOnly: readOnly,
            onTapOutside: onTapOutside,
            textCapitalization: textCapitalization!,
            autovalidateMode: autoValidateMode ?? AutovalidateMode.disabled,
            keyboardType: textInputType,
            focusNode: focusNode,
            enabled: !disableField,
            inputFormatters: inputFormatters,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              color: fontColor ?? ColorTheme.kPrimaryColor,
              fontFamily: FontTheme.themeFontFamily,
              fontWeight: fontWeight ?? FontTheme.notoMedium,
              fontSize: fontSize,
              height: 1.1,
            ),
            onTap: onTap,
            onFieldSubmitted: (value) async {
              if (onFieldSubmitted != null) {
                await onFieldSubmitted!(value);
              }

              if (kIsWeb && !disableFocusShift && focusNode != null) {
                focusNode?.requestFocus();
                focusNode?.nextFocus();
              }
            },
            initialValue: initValue,
            maxLines: maxLine,
            maxLength: maxInput,
            onChanged: onChanged,
            textAlign: textAlign ?? TextAlign.start,
            textAlignVertical: const TextAlignVertical(y: 0.2),
            decoration: InputDecoration(
              floatingLabelBehavior: textFieldLabel != null ? FloatingLabelBehavior.always : FloatingLabelBehavior.never,
              filled: filled,
              fillColor: fillColor ?? (disableField ? ColorTheme.kBackGroundGrey : ColorTheme.kWhite),
              counterText: "",
              errorStyle: TextStyle(color: ColorTheme.kRed, fontSize: 11, fontFamily: FontTheme.themeFontFamily),
              focusedBorder: hideBorder
                  ? InputBorder.none
                  : OutlineInputBorder(
                      borderSide: BorderSide(color: borderColor ?? ColorTheme.kFocusedBorderColor, width: 1.5),
                      borderRadius: BorderRadius.circular(borderRadius ?? 5.0),
                    ),
              border: hideBorder
                  ? InputBorder.none
                  : underlineBorder
                      ? null
                      : OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor ?? ColorTheme.kBorderColor, width: 1),
                          borderRadius: BorderRadius.circular(borderRadius ?? 5.0),
                        ),
              enabledBorder: hideBorder
                  ? InputBorder.none
                  : underlineBorder
                      ? null
                      : OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor ?? ColorTheme.kBorderColor, width: 1),
                          borderRadius: BorderRadius.circular(borderRadius ?? 5.0),
                        ),
              errorBorder: hideBorder
                  ? InputBorder.none
                  : underlineBorder
                      ? null
                      : OutlineInputBorder(
                          borderSide: BorderSide(color: borderColor ?? ColorTheme.kRedError, width: 1.5),
                          borderRadius: BorderRadius.circular(borderRadius ?? 5.0),
                        ),
              contentPadding: contentPadding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              isDense: true,
              labelText: labelText,
              hintText: hintText,
              prefixIcon: prefixWidget != null
                  ? IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: prefixWidget!,
                          ),
                          if (showPrefixDivider)
                            const Padding(
                              padding: EdgeInsets.only(top: 1.0, bottom: 1, right: 4),
                              child: VerticalDivider(width: 1, color: ColorTheme.kBorderColor),
                            ),
                        ],
                      ),
                    )
                  : prefixIcon != null
                      ? Container(
                          padding: const EdgeInsets.all(5),
                          child: prefixIcon!.split(".").last == "png"
                              ? Image.asset(
                                  prefixIcon.toString(),
                                  color: ColorTheme.kIconColor,
                                  width: 7,
                                  height: 7,
                                )
                              : SvgPicture.asset(
                                  prefixIcon.toString(),
                                  colorFilter: const ColorFilter.mode(ColorTheme.kIconColor, BlendMode.srcIn),
                                  width: 10,
                                  height: 10,
                                ),
                        )
                      : null,
              prefixIconConstraints: prefixIconConstraints ?? (maxLine == 1 ? BoxConstraints.tightFor(height: height ?? 36) : null),
              suffixIconConstraints: maxLine == 1 ? BoxConstraints.tightFor(height: height ?? (kIsWeb ? 40 : 48)) : null,
              suffixIcon: suffixWidget != null
                  ? IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Visibility(
                            visible: showSuffixDivider,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.0),
                              child: VerticalDivider(width: 1, color: ColorTheme.kBorderColor),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Center(child: suffixWidget!),
                          ),
                        ],
                      ),
                    )
                  : (showSuffixIcon
                      ? Container(
                          child: isPng == "png"
                              ? Image.asset(
                                  suffixIcon.toString(),
                                  color: ColorTheme.kBorderColor,
                                  width: 7,
                                  height: 7,
                                )
                              : SvgPicture.asset(
                                  suffixIcon.toString(),
                                  colorFilter: const ColorFilter.mode(ColorTheme.kIconColor, BlendMode.srcIn),
                                  width: 10,
                                  height: 10,
                                ),
                        )
                      : suffixIcon != null
                          ? InkResponse(
                              focusNode: FocusNode(skipTraversal: true),
                              onTap: suffixOnTap,
                              child: SvgPicture.asset(
                                suffixIcon.toString(),
                                width: 25,
                                height: 25,
                                colorFilter: const ColorFilter.mode(ColorTheme.kIconColor, BlendMode.srcIn),
                              ).paddingOnly(right: 4),
                            )
                          : null),
              labelStyle: TextStyle(
                fontFamily: FontTheme.themeFontFamily,
                fontWeight: FontTheme.notoRegular,
                color: ColorTheme.kTextColor,
                overflow: TextOverflow.visible,
              ),
              hintStyle: TextStyle(
                fontFamily: FontTheme.themeFontFamily,
                fontWeight: hintWeight ?? FontTheme.notoRegular,
                color: hintColor ?? ColorTheme.kHintColor,
                fontSize: hintSize ?? 12,
              ),
            ),
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }
}
