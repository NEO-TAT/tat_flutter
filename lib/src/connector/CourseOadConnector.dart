import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'NTUTConnector.dart';
import 'core/ConnectorParameter.dart';

class CourseOadConnector {
  static final _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static final String _host = "https://aps-course.ntut.edu.tw/oads/";
  static final String _queryUrl = _host + "QueryCourse";
  static final String _addCourseUrl = _host + "AddCourse";

  static Future<bool> login() async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "apUrl": "https://aps-course.ntut.edu.tw/oads/StuLoginSID&amp",
        "apOu": "aa_030",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_ssoLoginUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("input");
      data = Map();
      for (Element node in nodes) {
        String name = node.attributes['name'];
        String value = node.attributes['value'];
        data[name] = value;
      }
      String jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"];
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;
      await Connector.getDataByPostResponse(parameter);
      parameter = ConnectorParameter(
          "https://aps-course.ntut.edu.tw/oads/Main?func=QueryCourse");
      parameter.data = null;
      await Connector.getDataByGet(parameter);
      return true;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return false;
    }
  }

  static Future<String> queryCourse(String courseId) async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      /*
      String data = "";
      data += "sbj_num=$courseId&";
      for (int i = 0; i < 9; i++) {
        data += "sbj_num=&";
      }
      data += "op=0";
      print(data);
      parameter = ConnectorParameter(_queryUrl + "?" + data);
      */
      parameter = ConnectorParameter(_queryUrl);
      parameter.data = <String, String>{
        "sbj_num": courseId.toString(),
        "op": "0"
      };
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      nodes = tagNode
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tbody")
          .first
          .getElementsByTagName("tr");
      print(nodes.first
          .getElementsByTagName("td")
          .first
          .innerHtml);
      if (nodes.first
          .getElementsByTagName("td")
          .first
          .innerHtml
          .contains('checkbox')) {
        print("select");
        parameter = ConnectorParameter(_addCourseUrl);
        parameter.data = <String, String>{
          "sbj_num": courseId.toString(),
          "add_reason[]": ""
        };
        result = await Connector.getDataByPost(parameter);
        var start  = result.indexOf("alert('");
        start += 7;
        var end = result.substring(start,result.length).indexOf("'");
        return result.substring(start,start+end);
      }
      return null;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
