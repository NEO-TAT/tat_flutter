import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:tat/debug/log/Log.dart';
import 'package:tat/src/connector/core/Connector.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course/course_main_extra_json.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';

import 'core/connector_parameter.dart';
import 'course_connector.dart';
import 'ntut_connector.dart';

class AddCourseResult {
  AddCourseResult({this.success, this.msg});

  bool? success;
  String? msg;
}

class QueryCourseResult {
  QueryCourseResult({
    this.success,
    this.info,
    this.up,
    this.down,
    this.sign,
    this.msg,
    this.error = false,
  });

  bool? success;
  CourseMainInfoJson? info;
  int? up, down, now, sign;
  String? msg;
  bool error;
}

class CourseOadConnector {
  static final _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static const host = "https://aps-course.ntut.edu.tw/oads/";
  static const _queryUrl = host + "QueryCourse";
  static const _addCourseUrl = host + "AddCourse";
  static const _checkCourseStatusUrl = host + "Main";

  static Future<bool> login() async {
    try {
      ConnectorParameter parameter;

      final data = {
        "apUrl": "https://aps-course.ntut.edu.tw/oads/StuLoginSID&amp",
        "apOu": "aa_030",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };

      parameter = ConnectorParameter(_ssoLoginUrl)..data = data;
      final result = await Connector.getDataByGet(parameter);
      final tagNode = parse(result);
      final nodes = tagNode.getElementsByTagName("input");
      data.clear();

      for (final node in nodes) {
        final name = node.attributes['name']!;
        final value = node.attributes['value']!;
        data[name] = value;
      }

      final jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"]!;
      parameter = ConnectorParameter(jumpUrl)..data = data;

      await Connector.getDataByPostResponse(parameter);

      parameter = ConnectorParameter(
        "https://aps-course.ntut.edu.tw/oads/Main?func=QueryCourse",
      )..data = null;

      await Connector.getDataByGet(parameter);

      return true;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return false;
    }
  }

  static final dayEnum = [
    Day.Monday,
    Day.Tuesday,
    Day.Wednesday,
    Day.Thursday,
    Day.Friday,
    Day.Saturday,
    Day.Sunday,
  ];

  static Future<CourseMainInfo?> backupGetCourseMainInfoList() async {
    final info = CourseMainInfo();

    try {
      ConnectorParameter parameter;

      final data = {"func": "CheckCourseStatus"};

      parameter = ConnectorParameter(_checkCourseStatusUrl)..data = data;

      final result = await Connector.getDataByGet(parameter);
      final node = parse(result).getElementsByTagName("table")[0];
      final courseNodes =
          node.getElementsByTagName("tbody").first.getElementsByTagName("tr");

      info.studentName = '';
      data['func'] = 'ShowSchedule';
      parameter = ConnectorParameter(_checkCourseStatusUrl)..data = data;

      final classResult = await Connector.getDataByGet(parameter);

      final classNodes = parse(classResult)
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tbody")
          .first
          .getElementsByTagName("tr")
        ..removeAt(11)
        ..removeAt(4);

      final List<CourseMainInfoJson> courseMainInfoList = [];
      for (int i = 0; i < courseNodes.length; i++) {
        final courseMainInfo = CourseMainInfoJson();
        final courseMain = CourseMainJson();
        final nodesOne = courseNodes[i].getElementsByTagName("td");

        // get course number
        courseMain.id = nodesOne[1].text;

        // get course name/link
        List<Element> nodes =
            nodesOne[9].getElementsByTagName("a"); // detect if link exist

        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }

        courseMain.stage = nodesOne[7].text.replaceAll("\n", ""); // level
        courseMain.credits = nodesOne[5].text.replaceAll("\n", ""); // credit
        courseMain.hours = nodesOne[6].text.replaceAll("\n", ""); // hours
        courseMain.note = nodesOne[13].text.replaceAll("\n", ""); // remarks

        if (nodesOne[11].getElementsByTagName("a").length > 0) {
          courseMain.scheduleHref = nodesOne[11]
              .getElementsByTagName("a")[0]
              .attributes["href"]!; // Teaching schedule outline
        }

        // time
        final timeString = nodesOne[12].text;
        final timeList = timeString.split("/");

        for (int j = 0; j < 7; j++) {
          final day = dayEnum[j];
          courseMain.time[day] = "";
        }

        for (final t in timeList) {
          final dayInt = int.parse(t.split("_").first);
          final day = dayEnum[dayInt - 1];
          final time = t.split("_").last;
          courseMain.time[day] = courseMain.time[day]! + (" " + time);

          for (final e in classNodes) {
            nodes = e.getElementsByTagName("td");

            if (nodes[0].text == time) {
              final classroomName =
                  nodes[dayInt + 1].innerHtml.split("<br>").last;
              bool add = false;

              for (ClassroomJson c in courseMainInfo.classroom) {
                if (c.name == classroomName) {
                  add = true;
                  break;
                }
              }

              if (!add) {
                final classroom = ClassroomJson();
                classroom.name = classroomName.replaceAll("\n", "");
                courseMainInfo.classroom.add(classroom);
              }

              break;
            }
          }
        }

        courseMainInfo.course = courseMain;

        // get teacher name
        for (final node in nodesOne[11].getElementsByTagName("a")) {
          final teacher = TeacherJson();
          teacher.name = node.text;
          teacher.href = node.attributes["href"]!;
          courseMainInfo.teacher.add(teacher);
        }

        // get the name of the opened classroom
        final classInfo = ClassJson();
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

  static Future<QueryCourseResult?> queryCourse(String courseId) async {
    String result = '';

    try {
      final status = QueryCourseResult();
      final courseMainInfo = CourseMainInfoJson();
      final courseMain = CourseMainJson();
      final data = {"sbj_num": courseId.toString(), "op": "0"};
      final parameter = ConnectorParameter(_queryUrl)..data = data;
      result = await Connector.getDataByPost(parameter);

      final nodes = parse(result)
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tbody")
          .first
          .getElementsByTagName("tr")
          .first
          .getElementsByTagName("td");

      status.success = nodes.first.innerHtml.contains('checkbox');
      courseMain.name = nodes[7].getElementsByTagName("a").first.text;
      courseMain.id = nodes[2].text;
      courseMain.note = nodes[16].text;

      // time
      final timeList =
          nodes[10].innerHtml.replaceAll(RegExp("[\n|	| ]"), "").split("<br>");

      for (int j = 0; j < 7; j++) {
        final day = dayEnum[j];
        courseMain.time[day] = "";
      }

      for (final t in timeList) {
        final dayInt = int.parse(t.split("(").first.split("_").first);
        final num = t.split("(").first.split("_").last;
        final day = dayEnum[dayInt - 1];
        courseMain.time[day] = courseMain.time[day]! + (" " + num);
      }

      // get classroom name
      final classroom = ClassroomJson();
      classroom.name = timeList.first.split("(").last.split(")").first;
      courseMainInfo.classroom.add(classroom);

      // get teacher name
      for (final node in nodes[9].getElementsByTagName("a")) {
        final teacher = TeacherJson();
        teacher.name = node.text;
        teacher.href = node.attributes["href"]!;
        courseMain.scheduleHref = teacher.href;
        courseMainInfo.teacher.add(teacher);
      }

      courseMain.isSelect = false;
      courseMainInfo.course = courseMain;

      // get the name of the opened classroom
      final classInfo = ClassJson();
      classInfo.name = nodes[8].text.replaceAll("\n", " ");
      courseMainInfo.openClass.add(classInfo);

      status.up = int.parse(nodes[12].text.replaceAll("\n", ""));
      status.down = int.parse(nodes[13].text.replaceAll("\n", ""));
      status.now = int.parse(nodes[14].text.replaceAll("\n", ""));
      status.sign = int.parse(nodes[15].text.replaceAll("\n", ""));
      status.msg = nodes[17].text;
      status.info = courseMainInfo;

      return status;
    } catch (e) {
      try {
        final tagNode = parse(result);
        final status = QueryCourseResult();
        status.error = true;
        status.success = false;
        status.msg = tagNode.getElementsByClassName("errmsg_text").first.text;

        return status;
      } catch (e, stack) {
        Log.eWithStack(e.toString(), stack);
        return null;
      }
    }
  }

  static Future<AddCourseResult?> addCourse(String courseId) async {
    try {
      final status = AddCourseResult();
      final data = {"sbj_num": courseId.toString(), "add_reason[]": ""};
      final parameter = ConnectorParameter(_addCourseUrl)..data = data;
      final result = await Connector.getDataByPost(parameter);
      final start = result.indexOf("alert('") + 7;
      final end = result.substring(start, result.length).indexOf("'");
      status.success = true;
      status.msg = result.substring(start, start + end);

      return status;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
