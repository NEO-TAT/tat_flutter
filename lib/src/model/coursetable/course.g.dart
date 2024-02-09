// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      idString: json['idString'] as String,
      name: json['name'] as String,
      stageString: json['stageString'] as String,
      creditString: json['creditString'] as String,
      periodCountString: json['periodCountString'] as String,
      category: json['category'] as String,
      teacherString: json['teacherString'] as String,
      classNameString: json['classNameString'] as String,
      periodSlots: (json['periodSlots'] as List<dynamic>).map((e) => e as String).toList(),
      classroomString: json['classroomString'] as String,
      applyStatus: json['applyStatus'] as String,
      language: json['language'] as String,
      syllabusLink: json['syllabusLink'] as String,
      note: json['note'] as String,
    )
      ..id = json['id'] as int
      ..stage = (json['stage'] as num).toDouble()
      ..credit = (json['credit'] as num).toDouble()
      ..periodCount = json['periodCount'] as int
      ..teachers = (json['teachers'] as List<dynamic>).map((e) => e as String).toList()
      ..classNames = (json['classNames'] as List<dynamic>).map((e) => e as String).toList()
      ..coursePeriods =
          (json['coursePeriods'] as List<dynamic>).map((e) => CoursePeriod.fromJson(e as Map<String, dynamic>)).toList()
      ..classrooms = (json['classrooms'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'idString': instance.idString,
      'id': instance.id,
      'name': instance.name,
      'stageString': instance.stageString,
      'stage': instance.stage,
      'creditString': instance.creditString,
      'credit': instance.credit,
      'periodCountString': instance.periodCountString,
      'periodCount': instance.periodCount,
      'category': instance.category,
      'teacherString': instance.teacherString,
      'teachers': instance.teachers,
      'classNameString': instance.classNameString,
      'classNames': instance.classNames,
      'periodSlots': instance.periodSlots,
      'coursePeriods': instance.coursePeriods,
      'classroomString': instance.classroomString,
      'classrooms': instance.classrooms,
      'applyStatus': instance.applyStatus,
      'language': instance.language,
      'syllabusLink': instance.syllabusLink,
      'note': instance.note,
    };
