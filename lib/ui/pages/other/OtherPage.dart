import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/UserDataJson.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/fileviewer/FileViewerPage.dart';
import 'package:flutter_app/ui/pages/other/page/LanguagePage.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';
import 'package:flutter_app/ui/pages/webview/WebViewPluginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:page_transition/page_transition.dart';

import 'page/AboutPage.dart';

enum onListViewPress {
  Language,
  FileViewer,
  Logout,
  Report,
  About,
  ChangePassword
}

class OtherPage extends StatefulWidget {
  final PageController pageController;
  OtherPage(this.pageController);

  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  final List<Map> optionList = [
    {
      "icon": EvaIcons.globeOutline,
      "color": Colors.orange,
      "title": R.current.languageSetting,
      "onPress": onListViewPress.Language
    },
    {
      "icon": EvaIcons.downloadOutline,
      "color": Colors.yellow[700],
      "title": R.current.fileViewer,
      "onPress": onListViewPress.FileViewer
    },
//    {
//      "icon": EvaIcons.syncOutline,
//      "color": Colors.lightGreen,
//      "title": R.current.changePassword,
//      "onPress": onListViewPress.ChangePassword
//    },
    {
      "icon": EvaIcons.undoOutline,
      "color": Colors.teal[400],
      "title": R.current.logout,
      "onPress": onListViewPress.Logout
    },
    {
      "icon": EvaIcons.messageSquareOutline,
      "color": Colors.cyan,
      "title": R.current.feedback,
      "onPress": onListViewPress.Report
    },
    {
      "icon": EvaIcons.infoOutline,
      "color": Colors.lightBlue,
      "title": R.current.about,
      "onPress": onListViewPress.About
    }
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
        Model.instance.logout().then((_) {
          Navigator.of(context).push(CustomRoute(LoginScreen())).then((_) {
            widget.pageController.jumpToPage(0); //跳轉到第一頁
          });
        });
        break;
      case onListViewPress.FileViewer:
        FileStore.findLocalPath(context).then((filePath) {
          Navigator.of(context).push(
            PageTransition(
              type: PageTransitionType.leftToRight,
              child: FileViewerPage(
                title: R.current.fileViewer,
                path: filePath,
              ),
            ),
          );
        });
        break;
      case onListViewPress.About:
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: AboutPage(),
          ),
        );
        break;
      case onListViewPress.Language:
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: LanguagePage(widget.pageController),
          ),
        );
        break;
      case onListViewPress.Report:
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: WebViewPluginPage(R.current.feedback, formUrl),
          ),
        );
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
        title: Text(R.current.titleOther),
      ),
      body: AnimationLimiter(
        child: Container(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: <Widget>[
                _buildHeader(),
                SizedBox(height: 16,),
                for (Map option in optionList) _buildSetting(option),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    UserInfoJson userInfo = Model.instance.getUserInfo();
    String givenName = userInfo.givenName;
    String userMail = userInfo.userMail;
    givenName = (givenName.isEmpty) ? R.current.pleaseLogin : givenName;
    userMail = (userMail.isEmpty) ? "" : userMail;
    Widget userImage = NTUTConnector.getUserImage();
    return Container(
      color: Colors.white,
      padding:
          EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: userImage,
          ),
          SizedBox(
            width: 16.0,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetting(Map data) {
    return InkWell(
      child: Container(
        color: Colors.white,
        padding:
        EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 24.0),
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
      ),
    );
  }
}
