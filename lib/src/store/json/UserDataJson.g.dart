// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserDataJson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDataJson _$UserDataJsonFromJson(Map<String, dynamic> json) {
  return UserDataJson(
    givenName: json['givenName'] as String,
    userMail: json['userMail'] as String,
    userPhoto: json['userPhoto'] as String,
    passwordExpiredRemind: json['passwordExpiredRemind'] as String,
    userDn: json['userDn'] as String,
  );
}

Map<String, dynamic> _$UserDataJsonToJson(UserDataJson instance) =>
    <String, dynamic>{
      'givenName': instance.givenName,
      'userMail': instance.userMail,
      'userPhoto': instance.userPhoto,
      'passwordExpiredRemind': instance.passwordExpiredRemind,
      'userDn': instance.userDn,
    };
