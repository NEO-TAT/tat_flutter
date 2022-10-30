// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/config/app_config.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:flutter_app/src/connector/blocked_cookies.dart';
import 'package:flutter_app/src/connector/interceptors/request_interceptor.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:flutter_app/src/controllers/zuvio_auto_roll_call_schedule_controller.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/providers/category_provider.dart';
import 'package:flutter_app/src/repositories/auto_roll_call_schedule_repository_impl.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/src/util/cloud_messaging_utils.dart';
import 'package:flutter_app/src/version/update/app_update.dart';
import 'package:flutter_app/ui/pages/webview/web_view_page.dart';
import 'package:flutter_app/ui/screen/main_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tat_core/tat_core.dart';

import 'debug/log/log.dart';
import 'generated/l10n.dart';

const String _kVersion = 'version';

Future<void> main() async {
  // Pass all uncaught errors from the framework to Crashlytics.
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  await FirebaseAnalytics.instance.setDefaultEventParameters({
    _kVersion: await AppUpdate.getAppVersion(),
  });

  await CloudMessagingUtils.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final zuvioApiService = ZuvioApiService();

  final appDocDir = (await getApplicationDocumentsDirectory()).path;
  final CookieJar cookieJar = PersistCookieJar(storage: FileStorage('$appDocDir/.cookies'));

  final apiInterceptors = [
    ResponseCookieFilter(blockedCookieNamePatterns: blockedCookieNamePatterns),
    CookieManager(cookieJar),
    RequestInterceptors(),
  ];

  final schoolApiService = SchoolApiService(interceptors: apiInterceptors);

  final zuvioLoginRepository = ZLoginRepository(apiService: zuvioApiService);
  final zStudentCourseListRepository = ZStudentCourseListRepository(apiService: zuvioApiService);
  final zGetRollCallRepository = ZGetRollCallRepository(apiService: zuvioApiService);
  final zMakeRollCallRepository = ZMakeRollCallRepository(apiService: zuvioApiService);

  final simpleLoginRepository = SimpleLoginRepository(apiService: schoolApiService);

  final zuvioLoginUseCase = ZLoginUseCase(zuvioLoginRepository);
  final zuvioGetCourseListUseCase = ZGetStudentCourseListUseCase(zStudentCourseListRepository);
  final zuvioGetRollCallUseCase = ZGetRollCallUseCase(zGetRollCallRepository);
  final zuvioMakeRollCallUseCase = ZMakeRollCallUseCase(
    zGetRollCallRepository,
    zMakeRollCallRepository,
  );

  final simpleLoginUseCase = SimpleLoginUseCase(simpleLoginRepository);

  final firebaseMessaging = FirebaseMessaging.instance;
  final firebaseAuth = FirebaseAuth.instance;

  await firebaseAuth.signInAnonymously();

  final autoRollCallScheduleRepository = AutoRollCallScheduleRepositoryImpl(
    firebaseAuth: firebaseAuth,
    firebaseMessaging: firebaseMessaging,
  );

  final addAutoRollCallScheduleUseCase = AddAutoRollCallScheduleUseCase(
    autoRollCallScheduleRepository,
  );

  final cancelAutoRollCallScheduleUseCase = CancelAutoRollCallScheduleUseCase(
    autoRollCallScheduleRepository,
  );

  final getMyAutoRollCallScheduleUseCase = GetMyAutoRollCallScheduleUseCase(
    autoRollCallScheduleRepository,
  );

  final enableAutoRollCallScheduleUseCase = EnableAutoRollCallScheduleUseCase(
    autoRollCallScheduleRepository,
  );

  final disableAutoRollCallScheduleUseCase = DisableAutoRollCallScheduleUseCase(
    autoRollCallScheduleRepository,
  );

  final zAuthController = ZAuthController(
    isLoginBtnEnabled: true,
    isInputBoxesEnabled: true,
    loginUseCase: zuvioLoginUseCase,
  );

  final zRollCallMonitorController = ZAutoRollCallScheduleController(
    getRollCallUseCase: zuvioGetRollCallUseCase,
    makeRollCallUseCase: zuvioMakeRollCallUseCase,
    getCourseListUseCase: zuvioGetCourseListUseCase,
    addAutoRollCallScheduleUseCase: addAutoRollCallScheduleUseCase,
    getMyAutoRollCallScheduleUseCase: getMyAutoRollCallScheduleUseCase,
    cancelAutoRollCallScheduleUseCase: cancelAutoRollCallScheduleUseCase,
    enableAutoRollCallScheduleUseCase: enableAutoRollCallScheduleUseCase,
    disableAutoRollCallScheduleUseCase: disableAutoRollCallScheduleUseCase,
  );

  const webViewPage = WebViewPage();

  Future<void> handleAppDetached() async {
    await webViewPage.close();
    await firebaseAuth.signOut();
  }

  WidgetsBinding.instance.addObserver(
    _TATLifeCycleEventHandler(detachedCallBack: handleAppDetached),
  );

  Get.put(webViewPage);
  Get.put(zAuthController);
  Get.put(zRollCallMonitorController);
  Get.put(simpleLoginUseCase);
  Get.put(cookieJar);

  Get.put(await availableCameras());

  Get.put(await openDatabase(
    join(await getDatabasesPath(), 'localDB.db'),
    onCreate: (db, version) {
      return db.execute('CREATE TABLE photo_storage ('
          '_id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'cursorId INTEGER, '
          'courseId TEXT, '
          'label TEXT, '
          'note TEXT, '
          'picturePath TEXT)');
    },
    version: 1,
  ));

  await LocalStorage.instance.init(httpClientInterceptors: apiInterceptors);

  runZonedGuarded(
    () {
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

typedef _FutureVoidCallBack = Future<void> Function();

class _TATLifeCycleEventHandler extends WidgetsBindingObserver {
  _TATLifeCycleEventHandler({
    @required _FutureVoidCallBack detachedCallBack,
  }) : _detachedCallBack = detachedCallBack;
  final _FutureVoidCallBack _detachedCallBack;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        await _detachedCallBack();
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }
}
