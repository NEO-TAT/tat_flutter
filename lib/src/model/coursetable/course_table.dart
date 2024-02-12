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
  late final Set<int> weekdays = {};
  late final Set<String> periods = {};

  CourseTable({required this.year, required this.semester, required this.courses, required this.user}) {
    year = year;
    semester = semester;
    courses = courses;
    user = user;
    weekdays.addAll(courses.map((course) => course.coursePeriods.map((coursePeriod) => coursePeriod.weekday))
        .expand((element) => element));
    periods.addAll(courses.map((course) => course.coursePeriods.map((coursePeriod) => coursePeriod.period))
        .expand((element) => element));
  }

  bool isPeriodInCourseTable(String period) => periods.contains(period);

  bool isWeekdayInCourseTable(int weekday) => weekdays.contains(weekday);

  factory CourseTable.fromJson(Map<String, dynamic> json) => _$CourseTableFromJson(json);
  Map<String, dynamic> toJson() => _$CourseTableToJson(this);
}
