import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.light,
    backgroundColor: AppColors.lightBG,
    primaryColor: AppColors.mainColor,
    toggleableActiveColor: Colors.blue,
    dividerColor: const Color(0xFFF8F8F8),
    scaffoldBackgroundColor: AppColors.lightBG,
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: AppColors.mainColor,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.lightAccent),
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.lightAccent),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.dark,
    backgroundColor: AppColors.darkBG,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBG,
    toggleableActiveColor: Colors.blueAccent,
    dividerColor: const Color(0xFF2F2F2F),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.darkAccent,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.darkAccent),
  );
}
