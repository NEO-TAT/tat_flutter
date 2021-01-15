import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:flutter_app/ui/pages/coursedetail/CourseDetailPage.dart';
import 'package:flutter_app/ui/pages/coursedetail/screen/ischoolplus/IPlusAnnouncementDetailPage.dart';
import 'package:flutter_app/ui/pages/debug/DebugPage.dart';
import 'package:flutter_app/ui/pages/fileviewer/FileViewerPage.dart';
import 'package:flutter_app/ui/pages/other/page/AboutPage.dart';
import 'package:flutter_app/ui/pages/other/page/ContributorsPage.dart';
import 'package:flutter_app/ui/pages/other/page/PrivacyPolicyPage.dart';
import 'package:flutter_app/ui/pages/other/page/SettingPage.dart';
import 'package:flutter_app/ui/pages/videoplayer/ClassVideoPlayer.dart';
import 'package:flutter_app/ui/pages/webview/WebViewPluginPage.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';
import 'package:get/get.dart';

class RouteUtils {
  static Future toLoginScreen() async {
    return await Get.to(
      LoginScreen(),
      transition: Transition.downToUp,
    );
  }

  static Future toFileViewerPage(String title, String path) async {
    return await Get.to(
        FileViewerPage(
          title: title,
          path: path,
        ),
        transition: Transition.downToUp);
  }

  static Future toISchoolPage(
      String studentId, CourseInfoJson courseInfo) async {
    return await Get.to(
      ISchoolPage(studentId, courseInfo),
      transition: Transition.downToUp,
    );
  }

  static Future toPrivacyPolicyPage() async {
    return await Get.to(
      PrivacyPolicyPage(),
      transition: Transition.downToUp,
    );
  }

  static Future toContributorsPage() async {
    return await Get.to(
      ContributorsPage(),
      transition: Transition.downToUp,
    );
  }

  static Future toAboutPage() async {
    return await Get.to(
      AboutPage(),
      transition: Transition.downToUp,
    );
  }

  static Future toSettingPage(PageController controller) async {
    return await Get.to(
      SettingPage(controller),
      transition: Transition.downToUp,
    );
  }

  static Future toWebViewPluginPage(String title, String url) async {
    return await Get.to(
      WebViewPluginPage(
        title: title,
        url: url,
      ),
      transition: Transition.downToUp,
    );
  }

  static toDebugPage() async {
    return await Get.to(
      DebugPage(),
      transition: Transition.downToUp,
    );
  }

  static toIPlusAnnouncementDetailPage(
      CourseInfoJson courseInfo, Map detail) async {
    return await Get.to(
      IPlusAnnouncementDetailPage(courseInfo, detail),
      transition: Transition.downToUp,
    );
  }

  static toVideoPlayer(
      String url, CourseInfoJson courseInfo, String name) async {
    return await Get.to(
      ClassVideoPlayer(url, courseInfo, name),
      transition: Transition.downToUp,
    );
  }
}
