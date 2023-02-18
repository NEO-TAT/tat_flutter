// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  static final AppProvider instance = AppProvider._();

  factory AppProvider() => instance;

  AppProvider._() {
    checkTheme();
  }

  ThemeData get theme => (() => _theme)();
  ThemeData _theme = Get.isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
  final Key key = UniqueKey();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void setTheme(ThemeData value, String colorName) {
    _theme = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("theme", colorName).then((val) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: colorName == "dark" ? AppColors.darkPrimary : AppColors.mainColor,
          statusBarIconBrightness: colorName == "dark" ? Brightness.light : Brightness.dark,
        ));
      });
    });
    notifyListeners();
  }

  Future<ThemeData> checkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    late final ThemeData t;
    final r = prefs.getString("theme") ?? "dark";

    if (r == "light") {
      t = AppThemes.lightTheme;
      setTheme(AppThemes.lightTheme, "light");
    } else {
      t = AppThemes.darkTheme;
      setTheme(AppThemes.darkTheme, "dark");
    }

    return t;
  }
}
