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
  static List<String> errorLog = List();
  static List<String> debugLog = List();

  static void eWithStack(String data, String stack) {
    //用於顯示已用try catch的處理error
    String stackSplit = stack.split("#5").first;
    String error = data.substring(0, (data.length > 100) ? 100 : data.length) +
        "\n\n" +
        stackSplit;
    logger.e(data, stackSplit);
    addErrorLog(error);
  }

  static void error(String data, String stack) {
    //用於顯示無try catch的error
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
    logger.d(data);
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
}
