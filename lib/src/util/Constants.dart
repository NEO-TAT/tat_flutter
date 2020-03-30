import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/costants/app_colors.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Constants {
  //App related strings
  static String appName = "TAT";

  //Colors for theme
  static Color lightPrimary = Colors.white;
  static Color darkPrimary = Color(0xff2B2B2B);
  static Color lightAccent = Color(0xff597ef7);
  static Color darkAccent = Color(0xff4F4F4f);
  static Color lightBG = Colors.white;
  static Color darkBG = Color(0xEE2B2B2B);
  static Color hyperlinkColor = Colors.blue;

/*
  static ThemeData lightTheme = ThemeData(
    backgroundColor: lightBG,
    primaryColor: lightPrimary,
    accentColor: lightAccent,
    cursorColor: lightAccent,
    scaffoldBackgroundColor: lightBG,
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        title: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cursorColor: darkAccent,
    appBarTheme: AppBarTheme(
      elevation: 0,
      textTheme: TextTheme(
        title: TextStyle(
          color: lightBG,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

 */

  static ThemeData lightTheme = ThemeData(
    fontFamily: 'GenSenMaruGothicTW',
    backgroundColor: lightBG,
    primaryColor: AppColors.mainColor,
    accentColor: lightAccent,
    cursorColor: lightAccent,
    dividerColor: Color(0xFFF8F8F8),
    scaffoldBackgroundColor: lightBG,
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: AppColors.mainColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'GenSenMaruGothicTW',
    brightness: Brightness.dark,
    backgroundColor: darkBG,
    primaryColor: darkPrimary,
    accentColor: darkAccent,
    scaffoldBackgroundColor: darkBG,
    cursorColor: darkAccent,
    dividerColor: Color(0xEE2F2F2F),
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: darkAccent,
    ),
    buttonColor: darkAccent,
  );

  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  static List sortList = [
    "File name (A to Z)",
    "File name (Z to A)",
    "Date (oldest first)",
    "Date (newest first)",
    "Size (largest first)",
    "Size (Smallest first)",
  ];
}
