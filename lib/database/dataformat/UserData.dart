import 'package:flutter_app/debug/error/HandleError.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:sqflite/sqflite.dart';
import '../CreateModel.dart';
import '../Model.dart';

class UserData {
  static final _className = "UserData";
  static final String _account = "account";
  static final String _password = 'password';
  static final String _id = 'id';
  static final Map<String, dynamic> _data = {
    _id : 1,
    _account  : "",
    _password : ""
  };
  static final table = "UserData";
  static final CreateModel dbCreate = CreateModel(table , _data );

  String get account {
    return _data[_account];
  }
  String get password {
    return _data[_password];
  }
  set account(String value) {
    _data[_account] = value;
  }
  set password(String value) {
    _data[_password] = value;
  }

  Future<int> save() async{
    Database db = await Model.instance.database;
    int insertId = await db.insert(
      table,
      _data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _data['id'] = insertId;
    return insertId;
  }

  Future<bool> load() async{
    Database db = await Model.instance.database;
    try{
      List<Map<String, dynamic>> data = await db.query(table , where: "id = ?", whereArgs: [ _data['id'] ] );
      if ( data.length != 0) {
        account = data[0][_account];
        password = data[0][_password];
        return true;
      }else {
        return false;
      }
    }on Exception catch(e){
      HandleError.sendError( _className , e);
      return false;
    }
  }


}