import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/costants/AppLink.dart';
import 'package:flutter_app/src/hotfix/AppHotFix.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:url_launcher/url_launcher.dart';

enum onListViewPress { AppUpdate, Contribution, Version, Patch }

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final List<Map> listViewData = [
    {
      "icon": EvaIcons.refreshOutline,
      "title": R.current.checkVersion,
      "color": Colors.orange,
      "onPress": onListViewPress.AppUpdate
    },
    {
      "icon": EvaIcons.awardOutline,
      "title": R.current.Contribution,
      "color": Colors.lightGreen,
      "onPress": onListViewPress.Contribution
    },
    {
      "icon": EvaIcons.infoOutline,
      "color": Colors.blue,
      "title": R.current.versionInfo,
      "onPress": onListViewPress.Version
    },
    {
      "icon": EvaIcons.infoOutline,
      "color": Colors.amberAccent,
      "title": R.current.patchVersion,
      "onPress": onListViewPress.Patch
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onListViewPress(onListViewPress value) async{
    switch (value) {
      case onListViewPress.AppUpdate:
        MyToast.show(R.current.checkingVersion);
        UpdateDetail value = await AppUpdate.checkUpdate();
        Model.instance.setAlreadyUse(Model.appCheckUpdate);
        if (value != null) {
          //檢查到app要更新
          AppUpdate.showUpdateDialog(context, value);
        } else {
          //檢查捕丁
          PatchDetail patch = await AppHotFix.checkPatchVersion();
          if (patch != null) {
            bool v = await AppHotFix.showUpdateDialog(context, patch);
            if (v) AppHotFix.downloadPatch(context,patch);
          }
        }
        break;
      case onListViewPress.Contribution:
        const url = AppLink.gitHub;
        launch(url);
        break;
      case onListViewPress.Version:
        AppUpdate.getAppVersion().then((version) {
          MyToast.show(version);
        });
        break;
      case onListViewPress.Patch:
        AppHotFix.getPatchVersion().then((version) {
          MyToast.show(version.toString());
        });
        break;
      default:
        MyToast.show(R.current.noFunction);
        break;
    }
  }

  void _onListViewLongPress(onListViewPress value) {
    switch (value) {
      case onListViewPress.Patch:
        AppHotFix.deleteHotFix().then((version) {
          MyToast.show("刪除補丁");
        });
        break;
      default:

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
            onLongPress: () {
              _onListViewLongPress(listViewData[index]['onPress']);
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
