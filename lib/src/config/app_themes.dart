import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.light,
    backgroundColor: AppColors.lightBG,
    primaryColor: AppColors.mainColor,
    accentColor: AppColors.lightAccent,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightAccent,
    ),
    toggleableActiveColor: Colors.blue,
    dividerColor: Color(0xFFF8F8F8),
    scaffoldBackgroundColor: AppColors.lightBG,
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.mainColor,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        primary: Colors.black12,
        onPrimary: Colors.black,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.dark,
    backgroundColor: AppColors.darkBG,
    primaryColor: AppColors.darkPrimary,
    accentColor: AppColors.darkAccent,
    scaffoldBackgroundColor: AppColors.darkBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkAccent,
    ),
    toggleableActiveColor: Colors.blueAccent,
    dividerColor: Color(0xFF2F2F2F),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.darkAccent,
    ),
    buttonColor: AppColors.darkAccent,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        primary: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        primary: Colors.white12,
        onPrimary: Colors.white,
      ),
    ),
  );
}
