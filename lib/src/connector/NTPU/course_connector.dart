// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:convert';
import 'dart:math';

import 'package:dart_big5/big5.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/connector.dart';
import 'package:flutter_app/src/connector/core/connector_parameter.dart';
import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/connector/ntpu_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:tat_core/core/course/domain/course.dart';

import '../../model/course/course_main_extra_json.dart';

enum CourseConnectorStatus { loginSuccess, loginFail, unknownError }

class CourseMainInfo {
  List<CourseMainInfoJson> json;
  String studentName;
}

class CourseConnector {
  //static const str_SSOLoginTokenURL = "${NTPU_Connector.host}get-projects/10?url=https%3A%2F%2Fohs01.ntpu.edu.tw%2Fpls%2Fgradu%2Fquery_all_course.judge%3Ffunc%3D4";
  static const str_CurrentSemesterCourseListURL = "${NTPU_Connector.host}get-projects/10?url=https%3A%2F%2Fohs01.ntpu.edu.tw%2Fpls%2Funiver%2Fu0001.query_all_course.judge%3Ffunc%3D3_m";

  static Future<List<dynamic>> login(String str_ProjectURL) async {
    Dio NetworkConnector = LocalStorage.NetworkConnector;
    Response CourseResponse = await NetworkConnector.get(str_ProjectURL);
    Map<String, dynamic> StudentLoginToken;

    String str_SSOURL = "";
    String str_CourseURL = "";
    String str_CourseData = CourseResponse.toString();
    try {
      str_SSOURL = jsonDecode(str_CourseData)["form_url"];
      str_CourseURL = jsonDecode(str_CourseData)["base_url"];
      StudentLoginToken = jsonDecode(str_CourseData)["formData"];
    }
    catch(e, StackTrace) {
      Log.error(e, StackTrace);
      return [CourseConnectorStatus.unknownError, ""];
    }

    //Get ohs system token.
    // NetworkConnector.options.headers.addAll({"origin": NTPU_Connector.host, "Referer": NTPU_Connector.host});
    try {
      CourseResponse = await NetworkConnector.post(str_SSOURL, data: "id=${StudentLoginToken["id"]}&pw=${StudentLoginToken["pw"]}");
      CourseResponse = await NetworkConnector.get(str_CourseURL, options: Options(responseType: ResponseType.bytes));
      str_CourseData = big5.decode(CourseResponse.data);
    }
    catch(e, stackTrace) {
      Log.error(e, stackTrace);
      return [CourseConnectorStatus.loginFail, ""];
    }

    return [CourseConnectorStatus.loginSuccess, str_CourseData];
  }

  /*Get current semester course table.*/
  static Future<CourseMainInfo> getCurrentSemesterCourseMainInfoList() async {
    CourseMainInfo info = CourseMainInfo();
    try {
      List<dynamic> result = await login(str_CurrentSemesterCourseListURL);
      if (result[0] == CourseConnectorStatus.loginSuccess) {
        String str_HTMLDoc = result[1];
        List<Element> L_nodes = parse(str_HTMLDoc).getElementsByTagName("table")[0].getElementsByTagName("tbody");
        List<Element> CourseNodes = L_nodes[0].getElementsByTagName("tr");

        List<Day> WeekDayEnum = [Day.Sunday, Day.Monday, Day.Tuesday, Day.Wednesday, Day.Thursday, Day.Friday, Day.Saturday];

        List<CourseMainInfoJson> CourseMainInfoList = [];
        for(int Run = 0; Run < CourseNodes.length; Run++) {
          CourseMainInfoJson MainInfo = CourseMainInfoJson();
          CourseMainJson CourseInfo = CourseMainJson();
          List<Element> CourseNode = CourseNodes[Run].getElementsByTagName("td");

          List<String> str_Tmp = CourseNode[1].text.split("(");
          String str_Classroom = "";
          CourseInfo.id = str_Tmp[1].replaceAll(")", ""); // CourseID
          CourseInfo.name = str_Tmp[0]; // CourseName

          str_Tmp = CourseNode[6].text.split("/");
          CourseInfo.credits = str_Tmp[0];
          CourseInfo.hours = str_Tmp[1];

          // Course Time analysis.
          str_Tmp = CourseNode[4].innerHtml.split("<br>");
          for(int WeekOfDay = 0; WeekOfDay < 7; WeekOfDay++) {
            CourseInfo.time[WeekDayEnum[WeekOfDay]] = " ";
          }
          for(int CourseWeekdayIndex = 0; CourseWeekdayIndex < (str_Tmp.length / 2).floor(); CourseWeekdayIndex++) {
            if(str_Tmp[CourseWeekdayIndex] == "") {
              break;
            }
            String TimeStr = str_Tmp[CourseWeekdayIndex].substring(1).replaceAll("~", " ");
            int i_Start = int.parse(TimeStr.split(" ")[0]);
            int i_End = int.parse(TimeStr.split(" ")[1]);
            TimeStr = "";
            for(int Run = i_Start; Run <= i_End; Run++) {
              if(Run == i_End) {
                TimeStr += "${Run.toString()} ";
              }
              else {
                TimeStr += Run.toString();
              }
            }
            switch(str_Tmp[CourseWeekdayIndex][0]) {
              case "日":
                CourseInfo.time[WeekDayEnum[0]] = TimeStr;
                break;
              case "一":
                CourseInfo.time[WeekDayEnum[1]] = TimeStr;
                break;
              case "二":
                CourseInfo.time[WeekDayEnum[2]] = TimeStr;
                break;
              case "三":
                CourseInfo.time[WeekDayEnum[3]] = TimeStr;
                break;
              case "四":
                CourseInfo.time[WeekDayEnum[4]] = TimeStr;
                break;
              case "五":
                CourseInfo.time[WeekDayEnum[5]] = TimeStr;
                break;
              case "六":
                CourseInfo.time[WeekDayEnum[6]] = TimeStr;
                break;
            }
            if (CourseWeekdayIndex + (str_Tmp.length / 2).floor() < str_Tmp.length) {
              if (str_Classroom != "") {
                str_Classroom += "/${str_Tmp[CourseWeekdayIndex + (str_Tmp.length / 2).floor()].replaceAll("@", "")}";
              }
              else {
                str_Classroom += str_Tmp[CourseWeekdayIndex + (str_Tmp.length / 2).floor()].replaceAll("@", "");
              }
            }
          }

          MainInfo.course = CourseInfo;

          // Information of course's teacher.
          TeacherJson teacher = TeacherJson();
          teacher.name = CourseNode[3].text;
          MainInfo.teacher.add(teacher);

          // Information of class room.
          ClassroomJson ClassroomInfo = ClassroomJson();
          ClassroomInfo.name = str_Classroom;
          ClassroomInfo.href = "";
          MainInfo.classroom.add(ClassroomInfo);


          CourseMainInfoList.add(MainInfo);
        }
        info.json = CourseMainInfoList;
      } else {
        return null;
      }
    }
    catch(e, stackTrace) {
      Log.error(e, stackTrace);
      return null;
    }

    return info;
  }
}