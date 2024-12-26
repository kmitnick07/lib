import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';

import '../../style/theme_const.dart';

class MyRadioOption<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String? label;
  final String? text;
  final ValueChanged<T?> onChanged;

  const MyRadioOption({
    required this.value,
    required this.groupValue,
    this.label,
    this.text,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxHeight: 200,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => onChanged(value),
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              height: 20,
              width: 20,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1,
                  color: isSelected ? ColorTheme.kPrimaryColor : ColorTheme.kHintTextColor,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: isSelected ? ColorTheme.kPrimaryColor : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          TextWidget(
            text: text.toString(),
            color: isSelected ? ColorTheme.kPrimaryColor : ColorTheme.kHintTextColor,
            fontWeight: FontTheme.notoMedium,
            fontSize: 15,
          ),
        ],
      ),
    );
  }
}
