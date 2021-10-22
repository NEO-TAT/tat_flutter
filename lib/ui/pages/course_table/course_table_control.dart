import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_colors.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';

class CourseTableControl {
  bool isHideSaturday = false;
  bool isHideSunday = false;
  bool isHideUnKnown = false;
  bool isHideN = false;
  bool isHideA = false;
  bool isHideB = false;
  bool isHideC = false;
  bool isHideD = false;
  late final CourseTableJson courseTable;
  final dayStringList = [
    R.current.Monday,
    R.current.Tuesday,
    R.current.Wednesday,
    R.current.Thursday,
    R.current.Friday,
    R.current.Saturday,
    R.current.Sunday,
    R.current.UnKnown
  ];
  final timeList = [
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

  final sectionStringList = ["1", "2", "3", "4", "N", "5", "6", "7", "8", "9", "A", "B", "C", "D"];
  static const dayLength = 8;
  static const sectionLength = 14;
  late Map<String, Color> colorMap;

  void set(CourseTableJson value) {
    courseTable = value;
    isHideSaturday = !courseTable.isDayInCourseTable(Day.Saturday);
    isHideSunday = !courseTable.isDayInCourseTable(Day.Sunday);
    isHideUnKnown = !courseTable.isDayInCourseTable(Day.UnKnown);
    isHideN = !courseTable.isSectionNumberInCourseTable(SectionNumber.T_N);
    isHideA = (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_A));
    isHideB = (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_B));
    isHideC = (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_C));
    isHideD = (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_D));
    isHideA &= (isHideB & isHideC & isHideD);
    isHideB &= (isHideC & isHideD);
    isHideC &= isHideD;
    _initColorList();
  }

  List<int> get getDayIntList {
    final List<int> intList = [];
    for (int i = 0; i < dayLength; i++) {
      if (isHideSaturday && i == 5) continue;
      if (isHideSunday && i == 6) continue;
      if (isHideUnKnown && i == 7) continue;
      intList.add(i);
    }
    return intList;
  }

  CourseInfoJson? getCourseInfo(int intDay, int intNumber) {
    final day = Day.values[intDay];
    final number = SectionNumber.values[intNumber];
    return courseTable.courseInfoMap![day]![number];
  }

  Color? getCourseInfoColor(int intDay, int intNumber) {
    final courseInfo = getCourseInfo(intDay, intNumber);
    for (final key in colorMap.keys) {
      if (courseInfo != null) {
        if (key == courseInfo.main!.course!.id) {
          return colorMap[key];
        }
      }
    }
    return Colors.white;
  }

  void _initColorList() {
    colorMap = Map();
    final courseInfoList = courseTable.getCourseIdList();
    final colorCount = (courseInfoList.length == 0) ? 1 : courseInfoList.length;

    final colors = AppColors.courseTableColors.toList()..shuffle();

    for (int i = 0; i < colorCount; i++) {
      colorMap[courseInfoList[i]] = colors[i % colors.length];
    }
  }

  List<int> get getSectionIntList {
    final List<int> intList = [];
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

  String getDayString(int day) => dayStringList[day];

  String getTimeString(int time) => timeList[time];

  String getSectionString(int section) => sectionStringList[section];
}
