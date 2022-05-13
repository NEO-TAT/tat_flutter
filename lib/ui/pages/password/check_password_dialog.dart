// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class CheckPasswordDialog extends StatefulWidget {
  const CheckPasswordDialog({Key key}) : super(key: key);

  @override
  State<CheckPasswordDialog> createState() => _CheckPasswordDialogState();
}

class _CheckPasswordDialogState extends State<CheckPasswordDialog> {
  final TextEditingController _originPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _originPasswordFocus = FocusNode();
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
        localizedReason: R.current.checkIdentity,
        options: const AuthenticationOptions(
          useErrorDialogs: false,
          biometricOnly: true,
        ),
      );
      if (didAuthenticate) {
        Get.back<bool>(result: true);
      }
    } on PlatformException catch (e) {
      Log.d(e.code);
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
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
                  errorStyle: const TextStyle(
                    height: 0,
                    fontSize: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            if (_originPasswordErrorMessage.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _originPasswordErrorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(
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
            })
      ],
    );
  }

  String _validatorOriginPassword(String value) {
    if (value == LocalStorage.instance.getPassword()) {
      _originPasswordErrorMessage = '';
    } else {
      setState(() {
        _originPasswordErrorMessage = R.current.passwordNotSame;
      });
    }
    return _originPasswordErrorMessage.isNotEmpty ? _originPasswordErrorMessage : null;
  }
}