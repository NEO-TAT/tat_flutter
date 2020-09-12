import 'dart:io';

class AppLink {
  static final String androidAppPackageName = "club.ntut.npc.tat";
  static final String _playStore =
      "https://play.google.com/store/apps/details?id=$androidAppPackageName";
  static final String _appleStore =
      "https://apps.apple.com/tw/app/id1513875597";
  static final String gitHub = "https://github.com/NEO-TAT/tat_flutter";
  static final String feedbackBaseUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLSc3JFQECAA6HuzqybasZEXuVf8_ClM0UZYFjpPvMwtHbZpzDA/viewform";
  static final String appUpdateCheck =
      "https://api.github.com/repos/NEO-TAT/tat_flutter/releases/latest";

  static String feedback(String mainVersion, String log) {
    Uri url = Uri.https(
        Uri.parse(feedbackBaseUrl).host, Uri.parse(feedbackBaseUrl).path, {
      "entry.978972557": (Platform.isAndroid) ? "Android" : "IOS",
      "entry.823909330": mainVersion,
      "entry.517392071": log
    });
    return url.toString();
  }

  static String get storeLink {
    return (Platform.isAndroid) ? _playStore : _appleStore;
  }
}
