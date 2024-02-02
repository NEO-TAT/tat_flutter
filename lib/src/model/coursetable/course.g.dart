// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as String,
      name: json['name'] as String,
      stage: json['stage'] as String,
      credit: json['credit'] as String,
      periodCount: json['periodCount'] as String,
      category: json['category'] as String,
      teacher: json['teacher'] as String,
      className: json['className'] as String,
      periodSlots: (json['periodSlots'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      classroom: json['classroom'] as String,
      applyStatus: json['applyStatus'] as String,
      language: json['language'] as String,
      syllabusLink: json['syllabusLink'] as String,
      note: json['note'] as String,
    )..coursePeriods = (json['coursePeriods'] as List<dynamic>)
        .map((e) => CoursePeriod.fromJson(e as Map<String, dynamic>))
        .toList();

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stage': instance.stage,
      'credit': instance.credit,
      'periodCount': instance.periodCount,
      'category': instance.category,
      'teacher': instance.teacher,
      'className': instance.className,
      'periodSlots': instance.periodSlots,
      'coursePeriods': instance.coursePeriods,
      'classroom': instance.classroom,
      'applyStatus': instance.applyStatus,
      'language': instance.language,
      'syllabusLink': instance.syllabusLink,
      'note': instance.note,
    };
