import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/connector/DioConnector.dart';

import 'dataformat/UserData.dart';
class DataModel{
  static final String _dataModelKey = "key";
  DataModel._privateConstructor();
  static final DataModel instance = DataModel._privateConstructor();
  UserData user = UserData(_dataModelKey);
  Future<void> init () async{
    await user.load();
    await DioConnector.instance.init();
  }
}