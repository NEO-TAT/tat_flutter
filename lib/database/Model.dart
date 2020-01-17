import 'dart:async';
import 'dart:io';

import 'package:flutter_app/database/CreateModel.dart';
import 'package:flutter_app/database/dataformat/UserData.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import 'package:sqflite/sqflite.dart';

class Model {
  // make this a singleton class
  static final _className = "Model";
  Model._privateConstructor();
  static final Model instance = Model._privateConstructor();

  static final _databaseName = "Database.db";
  static final _databaseVersion = 1;
  static final List<CreateModel> dbCreateList = [ UserData.dbCreate ];

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;  //不存在就創建
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    //deleteDatabase(path);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    List<String> createSqlList = List();
    for( CreateModel dbCreate in dbCreateList){
      String sqlTable = sprintf( 'CREATE TABLE %s' , [dbCreate.table] );
      String sqlData = '';
      if ( dbCreate.data.containsKey('id')){
        String sqlKey   = 'id INTEGER PRIMARY KEY';
        sqlData += sqlKey;
      }
      for( String key in dbCreate.data.keys ){
        if ( key == 'id') continue;
        if (sqlData != '') sqlData += ',';
        sqlData += sprintf( '%s TEXT NOT NULL' , [key] );
      }
      String sqlItem = sprintf( '%s ( %s );' , [ sqlTable , sqlData] );
      createSqlList.add(sqlItem);
    }
    String sql = '';
    for ( String s in createSqlList){
      sql += s;
    }
    Log.d( _className , sql);
    await db.execute(sql);
  }
}