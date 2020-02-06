import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/ui/pages/BottomNavigationBar/screen/other/FileViewer/providers/app_provider.dart';
import 'package:flutter_app/ui/pages/BottomNavigationBar/screen/other/FileViewer/providers/category_provider.dart';
import 'package:flutter_app/ui/pages/BottomNavigationBar/screen/other/FileViewer/providers/core_provider.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/BottomNavigationWidget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sprintf/sprintf.dart';
import 'debug/log/Log.dart';
import 'generated/i18n.dart';
import 'ui/pages/login/LoginPage.dart';

Future<Null> main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    Log.error(details.toString());
  };
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
  }, onError: (Object obj, StackTrace stack) {
    String log = Log.buildLog(stack.toString());
    Log.error(sprintf("ErrorType : %s , %s", [obj.toString(), log]));
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
      //localeResolutionCallback: S.delegate.resolution(fallback: const  Locale('en' , "") ),
      title: 'Navigation Basics',
      home: Scaffold(
        body: BottomNavigationWidget(),
      ),
    );
  }
}

/*
MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,


      //localeResolutionCallback: S.delegate.resolution(fallback: const  Locale('en' , "") ),
      title: 'Navigation Basics',
      home: Scaffold(
        body: BottomNavigationWidget(),
      ),
    );
 */
