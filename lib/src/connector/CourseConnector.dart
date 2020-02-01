import 'dart:convert';

import 'package:big5/big5.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/src/store/json/CourseInfoJson.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'Connector.dart';
import 'ConnectorParameter.dart';

enum CourseConnectorStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class CourseConnector {
  static bool _isLogin = false;
  static final String _getLoginCourseUrl =
      "https://nportal.ntut.edu.tw/ssoIndex.do";
  static final String _postCourseUrl =
      "https://aps.ntut.edu.tw/course/tw/Select.jsp";
  static final String _checkLoginUrl =
      "https://aps.ntut.edu.tw/course/tw/Select.jsp";


  static Future<CourseConnectorStatus> login() async {
    String result;
    _isLogin = false;
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
      parameter = ConnectorParameter(_getLoginCourseUrl);
      parameter.data = data;
      result = await Connector.getDataByGet( parameter );
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("input");
      data = Map();
      for (Element node in nodes) {
        String name = node.attributes['name'];
        String value = node.attributes['value'];
        data[name] = value;
      }
      String jumpUrl = tagNode.getElementsByTagName("form")[0].attributes["action"];
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;
      Response response = await Connector.getDataByPostResponse( parameter );
      _isLogin = true;
      return CourseConnectorStatus.LoginSuccess;
    } on Exception catch (e) {
      Log.e(e.toString());
      return CourseConnectorStatus.LoginFail;
    }
  }


  static Future<CourseInfoJson> getCourseByCourseId(String courseId) async{
    try{
      ConnectorParameter parameter;
      Document tagNode;
      List<Element>  courseNodes , courseInfoNodes;
      Map<String, String> data = {
        "code": courseId,
        "format": "-1",
      };
      parameter = ConnectorParameter(_postCourseUrl);
      parameter.data = data;
      parameter.charsetName = 'big5';
      String result = await Connector.getDataByPost( parameter );
      tagNode = parse(result);
      courseNodes = tagNode.getElementsByTagName("table");

      CourseInfoJson courseInfo = CourseInfoJson();

      //取得學期資料
      courseInfoNodes = courseNodes[0].getElementsByTagName("td");
      SemesterJson semester = SemesterJson();
      semester.year = courseInfoNodes[1].text;
      semester.semester = courseInfoNodes[2].text;

      //取得課程資料
      CourseDetailJson courseDetail = CourseDetailJson();
      CourseJson course = CourseJson();
      course.id = courseInfoNodes[0].text;
      course.name = courseInfoNodes[3].getElementsByTagName("a")[0].text;
      course.href = courseInfoNodes[3].getElementsByTagName("a")[0].attributes['href'];
      courseDetail.course = course;

      //取的剩餘資料
      courseDetail.stage   = courseInfoNodes[4].text;
      courseDetail.credits = courseInfoNodes[5].text;
      courseDetail.hours   = courseInfoNodes[6].text;
      courseDetail.category = courseInfoNodes[7].text;
      courseDetail.selectNumber =  courseInfoNodes[11].text;
      courseDetail.withdrawNumber =  courseInfoNodes[12].text;

      courseInfo.courseSemester = semester;
      courseInfo.courseDetail = courseDetail;

      //取得老師資料
      for( Element value in courseInfoNodes[8].getElementsByTagName("a") ){
        TeacherJson teacher = TeacherJson();
        if( value.attributes['href'].contains("format") ){  // 確定是老師名稱
          teacher.name = value.text;
          teacher.href = value.attributes['href'];
        }
        courseInfo.teacher.add(teacher);
      }

      //取得教室資料
      for( Element value in courseInfoNodes[10].getElementsByTagName("a") ){
        ClassroomJson classroom = ClassroomJson();
        classroom.name = value.text;
        classroom.href = value.attributes['href'];
        courseInfo.classroom.add(classroom);
      }

      //取得開課班級
      for( Element value in courseInfoNodes[11].getElementsByTagName("a") ){
        CourseJson course;
        course.name = value.text;
        course.href = value.attributes['href'];
        courseInfo.openClass.add(course);
      }
      return courseInfo;
    }on Exception catch(e){
      //throw e;
      Log.e(e.toString());
      return null;
    }
  }

  static Future<List<SemesterJson>> getSemesterByStudentId(String studentId) async{
    try{
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> nodes , courseNodes , courseInfo;

      Map<String, String> data = {
        "code": studentId,
        "format": "-3",
      };
      parameter = ConnectorParameter( _postCourseUrl );
      parameter.data = data;
      parameter.charsetName  = 'big5';
      Response response = await Connector.getDataByPostResponse( parameter );
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[0];
      nodes = node.getElementsByTagName("tr");
      List<SemesterJson> semesterJsonList = List();
      for( int i = 1 ; i < nodes.length ; i++) {
        node = nodes[i];
        String year, semester;
        year = node.getElementsByTagName("a")[0].text.split(" ")[0];
        semester = node.getElementsByTagName("a")[0].text.split(" ")[2];
        semesterJsonList.add( SemesterJson( year: year , semester:  semester ) );
      }
      return semesterJsonList;
    }on Exception catch(e){
      //throw e;
      Log.e(e.toString());
      return null;
    }
  }

  static String strQ2B(String input)
  {
    List<int> newString = List();
    for (int c in input.codeUnits)
    {
      if ( c == 12288)
      {
        c = 32;
        continue;
      }
      if (c > 65280 && c< 65375){
        c = (c - 65248);
      }
      newString.add(c);
    }
    return String.fromCharCodes(newString);
  }




  static Future<CourseTableJson> getCourseByStudentId(String studentId , SemesterJson semester) async {
    try {
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> courseNodes, nodesOne, nodes;
      CourseTableJson courseTable = CourseTableJson();
      courseTable.setCourseSemester(semester.year, semester.semester );

      Map<String, String> data = {
        "code": studentId,
        "format": "-2",
        "year": semester.year,
        "sem": semester.semester,
      };
      parameter = ConnectorParameter(_postCourseUrl);
      parameter.data = data;
      parameter.charsetName = 'big5';
      Response response = await Connector.getDataByPostResponse(parameter);
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[1];
      courseNodes = node.getElementsByTagName("tr");

      for (int i = 2; i < courseNodes.length - 1; i++) {
        CourseTableDetailJson courseDetail = CourseTableDetailJson();
        CourseJson course = CourseJson();

        nodesOne = courseNodes[i].getElementsByTagName("td");

        //取得課號
        nodes = nodesOne[0].getElementsByTagName("a");
        if (nodes.length >= 1) {
          course.id = nodes[0].text;
          course.href = nodes[0].attributes["href"];
        }

        //取的課程名稱/課程連結
        nodes = nodesOne[1].getElementsByTagName("a");
        if (nodes.length >= 1) {
          course.name = nodes[0].innerHtml;
        } else {
          course.name = nodesOne[1].text;
        }

        courseDetail.course = course;

        //取得老師名稱
        for (Element node in nodesOne[6].getElementsByTagName("a")) {
          TeacherJson teacher = TeacherJson();
          teacher.name = node.text;
          teacher.href = node.attributes["href"];
          courseDetail.addTeacher(teacher);
        }

        //取得教室名稱
        List<ClassroomJson> classroomList = List();
        for (Element node in nodesOne[15].getElementsByTagName("a")) {
          ClassroomJson classroom = ClassroomJson();
          classroom.name = node.text;
          classroom.href = node.attributes["href"];
          classroomList.add(classroom);
        }
        int courseDay = 0;
        bool add = false;
        for (int j = 8; j < 8 + 7; j++) {
          String time = nodesOne[j].text;
          //計算教室
          if (classroomList.length >= 1) {
            int classroomIndex = (courseDay < classroomList.length)
                ? courseDay
                : classroomList.length - 1;
            courseDetail.classroom = classroomList[ classroomIndex ];
          }
          courseDay++;
          //加入課程時間
          add |= courseTable.setCourseDetailByTimeString(
              Day.values[ j - 8 ], time, courseDetail);
        }
        if (!add) { //代表課程沒有時間
          courseTable.setCourseDetailByTime(
              Day.UnKnown, SectionNumber.T_UnKnown, courseDetail);
        }
      }
      //Log.d( courseTable.toString() );
      return courseTable;
    } on Exception catch (e) {
      //throw e;
      Log.e(e.toString());
      return null;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static Future<bool> checkLogin() async {
    Log.d("Course CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    try {
      parameter = ConnectorParameter(_checkLoginUrl);
      parameter.charsetName = "big5";
      String result = await Connector.getDataByGet(parameter);
      if (result.isEmpty || result.contains("尚未登錄入口網站")) {
        return false;
      } else {
        Log.d("Course Is Readly Login");
        _isLogin = true;
        return true;
      }
    } on Exception catch (e) {
      //throw e;
      Log.e(e.toString());
      return false;
    }
  }

}