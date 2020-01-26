import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/ConnectorParameter.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:sprintf/sprintf.dart';
import 'Connector.dart';
import 'NTUTConnector.dart';

enum ISchoolLoginStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class ISchoolConnector {
  static bool _isLogin = false;
  static final String _getLoginISchoolUrl =
      "https://nportal.ntut.edu.tw/ssoIndex.do";
  static final String _postLoginISchoolUrl =
      "https://ischool.ntut.edu.tw/learning/auth/login.php";
  static final String _iSchoolUrl = "https://ischool.ntut.edu.tw";
  static final String _iSchoolFileUrl =
      "https://ischool.ntut.edu.tw/learning/document/document.php";
  static final String _iSchoolCourseAnnouncementUrl =
      "https://ischool.ntut.edu.tw/learning/announcements/announcements.php";
  static final String _iSchoolNewAnnouncementUrl =
      "https://ischool.ntut.edu.tw/learning/messaging/messagebox.php";
  static final String _iSchoolAnnouncementDetailUrl =
      "https://ischool.ntut.edu.tw/learning/messaging/readmessage.php";
  static final String _iSchoolDownloadUrl =
      "https://ischool.ntut.edu.tw/learning/backends/download.php";

  static Future<ISchoolLoginStatus> login() async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "apUrl": "https://ischool.ntut.edu.tw/learning/auth/login.php",
        "apOu": "ischool" ,
        "sso" : "true" ,
        "datetime1" : DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_getLoginISchoolUrl);
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
      parameter.data  = data;
      Response response = await Connector.getDataByPostResponse( parameter );
      //String res = await Connector.getDataByGet( _iSchoolUrl);
      //Log.d(res);
      _isLogin = true;
      return ISchoolLoginStatus.LoginSuccess;
    } on Exception catch (e) {
      Log.e(e.toString());
      return ISchoolLoginStatus.LoginFail;
    }
  }

  static Future<bool> getISchoolNewAnnouncement() async {
    ConnectorParameter parameter;
    int i, j;
    String result;
    String title;
    String postTime;
    String sender;
    String messageId;
    String uid;
    Document tagNode;
    List<Element> nodes, nodesItem;
    try {
      Map<String, String> data = {
        "box": "inbox",
      };
      parameter = ConnectorParameter( _iSchoolNewAnnouncementUrl );
      parameter.data = data;
      result = await Connector.getDataByGet( parameter );
      tagNode = parse(result);

      nodes = tagNode.getElementsByTagName("tbody"); // 取得兩個取第二個
      nodes = nodes[1].getElementsByTagName("tr");
      for (i = 0; i < nodes.length; i++) {
        nodesItem = nodes[i].getElementsByTagName("td");
        for (j = 0; j < nodesItem.length; j++) {
          switch (j) {
            case 0:
              String href =
                  nodesItem[j].getElementsByTagName("a")[1].attributes["href"];
              uid = nodesItem[j]
                  .getElementsByClassName("im_context")[0]
                  .innerHtml;
              uid = uid.replaceAll(" ", "");
              uid = uid.replaceAll("[", "");
              uid = uid.split("-")[0];
              href = href.replaceAll("amp;", ""); //修正&後出現amp;問題
              messageId = Uri.parse(href).queryParameters["messageId"];
              title = nodesItem[j].getElementsByTagName("a")[1].innerHtml;
              break;
            case 1:
              sender = nodesItem[j].getElementsByTagName("a")[0].innerHtml;
              break;
            case 2:
              postTime = nodesItem[j].innerHtml;
              break;
          }
        }
        Log.d(sprintf("  title:%s \n  postTime:%s \n  sender:%s \n  messageId:%s \n  uid:%s \n \n",
            [title, postTime, sender, messageId, uid]));
      }
      return true;
    } on Exception catch (e) {
      Log.e(e.toString());
      return false;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static Future<bool> checkLogin() async {
    Log.d("ISchool CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    try {
      parameter = ConnectorParameter(_iSchoolUrl);
      Response response = await Connector.getDataByGetResponse( parameter );
      if ( response.statusCode != 200 ) {
        return false;
      } else {
        Log.d("ISchool Is Readly Login");
        _isLogin = true;
        return true;
      }
    } on Exception catch (e) {
      throw e;
    }
  }
}
