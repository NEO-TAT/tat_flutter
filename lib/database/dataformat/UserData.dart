import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:sprintf/sprintf.dart';
import 'package:sqflite/sqflite.dart';
import '../Model.dart';
import 'DataFormat.dart';

class UserData extends  DataFormat {
  static final String _id = 'id';
  static final String _account = "account";
  static final String _password = "password";
  static final String _givenName = "givenName";
  static final String _userMail = "userMail";
  static final String _userPhoto = "userPhoto";
  static final String _passwordExpiredRemind = "passwordExpiredRemind";
  static final String _userDn = "userDn";
  static final table = "UserData";
  static final String _createTable = '''
    CREATE TABLE $table (
      $_id INTEGER PRIMARY KEY , 
      $_account TEXT NOT NULL ,
      $_password TEXT NOT NULL ,
      $_givenName TEXT ,
      $_userMail TEXT ,
      $_userPhoto TEXT ,
      $_passwordExpiredRemind TEXT ,
      $_userDn TEXT 
    )
  ''';
  final Map<String, dynamic> _data = Map();

  UserData( String dataModelKey , {Key key, account , password , givenName ,userMail , userPhoto, passwordExpiredRemind , userDn })  : super(_createTable) {
    this.account = account;
    this.password = password;
    this.givenName = givenName;
    this.userMail = userMail;
    this.userPhoto = userPhoto;
    this.passwordExpiredRemind = passwordExpiredRemind;
    this.userDn = userDn;
    _data[_id] = 1;
  }


  @override
  Future<bool> save() async{
    Database db = await Model.instance.database;
    int insertId = await db.insert(
      table,
      _data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _data['id'] = insertId;
    return true;
  }

  @override
  Future<bool> load() async{
    try{
      Database db = await Model.instance.database;
      List<Map<String, dynamic>> data = await db.query(table , where: "id = ?", whereArgs: [ _data['id'] ] );
      if ( data.length != 0) {
        account     = data[0][_account];
        password    = data[0][_password];
        givenName   = data[0][_givenName];
        userMail    = data[0][_userMail];
        userPhoto   = data[0][_userPhoto];
        passwordExpiredRemind = data[0][_passwordExpiredRemind];
        userDn = data[0][_userDn];
        Log.d(this.toString());
        return true;
      }else {
        return false;
      }
    }on Exception catch(e){
      //db.delete("DROP TABLE $table");
      Log.e(e.toString());
      return false;
    }
  }

  @override
  String toString() {
    String text = sprintf( " account:%s \n password:%s \n givenName:%s \n userMail:%s \n userPhoto:%s" , [account , password , givenName , userMail , userPhoto]);
    return text;
  }

  String get account {
    return _data[_account];
  }
  set account(String value) {
    _data[_account] = value;
  }

  String get password {
    return _data[_password];
  }
  set password(String value) {
    _data[_password] = value;
  }

  set givenName(String value) {
    _data[_givenName] = value;
  }
  String get givenName {
    return _data[_givenName];
  }

  set userMail(String value) {
    _data[_userMail] = value;
  }
  String get userMail {
    return _data[_userMail];
  }

  set userPhoto(String value) {
    _data[_userPhoto] = value;
  }
  String get userPhoto {
    return _data[_userPhoto];
  }

  set passwordExpiredRemind(String value) {
    _data[_passwordExpiredRemind] = value;
  }
  String get passwordExpiredRemind {
    return _data[_passwordExpiredRemind];
  }

  set userDn(String value) {
    _data[_userDn] = value;
  }
  String get userDn {
    return _data[_userDn];
  }

}