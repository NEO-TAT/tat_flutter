// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/pages/webview/tat_web_view.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

@immutable
@sealed
class WebViewPage {
  @literal
  const WebViewPage();

  static WebViewPage get to => Get.find();

  Future<void> close() => FlutterWebBrowser.close();

  Future<void> _launchNativeWebView({required Uri initialUrl}) => Future.microtask(
        () => FlutterWebBrowser.openWebPage(
          url: initialUrl.toString(),
          customTabsOptions: CustomTabsOptions(
            colorScheme: Get.isDarkMode ? CustomTabsColorScheme.dark : CustomTabsColorScheme.light,
            instantAppsEnabled: true,
            showTitle: true,
            urlBarHidingEnabled: true,
            // Enable the Incognito mode on Android web view.
            // But should self-enable the `ALLOW_INCOGNITO_CUSTOM_TABS_FROM_THIRD_PARTY` flag on device's chrome.
            // chrome://flags/#cct-incognito-available-to-third-party
            privateMode: true,
          ),
          safariVCOptions: const SafariViewControllerOptions(
            barCollapsingEnabled: true,
            dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
          ),
        ).onError((error, stackTrace) {
          stackTrace.printError();

          FirebaseAnalytics.instance.logEvent(
            name: 'custom_tab_open_err_aos',
          );

          ErrorDialog(ErrorDialogParameter(
            desc: R.current.alertError,
            title: R.current.error,
            dialogType: DialogType.ERROR,
            offCancelBtn: true,
            btnOkText: R.current.sure,
          )).show();
        }),
      );

  Future<void> _launchTATWebView({
    required Uri initialUrl,
    String? title,
  }) =>
      Future.microtask(
        () => Get.to(
          () => TATWebView(
            initialUrl: initialUrl,
            title: title,
          ),
        ),
      );

  /// Launch a web view with configs.
  ///
  /// Set [shouldUseAppCookies] to true if the [initialUrl] requires cookies stored in app.
  /// When [shouldUseAppCookies] is true, the internal web view will be launched,
  /// otherwise we use the native web view.
  Future<void> call({
    required Uri initialUrl,
    String? title,
    bool shouldUseAppCookies = false,
  }) async {
    if (shouldUseAppCookies) {
      return _launchTATWebView(
        initialUrl: initialUrl,
        title: title,
      );
    }

    return _launchNativeWebView(initialUrl: initialUrl);
  }
}
