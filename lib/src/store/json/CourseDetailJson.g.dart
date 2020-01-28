// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseDetailJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseDetail _$CourseDetailFromJson(Map<String, dynamic> json) {
  return CourseDetail(
    courseName: json['courseName'] as String,
    courseId: json['courseId'] as String,
    courseHref: json['courseHref'] as String,
    teacherName:
        (json['teacherName'] as List)?.map((e) => e as String)?.toList(),
    courseTime: (json['courseTime'] as List)
        ?.map((e) => (e as List)
            ?.map((e) => e == null
                ? null
                : CourseTime.fromJson(e as Map<String, dynamic>))
            ?.toList())
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseDetailToJson(CourseDetail instance) =>
    <String, dynamic>{
      'courseName': instance.courseName,
      'courseId': instance.courseId,
      'courseHref': instance.courseHref,
      'teacherName': instance.teacherName,
      'courseTime': instance.courseTime,
    };

CourseTime _$CourseTimeFromJson(Map<String, dynamic> json) {
  return CourseTime(
    time: json['time'] as String,
    classroom: json['classroom'] == null
        ? null
        : CourseClassroom.fromJson(json['classroom'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CourseTimeToJson(CourseTime instance) =>
    <String, dynamic>{
      'time': instance.time,
      'classroom': instance.classroom,
    };

CourseClassroom _$CourseClassroomFromJson(Map<String, dynamic> json) {
  return CourseClassroom(
    name: json['name'] as String,
    href: json['href'] as String,
  );
}

Map<String, dynamic> _$CourseClassroomToJson(CourseClassroom instance) =>
    <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
    };
