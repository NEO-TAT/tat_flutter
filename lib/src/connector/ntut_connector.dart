// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/model/ntut/ap_tree_json.dart';
import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/model/userdata/user_data_json.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:intl/intl.dart';

enum NTUTConnectorStatus {
  loginSuccess,
  accountLockWarning, //帳號鎖住
  accountPasswordIncorrect,
  authCodeFailError, //驗證碼錯誤
  unknownError
}

class NTUTConnector {
  static const host = "https://app.ntut.edu.tw/";
  static const _loginUrl = "${host}login.do";
  static const _getPictureUrl = "${host}photoView.do";
  static const _getTreeUrl = "${host}aptreeList.do";
  static const _getCalendarUrl = "${host}calModeApp.do";
  static const _changePasswordUrl = "${host}passwordMdy.do";

  static Future<NTUTConnectorStatus> login(String account, String password) async {
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
        LocalStorage.instance.setUserInfo(userInfo);
        LocalStorage.instance.saveUserData();
        // if the user's password is nearly to expired, `userInfo.passwordExpiredRemind.isNotEmpty` will be true.
        return NTUTConnectorStatus.loginSuccess;
      } else {
        String errorMsg = jsonMap["errorMsg"];
        if (errorMsg.contains("帳號或密碼錯誤")) {
          return NTUTConnectorStatus.accountPasswordIncorrect;
        } else if (errorMsg.contains("驗證碼")) {
          return NTUTConnectorStatus.authCodeFailError;
        } else if (errorMsg.contains("帳號已被鎖住")) {
          return NTUTConnectorStatus.accountLockWarning;
        } else {
          return NTUTConnectorStatus.unknownError;
        }
      }
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return NTUTConnectorStatus.unknownError;
    }
  }

  static Future<List<NTUTCalendarJson>> getCalendar(DateTime startTime, DateTime endTime) async {
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
      List<NTUTCalendarJson> calendarList = getNTUTCalendarJsonList(json.decode(result));
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

  static Future<Map<String, Map<String, String>>> getUserImageRequestInfo() async {
    final imageInfo = <String, Map<String, String>>{};
    final userPhoto = LocalStorage.instance.getUserInfo().userPhoto;
    Log.d("getUserImage");

    final url = '$_getPictureUrl?realname=$userPhoto';

    imageInfo['url'] = {'value': url};
    imageInfo['header'] = await Connector.getLoginHeaders(url);

    return imageInfo;
  }

  static Future<String> changePassword(String password) async {
    ConnectorParameter parameter;
    String result;
    try {
      parameter = ConnectorParameter(_changePasswordUrl);
      String oldPassword = LocalStorage.instance.getPassword();
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