import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppHotFix{
  Directory getUpdatePath() async{
    Directory dir = await getExternalCacheDirectories();
  }
}