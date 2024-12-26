import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';

import '../../style/theme_const.dart';
import 'custom_text_form_field.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    required this.txtSearch,
    this.onSearch,
    this.onTap,
    this.onChanged,
    this.isSearching = false,
    this.focusNode,
  });

  final TextEditingController txtSearch;
  final Function(String p1)? onSearch;
  final void Function()? onTap;
  final dynamic Function(String)? onChanged;
  final bool? isSearching;

  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: CustomTextFormField(
        hintColor: ColorTheme.kPrimaryColor,
        fillColor: ColorTheme.kGrey.withOpacity(0.1),
        onFieldSubmitted: onSearch,
        onChanged: onChanged,
        controller: txtSearch,
        hintText: 'Search',
        borderColor: ColorTheme.kHeaderFieldBorderColor,
        showSuffixDivider: false,
        focusNode: focusNode,
        suffixWidget: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            if (txtSearch.text.isNotNullOrEmpty) {
              txtSearch.text = "";
              if (onSearch != null) {
                onSearch!('');
              }
            }
          },
          child: Icon(
            isSearching! ? Icons.close : Icons.search,
            color: ColorTheme.kHeaderFieldBorderColor,
          ).paddingSymmetric(horizontal: 8),
        ),
      ),
    );
  }
}
