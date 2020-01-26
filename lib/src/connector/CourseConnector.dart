import 'package:big5/big5.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'Connector.dart';
import 'ConnectorParameter.dart';

enum CourseLoginStatus {
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


  static Future<CourseLoginStatus> login() async {
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
      return CourseLoginStatus.LoginSuccess;
    } on Exception catch (e) {
      Log.e(e.toString());
      return CourseLoginStatus.LoginFail;
    }
  }


  static void getCourseByCourseId(String courseId) async{
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
    }on Exception catch(e){
      Log.e(e.toString());
      throw e;
    }
  }

  static void getCourseByStudentId(String studentId) async{
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
    }on Exception catch(e){
      Log.e(e.toString());
      throw e;
    }
  }


}