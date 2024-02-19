// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_period.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoursePeriod _$CoursePeriodFromJson(Map<String, dynamic> json) => CoursePeriod(
      weekday: json['weekday'] as int,
      period: json['period'] as String,
    );

Map<String, dynamic> _$CoursePeriodToJson(CoursePeriod instance) => <String, dynamic>{
      'weekday': instance.weekday,
      'period': instance.period,
    };
