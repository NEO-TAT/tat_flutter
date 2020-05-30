import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

bool _isShowing = false;
BuildContext _context, _dismissingContext;
bool _barrierDismissible = true;
String _dialogMessage = "Loading...";
String _progressString = "0/100";
double _progress = 0;

class ProgressRateDialog {
  _Body _dialog;

  ProgressRateDialog(BuildContext context, {bool isDismissible}) {
    _context = context;
    _barrierDismissible = isDismissible ?? true;
  }

  void update({String message, double nowProgress, String progressString}) {
    _progress = nowProgress ?? _progress;
    _dialogMessage = message ?? _dialogMessage;
    _progressString = progressString ?? _progressString;
    if (_isShowing) _dialog.update();
  }

  bool isShowing() {
    return _isShowing;
  }

  void dismiss() {
    if (_isShowing) {
      try {
        _isShowing = false;
        if (Navigator.of(_dismissingContext).canPop()) {
          Navigator.of(_dismissingContext).pop();
        }
      } catch (_) {}
    }
  }

  Future<bool> hide() {
    if (_isShowing) {
      try {
        _isShowing = false;
        Navigator.of(_dismissingContext).pop(true);
        return Future.value(true);
      } catch (_) {
        return Future.value(false);
      }
    } else {
      return Future.value(false);
    }
  }

  Future<bool> show() async {
    if (!_isShowing) {
      try {
        _dialog = new _Body();
        showDialog<dynamic>(
          context: _context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            _dismissingContext = context;
            return WillPopScope(
                onWillPop: () async => _barrierDismissible, child: _dialog);
          },
        );
        // Delaying the function for 200 milliseconds
        // [Default transitionDuration of DialogRoute]
        await Future.delayed(Duration(milliseconds: 200));
        _isShowing = true;
        return true;
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }
}

// ignore: must_be_immutable
class _Body extends StatefulWidget {
  _BodyState _dialog = _BodyState();

  update() {
    _dialog.update();
  }

  @override
  State<StatefulWidget> createState() {
    return _dialog;
  }
}

class _BodyState extends State<_Body> {
  update() {
    setState(() {});
  }

  @override
  void dispose() {
    _isShowing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(15.0),
          height: 100.0,
          decoration: ShapeDecoration(
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 5),
                  child: Text(
                    _dialogMessage,
                    textAlign: TextAlign.left,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                  value: _progress,
                ),
              ),
              Expanded(
                flex: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(sprintf("%d%", [(_progress * 100).toInt()]),
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.white)),
                    ),
                    Expanded(
                      child: Text(_progressString,
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
