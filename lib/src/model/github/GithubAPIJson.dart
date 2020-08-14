import 'package:json_annotation/json_annotation.dart';

part 'GithubAPIJson.g.dart';

@JsonSerializable()
class GithubAPIJson {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'assets_url')
  String assetsUrl;

  @JsonKey(name: 'upload_url')
  String uploadUrl;

  @JsonKey(name: 'html_url')
  String htmlUrl;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'tag_name')
  String tagName;

  @JsonKey(name: 'target_commitish')
  String targetCommitish;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'draft')
  bool draft;

  @JsonKey(name: 'author')
  Author author;

  @JsonKey(name: 'prerelease')
  bool prerelease;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'published_at')
  String publishedAt;

  @JsonKey(name: 'assets')
  List<Assets> assets;

  @JsonKey(name: 'tarball_url')
  String tarballUrl;

  @JsonKey(name: 'zipball_url')
  String zipballUrl;

  @JsonKey(name: 'body')
  String body;

  GithubAPIJson(
    this.url,
    this.assetsUrl,
    this.uploadUrl,
    this.htmlUrl,
    this.id,
    this.nodeId,
    this.tagName,
    this.targetCommitish,
    this.name,
    this.draft,
    this.author,
    this.prerelease,
    this.createdAt,
    this.publishedAt,
    this.assets,
    this.tarballUrl,
    this.zipballUrl,
    this.body,
  );

  factory GithubAPIJson.fromJson(Map<String, dynamic> srcJson) =>
      _$GithubAPIJsonFromJson(srcJson);
}

@JsonSerializable()
class Author {
  @JsonKey(name: 'login')
  String login;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'avatar_url')
  String avatarUrl;

  @JsonKey(name: 'gravatar_id')
  String gravatarId;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'html_url')
  String htmlUrl;

  @JsonKey(name: 'followers_url')
  String followersUrl;

  @JsonKey(name: 'following_url')
  String followingUrl;

  @JsonKey(name: 'gists_url')
  String gistsUrl;

  @JsonKey(name: 'starred_url')
  String starredUrl;

  @JsonKey(name: 'subscriptions_url')
  String subscriptionsUrl;

  @JsonKey(name: 'organizations_url')
  String organizationsUrl;

  @JsonKey(name: 'repos_url')
  String reposUrl;

  @JsonKey(name: 'events_url')
  String eventsUrl;

  @JsonKey(name: 'received_events_url')
  String receivedEventsUrl;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'site_admin')
  bool siteAdmin;

  Author(
    this.login,
    this.id,
    this.nodeId,
    this.avatarUrl,
    this.gravatarId,
    this.url,
    this.htmlUrl,
    this.followersUrl,
    this.followingUrl,
    this.gistsUrl,
    this.starredUrl,
    this.subscriptionsUrl,
    this.organizationsUrl,
    this.reposUrl,
    this.eventsUrl,
    this.receivedEventsUrl,
    this.type,
    this.siteAdmin,
  );

  factory Author.fromJson(Map<String, dynamic> srcJson) =>
      _$AuthorFromJson(srcJson);
}

@JsonSerializable()
class Assets {
  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'uploader')
  Uploader uploader;

  @JsonKey(name: 'content_type')
  String contentType;

  @JsonKey(name: 'state')
  String state;

  @JsonKey(name: 'size')
  int size;

  @JsonKey(name: 'download_count')
  int downloadCount;

  @JsonKey(name: 'created_at')
  String createdAt;

  @JsonKey(name: 'updated_at')
  String updatedAt;

  @JsonKey(name: 'browser_download_url')
  String browserDownloadUrl;

  Assets(
    this.url,
    this.id,
    this.nodeId,
    this.name,
    this.uploader,
    this.contentType,
    this.state,
    this.size,
    this.downloadCount,
    this.createdAt,
    this.updatedAt,
    this.browserDownloadUrl,
  );

  factory Assets.fromJson(Map<String, dynamic> srcJson) =>
      _$AssetsFromJson(srcJson);
}

@JsonSerializable()
class Uploader {
  @JsonKey(name: 'login')
  String login;

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'node_id')
  String nodeId;

  @JsonKey(name: 'avatar_url')
  String avatarUrl;

  @JsonKey(name: 'gravatar_id')
  String gravatarId;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'html_url')
  String htmlUrl;

  @JsonKey(name: 'followers_url')
  String followersUrl;

  @JsonKey(name: 'following_url')
  String followingUrl;

  @JsonKey(name: 'gists_url')
  String gistsUrl;

  @JsonKey(name: 'starred_url')
  String starredUrl;

  @JsonKey(name: 'subscriptions_url')
  String subscriptionsUrl;

  @JsonKey(name: 'organizations_url')
  String organizationsUrl;

  @JsonKey(name: 'repos_url')
  String reposUrl;

  @JsonKey(name: 'events_url')
  String eventsUrl;

  @JsonKey(name: 'received_events_url')
  String receivedEventsUrl;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: 'site_admin')
  bool siteAdmin;

  Uploader(
    this.login,
    this.id,
    this.nodeId,
    this.avatarUrl,
    this.gravatarId,
    this.url,
    this.htmlUrl,
    this.followersUrl,
    this.followingUrl,
    this.gistsUrl,
    this.starredUrl,
    this.subscriptionsUrl,
    this.organizationsUrl,
    this.reposUrl,
    this.eventsUrl,
    this.receivedEventsUrl,
    this.type,
    this.siteAdmin,
  );

  factory Uploader.fromJson(Map<String, dynamic> srcJson) =>
      _$UploaderFromJson(srcJson);
}
