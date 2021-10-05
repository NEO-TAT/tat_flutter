//  北科課程助手

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/src/connector/ntut_connector.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course/course_score_json.dart';

import 'core/connector.dart';
import 'core/connector_parameter.dart';

enum ScoreConnectorStatus { LoginSuccess, LoginFail, UnknownError }

class ScoreConnector {
  static const host = "https://aps-course.ntut.edu.tw/";
  static const _ssoLoginUrl = "${NTUTConnector.host}ssoIndex.do";
  static const _scoreUrl = host + "StuQuery/StudentQuery.jsp";
  static const _scoreRankUrl = host + "StuQuery/QryRank.jsp";
  static const _scoreAllScoreUrl = host + "StuQuery/QryScore.jsp";
  static const _generalLessonAllScoreUrl = host + "StuQuery/QryLAECourse.jsp";

  static Future<ScoreConnectorStatus> login() async {
    try {
      ConnectorParameter parameter;

      final data = {
        "apUrl": "https://aps-course.ntut.edu.tw/StuQuery/LoginSID.jsp",
        "apOu": "aa_003_LB",
        "sso": "big5",
        "datetime1": DateTime.now().millisecondsSinceEpoch.toString()
      };

      parameter = ConnectorParameter(_ssoLoginUrl)..data = data;

      final result = await Connector.getDataByGet(parameter);
      final tagNode = parse(result);
      final nodes = tagNode.getElementsByTagName("input");

      data.clear();

      for (final node in nodes) {
        final name = node.attributes['name']!;
        final value = node.attributes['value']!;
        data[name] = value;
      }

      final jumpUrl =
          tagNode.getElementsByTagName("form")[0].attributes["action"]!;
      parameter = ConnectorParameter(jumpUrl);
      parameter.data = data;
      await Connector.getDataByPostResponse(parameter);

      return ScoreConnectorStatus.LoginSuccess;
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
      return ScoreConnectorStatus.LoginFail;
    }
  }

  static String strQ2B(String input) {
    final List<int> newString = [];

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

  static Future<List<SemesterCourseScoreJson>?> getScoreRankList() async {
    ConnectorParameter parameter;
    String result;
    Document tagNode;
    List<Element> rankNodes;
    final List<SemesterCourseScoreJson> courseScoreList = [];

    try {
      final data = {"format": "-2"};
      parameter = ConnectorParameter(_scoreAllScoreUrl)
        ..data = data
        ..charsetName = 'big5';

      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      final tableNodes = tagNode.getElementsByTagName("table");
      final h3Nodes = tagNode
          .getElementsByTagName("h3")
          .reversed
          .toList()
          .getRange(0, tableNodes.length)
          .toList()
          .reversed
          .toList();

      // get course info by semester
      for (int i = 0; i < tableNodes.length; i++) {
        final tableNode = tableNodes[i];
        final h3Node = h3Nodes[i];
        final courseScore = SemesterCourseScoreJson();
        final semester = SemesterJson();
        semester.year = h3Node.text.split(" ")[0];
        semester.semester = h3Node.text.split(" ")[3];
        courseScore.semester = semester;

        // get course name and score
        final scoreNodes = tableNode.getElementsByTagName("tr");
        int scoreEnd = scoreNodes.length - 5;

        for (int i = scoreNodes.length - 1; i >= 0; i--) {
          final text = strQ2B(scoreNodes[i].text).replaceAll("[\n| ]", "");
          if (text.contains("This Semester Score")) {
            scoreEnd = i;
            break;
          }
        }

        for (int j = 1; j < scoreEnd - 1; j++) {
          final scoreNode = scoreNodes[j];
          final score = CourseScoreInfoJson();

          score.courseId = scoreNode
              .getElementsByTagName("th")[0]
              .text
              .replaceAll(RegExp(r"[\s| ]"), "");

          score.nameZh = scoreNode
              .getElementsByTagName("th")[2]
              .text
              .replaceAll(RegExp(r"[\s| ]"), "");

          score.nameEn = scoreNode
              .getElementsByTagName("th")[3]
              .text
              .replaceAll(RegExp("\n"), "");

          score.courseCode = scoreNode
              .getElementsByTagName("th")[4]
              .text
              .replaceAll(RegExp("[\n| ]"), "");

          score.credit =
              double.parse(scoreNode.getElementsByTagName("th")[6].text);

          score.score = scoreNode
              .getElementsByTagName("th")[7]
              .text
              .replaceAll(RegExp(r"[\s| ]"), "");

          courseScore.courseScoreList!.add(score);
        }

        try {
          courseScore.averageScore = double.parse(
              scoreNodes[scoreNodes.length - 4]
                  .getElementsByTagName("td")[0]
                  .text);

          courseScore.performanceScore = double.parse(
              scoreNodes[scoreNodes.length - 3]
                  .getElementsByTagName("td")[0]
                  .text);

          courseScore.totalCredit = double.parse(
              scoreNodes[scoreNodes.length - 2]
                  .getElementsByTagName("td")[0]
                  .text);

          courseScore.takeCredit = double.parse(
              scoreNodes[scoreNodes.length - 1]
                  .getElementsByTagName("td")[0]
                  .text);
        } catch (e) {
          // FIXME implement error case.
          continue;
        } finally {
          courseScoreList.add(courseScore);
        }
      }

      parameter = ConnectorParameter(_scoreRankUrl)
        ..data = data
        ..charsetName = 'big5';

      result = await Connector.getDataByGet(parameter);
      tagNode = parse(result);
      rankNodes =
          tagNode.getElementsByTagName("tbody")[0].getElementsByTagName("tr");
      rankNodes =
          rankNodes.getRange(2, rankNodes.length).toList().reversed.toList();

      for (int i = 0; i < (rankNodes.length / 3).floor(); i++) {
        final semester = SemesterJson();
        final semesterString = rankNodes[i * 3 + 2]
            .getElementsByTagName("td")[0]
            .innerHtml
            .split("<br>")
            .first;

        semester.year = semesterString.split(" ")[0];
        semester.semester = semesterString.split(" ").reversed.toList()[0];

        // get semester grades ranking
        final rankNow = RankJson();
        RankItemJson rankItemCourse = RankItemJson();
        RankItemJson rankItemDepartment = RankItemJson();

        rankNow.course = rankItemCourse;
        rankNow.department = rankItemDepartment;

        rankItemCourse.rank = double.parse(
            rankNodes[i * 3 + 2].getElementsByTagName("td")[2].text);
        rankItemCourse.total = double.parse(
            rankNodes[i * 3 + 2].getElementsByTagName("td")[3].text);

        final percentage = rankNodes[i * 3 + 2]
            .getElementsByTagName("td")[4]
            .text
            .replaceAll(RegExp("[%|\n]"), "");

        try {
          rankItemCourse.percentage = double.parse(percentage);
        } catch (e) {
          rankItemCourse.percentage =
              double.parse(percentage.replaceAll("%", ""));
        }

        rankItemDepartment.rank =
            double.parse(rankNodes[i * 3].getElementsByTagName("td")[1].text);
        rankItemDepartment.total =
            double.parse(rankNodes[i * 3].getElementsByTagName("td")[2].text);
        rankItemDepartment.percentage = double.parse(rankNodes[i * 3]
            .getElementsByTagName("td")[3]
            .text
            .replaceAll(RegExp(r"[%|\s]"), ""));

        // get rankings over the years
        final rankHistory = RankJson();
        rankItemCourse = RankItemJson();
        rankItemDepartment = RankItemJson();

        rankHistory.course = rankItemCourse;
        rankHistory.department = rankItemDepartment;

        rankItemCourse.rank = double.parse(
            rankNodes[i * 3 + 2].getElementsByTagName("td")[5].text);
        rankItemCourse.total = double.parse(
            rankNodes[i * 3 + 2].getElementsByTagName("td")[6].text);
        rankItemCourse.percentage = double.parse(rankNodes[i * 3 + 2]
            .getElementsByTagName("td")[7]
            .text
            .replaceAll("%", ""));

        rankItemDepartment.rank =
            double.parse(rankNodes[i * 3].getElementsByTagName("td")[4].text);
        rankItemDepartment.total =
            double.parse(rankNodes[i * 3].getElementsByTagName("td")[5].text);
        rankItemDepartment.percentage = double.parse(rankNodes[i * 3]
            .getElementsByTagName("td")[6]
            .text
            .replaceAll("%", ""));

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

  static Future<List<String>?> getCoreGeneralLesson() async {
    final List<String> coreGeneralLessonList = [];

    try {
      final parameter = ConnectorParameter(_generalLessonAllScoreUrl)
        ..charsetName = 'big5';

      final result = await Connector.getDataByGet(parameter);
      final nodes = parse(result)
          .getElementsByTagName("tbody")
          .first
          .getElementsByTagName("tr");

      for (int i = 2; i < nodes.length; i++) {
        final node = nodes[i];
        if (node.innerHtml.contains("＊")) {
          String name;

          if (node
              .getElementsByTagName("td")[0]
              .attributes
              .containsKey("rowspan")) {
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
