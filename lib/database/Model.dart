import 'dart:async';
import 'dart:io';

import 'package:flutter_app/database/CreateModel.dart';
import 'package:flutter_app/database/dataformat/UserData.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:sqflite/sqflite.dart';

import 'DataModel.dart';

class Model {
  // make this a singleton class
  Model._privateConstructor();
  static final Model instance = Model._privateConstructor();

  static final _databaseName = "Database.db";
  static final _databaseVersion = 1;
  static final List<CreateModel> dbCreateList = [ DataModel.instance.user.dbCreate ];

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;  //不存在就創建
    _database = await _initDatabase();
    return _database;
  }
  
  void _deleteModel() async{
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    await deleteDatabase(path);
  }
  
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    List<String> createSqlList = List();
    for( CreateModel dbCreate in dbCreateList){
      String sqlItem = dbCreate.createTable;
      createSqlList.add(sqlItem);
    }
    String sql = '';
    for ( String s in createSqlList){
      if (sql.isNotEmpty ) sql += ",";
      sql += s;
    }


    try{
      await db.execute(sql);
      Log.d(sql);
    } on Exception catch(e){
      Log.e(e.toString());
    }
  }

}