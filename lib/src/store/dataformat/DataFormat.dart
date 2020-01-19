import 'package:sqflite/sqlite_api.dart';

import '../CreateModel.dart';

abstract class DataFormat {
  CreateModel dbCreate;
  DataFormat(String value){
    dbCreate = CreateModel(value);
  }

  Future<bool> load();
  Future<bool> save();
}