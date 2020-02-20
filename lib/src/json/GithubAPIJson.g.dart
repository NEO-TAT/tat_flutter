// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'GithubAPIJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubAPIJson _$GithubAPIJsonFromJson(Map<String, dynamic> json) {
  return GithubAPIJson(
    json['url'] as String,
    json['assets_url'] as String,
    json['upload_url'] as String,
    json['html_url'] as String,
    json['id'] as int,
    json['node_id'] as String,
    json['tag_name'] as String,
    json['target_commitish'] as String,
    json['name'] as String,
    json['draft'] as bool,
    json['author'] == null
        ? null
        : Author.fromJson(json['author'] as Map<String, dynamic>),
    json['prerelease'] as bool,
    json['created_at'] as String,
    json['published_at'] as String,
    (json['assets'] as List)
        ?.map((e) =>
            e == null ? null : Assets.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['tarball_url'] as String,
    json['zipball_url'] as String,
    json['body'] as String,
  );
}

Map<String, dynamic> _$GithubAPIJsonToJson(GithubAPIJson instance) =>
    <String, dynamic>{
      'url': instance.url,
      'assets_url': instance.assetsUrl,
      'upload_url': instance.uploadUrl,
      'html_url': instance.htmlUrl,
      'id': instance.id,
      'node_id': instance.nodeId,
      'tag_name': instance.tagName,
      'target_commitish': instance.targetCommitish,
      'name': instance.name,
      'draft': instance.draft,
      'author': instance.author,
      'prerelease': instance.prerelease,
      'created_at': instance.createdAt,
      'published_at': instance.publishedAt,
      'assets': instance.assets,
      'tarball_url': instance.tarballUrl,
      'zipball_url': instance.zipballUrl,
      'body': instance.body,
    };

Author _$AuthorFromJson(Map<String, dynamic> json) {
  return Author(
    json['login'] as String,
    json['id'] as int,
    json['node_id'] as String,
    json['avatar_url'] as String,
    json['gravatar_id'] as String,
    json['url'] as String,
    json['html_url'] as String,
    json['followers_url'] as String,
    json['following_url'] as String,
    json['gists_url'] as String,
    json['starred_url'] as String,
    json['subscriptions_url'] as String,
    json['organizations_url'] as String,
    json['repos_url'] as String,
    json['events_url'] as String,
    json['received_events_url'] as String,
    json['type'] as String,
    json['site_admin'] as bool,
  );
}

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
      'login': instance.login,
      'id': instance.id,
      'node_id': instance.nodeId,
      'avatar_url': instance.avatarUrl,
      'gravatar_id': instance.gravatarId,
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'followers_url': instance.followersUrl,
      'following_url': instance.followingUrl,
      'gists_url': instance.gistsUrl,
      'starred_url': instance.starredUrl,
      'subscriptions_url': instance.subscriptionsUrl,
      'organizations_url': instance.organizationsUrl,
      'repos_url': instance.reposUrl,
      'events_url': instance.eventsUrl,
      'received_events_url': instance.receivedEventsUrl,
      'type': instance.type,
      'site_admin': instance.siteAdmin,
    };

Assets _$AssetsFromJson(Map<String, dynamic> json) {
  return Assets(
    json['url'] as String,
    json['id'] as int,
    json['node_id'] as String,
    json['name'] as String,
    json['uploader'] == null
        ? null
        : Uploader.fromJson(json['uploader'] as Map<String, dynamic>),
    json['content_type'] as String,
    json['state'] as String,
    json['size'] as int,
    json['download_count'] as int,
    json['created_at'] as String,
    json['updated_at'] as String,
    json['browser_download_url'] as String,
  );
}

Map<String, dynamic> _$AssetsToJson(Assets instance) => <String, dynamic>{
      'url': instance.url,
      'id': instance.id,
      'node_id': instance.nodeId,
      'name': instance.name,
      'uploader': instance.uploader,
      'content_type': instance.contentType,
      'state': instance.state,
      'size': instance.size,
      'download_count': instance.downloadCount,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'browser_download_url': instance.browserDownloadUrl,
    };

Uploader _$UploaderFromJson(Map<String, dynamic> json) {
  return Uploader(
    json['login'] as String,
    json['id'] as int,
    json['node_id'] as String,
    json['avatar_url'] as String,
    json['gravatar_id'] as String,
    json['url'] as String,
    json['html_url'] as String,
    json['followers_url'] as String,
    json['following_url'] as String,
    json['gists_url'] as String,
    json['starred_url'] as String,
    json['subscriptions_url'] as String,
    json['organizations_url'] as String,
    json['repos_url'] as String,
    json['events_url'] as String,
    json['received_events_url'] as String,
    json['type'] as String,
    json['site_admin'] as bool,
  );
}

Map<String, dynamic> _$UploaderToJson(Uploader instance) => <String, dynamic>{
      'login': instance.login,
      'id': instance.id,
      'node_id': instance.nodeId,
      'avatar_url': instance.avatarUrl,
      'gravatar_id': instance.gravatarId,
      'url': instance.url,
      'html_url': instance.htmlUrl,
      'followers_url': instance.followersUrl,
      'following_url': instance.followingUrl,
      'gists_url': instance.gistsUrl,
      'starred_url': instance.starredUrl,
      'subscriptions_url': instance.subscriptionsUrl,
      'organizations_url': instance.organizationsUrl,
      'repos_url': instance.reposUrl,
      'events_url': instance.eventsUrl,
      'received_events_url': instance.receivedEventsUrl,
      'type': instance.type,
      'site_admin': instance.siteAdmin,
    };
