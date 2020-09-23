import 'package:json_annotation/json_annotation.dart';
part 'RemoteConfigVersionInfo.g.dart';

@JsonSerializable()
class RemoteConfigVersionInfo {
  @JsonKey(name: "is_focus_update")
  bool isFocusUpdate;

  @JsonKey(name: "last_version")
  String lastVersion;

  @JsonKey(name: "last_version_detail")
  String lastVersionDetail;

  RemoteConfigVersionInfo(
      {this.lastVersion, this.lastVersionDetail, this.isFocusUpdate});

  factory RemoteConfigVersionInfo.fromJson(Map<String, dynamic> srcJson) =>
      _$RemoteConfigVersionInfoFromJson(srcJson);
}
