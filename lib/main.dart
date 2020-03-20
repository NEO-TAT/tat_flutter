import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/providers/CategoryProvider.dart';
import 'package:flutter_app/src/providers/CoreProvider.dart';
import 'package:flutter_app/ui/screen/MainScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'debug/log/Log.dart';
import 'generated/l10n.dart';

Future<Null> main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  //runApp( MyApp() );
  runZoned(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => CoreProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: MyApp(),
      ),
    );
  }, onError: (dynamic exception, StackTrace stack,
      {dynamic context}) {
    Log.error( exception.toString() );
    Crashlytics.instance.recordError( exception, stack,
        context: context);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Locale myLocale = Localizations.localeOf(context);
    //Log.d( myLocale.toString() );
    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'TAT',
      home: MainScreen(),
    );
  }
}
