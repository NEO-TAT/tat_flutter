// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'RemoteConfigVersionInfo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RemoteConfigVersionInfo _$RemoteConfigVersionInfoFromJson(
    Map<String, dynamic> json) {
  return RemoteConfigVersionInfo(
    lastVersion: json['last_version'] as String,
    lastVersionDetail: json['last_version_detail'] as String,
    isFocusUpdate: json['is_focus_update'] as bool,
  );
}

Map<String, dynamic> _$RemoteConfigVersionInfoToJson(
        RemoteConfigVersionInfo instance) =>
    <String, dynamic>{
      'is_focus_update': instance.isFocusUpdate,
      'last_version': instance.lastVersion,
      'last_version_detail': instance.lastVersionDetail,
    };
