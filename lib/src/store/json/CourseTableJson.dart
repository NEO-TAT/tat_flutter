import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:quiver/core.dart';
import 'package:sprintf/sprintf.dart';
import '../JsonInit.dart';
import 'CourseClassJson.dart';
part 'CourseTableJson.g.dart';

enum Day {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday,
  Sunday,
  UnKnown
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
  T_UnKnown
}

@JsonSerializable()
class CourseTableJson {
  SemesterJson courseSemester; //課程學期資料
  String studentId;
  Map<Day, Map<SectionNumber, CourseInfoJson>> courseInfoMap;

  CourseTableJson({this.courseSemester, this.courseInfoMap}) {
    studentId = JsonInit.stringInit(studentId);
    courseSemester = courseSemester ?? SemesterJson();
    if (courseInfoMap != null) {
      courseInfoMap = courseInfoMap;
    } else {
      courseInfoMap = Map();
      for (Day value in Day.values) {
        courseInfoMap[value] = Map();
      }
    }
  }

  bool isDayInCourseTable(Day day) {
    bool pass = false;
    for (SectionNumber number in SectionNumber.values) {
      if (courseInfoMap[day][number] != null) {
        pass = true;
        break;
      }
    }
    return pass;
  }

  bool isSectionNumberInCourseTable(SectionNumber number) {
    bool pass = false;
    for (Day day in Day.values) {
      if (courseInfoMap[day].containsKey(number)) {
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
    for (Day day in Day.values) {
      for (SectionNumber number in SectionNumber.values) {
        courseInfoString += day.toString() + "  " + number.toString() + "\n";
        courseInfoString += courseInfoMap[day][number].toString() + "\n";
      }
    }
    return sprintf(
        "studentId :%s \n " +
            "---------courseSemester-------- \n%s \n" +
            "---------courseInfo--------     \n%s \n",
        [studentId, courseSemester.toString(), courseInfoString]);
  }

  bool get isEmpty {
    return studentId.isEmpty && courseSemester.isEmpty;
  }

  CourseInfoJson getCourseDetailByTime(Day day, SectionNumber sectionNumber) {
    return courseInfoMap[day][sectionNumber];
  }

  void setCourseDetailByTime(
      Day day, SectionNumber sectionNumber, CourseInfoJson courseInfo) {
    if (day == Day.UnKnown) {
      for (SectionNumber value in SectionNumber.values) {
        if (!courseInfoMap[day].containsKey(value)) {
          courseInfoMap[day][value] = courseInfo;
          //Log.d( day.toString() + value.toString() + courseInfo.toString() );
          break;
        }
      }
    } else if (courseInfoMap[day].containsKey(sectionNumber)) {
      throw Exception("衝堂");
    } else {
      courseInfoMap[day][sectionNumber] = courseInfo;
    }
  }

  bool setCourseDetailByTimeString(
      Day day, String sectionNumber, CourseInfoJson courseInfo) {
    bool add = false;
    if (courseInfoMap[day].containsKey(sectionNumber)) {
      throw Exception("衝堂");
    }
    for (SectionNumber value in SectionNumber.values) {
      String time = value.toString().split("_")[1];
      if (sectionNumber.contains(time)) {
        setCourseDetailByTime(day, value, courseInfo);
        add = true;
      }
    }
    return add;
  }

  List<String> getCourseIdList() {
    List<String> courseIdList = List();
    for (Day day in Day.values) {
      for (SectionNumber number in SectionNumber.values) {
        CourseInfoJson courseInfo = courseInfoMap[day][number];
        if (courseInfo != null) {
          String id = courseInfo.main.course.id;
          if (!courseIdList.contains(id)) {
            courseIdList.add(id);
          }
        }
      }
    }
    return courseIdList;
  }

  String getCourseNameByCourseId(String courseId) {
    for (Day day in Day.values) {
      for (SectionNumber number in SectionNumber.values) {
        CourseInfoJson courseDetail = courseInfoMap[day][number];
        if (courseDetail != null) {
          if (courseDetail.main.course.id == courseId) {
            return courseDetail.main.course.name;
          }
        }
      }
    }
    return null;
  }
}

@JsonSerializable()
class CourseInfoJson {
  CourseMainInfoJson main;
  CourseExtraInfoJson extra;

  CourseInfoJson({this.main, this.extra}) {
    main = main ?? CourseMainInfoJson();
    extra = extra ?? CourseExtraInfoJson();
  }

  bool get isEmpty {
    return main.isEmpty && extra.isEmpty;
  }
/*
  @override
  bool operator ==(dynamic  o) {
    if( isEmpty || o.isEmpty || !(o is CourseInfoJson) ){
      return false;
    }else{
      return ( main.course.id == o.main.course.id );
    }
  }

  int get hashCode => hash2(main.hashCode, extra.hashCode);
*/

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
