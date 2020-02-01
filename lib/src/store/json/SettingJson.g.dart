// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SettingJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingJson _$SettingJsonFromJson(Map<String, dynamic> json) {
  return SettingJson(
    course: json['course'] == null
        ? null
        : CourseSettingJson.fromJson(json['course'] as Map<String, dynamic>),
    other: json['other'] == null
        ? null
        : OtherSettingJson.fromJson(json['other'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SettingJsonToJson(SettingJson instance) =>
    <String, dynamic>{
      'course': instance.course,
      'other': instance.other,
    };

CourseSettingJson _$CourseSettingJsonFromJson(Map<String, dynamic> json) {
  return CourseSettingJson(
    studentId: json['studentId'] as String,
    semester: json['semester'] == null
        ? null
        : SemesterJson.fromJson(json['semester'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CourseSettingJsonToJson(CourseSettingJson instance) =>
    <String, dynamic>{
      'studentId': instance.studentId,
      'semester': instance.semester,
    };

OtherSettingJson _$OtherSettingJsonFromJson(Map<String, dynamic> json) {
  return OtherSettingJson(
    lang: json['lang'] as String,
  );
}

Map<String, dynamic> _$OtherSettingJsonToJson(OtherSettingJson instance) =>
    <String, dynamic>{
      'lang': instance.lang,
    };
