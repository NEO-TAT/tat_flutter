import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/providers/AppProvider.dart';
import 'package:flutter_app/src/providers/CategoryProvider.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/util/Constants.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:step_slider/step_slider.dart';

class LanguagePage extends StatefulWidget {
  final PageController pageController;

  LanguagePage(this.pageController);

  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  Map<double, String> langMap = {0: "en", 1: "zh"};
  bool focusLogin;

  @override
  void initState() {
    super.initState();
    focusLogin = Model.instance.getOtherSetting().focusLogin;
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
                      StepSlider(
                        min: 0.0,
                        max: 1.0,
                        animCurve: Curves.fastLinearToSlowEaseIn,
                        animDuration: const Duration(milliseconds: 500),
                        steps: Set<double>()..add(0)..add(1),
                        initialStep:
                            LanguageUtil.getLangIndex().index.toDouble(),
                        snapMode: SnapMode.value(10),
                        hardSnap: true,
                        onStepChanged: (it) {
                          LanguageUtil.setLang(langMap[it]).then((_) {
                            widget.pageController.jumpToPage(0);
                            Navigator.of(context).pop();
                          });
                        },
                        // ... slider's other args
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
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
                ),
                Checkbox(
                  value: focusLogin,
                  onChanged: (bool value) {
                    setState(() {
                      focusLogin = value;
                      Model.instance.getOtherSetting().focusLogin = value;
                      Model.instance.saveOtherSetting();
                    });
                  },
                ),
              ],
            ),
            MediaQuery.of(context).platformBrightness != Constants.darkTheme.brightness
                ?SwitchListTile.adaptive(
              contentPadding: EdgeInsets.all(0),
              secondary: Icon(
                Feather.moon,
              ),
              title: Text(
                "Dark mode",
              ),
              value: Provider.of<AppProvider>(context).theme == Constants.lightTheme
                  ? false
                  : true,
              onChanged: (v){
                if (v) {
                  Provider.of<AppProvider>(context, listen: false)
                      .setTheme(Constants.darkTheme, "dark");
                } else {
                  Provider.of<AppProvider>(context, listen: false)
                      .setTheme(Constants.lightTheme, "light");
                }
              },
              activeColor: Theme.of(context).accentColor,
            ):SizedBox(),

            MediaQuery.of(context).platformBrightness != Constants.darkTheme.brightness
                ?Container(
              height: 1,
              color: Theme.of(context).dividerColor,
            ):SizedBox(),

          ],
        ),
      ),
    );
  }
}
