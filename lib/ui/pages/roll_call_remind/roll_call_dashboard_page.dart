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

  Widget get _scheduledMonitorList {
    return GetBuilder<ZRollCallMonitorController>(
      builder: (controller) => ListView.builder(
        itemCount: controller.schedules.length,
        itemBuilder: (_, index) {
          final schedule = controller.schedules[index];

          // TODO: FIXME: refactor with the correct domain model inside TAT-Core, instead of using Map structure.
          final isEnabled = schedule['enabled'] as bool;
          final startHour = schedule['schedule']['start-time']['hour'] as int;
          final startMinute = schedule['schedule']['start-time']['minute'] as int;
          final endHour = schedule['schedule']['end-time']['hour'] as int;
          final endMinute = schedule['schedule']['end-time']['minute'] as int;

          final courseRawData = schedule['z-course'] as Map<String, dynamic>;
          final zCourse = ZCourse.fromJson(courseRawData);

          final weekDay = schedule['schedule']['weekday'] as int;

          final id = schedule['id'] as String;

          return ScheduledRollCallMonitorCard(
            period: TimeOfDayPeriod(
              TimeOfDay(hour: startHour, minute: startMinute),
              TimeOfDay(hour: endHour, minute: endMinute),
            ),
            courseName: zCourse.name,
            selectedWeekDay: Week.values[weekDay],
            isMonitorEnabled: isEnabled,
            onRemoveMonitorPressed: () => controller.removeMonitor(monitorId: id),
            onRollCallPressed: () => controller.makeRollCall(course: zCourse),
          );
        },
      ),
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
