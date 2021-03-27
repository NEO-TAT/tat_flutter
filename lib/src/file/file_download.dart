//
//  file_download.dart
//  北科課程助手
//  下載檔案用使用flutter_downloader
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/src/notifications/notifications.dart';
import 'package:flutter_app/src/util/file_utils.dart';

import 'file_store.dart';

class FileDownload {
  static Future<void> download(BuildContext context, String url, dirName,
      [String name = "", String referer]) async {
    String path = await FileStore.getDownloadDir(context, dirName); //取得下載路徑
    String realFileName;
    String fileExtension;
    referer = referer ?? url;
    Log.d("file download \n url: $url \n referer: $referer");
    //顯示下載通知窗
    ReceivedNotification value = ReceivedNotification(
        title: name, body: R.current.prepareDownload, payload: null); //通知窗訊息
    CancelToken cancelToken; //取消下載用
    ProgressCallback onReceiveProgress; //下載進度回調
    await Notifications.instance.showIndeterminateProgressNotification(value);
    //顯示下載進度通知窗
    value.title = name;

    int nowSize = 0;
    onReceiveProgress = (int count, int total) async {
      value.body = FileUtils.formatBytes(count, 2);
      if ((nowSize + 1024 * 128) > count && nowSize != 0) {
        //128KB顯示一次
        return;
      }
      nowSize = count;
      if (count < total) {
        Notifications.instance.showProgressNotification(
            value, 100, (count * 100 / total).round()); //顯示下載進度
      } else {
        Notifications.instance
            .showIndeterminateProgressNotification(value); //顯示下載進度
      }
    };
    //開始下載檔案
    DioConnector.instance.download(url, (Headers responseHeaders) {
      Map<String, List<String>> headers = responseHeaders.map;
      if (headers.containsKey("content-disposition")) {
        //代表有名字
        List<String> name = headers["content-disposition"];
        RegExp exp =
            RegExp("['|\"](?<name>.+)['|\"]"); //尋找 'name' , "name" 的name
        RegExpMatch matches = exp.firstMatch(name[0]);
        realFileName = matches.group(1);
      } else if (headers.containsKey("content-type")) {
        List<String> name = headers["content-type"];
        if (name[0].toLowerCase().contains("pdf")) {
          //是application/pdf
          realFileName = '.pdf';
        }
      }
      if (!name.contains(".")) {
        //代表名字不包含副檔名
        if (realFileName != null) {
          //代表可以從網路取得副檔名
          fileExtension = realFileName.split(".").reversed.toList()[0];
          realFileName = name + "." + fileExtension;
        } else {
          //嘗試使用網址後面找出附檔名
          String maybeName = url.split("/").toList().last;
          if (maybeName.contains(".")) {
            fileExtension = maybeName.split(".").toList().last;
            realFileName = name + "." + fileExtension;
          }
          //realFileName = name + "." + fileExtension;
        }
      } else {
        //代表包含.
        List<String> s = name.split(".");
        s.removeLast();
        if (realFileName != null && realFileName.contains(".")) {
          realFileName = s.join() + '.' + realFileName.split(".").last;
        }
      }
      realFileName = realFileName ?? name; //如果還是沒有找到副檔名直接使用原始名稱
      //print(path + "/" + realFileName);
      return path + "/" + realFileName;
    },
        progressCallback: onReceiveProgress,
        cancelToken: cancelToken,
        header: {"referer": referer}).whenComplete(
      () async {
        //顯示下載萬完成通知窗
        await Notifications.instance.cancelNotification(value.id);
        value.body = R.current.downloadComplete;
        value.id = Notifications.instance.notificationId; //取得新的id
        String filePath = path + '/' + realFileName;
        int id = value.id;
        value.payload = json.encode({
          "type": "download_complete",
          "path": filePath,
          "id": id,
        });
        await Notifications.instance.showNotification(value); //顯示下載完成
      },
    ).catchError(
      (onError) async {
        //顯示下載萬完成通知窗
        Log.d(onError.toString());
        await Future.delayed(Duration(milliseconds: 100));
        Notifications.instance.cancelNotification(value.id);
        value.body = "下載失敗";
        value.id = Notifications.instance.notificationId; //取得新的id
        int id = value.id;
        value.payload = json.encode({
          "type": "download_fail",
          "id": id,
        });
        await Notifications.instance.showNotification(value); //顯示下載完成
      },
    );
  }
}
