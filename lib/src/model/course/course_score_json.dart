import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/json_init.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/src/util/language_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'course_score_json.g.dart';

const List<String> constCourseType = [
  "○", //	  必	部訂共同必修
  "△", //	必	校訂共同必修
  "☆", //	選	共同選修
  "●", //	  必	部訂專業必修
  "▲", //	  必	校訂專業必修
  "★" //	  選	專業選修
];

@JsonSerializable()
class CourseScoreCreditJson {
  GraduationInformationJson graduationInformation;
  List<SemesterCourseScoreJson> semesterCourseScoreList;

  CourseScoreCreditJson(
      {this.graduationInformation, this.semesterCourseScoreList}) {
    graduationInformation =
        graduationInformation ?? GraduationInformationJson();
    semesterCourseScoreList = semesterCourseScoreList ?? [];
  }

  //利用學期取得課程資訊
  SemesterCourseScoreJson getCourseBySemester(SemesterJson semesterJson) {
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      if (i.semester == semesterJson) {
        return i;
      }
    }
    return null;
  }

  //取得所有課程資訊
  List<CourseScoreInfoJson> getCourseInfoList() {
    List<CourseScoreInfoJson> courseInfoList = [];
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      courseInfoList.addAll(i.courseScoreList);
    }
    return courseInfoList;
  }

  //利用課程id取得課程資訊
  CourseScoreInfoJson getCourseByCourseId(String courseId) {
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      for (CourseScoreInfoJson j in i.courseScoreList) {
        if (courseId == j.courseId) {
          return j;
        }
      }
    }
    return null;
  }

  //取得所有課程id
  List<String> getCourseIdList() {
    List<String> courseIdList = [];
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      for (CourseScoreInfoJson j in i.courseScoreList) {
        courseIdList.add(j.courseId);
      }
    }
    return courseIdList;
  }

  //取得所有學期
  List<SemesterJson> getSemesterList() {
    List<SemesterJson> value;
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      value.add(i.semester);
    }
    return value;
  }

  int getCreditByType(String type) {
    int credit = 0;
    Map<String, List<CourseScoreInfoJson>> result = getCourseByType(type);
    for (String key in result.keys.toList()) {
      for (CourseScoreInfoJson j in result[key]) {
        credit += j.credit.toInt();
      }
    }
    return credit;
  }

  /*
  key
  Map<Semester , List<CourseInfoJson> >
  */
  Map<String, List<CourseScoreInfoJson>> getCourseByType(String type) {
    Map<String, List<CourseScoreInfoJson>> result = Map();
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      String semester =
          sprintf("%s-%s", [i.semester.year, i.semester.semester]);
      result[semester] = [];
      for (CourseScoreInfoJson j in i.courseScoreList) {
        if (j.category.contains(type) && j.isPass) {
          result[semester].add(j);
        }
      }
    }
    return result;
  }

  String getSemesterString(SemesterJson semester) {
    return sprintf("%s-%s", [semester.year, semester.semester]);
  }

  /*
  key
  Map<Semester , List<CourseInfoJson> >
  */
  Map<String, List<CourseScoreInfoJson>> getGeneralLesson() {
    Map<String, List<CourseScoreInfoJson>> result = Map();
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      String semester = getSemesterString(i.semester);
      result[semester] = [];
      for (CourseScoreInfoJson j in i.courseScoreList) {
        if (j.isGeneralLesson && j.isPass) {
          result[semester].add(j);
        }
      }
    }
    return result;
  }

  /*
  計算外系學分
  */
  Map<String, List<CourseScoreInfoJson>> getOtherDepartmentCourse(
      String divisionCode) {
    Map<String, List<CourseScoreInfoJson>> result = Map();
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      String semester = getSemesterString(i.semester);
      result[semester] = [];
      for (CourseScoreInfoJson j in i.courseScoreList) {
        if (j.isOtherDepartment(divisionCode) && j.isPass) {
          result[semester].add(j);
        }
      }
    }
    return result;
  }

  int getTotalCourseCredit() {
    int credit = 0;
    for (SemesterCourseScoreJson i in semesterCourseScoreList) {
      for (CourseScoreInfoJson j in i.courseScoreList) {
        if (j.isPass) {
          credit += j.credit.toInt();
        }
      }
    }
    return credit;
  }

  factory CourseScoreCreditJson.fromJson(Map<String, dynamic> json) =>
      _$CourseScoreCreditJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseScoreCreditJsonToJson(this);
}

@JsonSerializable()
class GraduationInformationJson {
  String selectYear;
  String selectMatric; //四技...
  String selectDivision; //系所
  int lowCredit; //最低畢業門檻
  int outerDepartmentMaxCredit; //外系最多承認學分
  Map<String, int> courseTypeMinCredit;
  List<String> courseCodeList;

  GraduationInformationJson(
      {this.lowCredit,
      this.courseTypeMinCredit,
      this.outerDepartmentMaxCredit,
      this.selectYear,
      this.selectDivision,
      this.selectMatric,
      this.courseCodeList}) {
    String studentId = Model.dioInstance.getAccount();
    selectYear = selectYear ??
        ((studentId != null && (studentId.length) > 3)
            ? studentId.substring(0, 3)
            : "");
    selectMatric = selectMatric ?? '7';
    selectDivision = selectDivision ??
        ((studentId != null && studentId.length > 3)
            ? studentId.substring(3, 6)
            : "");
    lowCredit = lowCredit ?? 0;
    outerDepartmentMaxCredit = outerDepartmentMaxCredit ?? 0;
    courseCodeList = courseCodeList ?? [];
    if (courseTypeMinCredit == null) {
      courseTypeMinCredit = Map();
      for (String type in constCourseType) {
        courseTypeMinCredit[type] = 0;
      }
    }
  }

  bool get isSelect {
    return !(lowCredit == 0);
  }

  factory GraduationInformationJson.fromJson(Map<String, dynamic> json) =>
      _$GraduationInformationJsonFromJson(json);

  Map<String, dynamic> toJson() => _$GraduationInformationJsonToJson(this);

  @override
  String toString() {
    return sprintf(
        "---------selectYear--------     \n%s \n" +
            "---------selectDivision--------          \n%s \n" +
            "---------selectMatric--------      \n%s \n" +
            "---------lowCredit--------  \n%s \n" +
            "---------outerDepartmentMacCredit--------     :%s \n" +
            "courseTypeMinCredit :%s \n",
        [
          selectYear,
          selectDivision,
          selectMatric,
          lowCredit.toString(),
          outerDepartmentMaxCredit.toString(),
          courseTypeMinCredit.toString()
        ]);
  }
}

@JsonSerializable()
class SemesterCourseScoreJson {
  SemesterJson semester;
  RankJson now;
  RankJson history;
  List<CourseScoreInfoJson> courseScoreList;
  double averageScore; //總平均
  double performanceScore; //操行成績
  double totalCredit; //修習總學分數
  double takeCredit; //實得學分數

  SemesterCourseScoreJson(
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
    courseScoreList = courseScoreList ?? [];
    semester = semester ?? SemesterJson();
    averageScore = averageScore ?? 0;
    performanceScore = performanceScore ?? 0;
    totalCredit = totalCredit ?? 0;
    takeCredit = takeCredit ?? 0;
  }

  bool get isRankEmpty {
    return history.isEmpty && now.isEmpty;
  }

  String getAverageScoreString() {
    double average = 0;
    double total = 0;
    for (CourseScoreInfoJson score in courseScoreList) {
      try {
        average += double.parse(score.score) * score.credit;
        total += score.credit;
      } catch (e) {
        continue;
      }
    }
    average /= total;
    return (averageScore != 0)
        ? averageScore.toString()
        : average.toStringAsFixed(2);
  }

  String getPerformanceScoreString() {
    return performanceScore.toString();
  }

  String getTakeCreditString() {
    return takeCredit.toString();
  }

  String getTotalCreditString() {
    double total = 0;
    for (CourseScoreInfoJson score in courseScoreList) {
      total += score.credit;
    }
    return (totalCredit != 0) ? totalCredit.toString() : total.toString();
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

  factory SemesterCourseScoreJson.fromJson(Map<String, dynamic> json) =>
      _$SemesterCourseScoreJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterCourseScoreJsonToJson(this);
}

@JsonSerializable()
class RankJson {
  RankItemJson course;
  RankItemJson department;

  RankJson({this.course, this.department}) {
    course = course ?? RankItemJson();
    department = department ?? RankItemJson();
  }

  bool get isEmpty {
    return course.isEmpty && department.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "---------course--------     \n%s \n" +
            "---------department--------          \n%s \n",
        [course.toString(), department.toString()]);
  }

  factory RankJson.fromJson(Map<String, dynamic> json) =>
      _$RankJsonFromJson(json);

  Map<String, dynamic> toJson() => _$RankJsonToJson(this);
}

@JsonSerializable()
class RankItemJson {
  double rank;
  double total;
  double percentage;

  RankItemJson({this.percentage, this.rank, this.total}) {
    percentage = percentage ?? 0;
    rank = rank ?? 0;
    total = total ?? 0;
  }

  bool get isEmpty {
    return rank == 0 && total == 0 && percentage == 0;
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

  factory RankItemJson.fromJson(Map<String, dynamic> json) =>
      _$RankItemJsonFromJson(json);

  Map<String, dynamic> toJson() => _$RankItemJsonToJson(this);
}

@JsonSerializable()
class CourseScoreInfoJson {
  String courseId;
  String courseCode; //用來判斷是否是外系
  String nameZh;
  String nameEn;
  String score;
  double credit; //學分
  String openClass;
  String category;

  String get name {
    return (LanguageUtils.getLangIndex() == LangEnum.en) ? nameEn : nameZh;
  }

  CourseScoreInfoJson(
      {this.courseId,
      this.courseCode,
      this.nameZh,
      this.nameEn,
      this.score,
      this.credit,
      this.category,
      this.openClass}) {
    courseId = JsonInit.stringInit(courseId);
    courseCode = JsonInit.stringInit(courseCode);
    nameZh = JsonInit.stringInit(nameZh);
    nameEn = JsonInit.stringInit(nameEn);
    score = JsonInit.stringInit(score);
    category = JsonInit.stringInit(category);
    openClass = JsonInit.stringInit(openClass);
    credit = credit ?? 0;
  }

  bool get isPass {
    //是否拿到學分
    try {
      int s = int.parse(score);
      return (s >= 60) ? true : false;
    } catch (e) {
      return false;
    }
  }

  bool isOtherDepartment(String divisionCode) {
    //是否是跨系選修
    var courseCodeList =
        Model.dioInstance.getGraduationInformation().courseCodeList;
    if (category.contains("△")) {
      return false;
    } else if (courseCode.substring(0, 3) == divisionCode) {
      return false;
    } else if (courseCodeList.contains(courseCode)) {
      return false;
    } else {
      return true;
    }
  }

  bool get isGeneralLesson {
    //是否是博雅課程
    return openClass.contains("博雅") || openClass.contains("職通識課程");
  }

  bool get isCoreGeneralLesson {
    //是否是博雅核心課程
    return openClass.contains("核心");
  }

  @override
  String toString() {
    return sprintf(
        "name           :%s \n" +
            "score           :%s \n" +
            "credit          :%s \n",
        [
          nameZh.toString(),
          score.toString(),
          credit.toString(),
        ]);
  }

  factory CourseScoreInfoJson.fromJson(Map<String, dynamic> json) =>
      _$CourseScoreInfoJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseScoreInfoJsonToJson(this);
}
