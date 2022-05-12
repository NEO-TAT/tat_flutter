// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.17
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/controllers/zuvio_course_controller.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/roll_call_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RollCallDashboardPage extends StatelessWidget {
  const RollCallDashboardPage({
    Key? key,
  }) : super(key: key);

  final _addNewButtonSize = 144.0;

  void _onAddNewButtonPressed(BuildContext context) {
    ZCourseController.to.loadCourses();
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const RollCallBottomSheet(),
    );
  }

  PreferredSizeWidget get _appBar => AppBar(
        title: Row(
          children: [
            const Icon(Icons.access_alarm),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              child: Text(R.current.rollCallRemind),
            ),
          ],
        ),
      );

  Widget _buildAddNewButton(
    BuildContext context, {
    VoidCallback? onPressed,
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
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: Align(
              alignment: Alignment.center,
              child: _buildAddNewButton(
                context,
                onPressed: () => _onAddNewButtonPressed(context),
              ),
            ),
          ),
        ),
      );
}
