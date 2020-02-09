import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:native_color/native_color.dart';

class CourseTableControl {
  bool isHideSaturday = false;
  bool isHideSunday = false;
  bool isHideUnKnown = false;
  bool isHideN = false;
  bool isHideABCD = false;
  CourseTableJson courseTable;
  List<String> dayStringList = ["一", "二", "三", "四", "五", "六", "日", ""];
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
    isHideSaturday = !courseTable.isDayInCourseTable(Day.Sunday);
    isHideSunday = !courseTable.isDayInCourseTable(Day.Saturday);
    isHideUnKnown = !courseTable.isDayInCourseTable(Day.UnKnown);
    isHideN = !courseTable.isSectionNumberInCourseTable(SectionNumber.T_N);
    isHideABCD = (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_A));
    isHideABCD &=
        (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_B));
    isHideABCD &=
        (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_C));
    isHideABCD &=
        (!courseTable.isSectionNumberInCourseTable(SectionNumber.T_D));
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
    int delta = (360 / colorCount).floor();
    int offset = (Random().nextDouble() * 360).floor();
    for (int i = 0; i < colorCount; i++) {
      Color color = HslColor((offset + (delta * i) % 360).toDouble(), 100, 80);
      colorMap[courseInfoList[i]] = color;
    }
  }

  List<int> get getSectionIntList {
    List<int> intList = List();
    for (int i = 0; i < sectionLength; i++) {
      if (isHideN && i == 4) continue;
      if (isHideABCD && (i == 10 || i == 11 || i == 12 || i == 13)) continue;
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
