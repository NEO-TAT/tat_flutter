import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/UserDataJson.dart';
import '../store/Model.dart';
import '../store/json/UserDataJson.dart';
import 'core/Connector.dart';
import 'core/ConnectorParameter.dart';

enum NTUTConnectorStatus {
  LoginSuccess,
  PasswordExpiredWarning,
  AccountLockWarning, //帳號鎖住
  AccountPasswordIncorrect,
  AuthCodeFailError, //驗證碼錯誤
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class NTUTConnector {
  static bool _isLogin = true;
  static final String _Host = "https://nportal.ntut.edu.tw/";
  static final String _loginUrl = _Host + "login.do";
  static final String _indexUrl = _Host + "index.do";
  static final String _getPictureUrl = _Host + "photoView.do";
  static final String _checkLoginUrl = _Host + "myPortal.do";
  static final String _getCalendarUrl = _Host + "calModeApp.do";

  static Future<NTUTConnectorStatus> login(
      String account, String password) async {
    try {
      ConnectorParameter parameter;
      _isLogin = false;
      Map<String, String> data = {
        "muid": account,
        "mpassword": password,
        "forceMobile": "mobile",
        //"rememberUidValue": "" ,
        //"rememberPwdValue" : "1" ,
        //"authcode" : "" ,
        "md5Code": "1111",
        "ssoId": ""
      };
      parameter = ConnectorParameter(_loginUrl);
      parameter.data = data;
      parameter.userAgent = "Direk Android App";
      String jsonResult = await Connector.getDataByPost(parameter);
      parameter.userAgent = "";
      String result = await Connector.getDataByPost(parameter);
      if (result.contains("帳號或密碼錯誤")) {
        return NTUTConnectorStatus.AccountPasswordIncorrect;
      } else if (result.contains("驗證碼")) {
        return NTUTConnectorStatus.AuthCodeFailError;
      } else if (result.contains("帳號已被鎖住")) {
        return NTUTConnectorStatus.AccountLockWarning;
      } else if (result.contains("重新登入")) {
        return NTUTConnectorStatus.UnknownError;
      } else {
        UserInfoJson userInfo = UserInfoJson.fromJson(json.decode(jsonResult));
        Model.instance.userData.info = userInfo;
        Model.instance.save(Model.userDataJsonKey);
        if (userInfo.passwordExpiredRemind == 'true') {
          return NTUTConnectorStatus.PasswordExpiredWarning;
        }
        _isLogin = true;
        return NTUTConnectorStatus.LoginSuccess;
      }
    } catch (e) {
      Log.e(e.toString());
      if (e is TimeoutException || e is DioError) {
        return NTUTConnectorStatus.ConnectTimeOutError;
      } else if (e is SocketException) {
        return NTUTConnectorStatus.NetworkError;
      }
      return NTUTConnectorStatus.UnknownError;
    }
  }

  static Future<String> getCalendar(DateTime startTime , DateTime endTime ) async{
    ConnectorParameter parameter;
    try {
      Map<String, String> data = {
        "stratDate": "2020/03/01",
        "endDate": "2020/04/01",
      };
      parameter = ConnectorParameter( _getCalendarUrl );
      parameter.data = data;
      Response response = await Connector.getDataByGetResponse(parameter);
      return null;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Widget getUserImage() {
    Widget image;
    String userPhoto = Model.instance.userData.info.userPhoto;
    Log.d("getUserImage");
    String url = _getPictureUrl;
    Map<String, String> data = {"realname": userPhoto};
    if (userPhoto.isNotEmpty) {
      url =
          Uri.https(Uri.parse(url).host, Uri.parse(url).path, data).toString();
    }
    Log.d(url);
    image = CachedNetworkImage(
      imageUrl: url,
      httpHeaders: Connector.getLoginHeaders(url),
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 30.0,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
    return image;
  }

  static bool get isLogin {
    return _isLogin;
  }

  static Future<bool> checkLogin() async {
    Log.d("NTUT CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    try {
      parameter = ConnectorParameter(_checkLoginUrl);
      String result = await Connector.getDataByGet(parameter);
      if (result.isEmpty || result.contains("請重新登入")) {
        return false;
      } else {
        Log.d("NTUT Is Readly Login");
        _isLogin = true;
        return true;
      }
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return false;
    }
  }
}
