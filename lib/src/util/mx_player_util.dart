import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class MXPlayerUtil {
  static String mxPlayerFreePackageName = "com.mxtech.videoplayer.ad";
  static String mxPlayerProPackageName = "com.mxtech.videoplayer.pro";

  static Future<bool> _androidLaunch(String url, [String name]) async {
    AndroidIntent intent;
    intent = AndroidIntent(
      action: 'action_view',
      data: url,
      type: "application/mpegurl",
      arguments: {"title": name ?? "video"},
    );
    try {
      await intent.launch();
    } catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> _iosLaunch(String url) async {
    try {
      if (await launchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> launch({String url, String name}) async {
    bool open = true;
    if (Platform.isAndroid) {
      open = await _androidLaunch(url, name);
    } else {
      open = await _iosLaunch(url);
    }
    if (!open) {
      MyToast.show(R.current.noSupportExternalVideoPlayer);
    }
    return open;
  }
}
