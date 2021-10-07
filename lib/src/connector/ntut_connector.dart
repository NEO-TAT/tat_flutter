//  北科課程助手

import 'dart:async';
import 'dart:convert';

import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/src/connector/core/connector.dart';
import 'package:tat/src/connector/core/connector_parameter.dart';
import 'package:tat/src/model/ntut/ap_tree_json.dart';
import 'package:tat/src/model/ntut/ntut_calendar_json.dart';
import 'package:tat/src/model/userdata/user_data_json.dart';
import 'package:tat/src/store/model.dart';

enum NTUTConnectorStatus {
  LoginSuccess,
  PasswordExpiredWarning,
  AccountLockWarning,
  AccountPasswordIncorrect,
  AuthCodeFailError,
  UnknownError
}

class OrgtreeSearchResult {
  OrgtreeSearchResult({
    this.id,
    this.name,
    this.msg,
  });

  String? id;
  String? name;
  String? msg;
}

class NTUTConnector {
  static const host = "https://app.ntut.edu.tw/";
  static const _loginUrl = host + "login.do";
  static const _getPictureUrl = host + "photoView.do";
  static const _getTreeUrl = host + "aptreeList.do";
  static const _getCalendarUrl = host + "calModeApp.do";
  static const _changePasswordUrl = host + "passwordMdy.do";
  static const _orgtreeSearchUrl = host + "orgtreeSearch.do";

  static Future<NTUTConnectorStatus> login(
    String account,
    String password,
  ) async {
    try {
      final data = {
        "muid": account,
        "mpassword": password,
        "forceMobile": "app",
        "md5Code": "1111",
        "ssoId": ""
      };

      final parameter = ConnectorParameter(_loginUrl)
        ..data = data
        ..userAgent = 'Direk Android App'
        ..userAgent = '';

      final result = await Connector.getDataByPost(parameter);
      final jsonMap = json.decode(result);

      if (jsonMap["success"]) {
        final userInfo = UserInfoJson.fromJson(jsonMap);
        Model.instance.setUserInfo(userInfo);
        Model.instance.saveUserData();

        if (userInfo.passwordExpiredRemind.isNotEmpty) {
          return NTUTConnectorStatus.PasswordExpiredWarning;
        }

        return NTUTConnectorStatus.LoginSuccess;
      } else {
        final errorMsg = jsonMap["errorMsg"];

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

  static Future<List<NTUTCalendarJson>?> getCalendar(
    DateTime startTime,
    DateTime endTime,
  ) async {
    final formatter = DateFormat("yyyy/MM/dd");
    final startDate = formatter.format(startTime);
    final endDate = formatter.format(endTime);

    try {
      final data = {
        "startDate": startDate,
        "endDate": endDate,
      };

      final parameter = ConnectorParameter(_getCalendarUrl)..data = data;
      final result = await Connector.getDataByGet(parameter);
      final calendarList = getNTUTCalendarJsonList(json.decode(result));

      return calendarList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<APTreeJson?> getTree(String arg) async {
    try {
      final data = {"apDn": arg};
      final parameter = ConnectorParameter(_getTreeUrl)..data = data;
      final result = await Connector.getDataByPost(parameter);
      final apTreeJson = APTreeJson.fromJson(json.decode(result));

      return apTreeJson;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Map getUserImage() {
    final imageInfo = Map();
    final userPhoto = Model.instance.getUserInfo()!.userPhoto;

    Log.d("getUserImage");

    String url = _getPictureUrl;
    final data = {"realname": userPhoto};

    if (userPhoto.isNotEmpty) {
      url =
          Uri.https(Uri.parse(url).host, Uri.parse(url).path, data).toString();
    }

    imageInfo["url"] = url;
    imageInfo["header"] = Connector.getLoginHeaders(url);
    return imageInfo;
  }

  static Future<String?> changePassword(String password) async {
    try {
      final data = {
        "userPassword": password,
        "oldPassword": Model.instance.getPassword(),
        "pwdForceMdy": "profile",
      };

      final parameter = ConnectorParameter(_changePasswordUrl)..data = data;
      final result = await Connector.getDataByPost(parameter);
      final jsonResult = json.decode(result);

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

  static Future<List<OrgtreeSearchResult>?> orgtreeSearch(
      String keyword) async {
    final List<OrgtreeSearchResult> orgtreeSearchList = [];

    try {
      final data = {
        "searchType": '1',
        "excuteFunction": "orgtreeEntryShow",
        "submitFunction": "",
        "searchKeyword": keyword
      };
      final parameter = ConnectorParameter(_orgtreeSearchUrl)..data = data;
      final result = await Connector.getDataByGet(parameter);

      final nodes = parse(result)
          .getElementsByClassName("eipOrgTreeDisplay")
          .first
          .getElementsByTagName("div");

      for (final node in nodes) {
        final r = OrgtreeSearchResult();
        r.id = node.getElementsByTagName("input").last.attributes["value"];
        r.name = node.getElementsByTagName("span").first.text;
        r.msg = node.text;
        orgtreeSearchList.add(r);
      }

      return orgtreeSearchList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
