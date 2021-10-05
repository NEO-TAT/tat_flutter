import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tat/src/config/app_colors.dart';
import 'package:tat/src/config/app_themes.dart';
import 'package:tat/ui/other/my_toast.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    checkTheme();
  }

  ThemeData theme = AppThemes.darkTheme;
  UniqueKey key = UniqueKey();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void setKey(UniqueKey value) {
    key = value;
    notifyListeners();
  }

  void setNavigatorKey(GlobalKey<NavigatorState> value) {
    navigatorKey = value;
    notifyListeners();
  }

  void setTheme(ThemeData value, String c) {
    theme = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("theme", c).then((val) {
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor:
              c == "dark" ? AppColors.darkPrimary : AppColors.mainColor,
          statusBarIconBrightness:
              c == "dark" ? Brightness.light : Brightness.dark,
        ));
      });
    });
    notifyListeners();
  }

  ThemeData getTheme() => theme;

  Future<ThemeData> checkTheme() async {
    final prefs = await SharedPreferences.getInstance();
    ThemeData t;
    final String? r =
        prefs.getString("theme") == null ? "dark" : prefs.getString("theme");

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
