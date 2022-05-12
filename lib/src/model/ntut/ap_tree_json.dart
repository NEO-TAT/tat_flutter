import 'package:json_annotation/json_annotation.dart';

part 'ap_tree_json.g.dart';

@JsonSerializable()
class APTreeJson {
  @JsonKey(name: 'apList')
  List<APListJson> apList;

  @JsonKey(name: 'parentDn')
  String parentDn;

  APTreeJson(this.apList, this.parentDn);

  factory APTreeJson.fromJson(Map<String, dynamic> srcJson) => _$APTreeJsonFromJson(srcJson);
}

@JsonSerializable()
class APListJson {
  @JsonKey(name: 'apDn')
  String apDn;
  @JsonKey(name: 'icon')
  String icon;
  @JsonKey(name: 'urlSource')
  String urlSource;
  @JsonKey(name: 'description')
  String description;
  @JsonKey(name: 'type')
  String type;
  @JsonKey(name: 'urlLink')
  String urlLink;

  APListJson(this.apDn, this.description, this.icon, this.type, this.urlLink, this.urlSource);

  factory APListJson.fromJson(Map<String, dynamic> srcJson) => _$APListJsonFromJson(srcJson);
}
