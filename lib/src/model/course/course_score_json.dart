// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/model/course/course_semester.dart';
import 'package:flutter_app/src/model/json_init.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'course_score_json.g.dart';

const constCourseType = [
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

  CourseScoreCreditJson({this.graduationInformation, this.semesterCourseScoreList}) {
    graduationInformation = graduationInformation ?? GraduationInformationJson();
    semesterCourseScoreList = semesterCourseScoreList ?? [];
  }

  //利用學期取得課程資訊
  SemesterCourseScoreJson getCourseBySemester(SemesterJson semesterJson) {
    for (final i in semesterCourseScoreList) {
      if (i.semester == semesterJson) {
        return i;
      }
    }
    return null;
  }

  //取得所有課程資訊
  List<CourseScoreInfoJson> getCourseInfoList() {
    final courseInfoList = <CourseScoreInfoJson>[];

    for (final i in semesterCourseScoreList) {
      courseInfoList.addAll(i.courseScoreList);
    }

    return courseInfoList;
  }

  //利用課程id取得課程資訊
  CourseScoreInfoJson getCourseByCourseId(String courseId) {
    for (final i in semesterCourseScoreList) {
      for (final j in i.courseScoreList) {
        if (courseId == j.courseId) {
          return j;
        }
      }
    }
    return null;
  }

  //取得所有課程id
  List<String> getCourseIdList() {
    final courseIdList = <String>[];

    for (final i in semesterCourseScoreList) {
      for (final j in i.courseScoreList) {
        courseIdList.add(j.courseId);
      }
    }

    return courseIdList;
  }

  //取得所有學期
  List<SemesterJson> getSemesterList() {
    final value = <SemesterJson>[];

    for (final i in semesterCourseScoreList) {
      value.add(i.semester);
    }

    return value;
  }

  int getCreditByType(String type) {
    int credit = 0;

    final result = getCourseByType(type);

    for (final key in result.keys.toList()) {
      for (final j in result[key]) {
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
    final result = <String, List<CourseScoreInfoJson>>{};

    for (final i in semesterCourseScoreList) {
      final semester = sprintf("%s-%s", [i.semester.year, i.semester.semester]);
      result[semester] = [];
      for (final j in i.courseScoreList) {
        if (j.category.contains(type) && j.isPass) {
          result[semester].add(j);
        }
      }
    }
    return result;
  }

  String getSemesterString(SemesterJson semester) => sprintf("%s-%s", [semester.year, semester.semester]);

  /*
  key
  Map<Semester , List<CourseInfoJson> >
  */
  Map<String, List<CourseScoreInfoJson>> getGeneralLesson() {
    final result = <String, List<CourseScoreInfoJson>>{};

    for (final i in semesterCourseScoreList) {
      final semester = getSemesterString(i.semester);
      result[semester] = [];
      for (final j in i.courseScoreList) {
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
  Map<String, List<CourseScoreInfoJson>> getOtherDepartmentCourse(String department) {
    final result = <String, List<CourseScoreInfoJson>>{};

    for (final i in semesterCourseScoreList) {
      final semester = getSemesterString(i.semester);
      result[semester] = [];
      for (final j in i.courseScoreList) {
        if (j.isOtherDepartment(department) && j.isPass) {
          result[semester].add(j);
        }
      }
    }
    return result;
  }

  int getTotalCourseCredit() {
    int credit = 0;

    for (final i in semesterCourseScoreList) {
      for (final j in i.courseScoreList) {
        if (j.isPass) {
          credit += j.credit.toInt();
        }
      }
    }
    return credit;
  }

  factory CourseScoreCreditJson.fromJson(Map<String, dynamic> json) => _$CourseScoreCreditJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseScoreCreditJsonToJson(this);
}

@JsonSerializable()
class GraduationInformationJson {
  String selectYear;
  String selectDivision;
  String selectDepartment;
  int lowCredit; //最低畢業門檻
  int outerDepartmentMaxCredit; //外系最多承認學分
  Map<String, int> courseTypeMinCredit;

  GraduationInformationJson({
    this.lowCredit,
    this.courseTypeMinCredit,
    this.outerDepartmentMaxCredit,
    this.selectYear,
    this.selectDivision,
    this.selectDepartment,
  }) {
    selectYear = JsonInit.stringInit(selectYear);
    selectDivision = JsonInit.stringInit(selectDivision);
    selectDepartment = JsonInit.stringInit(selectDepartment);
    lowCredit = lowCredit ?? 0;
    outerDepartmentMaxCredit = outerDepartmentMaxCredit ?? 0;
    if (courseTypeMinCredit == null) {
      courseTypeMinCredit = {};
      for (final type in constCourseType) {
        courseTypeMinCredit[type] = 0;
      }
    }
  }

  bool get isSelect => !(selectYear.isEmpty | selectDivision.isEmpty | selectDepartment.isEmpty);

  factory GraduationInformationJson.fromJson(Map<String, dynamic> json) => _$GraduationInformationJsonFromJson(json);

  Map<String, dynamic> toJson() => _$GraduationInformationJsonToJson(this);

  @override
  String toString() => sprintf(
        "---------selectYear--------     \n%s \n---------selectDivision--------          \n%s \n---------selectDepartment--------      \n%s \n---------lowCredit--------  \n%s \n---------outerDepartmentMacCredit--------     :%s \ncourseTypeMinCredit :%s \n",
        [
          selectYear,
          selectDivision,
          selectDepartment,
          lowCredit.toString(),
          outerDepartmentMaxCredit.toString(),
          courseTypeMinCredit.toString(),
        ],
      );
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

  SemesterCourseScoreJson({
    this.semester,
    this.now,
    this.averageScore,
    this.courseScoreList,
    this.history,
    this.performanceScore,
    this.takeCredit,
    this.totalCredit,
  }) {
    now = now ?? RankJson();
    history = history ?? RankJson();
    courseScoreList = courseScoreList ?? [];
    semester = semester ?? SemesterJson.origin();
    averageScore = averageScore ?? 0;
    performanceScore = performanceScore ?? 0;
    totalCredit = totalCredit ?? 0;
    takeCredit = takeCredit ?? 0;
  }

  bool get isRankEmpty => history.isEmpty && now.isEmpty;

  String getAverageScoreString() {
    if (averageScore != 0) {
      return averageScore.toString();
    }

    double average = 0;
    double total = 0;

    for (final score in courseScoreList) {
      try {
        average += double.parse(score.score) * score.credit;
        total += score.credit;
      } catch (e) {
        continue;
      }
    }

    average /= total;
    return average.toStringAsFixed(2);
  }

  String getPerformanceScoreString() => performanceScore.toString();

  String getTakeCreditString() => takeCredit.toString();

  String getTotalCreditString() {
    if (totalCredit != 0) {
      return totalCredit.toString();
    }

    double total = 0;
    for (final score in courseScoreList) {
      total += score.credit;
    }

    return total.toString();
  }

  @override
  String toString() => sprintf(
        "---------semester--------     \n%s \n---------now--------          \n%s \n---------history--------      \n%s \n---------courseScore--------  \n%s \naverageScore     :%s \nperformanceScore :%s \ntotalCredit      :%s \ntakeCredit       :%s \n",
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

  factory SemesterCourseScoreJson.fromJson(Map<String, dynamic> json) => _$SemesterCourseScoreJsonFromJson(json);

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

  bool get isEmpty => course.isEmpty && department.isEmpty;

  @override
  String toString() {
    return sprintf(
      "---------course--------     \n%s \n" "---------department--------          \n%s \n",
      [
        course.toString(),
        department.toString(),
      ],
    );
  }

  factory RankJson.fromJson(Map<String, dynamic> json) => _$RankJsonFromJson(json);

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

  bool get isEmpty => rank == 0 && total == 0 && percentage == 0;

  @override
  String toString() {
    return sprintf(
      "percentage     :%s \nrank           :%s \ntotal          :%s \n",
      [
        percentage.toString(),
        rank.toString(),
        total.toString(),
      ],
    );
  }

  factory RankItemJson.fromJson(Map<String, dynamic> json) => _$RankItemJsonFromJson(json);

  Map<String, dynamic> toJson() => _$RankItemJsonToJson(this);
}

@JsonSerializable()
class CourseScoreInfoJson {
  String courseId;
  String nameZh;
  String nameEn;
  String score;
  double credit; //學分
  String openClass;
  String category;

  String get name => (LanguageUtil.getLangIndex() == LangEnum.en) ? nameEn : nameZh;

  CourseScoreInfoJson({
    this.courseId,
    this.nameZh,
    this.nameEn,
    this.score,
    this.credit,
    this.category,
    this.openClass,
  }) {
    courseId = JsonInit.stringInit(courseId);
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
      final s = int.parse(score);
      return s >= 60;
    } catch (e) {
      return false;
    }
  }

  bool isOtherDepartment(String department) {
    //是否是跨系選修
    final containClass = ["最後一哩"]; //包含就是外系
    final excludeClass = ["體育"]; //包含就不是外系

    bool isOther;
    isOther = category.contains("△"); //是校內共同必修就不是外系
    if (isOther) return false;

    isOther = !openClass.contains(department); //先用開設班級是否是本系判斷
    for (final key in excludeClass) {
      isOther &= !openClass.contains(key);
    }

    for (final key in containClass) {
      isOther |= openClass.contains(key);
    }

    if (category.contains("▲") && openClass.contains("重補修")) {
      isOther = false;
    }

    return isOther;
  }

  // 是否是博雅課程
  bool get isGeneralLesson => openClass.contains("博雅") || openClass.contains("職通識課程");

  // 是否是博雅核心課程
  bool get isCoreGeneralLesson => openClass.contains("核心");

  @override
  String toString() {
    return sprintf(
      "name           :%s \nscore           :%s \ncredit          :%s \n",
      [
        nameZh.toString(),
        score.toString(),
        credit.toString(),
      ],
    );
  }

  factory CourseScoreInfoJson.fromJson(Map<String, dynamic> json) => _$CourseScoreInfoJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseScoreInfoJsonToJson(this);
}
