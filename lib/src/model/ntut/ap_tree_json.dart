import 'package:json_annotation/json_annotation.dart';

part 'ap_tree_json.g.dart';

@JsonSerializable()
class APTreeJson {
  @JsonKey(name: 'apList')
  late final List<APListJson> apList;

  @JsonKey(name: 'parentDn')
  late final String parentDn;

  APTreeJson(this.apList, this.parentDn);

  factory APTreeJson.fromJson(Map<String, dynamic> srcJson) =>
      _$APTreeJsonFromJson(srcJson);
}

@JsonSerializable()
class APListJson {
  @JsonKey(name: 'apDn')
  late final String apDn;
  @JsonKey(name: 'icon')
  late final String icon;
  @JsonKey(name: 'urlSource')
  late final String urlSource;
  @JsonKey(name: 'description')
  late final String description;
  @JsonKey(name: 'type')
  late final String type;
  @JsonKey(name: 'urlLink')
  late final String urlLink;

  APListJson(
    this.apDn,
    this.description,
    this.icon,
    this.type,
    this.urlLink,
    this.urlSource,
  );

  factory APListJson.fromJson(Map<String, dynamic> srcJson) =>
      _$APListJsonFromJson(srcJson);
}
