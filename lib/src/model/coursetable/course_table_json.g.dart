// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_table_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseTableJson _$CourseTableJsonFromJson(Map<String, dynamic> json) {
  return CourseTableJson(
    courseSemester:
        json['courseSemester'] == null ? null : SemesterJson.fromJson(json['courseSemester'] as Map<String, dynamic>),
    courseInfoMap: (json['courseInfoMap'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          _$enumDecodeNullable(_$DayEnumMap, k),
          (e as Map<String, dynamic>)?.map(
            (k, e) => MapEntry(_$enumDecodeNullable(_$SectionNumberEnumMap, k),
                e == null ? null : CourseInfoJson.fromJson(e as Map<String, dynamic>)),
          )),
    ),
    studentId: json['studentId'] as String,
    studentName: json['studentName'] as String,
  );
}

Map<String, dynamic> _$CourseTableJsonToJson(CourseTableJson instance) => <String, dynamic>{
      'courseSemester': instance.courseSemester,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'courseInfoMap': instance.courseInfoMap
          ?.map((k, e) => MapEntry(_$DayEnumMap[k], e?.map((k, e) => MapEntry(_$SectionNumberEnumMap[k], e)))),
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

  final value = enumValues.entries.singleWhere((e) => e.value == source, orElse: () => null)?.key;

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
  Day.Monday: 'Monday',
  Day.Tuesday: 'Tuesday',
  Day.Wednesday: 'Wednesday',
  Day.Thursday: 'Thursday',
  Day.Friday: 'Friday',
  Day.Saturday: 'Saturday',
  Day.Sunday: 'Sunday',
  Day.UnKnown: 'UnKnown',
};

CourseInfoJson _$CourseInfoJsonFromJson(Map<String, dynamic> json) {
  return CourseInfoJson(
    main: json['main'] == null ? null : CourseMainInfoJson.fromJson(json['main'] as Map<String, dynamic>),
    extra: json['extra'] == null ? null : CourseExtraInfoJson.fromJson(json['extra'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CourseInfoJsonToJson(CourseInfoJson instance) => <String, dynamic>{
      'main': instance.main,
      'extra': instance.extra,
    };
