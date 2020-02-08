import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'FileStore.dart';

class FileDownload {
  static Future<void> download(BuildContext context , String url , dirName , [String name = ""] ) async{
    String path = await FileStore.getDownloadDir(
        context, dirName );

    String realFileName;
    if( name.isNotEmpty ){  //代表沒有名字直接使用FlutterDownload自動取名
      realFileName = await Connector.getFileName(url);
      if (realFileName != null) {
        String fileExtension = realFileName.split(".").reversed.toList()[0];
        realFileName = name + "." + fileExtension;
      }
    }

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: path,
      fileName: realFileName,
      headers: Connector.getLoginHeaders(url),
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification: true,
      // click on notification to open downloaded file (for Android)
    );
  }
}