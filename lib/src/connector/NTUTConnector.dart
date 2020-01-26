import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/DataModel.dart';
import 'package:flutter_app/src/store/dataformat/UserData.dart';
import 'package:flutter_app/src/store/json/UserDataJson.dart';
import 'package:html/parser.dart';

import 'Connector.dart';
import 'ConnectorParameter.dart';

enum NTUTLoginStatus {
  LoginSuccess ,
  PasswordExpiredWarning ,
  AccountLockWarning ,   //帳號鎖住
  AccountPasswordIncorrect ,
  AuthCodeFailError ,  //驗證碼錯誤
  ConnectTimeOutError ,
  NetworkError ,
  UnknownError
}

class NTUTConnector {
  static bool _isLogin = false;
  static final String _loginUrl = "https://nportal.ntut.edu.tw/login.do";
  static final String _indexUrl = "https://nportal.ntut.edu.tw/index.do";
  static final String _getPictureUrl = "https://nportal.ntut.edu.tw/photoView.do?realname=";
  static final String _checkLoginUrl = "https://nportal.ntut.edu.tw/myPortal.do";

  static Future<NTUTLoginStatus> login(String account , String password) async{
    try {
      ConnectorParameter parameter;
      _isLogin = false;
      Map<String, String> data = {
        "muid": account,
        "mpassword": password,
        "forceMobile": "mobile" ,
        //"authcode" : "" ,
        //"md5Code" : ""
      };
      parameter = ConnectorParameter(_loginUrl);
      parameter.data = data;
      parameter.userAgent = "Direk Android App";
      String result = await Connector.getDataByPost( parameter );
      if (result.contains("帳號或密碼錯誤")) {
        return NTUTLoginStatus.AccountPasswordIncorrect;
      } else if (result.contains("驗證碼")) {
        return NTUTLoginStatus.AuthCodeFailError;
      } else if (result.contains("帳號已被鎖住")) {
        return NTUTLoginStatus.AccountLockWarning;
      }else if (result.contains("重新登入")) {
        return NTUTLoginStatus.UnknownError;
      } else {
        UserDataJson jsonParse = UserDataJson.fromJson(json.decode(result));
        UserData user = DataModel.instance.user;
        user.givenName = jsonParse.givenName;
        user.userMail = jsonParse.userMail;
        user.userPhoto = jsonParse.userPhoto;
        user.passwordExpiredRemind = jsonParse.passwordExpiredRemind;
        user.userDn = jsonParse.userDn;
        //user.save();
        if ( user.passwordExpiredRemind == 'true' ){
          return NTUTLoginStatus.PasswordExpiredWarning;
        }
        _isLogin = true;
        return NTUTLoginStatus.LoginSuccess;
      }
    } on Exception catch(e){
      Log.e(e.toString());
      if ( e is TimeoutException){
        return NTUTLoginStatus.ConnectTimeOutError;
      }
      else if ( e is SocketException){
        return NTUTLoginStatus.NetworkError;
      }
      return NTUTLoginStatus.UnknownError;
    }
  }

  static CachedNetworkImageProvider getUserImage(){
    ImageProvider image ;
    String userPhoto = DataModel.instance.user.userPhoto;
    if ( NTUTConnector.isLogin && userPhoto!=null){
      Log.d( "getUserImage");
      String userPhoto = DataModel.instance.user.userPhoto;
      String url = _getPictureUrl + userPhoto;
      image = CachedNetworkImageProvider(
          url,
          headers: Connector.getLoginHeaders(url)
      );
    }else {
      Log.d( "getUserImage Fail");
      image = CachedNetworkImageProvider(
          "http://cdn.onlinewebfonts.com/svg/img_311846.png"
      );
    }
    return image;
  }

  static bool get isLogin {
    return _isLogin;
  }

  static Future<bool> checkLogin() async{
    Log.d("NTUT CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    try{
      parameter = ConnectorParameter(_checkLoginUrl);
      String result = await Connector.getDataByGet( parameter );
      if (result.isEmpty || result.contains("請重新登入")) {
        return false;
      } else {
        Log.d("NTUT Is Readly Login");
        _isLogin = true;
        return true;
      }
    }on Exception catch(e){
      throw e;
    }

  }

}