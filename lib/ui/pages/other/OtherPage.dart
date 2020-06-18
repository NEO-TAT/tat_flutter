import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/costants/AppLink.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/UserDataJson.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/fileviewer/FileViewerPage.dart';
import 'package:flutter_app/ui/pages/other/page/AboutPage.dart';
import 'package:flutter_app/ui/pages/other/page/SettingPage.dart';
import 'package:flutter_app/ui/pages/webview/WebViewPluginPage.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:page_transition/page_transition.dart';

enum onListViewPress {
  Setting,
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
  List<Map> optionList = [
    {
      "icon": EvaIcons.settings2Outline,
      "color": Colors.orange,
      "title": R.current.setting,
      "onPress": onListViewPress.Setting
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
      "icon": (Model.instance.getAccount().isEmpty)
          ? EvaIcons.logIn
          : EvaIcons.undoOutline,
      "color": Colors.teal[400],
      "title": (Model.instance.getAccount().isEmpty)
          ? R.current.login
          : R.current.logout,
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

  @override
  void initState() {
    super.initState();
  }

  void _onListViewPress(onListViewPress value) {
    switch (value) {
      case onListViewPress.Logout:
        if (Model.instance.getAccount().isNotEmpty) {
          ErrorDialogParameter parameter = ErrorDialogParameter(
              context: context,
              desc: R.current.logoutWarning,
              dialogType: DialogType.WARNING,
              title: R.current.warning,
              btnOkText: R.current.sure,
              btnOkOnPress: () {
                Model.instance.logout().then((_) {
                  widget.pageController.jumpToPage(0);
                });
              });
          ErrorDialog(parameter).show();
        } else {
          Navigator.of(context)
              .push(
            PageTransition(
              type: PageTransitionType.downToUp,
              child: LoginScreen(),
            ),
          )
              .then(
            (value) {
              if (value) widget.pageController.jumpToPage(0);
            },
          );
        }
        break;
      case onListViewPress.FileViewer:
        FileStore.findLocalPath(context).then((filePath) {
          Navigator.of(context).push(
            PageTransition(
              type: PageTransitionType.downToUp,
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
      case onListViewPress.Setting:
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: SettingPage(widget.pageController),
          ),
        );
        break;
      case onListViewPress.Report:
        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: WebViewPluginPage(R.current.feedback, AppLink.feedback),
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
                if (Model.instance.getAccount().isNotEmpty) _buildHeader(),
                SizedBox(
                  height: 16,
                ),
                for (Map option in optionList) _buildSetting(option)
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
    Map userImageInfo = NTUTConnector.getUserImage();
    Widget userImage = CachedNetworkImage(
      cacheManager: Model.instance.cacheManager,
      imageUrl: userImageInfo["url"],
      httpHeaders: userImageInfo["header"],
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 30.0,
        backgroundImage: imageProvider,
      ),
      useOldImageOnUrlChange: true,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) {
        Log.e(error.toString());
        return Icon(Icons.error);
      },
    );
    List<Widget> columnItem = List();
    if (givenName.isNotEmpty) {
      columnItem
        ..add(Text(
          givenName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ))
        ..add(SizedBox(
          height: 5.0,
        ))
        ..add(Text(
          userMail,
          style: TextStyle(
            fontSize: 16,
          ),
        ));
    } else {
      givenName = (givenName.isEmpty) ? R.current.pleaseLogin : givenName;
      userMail = (userMail.isEmpty) ? "" : userMail;
    }
    return Container(
      padding:
          EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: InkWell(
              child: userImage,
              onTap: () {
                Model.instance.cacheManager.emptyCache(); //清除圖片暫存
              },
            ),
          ),
          SizedBox(
            width: 16.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnItem,
          ),
        ],
      ),
    );
  }

  Widget _buildSetting(Map data) {
    return InkWell(
      onTap: () {
        _onListViewPress(data['onPress']);
      },
      child: Container(
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
