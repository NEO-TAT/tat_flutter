// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ntut_calendar_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NTUTCalendarJson _$NTUTCalendarJsonFromJson(Map<String, dynamic> json) {
  return NTUTCalendarJson(
    json['id'] as int,
    json['calStart'] as int,
    json['calEnd'] as int,
    json['allDay'] as String,
    json['calTitle'] as String,
    json['calPlace'] as String,
    json['calContent'] as String,
    json['calColor'] as String,
    json['ownerId'] as String,
    json['ownerName'] as String,
    json['creatorId'] as String,
    json['creatorName'] as String,
    json['modifierId'] as String,
    json['modifierName'] as String,
    json['modifyDate'] as int,
    json['hasBeenDeleted'] as int,
    json['calInviteeList'] as List,
    json['calAlertList'] as List,
  );
}