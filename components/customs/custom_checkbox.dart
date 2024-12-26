import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

class CustomCheckBox extends StatelessWidget {
  const CustomCheckBox({
    super.key,
    required this.value,
    required this.onChanged,
    this.focusNode,
    this.label,
    this.shape,
    this.fontSize,
    this.fontWeight,
  });

  final bool value;
  final Function(bool? value) onChanged;
  final FocusNode? focusNode;
  final String? label;
  final double? fontSize;
  final FontWeight? fontWeight;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            onChanged(!value);
          },
          child: Checkbox(
            value: value,
            shape: shape,
            onChanged: onChanged,
            focusNode: FocusNode(skipTraversal: true),
            checkColor: ColorTheme.kWhite,
            activeColor: ColorTheme.kBlack,
          ),
        ),
        Visibility(
          visible: label.isNotNullOrEmpty,
          child: TextWidget(
            text: label,
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight ?? FontTheme.notoRegular,
          ),
        )
      ],
    );
  }
}
