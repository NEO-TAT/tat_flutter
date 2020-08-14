import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppColors.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';

class CourseTableControl {
  bool isHideSaturday = false;
  bool isHideSunday = false;
  bool isHideUnKnown = false;
  bool isHideN = false;
  bool isHideA = false;
  bool isHideB = false;
  bool isHideC = false;
  bool isHideD = false;
  CourseTableJson courseTable;
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
    "18:30 - 19:20",
    "19:20 - 20:10",
    "20:20 - 21:10",
    "21:10 - 22:00"
  ];

  List<String> sectionStringList = [
    "1",
    "2",
    "3",
    "4",
    "N",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D"
  ];
  static int dayLength = 8;
  static int sectionLength = 14;
  Map<String, Color> colorMap;

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
    List<int> intList = List();
    for (int i = 0; i < dayLength; i++) {
      if (isHideSaturday && i == 5) continue;
      if (isHideSunday && i == 6) continue;
      if (isHideUnKnown && i == 7) continue;
      intList.add(i);
    }
    return intList;
  }

  CourseInfoJson getCourseInfo(int intDay, int intNumber) {
    Day day = Day.values[intDay];
    SectionNumber number = SectionNumber.values[intNumber];
    //Log.d( day.toString()  + " " + number.toString() );
    return courseTable.courseInfoMap[day][number];
  }

  Color getCourseInfoColor(int intDay, int intNumber) {
    CourseInfoJson courseInfo = getCourseInfo(intDay, intNumber);
    for (String key in colorMap.keys) {
      if (courseInfo != null) {
        if (key == courseInfo.main.course.id) {
          return colorMap[key];
        }
      }
    }
    return Colors.white;
  }

  void _initColorList() {
    colorMap = Map();
    List<String> courseInfoList = courseTable.getCourseIdList();
    int colorCount = courseInfoList.length;
    colorCount = (colorCount == 0) ? 1 : colorCount;

    final colors = AppColors.courseTableColors.toList()..shuffle();

    for (int i = 0; i < colorCount; i++) {
      colorMap[courseInfoList[i]] = colors[i % colors.length];
    }
  }

  List<int> get getSectionIntList {
    List<int> intList = List();
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
}
