// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/model/ntut/ap_tree_json.dart';
import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/model/userdata/user_data_json.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tat_core/core/portal/domain/login_credential.dart';
import 'package:tat_core/core/portal/domain/simple_login_result.dart';
import 'package:tat_core/core/portal/usecase/simple_login_use_case.dart';

enum NTUTConnectorStatus {
  loginSuccess,
  accountLockWarning,
  accountPasswordIncorrect,
  authCodeFailError,
  unknownError,
}

class NTUTConnector {
  static const host = "https://app.ntut.edu.tw/";
  static const _getPictureUrl = "${host}photoView.do";
  static const _getTreeUrl = "${host}aptreeList.do";
  static const _getCalendarUrl = "${host}calModeApp.do";
  static const _changePasswordUrl = "${host}passwordMdy.do";

  static Future<NTUTConnectorStatus> login(String account, String password) async {
    final simpleLoginUseCase = Get.find<SimpleLoginUseCase>();
    final loginCredential = LoginCredential(userId: account, password: password);
    final loginResult = await simpleLoginUseCase(credential: loginCredential);

    Log.d(loginResult.resultType);

    await FirebaseAnalytics.instance.logLogin(
      loginMethod: 'ntut_portal_new',
    );

    switch (loginResult.resultType) {
      case SimpleLoginResultType.success:
      case SimpleLoginResultType.needsVerifyMobile:
        final userInfo = UserInfoJson(
          givenName: loginResult.userNaturalName,
          userMail: loginResult.userMail,
          userPhoto: loginResult.userPhotoName,
          userDn: loginResult.userDn,
          passwordExpiredRemind: loginResult.passwordExpiredRemind,
        );

        LocalStorage.instance.setUserInfo(userInfo);
        LocalStorage.instance.saveUserData();
        return NTUTConnectorStatus.loginSuccess;

      case SimpleLoginResultType.wrongCredential:
        return NTUTConnectorStatus.accountPasswordIncorrect;

      case SimpleLoginResultType.locked:
        return NTUTConnectorStatus.accountLockWarning;

      case SimpleLoginResultType.needsResetPassword:
      case SimpleLoginResultType.unknown:
        return NTUTConnectorStatus.unknownError;
    }
  }

  static Future<List<NTUTCalendarJson>?> getCalendar(DateTime startTime, DateTime endTime) async {
    final formatter = DateFormat("yyyy/MM/dd");
    final startDate = formatter.format(startTime);
    final endDate = formatter.format(endTime);
    try {
      final data = {
        "startDate": startDate,
        "endDate": endDate,
      };
      final parameter = ConnectorParameter(_getCalendarUrl);
      parameter.data = data;
      final result = await Connector.getDataByGet(parameter);
      final calendarList = getNTUTCalendarJsonList(json.decode(result));
      return calendarList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<APTreeJson?> getTree(String? arg) async {
    try {
      final parameter = ConnectorParameter(_getTreeUrl);
      if (arg != null) {
        parameter.data = {"apDn": arg};
      }
      final result = await Connector.getDataByPost(parameter);
      final apTreeJson = APTreeJson.fromJson(json.decode(result));
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

  static Future<String?> changePassword(String password) async {
    try {
      final parameter = ConnectorParameter(_changePasswordUrl);
      final oldPassword = LocalStorage.instance.getPassword();
      parameter.data = {
        "userPassword": password,
        "oldPassword": oldPassword,
        "pwdForceMdy": "profile",
      };
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
}
