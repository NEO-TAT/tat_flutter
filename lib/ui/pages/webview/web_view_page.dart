// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/foundation.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

@immutable
@sealed
class WebViewPage {
  @literal
  const WebViewPage();

  static WebViewPage get to => Get.find();

  Future<void> _setInitialCookiesFrom(Uri url) async {
    final cookieJar = DioConnector.instance.cookiesManager;
    final cookies = await cookieJar.loadForRequest(url);
  }

  Future<void> call({required Uri initialUrl}) async {
    await _setInitialCookiesFrom(initialUrl);

    return Future.microtask(
      () => FlutterWebBrowser.openWebPage(
        url: initialUrl.toString(),
        customTabsOptions: CustomTabsOptions(
          colorScheme: Get.isDarkMode ? CustomTabsColorScheme.dark : CustomTabsColorScheme.light,
          instantAppsEnabled: true,
          showTitle: true,
          urlBarHidingEnabled: true,
        ),
        safariVCOptions: const SafariViewControllerOptions(
          barCollapsingEnabled: true,
          dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        ),
      ),
    );
  }

  Future<void> close() => FlutterWebBrowser.close();
}
