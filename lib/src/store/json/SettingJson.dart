import 'package:flutter_app/src/store/JsonInit.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'CourseClassJson.dart';
part 'SettingJson.g.dart';

@JsonSerializable()
class SettingJson{
  CourseSettingJson course;
  OtherSettingJson other;
  AnnouncementSettingJson announcement;
  SettingJson( { this.course , this.other , this.announcement }) {
    course       =  course       ?? CourseSettingJson();
    other        =  other        ?? OtherSettingJson();
    announcement =  announcement ?? AnnouncementSettingJson();
  }

  @override
  String toString() {
    return sprintf(
        "course        :\n%s \n " +
        "other         :\n%s \n " +
        "announcement  :\n%s \n " ,
        [course.toString() , other.toString() , announcement.toString() ] );
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
    semester     = semester   ?? SemesterJson();
  }

  @override
  String toString() {
    return sprintf(
        "studentId      :%s   \n " +
        "semester       :\n%s \n " ,
        [studentId , semester.toString() ] );
  }

  factory CourseSettingJson.fromJson(Map<String, dynamic> json) => _$CourseSettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$CourseSettingJsonToJson(this);


}
@JsonSerializable()
class AnnouncementSettingJson{
  int page;
  int maxPage;
  AnnouncementSettingJson( { this.page , this.maxPage } ) {
    page    = page     ?? 0;
    maxPage = maxPage  ?? 0;
  }

  @override
  String toString() {
    return sprintf(
        "page      :%s \n " +
        "maxPage   :%s \n " ,
        [page.toString() , maxPage.toString() ] );
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

  @override
  String toString() {
    return sprintf(
        "lang      :%s \n " ,
        [ lang ] );
  }

  factory OtherSettingJson.fromJson(Map<String, dynamic> json) => _$OtherSettingJsonFromJson(json);
  Map<String, dynamic> toJson() => _$OtherSettingJsonToJson(this);


}