import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/util/Constants.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  final PageController pageController;

  SettingPage(this.pageController);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Map<int, String> langMap = {LangEnum.en.index: "en", LangEnum.zh.index: "zh"};
  int selectLang;

  @override
  void initState() {
    selectLang = LanguageUtil.getLangIndex().index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.setting),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      R.current.languageSwitch,
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      R.current.willRestart,
                      style: TextStyle(fontSize: 16, color: Color(0xFF808080)),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 15, right: 15),
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
                        step: 1.0,
                        onDragCompleted: (handlerIndex, it, _) {
                          selectLang = it.toInt();
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
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    R.current.focusLogin,
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    R.current.focusLoginResult,
                    style: TextStyle(fontSize: 16, color: Color(0xFF808080)),
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
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.all(0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    R.current.autoAppCheck,
                    style: TextStyle(fontSize: 24),
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
            ),
            MediaQuery.of(context).platformBrightness !=
                    Constants.darkTheme.brightness
                ? SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.all(0),
                    title: Row(
                      children: <Widget>[
                        Text(
                          R.current.darkMode,
                          style: TextStyle(fontSize: 24),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                        ),
                        Icon(
                          Feather.moon,
                        ),
                      ],
                    ),
                    value: Provider.of<AppProvider>(context).theme ==
                            Constants.lightTheme
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
                : SizedBox(),
            MediaQuery.of(context).platformBrightness !=
                    Constants.darkTheme.brightness
                ? Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
