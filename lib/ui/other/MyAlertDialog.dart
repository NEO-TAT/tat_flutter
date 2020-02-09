import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:path/path.dart';

import 'CustomRoute.dart';

class MyAlertDialog {
  static void showAlertDialog(BuildContext context, String message) {
/*
    showDialog(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return _style2AlertDialog(context, message);
      },
    );

 */

    var dialog = CupertinoAlertDialog(
      content: Text(
        "你好,我是你蘋果爸爸的界面",
        style: TextStyle(fontSize: 20),
      ),
      actions: <Widget>[
        CupertinoButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoButton(
          child: Text("確定"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);

  }

  static Widget _simpleAlertDialog(BuildContext context, String message) {
    return AlertDialog(
      title: Row(children: <Widget>[
        Icon(Icons.warning, color: Colors.yellow, size: 32),
        SizedBox(
          width: 16,
        ),
        Text(S.current.warning),
      ]),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text('Regret'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static Widget _style1AlertDialog(BuildContext context, String message) {
    return FlareGiffyDialog(
      flarePath: 'assets/gif/error.gif',
      flareAnimation: 'loading',
      title: Text(
        S.of(context).alertError,
        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
      ),
      description: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(),
      ),
      onOkButtonPressed: () {},
    );
  }

  static Widget _style2AlertDialog(BuildContext context, String message) {
    return NetworkGiffyDialog(
      image: Image.asset("assets/gif/error.gif"),
      title: Text(S.of(context).alertError,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
      description: Text(
        message,
        textAlign: TextAlign.center,
      ),
      buttonOkText:
      Text("ok", style: TextStyle(fontSize: 18.0, color: Colors.white)),
      buttonCancelText:
      Text("clear", style: TextStyle(fontSize: 18.0, color: Colors.white)),
      onOkButtonPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

}
