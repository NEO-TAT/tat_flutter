import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/model/course/CourseMainExtraJson.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'CourseConnector.dart';
import 'NTUTConnector.dart';
import 'core/ConnectorParameter.dart';

class AddCourseResult {
  bool success;
  String msg;
}

class QueryCourseResult {
  bool success;
  int up;
  int down;
  int now;
  int sign;
  String msg;
}

class CourseOadConnector {
  static final _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static final String host = "https://aps-course.ntut.edu.tw/oads/";
  static final String _queryUrl = host + "QueryCourse";
  static final String _addCourseUrl = host + "AddCourse";
  static final String _checkCourseStatusUrl = host + "Main";

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

  static Future<CourseMainInfo> backupGetCourseMainInfoList() async {
    //課程系統故障時
    var info = CourseMainInfo();
    try {
      String result, classResult;
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodesOne, nodes, classNodes;
      List<Day> dayEnum = [
        Day.Monday,
        Day.Tuesday,
        Day.Wednesday,
        Day.Thursday,
        Day.Friday,
        Day.Saturday,
        Day.Sunday,
      ];
      Map<String, String> data = {"func": "CheckCourseStatus"};
      parameter = ConnectorParameter(_checkCourseStatusUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table")[0];
      courseNodes =
          node.getElementsByTagName("tbody").first.getElementsByTagName("tr");
      String studentName;
      studentName = "";
      info.studentName = studentName;

      data = {"func": "ShowSchedule"};
      parameter = ConnectorParameter(_checkCourseStatusUrl);
      parameter.data = data;
      classResult = await Connector.getDataByGet(parameter);

      classNodes = parse(classResult)
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tbody")
          .first
          .getElementsByTagName("tr");
      classNodes.removeAt(11);
      classNodes.removeAt(4);
      List<CourseMainInfoJson> courseMainInfoList = List();
      for (int i = 0; i < courseNodes.length; i++) {
        CourseMainInfoJson courseMainInfo = CourseMainInfoJson();
        CourseMainJson courseMain = CourseMainJson();

        nodesOne = courseNodes[i].getElementsByTagName("td");
        //取得課號
        courseMain.id = nodesOne[1].text;
        //取的課程名稱/課程連結
        nodes = nodesOne[9].getElementsByTagName("a"); //確定是否有連結
        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }

        courseMain.stage = nodesOne[7].text.replaceAll("\n", ""); //階段
        courseMain.credits = nodesOne[5].text.replaceAll("\n", ""); //學分
        courseMain.hours = nodesOne[6].text.replaceAll("\n", ""); //時數
        courseMain.note = nodesOne[13].text.replaceAll("\n", ""); //備註
        if (nodesOne[11].getElementsByTagName("a").length > 0) {
          courseMain.scheduleHref = nodesOne[11]
              .getElementsByTagName("a")[0]
              .attributes["href"]; //教學進度大綱
        }

        //時間
        final timeString = nodesOne[12].text;
        List<String> timeList = timeString.split("/");
        for (int j = 0; j < 7; j++) {
          Day day = dayEnum[j];
          courseMain.time[day] = "";
        }
        for (String t in timeList) {
          int dayInt = int.parse(t.split("_").first);
          Day day = dayEnum[dayInt - 1]; //要做變換網站是從星期日開始
          String time = t.split("_").last;
          courseMain.time[day] += (" " + time);
          for (Element e in classNodes) {
            nodes = e.getElementsByTagName("td");
            if (nodes[0].text == time) {
              String classroomName =
                  nodes[dayInt + 1].innerHtml.split("<br>").last;
              bool add = false;
              for (ClassroomJson c in courseMainInfo.classroom) {
                if (c.name == classroomName) {
                  add = true;
                  break;
                }
              }
              if (!add) {
                ClassroomJson classroom = ClassroomJson();
                classroom.name = classroomName.replaceAll("\n", "");
                courseMainInfo.classroom.add(classroom);
              }
              break;
            }
          }
        }

        courseMainInfo.course = courseMain;

        //取得老師名稱
        for (Element node in nodesOne[11].getElementsByTagName("a")) {
          TeacherJson teacher = TeacherJson();
          teacher.name = node.text;
          teacher.href = node.attributes["href"];
          courseMainInfo.teacher.add(teacher);
        }

        //取得開設教室名稱
        ClassJson classInfo = ClassJson();
        classInfo.name = nodesOne[10].text;
        courseMainInfo.openClass.add(classInfo);

        courseMainInfoList.add(courseMainInfo);
      }
      info.json = courseMainInfoList;
      return info;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<QueryCourseResult> queryCourse(String courseId) async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      QueryCourseResult status = QueryCourseResult();
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
      nodes = nodes.first.getElementsByTagName("td");

      status.success = nodes.first.innerHtml.contains('checkbox');

      status.up = int.parse(nodes[12].text.replaceAll("\n", ""));
      status.down = int.parse(nodes[13].text.replaceAll("\n", ""));
      status.now = int.parse(nodes[14].text.replaceAll("\n", ""));
      status.sign = int.parse(nodes[15].text.replaceAll("\n", ""));
      status.msg = nodes[17].text;
      return status;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<AddCourseResult> addCourse(String courseId) async {
    String result;
    try {
      ConnectorParameter parameter;
      AddCourseResult status = AddCourseResult();
      parameter = ConnectorParameter(_addCourseUrl);
      parameter.data = <String, String>{
        "sbj_num": courseId.toString(),
        "add_reason[]": ""
      };
      result = await Connector.getDataByPost(parameter);
      var start = result.indexOf("alert('");
      start += 7;
      var end = result.substring(start, result.length).indexOf("'");
      status.success = true;
      status.msg = result.substring(start, start + end);
      return status;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
