// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseDetailJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseDetailJson _$CourseDetailJsonFromJson(Map<String, dynamic> json) {
  return CourseDetailJson(
    courseName: json['courseName'] as String,
    courseId: json['courseId'] as String,
    courseHref: json['courseHref'] as String,
    teacherName:
        (json['teacherName'] as List)?.map((e) => e as String)?.toList(),
    courseTime: (json['courseTime'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : CourseTimeJson.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
  )..courseSemester = json['courseSemester'] == null
      ? null
      : CourseSemesterJson.fromJson(
          json['courseSemester'] as Map<String, dynamic>);
}

Map<String, dynamic> _$CourseDetailJsonToJson(CourseDetailJson instance) =>
    <String, dynamic>{
      'courseName': instance.courseName,
      'courseId': instance.courseId,
      'courseHref': instance.courseHref,
      'teacherName': instance.teacherName,
      'courseSemester': instance.courseSemester,
      'courseTime': instance.courseTime,
    };

CourseTimeJson _$CourseTimeJsonFromJson(Map<String, dynamic> json) {
  return CourseTimeJson(
    time: json['time'] as String,
    classroom: json['classroom'] == null
        ? null
        : CourseClassroomJson.fromJson(
            json['classroom'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CourseTimeJsonToJson(CourseTimeJson instance) =>
    <String, dynamic>{
      'time': instance.time,
      'classroom': instance.classroom,
    };

CourseClassroomJson _$CourseClassroomJsonFromJson(Map<String, dynamic> json) {
  return CourseClassroomJson(
    name: json['name'] as String,
    href: json['href'] as String,
  );
}

Map<String, dynamic> _$CourseClassroomJsonToJson(
        CourseClassroomJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
    };

CourseSemesterJson _$CourseSemesterJsonFromJson(Map<String, dynamic> json) {
  return CourseSemesterJson(
    year: json['year'] as String,
    semester: json['semester'] as String,
  );
}

Map<String, dynamic> _$CourseSemesterJsonToJson(CourseSemesterJson instance) =>
    <String, dynamic>{
      'year': instance.year,
      'semester': instance.semester,
    };
