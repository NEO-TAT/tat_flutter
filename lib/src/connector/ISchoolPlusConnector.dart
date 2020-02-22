import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/RequestsConnector.dart';
import 'package:flutter_app/src/store/json/CourseFileJson.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:tripledes/tripledes.dart';
import 'core/ConnectorParameter.dart';

enum ISchoolPlusConnectorStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class ISchoolPlusConnector {
  static bool _isLogin = true;

  static final String _iSchoolPlusUrl = "https://istudy.ntut.edu.tw/";
  static final String _getLoginISchoolUrl = _iSchoolPlusUrl + "mooc/login.php";
  static final String _postLoginISchoolUrl = _iSchoolPlusUrl + "login.php";
  static final String _iSchoolPlusIndexUrl = _iSchoolPlusUrl + "mooc/index.php";
  static final String _iSchoolPlusLearnIndexUrl =
      _iSchoolPlusUrl + "learn/index.php";
  static final String _checkLoginUrl = _iSchoolPlusLearnIndexUrl;
  static final String _getCourseName =
      _iSchoolPlusUrl + "learn/mooc_sysbar.php";

  static Future<ISchoolPlusConnectorStatus> login(
      String account, String password) async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Element node;

      await RequestsConnector.deleteCookies(_iSchoolPlusUrl); //刪除先前登入

      parameter = ConnectorParameter(_getLoginISchoolUrl);
      result = await RequestsConnector.getDataByGet(parameter);

      tagNode = parse(result);
      node = tagNode.getElementById("loginForm");
      nodes = node.getElementsByTagName("input");
      String loginKey;
      for (Element node in nodes) {
        if (node.attributes["name"] == "login_key")
          loginKey = node.attributes['value'];
      }

      var bytes = utf8.encode(password);
      String md5Key = md5.convert(bytes).toString();
      String cypKey = md5Key.substring(0, 4) + loginKey.substring(0, 4);
      var blockCipher = new BlockCipher(new DESEngine(), cypKey);
      var encryptPwd = blockCipher.encodeB64(password);
      var password1 = base64.encode(utf8.encode(password));

      String passwordMask = "**********************************";
      Map<String, String> data = {
        "reurl": "",
        "login_key": loginKey,
        "encrypt_pwd": encryptPwd,
        "username": account,
        "password": passwordMask.substring(0, password.length),
        "password1": password1,
      };

      parameter = ConnectorParameter(_postLoginISchoolUrl);
      parameter.data = data;

      await RequestsConnector.getDataByPost(parameter);

      parameter = ConnectorParameter(_iSchoolPlusLearnIndexUrl);

      result = await RequestsConnector.getDataByGet(parameter);

      if (result.contains("Guest")) {
        //代表登入失敗
        return ISchoolPlusConnectorStatus.LoginFail;
      }
      _isLogin = true;
      return ISchoolPlusConnectorStatus.LoginSuccess;
    } catch (e) {
      Log.e(e.toString());
      return ISchoolPlusConnectorStatus.LoginFail;
    }
  }

  static Future<List<CourseFileJson>> getCourseFile(String courseId) async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> courseFileNodes, nodes, itemNodes;
    try {
      List<CourseFileJson> courseFileList = List();
      _selectCourse(courseId);

      return courseFileList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static Future<void> _selectCourse(String courseId) async {
    ConnectorParameter parameter;
    Document tagNode;
    Element node;
    List<Element> nodes;
    String result;
    try {
      parameter = ConnectorParameter(_getCourseName);
      result = await RequestsConnector.getDataByGet(parameter);

      tagNode = parse(result);
      node = tagNode.getElementById("selcourse");
      nodes = node.getElementsByTagName("option");
      String courseValue;
      for (int i = 1; i < nodes.length; i++) {
        node = nodes[i];
        String name = node.text.split("_").last;
        if( name == courseId){
          courseValue = node.attributes["value"];
          break;
        }
      }
      Log.d( courseValue );
      String xml = "<manifest><ticket/><course_id>$courseValue</course_id><env/></manifest>";
      parameter = ConnectorParameter( "https://istudy.ntut.edu.tw/learn/goto_course.php" );
      parameter.data = xml;
      await Connector.getDataByPost(parameter);  //因為RequestsConnector無法傳送XML但是 DioConnector無法解析 Content-Type: text/html;;charset=UTF-8



      parameter = ConnectorParameter( "https://istudy.ntut.edu.tw/learn/path/launch.php" );
      result = await RequestsConnector.getDataByGet(parameter);
      Log.d( result );

    } catch (e) {
      throw e;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static void loginFalse() {
    _isLogin = false;
  }

  static Future<bool> checkLogin() async {
    Log.d("ISchoolPlus CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    try {
      parameter = ConnectorParameter(_iSchoolPlusLearnIndexUrl);
      String result = await RequestsConnector.getDataByGet(parameter);
      if (result.contains("Guest")) {
        //代表登入失敗
        return false;
      } else {
        Log.d("ISchoolPlus Is Readly Login");
        _isLogin = true;
        return true;
      }
    } catch (e) {
      //throw e;
      Log.e(e.toString());
      return false;
    }
  }
}
