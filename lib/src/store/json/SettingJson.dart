import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:json_annotation/json_annotation.dart';

part 'SettingJson.g.dart';

@JsonSerializable()
class SettingJson{
  CourseSettingJson course;
  OtherSettingJson other;
  AnnouncementSettingJson announcement;
  SettingJson( { this.course , this.other , this.announcement }) {
    course       = (course       != null) ? course       : CourseSettingJson();
    other        = (other        != null) ? other        : OtherSettingJson();
    announcement = (announcement != null )? announcement : AnnouncementSettingJson();
  }

  factory SettingJson.fromJson(Map<String, dynamic> json) => _$SettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$SettingJsonToJson(this);

}

@JsonSerializable()
class CourseSettingJson{
  String studentId;
  SemesterJson semester;

  CourseSettingJson( { this.studentId , this.semester }) {
    studentId    = JsonInit.stringInit(studentId);
    semester     = (semester     != null )? semester     : SemesterJson();
  }

  factory CourseSettingJson.fromJson(Map<String, dynamic> json) => _$CourseSettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseSettingJsonToJson(this);


}
@JsonSerializable()
class AnnouncementSettingJson{
  int page;
  AnnouncementSettingJson( { this.page}) {
    page    = (page != null) ? page : 0;
  }


  factory AnnouncementSettingJson.fromJson(Map<String, dynamic> json) => _$AnnouncementSettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$AnnouncementSettingJsonToJson(this);
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