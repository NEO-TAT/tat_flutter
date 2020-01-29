import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sprintf/sprintf.dart';
part 'UserDataJson.g.dart';


class StringInit {
  static String init(String value){
    return (value != null)? value : "";
  }
}

@JsonSerializable()
class UserDataJson {
  String account;
  String password;
  UserInfoJson info;
  UserDataJson({ this.account , this.password , this.info  }){
    this.account = StringInit.init( this.account );
    this.password = StringInit.init( this.password );
    this.info = (this.info != null ) ? this.info : UserInfoJson();
  }

  factory UserDataJson.fromJson(Map<String, dynamic> json) => _$UserDataJsonFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataJsonToJson(this);

  @override
  String toString() {
    return sprintf(" account: %s \n password: %s \n --------UserInfoClass--------\n%s" , [account , password , info.toString() ] );
  }

}


@JsonSerializable()
class UserInfoJson{
  String givenName;
  String userMail;
  String userPhoto;
  String passwordExpiredRemind;
  String userDn;

  UserInfoJson({ this.givenName , this.userMail , this.userPhoto , this.passwordExpiredRemind , this.userDn }){
    this.givenName = StringInit.init( this.givenName );
    this.userMail = StringInit.init( this.userMail );
    this.userPhoto = StringInit.init( this.userPhoto );
    this.passwordExpiredRemind = StringInit.init( this.passwordExpiredRemind );
    this.userDn = StringInit.init( this.userDn );
  }

  factory UserInfoJson.fromJson(Map<String, dynamic> json) => _$UserInfoJsonFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoJsonToJson(this);

  @override
  String toString() {
    return sprintf(" givenName: %s \n userMail: %s \n userPhoto: %s \n passwordExpiredRemind: %s \n userDn: %s" , [givenName , userMail , userPhoto , passwordExpiredRemind , userDn ] );
  }


}