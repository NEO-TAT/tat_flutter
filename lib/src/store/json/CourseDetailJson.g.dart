// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseDetailJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseTableJsonList _$CourseTableJsonListFromJson(Map<String, dynamic> json) {
  return CourseTableJsonList(
    courseTableList: (json['courseTableList'] as List)
        ?.map((e) => e == null
            ? null
            : CourseTableJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseTableJsonListToJson(
        CourseTableJsonList instance) =>
    <String, dynamic>{
      'courseTableList': instance.courseTableList,
    };

CourseSemesterJsonList _$CourseSemesterJsonListFromJson(
    Map<String, dynamic> json) {
  return CourseSemesterJsonList(
    courseSemesterList: (json['courseSemesterList'] as List)
        ?.map((e) => e == null
            ? null
            : CourseSemesterJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseSemesterJsonListToJson(
        CourseSemesterJsonList instance) =>
    <String, dynamic>{
      'courseSemesterList': instance.courseSemesterList,
    };

CourseTableJson _$CourseTableJsonFromJson(Map<String, dynamic> json) {
  return CourseTableJson(
    courseSemester: json['courseSemester'] == null
        ? null
        : CourseSemesterJson.fromJson(
            json['courseSemester'] as Map<String, dynamic>),
    courseDetail: (json['courseDetail'] as List)
        ?.map((e) => e == null
            ? null
            : CourseDetailJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseTableJsonToJson(CourseTableJson instance) =>
    <String, dynamic>{
      'courseSemester': instance.courseSemester,
      'courseDetail': instance.courseDetail,
    };

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
  );
}

Map<String, dynamic> _$CourseDetailJsonToJson(CourseDetailJson instance) =>
    <String, dynamic>{
      'courseName': instance.courseName,
      'courseId': instance.courseId,
      'courseHref': instance.courseHref,
      'teacherName': instance.teacherName,
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
