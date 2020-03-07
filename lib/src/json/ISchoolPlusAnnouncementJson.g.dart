// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ISchoolPlusAnnouncementJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ISchoolPlusAnnouncementInfoJson _$ISchoolPlusAnnouncementInfoJsonFromJson(
    Map<String, dynamic> json) {
  return ISchoolPlusAnnouncementInfoJson(
    json['total'] as int,
    json['code'] as int,
    json['total_rows'] as String,
    json['limit_rows'] as int,
    json['current_page'] as String,
    json['editEnable'] as String,
    json['data'] as String,
  );
}

Map<String, dynamic> _$ISchoolPlusAnnouncementInfoJsonToJson(
        ISchoolPlusAnnouncementInfoJson instance) =>
    <String, dynamic>{
      'total': instance.total,
      'code': instance.code,
      'total_rows': instance.totalRows,
      'limit_rows': instance.limitRows,
      'current_page': instance.currentPage,
      'editEnable': instance.editEnable,
      'data': instance.data,
    };

ISchoolPlusAnnouncementJson _$ISchoolPlusAnnouncementJsonFromJson(
    Map<String, dynamic> json) {
  return ISchoolPlusAnnouncementJson(
    json['boardid'] as String,
    json['encbid'] as String,
    json['node'] as String,
    json['encnid'] as String,
    json['cid'] as String,
    json['enccid'] as String,
    json['poster'] as String,
    json['realname'] as String,
    json['cpic'] as String,
    json['subject'] as String,
    json['postdate'] as String,
    json['postdatelen'] as String,
    json['postcontent'] as String,
    json['postcontenttext'] as String,
    json['hit'] as String,
    json['qrcode_url'] as String,
    json['floor'] as int,
    json['attach'] as String,
    json['postfilelink'] as String,
    json['attachment'] as String,
    json['n'] as String,
    json['s'] as String,
    json['readflag'] as int,
    json['postRoles'] as String,
  )
    ..token = json['token'] as String
    ..bid = json['bid'] as String
    ..nid = json['nid'] as String;
}

Map<String, dynamic> _$ISchoolPlusAnnouncementJsonToJson(
        ISchoolPlusAnnouncementJson instance) =>
    <String, dynamic>{
      'token': instance.token,
      'bid': instance.bid,
      'nid': instance.nid,
      'boardid': instance.boardid,
      'encbid': instance.encbid,
      'node': instance.node,
      'encnid': instance.encnid,
      'cid': instance.cid,
      'enccid': instance.enccid,
      'poster': instance.poster,
      'realname': instance.realname,
      'cpic': instance.cpic,
      'subject': instance.subject,
      'postdate': instance.postdate,
      'postdatelen': instance.postdatelen,
      'postcontent': instance.postcontent,
      'postcontenttext': instance.postcontenttext,
      'hit': instance.hit,
      'qrcode_url': instance.qrcodeUrl,
      'floor': instance.floor,
      'attach': instance.attach,
      'postfilelink': instance.postfilelink,
      'attachment': instance.attachment,
      'n': instance.n,
      's': instance.s,
      'readflag': instance.readflag,
      'postRoles': instance.postRoles,
    };
