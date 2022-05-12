// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingJson _$SettingJsonFromJson(Map<String, dynamic> json) {
  return SettingJson(
    course: json['course'] == null ? null : CourseSettingJson.fromJson(json['course'] as Map<String, dynamic>),
    other: json['other'] == null ? null : OtherSettingJson.fromJson(json['other'] as Map<String, dynamic>),
    announcement: json['announcement'] == null
        ? null
        : AnnouncementSettingJson.fromJson(json['announcement'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$SettingJsonToJson(SettingJson instance) => <String, dynamic>{
      'course': instance.course,
      'other': instance.other,
      'announcement': instance.announcement,
    };

CourseSettingJson _$CourseSettingJsonFromJson(Map<String, dynamic> json) {
  return CourseSettingJson(
    info: json['info'] == null ? null : CourseTableJson.fromJson(json['info'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$CourseSettingJsonToJson(CourseSettingJson instance) => <String, dynamic>{
      'info': instance.info,
    };

AnnouncementSettingJson _$AnnouncementSettingJsonFromJson(Map<String, dynamic> json) {
  return AnnouncementSettingJson(
    page: json['page'] as int,
    maxPage: json['maxPage'] as int,
  );
}

Map<String, dynamic> _$AnnouncementSettingJsonToJson(AnnouncementSettingJson instance) => <String, dynamic>{
      'page': instance.page,
      'maxPage': instance.maxPage,
    };

OtherSettingJson _$OtherSettingJsonFromJson(Map<String, dynamic> json) {
  return OtherSettingJson(
    lang: json['lang'] as String,
    autoCheckAppUpdate: json['autoCheckAppUpdate'] as bool,
    useExternalVideoPlayer: json['useExternalVideoPlayer'] as bool,
    checkIPlusNew: json['checkIPlusNew'] as bool,
  );
}

Map<String, dynamic> _$OtherSettingJsonToJson(OtherSettingJson instance) => <String, dynamic>{
      'lang': instance.lang,
      'autoCheckAppUpdate': instance.autoCheckAppUpdate,
      'useExternalVideoPlayer': instance.useExternalVideoPlayer,
      'checkIPlusNew': instance.checkIPlusNew,
    };
