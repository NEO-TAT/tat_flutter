// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NTUTCalendarJson.dart';

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

Map<String, dynamic> _$NTUTCalendarJsonToJson(NTUTCalendarJson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'calStart': instance.calStart,
      'calEnd': instance.calEnd,
      'allDay': instance.allDay,
      'calTitle': instance.calTitle,
      'calPlace': instance.calPlace,
      'calContent': instance.calContent,
      'calColor': instance.calColor,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'creatorId': instance.creatorId,
      'creatorName': instance.creatorName,
      'modifierId': instance.modifierId,
      'modifierName': instance.modifierName,
      'modifyDate': instance.modifyDate,
      'hasBeenDeleted': instance.hasBeenDeleted,
      'calInviteeList': instance.calInviteeList,
      'calAlertList': instance.calAlertList,
    };
