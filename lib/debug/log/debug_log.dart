// 🎯 Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:logging/logging.dart';

// 🌎 Project imports:
// import 'package:tat_core/src/strings.dart';

const debugFlagTAT = 'TAT';

/// log the target when not in production mode.
///
/// The debugTarget will be converted to string using `toString()` method when logging.
void debugLog(
  Object debugTarget, {
  DateTime? time,
  int? sequenceNumber,
  Level level = Level.ALL,
  String name = '',
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  final isTesting = Platform.environment.containsKey('FLUTTER_TEST');
  if (isTesting) {
    if (kDebugMode) {
      print('$debugFlagTAT $name $debugTarget');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  } else {
    log(
      debugTarget.toString(),
      time: time,
      sequenceNumber: sequenceNumber,
      level: level.value,
      name: '$debugFlagTAT $name',
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Create a log function which calls [debugLog] with [scopeName].
NamedLogFunction createNamedLog(String scopeName) => (Object object, {required String areaName}) => debugLog(
      object,
      name: '$scopeName $areaName',
    );

/// A [Function] which calls [debugLog] with the log [object].
///
/// An [areaName] should be provided for a more precise description of where the log occurs.
typedef NamedLogFunction = void Function(Object object, {required String areaName});
