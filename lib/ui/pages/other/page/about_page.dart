// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/version/app_version.dart';
import 'package:flutter_app/src/version/update/app_update.dart';
import 'package:flutter_app/ui/other/list_view_animator.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:flutter_app/ui/other/route_utils.dart';

enum OnListViewPress { appUpdate, contribution, privacyPolicy, version, dev }

class AboutPage extends StatefulWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<Map> listViewData = [];

  static bool inDevMode = false;

  @override
  void initState() {
    super.initState();
    initList();
  }

  void initList() {
    listViewData = [];
    listViewData.addAll([
      {
        "icon": EvaIcons.refreshOutline,
        "title": R.current.checkVersion,
        "color": Colors.orange,
        "onPress": OnListViewPress.appUpdate
      },
      {
        "icon": EvaIcons.awardOutline,
        "title": R.current.Contribution,
        "color": Colors.lightGreen,
        "onPress": OnListViewPress.contribution
      },
      {
        "icon": EvaIcons.shieldOffOutline,
        "color": Colors.blueGrey,
        "title": R.current.PrivacyPolicy,
        "onPress": OnListViewPress.privacyPolicy
      },
      {
        "icon": EvaIcons.infoOutline,
        "color": Colors.blue,
        "title": R.current.versionInfo,
        "onPress": OnListViewPress.version
      }
    ]);
    _addDevListItem();
  }

  void _addDevListItem() {
    if (inDevMode) {
      setState(() {
        listViewData.add({
          "icon": EvaIcons.options,
          "color": Colors.amberAccent,
          "title": R.current.developerMode,
          "onPress": OnListViewPress.dev
        });
      });
    }
  }

  int pressTime = 0;

  void _onListViewPress(OnListViewPress value) async {
    switch (value) {
      case OnListViewPress.appUpdate:
        MyToast.show(R.current.checkingVersion);
        final result = await APPVersion.checkShouldUpdate();
        if (!result) {
          MyToast.show(R.current.isNewVersion);
        }
        break;
      case OnListViewPress.contribution:
        RouteUtils.toContributorsPage();
        break;
      case OnListViewPress.version:
        String mainVersion = await AppUpdate.getAppVersion();
        if (pressTime == 0) {
          MyToast.show(mainVersion);
        }
        pressTime++;
        Future.delayed(const Duration(seconds: 2)).then((_) {
          pressTime = 0;
        });
        if (pressTime > 3 && kDebugMode) {
          if (!inDevMode) {
            inDevMode = true;
            _addDevListItem();
          }
        }
        break;
      case OnListViewPress.privacyPolicy:
        RouteUtils.toPrivacyPolicyPage();
        break;
      case OnListViewPress.dev:
        RouteUtils.toDevPage();
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
        title: Text(R.current.about),
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
