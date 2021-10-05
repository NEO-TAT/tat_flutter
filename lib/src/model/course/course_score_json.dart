import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/util/language_utils.dart';

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
  GraduationInformationJson? graduationInformation =
      GraduationInformationJson();
  List<SemesterCourseScoreJson>? semesterCourseScoreList = [];

  CourseScoreCreditJson({
    this.graduationInformation,
    this.semesterCourseScoreList,
  });

  // get course info by semester
  SemesterCourseScoreJson? getCourseBySemester(SemesterJson semesterJson) {
    for (final i in semesterCourseScoreList!) {
      if (i.semester == semesterJson) {
        return i;
      }
    }
    return null;
  }

  // get all courses' info
  List<CourseScoreInfoJson> getCourseInfoList() {
    final List<CourseScoreInfoJson> courseInfoList = [];
    for (final i in semesterCourseScoreList!) {
      courseInfoList.addAll(i.courseScoreList!);
    }
    return courseInfoList;
  }

  // get course info by its id
  CourseScoreInfoJson? getCourseByCourseId(String courseId) {
    for (final i in semesterCourseScoreList!) {
      for (final j in i.courseScoreList!) {
        if (courseId == j.courseId) {
          return j;
        }
      }
    }
    return null;
  }

  // get all courses' id
  List<String> getCourseIdList() {
    final List<String> courseIdList = [];
    for (final i in semesterCourseScoreList!) {
      for (final j in i.courseScoreList!) {
        courseIdList.add(j.courseId);
      }
    }
    return courseIdList;
  }

  // get all semesters
  List<SemesterJson> getSemesterList() {
    final List<SemesterJson> value = [];
    for (final i in semesterCourseScoreList!) {
      value.add(i.semester!);
    }
    return value;
  }

  int getCreditByType(String type) {
    int credit = 0;
    final result = getCourseByType(type);
    for (final key in result.keys.toList()) {
      for (final j in result[key]!) {
        credit += j.credit.toInt();
      }
    }
    return credit;
  }

  Map<String, List<CourseScoreInfoJson>> getCourseByType(String type) {
    final Map<String, List<CourseScoreInfoJson>> result = Map();
    for (final i in semesterCourseScoreList!) {
      final semester =
          sprintf("%s-%s", [i.semester!.year, i.semester!.semester]);
      result[semester] = [];
      for (final j in i.courseScoreList!) {
        if (j.category.contains(type) && j.isPass) {
          result[semester]!.add(j);
        }
      }
    }
    return result;
  }

  String getSemesterString(SemesterJson semester) {
    return sprintf("%s-%s", [semester.year, semester.semester]);
  }

  Map<String, List<CourseScoreInfoJson>> getGeneralLesson() {
    final Map<String, List<CourseScoreInfoJson>> result = Map();
    for (final i in semesterCourseScoreList!) {
      final semester = getSemesterString(i.semester!);
      result[semester] = [];
      for (final j in i.courseScoreList!) {
        if (j.isGeneralLesson && j.isPass) {
          result[semester]!.add(j);
        }
      }
    }
    return result;
  }

  // calculate credits received from foreign Department
  Map<String, List<CourseScoreInfoJson>> getOtherDepartmentCourse(
    String divisionCode,
  ) {
    final Map<String, List<CourseScoreInfoJson>> result = Map();
    for (final i in semesterCourseScoreList!) {
      final semester = getSemesterString(i.semester!);
      result[semester] = [];
      for (final j in i.courseScoreList!) {
        if (j.isOtherDepartment(divisionCode) && j.isPass) {
          result[semester]!.add(j);
        }
      }
    }
    return result;
  }

  int getTotalCourseCredit() {
    int credit = 0;
    for (final i in semesterCourseScoreList!) {
      for (final j in i.courseScoreList!) {
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
  late final String? selectYear;
  final String selectMatric;
  late final String? selectDivision;
  late final int lowCredit; // the lowest credit limit to graduate
  late final int outerDepartmentMaxCredit; // max recognized credits
  late final Map<String, int>? courseTypeMinCredit;
  List<String>? courseCodeList = [];

  GraduationInformationJson({
    this.lowCredit = 0,
    this.courseTypeMinCredit,
    this.outerDepartmentMaxCredit = 0,
    this.selectYear,
    this.selectDivision,
    this.selectMatric = '7',
    this.courseCodeList,
  }) {
    final String? studentId = Model.instance.getAccount();

    selectYear ??= ((studentId != null && (studentId.length) > 3)
        ? studentId.substring(0, 3)
        : "");

    selectDivision ??= ((studentId != null && studentId.length > 3)
        ? studentId.substring(3, 6)
        : "");

    if (courseTypeMinCredit == null) {
      final courseTypeMinCredit = Map();
      for (final type in constCourseType) {
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
        courseTypeMinCredit.toString(),
      ],
    );
  }
}

@JsonSerializable()
class SemesterCourseScoreJson {
  SemesterJson? semester = SemesterJson();
  RankJson? now = RankJson();
  RankJson? history = RankJson();
  List<CourseScoreInfoJson>? courseScoreList = [];
  double averageScore;
  double performanceScore; // 操行成績
  double totalCredit;
  double takeCredit; // 實得學分數

  SemesterCourseScoreJson({
    this.semester,
    this.now,
    this.averageScore = 0,
    this.courseScoreList,
    this.history,
    this.performanceScore = 0,
    this.takeCredit = 0,
    this.totalCredit = 0,
  });

  bool get isRankEmpty => history!.isEmpty && now!.isEmpty;

  String getAverageScoreString() {
    double average = 0, total = 0;

    for (final score in courseScoreList!) {
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

  String getPerformanceScoreString() => performanceScore.toString();

  String getTakeCreditString() => takeCredit.toString();

  String getTotalCreditString() {
    double total = 0;

    for (final score in courseScoreList!) {
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
        takeCredit.toString(),
      ],
    );
  }

  factory SemesterCourseScoreJson.fromJson(Map<String, dynamic> json) =>
      _$SemesterCourseScoreJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterCourseScoreJsonToJson(this);
}

@JsonSerializable()
class RankJson {
  RankItemJson? course = RankItemJson();
  RankItemJson? department = RankItemJson();

  RankJson({this.course, this.department});

  bool get isEmpty => course!.isEmpty && department!.isEmpty;

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
  late final double rank;
  late final double total;
  late final double percentage;

  RankItemJson({
    this.percentage = 0,
    this.rank = 0,
    this.total = 0,
  });

  bool get isEmpty => rank == 0 && total == 0 && percentage == 0;

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
      ],
    );
  }

  factory RankItemJson.fromJson(Map<String, dynamic> json) =>
      _$RankItemJsonFromJson(json);

  Map<String, dynamic> toJson() => _$RankItemJsonToJson(this);
}

@JsonSerializable()
class CourseScoreInfoJson {
  late final String courseId;
  late final String courseCode; // 用來判斷是否是外系
  late final String nameZh;
  late final String nameEn;
  late final String score;
  late final double credit;
  final String openClass;
  final String category;

  String get name =>
      (LanguageUtils.getLangIndex() == LangEnum.en) ? nameEn : nameZh;

  CourseScoreInfoJson({
    this.courseId = "",
    this.courseCode = "",
    this.nameZh = "",
    this.nameEn = "",
    this.score = "",
    this.credit = 0,
    this.category = "",
    this.openClass = "",
  });

  bool get isPass {
    try {
      final s = int.parse(score);
      return s >= 60;
    } catch (e) {
      return false;
    }
  }

  bool isOtherDepartment(String divisionCode) {
    final courseCodeList =
        Model.instance.getGraduationInformation().courseCodeList;
    if (category.contains("△")) {
      return false;
    } else if (courseCode.substring(0, 3) == divisionCode) {
      return false;
    } else if (courseCodeList!.contains(courseCode)) {
      return false;
    } else {
      return true;
    }
  }

  bool get isGeneralLesson =>
      openClass.contains("博雅") || openClass.contains("職通識課程");

  bool get isCoreGeneralLesson => openClass.contains("核心");

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
      ],
    );
  }

  factory CourseScoreInfoJson.fromJson(Map<String, dynamic> json) =>
      _$CourseScoreInfoJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseScoreInfoJsonToJson(this);
}
