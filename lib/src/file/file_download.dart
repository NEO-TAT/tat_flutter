//  北科課程助手

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/connector/core/dio_connector.dart';
import 'package:tat/src/notifications/notifications.dart';
import 'package:tat/src/util/file_utils.dart';

import 'file_store.dart';

class FileDownload {
  static Future<void> download(
    BuildContext context,
    String url,
    dirName, [
    String name = "",
    String? referer,
  ]) async {
    // get the download path
    final path = await FileStore.getDownloadDir(context, dirName);
    String? realFileName, fileExtension;
    referer ??= url;
    Log.d("file download \n url: $url \n referer: $referer");

    // display the download notification window
    ReceivedNotification value = ReceivedNotification(
      title: name,
      body: R.current.prepareDownload,
      payload: "",
    ); // the message of the notification window

    // for cancel downloading usage
    CancelToken? cancelToken;

    // the callback of download progress changed.
    ProgressCallback onReceiveProgress;

    // display the download progress notification window
    await Notifications.instance.showIndeterminateProgressNotification(value);

    value.title = name;
    int nowSize = 0;
    onReceiveProgress = (int count, int total) async {
      value.body = FileUtils.formatBytes(count, 2);
      if ((nowSize + 1024 * 128) > count && nowSize != 0) {
        // show the notification per 128KB
        return;
      }

      nowSize = count;

      if (count < total) {
        // show download progress
        Notifications.instance.showProgressNotification(
          value,
          100,
          (count * 100 / total).round(),
        );
      } else {
        // show download progress
        Notifications.instance.showIndeterminateProgressNotification(value);
      }
    };

    // start to download the file
    DioConnector.dioInstance.download(url, (Headers responseHeaders) {
      final headers = responseHeaders.map;

      if (headers.containsKey("content-disposition")) {
        // means the name is exist.
        final name = headers["content-disposition"]!;

        // find 'name' or "name"
        final exp = RegExp("['|\"](?<name>.+)['|\"]");
        final matches = exp.firstMatch(name[0])!;
        realFileName = matches.group(1)!;
      } else if (headers.containsKey("content-type")) {
        final name = headers["content-type"]!;
        if (name[0].toLowerCase().contains("pdf")) {
          // means its type is application/pdf
          realFileName = '.pdf';
        }
      }

      if (!name.contains(".")) {
        // means there's no any extensions in its name
        if (realFileName != null) {
          // means the extension can be fetched from web
          fileExtension = realFileName!.split(".").reversed.toList()[0];
          realFileName = name + "." + fileExtension!;
        } else {
          // try to find the extension at the end of url
          final maybeName = url.split("/").toList().last;
          if (maybeName.contains(".")) {
            fileExtension = maybeName.split(".").toList().last;
            realFileName = name + "." + fileExtension!;
          }
        }
      } else {
        // means there's include extension in its name
        final s = name.split(".");
        s.removeLast();
        if (realFileName != null && realFileName!.contains(".")) {
          realFileName = s.join() + '.' + realFileName!.split(".").last;
        }
      }

      // if still not found a extension, use its origin name
      realFileName ??= name;
      return path + "/" + realFileName.toString();
    },
        progressCallback: onReceiveProgress,
        cancelToken: cancelToken,
        header: {"referer": referer}).whenComplete(
      () async {
        // shoe the download finish notification
        await Notifications.instance.cancelNotification(value.id);
        value.body = R.current.downloadComplete;
        value.id = Notifications.instance.notificationId; // get new id
        final filePath = path + '/' + realFileName.toString();
        final id = value.id;

        value.payload = json.encode({
          "type": "download_complete",
          "path": filePath,
          "id": id,
        });

        await Notifications.instance.showNotification(value);
      },
    ).catchError(
      (onError) async {
        // shoe the download finish notification
        Log.d(onError.toString());
        await Future.delayed(Duration(milliseconds: 100));
        Notifications.instance.cancelNotification(value.id);
        value.body = "下載失敗";
        value.id = Notifications.instance.notificationId; // get new id
        final id = value.id;

        value.payload = json.encode({
          "type": "download_fail",
          "id": id,
        });

        await Notifications.instance.showNotification(value);
      },
    );
  }
}
