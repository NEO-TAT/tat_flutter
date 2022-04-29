// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';

class RollCallDashboardPage extends StatelessWidget {
  const RollCallDashboardPage({
    Key? key,
    required void Function() onAddNewPressed,
  })  : _onAddNewButtonPressed = onAddNewPressed,
        super(key: key);

  final void Function() _onAddNewButtonPressed;
  final _addNewButtonSize = 144.0;

  PreferredSizeWidget get _appBar => AppBar(
        title: Row(
          children: [
            Icon(Icons.access_alarm),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              child: Text(R.current.rollCallRemind),
            ),
          ],
        ),
      );

  Widget get _addNewButton => IconButton(
        onPressed: _onAddNewButtonPressed,
        iconSize: _addNewButtonSize,
        icon: Center(
          child: Icon(
            Icons.add_outlined,
            size: _addNewButtonSize,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _appBar,
        body: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: _addNewButton,
          ),
        ),
      );
}
