import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as errorCode;
import 'package:local_auth/local_auth.dart';

class CheckPasswordDialog extends StatefulWidget {
  CheckPasswordDialog({Key key}) : super(key: key);

  @override
  _CheckPasswordDialogState createState() => _CheckPasswordDialogState();
}

class _CheckPasswordDialogState extends State<CheckPasswordDialog> {
  final TextEditingController _originPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _originPasswordFocus = new FocusNode();
  String _originPasswordErrorMessage = "";

  @override
  void initState() {
    checkAuth();
    super.initState();
  }

  void checkAuth() async {
    LocalAuthentication localAuthentication = LocalAuthentication();
    try {
      bool didAuthenticate = await localAuthentication.authenticate(
          localizedReason: R.current.checkIdentity, useErrorDialogs: false);
      if (didAuthenticate) {
        Get.back<bool>(result: true);
      }
    } on PlatformException catch (e) {
      Log.d(e.code);
      switch (e.code) {
        case errorCode.passcodeNotSet:
          break;
        case errorCode.lockedOut:
          break;
        case errorCode.notAvailable:
          break;
        case errorCode.notEnrolled: //NotEnrolled
          break;
        case errorCode.otherOperatingSystem:
          break;
        case errorCode.permanentlyLockedOut:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          R.current.checkIdentity,
          textAlign: TextAlign.center,
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Material(
              elevation: 2,
              child: TextFormField(
                controller: _originPasswordController,
                cursorColor: Colors.blue[800],
                textInputAction: TextInputAction.done,
                focusNode: _originPasswordFocus,
                onEditingComplete: () {
                  _originPasswordFocus.unfocus();
                },
                obscureText: true,
                validator: (value) => _validatorOriginPassword(value),
                decoration: InputDecoration(
                  hintText: R.current.originPassword,
                  errorStyle: TextStyle(
                    height: 0,
                    fontSize: 0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            if (_originPasswordErrorMessage.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _originPasswordErrorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(R.current.cancel),
          onPressed: () => Get.back<bool>(result: false),
        ),
        TextButton(
          child: Text(R.current.sure),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              Get.back<bool>(result: true);
            }
          },
        )
      ],
    );
  }

  String _validatorOriginPassword(String value) {
    if (value == Model.instance.getPassword()) {
      _originPasswordErrorMessage = '';
    } else {
      setState(() {
        _originPasswordErrorMessage = R.current.passwordNotSame;
      });
    }
    return _originPasswordErrorMessage.isNotEmpty
        ? _originPasswordErrorMessage
        : null;
  }
}
