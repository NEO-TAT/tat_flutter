// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/src/notifications/notifications.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/util/file_utils.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';

import 'file_store.dart';

class FileDownload {
  static Future<void> download(String url, dirName, [String name = "", String? referer]) async {
    final path = await FileStore.getDownloadDir(dirName);
    String? realFileName = "";
    String? fileExtension = "";
    referer = referer ?? url;
    Log.d("file download \n url: $url \n referer: $referer");
    final value = ReceivedNotification(title: name, body: R.current.prepareDownload, payload: null); //通知窗訊息
    final cancelToken = CancelToken();
    await Notifications.instance.showIndeterminateProgressNotification(value);
    value.title = name;

    int nowSize = 0;
    onReceiveProgress(int count, int total) {
      value.body = FileUtils.formatBytes(count, 2);
      if ((nowSize + 1024 * 128) > count && nowSize != 0) {
        return;
      }
      nowSize = count;
      if (count < total) {
        Notifications.instance.showProgressNotification(value, 100, (count * 100 / total).round()); //顯示下載進度
      } else {
        Notifications.instance.showIndeterminateProgressNotification(value);
      }
    }

    // This flag is used to prevent the dialog from being displayed multiple times.
    bool hasError = false;
    await DioConnector.instance.download(
      url,
      (responseHeaders) {
        final Map<String, List<String>> headers = responseHeaders.map;
        if (headers.containsKey("content-disposition")) {
          final name = headers["content-disposition"];
          final exp = RegExp("['|\"](?<name>.+)['|\"]");
          final matches = name != null ? exp.firstMatch(name[0]) : null;
          realFileName = matches?.group(1);
        } else if (headers.containsKey("content-type")) {
          final name = headers["content-type"];
          if (name?[0].toLowerCase().contains("pdf") == true) {
            realFileName = '.pdf';
          }
        }
        if (!name.contains(".")) {
          if (realFileName != null) {
            fileExtension = realFileName?.split(".").reversed.toList()[0];
            realFileName = "$name.$fileExtension";
          } else {
            final maybeName = url.split("/").toList().last;
            if (maybeName.contains(".")) {
              fileExtension = maybeName.split(".").toList().last;
              realFileName = "$name.$fileExtension";
            }
          }
        } else {
          final List<String> s = name.split(".");
          s.removeLast();
          if (realFileName != null && realFileName?.contains(".") == true) {
            realFileName = '${s.join()}.${realFileName?.split(".").last ?? ""}';
          }
        }
        realFileName = realFileName ?? name;
        return "$path/$realFileName";
      },
      progressCallback: onReceiveProgress,
      cancelToken: cancelToken,
      header: {"referer": referer},
    ).catchError(
      (onError) async {
        hasError = true;
        Log.d(onError.toString());
        await Future.delayed(const Duration(milliseconds: 100));
        Notifications.instance.cancelNotification(value.id);

        value.body = R.current.downloadError;
        value.id = Notifications.instance.notificationId;
        value.payload = json.encode({
          "type": "download_fail",
          "id": value.id,
        });

        await Notifications.instance.showNotification(value);
        ErrorDialog(ErrorDialogParameter(
          desc: realFileName,
          title: R.current.downloadError,
          offCancelBtn: true,
          dialogType: DialogType.warning,
        )).show();
      },
    );

    if (!hasError) {
      await Notifications.instance.cancelNotification(value.id);
      value.body = R.current.downloadComplete;
      value.id = Notifications.instance.notificationId;
      value.payload = json.encode({
        "type": "download_complete",
        "path": '$path/$realFileName',
        "id": value.id,
      });
      await Notifications.instance.showNotification(value);
      ErrorDialog(ErrorDialogParameter(
        desc: realFileName,
        title: R.current.downloadComplete,
        offCancelBtn: true,
        dialogType: DialogType.success,
      )).show();
    }
  }
}
