import 'package:tat/src/model/json_init.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';

part 'user_data_json.g.dart';

@JsonSerializable()
class UserDataJson {
  String account;
  String password;
  UserInfoJson info;

  UserDataJson({this.account, this.password, this.info}) {
    this.account = JsonInit.stringInit(this.account);
    this.password = JsonInit.stringInit(this.password);
    this.info = (this.info != null) ? this.info : UserInfoJson();
  }

  factory UserDataJson.fromJson(Map<String, dynamic> json) =>
      _$UserDataJsonFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataJsonToJson(this);

  bool get isEmpty {
    return account.isEmpty && password.isEmpty && info.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "account  : %s \n"
        "password : %s \n"
        "---------info--------     \n%s \n",
        [account, password, info.toString()]);
  }
}

@JsonSerializable()
class UserInfoJson {
  String givenName;
  String userMail;
  String userPhoto;
  String passwordExpiredRemind;
  String userDn;

  UserInfoJson(
      {this.givenName,
      this.userMail,
      this.userPhoto,
      this.passwordExpiredRemind,
      this.userDn}) {
    this.givenName = JsonInit.stringInit(this.givenName);
    this.userMail = JsonInit.stringInit(this.userMail);
    this.userPhoto = JsonInit.stringInit(this.userPhoto);
    this.userDn = JsonInit.stringInit(this.userDn);
    this.passwordExpiredRemind =
        JsonInit.stringInit(this.passwordExpiredRemind);
  }

  factory UserInfoJson.fromJson(Map<String, dynamic> json) =>
      _$UserInfoJsonFromJson(json);

  Map<String, dynamic> toJson() => _$UserInfoJsonToJson(this);

  bool get isEmpty {
    return givenName.isEmpty &&
        userMail.isEmpty &&
        userPhoto.isEmpty &&
        userDn.isEmpty &&
        passwordExpiredRemind.isEmpty;
  }

  @override
  String toString() {
    return sprintf(
        "givenName  : %s \n" +
            "userMail   : %s \n" +
            "userPhoto  : %s \n" +
            "userDn     : %s \n" +
            "passwordExpiredRemind: %s \n",
        [givenName, userMail, userPhoto, passwordExpiredRemind, userDn]);
  }
}
