//
//  Lang.dart
//  北科課程助手
//  切換語言用
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/SettingJson.dart';

enum LangEnum{ en , zh }

class Lang {
  static Future<void> load([Locale myLocale]) async {
    OtherSettingJson otherSetting = OtherSettingJson();
    otherSetting = Model.instance.getOtherSetting();
    if (  otherSetting.lang.isEmpty && myLocale != null  ) {
      if (myLocale.toString().contains("zh")) {
        otherSetting.lang = "zh";
      } else {
        otherSetting.lang = "en";
      }
    }
    Locale locale;
    switch (otherSetting.lang) {
      case "zh":
        locale = Locale("zh", "");
        break;
      case "en":
        locale = Locale("en", "");
        break;
      default:
        locale = Locale("en", "");
        break;
    }
    S.delegate.load(locale);

    Model.instance.setOtherSetting(otherSetting);
    await Model.instance.saveOtherSetting();

  }

  static Future<void> setLang(String lang) async {
    OtherSettingJson otherSetting = OtherSettingJson();
    otherSetting = Model.instance.getOtherSetting();
    if ( otherSetting.lang.contains(lang)) {
      return;
    } else {
      await Model.instance.clearCourseTableList();
      await Model.instance.clearCourseSetting();
      switch (lang) {
        case "zh":
          otherSetting.lang = "zh";
          break;
        default:
          otherSetting.lang = "en";
          break;
      }
      Model.instance.setOtherSetting(otherSetting);
      await Model.instance.saveOtherSetting();
      await load();
    }
  }

  static LangEnum getLangIndex(){
    OtherSettingJson otherSetting = OtherSettingJson();
    otherSetting = Model.instance.getOtherSetting();
    return otherSetting.lang.contains("zh") ? LangEnum.zh : LangEnum.en;
  }

}
