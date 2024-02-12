import 'package:flutter_app/src/model/coursetable/course_period.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_init.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  String idString;
  late int id;

  String name;

  String stageString;
  late double stage;

  String creditString;
  late double credit;

  String periodCountString;
  late int periodCount;

  String category;

  String teacherString;
  late List<String> teachers;

  String classNameString;
  late List<String> classNames;

  List<String> periodSlots;
  late List<CoursePeriod> coursePeriods;

  String classroomString;
  late List<String> classrooms;

  String applyStatus;
  String language;
  String syllabusLink;
  String note;

  Course({
    required this.idString,
    required this.name,
    required this.stageString,
    required this.creditString,
    required this.periodCountString,
    required this.category,
    required this.teacherString,
    required this.classNameString,
    required this.periodSlots,
    required this.classroomString,
    required this.applyStatus,
    required this.language,
    required this.syllabusLink,
    required this.note,
  }) {
    id = JsonInit.intInit(idString);
    name = JsonInit.stringInit(name).trim();
    stage = JsonInit.doubleInit(stageString);
    credit = JsonInit.doubleInit(creditString);
    periodCount = JsonInit.intInit(periodCountString);
    category = JsonInit.stringInit(category).trim();
    teacherString = JsonInit.stringInit(teacherString).trim();
    teachers = teacherString.split(RegExp(r"\n")).map((element) => element.trim()).toList();
    periodSlots = JsonInit.listInit<String>(periodSlots);
    coursePeriods = _convertPeriodSlotsToCoursePeriods(periodSlots);
    classroomString = JsonInit.stringInit(classroomString).trim();
    classrooms = classroomString.split(RegExp(r"\n")).map((element) => element.trim()).toList();
    classNameString = JsonInit.stringInit(classNameString).trim();
    classNames = classNameString.split(RegExp(r"\n")).map((element) => element.trim()).toList();
    applyStatus = JsonInit.stringInit(applyStatus).trim();
    language = JsonInit.stringInit(language).trim();
    syllabusLink = JsonInit.stringInit(syllabusLink).trim();
    note = JsonInit.stringInit(note).trim();
  }

  bool isEmpty() => id == 0;

  List<CoursePeriod> _convertPeriodSlotsToCoursePeriods(List<String> periodSlots) {
    List<CoursePeriod> coursePeriods = <CoursePeriod>[];
    for (int weekday = 1; weekday <= 7; weekday++) {
      String weekdaySlot = periodSlots[weekday % 7];
      if (_isNullOrEmpty(weekdaySlot)) {
        continue;
      }
      List<String> periods = weekdaySlot.split(RegExp(r"\s"));
      for (String period in periods) {
        coursePeriods.add(CoursePeriod(weekday: weekday, period: period));
      }
    }
    return coursePeriods;
  }

  bool _isNullOrEmpty(String? text) {
    return text == null || text.replaceAll(RegExp(r"\s"), "").isEmpty;
  }

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);
}
