import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/generated/l10n.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/store/model.dart';

enum LangEnum { en, zh }

class LanguageUtils {
  static Future<void> init(BuildContext context) async {
    final otherSetting = Model.instance.getOtherSetting();

    if (otherSetting!.lang.isEmpty || !otherSetting.lang.contains("_")) {
      Locale locale = Localizations.localeOf(context);
      load(locale);
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
      final otherSetting = Model.instance.getOtherSetting();

      if (otherSetting!.lang != lang) {
        otherSetting.lang = lang;
        Model.instance.setOtherSetting(otherSetting);
        await Model.instance.saveOtherSetting();
        await Model.instance.clearCourseTableList();
        await Model.instance.clearCourseSetting();
      }
    } else {
      Log.e("no any locale load");
      return;
    }
  }

  static String locale2String(Locale locale) {
    final String countryCode = locale.countryCode ?? "";
    final String languageCode = locale.languageCode;
    return countryCode + '_' + languageCode;
  }

  static Locale string2Locale(String lang) {
    try {
      final String countryCode = lang.split("_")[0];
      final String languageCode = lang.split("_")[1];
      for (final locale in getSupportLocale) {
        if (locale.languageCode == languageCode &&
            locale.countryCode == countryCode) {
          return locale;
        }
      }
    } catch (e) {}
    return getSupportLocale[0];
  }

  static Future<void> setLangByIndex(LangEnum langEnum) async {
    final locale = getSupportLocale[langEnum.index];
    await load(locale);
  }

  static LangEnum getLangIndex() {
    final otherSetting = Model.instance.getOtherSetting();
    final index = getSupportLocale.indexOf(string2Locale(otherSetting!.lang));
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
