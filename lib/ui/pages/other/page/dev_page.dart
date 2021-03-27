import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/util/cloud_messaging_utils.dart';
import 'package:flutter_app/src/util/route_utils.dart';
import 'package:flutter_app/ui/other/listview_animator.dart';
import 'package:flutter_app/ui/other/my_toast.dart';

enum onListViewPress { CloudMessageToken, DioLog, AppLog, StoreEdit }

class DevPage extends StatefulWidget {
  @override
  _DevPageState createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  final List<Map> listViewData = [
    {
      "icon": Icons.vpn_key_outlined,
      "title": "Cloud Messaging Token",
      "color": Colors.green,
      "onPress": onListViewPress.CloudMessageToken
    },
    {
      "icon": Icons.info_outline,
      "title": "Dio Log",
      "color": Colors.blue,
      "onPress": onListViewPress.DioLog
    },
    {
      "icon": Icons.info_outline,
      "title": "App Log",
      "color": Colors.yellow,
      "onPress": onListViewPress.AppLog
    },
    {
      "icon": Icons.edit_outlined,
      "title": "Store Edit",
      "color": Colors.green,
      "onPress": onListViewPress.StoreEdit
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  int pressTime = 0;

  void _onListViewPress(onListViewPress value) async {
    switch (value) {
      case onListViewPress.CloudMessageToken:
        String token = await CloudMessagingUtils.getToken();
        MyToast.show(token + " copy");
        FlutterClipboard.copy(token);
        break;
      case onListViewPress.DioLog:
        RouteUtils.toAliceInspectorPage();
        break;
      case onListViewPress.AppLog:
        RouteUtils.toLogConsolePage();
        break;
      case onListViewPress.StoreEdit:
        RouteUtils.toStoreEditPage();
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
      padding:
          EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            data['icon'],
            color: data['color'],
          ),
          SizedBox(
            width: 20.0,
          ),
          Text(
            data['title'],
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
