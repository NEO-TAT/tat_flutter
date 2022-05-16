// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/util/cloud_messaging_utils.dart';
import 'package:flutter_app/ui/other/list_view_animator.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:flutter_app/ui/other/route_utils.dart';

enum OnListViewPress {
  cloudMessageToken,
  dioLog,
  appLog,
  backgroundServices,
}

class DevPage extends StatefulWidget {
  const DevPage({Key key}) : super(key: key);

  @override
  State<DevPage> createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  final List<Map> listViewData = [
    {
      "icon": Icons.vpn_key_outlined,
      "title": "Cloud Messaging Token",
      "color": Colors.green,
      "onPress": OnListViewPress.cloudMessageToken
    },
    {
      "icon": Icons.info_outline,
      "title": "Dio Log",
      "color": Colors.blue,
      "onPress": OnListViewPress.dioLog,
    },
    {
      "icon": Icons.info_outline,
      "title": "App Log",
      "color": Colors.yellow,
      "onPress": OnListViewPress.appLog,
    },
    {
      "icon": Icons.account_tree_outlined,
      "title": "Background Services",
      "color": Colors.red,
      "onPress": OnListViewPress.backgroundServices,
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  int pressTime = 0;

  void _onListViewPress(OnListViewPress value) async {
    switch (value) {
      case OnListViewPress.cloudMessageToken:
        String token = await CloudMessagingUtils.getToken();
        MyToast.show("$token copy");
        FlutterClipboard.copy(token);
        break;
      case OnListViewPress.dioLog:
        RouteUtils.toAliceInspectorPage();
        break;
      case OnListViewPress.appLog:
        RouteUtils.toLogConsolePage();
        break;
      case OnListViewPress.backgroundServices:
        RouteUtils.launchBackgroundServicesDebugPage();
        break;
      default:
        MyToast.show(R.current.noFunction);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.developerMode),
      ),
      body: ListView.separated(
        itemCount: listViewData.length,
        itemBuilder: (context, index) {
          Widget widget;
          widget = _buildAbout(listViewData[index]);
          return InkWell(
            child: WidgetAnimator(widget),
            onTap: () {
              _onListViewPress(listViewData[index]['onPress']);
            },
          );
        },
        separatorBuilder: (context, index) {
          // 顯示格線
          return Container(
            color: Colors.black12,
            height: 1,
          );
        },
      ),
    );
  }

  Container _buildAbout(Map data) {
    return Container(
      //color: Colors.yellow,
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            data['icon'],
            color: data['color'],
          ),
          const SizedBox(
            width: 20.0,
          ),
          Text(
            data['title'],
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
