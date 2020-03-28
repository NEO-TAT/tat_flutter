import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'CourseMainExtraJson.g.dart';

@JsonSerializable()
class CourseExtraInfoJson {
  //點入課程使用
  SemesterJson courseSemester;
  CourseExtraJson course;
  List<ClassmateJson> classmate; //修課同學

  CourseExtraInfoJson({this.courseSemester, this.course, this.classmate}) {
    classmate = classmate ?? List();
    courseSemester = courseSemester ?? SemesterJson();
    course = course ?? CourseExtraJson();
  }

  bool get isEmpty {
    return classmate.isEmpty && courseSemester.isEmpty && course.isEmpty;
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
  CourseMainJson course;
  List<TeacherJson> teacher; //開課老師
  List<ClassroomJson> classroom; //使用教室
  List<ClassJson> openClass; //開課班級
  CourseMainInfoJson(
      {this.course, this.teacher, this.classroom, this.openClass}) {
    course = course ?? CourseMainJson();
    teacher = teacher ?? List();
    classroom = classroom ?? List();
    openClass = openClass ?? List();
  }

  String getOpenClassName() {
    String name = "";
    for (ClassJson value in openClass) {
      name += value.name + ' ';
    }
    return name;
  }

  String getTeacherName() {
    String name = "";
    for (TeacherJson value in teacher) {
      name += value.name + ' ';
    }
    return name;
  }

  String getClassroomName() {
    String name = "";
    for (ClassroomJson value in classroom) {
      name += value.name + ' ';
    }
    return name;
  }

  List<String> getClassroomNameList() {
    List<String> name = List();
    for (ClassroomJson value in classroom) {
      name.add(value.name);
    }
    return name;
  }

  List<String> getClassroomHrefList() {
    List<String> href = List();
    for (ClassroomJson value in classroom) {
      href.add(value.href);
    }
    return href;
  }

  bool get isEmpty {
    return course.isEmpty &&
        teacher.length == 0 &&
        classroom.length == 0 &&
        openClass.length == 0;
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
