import 'dart:convert';

import 'package:big5/big5.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
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


  static Future<bool> getCourseByCourseId(String courseId) async{
    try{
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "code": courseId,
        "format": "-1",
      };
      parameter = ConnectorParameter(_postCourseUrl);
      parameter.data = data;
      String result = await Connector.getDataByPost( parameter );
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("a");
      for( Element node in nodes){
        Log.d( node.attributes["herf"] );
        Log.d( node.innerHtml );
      }
      return true;
    }on Exception catch(e){
      //throw e;
      Log.e(e.toString());
      return false;
    }
  }

  static Future<bool> getSemesterByStudentId(String studentId) async{
    try{
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "code": studentId,
        "format": "-3",
      };
      parameter = ConnectorParameter( _postCourseUrl );
      parameter.data = data;
      parameter.charsetName  = 'big5';
      Response response = await Connector.getDataByPostResponse( parameter );
      tagNode = parse(response.toString());
      nodes = tagNode.getElementsByTagName("a");
      for( Element node in nodes){
        Log.d( node.attributes["href"] );
        Log.d( node.innerHtml );
      }
      return true;
    }on Exception catch(e){
      //throw e;
      Log.e(e.toString());
      return false;
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




  static Future<CourseTableJson> getCourseByStudentId(String studentId , String year , String semester) async{
    try{
      ConnectorParameter parameter;
      Document tagNode;
      Element node;
      List<Element> nodes , nodesOne;
      String courseName , courseId , courseHref;
      List<List<CourseTimeJson>> courseTime;
      List<String> teacherName;
      List<CourseClassroomJson> courseClassroom;
      CourseTableJson courseTable = CourseTableJson();
      Map<String, String> data = {
        "code": studentId,
        "format": "-2",
        "year" : year ,
        "sem" : semester ,
      };
      parameter = ConnectorParameter( _postCourseUrl );
      parameter.data = data;
      parameter.charsetName  = 'big5';
      Response response = await Connector.getDataByPostResponse( parameter );
      tagNode = parse(response.toString());
      node = tagNode.getElementsByTagName("table")[1];
      nodes = node.getElementsByTagName("tr");
      courseTable.courseSemester = CourseSemesterJson( year:year , semester:semester );

      for ( int i = 3 ; i < nodes.length-1 ; i++){
        courseTime = List();
        courseClassroom = List();
        teacherName = List();
        nodesOne = nodes[i].getElementsByTagName("td");
        courseName = nodesOne[1].getElementsByTagName("a")[0].innerHtml;
        for( Element node in nodesOne[6].getElementsByTagName("a") ){
          teacherName.add( node.text );
        }
        for( Element node in nodesOne[15].getElementsByTagName("a") ){
          CourseClassroomJson classroom = CourseClassroomJson();
          classroom.name = node.text;
          classroom.href = node.attributes["href"];
          courseClassroom.add( classroom );
        }
        int courseDay = 0;
        for( int j = 8 ; j < 8 + 7 ; j++ ){
          List<CourseTimeJson> courseTimeList = List();
          String time = nodesOne[j].text;
          if( strQ2B(time).replaceAll(" ", "").isNotEmpty ){
            int timeLength = time.split(" ").length;
            for ( String t in time.split(" ").getRange(1, timeLength ).toList() ){
              CourseTimeJson courseTimeItem  = CourseTimeJson();
              courseTimeItem.time = t;
              if( courseClassroom.length >= 1){
                int classroomIndex = ( courseDay < courseClassroom.length ) ? courseDay : courseClassroom.length-1;
                courseTimeItem.classroom =  courseClassroom[classroomIndex];
              }
              courseTimeList.add( courseTimeItem );
            }
            courseTime.add(courseTimeList);
            courseDay++;
          }else{
            courseTime.add( List() );
          }
        }

        courseId = nodesOne[0].text.replaceAll("\n", "");
        courseHref = nodesOne[1].getElementsByTagName("a")[0].attributes["href"];

        var courseDetail = CourseDetailJson(
          courseName : courseName ,
          courseId : courseId ,
          teacherName : teacherName ,
          courseHref : courseHref ,
          courseTime : courseTime ,
        );
        courseTable.courseDetail.add( courseDetail );
      }
      return courseTable;
    }on Exception catch(e){
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