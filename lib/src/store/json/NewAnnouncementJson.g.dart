// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NewAnnouncementJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewAnnouncementJson _$NewAnnouncementJsonFromJson(Map<String, dynamic> json) {
  return NewAnnouncementJson(
    title: json['title'] as String,
    detail: json['detail'] as String,
    sender: json['sender'] as String,
    courseName: json['courseName'] as String,
    messageId: json['messageId'] as String,
    isRead: json['isRead'] as bool,
    time: json['time'] == null ? null : DateTime.parse(json['time'] as String),
  )..courseId = json['courseId'] as String;
}

Map<String, dynamic> _$NewAnnouncementJsonToJson(
        NewAnnouncementJson instance) =>
    <String, dynamic>{
      'title': instance.title,
      'detail': instance.detail,
      'sender': instance.sender,
      'courseId': instance.courseId,
      'courseName': instance.courseName,
      'messageId': instance.messageId,
      'isRead': instance.isRead,
      'time': instance.time?.toIso8601String(),
    };
