// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:tat_core/tat_core.dart';

@immutable
@sealed
class WebViewPage {
  @literal
  const WebViewPage();

  static WebViewPage get to => Get.find();

  Future<List<Cookie>> _loadCookiesFrom(Uri url) {
    final cookieJar = DioConnector.instance.cookiesManager;
    return cookieJar.loadForRequest(url);
  }

  String _encodeToBase64(dynamic origin) => base64Encode(utf8.encode(origin.toString()));

  List<String> _encodeCookiesToBase64(List<Cookie> cookies) =>
      cookies.map((cookie) => _encodeToBase64(cookie)).toList();

  Future<String> _generateEncryptedRedirectReqPath({required Uri targetUrl}) async {
    final cookies = await _loadCookiesFrom(targetUrl);
    final encodedCookies = _encodeCookiesToBase64(cookies);
    final redirectReq = RedirectRequest(
      targetUrl: targetUrl.toString(),
      encodedCookies: encodedCookies,
    );

    final redirectReqJson =  json.encode(redirectReq.toJson());

    // DEV: TODO: should apply encrypt
    return _encodeToBase64(redirectReqJson);
  }

  /// Set [shouldUseAppCookies] to true if the [initialUrl] requires cookies stored in app.
  Future<void> call({required Uri initialUrl, bool shouldUseAppCookies = false}) async {
    if (shouldUseAppCookies) {
      final encryptedRedirectPath = await _generateEncryptedRedirectReqPath(targetUrl: initialUrl);
      // TODO: change target to redirect page and send the encryptedRedirectPath.
    }

    return Future.microtask(
      () => FlutterWebBrowser.openWebPage(
        url: initialUrl.toString(),
        customTabsOptions: CustomTabsOptions(
          colorScheme: Get.isDarkMode ? CustomTabsColorScheme.dark : CustomTabsColorScheme.light,
          instantAppsEnabled: true,
          showTitle: true,
          urlBarHidingEnabled: true,
          privateMode: true,
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
