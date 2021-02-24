import 'dart:async';

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
  static final String host = "https://ntut.app/";
  static final String _loginUrl = host + "php/login.php";
  static final String _countCreditUrl = host + "pages/credit.php";

  static Future<NTUTAppConnectorStatus> login(
      String account, String password) async {
    try {
      ConnectorParameter parameter;
      Map<String, String> data = {
        "\"i\"": "\"$account\"",
        "\"p\"": "\"$password\""
      };
      parameter = ConnectorParameter(_loginUrl);
      parameter.data = data.toString();
      //String jsonResult = await Connector.getDataByPost(parameter);
      await Connector.getDataByPost(parameter);
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
      return departmentData;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
