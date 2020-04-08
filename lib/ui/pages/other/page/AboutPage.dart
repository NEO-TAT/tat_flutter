import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/costants/AppLink.dart';
import 'package:flutter_app/src/hotfix/AppHotFix.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/other/page/DevPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

enum onListViewPress { AppUpdate, Contribution, Version, Dev }

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<Map> listViewData = List();

  @override
  void initState() {
    super.initState();
    initList();
  }

  void initList() {
    listViewData = List();
    listViewData.addAll([
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
      }
    ]);
    _addDevListItem();
  }

  void _addDevListItem() {
    if(AppHotFix.inDevMode) {
      listViewData.add({
        "icon": EvaIcons.options,
        "color": Colors.amberAccent,
        "title": R.current.developerMode,
        "onPress": onListViewPress.Dev
      });
      setState(() {});
    }
  }

  int pressTime = 0;

  void _onListViewPress(onListViewPress value) async {
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
            if (v) AppHotFix.downloadPatch(context, patch);
          } else {
            MyToast.show(R.current.isNewVersion);
          }
        }
        break;
      case onListViewPress.Contribution:
        const url = AppLink.gitHub;
        launch(url);
        break;
      case onListViewPress.Version:
        String mainVersion = await AppUpdate.getAppVersion();
        int patchVersion = await AppHotFix.getPatchVersion();
        MyToast.show(sprintf("%s.%d", [mainVersion, patchVersion]));
        if (!AppHotFix.inDevMode) {
          pressTime++;
          Future.delayed(Duration(seconds: 2)).then((_) {
            pressTime = 0;
          });
          print(pressTime.toString());
          if (pressTime > 3) {
            AppHotFix.setDevMode(true);
            _addDevListItem();
          }
        }
        break;
      case onListViewPress.Dev:
        Navigator.of(context)
            .push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: DevPage(),
          ),
        )
            .then((v) {
          if (v != null) {
            initList();
          }
        });
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
