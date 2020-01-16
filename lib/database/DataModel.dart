import 'package:flutter/cupertino.dart';
import 'package:flutter_app/database/dataformat/UserData.dart';

class DataModel with ChangeNotifier{
  UserData user = UserData();
}