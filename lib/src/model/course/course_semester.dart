import 'package:equatable/equatable.dart';
import 'package:flutter_app/src/model/json_init.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'course_semester.g.dart';

@JsonSerializable()
class SemesterJson with EquatableMixin {
  String year;
  String semester;

  SemesterJson({required this.year, required this.semester}) {
    year = JsonInit.stringInit(year);
    semester = JsonInit.stringInit(semester);
  }

  factory SemesterJson.fromJson(Map<String, dynamic> json) => _$SemesterJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SemesterJsonToJson(this);

  bool get isEmpty {
    return year.isEmpty && semester.isEmpty;
  }

  @override
  String toString() {
    return sprintf("year     : %s \n" "semester : %s \n", [year, semester]);
  }

  @override
  List<Object?> get props => [
    year,
    semester
  ];
}
