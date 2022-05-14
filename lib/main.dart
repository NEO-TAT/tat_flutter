// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/config/app_config.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:flutter_app/src/controllers/zuvio_course_controller.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/providers/category_provider.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/src/util/cloud_messaging_utils.dart';
import 'package:flutter_app/ui/screen/main_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:tat_core/tat_core.dart';

import 'debug/log/log.dart';
import 'generated/l10n.dart';

Future<void> main() async {
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
  final zStudentCourseListRepository = ZStudentCourseListRepository(apiService: zuvioApiService);

  final zuvioLoginUseCase = ZLoginUseCase(zuvioLoginRepository);
  final zuvioGetCourseListUseCase = ZGetStudentCourseListUseCase(zStudentCourseListRepository);

  Get.put(await availableCameras());

  Get.put(await openDatabase(
    join(await getDatabasesPath(), 'localDB.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE photo_storage ('
              '_id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'cursorId INTEGER, '
              'courseId TEXT, '
              'label TEXT, '
              'picturePath TEXT)'
      );
    },
    version: 1,
  ));

  final zAuthController = ZAuthController(
    isLoginBtnEnabled: true,
    isInputBoxesEnabled: true,
    loginUseCase: zuvioLoginUseCase,
  );

  final zCourseController = ZCourseController(
    getCourseListUseCase: zuvioGetCourseListUseCase,
  );

  runZonedGuarded(
    () {
      Get.put(zAuthController);
      Get.put(zCourseController);
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
    return Consumer<AppProvider>(
        builder: (BuildContext context, AppProvider appProvider, Widget child) {
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
        navigatorObservers: [
          BotToastNavigatorObserver(),
          AnalyticsUtils.observer
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: const MainScreen(),
        logWriterCallback: (String text, {bool isError}) {
          Log.d(text);
        },
      );
    });
  }
}
