import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

class AnalyticsUtils {
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static Future<void> logDownloadFileEvent() async {
    await analytics.logEvent(name: "file_download");
  }

  static Future<void> setScreenName(String name) async {
    await analytics.setCurrentScreen(
      screenName: name,
    );
  }
}
