import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';

part 'course_main_extra_json.g.dart';

@JsonSerializable()
class CourseExtraInfoJson {
  SemesterJson? courseSemester = SemesterJson();
  CourseExtraJson? course = CourseExtraJson();
  List<ClassmateJson>? classmate = [];

  CourseExtraInfoJson({
    this.courseSemester,
    this.course,
    this.classmate,
  });

  bool get isEmpty {
    return (classmate != null && classmate!.isEmpty) &&
        (courseSemester != null && courseSemester!.isEmpty) &&
        (course != null && course!.isEmpty);
  }

  @override
  String toString() {
    return sprintf(
        "---------courseSemester--------  \n%s \n" +
            "---------course--------          \n%s \n" +
            "---------classmateList--------   \n%s \n",
        [courseSemester.toString(), course.toString(), classmate.toString()]);
  }

  factory CourseExtraInfoJson.fromJson(Map<String, dynamic> json) =>
      _$CourseExtraInfoJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseExtraInfoJsonToJson(this);
}

@JsonSerializable()
class CourseMainInfoJson {
  CourseMainJson? course = CourseMainJson();
  List<TeacherJson>? teacher = [];
  List<ClassroomJson>? classroom = [];
  List<ClassJson>? openClass = [];

  CourseMainInfoJson({
    this.course,
    this.teacher,
    this.classroom,
    this.openClass,
  });

  String getOpenClassName() {
    String name = "";
    for (ClassJson value in openClass!) {
      name += value.name + ' ';
    }
    return name;
  }

  String getTeacherName() {
    String name = "";
    for (TeacherJson value in teacher!) {
      name += value.name + ' ';
    }
    return name;
  }

  String getClassroomName() {
    String name = "";
    for (ClassroomJson value in classroom!) {
      name += value.name + ' ';
    }
    return name;
  }

  List<String> getClassroomNameList() {
    List<String> name = [];
    for (ClassroomJson value in classroom!) {
      name.add(value.name);
    }
    return name;
  }

  List<String> getClassroomHrefList() {
    List<String> href = [];
    for (ClassroomJson value in classroom!) {
      href.add(value.href);
    }
    return href;
  }

  String getTime() {
    String time = "";
    List<String> dayStringList = [
      R.current.Monday,
      R.current.Tuesday,
      R.current.Wednesday,
      R.current.Thursday,
      R.current.Friday,
      R.current.Saturday,
      R.current.Sunday,
      R.current.UnKnown
    ];
    for (Day day in course!.time!.keys) {
      if (course!.time![day]!.replaceAll(RegExp('[|\n]'), "").isNotEmpty) {
        time += "${dayStringList[day.index]}_${course!.time![day]} ";
      }
    }
    return time;
  }

  bool get isEmpty {
    return (course != null && course!.isEmpty) &&
        (teacher != null && teacher!.length == 0) &&
        (classroom != null && classroom!.length == 0) &&
        (openClass != null && openClass!.length == 0);
  }

  @override
  String toString() {
    return sprintf(
        "---------course--------         \n%s \n" +
            "---------teacherList--------    \n%s \n" +
            "---------classroomList--------  \n%s \n" +
            "---------openClassList--------  \n%s \n",
        [
          course.toString(),
          teacher.toString(),
          classroom.toString(),
          openClass.toString()
        ]);
  }

  factory CourseMainInfoJson.fromJson(Map<String, dynamic> json) =>
      _$CourseMainInfoJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseMainInfoJsonToJson(this);
}
