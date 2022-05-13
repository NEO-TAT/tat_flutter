// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/model/setting/setting_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';

enum LangEnum { en, zh }

class LanguageUtil {
  static Future<void> init(BuildContext context) async {
    OtherSettingJson otherSetting = LocalStorage.instance.getOtherSetting();
    if (otherSetting.lang.isEmpty || !otherSetting.lang.contains("_")) {
      //如果沒有設定語言使用手機目前語言
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
      String lang = locale2String(locale);
      OtherSettingJson otherSetting = LocalStorage.instance.getOtherSetting();
      if (otherSetting.lang != lang) {
        //只有不相同時可以載入
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
    String countryCode = locale.countryCode ?? "";
    String languageCode = locale.languageCode ?? "";
    return '${countryCode}_$languageCode';
  }

  static Locale string2Locale(String lang) {
    try {
      String countryCode = lang.split("_")[0];
      String languageCode = lang.split("_")[1];
      for (Locale locale in getSupportLocale) {
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
    Locale locale = getSupportLocale[langEnum.index];
    await load(locale);
  }

  static LangEnum getLangIndex() {
    OtherSettingJson otherSetting = LocalStorage.instance.getOtherSetting();
    int index = getSupportLocale.indexOf(string2Locale(otherSetting.lang));
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