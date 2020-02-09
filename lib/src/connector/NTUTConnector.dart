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
  static bool _isLogin = true;
  static final String _loginUrl = "https://nportal.ntut.edu.tw/login.do";
  static final String _indexUrl = "https://nportal.ntut.edu.tw/index.do";
  static final String _getPictureUrl = "https://nportal.ntut.edu.tw/photoView.do";
  static final String _checkLoginUrl = "https://nportal.ntut.edu.tw/myPortal.do";

  static Future<NTUTConnectorStatus> login(String account , String password) async{
    try {
      ConnectorParameter parameter;
      _isLogin = false;
      Map<String, String> data = {
        "muid": account,
        "mpassword": password,
        "forceMobile": "mobile" ,
        //"rememberUidValue": "" ,
        //"rememberPwdValue" : "1" ,
        //"authcode" : "" ,
        "md5Code" : "1111" ,
        "ssoId" : ""
      };
      parameter = ConnectorParameter(_loginUrl);
      parameter.data = data;
      parameter.userAgent = "Direk Android App";
      String jsonResult = await Connector.getDataByPost( parameter );
      parameter.userAgent = "";
      String result = await Connector.getDataByPost( parameter );
      if (result.contains("帳號或密碼錯誤")) {
        return NTUTConnectorStatus.AccountPasswordIncorrect;
      } else if (result.contains("驗證碼")) {
        return NTUTConnectorStatus.AuthCodeFailError;
      } else if (result.contains("帳號已被鎖住")) {
        return NTUTConnectorStatus.AccountLockWarning;
      }else if (result.contains("重新登入")) {
        return NTUTConnectorStatus.UnknownError;
      } else {
        UserInfoJson userInfo = UserInfoJson.fromJson(json.decode(jsonResult));
        Model.instance.userData.info = userInfo;
        Model.instance.save( Model.userDataJsonKey );
        if ( userInfo.passwordExpiredRemind == 'true' ){
          return NTUTConnectorStatus.PasswordExpiredWarning;
        }
        _isLogin = true;
        return NTUTConnectorStatus.LoginSuccess;
      }
    } catch(e){
      Log.e(e.toString());
      if ( e is TimeoutException || e is DioError ){
        return NTUTConnectorStatus.ConnectTimeOutError;
      }
      else if ( e is SocketException){
        return NTUTConnectorStatus.NetworkError;
      }
      return NTUTConnectorStatus.UnknownError;
    }
  }

  static CachedNetworkImageProvider getUserImage(){
    ImageProvider image ;
    String userPhoto = Model.instance.userData.info.userPhoto ;
    if ( NTUTConnector.isLogin && userPhoto!=null){
      Log.d( "getUserImage");
      String url = _getPictureUrl;
      Map<String,String> data = {
        "realname" : userPhoto
      };
      url = Uri.https( Uri.parse(url).host , Uri.parse(url).path , data ).toString();
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
    } catch(e){
      //throw e;
      Log.e(e.toString());
      return false;
    }

  }

}