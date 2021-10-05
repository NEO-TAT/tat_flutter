import 'package:json_annotation/json_annotation.dart';

part 'ischool_plus_announcement_json.g.dart';

@JsonSerializable()
class ISchoolPlusAnnouncementInfoJson {
  @JsonKey(name: 'total')
  late final int total;

  @JsonKey(name: 'code')
  late final int code;

  @JsonKey(name: 'total_rows')
  late final String totalRows;

  @JsonKey(name: 'limit_rows')
  late final int limitRows;

  @JsonKey(name: 'current_page')
  late final String currentPage;

  @JsonKey(name: 'editEnable')
  late final String editEnable;

  @JsonKey(name: 'data')
  late final String data;

  ISchoolPlusAnnouncementInfoJson(
    this.total,
    this.code,
    this.totalRows,
    this.limitRows,
    this.currentPage,
    this.editEnable,
    this.data,
  );

  factory ISchoolPlusAnnouncementInfoJson.fromJson(
          Map<String, dynamic> srcJson) =>
      _$ISchoolPlusAnnouncementInfoJsonFromJson(srcJson);
}

@JsonSerializable()
class ISchoolPlusAnnouncementJson {
  late final String token;
  late final String bid;
  late final String nid;

  @JsonKey(name: 'boardid')
  late final String boardid;

  @JsonKey(name: 'encbid')
  late final String encbid;

  @JsonKey(name: 'node')
  late final String node;

  @JsonKey(name: 'encnid')
  late final String encnid;

  @JsonKey(name: 'cid')
  late final String cid;

  @JsonKey(name: 'enccid')
  late final String enccid;

  @JsonKey(name: 'poster')
  late final String poster;

  @JsonKey(name: 'realname')
  late final String realname;

  @JsonKey(name: 'cpic')
  late final String cpic;

  @JsonKey(name: 'subject')
  late final String subject;

  @JsonKey(name: 'postdate')
  late final String postdate;

  @JsonKey(name: 'postdatelen')
  late final String postdatelen;

  @JsonKey(name: 'postcontent')
  late final String postcontent;

  @JsonKey(name: 'postcontenttext')
  late final String postcontenttext;

  @JsonKey(name: 'hit')
  late final String hit;

  @JsonKey(name: 'qrcode_url')
  late final String qrcodeUrl;

  @JsonKey(name: 'floor')
  late final int floor;

  @JsonKey(name: 'attach')
  late final String attach;

  @JsonKey(name: 'postfilelink')
  late final String postfilelink;

  @JsonKey(name: 'attachment')
  late final String attachment;

  @JsonKey(name: 'n')
  late final String n;

  @JsonKey(name: 's')
  late final String s;

  @JsonKey(name: 'readflag')
  late final int readflag;

  @JsonKey(name: 'postRoles')
  late final String postRoles;

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
    this.bid,
    this.nid,
    this.token,
  );

  factory ISchoolPlusAnnouncementJson.fromJson(Map<String, dynamic> srcJson) =>
      _$ISchoolPlusAnnouncementJsonFromJson(srcJson);
}
