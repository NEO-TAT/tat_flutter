import 'package:flutter/cupertino.dart';
import 'package:flutter_app/database/dataformat/UserData.dart';

class DataModel with ChangeNotifier{
  DataModel._privateConstructor();
  static final DataModel instance = DataModel._privateConstructor();
  UserData user = UserData();
}