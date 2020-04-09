import 'package:json_annotation/json_annotation.dart';

part 'GithubFileAPIJson.g.dart';

List<GithubFileAPIJson> getGithubFileAPIJsonList(List<dynamic> list) {
  List<GithubFileAPIJson> result = [];
  list.forEach((item) {
    result.add(GithubFileAPIJson.fromJson(item));
  });
  return result;
}

@JsonSerializable()
class GithubFileAPIJson {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'path')
  String path;

  @JsonKey(name: 'sha')
  String sha;

  @JsonKey(name: 'size')
  int size;

  @JsonKey(name: 'url')
  String url;

  @JsonKey(name: 'html_url')
  String htmlUrl;

  @JsonKey(name: 'git_url')
  String gitUrl;

  @JsonKey(name: 'download_url')
  String downloadUrl;

  @JsonKey(name: 'type')
  String type;

  @JsonKey(name: '_links')
  _links links;

  GithubFileAPIJson(
    this.name,
    this.path,
    this.sha,
    this.size,
    this.url,
    this.htmlUrl,
    this.gitUrl,
    this.downloadUrl,
    this.type,
    this.links,
  );

  factory GithubFileAPIJson.fromJson(Map<String, dynamic> srcJson) =>
      _$GithubFileAPIJsonFromJson(srcJson);
}

@JsonSerializable()
class _links {
  @JsonKey(name: 'self')
  String self;

  @JsonKey(name: 'git')
  String git;

  @JsonKey(name: 'html')
  String html;

  _links(
    this.self,
    this.git,
    this.html,
  );

  factory _links.fromJson(Map<String, dynamic> srcJson) =>
      _$_linksFromJson(srcJson);
}
