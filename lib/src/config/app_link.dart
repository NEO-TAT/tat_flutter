import 'dart:io';

class AppLink {
  static const androidAppPackageName = "club.ntut.npc.tat";

  static const _playStore =
      "https://play.google.com/store/apps/details?id=$androidAppPackageName";

  static const _appleStore = "https://apps.apple.com/tw/app/id1513875597";

  static const githubOwner = "NEO-TAT";

  static const githubName = "tat_flutter";

  static const gitHub = "https://github.com/$githubOwner/$githubName";

  static const feedbackBaseUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLSc3JFQECAA6HuzqybasZEXuVf8_ClM0UZYFjpPvMwtHbZpzDA/viewform";

  static const privacyPolicyUrl =
      "https://raw.githubusercontent.com/$githubOwner/$githubName/dev/privacy-policy.md";

  static String feedback(String mainVersion, String log) {
    final url = Uri.https(
        Uri.parse(feedbackBaseUrl).host, Uri.parse(feedbackBaseUrl).path, {
      "entry.978972557": (Platform.isAndroid) ? "Android" : "IOS",
      "entry.823909330": mainVersion,
      "entry.517392071": log,
    });

    return url.toString();
  }

  static String get storeLink {
    return (Platform.isAndroid) ? _playStore : _appleStore;
  }
}
