import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:rxdart/rxdart.dart';

class Notifications {
  Notifications._privateConstructor();

  static int idCount = 0;
  static final Notifications instance = Notifications._privateConstructor();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<ReceivedNotification>
      didReceiveLocalNotificationSubject =
      BehaviorSubject<ReceivedNotification>();
  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>();
  final String downloadChannelId = "Download";
  final String downloadChannelName = "Download";
  final String downloadChannelDescription = "Show Download Progress";
  List<int> idList = []; //紀錄以點擊id

  Future<void> init() async {
// needed if you intend to initialize in the `main` function
    WidgetsFlutterBinding.ensureInitialized();
    // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
    // change the default route of the app
    // var notificationAppLaunchDetails =
    //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      if (payload != null) {}
      selectNotificationSubject.add(payload);
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

  void _configureDidReceiveLocalNotificationSubject() {
    //IOS端接收到通知所作的處理的方法
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {});
  }

  void _configureSelectNotificationSubject() {
    //當通知窗被按下
    selectNotificationSubject.stream.listen((String payload) async {
      Map parse = json.decode(payload);
      String type = parse["type"];
      int id = parse["id"];
      if (!idList.contains(id)) {
        idList.add(parse["id"]);
      }
      switch (type) {
        case "download_complete":
          if (parse.containsKey("path")) {
            String path = parse["path"];
            Log.d("open $path");
            await OpenFile.open(path);
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

  Future<void> showProgressNotification(
      ReceivedNotification value, int maxProgress, int nowProgress) async {
    //顯示下載進度
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        downloadChannelId, downloadChannelName, downloadChannelDescription,
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: maxProgress,
        progress: nowProgress,
        playSound: false);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
        value.id, value.title, value.body, platformChannelSpecifics,
        payload: value.payload);
  }

  Future<void> showIndeterminateProgressNotification(
      ReceivedNotification value) async {
    //顯示未知下載進度
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        downloadChannelId, downloadChannelName, downloadChannelDescription,
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        indeterminate: true,
        playSound: false);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        value.id, value.title, value.body, platformChannelSpecifics,
        payload: value.payload);
  }

  Future<void> showNotification(ReceivedNotification value) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        downloadChannelId, downloadChannelName, downloadChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        ticker: 'ticker',
        playSound: false);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
        value.id, value.title, value.body, platformChannelSpecifics,
        payload: value.payload);
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  int get notificationId {
    return idCount++;
  }
}

class ReceivedNotification {
  int id;
  String _showTitle;
  String body;
  String payload;
  final _titleLong = 26;

  ReceivedNotification(
      {this.id,
      @required String title,
      @required this.body,
      @required this.payload}) {
    id = Notifications.instance.notificationId;
    this.title = title;
  }

  String get title {
    return _showTitle;
  }

  set title(String value) {
    String newTitle;
    if (value.length >= _titleLong) {
      newTitle = value.substring(0, _titleLong) + "...";
    }
    _showTitle = (value.length <= _titleLong) ? value : newTitle;
  }
}
