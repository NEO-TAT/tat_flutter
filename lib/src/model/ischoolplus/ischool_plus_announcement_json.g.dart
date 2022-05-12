// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ischool_plus_announcement_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ISchoolPlusAnnouncementInfoJson _$ISchoolPlusAnnouncementInfoJsonFromJson(Map<String, dynamic> json) {
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

ISchoolPlusAnnouncementJson _$ISchoolPlusAnnouncementJsonFromJson(Map<String, dynamic> json) {
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
