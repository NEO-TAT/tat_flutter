import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/config/AppConfig.dart';
import 'package:flutter_app/src/config/Appthemes.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/providers/CategoryProvider.dart';
import 'package:flutter_app/src/util/AnalyticsUtils.dart';
import 'package:flutter_app/src/util/CloudMessagingUtils.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/controllers/login_box_controller.dart';
import 'package:flutter_app/ui/screen/MainScreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tat_core/core/api/zuvio_api_service.dart';
import 'package:tat_core/core/zuvio/data/login_repository.dart';
import 'package:tat_core/core/zuvio/usecase/login_use_case.dart';

import 'debug/log/Log.dart';
import 'generated/l10n.dart';

Future<Null> main() async {
  // Pass all uncaught errors from the framework to Crashlytics.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await CloudMessagingUtils.init();
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  final zuvioApiService = ZuvioApiService();
  final zuvioLoginRepository = ZLoginRepository(apiService: zuvioApiService);
  final zuvioLoginUseCase = ZLoginUseCase(zuvioLoginRepository);

  final loginBoxController = LoginBoxController(
    isLoginBtnEnabled: true,
    isInputBoxesEnabled: true,
    loginUseCase: zuvioLoginUseCase,
  );

  runZonedGuarded(
    () {
      Get.put(loginBoxController);
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
            Provider.value(value: zuvioLoginUseCase, updateShouldNotify: (_, __) => false),
          ],
          child: MyApp(),
        ),
      );
    },
    (dynamic exception, StackTrace stack, {dynamic context}) {
      Log.error(exception.toString(), stack);
      FirebaseCrashlytics.instance.recordError(exception, stack);
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (BuildContext context, AppProvider appProvider, Widget child) {
      appProvider.navigatorKey = Get.key;
      return GetMaterialApp(
        title: AppConfig.appName,
        theme: appProvider.theme,
        darkTheme: AppThemes.darkTheme,
        localizationsDelegates: [
          S.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate
        ],
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver(), AnalyticsUtils.observer],
        supportedLocales: S.delegate.supportedLocales,
        home: MainScreen(),
        logWriterCallback: (String text, {bool isError}) {
          Log.d(text);
        },
      );
    });
  }
}
