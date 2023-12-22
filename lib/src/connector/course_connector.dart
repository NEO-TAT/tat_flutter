// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/course/course_main_extra_json.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

enum CourseConnectorStatus { loginSuccess, loginFail, unknownError }

class CourseMainInfo {
  List<CourseMainInfoJson> json;
  String studentName;
}

class CourseConnector {
  static const _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static const String _courseCNHost = "https://aps.ntut.edu.tw/course/tw/";
  static const String _courseENHost = "https://aps.ntut.edu.tw/course/en/";
  static const String _postCourseCNUrl = "${_courseCNHost}Select.jsp";
  static const String _postTeacherCourseCNUrl = "${_courseCNHost}Teach.jsp";
  static const String _postCourseENUrl = "${_courseENHost}Select.jsp";
  static const String _creditUrl = "${_courseCNHost}Cprog.jsp";

  static Future<CourseConnectorStatus> login() async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "apUrl": "https://aps.ntut.edu.tw/course/tw/courseSID.jsp",
        "apOu": "aa_0010-",
        "sso": "true",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_ssoLoginUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("input");
      data = {};
      for (Element node in nodes) {
        String name = node.attributes['name'];
        String value = node.attributes['value'];
        data[name] = value;
      }
      String jumpUrl = tagNode.getElementsByTagName("form")[0].attributes["action"];
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;
      await Connector.getDataByPostResponse(parameter);
      return CourseConnectorStatus.loginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return CourseConnectorStatus.loginFail;
    }
  }

  static Future<String> getCourseENName(String url) async {
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

  static Future<CourseExtraInfoJson> getCourseExtraInfo(String courseId) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodes, classExtraInfoNodes;
      Map<String, String> data = {
        "code": courseId,
        "format": "-1",
      };
      parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = data;
      String result = await Connector.getDataByPost(parameter);
      tagNode = parse(result);
      courseNodes = tagNode.getElementsByTagName("table");

      CourseExtraInfoJson courseExtraInfo = CourseExtraInfoJson();

      //取得學期資料
      nodes = courseNodes[0].getElementsByTagName("td");
      SemesterJson semester = SemesterJson();

      // Previously, the title string of the first course table was stored separately in its `<td>` element,
      // but it currently stores all the information in a row,
      // e.g. "學號：110310144　　姓名：xxx　　班級：電機三甲　　　 112 學年度 第 1 學期　上課時間表"
      // so the RegExp is used to filter out only the number parts
      final titleString = nodes[0].text;
      final RegExp studentSemesterDetailFilter = RegExp(r'\b[\dA-Z]+\b');
      final Iterable<RegExpMatch> studentSemesterDetailMatches = studentSemesterDetailFilter.allMatches(titleString);
      // "studentSemesterDetails" should consist of three numerical values
      // ex: [110310144, 112, 1]
      final List<String> studentSemesterDetails = studentSemesterDetailMatches.map((match) => match.group(0)).toList();
      if (studentSemesterDetails.isEmpty) {
        throw RangeError("[TAT] course_connector.dart: studentSemesterDetails list is empty");
      }
      if (studentSemesterDetails.length < 3) {
        throw RangeError("[TAT] course_connector.dart: studentSemesterDetails list has range less than 3");
      }
      semester.year = studentSemesterDetails[1];
      semester.semester = studentSemesterDetails[2];

      courseExtraInfo.courseSemester = semester;

      CourseExtraJson courseExtra = CourseExtraJson();

      nodes = courseNodes[1].getElementsByTagName("tr");
      final List<String> courseIds = nodes.skip(2).map((node) => node.getElementsByTagName("td")[0].text).toList();
      final courseIdPosition = courseIds.indexWhere((element) => element.contains(courseId));
      if (courseIdPosition == -1) {
        throw StateError('[TAT] course_connector.dart: CourseId not found: $courseId');
      } else {
        node = nodes[courseIdPosition + 2];
      }
      classExtraInfoNodes = node.getElementsByTagName("td");
      courseExtra.id = strQ2B(classExtraInfoNodes[0].text).replaceAll(RegExp(r"\s"), "");
      courseExtra.name = classExtraInfoNodes[1].getElementsByTagName("a")[0].text;
      courseExtra.openClass = classExtraInfoNodes[7].getElementsByTagName("a")[0].text;

      // if the courseExtraInfo.herf (課程大綱連結) is empty,
      // the category of the course will be set to ▲ (校訂專業必修) as default
      if (classExtraInfoNodes[18].text.trim() != "" &&
          classExtraInfoNodes[18].getElementsByTagName("a")[0].attributes.containsKey("href")) {
        courseExtra.href = _courseCNHost + classExtraInfoNodes[18].getElementsByTagName("a")[0].attributes["href"];
        parameter = ConnectorParameter(courseExtra.href);
        result = await Connector.getDataByPost(parameter);
        tagNode = parse(result);
        nodes = tagNode.getElementsByTagName("tr");
        courseExtra.category = nodes[1].getElementsByTagName("td")[6].text;
      } else {
        courseExtra.category = constCourseType[4];
      }

      courseExtra.selectNumber = "s?";
      courseExtra.withdrawNumber = "w?";

      courseExtraInfo.course = courseExtra;
      return courseExtraInfo;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<SemesterJson>> getCourseSemester(String studentId) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> nodes;

      Map<String, String> data = {
        "code": studentId,
        "format": "-3",
      };
      parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = data;
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[0];
      nodes = node.getElementsByTagName("tr");
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

  static Future<CourseMainInfo> getENCourseMainInfoList(String studentId, SemesterJson semester) async {
    var info = CourseMainInfo();
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> courseNodes, nodesOne, nodes;
      List<Day> dayEnum = [Day.Sunday, Day.Monday, Day.Tuesday, Day.Wednesday, Day.Thursday, Day.Friday, Day.Saturday];
      Map<String, String> data = {
        "code": studentId,
        "format": "-2",
        "year": semester.year,
        "sem": semester.semester,
      };
      parameter = ConnectorParameter(_postCourseENUrl);
      parameter.data = data;
      parameter.charsetName = 'utf-8';
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      nodes = tagNode.getElementsByTagName("table");
      courseNodes = nodes[1].getElementsByTagName("tr");
      String studentName;
      try {
        studentName = strQ2B(nodes[0].getElementsByTagName("td")[4].text).replaceAll(RegExp(r"[\n| ]"), "");
      } catch (e, stack) {
        Log.eWithStack(e.toString(), stack);
        studentName = "";
      }
      info.studentName = studentName;

      List<CourseMainInfoJson> courseMainInfoList = [];
      for (int i = 1; i < courseNodes.length - 1; i++) {
        CourseMainInfoJson courseMainInfo = CourseMainInfoJson();
        CourseMainJson courseMain = CourseMainJson();
        nodesOne = courseNodes[i].getElementsByTagName("td");
        if (nodesOne[16].text.contains("Withdraw")) {
          continue;
        }
        //取得課號
        courseMain.id = strQ2B(nodesOne[0].text).replaceAll(RegExp(r"[\n| ]"), "");
        //取的課程名稱/課程連結
        nodes = nodesOne[1].getElementsByTagName("a"); //確定是否有連結
        if (nodes.isNotEmpty) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }
        courseMain.credits = nodesOne[2].text.replaceAll("\n", ""); //學分
        courseMain.hours = nodesOne[3].text.replaceAll("\n", ""); //時數

        //時間
        for (int j = 0; j < 7; j++) {
          Day day = dayEnum[j]; //要做變換網站是從星期日開始
          String time = nodesOne[j + 6].text;
          time = strQ2B(time);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        int length;
        //取得老師名稱
        length = nodesOne[4].innerHtml.split("<br>").length;
        for (String name in nodesOne[4].innerHtml.split("<br>")) {
          TeacherJson teacher = TeacherJson();
          teacher.name = name.replaceAll("\n", "");
          courseMainInfo.teacher.add(teacher);
        }

        //取得教室名稱
        length = nodesOne[13].innerHtml.split("<br>").length;
        for (String name in nodesOne[13].innerHtml.split("<br>").getRange(0, length - 1)) {
          ClassroomJson classroom = ClassroomJson();
          classroom.name = name.replaceAll("\n", "");
          courseMainInfo.classroom.add(classroom);
        }

        //取得開設教室名稱
        for (Element node in nodesOne[5].getElementsByTagName("a")) {
          ClassJson classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = _courseCNHost + node.attributes["href"];
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

  static Future<CourseMainInfo> getTWCourseMainInfoList(String studentId, SemesterJson semester) async {
    var info = CourseMainInfo();
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodesOne, nodes;
      List<Day> dayEnum = [Day.Sunday, Day.Monday, Day.Tuesday, Day.Wednesday, Day.Thursday, Day.Friday, Day.Saturday];
      Map<String, String> data = {
        "code": studentId,
        "format": "-2",
        "year": semester.year,
        "sem": semester.semester,
      };
      parameter = ConnectorParameter(_postCourseCNUrl);
      parameter.data = data;
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[1];
      courseNodes = node.getElementsByTagName("tr");
      String studentName;
      try {
        studentName = RegExp(r"姓名：([\u4E00-\u9FA5]+)").firstMatch(courseNodes[0].text).group(1);
      } catch (e) {
        studentName = "";
      }
      info.studentName = studentName;
      List<CourseMainInfoJson> courseMainInfoList = [];
      for (int i = 2; i < courseNodes.length - 1; i++) {
        CourseMainInfoJson courseMainInfo = CourseMainInfoJson();
        CourseMainJson courseMain = CourseMainJson();

        nodesOne = courseNodes[i].getElementsByTagName("td");
        if (nodesOne[16].text.contains("撤選")) {
          continue;
        }
        //取得課號
        courseMain.id = strQ2B(nodesOne[0].text).replaceAll(RegExp(r"\s"), "");

        //取的課程名稱/課程連結
        nodes = nodesOne[1].getElementsByTagName("a"); //確定是否有連結
        if (nodes.isNotEmpty) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }
        courseMain.stage = nodesOne[2].text.replaceAll("\n", ""); //階段
        courseMain.credits = nodesOne[3].text.replaceAll("\n", ""); //學分
        courseMain.hours = nodesOne[4].text.replaceAll("\n", ""); //時數
        courseMain.note = nodesOne[19].text.replaceAll("\n", ""); //備註
        if (nodesOne[18].getElementsByTagName("a").isNotEmpty) {
          courseMain.scheduleHref =
              _courseCNHost + nodesOne[18].getElementsByTagName("a")[0].attributes["href"]; //教學進度大綱
        }

        //時間
        for (int j = 0; j < 7; j++) {
          Day day = dayEnum[j]; //要做變換網站是從星期日開始
          String time = nodesOne[j + 8].text;
          time = strQ2B(time);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        //取得老師名稱
        for (Element node in nodesOne[6].getElementsByTagName("a")) {
          TeacherJson teacher = TeacherJson();
          teacher.name = node.text;
          teacher.href = _courseCNHost + node.attributes["href"];
          courseMainInfo.teacher.add(teacher);
        }

        //取得教室名稱
        for (Element node in nodesOne[15].getElementsByTagName("a")) {
          ClassroomJson classroom = ClassroomJson();
          classroom.name = node.text;
          classroom.href = _courseCNHost + node.attributes["href"];
          courseMainInfo.classroom.add(classroom);
        }

        //取得開設教室名稱
        for (Element node in nodesOne[7].getElementsByTagName("a")) {
          ClassJson classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = _courseCNHost + node.attributes["href"];
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

  static Future<CourseMainInfo> getTWTeacherCourseMainInfoList(String studentId, SemesterJson semester) async {
    var info = CourseMainInfo();
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodesOne, nodes;
      List<Day> dayEnum = [Day.Sunday, Day.Monday, Day.Tuesday, Day.Wednesday, Day.Thursday, Day.Friday, Day.Saturday];
      Map<String, String> data = {
        "code": studentId,
        "format": "-3",
        "year": semester.year,
        "sem": semester.semester,
      };
      parameter = ConnectorParameter(_postTeacherCourseCNUrl);
      parameter.data = data;
      parameter.charsetName = 'big5';
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[0];
      courseNodes = node.getElementsByTagName("tr");
      String studentName;
      try {
        studentName = courseNodes[0].text.replaceAll("　　", " ").split(" ")[2];
      } catch (e) {
        studentName = "";
      }
      info.studentName = studentName;
      List<CourseMainInfoJson> courseMainInfoList = [];
      for (int i = 2; i < courseNodes.length - 1; i++) {
        CourseMainInfoJson courseMainInfo = CourseMainInfoJson();
        CourseMainJson courseMain = CourseMainJson();

        nodesOne = courseNodes[i].getElementsByTagName("td");
        if (nodesOne[16].text.contains("撤選")) {
          continue;
        }
        //取得課號
        nodes = nodesOne[0].getElementsByTagName("a"); //確定是否有課號
        if (nodes.isNotEmpty) {
          courseMain.id = nodes[0].text;
          courseMain.href = _courseCNHost + nodes[0].attributes["href"];
        }
        //取的課程名稱/課程連結
        nodes = nodesOne[1].getElementsByTagName("a"); //確定是否有連結
        if (nodes.isNotEmpty) {
          courseMain.name = nodes[0].text;
        } else {
          courseMain.name = nodesOne[1].text;
        }
        courseMain.stage = nodesOne[2].text.replaceAll("\n", ""); //階段
        courseMain.credits = nodesOne[3].text.replaceAll("\n", ""); //學分
        courseMain.hours = nodesOne[4].text.replaceAll("\n", ""); //時數
        courseMain.note = nodesOne[20].text.replaceAll("\n", ""); //備註
        if (nodesOne[19].getElementsByTagName("a").isNotEmpty) {
          courseMain.scheduleHref =
              _courseCNHost + nodesOne[19].getElementsByTagName("a")[0].attributes["href"]; //教學進度大綱
        }

        //時間
        for (int j = 0; j < 7; j++) {
          Day day = dayEnum[j]; //要做變換網站是從星期日開始
          String time = nodesOne[j + 8].text;
          time = strQ2B(time);
          courseMain.time[day] = time;
        }

        courseMainInfo.course = courseMain;

        //取得老師名稱
        TeacherJson teacher = TeacherJson();
        teacher.name = "";
        teacher.href = "";
        courseMainInfo.teacher.add(teacher);

        //取得教室名稱
        for (Element node in nodesOne[15].getElementsByTagName("a")) {
          ClassroomJson classroom = ClassroomJson();
          classroom.name = node.text;
          classroom.href = _courseCNHost + node.attributes["href"];
          courseMainInfo.classroom.add(classroom);
        }

        //取得開設教室名稱
        for (Element node in nodesOne[7].getElementsByTagName("a")) {
          ClassJson classInfo = ClassJson();
          classInfo.name = node.text;
          classInfo.href = _courseCNHost + node.attributes["href"];
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

  static Future<Map> getGraduation(String year, String department) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    RegExp exp;
    RegExpMatch matches;
    Map graduationMap = {};
    try {
      parameter = ConnectorParameter("https://aps.ntut.edu.tw/course/tw/Cprog.jsp");
      parameter.data = {"format": "-3", "year": year, "matric": "7"};
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("tbody").first;
      nodes = node.getElementsByTagName("tr");
      String href;
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        node = node.getElementsByTagName("a").first;
        if (node.text.contains(department)) {
          href = node.attributes["href"];
          break;
        }
      }
      href = "https://aps.ntut.edu.tw/course/tw/$href";
      parameter = ConnectorParameter(href);
      result = await Connector.getDataByGet(parameter);

      exp = RegExp(r"最低畢業學分：?(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["lowCredit"] = int.parse(matches.group(1));

      exp = RegExp(r"共同必修：?(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["△"] = int.parse(matches.group(1));

      exp = RegExp(r"專業必修：?(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["▲"] = int.parse(matches.group(1));

      exp = RegExp(r"專業選修：?(\d+)學分");
      matches = exp.firstMatch(result);
      graduationMap["★"] = int.parse(matches.group(1));

      /*
      exp = RegExp("通識博雅課程應修滿(\d+)學分");
      matches = exp.firstMatch(result);
      exp = RegExp("跨系所專業選修(\d+)學分為畢業學分");
      matches = exp.firstMatch(result);
      */
      return graduationMap;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<String>> getYearList() async {
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
  static Future<List<Map>> getDivisionList(String year) async {
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
        Map<String, String> code = Uri.parse(node.attributes["href"]).queryParameters;
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
  static Future<List<Map>> getDepartmentList(Map code) async {
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
        Map<String, String> code = Uri.parse(node.attributes["href"]).queryParameters;
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
  static Future<GraduationInformationJson> getCreditInfo(Map code, String select) async {
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
}
