import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

class Style {
  static ThemeData themeData(BuildContext context) {
    return ThemeData(
        scaffoldBackgroundColor: ColorTheme.kScaffoldColor,
        fontFamily: FontTheme.themeFontFamily,
        primaryColorDark: ColorTheme.kBlack,
        primaryColorLight: ColorTheme.kWhite,
        useMaterial3: false,
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: FontTheme.themeFontFamily,
            fontSize: 12.0,
          ),
          bodySmall: TextStyle(
            fontFamily: FontTheme.themeFontFamily,
            fontSize: 10.0,
          ),
          bodyLarge: TextStyle(
            fontFamily: FontTheme.themeFontFamily,
            fontSize: 14.0,
          ),
        ),
        hintColor: ColorTheme.kHintColor,
        colorScheme: const ColorScheme.light(
          onPrimary: ColorTheme.kBorderColor,
          onSurfaceVariant: ColorTheme.kWhite,
          onSurface: ColorTheme.kBlack,
          primary: ColorTheme.kPrimaryColor,
        ),
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        primaryColor: ColorTheme.kPrimaryColor,
        dialogTheme: const DialogTheme(surfaceTintColor: ColorTheme.kWhite),
        drawerTheme: const DrawerThemeData(surfaceTintColor: ColorTheme.kWhite),
        cardTheme: const CardTheme(surfaceTintColor: ColorTheme.kWhite),
        popupMenuTheme: const PopupMenuThemeData(surfaceTintColor: ColorTheme.kWhite),
        iconTheme: const IconThemeData(color: ColorTheme.kBlack),
        checkboxTheme: const CheckboxThemeData(side: BorderSide(color: ColorTheme.kBlack, width: 1)),
        primaryIconTheme: const IconThemeData(color: ColorTheme.kBlack),
        datePickerTheme: DatePickerThemeData(
          surfaceTintColor: ColorTheme.kWhite,
          dividerColor: ColorTheme.kBorderColor,
          headerBackgroundColor: ColorTheme.kPrimaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          headerHeadlineStyle: const TextStyle(color: ColorTheme.kWhite, fontSize: 25),
          rangePickerHeaderBackgroundColor: ColorTheme.kPrimaryColor,
          rangePickerShadowColor: ColorTheme.kPrimaryColor.withOpacity(0.3),
          rangeSelectionBackgroundColor: ColorTheme.kPrimaryColor.withOpacity(0.3),
        ),
        textSelectionTheme: TextSelectionThemeData(selectionColor:'b0d3fb'.toColor()),
        bottomSheetTheme: BottomSheetThemeData(
          dragHandleColor: ColorTheme.kPrimaryColor.withOpacity(0.8),
          backgroundColor: ColorTheme.kWhite,
          surfaceTintColor: ColorTheme.kWhite,
          dragHandleSize: const Size(40, 5),
        ),
        inputDecorationTheme: InputDecorationTheme(
          floatingLabelStyle:
          WidgetStateTextStyle.resolveWith((states) => states.contains(WidgetState.selected) ? const TextStyle(color: ColorTheme.kPrimaryColor) : const TextStyle(color: ColorTheme.kBlack)),
          labelStyle:
          WidgetStateTextStyle.resolveWith((states) => states.contains(WidgetState.selected) ? const TextStyle(color: ColorTheme.kPrimaryColor) : const TextStyle(color: ColorTheme.kBlack)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.kPrimaryColor, width: 2)),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: ColorTheme.kBorderColor, width: 1)),
        ),
        dialogBackgroundColor: ColorTheme.kWhite,
        scrollbarTheme: ScrollbarThemeData(thumbVisibility: WidgetStateProperty.all<bool>(true), interactive: true));
  }
}
