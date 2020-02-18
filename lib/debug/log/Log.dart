//
//  Log.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';

enum LogMode { LogError, LogDebug }

class Log {
  static String _lastLog = "";
  static Logger logger = Logger(
    printer: PrettyPrinter(
        methodCount: 3,
        // number of method calls to be displayed
        errorMethodCount: 8,
        // number of method calls if stacktrace is provided
        lineLength: 60,
        // width of the output
        colors: true,
        // Colorful log messages
        printEmojis: true,
        // Print an emoji for each log message
        printTime: false // Should each log print contain a timestamp
        ),
  );

  static void e(String data) {
    //用於顯示已用try catch的處理error
    myLogNew(LogMode.LogError, data);
  }

  static void error(String data) {
    //用於顯示無try catch的error
    myLogNew(LogMode.LogError, data);
  }

  static void d(String data) {
    //用於debug的Log
    myLogNew(LogMode.LogDebug, data);
  }

  static myLogNew(LogMode mode, String log) {
    if (bool.fromEnvironment("dart.vm.product") == true) {
      //代表現在不是debug模式
      return;
    }
    switch (mode) {
      case LogMode.LogDebug:
        logger.d(log);
        break;
      case LogMode.LogError:
        logger.e(log);
        break;
    }
  }

  static myLog(LogMode mode, String data) {
    if (bool.fromEnvironment("dart.vm.product") == true) {
      //代表現在不是debug模式
      return;
    }
    String log;
    String nowLog = _getFileLogDebug();
    String printLog = "";
    String printMode = "";
    switch (mode) {
      case LogMode.LogDebug:
        printLog = _getFileLogDebug();
        printMode = "Debug";
        break;
      case LogMode.LogError:
        printLog = _getFileLogError();
        printMode = "Error";
        break;
    }
    if (_lastLog != nowLog) {
      print("\n\n");
      log = sprintf("LogLevel: %s \nClass : %s \nMessage : \n%s",
          [printMode, printLog, data]);
    } else {
      log = sprintf("%s", [data]);
    }
    _lastLog = nowLog;
    _printWrapped(log);
  }

  static void _printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
  }

  static String _getFileLogError() {
    String log = buildLog(StackTrace.current.toString());
    return log;
  }

  static String _getFileLogDebug() {
    String log = StackTrace.current.toString();
    return log.split('\n')[3].replaceFirst("#3      ", "");
  }

  static String buildLog(String inputLog) {
    List<String> logList = inputLog.split("#");
    String log = "";
    int size = (logList.length >= 20) ? 20 : logList.length;
    for (String logItem in logList.sublist(0, size)) {
      log += '#' + logItem + "\n";
    }
    return log;
  }
}
