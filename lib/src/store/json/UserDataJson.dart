import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'UserDataJson.g.dart';

@JsonSerializable()
class UserDataJson{
  String givenName;
  String userMail;
  String userPhoto;
  String passwordExpiredRemind;
  String userDn;

  UserDataJson({ this.givenName , this.userMail , this.userPhoto , this.passwordExpiredRemind , this.userDn });

  factory UserDataJson.fromJson(Map<String, dynamic> json) => _$UserDataJsonFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataJsonToJson(this);

}