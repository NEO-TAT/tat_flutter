// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RollCallDashboardPage extends StatelessWidget {
  const RollCallDashboardPage({
    Key? key,
  }) : super(key: key);

  final _addNewButtonSize = 144.0;

  void _onAddNewButtonPressed(BuildContext context) => showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => _buildRollCallServiceSheet(context),
      );

  Widget _buildCloseSheetButton(BuildContext context) => GestureDetector(
        onTap: () => Get.back(),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              size: 24,
              color: Get.isDarkMode ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
            ),
          ),
        ),
      );

  BoxDecoration get _sheetDecoration => BoxDecoration();

  Widget _buildRollCallServiceSheet(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Container(
          decoration: _sheetDecoration,
          child: _buildCloseSheetButton(context),
        ),
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

  Widget _buildAddNewButton(BuildContext context) => IconButton(
        onPressed: () => _onAddNewButtonPressed(context),
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
            child: _buildAddNewButton(context),
          ),
        ),
      );
}
