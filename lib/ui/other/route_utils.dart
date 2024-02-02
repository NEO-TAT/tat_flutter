// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/core/dio_connector.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:flutter_app/src/controllers/zuvio_auto_roll_call_schedule_controller.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/ui/pages/coursedetail/course_detail_page.dart';
import 'package:flutter_app/ui/pages/coursedetail/screen/ischoolplus/iplus_announcement_detail_page.dart';
import 'package:flutter_app/ui/pages/fileviewer/file_viewer_page.dart';
import 'package:flutter_app/ui/pages/logconsole/log_console.dart';
import 'package:flutter_app/ui/pages/other/page/about_page.dart';
import 'package:flutter_app/ui/pages/other/page/contributors_page.dart';
import 'package:flutter_app/ui/pages/other/page/dev_page.dart';
import 'package:flutter_app/ui/pages/other/page/privacy_policy_page.dart';
import 'package:flutter_app/ui/pages/other/page/setting_page.dart';
import 'package:flutter_app/ui/pages/other/page/sub_system_page.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/roll_call_dashboard_page.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/zuvio_login_page.dart';
import 'package:flutter_app/ui/pages/videoplayer/class_video_player.dart';
import 'package:flutter_app/ui/pages/webview/web_view_page.dart';
import 'package:flutter_app/ui/screen/login_screen.dart';
import 'package:flutter_app/ui/screen/main_screen.dart';
import 'package:get/get.dart';

import '../../src/model/coursetable/course.dart';

class RouteUtils {
  static Transition transition = (Platform.isAndroid) ? Transition.downToUp : Transition.cupertino;

  static Future? toLoginScreen() {
    return Get.off(
      () => const LoginScreen(),
      transition: transition,
    );
  }

  static Future? launchMainPage() => Get.offAll(
        () => const MainScreen(),
        transition: transition,
      );

  static Future? toDevPage() {
    return Get.to(
      () => const DevPage(),
      transition: transition,
    );
  }

  static Future? toSubSystemPage(String title, String arg) {
    return Get.to(
      () => SubSystemPage(
        title: title,
        arg: arg,
      ),
      transition: transition,
      preventDuplicates: false,
    );
  }

  static Future? toFileViewerPage(String title, String path) {
    return Get.to(
      () => FileViewerPage(
        title: title,
        path: path,
      ),
      transition: transition,
    );
  }

  static Future? toISchoolPage(String studentId, Course course) {
    return Get.to(
      () => ISchoolPage(studentId, course),
      transition: transition,
    );
  }

  static Future? toPrivacyPolicyPage() {
    return Get.to(
      () => const PrivacyPolicyPage(),
      transition: transition,
    );
  }

  static Future? toContributorsPage() {
    return Get.to(
      () => ContributorsPage(),
      transition: transition,
    );
  }

  static Future? toAboutPage() {
    return Get.to(
      () => const AboutPage(),
      transition: transition,
    );
  }

  static Future? toSettingPage(PageController controller) => Get.to(
        () => SettingPage(controller),
        transition: transition,
      );

  static Future<void> toWebViewPage({
    required Uri initialUrl,
    String? title,
    bool shouldUseAppCookies = false,
  }) =>
      WebViewPage.to(
        initialUrl: initialUrl,
        title: title,
        shouldUseAppCookies: shouldUseAppCookies,
      );

  static Future? toLogConsolePage() {
    return Get.to(
      () => LogConsole(dark: true),
      transition: transition,
    );
  }

  static Future toAliceInspectorPage() async {
    DioConnector.instance.getAlice(navigatorKey: Get.key).showInspector();
  }

  static Future? toIPlusAnnouncementDetailPage(Course course, Map detail) {
    return Get.to(
      () => IPlusAnnouncementDetailPage(course, detail),
      transition: transition,
    );
  }

  static Future? toVideoPlayer(String url, Course course, String name) => Get.to(
        () => ClassVideoPlayer(url, course, name),
        transition: transition,
      );

  static Future<void>? launchRollCallDashBoardPageAfterLogin() => (!isLoggedIntoZuvio())
      ? launchZuvioLoginPage(loginSuccessAction: () => launchRollCallDashBoardPage())
      : launchRollCallDashBoardPage();

  static Future<void>? launchRollCallDashBoardPage() {
    ZAutoRollCallScheduleController.to.getScheduledAutoRollCalls();
    return Get.to(
      () => const RollCallDashboardPage(),
      transition: transition,
      preventDuplicates: true,
    );
  }

  static Future<void>? launchZuvioLoginPage({
    LoginSuccessAction? loginSuccessAction,
  }) =>
      Get.to(
        () => ZuvioLoginPage(
          onLoginSuccess: () {
            Get.back();
            loginSuccessAction?.call();
          },
          onPageClose: () => Get.back(),
        ),
        transition: transition,
      );

  static bool isLoggedIntoZuvio() => ZAuthController.to.isLoggedIntoZuvio();
}
