// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/model/json_init.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'course_semester.g.dart';

@JsonSerializable()
class SemesterJson {
  String year;
  String semester;

  SemesterJson({this.year, this.semester}) {
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
  bool operator ==(dynamic other) {
    if (other is! SemesterJson) {
      return false;
    }

    final isSemesterSame = int.tryParse(other.semester) == int.tryParse(semester);
    final isYearSame = int.tryParse(other.year) == int.tryParse(year);

    return isSemesterSame && isYearSame;
  }

  @override
  int get hashCode => Object.hashAll([semester.hashCode, year.hashCode]);
}
