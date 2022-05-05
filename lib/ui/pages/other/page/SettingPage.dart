import 'dart:io';

import 'package:after_init/after_init.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/Appthemes.dart';
import 'package:flutter_app/src/file/FileStore.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  final PageController pageController;

  SettingPage(this.pageController);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with AfterInitMixin<SettingPage> {
  String downloadPath;

  @override
  void initState() {
    downloadPath = "";
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
    List<Widget> listViewData = [];
    listViewData.add(_buildLanguageSetting());
    if (Platform.isAndroid) {
      listViewData.add(_buildOpenExternalVideoSetting());
    }
    listViewData.add(_buildLoadIPlusNewsSetting());
    listViewData.add(_buildAutoCheckAppVersionSetting());
    listViewData.add(_buildDarkModeSetting());
    if (Platform.isAndroid) {
      listViewData.add(_buildFolderPathSetting());
    }
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
            padding: EdgeInsets.only(top: 5, left: 20, right: 20),
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
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.all(0),
      title: Column(
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
      value: (LanguageUtil.getLangIndex() == LangEnum.en),
      onChanged: (value) {
        setState(() {
          int langIndex = 1 - LanguageUtil.getLangIndex().index;
          LanguageUtil.setLangByIndex(LangEnum.values.toList()[langIndex]).then((_) {
            widget.pageController.jumpToPage(0);
            Get.back();
          });
        });
      },
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
      value: LocalStorage.instance.getOtherSetting().autoCheckAppUpdate,
      onChanged: (value) {
        setState(() {
          LocalStorage.instance.getOtherSetting().autoCheckAppUpdate = value;
          LocalStorage.instance.saveOtherSetting();
        });
      },
    );
  }

  Widget _buildDarkModeSetting() {
    return (MediaQuery.of(context).platformBrightness != AppThemes.darkTheme.brightness)
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
            value: Provider.of<AppProvider>(context).theme == AppThemes.lightTheme ? false : true,
            onChanged: (v) {
              if (v) {
                Provider.of<AppProvider>(context, listen: false).setTheme(AppThemes.darkTheme, "dark");
              } else {
                Provider.of<AppProvider>(context, listen: false).setTheme(AppThemes.lightTheme, "light");
              }
            },
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
      value: LocalStorage.instance.getOtherSetting().checkIPlusNew,
      onChanged: (value) {
        setState(() {
          LocalStorage.instance.getOtherSetting().checkIPlusNew = value;
          LocalStorage.instance.saveOtherSetting();
        });
      },
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
      value: LocalStorage.instance.getOtherSetting().useExternalVideoPlayer,
      onChanged: (value) {
        setState(() {
          LocalStorage.instance.getOtherSetting().useExternalVideoPlayer = value;
          LocalStorage.instance.saveOtherSetting();
        });
      },
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
          String directory = await FilePicker.platform.getDirectoryPath();
          if (directory == "/" || directory == null) {
            if (directory == '/') {
              MyToast.show(R.current.selectDirectoryFail);
            }
          } else {
            await FileStore.setFilePath(directory);
            setState(() {
              downloadPath = directory;
            });
          }
        },
      );
    }
  }
}
