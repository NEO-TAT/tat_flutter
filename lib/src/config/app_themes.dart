import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tat/src/config/app_colors.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.light,
    backgroundColor: AppColors.lightBG,
    primaryColor: AppColors.mainColor,
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
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: AppColors.lightAccent),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'MyFont',
    brightness: Brightness.dark,
    backgroundColor: AppColors.darkBG,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBG,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkAccent,
    ),
    toggleableActiveColor: Colors.blueAccent,
    dividerColor: Color(0xFF2F2F2F),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.darkAccent,
    ),
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
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: AppColors.darkAccent),
  );
}
