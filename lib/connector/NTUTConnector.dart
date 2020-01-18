import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/connector/Connector.dart';
import 'package:flutter_app/database/DataModel.dart';
import 'package:flutter_app/database/dataformat/UserData.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:html/parser.dart';

enum LoginStatus {
  LoginSuccess ,
  LoginFail ,
  AccountLock ,   //帳號鎖住
  AuthCodeFail ,  //驗證碼錯誤
  AccountPasswordFail ,
  ConnectTimeOut ,
  UnknownError
}

class NTUTConnector {
  static final String loginUrl = "https://nportal.ntut.edu.tw/login.do";
  static final String indexUrl = "https://nportal.ntut.edu.tw/index.do";
  static final String getPictureUrl = "https://nportal.ntut.edu.tw/photoView.do?realname=";
  static final String checkLoginUrl = "https://nportal.ntut.edu.tw/myPortal.do";

  static Future<LoginStatus> login(String account , String password) async{
    Map<String, String> data = {
      "muid": account,
      "mpassword": password,
      "forceMobile": "mobile" ,
      "authcode" : "" ,
      "md5Code" : ""
    };
    try {
      String result = await Connector.getDataByPost(loginUrl, data);
      if (result.contains("帳號或密碼錯誤")) {
        return LoginStatus.AccountPasswordFail;
      } else if (result.contains("驗證碼")) {
        return LoginStatus.AuthCodeFail;
      } else if (result.contains("帳號已被鎖住")) {
        return LoginStatus.AccountLock;
      } else {
        //Log.d(  UserData.fromJson(json.decode(result)).toString() );
        return LoginStatus.LoginSuccess;
      }
    } on Exception catch(e){
      Log.e(e.toString());
      if ( e is TimeoutException){
        return LoginStatus.ConnectTimeOut;
      }
      return LoginStatus.UnknownError;
    }
  }
}