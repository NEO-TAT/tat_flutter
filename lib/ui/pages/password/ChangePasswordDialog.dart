import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/TaskFlow.dart';
import 'package:flutter_app/src/task/ntut/NTUTChangePasswordTask.dart';
import 'package:get/get.dart';

class ChangePasswordDialog extends StatefulWidget {
  ChangePasswordDialog({Key key}) : super(key: key);

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocus = new FocusNode();
  bool passwordShow = false;
  String _passwordErrorMessage = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          R.current.setNewPassword,
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
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      cursorColor: Colors.blue[800],
                      textInputAction: TextInputAction.done,
                      focusNode: _passwordFocus,
                      onEditingComplete: () {
                        _passwordFocus.unfocus();
                      },
                      obscureText: !passwordShow,
                      validator: (value) => _validatorSamePassword(value),
                      decoration: InputDecoration(
                        hintText: R.current.inputNewPassword,
                        errorStyle: TextStyle(
                          height: 0,
                          fontSize: 0,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: (passwordShow)
                        ? Icon(EvaIcons.eyeOutline)
                        : Icon(EvaIcons.eyeOffOutline),
                    onPressed: () {
                      setState(() {
                        passwordShow = !passwordShow;
                      });
                    },
                  )
                ],
              ),
            ),
            SizedBox(
              height: 4,
            ),
            SizedBox(
              height: 4,
            ),
            if (_passwordErrorMessage.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _passwordErrorMessage,
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
          child: Text(R.current.useOldPassword),
          onPressed: () async {
            String password = Model.instance.getPassword();
            TaskFlow taskFlow = TaskFlow();
            taskFlow.addTask(
                NTUTChangePasswordTask(password.split('').reversed.join()));
            taskFlow.addTask(NTUTChangePasswordTask(password));
            bool success = await taskFlow.start();
            if (success) {
              Get.back<bool>(result: true);
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text(R.current.cancel),
              onPressed: () => Get.back<bool>(result: false),
            ),
            TextButton(
              child: Text(R.current.sure),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  TaskFlow taskFlow = TaskFlow();
                  taskFlow.addTask(
                      NTUTChangePasswordTask(_passwordController.text));
                  bool success = await taskFlow.start();
                  if (success) {
                    Get.back<bool>(result: true);
                  }
                }
              },
            )
          ],
        ),
      ],
    );
  }

  String _validatorSamePassword(String value) {
    _passwordErrorMessage = "";
    if (_passwordController.text.isEmpty) {
      _passwordErrorMessage = R.current.inputNull;
    } else if (_passwordController.text.length < 8 ||
        _passwordController.text.length > 14) {
      _passwordErrorMessage = R.current.passwordLengthError;
    } else if (_passwordController.text == Model.instance.getPassword()) {
      _passwordErrorMessage = R.current.sameOldPassword;
    }
    setState(() {});
    return _passwordErrorMessage.isNotEmpty ? _passwordErrorMessage : null;
  }
}
