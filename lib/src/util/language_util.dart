// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/model/setting/setting_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:get/get_utils/get_utils.dart';

enum LangEnum { en, zh }

class LanguageUtil {
  static Future<void> init(BuildContext context) async {
    final otherSetting = LocalStorage.instance.getOtherSetting();
    if (otherSetting.lang.isEmpty || !otherSetting.lang.contains("_")) {
      try {
        final locale = Localizations.localeOf(context);
        load(locale);
      } catch (e) {
        e.printError();
      }
    } else {
      load(string2Locale(otherSetting.lang));
    }
  }

  static List<Locale> get getSupportLocale {
    return S.delegate.supportedLocales;
  }

  static Future<void> load(Locale locale) async {
    if (getSupportLocale.contains(locale)) {
      await R.load(locale);
      final lang = locale2String(locale);
      OtherSettingJson otherSetting = LocalStorage.instance.getOtherSetting();
      if (otherSetting.lang != lang) {
        otherSetting.lang = lang;
        LocalStorage.instance.setOtherSetting(otherSetting);
        await LocalStorage.instance.saveOtherSetting();
        await LocalStorage.instance.clearCourseTableList();
        await LocalStorage.instance.clearCourseSetting();
      }
    } else {
      Log.e("no any locale load");
      return;
    }
  }

  static String locale2String(Locale locale) {
    final countryCode = locale.countryCode ?? "";
    final languageCode = locale.languageCode;
    return '${countryCode}_$languageCode';
  }

  static Locale string2Locale(String lang) {
    try {
      final countryCode = lang.split("_")[0];
      final languageCode = lang.split("_")[1];
      for (final locale in getSupportLocale) {
        if (locale.languageCode == languageCode && locale.countryCode == countryCode) {
          return locale;
        }
      }
    } catch (e) {
      // A syntax to ignore the `avoid empty block` lint error.
      // Thanks to the origin author's PRETTY coding skill & style... :(
      0;
    }
    return getSupportLocale[0];
  }

  static Future<void> setLangByIndex(LangEnum langEnum) async {
    final locale = getSupportLocale[langEnum.index];
    await load(locale);
  }

  static LangEnum getLangIndex() {
    final otherSetting = LocalStorage.instance.getOtherSetting();
    final index = getSupportLocale.indexOf(string2Locale(otherSetting.lang));
    switch (index) {
      case 0:
        return LangEnum.en;
      case 1:
        return LangEnum.zh;
      default:
        return LangEnum.zh;
    }
  }
}
