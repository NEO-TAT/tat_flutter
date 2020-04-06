import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppHotFix{
  Future<String> _getUpdatePath() async{
    Directory dir = await getExternalStorageDirectory();
    return dir.path;
  }

  Future<String> getPatchVersion() async{
    var pref = await SharedPreferences.getInstance();
    String version = pref.getString("patch_version");
    version = version ?? "";
    return version;
  }

  void checkPatchVersion(){

  }



}