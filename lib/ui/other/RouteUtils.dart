import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:flutter_app/ui/pages/coursedetail/CourseDetailPage.dart';
import 'package:flutter_app/ui/pages/coursedetail/screen/ischoolplus/IPlusAnnouncementDetailPage.dart';
import 'package:flutter_app/ui/pages/fileviewer/FileViewerPage.dart';
import 'package:flutter_app/ui/pages/logconsole/log_console.dart';
import 'package:flutter_app/ui/pages/other/page/AboutPage.dart';
import 'package:flutter_app/ui/pages/other/page/ContributorsPage.dart';
import 'package:flutter_app/ui/pages/other/page/DevPage.dart';
import 'package:flutter_app/ui/pages/other/page/PrivacyPolicyPage.dart';
import 'package:flutter_app/ui/pages/other/page/SettingPage.dart';
import 'package:flutter_app/ui/pages/other/page/StoreEditPage.dart';
import 'package:flutter_app/ui/pages/other/page/SubSystemPage.dart';
import 'package:flutter_app/ui/pages/videoplayer/ClassVideoPlayer.dart';
import 'package:flutter_app/ui/pages/webview/WebViewPage.dart';
import 'package:flutter_app/ui/pages/webview/WebViewPluginPage.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';
import 'package:get/get.dart';

class RouteUtils {
  static Transition transition =
      (Platform.isAndroid) ? Transition.downToUp : Transition.cupertino;

  static Future toLoginScreen() async {
    return await Get.to(
      () => LoginScreen(),
      transition: transition,
    );
  }

  static Future toDevPage() async {
    return await Get.to(
      () => DevPage(),
      transition: transition,
    );
  }

  static Future toSubSystemPage(String title, String arg) async {
    return Get.to(
        () => SubSystemPage(
              title: title,
              arg: arg,
            ),
        transition: transition,
        preventDuplicates: false //必免重覆頁面時不載入
        );
  }

  static Future toFileViewerPage(String title, String path) async {
    return await Get.to(
        () => FileViewerPage(
              title: title,
              path: path,
            ),
        transition: transition);
  }

  static Future toISchoolPage(
      String studentId, CourseInfoJson courseInfo) async {
    return await Get.to(
      () => ISchoolPage(studentId, courseInfo),
      transition: transition,
    );
  }

  static Future toPrivacyPolicyPage() async {
    return await Get.to(
      () => PrivacyPolicyPage(),
      transition: transition,
    );
  }

  static Future toContributorsPage() async {
    return await Get.to(
      () => ContributorsPage(),
      transition: transition,
    );
  }

  static Future toAboutPage() async {
    return await Get.to(
      () => AboutPage(),
      transition: transition,
    );
  }

  static Future toSettingPage(PageController controller) async {
    return await Get.to(
      () => SettingPage(controller),
      transition: transition,
    );
  }

  static Future toWebViewPluginPage(String title, String url) async {
    return await Get.to(
      () => WebViewPluginPage(
        title: title,
        url: url,
      ),
      transition: transition,
    );
  }

  static Future toWebViewPage(String title, String url) async {
    return await Get.to(
      () => WebViewPage(
        title: title,
        url: url,
      ),
      transition: transition,
    );
  }

  static Future toLogConsolePage() async {
    return await Get.to(
      () => LogConsole(dark: true),
      transition: transition,
    );
  }

  static Future toStoreEditPage() async {
    return await Get.to(
      () => StoreEditPage(),
      transition: transition,
    );
  }

  static Future toAliceInspectorPage() async {
    DioConnector.instance.alice.showInspector();
  }

  static Future toIPlusAnnouncementDetailPage(
      CourseInfoJson courseInfo, Map detail) async {
    return await Get.to(
      () => IPlusAnnouncementDetailPage(courseInfo, detail),
      transition: transition,
    );
  }

  static Future toVideoPlayer(
      String url, CourseInfoJson courseInfo, String name) async {
    return await Get.to(
      () => ClassVideoPlayer(url, courseInfo, name),
      transition: transition,
    );
  }
}
