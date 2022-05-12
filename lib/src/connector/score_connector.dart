import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'core/connector.dart';
import 'core/connector_parameter.dart';

enum ScoreConnectorStatus { loginSuccess, loginFail, unknownError }

class ScoreConnector {
  static const String _scoreHost = "https://aps-course.ntut.edu.tw/";
  static const _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static const String _scoreRankUrl = "${_scoreHost}StuQuery/QryRank.jsp";
  static const String _scoreAllScoreUrl = "${_scoreHost}StuQuery/QryScore.jsp";
  static const String _generalLessonAllScoreUrl = "${_scoreHost}StuQuery/QryLAECourse.jsp";

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
      return ScoreConnectorStatus.loginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return ScoreConnectorStatus.loginFail;
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

  static Future<List<SemesterCourseScoreJson>> getScoreRankList() async {
    //取得排名與成績
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element tableNode, h3Node, scoreNode;
    List<Element> tableNodes, h3Nodes, scoreNodes, rankNodes;
    List<SemesterCourseScoreJson> courseScoreList = [];
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
      //依照學期取得課程資料
      for (int i = 0; i < tableNodes.length; i++) {
        tableNode = tableNodes[i];
        h3Node = h3Nodes[i];

        SemesterCourseScoreJson courseScore = SemesterCourseScoreJson();

        SemesterJson semester = SemesterJson();
        semester.year = h3Node.text.split(" ")[0];
        semester.semester = h3Node.text.split(" ")[3];
        courseScore.semester = semester;
        //取得課程名稱與分數
        scoreNodes = tableNode.getElementsByTagName("tr");
        int scoreEnd = scoreNodes.length - 5;
        for (int i = scoreNodes.length - 1; i >= 0; i--) {
          String text = strQ2B(scoreNodes[i].text).replaceAll("[\n| ]", "");
          if (text.contains("This Semester Score")) {
            scoreEnd = i;
            break;
          }
        }
        for (int j = 1; j < scoreEnd - 1; j++) {
          scoreNode = scoreNodes[j];
          CourseScoreInfoJson score = CourseScoreInfoJson();
          score.courseId = scoreNode.getElementsByTagName("th")[0].text.replaceAll(RegExp(r"[\s| ]"), "");
          score.nameZh = scoreNode.getElementsByTagName("th")[2].text.replaceAll(RegExp(r"[\s| ]"), "");
          score.nameEn = scoreNode.getElementsByTagName("th")[3].text.replaceAll(RegExp("\n"), "");
          score.credit = double.parse(scoreNode.getElementsByTagName("th")[6].text);
          score.score = scoreNode.getElementsByTagName("th")[7].text.replaceAll(RegExp(r"[\s| ]"), "");
          courseScore.courseScoreList.add(score);
        }
        try {
          courseScore.averageScore = double.parse(scoreNodes[scoreNodes.length - 4].getElementsByTagName("td")[0].text);
          courseScore.performanceScore =
              double.parse(scoreNodes[scoreNodes.length - 3].getElementsByTagName("td")[0].text);
          courseScore.totalCredit = double.parse(scoreNodes[scoreNodes.length - 2].getElementsByTagName("td")[0].text);
          courseScore.takeCredit = double.parse(scoreNodes[scoreNodes.length - 1].getElementsByTagName("td")[0].text);
        } catch (e) {
          continue;
        } finally {
          courseScoreList.add(courseScore);
        }
      }

      parameter = ConnectorParameter(_scoreRankUrl);
      parameter.data = data;
      parameter.charsetName = "big5";
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      rankNodes = tagNode.getElementsByTagName("tbody")[0].getElementsByTagName("tr");
      rankNodes = rankNodes.getRange(2, rankNodes.length).toList().reversed.toList();
      for (int i = 0; i < (rankNodes.length / 3).floor(); i++) {
        SemesterJson semester = SemesterJson();
        String semesterString = rankNodes[i * 3 + 2].getElementsByTagName("td")[0].innerHtml.split("<br>").first;
        semester.year = semesterString.split(" ")[0];
        semester.semester = semesterString.split(" ").reversed.toList()[0];

        //取得學期成績排名
        RankJson rankNow = RankJson();
        RankItemJson rankItemCourse = RankItemJson();
        RankItemJson rankItemDepartment = RankItemJson();
        rankNow.course = rankItemCourse;
        rankNow.department = rankItemDepartment;
        rankItemCourse.rank = double.parse(rankNodes[i * 3 + 2].getElementsByTagName("td")[2].text);
        rankItemCourse.total = double.parse(rankNodes[i * 3 + 2].getElementsByTagName("td")[3].text);
        rankItemCourse.percentage =
            double.parse(rankNodes[i * 3 + 2].getElementsByTagName("td")[4].text.replaceAll(RegExp(r"[%|\s]"), ""));
        rankItemDepartment.rank = double.parse(rankNodes[i * 3].getElementsByTagName("td")[1].text);
        rankItemDepartment.total = double.parse(rankNodes[i * 3].getElementsByTagName("td")[2].text);
        rankItemDepartment.percentage =
            double.parse(rankNodes[i * 3].getElementsByTagName("td")[3].text.replaceAll(RegExp(r"[%|\s]"), ""));

        //取得歷年成績排名
        RankJson rankHistory = RankJson();
        rankItemCourse = RankItemJson();
        rankItemDepartment = RankItemJson();
        rankHistory.course = rankItemCourse;
        rankHistory.department = rankItemDepartment;
        rankItemCourse.rank = double.parse(rankNodes[i * 3 + 2].getElementsByTagName("td")[5].text);
        rankItemCourse.total = double.parse(rankNodes[i * 3 + 2].getElementsByTagName("td")[6].text);
        rankItemCourse.percentage =
            double.parse(rankNodes[i * 3 + 2].getElementsByTagName("td")[7].text.replaceAll("%", ""));
        rankItemDepartment.rank = double.parse(rankNodes[i * 3].getElementsByTagName("td")[4].text);
        rankItemDepartment.total = double.parse(rankNodes[i * 3].getElementsByTagName("td")[5].text);
        rankItemDepartment.percentage =
            double.parse(rankNodes[i * 3].getElementsByTagName("td")[6].text.replaceAll("%", ""));

        for (SemesterCourseScoreJson score in courseScoreList) {
          if (score.semester == semester) {
            score.now = rankNow;
            score.history = rankHistory;
            break;
          }
        }
      }
      return courseScoreList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }

  static Future<List<String>> getCoreGeneralLesson() async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    Element node;
    List<Element> nodes;
    List<String> coreGeneralLessonList = [];
    try {
      parameter = ConnectorParameter(_generalLessonAllScoreUrl);
      parameter.charsetName = "big5";
      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      node = tagNode.getElementsByTagName("tbody").first;
      nodes = node.getElementsByTagName("tr");
      for (int i = 2; i < nodes.length; i++) {
        node = nodes[i];
        if (node.innerHtml.contains("＊")) {
          String name;
          if (node.getElementsByTagName("td")[0].attributes.containsKey("rowspan")) {
            name = node.getElementsByTagName("td")[7].text;
          } else {
            name = node.getElementsByTagName("td")[3].text;
          }
          name = name.replaceAll(RegExp(r"[\s|\n| ]"), "");
          coreGeneralLessonList.add(name);
        }
      }
      return coreGeneralLessonList;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return null;
    }
  }
}
