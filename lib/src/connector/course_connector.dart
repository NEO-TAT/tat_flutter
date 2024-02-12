// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/model/course/course_semester.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/model/coursetable/course.dart';
import 'package:flutter_app/src/model/coursetable/user.dart';
import 'package:flutter_app/src/model/course/course_syllabus.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

enum CourseConnectorStatus { loginSuccess, loginFail, unknownError }

class CourseConnector {
  static const _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static const String _courseCNHost = "https://aps.ntut.edu.tw/course/tw/";
  static const String _courseENHost = "https://aps.ntut.edu.tw/course/en/";
  static const String _postCourseCNUrl = "${_courseCNHost}Select.jsp";
  static const String _getSyllabusCNUrl = "${_courseCNHost}ShowSyllabus.jsp";
  static const String _postCourseENUrl = "${_courseENHost}Select.jsp";
  static const String _creditUrl = "${_courseCNHost}Cprog.jsp";

  static Future<CourseConnectorStatus> login() async {
    try {
      Document tagNode = await _getSSORedirectNodesInLoginPhase();
      await _tryToSSOLoginOrThrowException(_getSSOLoginJumpUrl(tagNode), _getSSOLoginPayload(tagNode));
      return CourseConnectorStatus.loginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return CourseConnectorStatus.loginFail;
    }
  }

  static Future<List<Course>> getEnglishCourses(String studentId, int year, int semester) async {
    ConnectorParameter parameter = ConnectorParameter(_postCourseENUrl);
    Map<String, String> data = {
      "code": studentId,
      "format": "-2",
      "year": year.toString(),
      "sem": semester.toString(),
    };
    parameter.charsetName = 'utf-8';
    parameter.data = data;
    String result = await Connector.getDataByGet(parameter);

    Document tagNode = parse(result);
    List<Element> courseRows = tagNode.getElementsByTagName("table")[1].getElementsByTagName("tr");
    List<Course> courses = <Course>[];

    for (int rowIndex = 1; rowIndex < courseRows.length - 1; rowIndex++) {
      final courseRowData = courseRows[rowIndex].getElementsByTagName("td");
      courses.add(Course.parseNodeString(
          idString: courseRowData[0].text,
          name: courseRowData[1].text,
          stageString: "",
          creditString: courseRowData[2].text,
          periodCountString: courseRowData[3].text,
          category: "",
          teacherString: courseRowData[4].innerHtml.replaceAll("<br>", "\n"),
          classNameString: courseRowData[5].text,
          periodSlots: courseRowData.sublist(6, 13).map((data) => data.text).toList(),
          classroomString: courseRowData[13].text,
          applyStatus: courseRowData[14].text,
          language: courseRowData[15].text,
          syllabusLink: "",
          note: courseRowData[16].text));
    }

    return courses;
  }

  static Future<User> getUserInfo(String studentId, int year, int semester) async {
    try {
      ConnectorParameter parameter = ConnectorParameter(_postCourseCNUrl);
      Map<String, String> data = {
        "code": studentId,
        "format": "-2",
        "year": year.toString(),
        "sem": semester.toString(),
      };
      parameter.charsetName = 'utf-8';
      parameter.data = data;
      String result = await Connector.getDataByGet(parameter);

      Document tagNode = parse(result);
      String courseTableHead = tagNode.getElementsByTagName("table")[1].getElementsByTagName("tr").first.text;
      List<RegExpMatch> matches = RegExp(r".+?：(.+?)\s").allMatches(courseTableHead).toList();

      String? name = matches[1].group(1);
      String? className = matches[2].group(1);

      if (name == null) {
        throw Exception("getUserInfo: Cannot Fetch the user info (null name).");
      }

      if (className == null) {
        throw Exception("getUserInfo: Cannot Fetch the user info (null className).");
      }

      return User(id: studentId, name: name, className: className);
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return User.origin();
    }
  }

  static Future<List<Course>> getChineseCourses(String studentId, int year, int semester) async {
    ConnectorParameter parameter = ConnectorParameter(_postCourseCNUrl);
    Map<String, String> data = {
      "code": studentId,
      "format": "-2",
      "year": year.toString(),
      "sem": semester.toString(),
    };
    parameter.charsetName = 'utf-8';
    parameter.data = data;
    String result = await Connector.getDataByGet(parameter);
    Document tagNode = parse(result);
    List<Element> courseRows = tagNode.getElementsByTagName("table")[1].getElementsByTagName("tr");
    List<Course> courses = <Course>[];

    for (int rowIndex = 2; rowIndex < courseRows.length - 1; rowIndex++) {
      final courseRowData = courseRows[rowIndex].getElementsByTagName("td");
      final syllabusNode = courseRowData[18].getElementsByTagName("a");
      final syllabusLinkHref = syllabusNode.isEmpty ? null : syllabusNode.first.attributes["href"];
      courses.add(Course.parseNodeString(
          idString: courseRowData[0].text,
          name: courseRowData[1].text,
          stageString: courseRowData[2].text,
          creditString: courseRowData[3].text,
          periodCountString: courseRowData[4].text,
          category: courseRowData[5].text,
          teacherString: courseRowData[6].text,
          classNameString: courseRowData[7].text,
          periodSlots: courseRowData.sublist(8, 15).map((data) => data.text).toList(),
          classroomString: courseRowData[15].text,
          applyStatus: courseRowData[16].text,
          language: courseRowData[17].text,
          syllabusLink: syllabusLinkHref == null ? "" : _postCourseCNUrl + syllabusLinkHref,
          note: courseRowData[19].text));
    }

    return courses;
  }

  static Future<String?> getCourseENName(String url) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      parameter = ConnectorParameter(url);
      parameter.charsetName = 'big5';
      String result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table").first;
      node = node.getElementsByTagName("tr")[1];
      return node.getElementsByTagName("td")[2].text.replaceAll(RegExp(r"\n"), "");
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<CourseSyllabusJson> getCourseCategory(String courseId) async {
    try {
      Map<String, String> data = {
        "snum": courseId,
      };
      ConnectorParameter parameter = ConnectorParameter(_getSyllabusCNUrl);
      parameter.data = data;
      String result = await Connector.getDataByGet(parameter);
      Document tagNode = parse(result);

      final tables = tagNode.getElementsByTagName("table");
      final trs = tables[0].getElementsByTagName("tr");
      final syllabusRow = trs[1].getElementsByTagName("td");

      final model = CourseSyllabusJson(
          yearSemester: syllabusRow[0].text,
          courseId: syllabusRow[1].text,
          courseName: syllabusRow[2].text,
          phase: syllabusRow[3].text,
          credit: syllabusRow[4].text,
          hour: syllabusRow[5].text,
          category: syllabusRow[6].text,
          teachers: syllabusRow[7].text,
          className: syllabusRow[8].text,
          applyStudentCount: syllabusRow[9].text,
          withdrawStudentCount: syllabusRow[10].text,
          note: syllabusRow[11].text);

      return model;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return CourseSyllabusJson();
    }
  }

  static Future<List<SemesterJson>?> getCourseSemester(String studentId) async {
    try {
      ConnectorParameter parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = {
        "code": studentId,
        "format": "-3",
      };
      Response response = await Connector.getDataByPostResponse(parameter);
      Document tagNode = parse(response.toString());

      Element node = tagNode.getElementsByTagName("table")[0];
      List<Element> nodes = node.getElementsByTagName("tr");

      List<SemesterJson> semesterJsonList = [];
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        String year, semester;
        year = node.getElementsByTagName("a")[0].text.split(" ")[0];
        semester = node.getElementsByTagName("a")[0].text.split(" ")[2];
        semesterJsonList.add(SemesterJson(year: year, semester: semester));
      }
      return semesterJsonList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static String strQ2B(String input) {
    List<int> newString = [];
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

  static Future<Map> getGraduation(String year, String department) async {
    ConnectorParameter parameter = ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
    parameter.data = {"format": "-3", "year": year, "matric": "7"};
    String result = await Connector.getDataByGet(parameter);
    Document tagNode = parse(result);

    Element node = tagNode.getElementsByTagName("tbody").first;
    List<Element> nodes = node.getElementsByTagName("tr");
    String redirectHypertextRef =
        nodes.firstWhere((node) => node.text.contains(department)).getElementsByTagName("a").first.attributes["href"]!;

    Map<String, int> graduationMap = await _getGraduationCreditMap(redirectHypertextRef);
    return graduationMap;
  }

  static Future<List<String>?> getYearList() async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<String> resultList = [];
    try {
      parameter = ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.data = {"format": "-1"};
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        resultList.add(node.text);
      }
      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  /*
  Map Key
  name 名稱
  code 參數
  */
  static Future<List<Map>?> getDivisionList(String year) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<Map> resultList = [];
    try {
      parameter = ConnectorParameter(_creditUrl);
      parameter.data = {"format": "-2", "year": year};
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        final href = node.attributes["href"];
        if (href == null || href.isEmpty) {
          throw Exception("getDivisionList: href is null or empty.");
        }
        Map<String, String> code = Uri.parse(href).queryParameters;
        resultList.add({"name": node.text, "code": code});
      }
      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  /*
  Map Key
  name 名稱
  code 參數
  */
  static Future<List<Map<dynamic, dynamic>>?> getDepartmentList(Map code) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<Map> resultList = [];
    try {
      parameter = ConnectorParameter(_creditUrl);
      parameter.data = code;
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table").first;
      nodes = node.getElementsByTagName("a");
      for (int i = 0; i < nodes.length; i++) {
        node = nodes[i];
        final href = node.attributes["href"];
        if (href == null || href.isEmpty) {
          throw Exception("getDepartmentList: href is null or empty.");
        }
        Map<String, String> code = Uri.parse(href).queryParameters;
        String name = node.text.replaceAll(RegExp("[ |s]"), "");
        resultList.add({"name": name, "code": code});
      }
      return resultList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  /*
  Map Key
  minGraduationCredits
  */
  static Future<GraduationInformationJson?> getCreditInfo(Map code, String select) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element anode, trNode, node, tdNode;
    List<Element> trNodes, tdNodes;
    GraduationInformationJson graduationInformation = GraduationInformationJson();
    try {
      Log.d("select is $select");
      parameter = ConnectorParameter(_creditUrl);
      parameter.data = code;
      result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("table").first;
      trNodes = node.getElementsByTagName("tr");
      trNodes.removeAt(0);
      bool pass = false;
      for (int i = 0; i < trNodes.length; i++) {
        trNode = trNodes[i];
        anode = trNode.getElementsByTagName("a").first;
        String name = anode.text.replaceAll(RegExp("[ |s]"), "");
        if (name.contains(select)) {
          tdNodes = trNode.getElementsByTagName("td");
          Log.d(trNode.innerHtml);
          for (int j = 1; j < tdNodes.length; j++) {
            tdNode = tdNodes[j];
            /*
              "○", //	  必	部訂共同必修
              "△", //	必	校訂共同必修
              "☆", //	選	共同選修
              "●", //	  必	部訂專業必修
              "▲", //	  必	校訂專業必修
              "★" //	  選	專業選修
             */
            String creditString = tdNode.text.replaceAll(RegExp(r"[\s|\n]"), "");
            switch (j - 1) {
              case 0:
                graduationInformation.courseTypeMinCredit["○"] = int.parse(creditString);
                break;
              case 1:
                graduationInformation.courseTypeMinCredit["△"] = int.parse(creditString);
                break;
              case 2:
                graduationInformation.courseTypeMinCredit["☆"] = int.parse(creditString);
                break;
              case 3:
                graduationInformation.courseTypeMinCredit["●"] = int.parse(creditString);
                break;
              case 4:
                graduationInformation.courseTypeMinCredit["▲"] = int.parse(creditString);
                break;
              case 5:
                graduationInformation.courseTypeMinCredit["★"] = int.parse(creditString);
                break;
              case 6:
                graduationInformation.outerDepartmentMaxCredit = int.parse(creditString);
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
      if (!pass) {
        Log.d("not find $select");
      }
      return graduationInformation;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<Document> _getSSORedirectNodesInLoginPhase() async {
    ConnectorParameter parameter = ConnectorParameter(_ssoLoginUrl);
    Map<String, String> data = {
      "apUrl": "https://aps.ntut.edu.tw/course/tw/courseSID.jsp",
      "apOu": "aa_0010-",
      "sso": "true",
      "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
    };
    parameter.data = data;
    String result = await Connector.getDataByGet(parameter);

    Document tagNode = parse(result);
    return tagNode;
  }

  static Map<String, dynamic> _getSSOLoginPayload(Document ssoRedirectTagNode) {
    Map<String, dynamic> data = {};
    List<Element> nodes = ssoRedirectTagNode.getElementsByTagName("input");

    for (Element node in nodes) {
      String? name = node.attributes['name'];
      String? value = node.attributes['value'];
      if (name == null || value == null) {
        throw Exception("Cannot fetch name or value.");
      }
      data[name] = value;
    }

    return data;
  }

  static String _getSSOLoginJumpUrl(Document ssoRedirectTagNode) {
    String? jumpUrl = ssoRedirectTagNode.getElementsByTagName("form")[0].attributes["action"];

    if (jumpUrl == null) {
      throw Exception("Cannot fetch jumpUrl.");
    }

    return jumpUrl;
  }

  static Future<void> _tryToSSOLoginOrThrowException(String jumpUrl, Map<String, dynamic> payload) async {
    ConnectorParameter parameter = ConnectorParameter(jumpUrl);
    parameter.data = payload;
    await Connector.getDataByPostResponse(parameter);
  }

  static Future<Map<String, int>> _getGraduationCreditMap(String href) async {
    ConnectorParameter parameter = ConnectorParameter(href);
    String result = await Connector.getDataByGet(parameter);
    Map<String, int> graduationMap = <String, int>{};

    graduationMap["lowCredit"] = _getGraduationCredit(result, RegExp(r"最低畢業學分：?(\d+)學分"));
    graduationMap["△"] = _getGraduationCredit(result, RegExp(r"共同必修：?(\d+)學分"));
    graduationMap["▲"] = _getGraduationCredit(result, RegExp(r"專業必修：?(\d+)學分"));
    graduationMap["★"] = _getGraduationCredit(result, RegExp(r"專業選修：?(\d+)學分"));

    return graduationMap;
  }

  static int _getGraduationCredit(String content, RegExp exp) {
    RegExpMatch? matches = exp.firstMatch(content);
    if (matches == null) {
      return 0;
    }

    String? creditText = matches.group(1);
    if (creditText == null) {
      return 0;
    }

    return int.parse(creditText);
  }
}
