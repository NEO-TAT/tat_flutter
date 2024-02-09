// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_semester.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SemesterJson _$SemesterJsonFromJson(Map<String, dynamic> json) {
  return SemesterJson(
    year: json['year'] as String,
    semester: json['semester'] as String,
  );
}

Map<String, dynamic> _$SemesterJsonToJson(SemesterJson instance) => <String, dynamic>{
      'year': instance.year,
      'semester': instance.semester,
    };
