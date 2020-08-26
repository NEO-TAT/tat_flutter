import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/ntut/NTUTChangePasswordTask.dart';

class ChangePasswordDialog extends StatefulWidget {
  ChangePasswordDialog({Key key}) : super(key: key);

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _onePasswordController = TextEditingController();
  final TextEditingController _twoPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _onePasswordFocus = new FocusNode();
  final FocusNode _twoPasswordFocus = new FocusNode();
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
              child: TextFormField(
                controller: _onePasswordController,
                cursorColor: Colors.blue[800],
                textInputAction: TextInputAction.done,
                focusNode: _onePasswordFocus,
                onEditingComplete: () {
                  _onePasswordFocus.unfocus();
                  FocusScope.of(context).requestFocus(_twoPasswordFocus);
                },
                obscureText: true,
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
            SizedBox(
              height: 4,
            ),
            Material(
              elevation: 2,
              child: TextFormField(
                controller: _twoPasswordController,
                cursorColor: Colors.blue[800],
                textInputAction: TextInputAction.done,
                focusNode: _twoPasswordFocus,
                onEditingComplete: () {
                  _twoPasswordFocus.unfocus();
                },
                obscureText: true,
                validator: (value) => _validatorSamePassword(value),
                decoration: InputDecoration(
                  hintText: R.current.inputNewPasswordAgain,
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
            if (_passwordErrorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Text(
                  _passwordErrorMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: Text(R.current.cancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        FlatButton(
            child: Text(R.current.sure),
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                TaskHandler.instance.addTask(NTUTChangePasswordTask(
                    context, _onePasswordController.text));
                await TaskHandler.instance.startTaskQueue(context);
                Navigator.of(context).pop(true);
              }
            })
      ],
    );
  }

  String _validatorSamePassword(String value) {
    _passwordErrorMessage = "";
    if (_onePasswordController.text.isEmpty ||
        _twoPasswordController.text.isEmpty) {
      _passwordErrorMessage = R.current.inputNull;
    } else if (_onePasswordController.text != _twoPasswordController.text) {
      _passwordErrorMessage = R.current.inputNotSame;
    } else if (_onePasswordController.text.length <= 4) {
      _passwordErrorMessage = R.current.passwordLengthShort;
    } else if (_onePasswordController.text == Model.instance.getPassword()) {
      _passwordErrorMessage = R.current.sameOldPassword;
    }
    setState(() {});
    return _passwordErrorMessage.isNotEmpty ? _passwordErrorMessage : null;
  }
}
