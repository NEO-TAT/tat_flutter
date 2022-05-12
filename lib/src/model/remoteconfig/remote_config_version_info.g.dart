// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_config_version_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteConfigVersionInfo _$RemoteConfigVersionInfoFromJson(Map<String, dynamic> json) {
  return RemoteConfigVersionInfo(
    last: json['last_version'] == null
        ? null
        : AndroidIosVersionInfo.fromJson(json['last_version'] as Map<String, dynamic>),
    lastVersionDetail: json['last_version_detail'] as String,
    isFocusUpdate: json['is_focus_update'] as bool,
  );
}

AndroidIosVersionInfo _$AndroidIosVersionInfoFromJson(Map<String, dynamic> json) {
  return AndroidIosVersionInfo(
    android: json['android'] as String,
    ios: json['ios'] as String,
  );
}
