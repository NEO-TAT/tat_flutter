import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_themes.dart';
import 'package:tat/src/file/file_store.dart';
import 'package:tat/src/providers/app_provider.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/util/document_utils.dart';
import 'package:tat/src/util/language_utils.dart';
import 'package:tat/ui/other/listview_animator.dart';

class SettingPage extends StatefulWidget {
  final PageController pageController;

  SettingPage(this.pageController);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with AfterLayoutMixin<SettingPage> {
  late String downloadPath;

  @override
  void initState() {
    downloadPath = "";
    super.initState();
  }

  void _getDownloadPath() async {
    final path = await FileStore.findLocalPath(context);
    setState(() {
      downloadPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewData = [];
    listViewData.add(_buildLanguageSetting());
    if (Platform.isAndroid) {
      listViewData.add(_buildOpenExternalVideoSetting());
    }
    listViewData.add(_buildLoadIPlusNewsSetting());
    listViewData.add(_buildAutoCheckAppVersionSetting());
    listViewData.add(_buildDarkModeSetting());
    listViewData.add(_buildFolderPathSetting());
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.setting),
      ),
      body: ListView.separated(
        itemCount: listViewData.length,
        itemBuilder: (context, index) {
          final widget = listViewData[index];
          return Container(
            padding: EdgeInsets.only(top: 5, left: 20, right: 20),
            child: WidgetAnimator(widget),
          );
        },
        separatorBuilder: (context, index) {
          return Container(
            color: Colors.black12,
            height: 1,
          );
        },
      ),
    );
  }

  final textTitle = TextStyle(fontSize: 24);
  final textBody = TextStyle(fontSize: 16, color: Color(0xFF808080));

  Widget _buildLanguageSetting() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      value: (LanguageUtils.getLangIndex() == LangEnum.en),
      onChanged: (value) {
        setState(() {
          final langIndex = 1 - LanguageUtils.getLangIndex().index;
          LanguageUtils.setLangByIndex(LangEnum.values.toList()[langIndex]).then((_) {
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
        children: [
          Text(
            R.current.autoAppCheck,
            style: textTitle,
          ),
        ],
      ),
      value: Model.instance.getOtherSetting()!.autoCheckAppUpdate,
      onChanged: (value) {
        setState(() {
          Model.instance.getOtherSetting()!.autoCheckAppUpdate = value;
          Model.instance.saveOtherSetting();
        });
      },
    );
  }

  Widget _buildDarkModeSetting() {
    return (MediaQuery.of(context).platformBrightness != AppThemes.darkTheme.brightness)
        ? SwitchListTile.adaptive(
            contentPadding: EdgeInsets.all(0),
            title: Row(
              children: [
                Text(
                  R.current.darkMode,
                  style: textTitle,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                Icon(
                  Icons.dark_mode_outlined,
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
        children: [
          Text(
            R.current.checkIPlusNew,
            style: textTitle,
          ),
        ],
      ),
      value: Model.instance.getOtherSetting()!.checkIPlusNew,
      onChanged: (value) {
        setState(() {
          Model.instance.getOtherSetting()!.checkIPlusNew = value;
          Model.instance.saveOtherSetting();
        });
      },
    );
  }

  Widget _buildOpenExternalVideoSetting() {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      value: Model.instance.getOtherSetting()!.useExternalVideoPlayer,
      onChanged: (value) {
        setState(() {
          Model.instance.getOtherSetting()!.useExternalVideoPlayer = value;
          Model.instance.saveOtherSetting();
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
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      R.current.downloadPath,
                      style: textTitle,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
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
          final directory = await DocumentUtils.choiceFolder();
          if (directory != null) {
            setState(() {
              downloadPath = directory;
            });
          }
        },
      );
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _getDownloadPath();
  }
}
