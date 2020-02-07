import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseScoreJson.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'core/Connector.dart';
import 'core/ConnectorParameter.dart';

enum ScoreConnectorStatus {
  LoginSuccess,
  LoginFail,
  ConnectTimeOutError,
  NetworkError,
  UnknownError
}

class ScoreConnector {
  static bool _isLogin = true;

  static final String _getLoginScoreUrl =
      "https://nportal.ntut.edu.tw/ssoIndex.do";
  static final String _scoreUrl =
      "https://aps-course.ntut.edu.tw/StuQuery/StudentQuery.jsp";
  static final String _scoreRankUrl =
      "https://aps-course.ntut.edu.tw/StuQuery/QryRank.jsp";
  static final String _scoreAllScoreUrl =
      "https://aps-course.ntut.edu.tw//StuQuery/QryScore.jsp";

  static Future<ScoreConnectorStatus> login() async {
    String result;
    try {
      ConnectorParameter parameter;
      Document tagNode;
      List<Element> nodes;
      Map<String, String> data = {
        "apUrl": "https://aps-course.ntut.edu.tw/StuQuery/LoginSID.jsp",
        "apOu": "aa_003_LB",
        "sso": "big5",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };
      parameter = ConnectorParameter(_getLoginScoreUrl);
      parameter.data = data;
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      nodes = tagNode.getElementsByTagName("input");
      data = Map();
      for (Element node in nodes) {
        String name = node.attributes['name'];
        String value = node.attributes['value'];
        data[name] = value;
      }
      String jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"];
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;
      await Connector.getDataByPostResponse(parameter);
      _isLogin = true;
      return ScoreConnectorStatus.LoginSuccess;
    } catch (e) {
      Log.e(e.toString());
      return ScoreConnectorStatus.LoginFail;
    }
  }

  static Future<List<CourseScoreJson>> getScoreRankList() async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element tableNode, h3Node, scoreNode;
    List<Element> tableNodes, h3Nodes, scoreNodes;
    List<CourseScoreJson> courseScoreList = List();
    try {
      Map<String, String> data = {"format": "-2"};
      parameter = ConnectorParameter(_scoreAllScoreUrl);
      parameter.data = data;
      parameter.charsetName = "big5";
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      tableNodes = tagNode.getElementsByTagName("table");
      h3Nodes = tagNode
          .getElementsByTagName("h3")
          .reversed
          .toList()
          .getRange(0, tableNodes.length)
          .toList()
          .reversed
          .toList();

      for (int i = 0; i < tableNodes.length; i++) {
        tableNode = tableNodes[i];
        h3Node = h3Nodes[i];

        CourseScoreJson courseScore = CourseScoreJson();

        SemesterJson semester = SemesterJson();
        semester.year = h3Node.text.split(" ")[0];
        semester.semester = h3Node.text.split(" ")[3];
        courseScore.semester = semester;

        scoreNodes = tableNode.getElementsByTagName("tr");
        for (int j = 1; j < scoreNodes.length - 6; j++) {
          scoreNode = scoreNodes[j];
          ScoreJson score = ScoreJson();
          score.name = scoreNode.getElementsByTagName("th")[2].text;
          score.credit =  double.parse(scoreNode.getElementsByTagName("th")[5].text);
          score.score = double.parse(scoreNode.getElementsByTagName("th")[6].text);
          courseScore.courseScoreList.add(score);
        }

        courseScore.averageScore     = double.parse ( scoreNodes[ scoreNodes.length - 4].getElementsByTagName("td")[0].text ) ;
        courseScore.performanceScore = double.parse ( scoreNodes[ scoreNodes.length - 3].getElementsByTagName("td")[0].text ) ;
        courseScore.totalCredit      = double.parse ( scoreNodes[ scoreNodes.length - 2].getElementsByTagName("td")[0].text ) ;
        courseScore.takeCredit       = double.parse ( scoreNodes[ scoreNodes.length - 1].getElementsByTagName("td")[0].text ) ;

        Log.d(courseScore.toString());
        courseScoreList.add(courseScore);
      }

      return courseScoreList;
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  static bool get isLogin {
    return _isLogin;
  }

  static Future<bool> checkLogin() async {
    Log.d("Score CheckLogin");
    ConnectorParameter parameter;
    _isLogin = false;
    try {
      parameter = ConnectorParameter(_scoreUrl);
      Response response = await Connector.getDataByGetResponse(parameter);
      if (response.statusCode != 200) {
        return false;
      } else {
        if (response.toString().contains("中斷連線")) {
          return false;
        }
        Log.d("Score Is Readly Login");
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
