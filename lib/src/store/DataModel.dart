import 'package:flutter/cupertino.dart';

import 'dataformat/UserData.dart';
class DataModel with ChangeNotifier{
  static final String _dataModelKey = "key";
  DataModel._privateConstructor();
  static final DataModel instance = DataModel._privateConstructor();
  UserData user = UserData(_dataModelKey);
}