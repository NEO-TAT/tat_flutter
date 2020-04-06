// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GithubFileAPIJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubFileAPIJson _$GithubFileAPIJsonFromJson(Map<String, dynamic> json) {
  return GithubFileAPIJson(
    json['name'] as String,
    json['path'] as String,
    json['sha'] as String,
    json['size'] as int,
    json['url'] as String,
    json['html_url'] as String,
    json['git_url'] as String,
    json['download_url'] as String,
    json['type'] as String,
    json['_links'] == null
        ? null
        : _links.fromJson(json['_links'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$GithubFileAPIJsonToJson(GithubFileAPIJson instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'sha': instance.sha,
      'size': instance.size,
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'git_url': instance.gitUrl,
      'download_url': instance.downloadUrl,
      'type': instance.type,
      '_links': instance.links,
    };

_links _$_linksFromJson(Map<String, dynamic> json) {
  return _links(
    json['self'] as String,
    json['git'] as String,
    json['html'] as String,
  );
}

Map<String, dynamic> _$_linksToJson(_links instance) => <String, dynamic>{
      'self': instance.self,
      'git': instance.git,
      'html': instance.html,
    };
