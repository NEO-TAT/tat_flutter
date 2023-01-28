// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  static AppProvider instance = AppProvider();

  factory AppProvider() = AppProvider._;

  AppProvider._() {
    checkTheme();
  }

  ThemeData theme = Get.isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
  Key key = UniqueKey();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void setKey(value) {
    key = value;
    notifyListeners();
  }

  void setNavigatorKey(value) {
    navigatorKey = value;
    notifyListeners();
  }

  void setTheme(value, c) {
    theme = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("theme", c).then((val) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: c == "dark" ? AppColors.darkPrimary : AppColors.mainColor,
          statusBarIconBrightness: c == "dark" ? Brightness.light : Brightness.dark,
        ));
      });
    });
    notifyListeners();
  }

  ThemeData getTheme(value) {
    return theme;
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

  void showToast(value) {
    MyToast.show(value);
    notifyListeners();
  }
}
