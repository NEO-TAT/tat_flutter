// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ap_tree_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

APTreeJson _$APTreeJsonFromJson(Map<String, dynamic> json) => APTreeJson(
      (json['apList'] as List<dynamic>)
          .map((e) => APListJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['parentDn'] as String,
    );

Map<String, dynamic> _$APTreeJsonToJson(APTreeJson instance) =>
    <String, dynamic>{
      'apList': instance.apList,
      'parentDn': instance.parentDn,
    };

APListJson _$APListJsonFromJson(Map<String, dynamic> json) => APListJson(
      json['apDn'] as String,
      json['description'] as String,
      json['icon'] as String,
      json['type'] as String,
      json['urlLink'] as String,
      json['urlSource'] as String,
    );

Map<String, dynamic> _$APListJsonToJson(APListJson instance) =>
    <String, dynamic>{
      'apDn': instance.apDn,
      'icon': instance.icon,
      'urlSource': instance.urlSource,
      'description': instance.description,
      'type': instance.type,
      'urlLink': instance.urlLink,
    };
