import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';

part 'setting_json.g.dart';

@JsonSerializable()
class SettingJson {
  CourseSettingJson? course = CourseSettingJson();
  OtherSettingJson? other = OtherSettingJson();
  AnnouncementSettingJson? announcement = AnnouncementSettingJson();

  SettingJson({this.course, this.other, this.announcement});

  bool get isEmpty =>
      course!.isEmpty && other!.isEmpty && announcement!.isEmpty;

  @override
  String toString() {
    return sprintf(
      "---------course--------        \n%s \n" +
          "---------other--------         \n%s \n" +
          "---------announcement--------  \n%s \n",
      [
        course.toString(),
        other.toString(),
        announcement.toString(),
      ],
    );
  }

  factory SettingJson.fromJson(Map<String, dynamic> json) =>
      _$SettingJsonFromJson(json);

  Map<String, dynamic> toJson() => _$SettingJsonToJson(this);
}

@JsonSerializable()
class CourseSettingJson {
  CourseTableJson? info = CourseTableJson();

  CourseSettingJson({this.info});

  bool get isEmpty => info!.isEmpty;

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
  final int page;
  final int maxPage;

  AnnouncementSettingJson({this.page = 0, this.maxPage = 0});

  bool get isEmpty => page == 0 && maxPage == 0;

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
  late final String lang;
  late final bool autoCheckAppUpdate;
  late final bool useExternalVideoPlayer;
  late final bool checkIPlusNew;

  OtherSettingJson({
    this.lang = '',
    this.autoCheckAppUpdate = true,
    this.useExternalVideoPlayer = false,
    this.checkIPlusNew = true,
  });

  bool get isEmpty => lang.isEmpty;

  @override
  String toString() {
    return sprintf("lang      :%s \n ", [lang]);
  }

  factory OtherSettingJson.fromJson(Map<String, dynamic> json) =>
      _$OtherSettingJsonFromJson(json);

  Map<String, dynamic> toJson() => _$OtherSettingJsonToJson(this);
}
