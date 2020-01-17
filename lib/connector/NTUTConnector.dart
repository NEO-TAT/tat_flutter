import 'package:flutter_app/connector/Connector.dart';
import 'package:flutter_app/debug/log/Log.dart';

enum LoginStatus {
  LoginSuccess ,
  LoginFail ,
  AuthCodeFail ,
  ConnectTimeOut ,
  ErrorTimeOut ,
  AccountPasswordFail
}

class NTUTConnector {
  static final String _className = 'NtutConnector';
  static final String loginUrl = "https://nportal.ntut.edu.tw/login.do";
  static final String indexUrl = "https://nportal.ntut.edu.tw/index.do";
  static final String NPORTAL_GET_PICTURE_URI = "https://nportal.ntut.edu.tw/photoView.do?realname=";
  static final String NPORTAL_CHECKLOGIN_URI = "https://nportal.ntut.edu.tw/myPortal.do";

  static void login(String account , String password) async{
    Log.e( _className , account );
    Log.e( _className , password );
    Map<String, String> data = {
      'muid': account,
      'mpassword': password,
      'authcode': 'getDataByPost ',
      'md5Code' : ''
    };
    String result = await Connector.getDataByPost(loginUrl, data);
    result = await Connector.getDataByGet(indexUrl);
    Log.e( _className , result);
  }
}