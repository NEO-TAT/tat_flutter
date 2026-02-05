// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/firebase_options.dart';
import 'package:flutter_app/src/util/cloud_messaging_utils.dart';
import 'package:flutter_app/src/version/update/app_update.dart';
import 'package:flutter_app/tat_app.dart';

import 'debug/log/log.dart';

const String _kVersion = 'version';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Log.init();

  final firebaseOptions = ScopedFirebaseOptions.getCurrentPlatformOn(Environment.beta());
  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await FirebaseAnalytics.instance.setDefaultEventParameters({
    _kVersion: await AppUpdate.getAppVersion(),
  });

  await CloudMessagingUtils.init();

  await FirebaseAnalytics.instance.logAppOpen();

  runZonedGuarded(runTATApp, FirebaseCrashlytics.instance.recordError);
}
