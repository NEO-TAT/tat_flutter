import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rxdart/rxdart.dart';

class Notifications {
  Notifications._privateConstructor();

  static int idCount = 0;
  static final instance = Notifications._privateConstructor();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
  final selectNotificationSubject = BehaviorSubject<String>();
  final downloadChannelId = "Download";
  final downloadChannelName = "Download";
  final downloadChannelDescription = "Show Download Progress";
  final List<int> idList = [];

  Future<void> init() async {
    // needed if you intend to initialize in the `main` function
    WidgetsFlutterBinding.ensureInitialized();
    // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
    // change the default route of the app
    // final notificationAppLaunchDetails =
    //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    final initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ));
        });
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload != null) {
          selectNotificationSubject.add(payload);
        }
      },
    );

    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    //IOS端接收到通知所作的處理的方法
    didReceiveLocalNotificationSubject.stream.listen((ReceivedNotification receivedNotification) async {});
  }

  void _configureSelectNotificationSubject() {
    //當通知窗被按下
    selectNotificationSubject.stream.listen((String payload) async {
      final Map parse = json.decode(payload);
      final String type = parse["type"];
      final int id = parse["id"];
      if (!idList.contains(id)) {
        idList.add(parse["id"]);
      }
      switch (type) {
        case "download_complete":
          if (parse.containsKey("path")) {
            final String path = parse["path"];
            Log.d("open $path");
            await OpenFilex.open(path);
          }
          break;
        case "download_fail":
          break;
        case "cloud_message_background":
          break;
        case "cloud_message":
          break;
        default:
          break;
      }
    });
  }

  Future<void> showProgressNotification(ReceivedNotification value, int maxProgress, int nowProgress) async {
    //顯示下載進度
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
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(value.id, value.title, value.body, platformChannelSpecifics,
        payload: value.payload);
  }

  Future<void> showIndeterminateProgressNotification(ReceivedNotification value) async {
    //顯示未知下載進度
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
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      value.id,
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
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      value.id,
      value.title,
      value.body,
      platformChannelSpecifics,
      payload: value.payload,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  int get notificationId {
    return idCount++;
  }
}

class ReceivedNotification {
  ReceivedNotification({
    int? id,
    required String? title,
    required this.body,
    required this.payload,
  })  : id = id ?? Notifications.instance.notificationId,
        title = title != null ? (title.length > 26 ? "${title.substring(0, 26)}..." : title) : 'TAT';

  int id;
  String title;
  String? body;
  String? payload;

  ReceivedNotification copyWith({
    int? id,
    String? title,
    String? body,
    String? payload,
  }) =>
      ReceivedNotification(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body ?? this.body,
        payload: payload ?? this.payload,
      );
}
