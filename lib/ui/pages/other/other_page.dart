import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_link.dart';
import 'package:tat/src/connector/ntut_connector.dart';
import 'package:tat/src/file/file_store.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/ntut/ntut_task.dart';
import 'package:tat/src/task/task_flow.dart';
import 'package:tat/src/util/route_utils.dart';
import 'package:tat/src/version/update/app_update.dart';
import 'package:tat/ui/other/error_dialog.dart';
import 'package:tat/ui/other/my_toast.dart';
import 'package:tat/ui/pages/log_console/log_console.dart';
import 'package:tat/ui/pages/password/change_password.dart';

enum onListViewPress { Setting, FileViewer, Logout, Report, About, Login, SubSystem, ChangePassword }

class OtherPage extends StatefulWidget {
  final PageController pageController;

  const OtherPage(this.pageController);

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
      "icon": EvaIcons.downloadOutline,
      "color": Colors.yellow[700],
      "title": R.current.fileViewer,
      "onPress": onListViewPress.FileViewer
    },
    if (Model.instance.getPassword().isNotEmpty)
      {
        "icon": EvaIcons.syncOutline,
        "color": Colors.lightGreen,
        "title": R.current.changePassword,
        "onPress": onListViewPress.ChangePassword
      },
    if (Model.instance.getPassword().isNotEmpty)
      {
        "icon": EvaIcons.undoOutline,
        "color": Colors.teal[400],
        "title": R.current.logout,
        "onPress": onListViewPress.Logout
      },
    if (Model.instance.getPassword().isEmpty)
      {"icon": EvaIcons.logIn, "color": Colors.teal[400], "title": R.current.login, "onPress": onListViewPress.Login},
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
        RouteUtils.toSubSystemPage(R.current.informationSystem, '');
        break;
      case onListViewPress.Logout:
        final parameter = ErrorDialogParameter(
            context: context,
            desc: R.current.logoutWarning,
            dialogType: DialogType.WARNING,
            title: R.current.warning,
            btnOkText: R.current.sure,
            btnOkOnPress: () {
              Get.back();
              TaskFlow.resetLoginStatus();
              Model.instance.logout().then((_) {
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
        RouteUtils.toWebViewPluginPage(R.current.feedback, link);
        break;
      case onListViewPress.ChangePassword:
        ChangePassword.show();
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
      body: Column(children: [
        if (Model.instance.getAccount().isNotEmpty)
          Container(
            child: _buildHeader(),
          ),
        SizedBox(
          height: 16,
        ),
        Container(
          child: Expanded(
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: optionList.length,
                itemBuilder: (BuildContext context, int index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: ScaleAnimation(
                      child: _buildSetting(optionList[index]),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader() {
    final userInfo = Model.instance.getUserInfo();
    String givenName = userInfo!.givenName;
    String userMail = userInfo.userMail;
    final userImageInfo = NTUTConnector.getUserImage();
    final userImage = CachedNetworkImage(
      cacheManager: Model.instance.cacheManager,
      imageUrl: userImageInfo["url"],
      httpHeaders: userImageInfo["header"],
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 40.0,
        backgroundImage: imageProvider,
      ),
      useOldImageOnUrlChange: true,
      errorWidget: (context, url, error) {
        Log.e(error.toString());
        return Icon(Icons.error);
      },
    );
    final List<Widget> columnItem = [];
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
    TaskFlow taskFlow = TaskFlow();
    var task = NTUTTask("ImageTask");
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
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                    return userImage;
                  } else {
                    return Container(color: Theme.of(context).accentColor);
                  }
                },
              ),
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
