import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:json_annotation/json_annotation.dart';

part 'SettingJson.g.dart';

@JsonSerializable()
class SettingJson{
  CourseSettingJson course;
  OtherSettingJson other;

  SettingJson( { this.course , this.other }) {
    course    = (course    != null) ? course    : CourseSettingJson();
    other     = (other     != null) ? other     : OtherSettingJson();
  }

  factory SettingJson.fromJson(Map<String, dynamic> json) => _$SettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$SettingJsonToJson(this);

}

@JsonSerializable()
class CourseSettingJson{
  String studentId;
  SemesterJson semester;

  CourseSettingJson( { this.studentId , this.semester }) {
    studentId = JsonInit.stringInit(studentId);
    semester  = (semester     != null) ? semester     : SemesterJson();
  }

  factory CourseSettingJson.fromJson(Map<String, dynamic> json) => _$CourseSettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseSettingJsonToJson(this);


}

@JsonSerializable()
class OtherSettingJson{
  String lang;

  OtherSettingJson( { this.lang }) {
    lang = JsonInit.stringInit(lang);
  }

  factory OtherSettingJson.fromJson(Map<String, dynamic> json) => _$OtherSettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$OtherSettingJsonToJson(this);


}