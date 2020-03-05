//
//  FileDownload.dart
//  北科課程助手
//  下載檔案用使用flutter_downloader
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/Connector.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/notifications/Notifications.dart';
import 'package:flutter_app/src/util/FileUtils.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:sprintf/sprintf.dart';

import 'FileStore.dart';

class FileDownload {
  static Future<void> download(BuildContext context, String url, dirName,
      [String name = ""]) async {
    String path = await FileStore.getDownloadDir(context, dirName); //取得下載路徑
    String realFileName;
    String fileExtension;
    ReceivedNotification value = ReceivedNotification(
        title: name,
        body: "下載準備中",
        payload: 'download'); //通知窗訊息
    CancelToken cancelToken; //取消下載用
    ProgressCallback onReceiveProgress; //下載進度回調

    await Notifications.instance.showIndeterminateProgressNotification(value);
    if (name.isNotEmpty && !name.contains(".")) {
      //代表名字已經包含副檔名
      //代表沒有名字直接使用FlutterDownload自動取名
      realFileName = await Connector.getFileName(url);
      if (realFileName != null) {
        //代表可以從網路取得副檔名
        fileExtension = realFileName.split(".").reversed.toList()[0];
        realFileName = name + "." + fileExtension;
      } else {
        String maybeName = url.split("/").toList().last;
        if (maybeName.contains(".")) {
          fileExtension = maybeName.split(".").toList().last;
          realFileName = name + "." + fileExtension;
        }
        realFileName = name + "." + fileExtension;
      }
    }

    onReceiveProgress = (int count, int total) async {
      //Log.d(sprintf("%d %d", [count, total]));
      value.body = FileUtils.formatBytes( count , 2);
      await Future.delayed(Duration(milliseconds: 10));
      if( count < total ){
        await Notifications.instance
            .showProgressNotification(value, 100, (count * 100 / total).round());  //顯示下載進度
      }else{
        value.body = "下載中...";
        await Notifications.instance
            .showIndeterminateProgressNotification(value);  //顯示下載進度
      }
    };

    await DioConnector.instance.download(url, path + "/" + realFileName,
        progressCallback: onReceiveProgress, cancelToken: cancelToken);
    await Future.delayed(Duration(milliseconds: 100));
    Notifications.instance.cancelNotification(value.id);
    value.body = '下載完成';
    value.id = Notifications.instance.notificationId;  //取得新的id
    value.payload = "file:" + path + '/' + realFileName;
    await Notifications.instance
        .showNotification(value);  //顯示下載完成


    /*
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

     */
  }
}
