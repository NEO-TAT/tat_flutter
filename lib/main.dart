import 'package:flutter/material.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/bottom_navigation_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'database/DataModel.dart';
import 'database/dataformat/UserData.dart';
import 'generated/i18n.dart';
import 'ui/pages/login/LoginPage.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => DataModel.instance,
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          S.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        localeResolutionCallback: S.delegate.resolution(fallback: const Locale('zh' , 'TW' )),
        title: 'Navigation Basics',
        //home: BottomNavigationWidget(),
        home: BottomNavigationWidget(),
    );
  }
}

