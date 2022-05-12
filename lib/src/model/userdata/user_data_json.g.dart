// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data_json.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDataJson _$UserDataJsonFromJson(Map<String, dynamic> json) {
  return UserDataJson(
    account: json['account'] as String,
    password: json['password'] as String,
    info: json['info'] == null ? null : UserInfoJson.fromJson(json['info'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$UserDataJsonToJson(UserDataJson instance) => <String, dynamic>{
      'account': instance.account,
      'password': instance.password,
      'info': instance.info,
    };

UserInfoJson _$UserInfoJsonFromJson(Map<String, dynamic> json) {
  return UserInfoJson(
    givenName: json['givenName'] as String,
    userMail: json['userMail'] as String,
    userPhoto: json['userPhoto'] as String,
    passwordExpiredRemind: json['passwordExpiredRemind'] as String,
    userDn: json['userDn'] as String,
  );
}

Map<String, dynamic> _$UserInfoJsonToJson(UserInfoJson instance) => <String, dynamic>{
      'givenName': instance.givenName,
      'userMail': instance.userMail,
      'userPhoto': instance.userPhoto,
      'passwordExpiredRemind': instance.passwordExpiredRemind,
      'userDn': instance.userDn,
    };
