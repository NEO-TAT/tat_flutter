// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/model/json_init.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CourseSyllabusJson {
  int year = 0;
  int semester = 0;
  int courseId = 0;
  String courseName = "";
  int phase = 0;
  double credit = 0;
  int hour = 0;
  String category = "";
  List<String> teachers = [];
  String className = "";
  int applyStudentCount = 0;
  int withdrawStudentCount = 0;
  String note = "";

  CourseSyllabusJson({
    String yearSemester,
    String courseId,
    String courseName,
    String phase,
    String credit,
    String hour,
    String category,
    String teachers,
    String className,
    String applyStudentCount,
    String withdrawStudentCount,
    String note
  }) {
    year = int.parse(yearSemester.split("-")[0]);
    semester = int.parse(yearSemester.split("-")[1]);
    this.courseId = int.parse(courseId);
    this.courseName = JsonInit.stringInit(courseName);
    this.phase = int.parse(phase);
    this.credit = double.parse(credit);
    this.hour = int.parse(hour);
    this.category = JsonInit.stringInit(category);
    this.teachers = JsonInit.listInit<String>(teachers.split("\n"));
    this.className = JsonInit.stringInit(className);
    this.applyStudentCount = int.parse(applyStudentCount);
    this.withdrawStudentCount = int.parse(withdrawStudentCount);
    this.note = JsonInit.stringInit(note);
  }
}