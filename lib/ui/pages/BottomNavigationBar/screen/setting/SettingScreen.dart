import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/ui/icon/MyIcons.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/BottomNavigationBar/screen/internet/WebViewPluginScreen.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:random_color/random_color.dart';

import '../../../../../src/store/Model.dart';
import '../../../../../src/store/json/UserDataJson.dart';

enum onListViewPress { Setting, Logout, Report, About, ChangePassword }

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreen createState() => _SettingScreen();
}

class _SettingScreen extends State<SettingScreen> {
  final List<Map> listViewData = [
    {"icon": Icons.settings, "title": S.current.setting, "onPress": onListViewPress.Setting},
    {
      "icon": MyIcon.arrows_cw,
      "title": S.current.changePassword,
      "onPress": onListViewPress.ChangePassword
    },
    {"icon": MyIcon.logout, "title": S.current.logout , "onPress": onListViewPress.Logout},
    {"icon": Icons.report, "title": S.current.feedback , "onPress": onListViewPress.Report},
    {"icon": Icons.info, "title": S.current.about, "onPress": onListViewPress.About}
  ];

  String formUrl =
      "https://docs.google.com/forms/d/e/1FAIpQLSc3JFQECAA6HuzqybasZEXuVf8_ClM0UZYFjpPvMwtHbZpzDA/viewform";

  @override
  void initState() {
    super.initState();
  }

  void _onListViewPress(onListViewPress value) {
    switch (value) {
      case onListViewPress.Logout:
        Model.instance.logout();
        Navigator.of(context).push(CustomRoute(LoginPage()));
        break;
      case onListViewPress.About:
        EasyDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(
            S.current.aboutDialogString,
          ),
          description: Text(""),
          contentList: [
            Text(
              "Power by morris13579",
              textAlign: TextAlign.end,
            ),
          ],
        ).show(context);
        return;
        break;
      case onListViewPress.Report:
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: WebViewPluginScreen(S.current.feedback , formUrl),
          ),
        );
        break;
      default:
        MyToast.show(S.current.noFunction);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: ListView.separated(
        itemCount: listViewData.length + 1,
        itemBuilder: (context, index) {
          Widget widget;
          widget = (index == 0)
              ? _buildHeader()
              : _buildSetting(listViewData[index - 1]);
          return GestureDetector(
              behavior: HitTestBehavior.opaque, //讓透明部分有反應
              child: WidgetAnimator(widget),
              onTap: () {
                if (index != 0)
                  _onListViewPress(listViewData[index - 1]['onPress']);
              });
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

  Container _buildHeader() {
    UserInfoJson userInfo = Model.instance.userData.info;
    String givenName = userInfo.givenName;
    String userMail = userInfo.userMail;
    givenName = givenName ?? S.current.pleaseLogin;
    userMail = userMail ?? "";
    return Container(
      //color: Colors.yellow,
      margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      constraints: BoxConstraints(maxHeight: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 30.0,
            backgroundImage: NTUTConnector.getUserImage(),
          ),
          SizedBox(
            width: 10.0,
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  givenName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  userMail,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ])
        ],
      ),
    );
  }

  Container _buildSetting(Map data) {
    return Container(
      //color: Colors.yellow,
      padding:
          EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            data['icon'],
            color: RandomColor()
                .randomColor(colorSaturation: ColorSaturation.highSaturation),
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
