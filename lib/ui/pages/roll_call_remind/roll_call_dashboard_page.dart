// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/roll_call_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

/// A function returns `void` and with no any parameters.
typedef VoidFunc = void Function();

class RollCallDashboardPage extends StatelessWidget {
  const RollCallDashboardPage({
    Key? key,
  }) : super(key: key);

  final _addNewButtonSize = 144.0;

  void _onAddNewButtonPressed(BuildContext context) => showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => RollCallBottomSheet(),
      );

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

  Widget _buildAddNewButton(
    BuildContext context, {
    VoidFunc? onPressed,
  }) =>
      IconButton(
        onPressed: onPressed,
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
            child: _buildAddNewButton(
              context,
              onPressed: () => _onAddNewButtonPressed(context),
            ),
          ),
        ),
      );
}
