import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:sprintf/sprintf.dart';

class CourseScoreJson {
  SemesterJson semester;
  RankJson now;
  RankJson history;
  List<ScoreJson> courseScoreList;
  double averageScore; //總平均
  double performanceScore; //操行成績
  double totalCredit; //修習總學分數
  double takeCredit; //實得學分數

  CourseScoreJson(
      {this.semester,
      this.now,
      this.averageScore,
      this.courseScoreList,
      this.history,
      this.performanceScore,
      this.takeCredit,
      this.totalCredit}) {
    now = now ?? RankJson();
    history = history ?? RankJson();
    courseScoreList = courseScoreList ?? List();
    semester = semester ?? SemesterJson();
    averageScore = averageScore ?? 0;
    performanceScore = performanceScore ?? 0;
    totalCredit = totalCredit ?? 0;
    takeCredit = takeCredit ?? 0;
  }

  String getTotalCreditString() {
    double total;
    for (ScoreJson score in courseScoreList) {
      total += score.credit;
    }
    return totalCredit ?? total.toString();
  }

  @override
  String toString() {
    return sprintf(
        "---------semester--------     \n%s \n" +
            "---------now--------          \n%s \n" +
            "---------history--------      \n%s \n" +
            "---------courseScore--------  \n%s \n" +
            "averageScore     :%s \n" +
            "performanceScore :%s \n" +
            "totalCredit      :%s \n" +
            "takeCredit       :%s \n",
        [
          semester.toString(),
          now.toString(),
          history.toString(),
          courseScoreList.toString(),
          averageScore.toString(),
          performanceScore.toString(),
          totalCredit.toString(),
          takeCredit.toString()
        ]);
  }
}

class RankJson {
  RankItemJson course;
  RankItemJson department;

  RankJson({this.course, this.department}) {
    course = course ?? RankItemJson();
    department = department ?? RankItemJson();
  }

  @override
  String toString() {
    return sprintf(
        "---------course--------     \n%s \n" +
            "---------department--------          \n%s \n",
        [course.toString(), department.toString()]);
  }
}

class RankItemJson {
  double rank;
  double total;
  double percentage;

  RankItemJson({this.percentage, this.rank, this.total}) {
    percentage = percentage ?? 0;
    rank = rank ?? 0;
    total = total ?? 0;
  }

  @override
  String toString() {
    return sprintf(
        "percentage     :%s \n" +
            "rank           :%s \n" +
            "total          :%s \n",
        [
          percentage.toString(),
          rank.toString(),
          total.toString(),
        ]);
  }
}

class ScoreJson {
  String name;
  double score;
  double credit; //學分

  ScoreJson({this.name, this.score, this.credit}) {
    name = JsonInit.stringInit(name);
    score = score ?? 0;
    credit = credit ?? 0;
  }

  @override
  String toString() {
    return sprintf(
        "name           :%s \n" +
            "score           :%s \n" +
            "credit          :%s \n",
        [
          name.toString(),
          score.toString(),
          credit.toString(),
        ]);
  }
}
