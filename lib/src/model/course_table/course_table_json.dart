import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course/course_main_extra_json.dart';

part 'course_table_json.g.dart';

enum Day {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday,
  UnKnown,
}

enum SectionNumber {
  T_1,
  T_2,
  T_3,
  T_4,
  T_N,
  T_5,
  T_6,
  T_7,
  T_8,
  T_9,
  T_A,
  T_B,
  T_C,
  T_D,
  T_UnKnown,
}

@JsonSerializable()
class CourseTableJson {
  SemesterJson? courseSemester = SemesterJson(); //課程學期資料
  late final String studentId;
  late final String studentName;
  late final Map<Day, Map<SectionNumber, CourseInfoJson>>? courseInfoMap;

  CourseTableJson({
    this.courseSemester,
    this.courseInfoMap,
    this.studentId = '',
    this.studentName = '',
  }) {
    if (courseInfoMap == null) {
      courseInfoMap = Map();
      for (Day value in Day.values) {
        courseInfoMap![value] = Map();
      }
    }
  }

  int getTotalCredit() {
    int credit = 0;
    final courseIdList = getCourseIdList();
    for (final courseId in courseIdList) {
      credit += getCreditByCourseId(courseId);
    }
    return credit;
  }

  int getCreditByCourseId(String courseId) {
    for (final day in Day.values) {
      for (final number in SectionNumber.values) {
        final courseDetail = courseInfoMap![day]![number];

        if (courseDetail != null) {
          if (courseDetail.main!.course!.id == courseId) {
            final creditString = courseDetail.main!.course!.credits;

            try {
              return double.parse(creditString).toInt();
            } catch (e) {
              return 0;
            }
          }
        }
      }
    }
    return 0;
  }

  bool isDayInCourseTable(Day day) {
    bool pass = false;
    for (final number in SectionNumber.values) {
      if (courseInfoMap![day]![number] != null) {
        pass = true;
        break;
      }
    }
    return pass;
  }

  bool isSectionNumberInCourseTable(SectionNumber number) {
    bool pass = false;
    for (final day in Day.values) {
      if (courseInfoMap![day]!.containsKey(number)) {
        pass = true;
        break;
      }
    }
    return pass;
  }

  factory CourseTableJson.fromJson(Map<String, dynamic> json) =>
      _$CourseTableJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseTableJsonToJson(this);

  String toString() {
    String courseInfoString = "";
    for (final day in Day.values) {
      for (final number in SectionNumber.values) {
        courseInfoString += day.toString() + "  " + number.toString() + "\n";
        courseInfoString += courseInfoMap![day]![number].toString() + "\n";
      }
    }

    return sprintf(
      "studentId :%s \n " +
          "---------courseSemester-------- \n%s \n" +
          "---------courseInfo--------     \n%s \n",
      [
        studentId,
        courseSemester.toString(),
        courseInfoString,
      ],
    );
  }

  bool get isEmpty => studentId.isEmpty && courseSemester!.isEmpty;

  CourseInfoJson? getCourseDetailByTime(Day day, SectionNumber sectionNumber) =>
      courseInfoMap![day]![sectionNumber];

  void setCourseDetailByTime(
    Day day,
    SectionNumber sectionNumber,
    CourseInfoJson courseInfo,
  ) {
    if (day == Day.UnKnown) {
      for (final value in SectionNumber.values) {
        if (courseInfo.main!.course!.id.isEmpty) {
          continue;
        }
        if (!courseInfoMap![day]!.containsKey(value)) {
          courseInfoMap![day]![value] = courseInfo;
          break;
        }
      }
    } else {
      courseInfoMap![day]![sectionNumber] = courseInfo;
    }
  }

  bool setCourseDetailByTimeString(
    Day day,
    String sectionNumber,
    CourseInfoJson courseInfo,
  ) {
    bool add = false;
    for (final value in SectionNumber.values) {
      final time = value.toString().split("_")[1];
      if (sectionNumber.contains(time)) {
        setCourseDetailByTime(day, value, courseInfo);
        add = true;
      }
    }
    return add;
  }

  SectionNumber? string2Time(String sectionNumber) {
    for (final value in SectionNumber.values) {
      final time = value.toString().split("_")[1];
      if (sectionNumber.contains(time)) {
        return value;
      }
    }
    return null;
  }

  bool addCourseDetailByCourseInfo(CourseMainInfoJson info) {
    bool add = false;
    final courseInfo = CourseInfoJson();

    for (int i = 0; i < 7; i++) {
      final day = Day.values[i];
      final time = info.course!.time![day]!;
      courseInfo.main = info;
      if (courseInfoMap![day]![string2Time(time)] != null) {
        return false;
      }
    }

    for (int i = 0; i < 7; i++) {
      final day = Day.values[i];
      final time = info.course!.time![day]!;
      courseInfo.main = info;
      add |= setCourseDetailByTimeString(day, time, courseInfo);
    }

    if (!add) {
      setCourseDetailByTime(Day.UnKnown, SectionNumber.T_UnKnown, courseInfo);
    }

    return true;
  }

  List<String> getCourseIdList() {
    final List<String> courseIdList = [];

    for (final day in Day.values) {
      for (final number in SectionNumber.values) {
        final courseInfo = courseInfoMap![day]![number];

        if (courseInfo != null) {
          final id = courseInfo.main!.course!.id;

          if (!courseIdList.contains(id)) {
            courseIdList.add(id);
          }
        }
      }
    }
    return courseIdList;
  }

  String? getCourseNameByCourseId(String courseId) {
    for (final day in Day.values) {
      for (final number in SectionNumber.values) {
        final courseDetail = courseInfoMap![day]![number];

        if (courseDetail != null) {
          if (courseDetail.main!.course!.id == courseId) {
            return courseDetail.main!.course!.name;
          }
        }
      }
    }
    return null;
  }

  CourseInfoJson? getCourseInfoByCourseName(String courseName) {
    for (final day in Day.values) {
      for (final number in SectionNumber.values) {
        final courseDetail = courseInfoMap![day]![number];

        if (courseDetail != null) {
          if (courseDetail.main!.course!.name == courseName) {
            return courseDetail;
          }
        }
      }
    }
    return null;
  }

  void removeCourseByCourseId(String courseId) {
    for (final day in Day.values) {
      for (final number in SectionNumber.values) {
        final courseDetail = courseInfoMap![day]![number];
        if (courseDetail != null) {
          if (courseDetail.main!.course!.id == courseId) {
            courseInfoMap![day]!.remove(number);
          }
        }
      }
    }
  }
}

@JsonSerializable()
class CourseInfoJson {
  CourseMainInfoJson? main = CourseMainInfoJson();
  CourseExtraInfoJson? extra = CourseExtraInfoJson();

  CourseInfoJson({this.main, this.extra});

  bool get isEmpty => main!.isEmpty && extra!.isEmpty;

  @override
  String toString() {
    return sprintf(
        "---------main--------  \n%s \n" + "---------extra-------- \n%s \n",
        [main.toString(), extra.toString()]);
  }

  factory CourseInfoJson.fromJson(Map<String, dynamic> json) =>
      _$CourseInfoJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseInfoJsonToJson(this);
}
