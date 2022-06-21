// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/controllers/zuvio_course_controller.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/roll_call_bottom_sheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class RollCallDashboardPage extends StatelessWidget {
  const RollCallDashboardPage({super.key});

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
      FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.add),
      );

  void _onAddNewButtonPressed(BuildContext context) {
    ZCourseController.to.loadCourses();
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const RollCallBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _appBar,
        floatingActionButton: _buildAddNewButton(
          context,
          onPressed: () => _onAddNewButtonPressed(context),
        ),
        body: SafeArea(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: const SizedBox.shrink(),
          ),
        ),
      );
}
