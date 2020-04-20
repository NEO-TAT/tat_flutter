import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

bool _isShowing = false;
BuildContext _context, _dismissingContext;
bool _barrierDismissible = true;
String _dialogMessage = "Loading...";
String _progressString = "0/100";
double _progress = 0;

class DynamicDialog {
  _Body _dialog;

  DynamicDialog(BuildContext context, {bool isDismissible}) {
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
              onWillPop: () async => _barrierDismissible,
              child: Dialog(
                  insetAnimationDuration: Duration(milliseconds: 100),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: _dialog),
            );
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
    return Container(
      height: 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(_dialogMessage),
          LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(Colors.blue),
            value: _progress,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(_progressString, textAlign: TextAlign.center),
              ),
            ],
          )
        ],
      ),
    );
  }
}
