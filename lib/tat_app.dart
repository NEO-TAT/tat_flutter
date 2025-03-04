// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:bot_toast/bot_toast.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/config/app_config.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:flutter_app/src/connector/blocked_cookies.dart';
import 'package:flutter_app/src/connector/interceptors/request_interceptor.dart';
import 'package:flutter_app/src/controllers/calendar_controller.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/providers/category_provider.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/ui/pages/webview/web_view_page.dart';
import 'package:flutter_app/ui/screen/main_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tat_core/core/api/interceptors/response_cookie_filter.dart';
import 'package:tat_core/core/api/school_api_service.dart';
import 'package:tat_core/core/portal/data/check_session_repository.dart';
import 'package:tat_core/core/portal/data/simple_login_repository.dart';
import 'package:tat_core/core/portal/usecase/check_session_use_case.dart';
import 'package:tat_core/core/portal/usecase/simple_login_use_case.dart';

typedef _FutureVoidCallBack = Future<void> Function();

Future<void> runTATApp() async {
  final firebaseAuth = FirebaseAuth.instance;

  await firebaseAuth.signInAnonymously();

  final appDocDir = (await getApplicationDocumentsDirectory()).path;
  final CookieJar cookieJar = PersistCookieJar(storage: FileStorage('$appDocDir/.cookies'));

  final apiInterceptors = [
    ResponseCookieFilter(blockedCookieNamePatterns: blockedCookieNamePatterns),
    CookieManager(cookieJar),
    RequestInterceptors(),
  ];

  final schoolApiService = SchoolApiService(interceptors: apiInterceptors);

  final simpleLoginRepository = SimpleLoginRepository(apiService: schoolApiService);
  final checkSessionRepository = CheckSessionRepository(apiService: schoolApiService);

  final simpleLoginUseCase = SimpleLoginUseCase(simpleLoginRepository);

  final checkSessionIsAliveUseCase = CheckSessionUseCase(checkSessionRepository);

  final calendarController = CalendarController();

  const webViewPage = WebViewPage();

  Future<void> handleAppDetached() async {
    await webViewPage.close();
    await firebaseAuth.signOut();
  }

  Get.put(webViewPage);
  Get.put(simpleLoginUseCase);
  Get.put(cookieJar);
  Get.put(calendarController);
  Get.put(checkSessionIsAliveUseCase);

  await LocalStorage.instance.init(httpClientInterceptors: apiInterceptors);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WidgetsBinding.instance.addObserver(
    _TATLifeCycleEventHandler(detachedCallBack: handleAppDetached),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const _TATApp(),
    ),
  );
}

class _TATApp extends StatelessWidget {
  const _TATApp();

  @override
  Widget build(BuildContext context) => Consumer<AppProvider>(
      builder: (context, appProvider, child) => GetMaterialApp(
            title: AppConfig.appName,
            theme: appProvider.theme,
            navigatorKey: appProvider.navigatorKey,
            darkTheme: AppThemes.darkTheme,
            localizationsDelegates: const [
              S.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate
            ],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
              child: BotToastInit().call(context, child),
            ),
            navigatorObservers: [BotToastNavigatorObserver(), AnalyticsUtils.observer],
            supportedLocales: S.delegate.supportedLocales,
            home: const MainScreen(),
            logWriterCallback: (String text, {bool? isError}) {
              Log.d(text);
            },
          ));
}

class _TATLifeCycleEventHandler extends WidgetsBindingObserver {
  _TATLifeCycleEventHandler({
    required _FutureVoidCallBack detachedCallBack,
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
