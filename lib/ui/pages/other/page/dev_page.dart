// ignore_for_file: import_of_legacy_library_into_null_safe

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
}

class DevPage extends StatelessWidget {
  const DevPage({super.key});

  final List<Map> listViewData = const [
    {
      "icon": Icons.vpn_key_outlined,
      "title": "Cloud Messaging Token",
      "color": Colors.green,
      "onPress": OnListViewPress.cloudMessageToken
    },
    {"icon": Icons.info_outline, "title": "Dio Log", "color": Colors.blue, "onPress": OnListViewPress.dioLog},
    {"icon": Icons.info_outline, "title": "App Log", "color": Colors.yellow, "onPress": OnListViewPress.appLog},
  ];

  void _onListViewPress(OnListViewPress value) async {
    switch (value) {
      case OnListViewPress.cloudMessageToken:
        final token = await CloudMessagingUtils.getToken();
        MyToast.show("$token copy");
        FlutterClipboard.copy(token);
        break;
      case OnListViewPress.dioLog:
        RouteUtils.toAliceInspectorPage();
        break;
      case OnListViewPress.appLog:
        RouteUtils.toLogConsolePage();
        break;
      default:
        MyToast.show(R.current.noFunction);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(R.current.developerMode),
        ),
        body: ListView.separated(
          itemCount: listViewData.length,
          itemBuilder: (context, index) => InkWell(
            child: WidgetAnimator(_buildAbout(listViewData[index])),
            onTap: () => _onListViewPress(listViewData[index]['onPress']),
          ),
          separatorBuilder: (context, index) {
            return Container(
              color: Colors.black12,
              height: 1,
            );
          },
        ),
      );

  Widget _buildAbout(Map data) => Container(
        //color: Colors.yellow,
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
