import 'dart:io';

class AppLink {
  static const String androidAppPackageName = "club.ntut.npc.tat";
  static const String _playStoreUrl = "https://play.google.com/store/apps/details?id=$androidAppPackageName";
  static const String _appleStoreUrl = "https://apps.apple.com/tw/app/id1513875597";

  static const String githubOwnerName = "NEO-TAT";
  static const String tatRepoName = "tat_flutter";

  static const String tatGitHubRepoUrlString = "https://github.com/$githubOwnerName/$tatRepoName";
  static const String privacyPolicyUrlString =
      'https://raw.githubusercontent.com/$githubOwnerName/$tatRepoName/dev/privacy-policy.md';

  // TODO: set this to be a remote-config.
  static final feedbackBaseUrl =
      Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSc3JFQECAA6HuzqybasZEXuVf8_ClM0UZYFjpPvMwtHbZpzDA/viewform');

  static Uri feedbackUrl(String mainVersion, String log) => Uri.https(
        feedbackBaseUrl.host,
        feedbackBaseUrl.path,
        {
          "entry.978972557": (Platform.isAndroid) ? "Android" : "IOS",
          "entry.823909330": mainVersion,
          "entry.517392071": log,
        },
      );

  static String get storeUrlString => (Platform.isAndroid) ? _playStoreUrl : _appleStoreUrl;
}
