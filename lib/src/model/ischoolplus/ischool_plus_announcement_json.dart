// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:json_annotation/json_annotation.dart';

part 'ischool_plus_announcement_json.g.dart';

@JsonSerializable()
class ISchoolPlusAnnouncementInfoJson {
  @JsonKey(name: 'total')
  int total;

  @JsonKey(name: 'code')
  int code;

  @JsonKey(name: 'total_rows')
  String totalRows;

  @JsonKey(name: 'limit_rows')
  int limitRows;

  @JsonKey(name: 'current_page')
  String currentPage;

  @JsonKey(name: 'editEnable')
  String editEnable;

  @JsonKey(name: 'data')
  String data;

  ISchoolPlusAnnouncementInfoJson(
      this.total, this.code, this.totalRows, this.limitRows, this.currentPage, this.editEnable, this.data);

  factory ISchoolPlusAnnouncementInfoJson.fromJson(Map<String, dynamic> srcJson) =>
      _$ISchoolPlusAnnouncementInfoJsonFromJson(srcJson);
}

@JsonSerializable()
class ISchoolPlusAnnouncementJson {
  String token;
  String bid;
  String nid;

  @JsonKey(name: 'boardid')
  String boardid;

  @JsonKey(name: 'encbid')
  String encbid;

  @JsonKey(name: 'node')
  String node;

  @JsonKey(name: 'encnid')
  String encnid;

  @JsonKey(name: 'cid')
  String cid;

  @JsonKey(name: 'enccid')
  String enccid;

  @JsonKey(name: 'poster')
  String poster;

  @JsonKey(name: 'realname')
  String realname;

  @JsonKey(name: 'cpic')
  String cpic;

  @JsonKey(name: 'subject')
  String subject;

  @JsonKey(name: 'postdate')
  String postdate;

  @JsonKey(name: 'postdatelen')
  String postdatelen;

  @JsonKey(name: 'postcontent')
  String postcontent;

  @JsonKey(name: 'postcontenttext')
  String postcontenttext;

  @JsonKey(name: 'hit')
  String hit;

  @JsonKey(name: 'qrcode_url')
  String qrcodeUrl;

  @JsonKey(name: 'floor')
  int floor;

  @JsonKey(name: 'attach')
  String attach;

  @JsonKey(name: 'postfilelink')
  String postfilelink;

  @JsonKey(name: 'attachment')
  String attachment;

  @JsonKey(name: 'n')
  String n;

  @JsonKey(name: 's')
  String s;

  @JsonKey(name: 'readflag')
  int readflag;

  @JsonKey(name: 'postRoles')
  String postRoles;

  ISchoolPlusAnnouncementJson(
    this.boardid,
    this.encbid,
    this.node,
    this.encnid,
    this.cid,
    this.enccid,
    this.poster,
    this.realname,
    this.cpic,
    this.subject,
    this.postdate,
    this.postdatelen,
    this.postcontent,
    this.postcontenttext,
    this.hit,
    this.qrcodeUrl,
    this.floor,
    this.attach,
    this.postfilelink,
    this.attachment,
    this.n,
    this.s,
    this.readflag,
    this.postRoles,
  );

  factory ISchoolPlusAnnouncementJson.fromJson(Map<String, dynamic> srcJson) =>
      _$ISchoolPlusAnnouncementJsonFromJson(srcJson);
}