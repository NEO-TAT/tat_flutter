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

class Lang {
  static Future<void> load([Locale myLocale]) async {
    if (Model.instance.setting.other.lang.isEmpty && myLocale != null) {
      if (myLocale.toString().contains("zh")) {
        Model.instance.setting.other.lang = "zh";
      } else {
        Model.instance.setting.other.lang = "en";
      }
      await Model.instance.save(Model.settingJsonKey);
    }
    Locale locale;
    switch (Model.instance.setting.other.lang) {
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
  }

  static Future<void> setLang(String lang) async {
    if (Model.instance.setting.other.lang.contains(lang)) {
      return;
    } else {
      await Model.instance.clear( Model.courseTableJsonKey );
      Model.instance.setting.course = CourseSettingJson();
      await Model.instance.save( Model.settingJsonKey );
      await Model.instance.init();
      switch (lang) {
        case "zh":
          Model.instance.setting.other.lang = "zh";
          break;
        default:
          Model.instance.setting.other.lang = "en";
          break;
      }
      await Model.instance.save(Model.settingJsonKey);
      Log.d( Model.instance.setting.other.lang );
      await load();
    }
  }


  static double getLangIndex(){
    return Model.instance.setting.other.lang.contains("zh") ? 1:0;
  }

}
