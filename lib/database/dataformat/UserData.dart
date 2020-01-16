import 'package:flutter_app/debug/error/HandleError.dart';
import 'package:flutter_app/debug/log/PrintLog.dart';
import 'package:sqflite/sqflite.dart';
import '../CreateModel.dart';
import '../Model.dart';

class UserData {
  static final _className = "UserData";
  static final String _account = "account";
  static final String _password = 'password';
  static final String _id = 'id';
  static final Map<String, dynamic> data = {
    _id : 1,
    _account  : "",
    _password : ""
  };
  static final table = "UserData";
  final CreateModel dbCreate = CreateModel(table , data );

  String get account {
    return data[_account];
  }
  String get password {
    return data[_password];
  }
  set account(String value) {
    data[_account] = value;
  }
  set password(String value) {
    data[_password] = value;
  }

  void login() async{
    Database db = await Model.instance.database;
    await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    List<Map<String, dynamic>> dataList = await db.query(table);
    for ( Map<String, dynamic> data in dataList ){
      Log.d( _className , data.toString());
    }
    Log.d( _className , dataList.length.toString() );
  }

  Future<bool> load() async{
    Database db = await Model.instance.database;
    try{
      List<Map<String, dynamic>> data = await db.query(table , where: "id = ?", whereArgs: [1] );
      account = data.elementAt(0)[_account];
      password = data.elementAt(0)[_password];
      return true;
    }on Exception catch(e){
      HandleError.sendError(e);
      return false;
    }
  }


}