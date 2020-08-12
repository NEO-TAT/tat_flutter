import 'dart:async';
import 'dart:convert';

import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'core/Connector.dart';

enum NTUTAppConnectorStatus {
  LoginSuccess,
  LoginFail,
}

class NTUTAppConnector {
  static bool _isLogin = false;
  static final String _host = "https://ntut.app/";
  static final String _loginUrl = _host + "php/login.php";
  static final String _countCreditUrl = _host + "pages/credit.php";
  static final String _creditUrl = _host + "pages/creditResult.php";

  static Future<NTUTAppConnectorStatus> login(
      String account, String password) async {
    try {
      ConnectorParameter parameter;
      _isLogin = false;
      Map<String, String> data = {
        "\"i\"": "\"$account\"",
        "\"p\"": "\"$password\""
      };
      parameter = ConnectorParameter(_loginUrl);
      parameter.data = data.toString();
      String jsonResult = await Connector.getDataByPost(parameter);
      _isLogin = true;
      return NTUTAppConnectorStatus.LoginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return NTUTAppConnectorStatus.LoginFail;
    }
  }

  static Future<Map<String, String>> getDepartment() async {
    ConnectorParameter parameter;
    String code;
    String result;
    Document tagNode;
    Map<String, String> departmentData = Map();
    List<Element> nodes;
    try {
      parameter = ConnectorParameter(_countCreditUrl);
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("option");
      //系所
      for (Element node in nodes) {
        if (node.attributes.containsKey("selected")) {
          code = node.attributes["value"];
          departmentData["department"] = node.text;
          departmentData["code"] = code;
        }
      }
      nodes = tagNode.getElementsByTagName("li");
      departmentData["division"] =
          nodes[4].getElementsByClassName("item-after").first.text; // 學制
      Log.d(departmentData.toString());
      _isLogin = true;
      return departmentData;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static void loginFalse() {
    _isLogin = false;
  }

  static Future<bool> checkLogin() async {
    Log.d("NTUTApp CheckLogin");
    _isLogin = false;
    String result;
    try {
      ConnectorParameter parameter = ConnectorParameter(_loginUrl);
      parameter.data = {"checkLogin": "true", "login": "true"};
      result = await Connector.getDataByPost(parameter);
      Map jsonDecode = json.decode(result);
      if (jsonDecode.containsKey("status")) {
        if (jsonDecode["status"].contains("logout")) {
          return false;
        }
      }
      Log.d("NTUTApp Is Readly Login");
      _isLogin = true;
      return true;
    } catch (e, stack) {
      //Log.eWithStack(e.toString(), stack);
      return false;
    }
  }
}
