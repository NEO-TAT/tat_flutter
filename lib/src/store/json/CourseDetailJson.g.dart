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
        ?.map((e) =>
            e == null ? null : SemesterJson.fromJson(e as Map<String, dynamic>))
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
        : SemesterJson.fromJson(json['courseSemester'] as Map<String, dynamic>),
    courseDetailMap: (json['courseDetailMap'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          _$enumDecodeNullable(_$DayEnumMap, k),
          (e as Map<String, dynamic>)?.map(
            (k, e) => MapEntry(
                _$enumDecodeNullable(_$SectionNumberEnumMap, k),
                e == null
                    ? null
                    : CourseTableDetailJson.fromJson(
                        e as Map<String, dynamic>)),
          )),
    ),
  );
}

Map<String, dynamic> _$CourseTableJsonToJson(CourseTableJson instance) =>
    <String, dynamic>{
      'courseSemester': instance.courseSemester,
      'courseDetailMap': instance.courseDetailMap?.map((k, e) => MapEntry(
          _$DayEnumMap[k],
          e?.map((k, e) => MapEntry(_$SectionNumberEnumMap[k], e)))),
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

const _$SectionNumberEnumMap = {
  SectionNumber.T_1: 'T_1',
  SectionNumber.T_2: 'T_2',
  SectionNumber.T_3: 'T_3',
  SectionNumber.T_4: 'T_4',
  SectionNumber.T_N: 'T_N',
  SectionNumber.T_5: 'T_5',
  SectionNumber.T_6: 'T_6',
  SectionNumber.T_7: 'T_7',
  SectionNumber.T_8: 'T_8',
  SectionNumber.T_9: 'T_9',
  SectionNumber.T_A: 'T_A',
  SectionNumber.T_B: 'T_B',
  SectionNumber.T_C: 'T_C',
  SectionNumber.T_D: 'T_D',
  SectionNumber.T_UnKnown: 'T_UnKnown',
};

const _$DayEnumMap = {
  Day.Sunday: 'Sunday',
  Day.Monday: 'Monday',
  Day.Tuesday: 'Tuesday',
  Day.Wednesday: 'Wednesday',
  Day.Thursday: 'Thursday',
  Day.Friday: 'Friday',
  Day.Saturday: 'Saturday',
  Day.UnKnown: 'UnKnown',
};

CourseTableDetailJson _$CourseTableDetailJsonFromJson(
    Map<String, dynamic> json) {
  return CourseTableDetailJson(
    course: json['course'] == null
        ? null
        : CourseJson.fromJson(json['course'] as Map<String, dynamic>),
    classroom: json['classroom'] == null
        ? null
        : ClassroomJson.fromJson(json['classroom'] as Map<String, dynamic>),
    teacher: (json['teacher'] as List)
        ?.map((e) =>
            e == null ? null : TeacherJson.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$CourseTableDetailJsonToJson(
        CourseTableDetailJson instance) =>
    <String, dynamic>{
      'course': instance.course,
      'classroom': instance.classroom,
      'teacher': instance.teacher,
    };

CourseJson _$CourseJsonFromJson(Map<String, dynamic> json) {
  return CourseJson(
    name: json['name'] as String,
    href: json['href'] as String,
    id: json['id'] as String,
  );
}

Map<String, dynamic> _$CourseJsonToJson(CourseJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'href': instance.href,
    };

ClassroomJson _$ClassroomJsonFromJson(Map<String, dynamic> json) {
  return ClassroomJson(
    name: json['name'] as String,
    href: json['href'] as String,
  );
}

Map<String, dynamic> _$ClassroomJsonToJson(ClassroomJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'href': instance.href,
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
