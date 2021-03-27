import 'package:flutter_app/src/model/course_table/course_table_json.dart';
import 'package:flutter_app/src/model/json_init.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'setting_json.g.dart';

@JsonSerializable()
class SettingJson {
  CourseSettingJson course;
  OtherSettingJson other;
  AnnouncementSettingJson announcement;

  SettingJson({this.course, this.other, this.announcement}) {
    course = course ?? CourseSettingJson();
    other = other ?? OtherSettingJson();
    announcement = announcement ?? AnnouncementSettingJson();
  }

  bool get isEmpty {
    return course.isEmpty && other.isEmpty && announcement.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "---------course--------        \n%s \n" +
            "---------other--------         \n%s \n" +
            "---------announcement--------  \n%s \n",
        [course.toString(), other.toString(), announcement.toString()]);
  }

  factory SettingJson.fromJson(Map<String, dynamic> json) =>
      _$SettingJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SettingJsonToJson(this);
}

@JsonSerializable()
class CourseSettingJson {
  CourseTableJson info;

  CourseSettingJson({this.info}) {
    info = info ?? CourseTableJson();
  }

  bool get isEmpty {
    return info.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "---------courseInfo--------       :\n%s \n", [info.toString()]);
  }

  factory CourseSettingJson.fromJson(Map<String, dynamic> json) =>
      _$CourseSettingJsonFromJson(json);

  Map<String, dynamic> toJson() => _$CourseSettingJsonToJson(this);
}

@JsonSerializable()
class AnnouncementSettingJson {
  int page;
  int maxPage;

  AnnouncementSettingJson({this.page, this.maxPage}) {
    page = page ?? 0;
    maxPage = maxPage ?? 0;
  }

  bool get isEmpty {
    return page == 0 && maxPage == 0;
  }

  @override
  String toString() {
    return sprintf("page      :%s \n " + "maxPage   :%s \n ",
        [page.toString(), maxPage.toString()]);
  }

  factory AnnouncementSettingJson.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementSettingJsonFromJson(json);

  Map<String, dynamic> toJson() => _$AnnouncementSettingJsonToJson(this);
}

@JsonSerializable()
class OtherSettingJson {
  String lang;
  bool autoCheckAppUpdate;
  bool useExternalVideoPlayer;
  bool checkIPlusNew;

  OtherSettingJson(
      {this.lang,
      this.autoCheckAppUpdate,
      this.useExternalVideoPlayer,
      this.checkIPlusNew}) {
    lang = JsonInit.stringInit(lang);
    autoCheckAppUpdate = autoCheckAppUpdate ?? true;
    useExternalVideoPlayer = useExternalVideoPlayer ?? false;
    checkIPlusNew = checkIPlusNew ?? true;
  }

  bool get isEmpty {
    return lang.isEmpty;
  }

  @override
  String toString() {
    return sprintf("lang      :%s \n ", [lang]);
  }

  factory OtherSettingJson.fromJson(Map<String, dynamic> json) =>
      _$OtherSettingJsonFromJson(json);

  Map<String, dynamic> toJson() => _$OtherSettingJsonToJson(this);
}
