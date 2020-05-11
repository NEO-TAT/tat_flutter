import 'dart:io';
import 'package:after_init/after_init.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/util/Constants.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/pages/other/directory_picker/directory_picker.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  final PageController pageController;

  SettingPage(this.pageController);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with AfterInitMixin<SettingPage> {
  Map<int, String> langMap = {LangEnum.en.index: "en", LangEnum.zh.index: "zh"};
  int selectLang;
  String downloadPath;

  @override
  void initState() {
    downloadPath = "";
    selectLang = LanguageUtil.getLangIndex().index;
    super.initState();
  }

  @override
  void didInitState() {
    _getDownloadPath();
  }

  void _getDownloadPath() async {
    String path = await FileStore.findLocalPath(context);
    setState(() {
      downloadPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> listViewData = List();
    listViewData.add(_buildLanguageSetting());
    listViewData.add(_buildFocusLoginSetting());
    listViewData.add(_buildOpenExternalVideoSetting());
    listViewData.add(_buildLoadIPlusNewsSetting());
    listViewData.add(_buildAutoCheckAppVersionSetting());
    listViewData.add(_buildDarkModeSetting());
    if (Platform.isAndroid) listViewData.add(_buildFolderPathSetting());
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.setting),
      ),
      body: ListView.separated(
        itemCount: listViewData.length,
        itemBuilder: (context, index) {
          Widget widget;
          widget = listViewData[index];
          return Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: WidgetAnimator(widget),
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

  final TextStyle textTitle = TextStyle(fontSize: 24);
  final TextStyle textBody = TextStyle(fontSize: 16, color: Color(0xFF808080));

  Widget _buildLanguageSetting() {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              R.current.languageSwitch,
              style: textTitle,
            ),
            Text(
              R.current.willRestart,
              style: textBody,
            ),
          ],
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "EN",
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "中",
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              FlutterSlider(
                values: [selectLang.toDouble()],
                max: 1.0,
                min: 0.0,
                step: FlutterSliderStep(step: 1.0),
                onDragCompleted: (handlerIndex, it, _) {
                  int select = it.toInt();
                  if (selectLang == select) {
                    return;
                  } else {
                    selectLang = select;
                  }
                  print(langMap[selectLang].toString());
                  LanguageUtil.setLang(langMap[selectLang]).then((_) {
                    widget.pageController.jumpToPage(0);
                    Navigator.of(context).pop();
                  });
                  setState(() {});
                },
                tooltip: FlutterSliderTooltip(
                  disabled: true,
                ),
                handler: FlutterSliderHandler(
                  decoration: BoxDecoration(),
                  child: Material(
                    type: MaterialType.circle,
                    color: Colors.white,
                    elevation: 10,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.adjust,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFocusLoginSetting() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            R.current.focusLogin,
            style: textTitle,
          ),
          Text(
            R.current.focusLoginResult,
            style: textBody,
          ),
        ],
      ),
      value: Model.instance.getOtherSetting().focusLogin,
      onChanged: (value) {
        setState(() {
          Model.instance.getOtherSetting().focusLogin = value;
          Model.instance.saveOtherSetting();
        });
      },
      activeColor: Theme.of(context).accentColor,
    );
  }

  Widget _buildAutoCheckAppVersionSetting() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            R.current.autoAppCheck,
            style: textTitle,
          ),
        ],
      ),
      value: Model.instance.getOtherSetting().autoCheckAppUpdate,
      onChanged: (value) {
        setState(() {
          Model.instance.getOtherSetting().autoCheckAppUpdate = value;
          Model.instance.saveOtherSetting();
        });
      },
      activeColor: Theme.of(context).accentColor,
    );
  }

  Widget _buildDarkModeSetting() {
    return (MediaQuery.of(context).platformBrightness !=
            Constants.darkTheme.brightness)
        ? SwitchListTile.adaptive(
            contentPadding: EdgeInsets.all(0),
            title: Row(
              children: <Widget>[
                Text(
                  R.current.darkMode,
                  style: textTitle,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Icon(
                  Feather.moon,
                ),
              ],
            ),
            value:
                Provider.of<AppProvider>(context).theme == Constants.lightTheme
                    ? false
                    : true,
            onChanged: (v) {
              if (v) {
                Provider.of<AppProvider>(context, listen: false)
                    .setTheme(Constants.darkTheme, "dark");
              } else {
                Provider.of<AppProvider>(context, listen: false)
                    .setTheme(Constants.lightTheme, "light");
              }
            },
            activeColor: Theme.of(context).accentColor,
          )
        : SizedBox();
  }

  Widget _buildLoadIPlusNewsSetting() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            R.current.checkIPlusNew,
            style: textTitle,
          ),
        ],
      ),
      value: Model.instance.getOtherSetting().checkIPlusNew,
      onChanged: (value) {
        setState(() {
          Model.instance.getOtherSetting().checkIPlusNew = value;
          Model.instance.saveOtherSetting();
        });
      },
      activeColor: Theme.of(context).accentColor,
    );
  }

  Widget _buildOpenExternalVideoSetting() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            R.current.openExternalVideo,
            style: textTitle,
          ),
          Text(
            R.current.openExternalVideoHint,
            style: textBody,
          ),
        ],
      ),
      value: Model.instance.getOtherSetting().useExternalVideoPlayer,
      onChanged: (value) {
        setState(() {
          Model.instance.getOtherSetting().useExternalVideoPlayer = value;
          Model.instance.saveOtherSetting();
        });
      },
      activeColor: Theme.of(context).accentColor,
    );
  }

  Widget _buildFolderPathSetting() {
    if (downloadPath.isEmpty) {
      return Container();
    } else {
      return InkWell(
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      R.current.downloadPath,
                      style: textTitle,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      downloadPath,
                      style: textBody,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () async {
          Directory newDirectory = await DirectoryPicker.pick(
            allowFolderCreation: true,
            context: context,
            rootDirectory: Directory(downloadPath),
          );
          FileStore.setFilePath(newDirectory).then((value) {
            if (value) {
              downloadPath = newDirectory.path;
              setState(() {});
            }
          });
        },
      );
    }
  }
}
