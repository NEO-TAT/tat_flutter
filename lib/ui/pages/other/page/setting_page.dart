// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_config.dart';
import 'package:flutter_app/src/config/app_themes.dart';
import 'package:flutter_app/src/file/file_store.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:flutter_app/ui/other/list_view_animator.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  final PageController pageController;

  const SettingPage(this.pageController, {super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? downloadPath;

  @override
  void initState() {
    downloadPath = "";
    super.initState();
    _getDownloadPath();
  }

  void _getDownloadPath() async {
    String path = await FileStore.findLocalPath();
    setState(() {
      downloadPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewData = [];

    listViewData.add(_buildLanguageSetting());
    listViewData.add(_buildLoadIPlusNewsSetting());
    listViewData.add(_buildDarkModeSetting());

    if (Platform.isAndroid) {
      listViewData.add(_buildOpenExternalVideoSetting());

      // TODO: ensure remote config fetched successfully then enable this line.
      // listViewData.add(_buildAndroidAllowPrivateBrowserGuide());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.setting),
      ),
      body: ListView.separated(
        itemCount: listViewData.length,
        itemBuilder: (context, index) {
          final widget = listViewData[index];
          return Container(
            padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
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

  final TextStyle textTitle = const TextStyle(fontSize: 24);
  final TextStyle textBody = const TextStyle(fontSize: 16, color: Color(0xFF808080));

  Widget _buildLanguageSetting() {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.all(0),
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
      value: (LanguageUtil.getLangIndex() == LangEnum.en),
      onChanged: (value) {
        setState(() {
          final int langIndex = 1 - LanguageUtil.getLangIndex().index;
          LanguageUtil.setLangByIndex(LangEnum.values.toList()[langIndex]).then((_) {
            widget.pageController.jumpToPage(0);
            Get.back();
          });
        });
      },
    );
  }

  Widget _buildDarkModeSetting() {
    return (MediaQuery.of(context).platformBrightness != AppThemes.darkTheme.brightness)
        ? SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.all(0),
            title: Row(
              children: [
                Text(
                  R.current.darkMode,
                  style: textTitle,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                ),
                const Icon(
                  FeatherIcons.moon,
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
        : const SizedBox();
  }

  Widget _buildLoadIPlusNewsSetting() {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.all(0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      contentPadding: const EdgeInsets.all(0),
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
      value: LocalStorage.instance.getOtherSetting().useExternalVideoPlayer,
      onChanged: (value) {
        setState(() {
          LocalStorage.instance.getOtherSetting().useExternalVideoPlayer = value;
          LocalStorage.instance.saveOtherSetting();
        });
      },
    );
  }

  // TODO: ensure remote config fetched successfully then enable this line.
  // ignore: unused_element
  Widget _buildAndroidAllowPrivateBrowserGuide() => ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              R.current.androidPrivateBrowseGuideTitle,
              style: textTitle,
            ),
            Text(
              R.current.androidPrivateBrowseGuideSubTitle,
              style: textBody,
            ),
          ],
        ),
        onTap: () async {
          final guidePageUrl = await AppConfig.androidChromeIncognitoFlagSetupPageUrl;
          if (guidePageUrl.isEmpty) {
            return;
          }

          final parsedGuidePageUrl = Uri.tryParse(guidePageUrl);

          if (parsedGuidePageUrl != null) {
            RouteUtils.toWebViewPage(initialUrl: parsedGuidePageUrl);
          }
        },
      );
}
