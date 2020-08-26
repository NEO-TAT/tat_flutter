import 'dart:io';

class AppLink {
  static final String androidAppPackageName = "club.ntut.npc.tat";
  static final String _playStore =
      "https://play.google.com/store/apps/details?id=$androidAppPackageName";
  static final String _appleStore =
      "https://apps.apple.com/tw/app/id1513875597";
  static final String gitHub = "https://github.com/NEO-TAT/tat_flutter";
  static final String feedback =
      "https://docs.google.com/forms/d/e/1FAIpQLSc3JFQECAA6HuzqybasZEXuVf8_ClM0UZYFjpPvMwtHbZpzDA/viewform";
  static final String appUpdateCheck =
      "https://api.github.com/repos/NEO-TAT/tat_flutter/releases/latest";

  static String get storeLink {
    return (Platform.isAndroid) ? _playStore : _appleStore;
  }
}
