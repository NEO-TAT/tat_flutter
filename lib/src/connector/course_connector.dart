//  北科課程助手

import 'package:charset_converter/charset_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:tat/debug/log/Log.dart';
import 'package:tat/src/connector/core/Connector.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course/course_main_extra_json.dart';
import 'package:tat/src/model/course/course_score_json.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';

import 'core/connector_parameter.dart';
import 'ntut_connector.dart';

enum CourseConnectorStatus { LoginSuccess, LoginFail, UnknownError }

class CourseMainInfo {
  CourseMainInfo({
    this.json,
    this.studentName,
  });

  List<CourseMainInfoJson>? json;
  String? studentName;
}

class CourseConnector {
  static const _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static const cnHost = "https://aps.ntut.edu.tw/course/tw/";
  static const enHost = "https://aps.ntut.edu.tw/course/en/";
  static const _postCourseCNUrl = cnHost + "Select.jsp";
  static const _postTeacherCourseCNUrl = cnHost + "Teach.jsp";
  static const _postCourseENUrl = enHost + "Select.jsp";
  static const _creditUrl = cnHost + "Cprog.jsp";
  static const _searchCourseUrl = cnHost + "QueryCourse.jsp";

  static Future<CourseConnectorStatus> login() async {
    try {
      ConnectorParameter parameter;

      final data = {
        "apUrl": "https://aps.ntut.edu.tw/course/tw/courseSID.jsp",
        "apOu": "aa_0010-",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };

      parameter = ConnectorParameter(_ssoLoginUrl);
      parameter.data = data;
      final result = await Connector.getDataByGet(parameter);
      final tagNode = parse(result);
      final nodes = tagNode.getElementsByTagName("input");
      data.clear();

      for (final node in nodes) {
        final name = node.attributes['name'] ?? 'Unknown name';
        final value = node.attributes['value'] ?? 'Unknown value';
        data[name] = value;
      }

      final jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"]!;
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;

      await Connector.getDataByPostResponse(parameter);
      return CourseConnectorStatus.LoginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return CourseConnectorStatus.LoginFail;
    }
  }

  static Future<String?> getCourseENName(String url) async {
    try {
      final parameter = ConnectorParameter(url)..charsetName = 'big5';
      final result = await Connector.getDataByGet(parameter);
      final tagNode = parse(result);
      final node = tagNode
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tr")[1];

      return node
          .getElementsByTagName("td")[2]
          .text
          .replaceAll(RegExp(r"\n"), "");
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<CourseExtraInfoJson?> getCourseExtraInfo(
    String courseId,
  ) async {
    try {
      List<Element> nodes;

      final data = {
        "code": courseId,
        "format": "-1",
      };

      final parameter = ConnectorParameter(_postCourseCNUrl)
        ..data = data
        ..charsetName = 'big5';

      final result = await Connector.getDataByPost(parameter);
      final courseExtraInfo = CourseExtraInfoJson();
      final tagNode = parse(result);
      final courseNodes = tagNode.getElementsByTagName("table");

      // get semester data.
      final semester = SemesterJson();
      final courseExtra = CourseExtraJson();
      nodes = courseNodes[0].getElementsByTagName("td");
      semester.year = nodes[1].text;
      semester.semester = nodes[2].text;
      courseExtraInfo.courseSemester = semester;
      courseExtra.name = nodes[3].getElementsByTagName("a")[0].text;

      if (nodes[3]
          .getElementsByTagName("a")[0]
          .attributes
          .containsKey("href")) {
        courseExtra.href =
            cnHost + nodes[3].getElementsByTagName("a")[0].attributes["href"]!;
      }

      // get course type.
      courseExtra.category = nodes[7].text;
      courseExtra.openClass = nodes[9].text;
      courseExtra.selectNumber = nodes[11].text;
      courseExtra.withdrawNumber = nodes[12].text;
      courseExtra.id = courseId;
      courseExtraInfo.course = courseExtra;
      nodes = courseNodes[2].getElementsByTagName("tr");

      for (int i = 1; i < nodes.length; i++) {
        final classmate = ClassmateJson();
        final node = nodes[i];
        final classmateNodes = node.getElementsByTagName("td");
        classmate.className = classmateNodes[0].text;
        classmate.studentId =
            classmateNodes[1].getElementsByTagName("a")[0].text;
        classmate.href = cnHost +
            classmateNodes[1].getElementsByTagName("a")[0].attributes["href"]!;
        classmate.studentName = classmateNodes[2].text;
        classmate.studentEnglishName = classmateNodes[3].text;
        classmate.isSelect = !classmateNodes[4].text.contains("撤選");
        courseExtraInfo.classmate.add(classmate);
      }
      return courseExtraInfo;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<SemesterJson>?> getTeacherCourseSemester(
    String teacherId,
  ) async {
    try {
      final data = {
        "code": teacherId,
        "format": "-5",
      };

      final parameter = ConnectorParameter(_postTeacherCourseCNUrl)
        ..data = data
        ..charsetName = 'big5';

      final response = await Connector.getDataByPostResponse(parameter);
      final tagNode = parse(response.toString());
      final nodes = tagNode.getElementsByTagName("a");
      final List<SemesterJson> semesterJsonList = [];

      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final url = node.attributes['href']!;
        final uri = Uri.parse(url);
        final year = uri.queryParameters['year']!;
        final semester = uri.queryParameters['sem']!;
        semesterJsonList.add(SemesterJson(year: year, semester: semester));
      }

      return semesterJsonList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<SemesterJson>?> getStudentCourseSemester(
    String studentId,
  ) async {
    try {
      final data = {
        "code": studentId,
        "format": "-3",
      };

      final parameter = ConnectorParameter(_postCourseCNUrl)
        ..data = data
        ..charsetName = 'big5';

      final response = await Connector.getDataByPostResponse(parameter);
      final tagNode = parse(response.toString());
      final nodes =
          tagNode.getElementsByTagName("table")[0].getElementsByTagName("tr");
      final List<SemesterJson> semesterJsonList = [];

      for (int i = 1; i < nodes.length; i++) {
        final node = nodes[i];
        final url = node.getElementsByTagName("a")[0].attributes['href']!;
        final uri = Uri.parse(url);
        final year = uri.queryParameters['year']!;
        final semester = uri.queryParameters['sem']!;
        semesterJsonList.add(SemesterJson(year: year, semester: semester));
      }

      return semesterJsonList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static String strQ2B(String input) {
    final List<int> newString = [];
    for (int c in input.codeUnits) {
      if (c == 12288) {
        c = 32;
        continue;
      }
      if (c > 65280 && c < 65375) {
        c = (c - 65248);
      }
      newString.add(c);
    }
    return String.fromCharCodes(newString);
  }

  static Future<CourseMainInfo?> getENCourseMainInfoList(
    String studentId,
    SemesterJson semester,
  ) async {
    final info = CourseMainInfo();

    try {
      List<Element> nodes;

      final dayEnum = [
        Day.Sunday,
        Day.Monday,
        Day.Tuesday,
        Day.Wednesday,
        Day.Thursday,
        Day.Friday,
        Day.Saturday
      ];

      final data = {
        "code": studentId,
        "format": "-2",
        "year": semester.year,
        "sem": semester.semester,
      };

      final parameter = ConnectorParameter(_postCourseENUrl)
        ..data = data
        ..charsetName = 'big5';

      final response = await Connector.getDataByPostResponse(parameter);
      final tagNode = parse(response.toString());
      nodes = tagNode.getElementsByTagName("table");
      final courseNodes = nodes[1].getElementsByTagName("tr");
      String studentName;

      try {
        studentName = strQ2B(nodes[0].getElementsByTagName("td")[4].text)
            .replaceAll(RegExp(r"[\n| ]"), "");
      } catch (e, stack) {
        Log.eWithStack(e.toString(), stack);
        studentName = "";
      }

      info.studentName = studentName;
      final List<CourseMainInfoJson> courseMainInfoList = [];

      for (int i = 1; i < courseNodes.length - 1; i++) {
        final courseMainInfo = CourseMainInfoJson();
        final courseMain = CourseMainJson();
        final nodesOne = courseNodes[i].getElementsByTagName("td");

        if (nodesOne[16].text.contains("Withdraw")) {
          continue;
        }

        // get course number.
        courseMain.id =
            strQ2B(nodesOne[0].text).replaceAll(RegExp(r"[\n| ]"), "");

        // get course name/link.
        nodes = nodesOne[1].getElementsByTagName("a"); // detect if link exist.

        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }

        courseMain.credits = nodesOne[2].text.replaceAll("\n", ""); // credit
        courseMain.hours = nodesOne[3].text.replaceAll("\n", ""); // hours
        courseMain.note = nodesOne[16].text; // remark

        // time
        for (int j = 0; j < 7; j++) {
          final day = dayEnum[j];
          final time = strQ2B(nodesOne[j + 6].text);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        int length;

        // get teacher name.
        length = nodesOne[4].innerHtml.split("<br>").length;
        for (final name in nodesOne[4].innerHtml.split("<br>")) {
          final teacher = TeacherJson();
          teacher.name = name.replaceAll("\n", "");
          courseMainInfo.teacher.add(teacher);
        }

        // get classroom name.
        length = nodesOne[13].innerHtml.split("<br>").length;
        for (final name
            in nodesOne[13].innerHtml.split("<br>").getRange(0, length - 1)) {
          final classroom = ClassroomJson();
          classroom.name = name.replaceAll("\n", "");
          courseMainInfo.classroom.add(classroom);
        }

        // get available classroom name.
        for (final node in nodesOne[5].getElementsByTagName("a")) {
          final classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = cnHost + node.attributes["href"]!;
          courseMainInfo.openClass.add(classInfo);
        }

        courseMainInfoList.add(courseMainInfo);
      }

      info.json = courseMainInfoList;
      return info;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<CourseMainInfo?> getTWCourseMainInfoList(
    String studentId,
    SemesterJson semester,
  ) async {
    final info = CourseMainInfo();

    try {
      List<Element> nodes;
      final dayEnum = [
        Day.Sunday,
        Day.Monday,
        Day.Tuesday,
        Day.Wednesday,
        Day.Thursday,
        Day.Friday,
        Day.Saturday
      ];

      final data = {
        "code": studentId,
        "format": "-2",
        "year": semester.year,
        "sem": semester.semester,
      };

      final parameter = ConnectorParameter(_postCourseCNUrl)
        ..data = data
        ..charsetName = 'big5';

      final response = await Connector.getDataByPostResponse(parameter);
      final tagNode = parse(response.toString());
      final courseNodes =
          tagNode.getElementsByTagName("table")[1].getElementsByTagName("tr");

      String studentName;

      try {
        studentName = RegExp(r"姓名：([\u4E00-\u9FA5]+)")
            .firstMatch(courseNodes[0].text)!
            .group(1)!;
      } catch (e) {
        studentName = "";
      }

      info.studentName = studentName;
      final List<CourseMainInfoJson> courseMainInfoList = [];

      for (int i = 2; i < courseNodes.length - 1; i++) {
        final courseMainInfo = CourseMainInfoJson();
        final courseMain = CourseMainJson();
        final nodesOne = courseNodes[i].getElementsByTagName("td");

        if (nodesOne[16].text.contains("撤選")) {
          continue;
        }
        // get course number.
        nodes = nodesOne[0].getElementsByTagName("a"); // detect if link exist.
        if (nodes.length >= 1) {
          courseMain.id = nodes[0].text;
          courseMain.href = cnHost + nodes[0].attributes["href"]!;
        }

        // get course name/link.
        nodes = nodesOne[1].getElementsByTagName("a"); // detect if link exist.
        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }

        courseMain.stage = nodesOne[2].text.replaceAll("\n", ""); // level.
        courseMain.credits = nodesOne[3].text.replaceAll("\n", ""); // credit.
        courseMain.hours = nodesOne[4].text.replaceAll("\n", ""); // hours.
        courseMain.note = nodesOne[20].text.replaceAll("\n", ""); // remark.

        if (nodesOne[19].getElementsByTagName("a").length > 0) {
          courseMain.scheduleHref = cnHost +
              nodesOne[19]
                  .getElementsByTagName("a")[0]
                  .attributes["href"]!; // Teaching schedule outline
        }

        // time
        for (int j = 0; j < 7; j++) {
          final day = dayEnum[j];
          final time = strQ2B(nodesOne[j + 8].text);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        // get teacher name.
        for (final node in nodesOne[6].getElementsByTagName("a")) {
          final teacher = TeacherJson();
          teacher.name = node.text;
          teacher.href = cnHost + node.attributes["href"]!;
          courseMainInfo.teacher.add(teacher);
        }

        // get classroom name
        for (final node in nodesOne[15].getElementsByTagName("a")) {
          final classroom = ClassroomJson();
          classroom.name = node.text;
          classroom.href = cnHost + node.attributes["href"]!;
          courseMainInfo.classroom.add(classroom);
        }

        // get the name of the opened classroom
        for (final node in nodesOne[7].getElementsByTagName("a")) {
          final classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = cnHost + node.attributes["href"]!;
          courseMainInfo.openClass.add(classInfo);
        }

        courseMainInfoList.add(courseMainInfo);
      }

      info.json = courseMainInfoList;
      return info;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<CourseMainInfo?> getTWTeacherCourseMainInfoList(
    String studentId,
    SemesterJson semester,
  ) async {
    final info = CourseMainInfo();

    try {
      List<Element> nodes;

      final dayEnum = [
        Day.Sunday,
        Day.Monday,
        Day.Tuesday,
        Day.Wednesday,
        Day.Thursday,
        Day.Friday,
        Day.Saturday
      ];

      final data = {
        "code": studentId,
        "format": "-3",
        "year": semester.year,
        "sem": semester.semester,
      };

      final parameter = ConnectorParameter(_postTeacherCourseCNUrl)
        ..data = data
        ..charsetName = 'big5';

      final response = await Connector.getDataByPostResponse(parameter);
      final tagNode = parse(response.toString());
      final courseNodes =
          tagNode.getElementsByTagName("table")[0].getElementsByTagName("tr");

      String studentName;

      try {
        studentName = courseNodes[0].text.replaceAll("　　", " ").split(" ")[2];
      } catch (e) {
        studentName = "";
      }

      info.studentName = studentName;
      final List<CourseMainInfoJson> courseMainInfoList = [];

      for (int i = 2; i < courseNodes.length - 1; i++) {
        final courseMainInfo = CourseMainInfoJson();
        final courseMain = CourseMainJson();

        final nodesOne = courseNodes[i].getElementsByTagName("td");
        if (nodesOne[16].text.contains("撤選")) {
          continue;
        }
        // get course number.
        nodes = nodesOne[0]
            .getElementsByTagName("a"); // detect if course number exist.
        if (nodes.length >= 1) {
          courseMain.id = nodes[0].text;
          courseMain.href = cnHost + nodes[0].attributes["href"]!;
        }

        // get course name/link.
        nodes = nodesOne[1].getElementsByTagName("a"); // detect if link exist.
        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }

        courseMain.stage = nodesOne[2].text.replaceAll("\n", ""); // level
        courseMain.credits = nodesOne[3].text.replaceAll("\n", ""); // credit
        courseMain.hours = nodesOne[4].text.replaceAll("\n", ""); // hours
        courseMain.note = nodesOne[20].text.replaceAll("\n", ""); // remark
        if (nodesOne[19].getElementsByTagName("a").length > 0) {
          courseMain.scheduleHref = cnHost +
              nodesOne[19]
                  .getElementsByTagName("a")[0]
                  .attributes["href"]!; // Teaching schedule outline
        }

        // time
        for (int j = 0; j < 7; j++) {
          final day = dayEnum[j];
          final time = strQ2B(nodesOne[j + 8].text);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        // get teacher name.
        final teacher = TeacherJson();
        teacher.name = "";
        teacher.href = "";
        courseMainInfo.teacher.add(teacher);

        // get classroom name.
        for (final node in nodesOne[15].getElementsByTagName("a")) {
          final classroom = ClassroomJson();
          classroom.name = node.text;
          classroom.href = cnHost + node.attributes["href"]!;
          courseMainInfo.classroom.add(classroom);
        }

        // get the name of the opened classroom.
        for (final node in nodesOne[7].getElementsByTagName("a")) {
          final classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = cnHost + node.attributes["href"]!;
          courseMainInfo.openClass.add(classInfo);
        }

        courseMainInfoList.add(courseMainInfo);
      }

      info.json = courseMainInfoList;
      return info;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<Map?> getGraduation(String year, String department) async {
    ConnectorParameter parameter;
    String result;
    RegExp exp;
    RegExpMatch matches;

    final graduationMap = Map();

    try {
      parameter =
          ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp")
            ..charsetName = 'big5'
            ..data = {"format": "-3", "year": year, "matric": "7"};

      result = await Connector.getDataByGet(parameter);
      final tagNode = parse(result);
      final nodes = tagNode
          .getElementsByTagName("tbody")
          .first
          .getElementsByTagName("tr");

      String href = '';

      for (int i = 1; i < nodes.length; i++) {
        final node = nodes[i].getElementsByTagName("a").first;
        if (node.text.contains(department)) {
          href = node.attributes["href"]!;
          break;
        }
      }

      href = "https://aps.ntut.edu.tw/course/tw/" + href;
      parameter = ConnectorParameter(href)..charsetName = 'big5';
      result = await Connector.getDataByGet(parameter);

      exp = RegExp(r"最低畢業學分：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["lowCredit"] = int.parse(matches.group(1)!);

      exp = RegExp(r"共同必修：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["△"] = int.parse(matches.group(1)!);

      exp = RegExp(r"專業必修：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["▲"] = int.parse(matches.group(1)!);

      exp = RegExp(r"專業選修：?(\d+)學分");
      matches = exp.firstMatch(result)!;
      graduationMap["★"] = int.parse(matches.group(1)!);

      return graduationMap;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<String>?> getYearList() async {
    final List<String> resultList = [];

    try {
      final parameter =
          ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp")
            ..data = {"format": "-1"}
            ..charsetName = 'big5';

      final result = await Connector.getDataByPost(parameter);
      final tagNode = parse(result);
      final nodes = tagNode.getElementsByTagName("a");

      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        resultList.add(node.text);
      }

      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<Map>?> getDivisionList(String year) async {
    final List<Map> resultList = [];

    try {
      final parameter = ConnectorParameter(_creditUrl)
        ..data = {"format": "-2", "year": year}
        ..charsetName = 'big5';

      final result = await Connector.getDataByPost(parameter);
      final tagNode = parse(result);
      final nodes = tagNode.getElementsByTagName("a");

      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final code = Uri.parse(node.attributes["href"]!).queryParameters;
        resultList.add({"name": node.text, "code": code});
      }

      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<Map>?> getDepartmentList(Map code) async {
    final List<Map> resultList = [];

    try {
      final parameter = ConnectorParameter(_creditUrl)
        ..data = code
        ..charsetName = 'big5';

      final result = await Connector.getDataByPost(parameter);
      final tagNode = parse(result);
      final nodes =
          tagNode.getElementsByTagName("table").first.getElementsByTagName("a");

      for (int i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final code = Uri.parse(node.attributes["href"]!).queryParameters;
        final name = node.text.replaceAll(RegExp("[ |\s]"), "");
        resultList.add({"name": name, "code": code});
      }

      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<GraduationInformationJson?> getCreditInfo(
    Map matricCode,
    Map divisionCode,
  ) async {
    ConnectorParameter parameter;
    String result;
    List<Element> trNodes;
    final graduationInformation = GraduationInformationJson();

    try {
      parameter = ConnectorParameter(_creditUrl)
        ..data = matricCode
        ..charsetName = 'big5';

      result = await Connector.getDataByPost(parameter);
      final tagNode = parse(result);
      trNodes = tagNode
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tr")
        ..removeAt(0);

      Log.d("select $divisionCode");
      bool pass = false;

      for (int i = 0; i < trNodes.length; i++) {
        final trNode = trNodes[i];
        final anode = trNode.getElementsByTagName("a").first;
        final url = anode.attributes["href"]!;
        var uri = Uri.parse(url);

        if (uri.queryParameters['division'] == divisionCode["division"]) {
          final tdNodes = trNode.getElementsByTagName("td");

          for (int j = 1; j < tdNodes.length; j++) {
            final tdNode = tdNodes[j];
            final creditString = tdNode.text.replaceAll(RegExp(r"[\s|\n]"), "");

            switch (j - 1) {
              case 0:
                graduationInformation.courseTypeMinCredit["○"] =
                    int.parse(creditString);
                break;
              case 1:
                graduationInformation.courseTypeMinCredit["△"] =
                    int.parse(creditString);
                break;
              case 2:
                graduationInformation.courseTypeMinCredit["☆"] =
                    int.parse(creditString);
                break;
              case 3:
                graduationInformation.courseTypeMinCredit["●"] =
                    int.parse(creditString);
                break;
              case 4:
                graduationInformation.courseTypeMinCredit["▲"] =
                    int.parse(creditString);
                break;
              case 5:
                graduationInformation.courseTypeMinCredit["★"] =
                    int.parse(creditString);
                break;
              case 6:
                graduationInformation.outerDepartmentMaxCredit =
                    int.parse(creditString);
                break;
              case 7:
                graduationInformation.lowCredit = int.parse(creditString);
                break;
            }
          }

          pass = true;
          Log.d(graduationInformation.courseTypeMinCredit.toString());
          break;
        }
      }

      parameter = ConnectorParameter(_creditUrl)
        ..data = divisionCode
        ..charsetName = 'big5';

      result = await compute(Connector.getDataByPost, parameter);
      trNodes = parse(result)
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tr");

      graduationInformation.courseCodeList = [];

      for (int i = 1; i < trNodes.length; i++) {
        final node = trNodes[i];
        final courseCode = node
            .getElementsByTagName("td")[3]
            .text
            .replaceAll(RegExp('[\n| ]'), "");
        graduationInformation.courseCodeList.add(courseCode);
      }

      if (!pass) {
        Log.e("not find $divisionCode");
      }

      return graduationInformation;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<CourseMainInfoJson>?> searchCourse(
    SemesterJson semester,
    String name,
    bool cname,
  ) async {
    List<Element> nodes;

    final dayEnum = [
      Day.Sunday,
      Day.Monday,
      Day.Tuesday,
      Day.Wednesday,
      Day.Thursday,
      Day.Friday,
      Day.Saturday
    ];

    final List<CourseMainInfoJson> courseMainInfoList = [];

    try {
      String encodeName = "";
      final encodeBig5 = await CharsetConverter.encode('big5', name);

      for (int i = 0; i < encodeBig5.length; i++) {
        encodeName += "%";
        encodeName += encodeBig5[i].toRadixString(16).toUpperCase();
      }

      final data = {
        "stime": '0',
        "year": semester.year.toString(),
        "matric": "'1','5','6','7','8','9'",
        "sem": semester.semester.toString(),
        "unit": "**",
        "cname": (cname) ? encodeName : "",
        "ccode": "",
        "tname": (!cname) ? encodeName : "",
        "D0": "ON",
        "D1": "ON",
        "D2": "ON",
        "D3": "ON",
        "D4": "ON",
        "D5": "ON",
        "D6": "ON",
        "P1": "ON",
        "P2": "ON",
        "P3": "ON",
        "P4": "ON",
        "PN": "ON",
        "P5": "ON",
        "P6": "ON",
        "P7": "ON",
        "P8": "ON",
        "P9": "ON",
        "P10": "ON",
        "P11": "ON",
        "P12": "ON",
        "P13": "ON",
        "search": "%B6%7D%A9l%ACd%B8%DF"
      };

      String d = "";
      data.forEach((key, value) => d += "&$key=$value");

      final parameter = ConnectorParameter(_searchCourseUrl + "?" + d)
        ..charsetName = 'big5';

      parameter.charsetName = 'big5';
      final result = await Connector.getDataByPost(parameter);

      final courseNodes = parse(result)
          .getElementsByTagName("table")
          .first
          .getElementsByTagName("tr");

      for (int i = 1; i < courseNodes.length; i++) {
        final courseMainInfo = CourseMainInfoJson();
        final courseMain = CourseMainJson();

        courseMain.isSelect = false;

        final nodesOne = courseNodes[i].getElementsByTagName("td");

        if (nodesOne[16].text.contains("撤選")) {
          continue;
        }

        // get course number.
        nodes = nodesOne[0].getElementsByTagName("a"); // detect if the course number exist.

        if (nodes.length >= 1) {
          courseMain.id = nodes[0].text;
          courseMain.href = cnHost + nodes[0].attributes["href"]!;
        } else {
          courseMain.id = nodesOne[0].text.replaceAll("\n", "");
        }

        // get course name/link.
        nodes = nodesOne[1].getElementsByTagName("a"); // detect if link exist.

        if (nodes.length >= 1) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }

        courseMain.stage = nodesOne[2].text.replaceAll("\n", ""); // level
        courseMain.credits = nodesOne[3].text.replaceAll("\n", ""); // credit
        courseMain.hours = nodesOne[4].text.replaceAll("\n", ""); // hours
        courseMain.note = nodesOne[21].text; // remark

        if (nodesOne[20].getElementsByTagName("a").length > 0) {
          courseMain.scheduleHref = cnHost +
              nodesOne[20]
                  .getElementsByTagName("a")[0]
                  .attributes["href"]!; // Teaching schedule outline
        }

        // time
        for (int j = 0; j < 7; j++) {
          final day = dayEnum[j];
          final time = strQ2B(nodesOne[j + 8].text);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        // get teacher name.
        for (final node in nodesOne[7].getElementsByTagName("a")) {
          final teacher = TeacherJson();
          teacher.name = node.text;
          teacher.href = cnHost + node.attributes["href"]!;
          courseMainInfo.teacher.add(teacher);
        }

        // get classroom name.
        for (final node in nodesOne[15].getElementsByTagName("a")) {
          final classroom = ClassroomJson();
          classroom.name = node.text;
          classroom.href = cnHost + node.attributes["href"]!;
          courseMainInfo.classroom.add(classroom);
        }

        // get the name of the opened classroom.
        for (final node in nodesOne[6].getElementsByTagName("a")) {
          final classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = cnHost + node.attributes["href"]!;
          courseMainInfo.openClass.add(classInfo);
        }

        courseMainInfoList.add(courseMainInfo);
      }

      return courseMainInfoList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
