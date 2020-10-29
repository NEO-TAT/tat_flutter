import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/providers/CategoryProvider.dart';
import 'package:flutter_app/ui/screen/MainScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'debug/log/Log.dart';
import 'generated/l10n.dart';

Future<Null> main() async {
  // Pass all uncaught errors from the framework to Crashlytics.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runZoned(() {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ],
        child: MyApp(),
      ),
    );
  }, onError: (dynamic exception, StackTrace stack, {dynamic context}) {
    Log.error(exception.toString(), stack);
    FirebaseCrashlytics.instance.recordError(exception, stack);
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
        GlobalMaterialLocalizations.delegate
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'TAT',
      home: MainScreen(),
    );
  }
}
