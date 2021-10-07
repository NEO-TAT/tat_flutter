import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tat/src/connector/core/dio_connector.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/ui/pages/course_detail/course_detail_page.dart';
import 'package:tat/ui/pages/course_detail/screen/ischool_plus/iplus_announcement_detail_page.dart';
import 'package:tat/ui/pages/file_viewer/file_viewer_page.dart';
import 'package:tat/ui/pages/log_console/log_console.dart';
import 'package:tat/ui/pages/other/page/about_page.dart';
import 'package:tat/ui/pages/other/page/contributors_page.dart';
import 'package:tat/ui/pages/other/page/dev_page.dart';
import 'package:tat/ui/pages/other/page/privacy_policy_page.dart';
import 'package:tat/ui/pages/other/page/setting_page.dart';
import 'package:tat/ui/pages/other/page/store_edit_page.dart';
import 'package:tat/ui/pages/other/page/sub_system_page.dart';
import 'package:tat/ui/pages/video_player/class_video_player.dart';
import 'package:tat/ui/pages/web_view/web_view_page.dart';
import 'package:tat/ui/pages/web_view/web_view_plugin_page.dart';
import 'package:tat/ui/screen/login_screen.dart';

class RouteUtils {
  static Transition transition =
      (Platform.isAndroid) ? Transition.downToUp : Transition.cupertino;

  static Future<dynamic> toLoginScreen() async {
    return await Get.to(
      () => LoginScreen(),
      transition: transition,
    );
  }

  static Future<dynamic> toDevPage() async {
    return await Get.to(
      () => DevPage(),
      transition: transition,
    );
  }

  static Future<dynamic> toSubSystemPage(String title, String arg) async {
    return Get.to(
      () => SubSystemPage(
        title: title,
        arg: arg,
      ),
      transition: transition,
      preventDuplicates: false,
    );
  }

  static Future<dynamic> toFileViewerPage(String title, String path) async {
    return await Get.to(
      () => FileViewerPage(
        title: title,
        path: path,
      ),
      transition: transition,
    );
  }

  static Future<dynamic> toISchoolPage(
    String studentId,
    CourseInfoJson courseInfo,
  ) async {
    return await Get.to(
      () => ISchoolPage(studentId, courseInfo),
      transition: transition,
    );
  }

  static Future<dynamic> toPrivacyPolicyPage() async {
    return await Get.to(
      () => PrivacyPolicyPage(),
      transition: transition,
    );
  }

  static Future<dynamic> toContributorsPage() async {
    return await Get.to(
      () => ContributorsPage(),
      transition: transition,
    );
  }

  static Future<dynamic> toAboutPage() async {
    return await Get.to(
      () => AboutPage(),
      transition: transition,
    );
  }

  static Future<dynamic> toSettingPage(PageController controller) async {
    return await Get.to(
      () => SettingPage(controller),
      transition: transition,
    );
  }

  static Future<dynamic> toWebViewPluginPage(String title, String url) async {
    return await Get.to(
      () => WebViewPluginPage(
        title: title,
        url: url,
      ),
      transition: transition,
    );
  }

  static Future<dynamic> toWebViewPage(String title, String url) async {
    return await Get.to(
      () => WebViewPage(
        title: title,
        url: Uri.parse(url),
      ),
      transition: transition,
    );
  }

  static Future<dynamic> toLogConsolePage() async {
    return await Get.to(
      () => LogConsole(dark: true),
      transition: transition,
    );
  }

  static Future<dynamic> toStoreEditPage() async {
    return await Get.to(
      () => StoreEditPage(),
      transition: transition,
    );
  }

  static Future<dynamic> toAliceInspectorPage() async {
    DioConnector.dioInstance.alice.showInspector();
  }

  static Future<dynamic> toIPlusAnnouncementDetailPage(
    CourseInfoJson courseInfo,
    Map detail,
  ) async {
    return await Get.to(
      () => IPlusAnnouncementDetailPage(courseInfo, detail),
      transition: transition,
    );
  }

  static Future<dynamic> toVideoPlayer(
    String url,
    CourseInfoJson courseInfo,
    String name,
  ) async {
    return await Get.to(
      () => ClassVideoPlayer(url, courseInfo, name),
      transition: transition,
    );
  }
}
