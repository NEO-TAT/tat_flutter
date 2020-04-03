// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CourseClassJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseMainJson _$CourseMainJsonFromJson(Map<String, dynamic> json) {
  return CourseMainJson(
    name: json['name'] as String,
    href: json['href'] as String,
    id: json['id'] as String,
    credits: json['credits'] as String,
    hours: json['hours'] as String,
    stage: json['stage'] as String,
    note: json['note'] as String,
    time: (json['time'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(_$enumDecodeNullable(_$DayEnumMap, k), e as String),
    ),
    scheduleHref: json['scheduleHref'] as String,
  );
}

Map<String, dynamic> _$CourseMainJsonToJson(CourseMainJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'href': instance.href,
      'note': instance.note,
      'stage': instance.stage,
      'credits': instance.credits,
      'hours': instance.hours,
      'scheduleHref': instance.scheduleHref,
      'time': instance.time?.map((k, e) => MapEntry(_$DayEnumMap[k], e)),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$DayEnumMap = {
  Day.Monday: 'Monday',
  Day.Tuesday: 'Tuesday',
  Day.Wednesday: 'Wednesday',
  Day.Thursday: 'Thursday',
  Day.Friday: 'Friday',
  Day.Saturday: 'Saturday',
  Day.Sunday: 'Sunday',
  Day.UnKnown: 'UnKnown',
};

CourseExtraJson _$CourseExtraJsonFromJson(Map<String, dynamic> json) {
  return CourseExtraJson(
    name: json['name'] as String,
    category: json['category'] as String,
    selectNumber: json['selectNumber'] as String,
    withdrawNumber: json['withdrawNumber'] as String,
    href: json['href'] as String,
  )
    ..id = json['id'] as String
    ..openClass = json['openClass'] as String;
}

Map<String, dynamic> _$CourseExtraJsonToJson(CourseExtraJson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'href': instance.href,
      'category': instance.category,
      'selectNumber': instance.selectNumber,
      'withdrawNumber': instance.withdrawNumber,
      'openClass': instance.openClass,
    };

ClassJson _$ClassJsonFromJson(Map<String, dynamic> json) {
  return ClassJson(
    name: json['name'] as String,
    href: json['href'] as String,
  );
}

Map<String, dynamic> _$ClassJsonToJson(ClassJson instance) => <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
    };

ClassroomJson _$ClassroomJsonFromJson(Map<String, dynamic> json) {
  return ClassroomJson(
    name: json['name'] as String,
    href: json['href'] as String,
    mainUse: json['mainUse'] as bool,
  );
}

Map<String, dynamic> _$ClassroomJsonToJson(ClassroomJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
      'mainUse': instance.mainUse,
    };

TeacherJson _$TeacherJsonFromJson(Map<String, dynamic> json) {
  return TeacherJson(
    name: json['name'] as String,
    href: json['href'] as String,
  );
}

Map<String, dynamic> _$TeacherJsonToJson(TeacherJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
    };

SemesterJson _$SemesterJsonFromJson(Map<String, dynamic> json) {
  return SemesterJson(
    year: json['year'] as String,
    semester: json['semester'] as String,
  );
}

Map<String, dynamic> _$SemesterJsonToJson(SemesterJson instance) =>
    <String, dynamic>{
      'year': instance.year,
      'semester': instance.semester,
    };

ClassmateJson _$ClassmateJsonFromJson(Map<String, dynamic> json) {
  return ClassmateJson(
    className: json['className'] as String,
    studentEnglishName: json['studentEnglishName'] as String,
    studentName: json['studentName'] as String,
    studentId: json['studentId'] as String,
    isSelect: json['isSelect'] as bool,
    href: json['href'] as String,
  );
}

Map<String, dynamic> _$ClassmateJsonToJson(ClassmateJson instance) =>
    <String, dynamic>{
      'className': instance.className,
      'studentEnglishName': instance.studentEnglishName,
      'studentName': instance.studentName,
      'studentId': instance.studentId,
      'href': instance.href,
      'isSelect': instance.isSelect,
    };
