import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/connector/core/RequestsConnector.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:tripledes/tripledes.dart';
import 'core/ConnectorParameter.dart';

enum ISchoolPlusConnectorStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class ISchoolPlusConnector {
  static bool _isLogin = true;

  static final String _iSchoolPlusUrl = "https://istudy.ntut.edu.tw/";
  static final String _getLoginISchoolUrl = _iSchoolPlusUrl + "mooc/login.php";
  static final String _postLoginISchoolUrl = _iSchoolPlusUrl + "login.php";
  static final String _iSchoolPlusIndexUrl = _iSchoolPlusUrl + "mooc/index.php";
  static final String _iSchoolPlusLearnIndexUrl =
      _iSchoolPlusUrl + "learn/index.php";

  static Future<ISchoolPlusConnectorStatus> login(
      String account, String password) async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Element node;

      await RequestsConnector.deleteCookies(_iSchoolPlusUrl); //刪除先前登入

      parameter = ConnectorParameter(_getLoginISchoolUrl);
      result = await RequestsConnector.getDataByGet(parameter);

      tagNode = parse(result);
      node = tagNode.getElementById("loginForm");
      nodes = node.getElementsByTagName("input");
      String loginKey;
      for (Element node in nodes) {
        if (node.attributes["name"] == "login_key")
          loginKey = node.attributes['value'];
      }

      var bytes = utf8.encode(password);
      String md5Key = md5.convert(bytes).toString();
      String cypKey = md5Key.substring(0, 4) + loginKey.substring(0, 4);
      var blockCipher = new BlockCipher(new DESEngine(), cypKey);
      var encryptPwd = blockCipher.encodeB64(password);
      var password1 = base64.encode(utf8.encode(password));

      String passwordMask = "**********************************";
      Map<String, String> data = {
        "reurl": "",
        "login_key": loginKey,
        "encrypt_pwd": encryptPwd,
        "username": account,
        "password": passwordMask.substring(0, password.length),
        "password1": password1,
      };

      parameter = ConnectorParameter(_postLoginISchoolUrl);
      parameter.data = data;

      await RequestsConnector.getDataByPost(parameter);

      parameter = ConnectorParameter(_iSchoolPlusLearnIndexUrl);

      result = await RequestsConnector.getDataByGet(parameter);
      Log.d( result );

      if( result.contains("Guest")){ //代表登入失敗
        return ISchoolPlusConnectorStatus.LoginFail;
      }
      _isLogin = true;
      return ISchoolPlusConnectorStatus.LoginSuccess;
    } catch (e) {
      Log.e(e.toString());
      return ISchoolPlusConnectorStatus.LoginFail;
    }
  }







}
