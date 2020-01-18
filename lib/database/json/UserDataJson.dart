import 'package:flutter/cupertino.dart';

class UserDataJson{
  String givenName;
  String userMail;
  String userPhoto;
  String passwordExpiredRemind;
  String userDn;

  UserDataJson({Key key, givenName ,userMail , userPhoto, passwordExpiredRemind , userDn }) {
    this.givenName = givenName;
    this.userMail = userMail;
    this.userPhoto = userPhoto;
    this.passwordExpiredRemind = passwordExpiredRemind;
    this.userDn = userDn;
  }

  factory UserDataJson.fromJson(Map<String, dynamic> json) {
    return UserDataJson(
      givenName: json['givenName'],
      userMail: json['userMail'],
      userPhoto: json['userPhoto'],
      passwordExpiredRemind: json['passwordExpiredRemind'],
      userDn: json['userDn'],
    );
  }


}