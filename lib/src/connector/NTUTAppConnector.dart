import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
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
    } catch (e) {
      Log.e(e.toString());
      return NTUTAppConnectorStatus.LoginFail;
    }
  }

  static Future<Map<String,String>> getDepartment() async{
    ConnectorParameter parameter;
    String code;
    String result;
    Document tagNode;
    Map<String,String> departmentData = Map();
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
      departmentData["division"] = nodes[4].getElementsByClassName("item-after").first.text; // 學制
      Log.d( departmentData.toString() );
      _isLogin = true;
      return departmentData;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<Map> getCredit() async {
    ConnectorParameter parameter;
    String code;
    String result;
    Document tagNode;
    Element listNode, blockTitleNode;
    Map creditData = Map();
    List<Element> listNodes, blockTitleNodes, nodes;
    try {
      parameter = ConnectorParameter(_countCreditUrl);
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("option");
      for (Element node in nodes) {
        if (node.attributes.containsKey("selected")) {
          code = node.attributes["value"];
          creditData["department"] = node.text;
        }
      }
      Map<String, String> data = {"code": code};
      parameter = ConnectorParameter(_creditUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      listNodes = tagNode.getElementsByClassName("list");
      blockTitleNodes = tagNode.getElementsByClassName("block-title");
      listNodes.removeAt(0);
      List<String> coreCourse =
          await ScoreConnector.getCoreGeneralLesson(); //去得博雅核心課程
      coreCourse = coreCourse ?? List();
      for (int i = 0; i < blockTitleNodes.length; i++) {
        List<Map> courseList = List();
        listNode = listNodes[i];
        blockTitleNode = blockTitleNodes[i];
        String semester = blockTitleNode.text.split(" ").first +
            '-' +
            blockTitleNode.text.split(" ")[3];
        nodes = listNode.getElementsByClassName("item-content");
        for (Element node in nodes) {
          Map courseMap = Map();
          courseMap["category"] =
              node.getElementsByClassName("item-media").first.text;
          node = node.getElementsByClassName("item-title").first;
          nodes = node.getElementsByTagName("div");
          courseMap["name"] = nodes[0].text;
          if (coreCourse.contains(courseMap["name"])) {
            courseMap['core'] = 1; //代表為博雅核心
          }
          courseMap["credit"] =
              int.parse(nodes[1].text.split("，").first.split("：").last);
          try {
            courseMap["score"] =
                int.parse(nodes[1].text
                    .split("，")
                    .last
                    .split("：")
                    .last);
          }catch(e){
            continue;
          }
          if (nodes.length >= 3) {
            courseMap["extra"] = nodes[2].text;
          }
          courseList.add(courseMap);
        }
        creditData[semester] = courseList;
      }
      _isLogin = true;
      return creditData;
    } catch (e) {
      Log.e(e.toString());
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
    ConnectorParameter parameter;
    _isLogin = false;
    Log.d("NTUT Is Readly Login");
    _isLogin = true;
    return true;
  }
}
