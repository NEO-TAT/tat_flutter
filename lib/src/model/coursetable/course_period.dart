import 'package:json_annotation/json_annotation.dart';

part 'course_period.g.dart';

@JsonSerializable()
class CoursePeriod {
  final int weekday;
  final String period;

  CoursePeriod({required this.weekday, required this.period});

  factory CoursePeriod.fromJson(Map<String, dynamic> json) => _$CoursePeriodFromJson(json);

  Map<String, dynamic> toJson() => _$CoursePeriodToJson(this);
}
