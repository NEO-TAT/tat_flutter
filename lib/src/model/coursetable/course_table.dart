import 'package:json_annotation/json_annotation.dart';

import 'course.dart';
import 'user.dart';

part 'course_table.g.dart';

@JsonSerializable()
class CourseTable {
  int year;
  int semester;
  List<Course> courses;
  User user;

  CourseTable({required this.year, required this.semester, required this.courses, required this.user}) {
    year = year;
    semester = semester;
    courses = courses;
    user = user;
  }

  factory CourseTable.fromJson(Map<String, dynamic> json) => _$CourseTableFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTableToJson(this);
}
