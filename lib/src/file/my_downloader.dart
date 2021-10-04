import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:tat/debug/log/log.dart';

class MyDownloader {
  static Map<String, Function> _callBackMap = Map();
  static bool isInit = false;
  static final _port = ReceivePort();

  static init() async {
    if (!isInit) {
      await FlutterDownloader.initialize();

      IsolateNameServer.registerPortWithName(
        _port.sendPort,
        'downloader_send_port',
      );

      _port.listen((dynamic data) {
        String id = data[0];
        DownloadTaskStatus status = data[1];
        int progress = data[2];
        _downloadListen(id, status, progress);
      });

      FlutterDownloader.registerCallback(downloadCallback);
      isInit = true;
    }
  }

  static _downloadListen(String id, DownloadTaskStatus status, int progress) {
    if (status == DownloadTaskStatus.complete) {
      Log.d("$id complete");
      final keyList = _callBackMap.keys.toList();

      for (int i = 0; i < keyList.length; i++) {
        final mapId = keyList[i];
        if (mapId == id) {
          Log.d("$id find callback");
          _callBackMap[mapId]!();
          _callBackMap.remove(mapId);
        }
      }
    } else if (status == DownloadTaskStatus.failed) {
      Log.d("$id fail");
    }
  }

  static deInit() async {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    isInit = false;
  }

  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  static void addCallBack(String id, Function callback) {
    Log.d("add $id callback");
    _callBackMap[id] = callback;
  }
}
