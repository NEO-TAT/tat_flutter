// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/model/coursetable/course_period.dart';
import 'package:flutter_app/src/r.dart';

import '../../../src/model/coursetable/course.dart';
import '../../../src/model/coursetable/course_table.dart';

class CourseTableControl {
  bool isHideSaturday = false;
  bool isHideSunday = false;
  bool isHideUnKnown = false;
  bool isHideN = false;
  bool isHideA = false;
  bool isHideB = false;
  bool isHideC = false;
  bool isHideD = false;
  CourseTable courseTable;
  List<String> dayStringList = [
    R.current.Sunday,
    R.current.Monday,
    R.current.Tuesday,
    R.current.Wednesday,
    R.current.Thursday,
    R.current.Friday,
    R.current.Saturday,
    R.current.UnKnown
  ];
  List<String> timeList = [
    "08:10 - 09:00",
    "09:10 - 10:00",
    "10:10 - 11:00",
    "11:10 - 12:00",
    "12:10 - 13:00",
    "13:10 - 14:00",
    "14:10 - 15:00",
    "15:10 - 16:00",
    "16:10 - 17:00",
    "17:10 - 18:00",
    "18:30 - 19:20",
    "19:20 - 20:10",
    "20:20 - 21:10",
    "21:10 - 22:00"
  ];

  List<String> sectionStringList = ["1", "2", "3", "4", "N", "5", "6", "7", "8", "9", "A", "B", "C", "D"];
  static int dayLength = 8;
  static int sectionLength = 14;
  Map<String, Color> colorMap;

  void set(CourseTable value) {
    courseTable = value;
    isHideSaturday =
        !courseTable.courses.any((course) => course.coursePeriods.any((coursePeriod) => coursePeriod.weekday == 6));
    isHideSunday =
        !courseTable.courses.any((course) => course.coursePeriods.any((coursePeriod) => coursePeriod.weekday == 0));
    isHideUnKnown = !courseTable.courses.any((course) => course.coursePeriods.isEmpty);
    isHideN =
        !courseTable.courses.any((course) => course.coursePeriods.any((coursePeriod) => coursePeriod.period == "N"));
    isHideA =
        !courseTable.courses.any((course) => course.coursePeriods.any((coursePeriod) => coursePeriod.period == "A"));
    isHideB =
        !courseTable.courses.any((course) => course.coursePeriods.any((coursePeriod) => coursePeriod.period == "B"));
    isHideC =
        !courseTable.courses.any((course) => course.coursePeriods.any((coursePeriod) => coursePeriod.period == "C"));
    isHideD =
        !courseTable.courses.any((course) => course.coursePeriods.any((coursePeriod) => coursePeriod.period == "D"));
    isHideA &= (isHideB & isHideC & isHideD);
    isHideB &= (isHideC & isHideD);
    isHideC &= isHideD;
    _initColorList();
  }

  List<int> get getDayIntList {
    List<int> intList = [];
    for (int i = 0; i < dayLength; i++) {
      if (isHideSaturday && i == 6) continue;
      if (isHideSunday && i == 0) continue;
      if (isHideUnKnown && i == 7) continue;
      intList.add(i);
    }
    return intList;
  }

  Course getCourse(int weekday, int period) {
    if (weekday == 7) {
      return getUnknownCourse(period);
    }
    return courseTable.courses.firstWhere(
        (course) => course.coursePeriods
            .any((coursePeriod) => coursePeriod.period == getSectionString(period) && coursePeriod.weekday == weekday),
        orElse: () => null);
  }

  Color getCourseInfoColor(int weekday, int period) {
    Course course = getCourse(weekday, period);
    if (colorMap == null) {
      return Colors.white;
    }

    if (course == null) {
      return Colors.white;
    }

    for (final key in colorMap.keys) {
      if (key == course.id.toString()) {
        return colorMap[key];
      }
    }

    return Colors.white;
  }

  void _initColorList() {
    colorMap = {};
    List<String> courseInfoList = courseTable.courses.map((course) => course.id.toString()).toList();
    int colorCount = courseInfoList.length;
    colorCount = (colorCount == 0) ? 1 : colorCount;

    final colors = AppColors.courseTableColors.toList()..shuffle();

    for (int i = 0; i < colorCount; i++) {
      colorMap[courseInfoList[i]] = colors[i % colors.length];
    }
  }

  List<CoursePeriod> get getCoursePeriodList {
    final Set<CoursePeriod> coursePeriodSet = {};
    for (Course course in courseTable.courses) {
      coursePeriodSet.addAll(course.coursePeriods);
    }
    return coursePeriodSet.toList();
  }

  List<int> get getSectionIntList {
    List<int> intList = [];
    for (int i = 0; i < sectionLength; i++) {
      if (isHideN && i == 4) continue;
      if (isHideA && i == 10) continue;
      if (isHideB && i == 11) continue;
      if (isHideC && i == 12) continue;
      if (isHideD && i == 13) continue;
      intList.add(i);
    }
    return intList;
  }

  String getDayString(int day) {
    return dayStringList[day];
  }

  String getTimeString(int time) {
    return timeList[time];
  }

  String getSectionString(int section) {
    return sectionStringList[section];
  }

  Course getUnknownCourse(int period) {
    final nonPeriodCourses = courseTable.courses.where((course) => course.coursePeriods.isEmpty);
    return period >= nonPeriodCourses.length ? null : nonPeriodCourses.elementAt(period);
  }
}
