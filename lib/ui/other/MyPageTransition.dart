import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

class MyPage {
  static Route transition(Widget widget,
      {PageTransitionType type = PageTransitionType.downToUp}) {
    return (Platform.isAndroid)
        ? PageTransition(
            type: type,
            child: widget,
          )
        : CupertinoPageRoute(builder: (BuildContext context) {
            return widget; //新打开的还是本控件,可无限重复打开
          });
  }
}
