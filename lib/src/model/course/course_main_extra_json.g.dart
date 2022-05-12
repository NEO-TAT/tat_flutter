// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_main_extra_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseExtraInfoJson _$CourseExtraInfoJsonFromJson(Map<String, dynamic> json) {
  return CourseExtraInfoJson(
    courseSemester:
        json['courseSemester'] == null ? null : SemesterJson.fromJson(json['courseSemester'] as Map<String, dynamic>),
    course: json['course'] == null ? null : CourseExtraJson.fromJson(json['course'] as Map<String, dynamic>),
    classmate: (json['classmate'] as List)
        ?.map((e) => e == null ? null : ClassmateJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseExtraInfoJsonToJson(CourseExtraInfoJson instance) => <String, dynamic>{
      'courseSemester': instance.courseSemester,
      'course': instance.course,
      'classmate': instance.classmate,
    };

CourseMainInfoJson _$CourseMainInfoJsonFromJson(Map<String, dynamic> json) {
  return CourseMainInfoJson(
    course: json['course'] == null ? null : CourseMainJson.fromJson(json['course'] as Map<String, dynamic>),
    teacher: (json['teacher'] as List)
        ?.map((e) => e == null ? null : TeacherJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    classroom: (json['classroom'] as List)
        ?.map((e) => e == null ? null : ClassroomJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    openClass: (json['openClass'] as List)
        ?.map((e) => e == null ? null : ClassJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseMainInfoJsonToJson(CourseMainInfoJson instance) => <String, dynamic>{
      'course': instance.course,
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'openClass': instance.openClass,
    };
