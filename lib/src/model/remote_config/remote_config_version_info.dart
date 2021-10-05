import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'remote_config_version_info.g.dart';

@JsonSerializable()
class RemoteConfigVersionInfo {
  @JsonKey(name: "is_focus_update")
  late final bool? isFocusUpdate;

  @JsonKey(name: "last_version")
  late final AndroidIosVersionInfo? last;

  @JsonKey(name: "last_version_detail")
  late final String lastVersionDetail;

  RemoteConfigVersionInfo({
    this.last,
    this.lastVersionDetail = '',
    this.isFocusUpdate,
  });

  factory RemoteConfigVersionInfo.fromJson(Map<String, dynamic> srcJson) =>
      _$RemoteConfigVersionInfoFromJson(srcJson);
}

@JsonSerializable()
class AndroidIosVersionInfo {
  @JsonKey(name: "android")
  late final String android;

  @JsonKey(name: "ios")
  late final String ios;

  AndroidIosVersionInfo({this.android = '', this.ios = ''});

  factory AndroidIosVersionInfo.fromJson(Map<String, dynamic> srcJson) =>
      _$AndroidIosVersionInfoFromJson(srcJson);

  String get version {
    return (Platform.isIOS) ? ios : android;
  }
}
