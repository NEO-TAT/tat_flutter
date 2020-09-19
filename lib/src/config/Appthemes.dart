import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/AppColors.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.light,
    backgroundColor: AppColors.lightBG,
    primaryColor: AppColors.mainColor,
    accentColor: AppColors.lightAccent,
    cursorColor: AppColors.lightAccent,
    toggleableActiveColor: Colors.blue,
    dividerColor: Color(0xFFF8F8F8),
    scaffoldBackgroundColor: AppColors.lightBG,
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.mainColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.dark,
    backgroundColor: AppColors.darkBG,
    primaryColor: AppColors.darkPrimary,
    accentColor: AppColors.darkAccent,
    scaffoldBackgroundColor: AppColors.darkBG,
    cursorColor: AppColors.darkAccent,
    toggleableActiveColor: Colors.blueAccent,
    dividerColor: Color(0xFF2F2F2F),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.darkAccent,
    ),
    buttonColor: AppColors.darkAccent,
  );
}
