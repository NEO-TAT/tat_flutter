import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tat/debug/log/log.dart';

class Notifications {
  Notifications._privateConstructor();

  static int idCount = 0;
  static final Notifications instance = Notifications._privateConstructor();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final didReceiveLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  final selectNotificationSubject = BehaviorSubject<String>();
  static const downloadChannelId = "Download";
  static const downloadChannelName = "Download";
  static const downloadChannelDescription = "Show Download Progress";
  final List<int> idList = [];

  Future<void> init() async {
    // needed if you intend to initialize in the `main` function
    WidgetsFlutterBinding.ensureInitialized();
    // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
    // change the default route of the app
    // var notificationAppLaunchDetails =
    //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    final initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    final initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id,
            title: title ?? '',
            body: body ?? '',
            payload: payload,
          ));
        });
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) {
      selectNotificationSubject.add(payload ?? '');
    });

    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // the process after ios received a notification
  // FIXME remove empty function
  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {});
  }

  // the callback of notification clicked
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      final parse = json.decode(payload);
      final type = parse["type"];
      final id = parse["id"];

      if (!idList.contains(id)) {
        idList.add(parse["id"]);
      }

      switch (type) {
        case "download_complete":
          if (parse.containsKey("path")) {
            final path = parse["path"];
            Log.d("open $path");
            await OpenFile.open(path);
          }
          break;
        case "download_fail":
        case "cloud_message_background":
        case "cloud_message":
        default:
          break;
      }
    });
  }

  // show current download progress
  Future<void> showProgressNotification(
    ReceivedNotification value,
    int maxProgress,
    int nowProgress,
  ) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      downloadChannelId,
      downloadChannelName,
      channelDescription: downloadChannelDescription,
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: maxProgress,
      progress: nowProgress,
      playSound: false,
    );

    final iOSPlatformChannelSpecifics = IOSNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      value.id!,
      value.title,
      value.body,
      platformChannelSpecifics,
      payload: value.payload,
    );
  }

  // show the download progress when it is an unknown progress
  Future<void> showIndeterminateProgressNotification(
    ReceivedNotification value,
  ) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      downloadChannelId,
      downloadChannelName,
      channelDescription: downloadChannelDescription,
      channelShowBadge: false,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      showProgress: true,
      indeterminate: true,
      playSound: false,
    );

    final iOSPlatformChannelSpecifics = IOSNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      value.id!,
      value.title,
      value.body,
      platformChannelSpecifics,
      payload: value.payload,
    );
  }

  Future<void> showNotification(ReceivedNotification value) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      downloadChannelId,
      downloadChannelName,
      channelDescription: downloadChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
      onlyAlertOnce: true,
      ticker: 'ticker',
      playSound: false,
    );

    final iOSPlatformChannelSpecifics = IOSNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      value.id!,
      value.title,
      value.body,
      platformChannelSpecifics,
      payload: value.payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  int get notificationId => idCount++;
}

class ReceivedNotification {
  int? id = Notifications.instance.notificationId;
  late final String _showTitle;
  late final String body;
  late final String? payload;
  final _titleLong = 26;

  ReceivedNotification({
    this.id,
    required String title,
    required this.body,
    this.payload,
  }) : _showTitle = title;

  String get title => _showTitle;

  set title(String value) {
    if (value.length >= _titleLong) {
      _showTitle = value.substring(0, _titleLong) + "...";
    } else {
      _showTitle = value;
    }
  }
}
