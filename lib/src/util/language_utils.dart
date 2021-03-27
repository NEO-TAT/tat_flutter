//
//  language_utils.dart
//  北科課程助手
//  切換語言用
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/model/setting/setting_json.dart';
import 'package:flutter_app/src/store/model.dart';

enum LangEnum { en, zh }

class LanguageUtils {
  static Future<void> init(BuildContext context) async {
    OtherSettingJson otherSetting = Model.instance.getOtherSetting();
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
      OtherSettingJson otherSetting = Model.instance.getOtherSetting();
      if (otherSetting.lang != lang) {
        //只有不相同時可以載入
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
    String countryCode = locale.countryCode ?? "";
    String languageCode = locale.languageCode ?? "";
    return countryCode + '_' + languageCode;
  }

  static Locale string2Locale(String lang) {
    try {
      String countryCode = lang.split("_")[0];
      String languageCode = lang.split("_")[1];
      for (Locale locale in getSupportLocale) {
        if (locale.languageCode == languageCode &&
            locale.countryCode == countryCode) {
          return locale;
        }
      }
    } catch (e) {}
    return getSupportLocale[0];
  }

  static Future<void> setLangByIndex(LangEnum langEnum) async {
    Locale locale = getSupportLocale[langEnum.index];
    await load(locale);
  }

  static LangEnum getLangIndex() {
    OtherSettingJson otherSetting = Model.instance.getOtherSetting();
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
