import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'MyFont',
    brightness: Brightness.light,
    primaryColor: AppColors.mainColor,
    appBarTheme: const AppBarTheme(
      color: Colors.blueAccent,
    ),
    dividerColor: const Color(0xFF2F2F2F),
    highlightColor: const Color(0xFFF8F8F8),
    scaffoldBackgroundColor: AppColors.lightBG,
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: AppColors.mainColor,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.lightAccent),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
    ),
    colorScheme:
        ColorScheme.fromSwatch().copyWith(secondary: AppColors.lightAccent).copyWith(background: AppColors.lightBG),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'MyFont',
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBG,
    dividerColor: const Color(0xFFF8F8F8),
    highlightColor: const Color(0xFF2F2F2F),
    appBarTheme: const AppBarTheme(
      color: Colors.black26,
    ),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.darkAccent,
    ),
    textSelectionTheme: TextSelectionThemeData(cursorColor: AppColors.darkAccent),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return null;
        }
        if (states.contains(MaterialState.selected)) {
          return Colors.blueAccent;
        }
        return null;
      }),
    ),
  );
}
