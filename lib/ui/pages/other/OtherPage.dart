import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppLink.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/TaskFlow.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/src/version/update/AppUpdate.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/other/RouteUtils.dart';
import 'package:flutter_app/ui/pages/logconsole/log_console.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

enum onListViewPress {
  Setting,
  FileViewer,
  Logout,
  Report,
  About,
  Login,
  SubSystem,
  RollCallRemind,
}

class OtherPage extends StatefulWidget {
  final PageController pageController;

  OtherPage(this.pageController);

  @override
  _OtherPageState createState() => _OtherPageState();
}

class _OtherPageState extends State<OtherPage> {
  final optionList = [
    {
      "icon": EvaIcons.settings2Outline,
      "color": Colors.orange,
      "title": R.current.setting,
      "onPress": onListViewPress.Setting
    },
    {
      "icon": Icons.computer,
      "color": Colors.lightBlue,
      "title": R.current.informationSystem,
      "onPress": onListViewPress.SubSystem
    },
    {
      "icon": Icons.access_alarm,
      "color": Colors.red,
      "title": R.current.rollCallRemind,
      "onPress": onListViewPress.RollCallRemind,
    },
    {
      "icon": EvaIcons.downloadOutline,
      "color": Colors.yellow[700],
      "title": R.current.fileViewer,
      "onPress": onListViewPress.FileViewer
    },
    if (LocalStorage.instance.getPassword().isNotEmpty)
      {
        "icon": EvaIcons.undoOutline,
        "color": Colors.teal[400],
        "title": R.current.logout,
        "onPress": onListViewPress.Logout
      },
    if (LocalStorage.instance.getPassword().isEmpty)
      {
        "icon": EvaIcons.logIn,
        "color": Colors.teal[400],
        "title": R.current.login,
        "onPress": onListViewPress.Login,
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

  void _onListViewPress(onListViewPress value) async {
    switch (value) {
      case onListViewPress.SubSystem:
        RouteUtils.toSubSystemPage(R.current.informationSystem, null);
        break;
      case onListViewPress.Logout:
        ErrorDialogParameter parameter = ErrorDialogParameter(
            context: context,
            desc: R.current.logoutWarning,
            dialogType: DialogType.WARNING,
            title: R.current.warning,
            btnOkText: R.current.sure,
            btnOkOnPress: () {
              Get.back();
              TaskFlow.resetLoginStatus();
              LocalStorage.instance.logout().then((_) {
                widget.pageController.jumpToPage(0);
              });
            });
        ErrorDialog(parameter).show();
        break;
      case onListViewPress.Login:
        RouteUtils.toLoginScreen().then((value) {
          if (value) widget.pageController.jumpToPage(0);
        });
        break;
      case onListViewPress.FileViewer:
        FileStore.findLocalPath(context).then((filePath) {
          RouteUtils.toFileViewerPage(R.current.fileViewer, filePath);
        });
        break;
      case onListViewPress.About:
        RouteUtils.toAboutPage();
        break;
      case onListViewPress.Setting:
        RouteUtils.toSettingPage(widget.pageController);
        break;
      case onListViewPress.Report:
        String link = AppLink.feedbackBaseUrl;
        try {
          String mainVersion = await AppUpdate.getAppVersion();
          link = AppLink.feedback(mainVersion, LogConsole.getLog());
        } catch (e) {}
        RouteUtils.toWebViewPage(R.current.feedback, link);
        break;
      case onListViewPress.RollCallRemind:
        RouteUtils.launchRollCallDashBoardPage();
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
      body: Column(children: <Widget>[
        if (LocalStorage.instance.getAccount().isNotEmpty)
          SizedBox(
            child: FutureBuilder<Map<String, Map<String, String>>>(
              future: NTUTConnector.getUserImageRequestInfo(),
              builder: (_, snapshot) => snapshot.data != null ? _buildHeader(snapshot.data) : SizedBox.shrink(),
            ),
          ),
        SizedBox(
          height: 16,
        ),
        Container(
          child: Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: optionList.length,
                itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: ScaleAnimation(
                    child: _buildSetting(optionList[index]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(Map userImageInfo) {
    final userInfo = LocalStorage.instance.getUserInfo();
    String givenName = userInfo.givenName;
    String userMail = userInfo.userMail;
    final userImage = CachedNetworkImage(
      cacheManager: LocalStorage.instance.cacheManager,
      imageUrl: userImageInfo["url"]["value"],
      httpHeaders: userImageInfo["header"],
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 40.0,
        backgroundImage: imageProvider,
      ),
      useOldImageOnUrlChange: true,
      placeholder: (context, url) => SpinKitRotatingCircle(color: Colors.white),
      errorWidget: (context, url, error) {
        Log.e(error.toString());
        return Icon(Icons.error);
      },
    );
    final columnItem = <Widget>[];
    final data = MediaQuery.of(context);
    if (givenName.isNotEmpty) {
      columnItem
        ..add(Text(
          givenName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ))
        ..add(SizedBox(
          height: 5.0,
        ))
        ..add(MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: Text(
            userMail,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ));
    } else {
      givenName = (givenName.isEmpty) ? R.current.pleaseLogin : givenName;
      userMail = (userMail.isEmpty) ? "" : userMail;
    }
    final taskFlow = TaskFlow();
    final task = NTUTTask("ImageTask");
    task.openLoadingDialog = false;
    taskFlow.addTask(task);
    return Container(
      padding: EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            child: InkWell(
              child: FutureBuilder<bool>(
                future: taskFlow.start(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data) {
                    return userImage;
                  }
                  return SpinKitRotatingCircle(color: Theme.of(context).colorScheme.secondary);
                },
              ),
              onTap: () {
                LocalStorage.instance.cacheManager.emptyCache(); //清除圖片暫存
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
        padding: EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 24.0),
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
