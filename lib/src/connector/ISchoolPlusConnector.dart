import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
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
  static final String _iSchoolPlusIndexUrl = _iSchoolPlusUrl +
      "learn/index.php";

  static Future<ISchoolPlusConnectorStatus> login(String account,
      String password) async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;

      parameter = ConnectorParameter(_getLoginISchoolUrl);
      result = await RequestsConnector.getDataByGet(parameter);

      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("form");
      nodes = nodes[2].getElementsByTagName("input");
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

      String passwordMask = "**********************************";

      Map<String, String> data = {
        "reurl": "",
        "login_key": loginKey,
        "encrypt_pwd": encryptPwd,
        "username": account,
        "password": passwordMask.substring(0, password.length),
        "password1": "cm9iZXJ0MTM1Nzk=",
      };

      Log.d(data.toString());

      parameter = ConnectorParameter(_postLoginISchoolUrl);
      parameter.data = data;

      await RequestsConnector.getDataByPost(parameter);

      parameter = ConnectorParameter(_iSchoolPlusIndexUrl);
      result = await RequestsConnector.getDataByGet(parameter);
      Log.d( result );


      _isLogin = true;
      return ISchoolPlusConnectorStatus.LoginSuccess;
    } catch (e) {
      Log.e(e.toString());
      return ISchoolPlusConnectorStatus.LoginFail;
    }
  }


}