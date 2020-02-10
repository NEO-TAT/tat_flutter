import 'package:flutter/material.dart';
import 'package:flutter_app/src/lang/lang.dart';
import 'package:step_slider/step_slider.dart';

class SettingPage extends StatefulWidget {
  final PageController pageController;

  SettingPage(this.pageController);

  @override
  _SettingPage createState() => _SettingPage();
}

class _SettingPage extends State<SettingPage> {
  Map<double, String> langMap = {0: "en", 1: "zh"};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
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
                      "語言切換",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      "將自動重啟並套用語言",
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
                        initialStep: Lang.getLangIndex() ,
                        snapMode: SnapMode.value(10),
                        hardSnap: true,
                        onStepChanged: (it) {
                          Lang.setLang( langMap[it] ).then( (_){
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
          ],
        ),
      ),
    );
  }
}
