// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseInfoJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseInfoJson _$CourseInfoJsonFromJson(Map<String, dynamic> json) {
  return CourseInfoJson(
    courseSemester: json['courseSemester'] == null
        ? null
        : SemesterJson.fromJson(json['courseSemester'] as Map<String, dynamic>),
    courseDetail: json['courseDetail'] == null
        ? null
        : CourseDetailJson.fromJson(
            json['courseDetail'] as Map<String, dynamic>),
    classmate: (json['classmate'] as List)
        ?.map((e) => e == null
            ? null
            : ClassmateJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    teacher: (json['teacher'] as List)
        ?.map((e) =>
            e == null ? null : TeacherJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    classroom: (json['classroom'] as List)
        ?.map((e) => e == null
            ? null
            : ClassroomJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    openClass: (json['openClass'] as List)
        ?.map((e) =>
            e == null ? null : CourseJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseInfoJsonToJson(CourseInfoJson instance) =>
    <String, dynamic>{
      'courseSemester': instance.courseSemester,
      'courseDetail': instance.courseDetail,
      'classmate': instance.classmate,
      'teacher': instance.teacher,
      'classroom': instance.classroom,
      'openClass': instance.openClass,
    };

CourseDetailJson _$CourseDetailJsonFromJson(Map<String, dynamic> json) {
  return CourseDetailJson(
    course: json['course'] == null
        ? null
        : CourseJson.fromJson(json['course'] as Map<String, dynamic>),
    stage: json['stage'] as String,
    credits: json['credits'] as String,
    hours: json['hours'] as String,
    category: json['category'] as String,
    selectNumber: json['selectNumber'] as String,
    withdrawNumber: json['withdrawNumber'] as String,
  );
}

Map<String, dynamic> _$CourseDetailJsonToJson(CourseDetailJson instance) =>
    <String, dynamic>{
      'course': instance.course,
      'stage': instance.stage,
      'credits': instance.credits,
      'hours': instance.hours,
      'category': instance.category,
      'selectNumber': instance.selectNumber,
      'withdrawNumber': instance.withdrawNumber,
    };

ClassmateJson _$ClassmateJsonFromJson(Map<String, dynamic> json) {
  return ClassmateJson(
    className: json['className'] as String,
    studentEnglishName: json['studentEnglishName'] as String,
    studentName: json['studentName'] as String,
    studentId: json['studentId'] as String,
    isSelect: json['isSelect'] as bool,
  );
}

Map<String, dynamic> _$ClassmateJsonToJson(ClassmateJson instance) =>
    <String, dynamic>{
      'className': instance.className,
      'studentEnglishName': instance.studentEnglishName,
      'studentName': instance.studentName,
      'studentId': instance.studentId,
      'isSelect': instance.isSelect,
    };
