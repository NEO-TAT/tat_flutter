// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseTable _$CourseTableFromJson(Map<String, dynamic> json) => CourseTable(
      year: json['year'] as int,
      semester: json['semester'] as int,
      courses: (json['courses'] as List<dynamic>)
          .map((e) => Course.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CourseTableToJson(CourseTable instance) =>
    <String, dynamic>{
      'year': instance.year,
      'semester': instance.semester,
      'courses': instance.courses,
      'user': instance.user,
    };
