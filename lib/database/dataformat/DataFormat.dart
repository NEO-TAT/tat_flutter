import 'package:flutter_app/database/CreateModel.dart';
import 'package:sqflite/sqlite_api.dart';

abstract class DataFormat {
  CreateModel dbCreate;
  DataFormat(String value){
    dbCreate = CreateModel(value);
  }

  Future<bool> load();
  Future<bool> save();
}