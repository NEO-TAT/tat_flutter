//
//  NTUTConnector.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/model/ntut/APTreeJson.dart';
import 'package:flutter_app/src/model/ntut/NTUTCalendarJson.dart';
import 'package:flutter_app/src/model/userdata/UserDataJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:intl/intl.dart';

enum NTUTConnectorStatus {
  LoginSuccess,
  PasswordExpiredWarning,
  AccountLockWarning, //帳號鎖住
  AccountPasswordIncorrect,
  AuthCodeFailError, //驗證碼錯誤
  UnknownError
}

class NTUTConnector {
  static final String host = "https://app.ntut.edu.tw/";
  static final String _loginUrl = host + "login.do";
  static final String _getPictureUrl = host + "photoView.do";
  static final String _getTreeUrl = host + "aptreeList.do";
  static final String _getCalendarUrl = host + "calModeApp.do";
  static final String _changePasswordUrl = host + "passwordMdy.do";

  static Future<NTUTConnectorStatus> login(
      String account, String password) async {
    try {
      ConnectorParameter parameter;
      Map<String, String> data = {
        "muid": account,
        "mpassword": password,
        "forceMobile": "app",
        //"rememberUidValue": "" ,
        //"rememberPwdValue" : "1" ,
        //"authcode" : "" ,
        "md5Code": "1111",
        "ssoId": ""
      };
      parameter = ConnectorParameter(_loginUrl);
      parameter.data = data;
      parameter.userAgent = "Direk Android App";
      String result = await Connector.getDataByPost(parameter);
      parameter.userAgent = "";
      Map jsonMap = json.decode(result);
      if (jsonMap["success"]) {
        UserInfoJson userInfo = UserInfoJson.fromJson(jsonMap);
        Model.instance.setUserInfo(userInfo);
        Model.instance.saveUserData();
        if (userInfo.passwordExpiredRemind.isNotEmpty) {
          return NTUTConnectorStatus.PasswordExpiredWarning;
        }
        return NTUTConnectorStatus.LoginSuccess;
      } else {
        String errorMsg = jsonMap["errorMsg"];
        if (errorMsg.contains("帳號或密碼錯誤")) {
          return NTUTConnectorStatus.AccountPasswordIncorrect;
        } else if (errorMsg.contains("驗證碼")) {
          return NTUTConnectorStatus.AuthCodeFailError;
        } else if (errorMsg.contains("帳號已被鎖住")) {
          return NTUTConnectorStatus.AccountLockWarning;
        } else {
          return NTUTConnectorStatus.UnknownError;
        }
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return NTUTConnectorStatus.UnknownError;
    }
  }

  static Future<List<NTUTCalendarJson>> getCalendar(
      DateTime startTime, DateTime endTime) async {
    //暫無用到 取得學校行事曆
    ConnectorParameter parameter;
    var formatter = DateFormat("yyyy/MM/dd");
    String startDate = formatter.format(startTime);
    String endDate = formatter.format(endTime);
    try {
      Map<String, String> data = {
        "startDate": startDate,
        "endDate": endDate,
      };
      parameter = ConnectorParameter(_getCalendarUrl);
      parameter.data = data;
      String result = await Connector.getDataByGet(parameter);
      List<NTUTCalendarJson> calendarList =
          getNTUTCalendarJsonList(json.decode(result));
      return calendarList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<APTreeJson> getTree(String arg) async {
    ConnectorParameter parameter;
    try {
      parameter = ConnectorParameter(_getTreeUrl);
      if (arg != null) {
        parameter.data = {"apDn": arg};
      }
      String result = await Connector.getDataByPost(parameter);
      APTreeJson apTreeJson = APTreeJson.fromJson(json.decode(result));
      return apTreeJson;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  /*
  Map key
  url
  header
   */
  static Map getUserImage() {
    Map imageInfo = Map();
    String userPhoto = Model.instance.getUserInfo().userPhoto;
    Log.d("getUserImage");
    String url = _getPictureUrl;
    Map<String, String> data = {"realname": userPhoto};
    if (userPhoto.isNotEmpty) {
      url =
          Uri.https(Uri.parse(url).host, Uri.parse(url).path, data).toString();
    }
    imageInfo["url"] = url;
    imageInfo["header"] = Connector.getLoginHeaders(url);
    return imageInfo;
  }

  static Future<String> changePassword(String password) async {
    ConnectorParameter parameter;
    String result;
    try {
      parameter = ConnectorParameter(_changePasswordUrl);
      String oldPassword = Model.instance.getPassword();
      parameter.data = {
        "userPassword": password,
        "oldPassword": oldPassword,
        "pwdForceMdy": "profile",
      };
      result = await Connector.getDataByPost(parameter);
      var jsonResult = json.decode(result);
      if (jsonResult["success"] == 'true') {
        return "";
      } else {
        return jsonResult["returnMsg"];
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
