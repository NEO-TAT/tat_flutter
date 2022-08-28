// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/config/app_config.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:flutter_app/src/controllers/zuvio_course_controller.dart';
import 'package:flutter_app/src/controllers/zuvio_roll_call_monitor_controller.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/providers/category_provider.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/src/util/cloud_messaging_utils.dart';
import 'package:flutter_app/src/version/update/app_update.dart';
import 'package:flutter_app/ui/screen/main_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tat_core/tat_core.dart';

import 'debug/log/log.dart';
import 'generated/l10n.dart';

Future<void> main() async {
  // Pass all uncaught errors from the framework to Crashlytics.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await FirebaseAnalytics.instance.setDefaultEventParameters({
    'version': await AppUpdate.getAppVersion(),
  });

  await CloudMessagingUtils.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final zuvioApiService = ZuvioApiService();

  final zuvioLoginRepository = ZLoginRepository(apiService: zuvioApiService);
  final zStudentCourseListRepository = ZStudentCourseListRepository(apiService: zuvioApiService);
  final zGetRollCallRepository = ZGetRollCallRepository(apiService: zuvioApiService);
  final zMakeRollCallRepository = ZMakeRollCallRepository(apiService: zuvioApiService);

  final zuvioLoginUseCase = ZLoginUseCase(zuvioLoginRepository);
  final zuvioGetCourseListUseCase = ZGetStudentCourseListUseCase(zStudentCourseListRepository);
  final zuvioGetRollCallUseCase = ZGetRollCallUseCase(zGetRollCallRepository);
  final zuvioMakeRollCallUseCase = ZMakeRollCallUseCase(
    zGetRollCallRepository,
    zMakeRollCallRepository,
  );

  final firestore = FirebaseFirestore.instance;

  final zAuthController = ZAuthController(
    isLoginBtnEnabled: true,
    isInputBoxesEnabled: true,
    loginUseCase: zuvioLoginUseCase,
  );

  final zCourseController = ZCourseController(
    getCourseListUseCase: zuvioGetCourseListUseCase,
    firestore: firestore,
  );

  final zRollCallMonitorController = ZRollCallMonitorController(
    getRollCallUseCase: zuvioGetRollCallUseCase,
    makeRollCallUseCase: zuvioMakeRollCallUseCase,
    firestore: firestore,
  );

  runZonedGuarded(
    () {
      Get.put(zAuthController);
      Get.put(zCourseController);
      Get.put(zRollCallMonitorController);

      FirebaseAnalytics.instance.logAppOpen();

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ],
          child: const MyApp(),
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
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (BuildContext context, AppProvider appProvider, Widget child) {
      appProvider.navigatorKey = Get.key;
      return GetMaterialApp(
        title: AppConfig.appName,
        theme: appProvider.theme,
        darkTheme: AppThemes.darkTheme,
        localizationsDelegates: const [
          S.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate
        ],
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver(), AnalyticsUtils.observer],
        supportedLocales: S.delegate.supportedLocales,
        home: const MainScreen(),
        logWriterCallback: (String text, {bool isError}) {
          Log.d(text);
        },
      );
    });
  }
}
