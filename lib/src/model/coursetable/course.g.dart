// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
      id: json['id'] as int,
      name: json['name'] as String,
      stage: (json['stage'] as num).toDouble(),
      credit: (json['credit'] as num).toDouble(),
      periodCount: json['periodCount'] as int,
      category: json['category'] as String,
      teachers: (json['teachers'] as List<dynamic>).map((e) => e as String).toList(),
      classNames: (json['classNames'] as List<dynamic>).map((e) => e as String).toList(),
      coursePeriods: (json['coursePeriods'] as List<dynamic>)
          .map((e) => CoursePeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
      classrooms: (json['classrooms'] as List<dynamic>).map((e) => e as String).toList(),
      applyStatus: json['applyStatus'] as String,
      language: json['language'] as String,
      syllabusLink: json['syllabusLink'] as String,
      note: json['note'] as String,
    );

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'stage': instance.stage,
      'credit': instance.credit,
      'periodCount': instance.periodCount,
      'category': instance.category,
      'teachers': instance.teachers,
      'classNames': instance.classNames,
      'coursePeriods': instance.coursePeriods,
      'classrooms': instance.classrooms,
      'applyStatus': instance.applyStatus,
      'language': instance.language,
      'syllabusLink': instance.syllabusLink,
      'note': instance.note,
    };
