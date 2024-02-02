import 'package:flutter_app/src/model/coursetable/course_period.dart';
import 'package:json_annotation/json_annotation.dart';

import '../json_init.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  late int id;
  String name;
  late int stage;
  late double credit;
  late int periodCount;
  String category;
  String teacher;
  String className;
  late List<String> periodSlots;
  late List<CoursePeriod> coursePeriods;
  String classroom;
  String applyStatus;
  String language;
  String syllabusLink;
  String note;

  Course({
    required String id,
    required this.name,
    required String stage,
    required String credit,
    required String periodCount,
    required this.category,
    required this.teacher,
    required this.className,
    required this.periodSlots,
    required this.classroom,
    required this.applyStatus,
    required this.language,
    required this.syllabusLink,
    required this.note
  }) {
    this.id = JsonInit.intInit(id);
    name = JsonInit.stringInit(name);
    this.stage = JsonInit.intInit(stage);
    this.credit = JsonInit.doubleInit(credit);
    this.periodCount = JsonInit.intInit(periodCount);
    category = JsonInit.stringInit(category);
    teacher = JsonInit.stringInit(teacher);
    periodSlots = JsonInit.listInit<String>(periodSlots);
    coursePeriods =  _convertPeriodSlotsToCoursePeriods(periodSlots);
    classroom = JsonInit.stringInit(classroom);
    applyStatus = JsonInit.stringInit(applyStatus);
    language = JsonInit.stringInit(language);
    syllabusLink = JsonInit.stringInit(syllabusLink);
    note = JsonInit.stringInit(note);
  }

  bool isEmpty() => id == 0;

  static List<CoursePeriod> _convertPeriodSlotsToCoursePeriods(List<String> periodSlots){
    List<CoursePeriod> coursePeriods = <CoursePeriod>[];
    for(int weekday = 1; weekday <= 7; weekday++){
      String weekdaySlot = periodSlots[weekday % 7];
      if(_isNullOrEmpty(weekdaySlot)){
        continue;
      }
      List<String> periods = weekdaySlot.split(RegExp(r"\s"));
      for(String period in periods) {
        coursePeriods.add(CoursePeriod(
            weekday: weekday,
            period: period
        ));
      }
    }
    return coursePeriods;
  }

  static bool _isNullOrEmpty(String? text){
    return text == null || text.replaceAll(RegExp(r"\s"), "").isEmpty;
  }

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
  Map<String, dynamic> toJson() => _$CourseToJson(this);
}