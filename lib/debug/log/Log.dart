//
//  Log.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';

enum LogMode { LogError, LogDebug }

class Log {
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
  static List<String> errorLog = List();
  static List<String> debugLog = List();

  static void eWithStack(String data, StackTrace stackTrace) {
    //用於顯示已用try catch的處理error
    String stack = stackTrace.toString();
    String stackSplit = stack.split("#5").first;
    String error = data.substring(0, (data.length > 100) ? 100 : data.length) +
        "\n\n" +
        stackSplit;
    logger.e(data, stackSplit);
    Crashlytics.instance.recordError(data, stackTrace);
    addErrorLog(error);
  }

  static void error(String data, StackTrace stackTrace) {
    //用於顯示無try catch的error
    String stack = stackTrace.toString();
    String stackSplit = stack.split("#5").first;
    String error = data.substring(0, (data.length > 100) ? 100 : data.length) +
        "\n\n" +
        stackSplit;
    logger.e(data, stackSplit);
    addErrorLog(error);
  }

  static void e(String data) {
    //用於顯示已用try catch的處理error
    String error = data.substring(0, (data.length > 100) ? 100 : data.length) +
        "\n\n" +
        StackTrace.current.toString().split("#5").first;
    logger.e(data);
    addErrorLog(error);
  }

  static void d(String data) {
    //用於debug的Log
    if (data.length <= 200) {
      logger.d(data);
    }
    addDebugLog(data);
  }

  static addErrorLog(String error) {
    errorLog.add(error);
    if (errorLog.length >= 30) {
      errorLog.removeAt(0);
    }
  }

  static addDebugLog(String error) {
    debugLog.add(error);
    if (debugLog.length >= 20) {
      debugLog.removeAt(0);
    }
  }

  static getLogString() {
    String log = "";
    log += 'error log \n';
    log = "";
    if (errorLog.length == 0) {
      return "目前沒有記錄到任何錯誤訊息";
    }
    for (String i in errorLog.reversed.toList()) {
      log += i;
    }
    log += 'debug log \n';
    for (String i in debugLog.reversed.toList()) {
      log += (i.length <= 200) ? i : i.substring(0, 200);
    }
    return (log.length <= 5000) ? log : log.substring(0, 5000);
  }
}
