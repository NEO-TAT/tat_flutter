import 'package:flutter_app/src/model/coursetable/course_period.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_init.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  late int id;
  String name;
  late double stage;
  late double credit;
  late int periodCount;
  String category;
  late List<String> teachers;
  late List<String> classNames;
  late List<CoursePeriod> coursePeriods;
  late List<String> classrooms;
  String applyStatus;
  String language;
  String syllabusLink;
  String note;

  Course(
      {required this.id,
      required this.name,
      required this.stage,
      required this.credit,
      required this.periodCount,
      required this.category,
      required this.teachers,
      required this.classNames,
      required this.coursePeriods,
      required this.classrooms,
      required this.applyStatus,
      required this.language,
      required this.syllabusLink,
      required this.note});

  Course.parseNodeString({
    required String idString,
    required this.name,
    required String stageString,
    required String creditString,
    required String periodCountString,
    required this.category,
    required String teacherString,
    required String classNameString,
    required List<String> periodSlots,
    required String classroomString,
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
    teachers = teacherString.split(RegExp(r"\n")).map((element) => element.trim()).toList();
    coursePeriods = _convertPeriodSlotsToCoursePeriods(periodSlots);
    classrooms = classroomString.split(RegExp(r"\n")).map((element) => element.trim()).toList();
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
