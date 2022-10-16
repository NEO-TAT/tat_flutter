// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/controllers/zuvio_auto_roll_call_schedule_controller.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/roll_call_bottom_sheet.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/scheduled_roll_call_monitor_card_widget.dart';
import 'package:get/get.dart';
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
    ZAutoRollCallScheduleController.to.loadZCourses();
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const RollCallBottomSheet(),
    );
  }

  Widget get _scheduledMonitorList => GetBuilder<ZAutoRollCallScheduleController>(
        builder: (controller) => ListView.builder(
          itemCount: controller.schedules.length,
          itemBuilder: (_, index) {
            final schedule = controller.schedules[index];
            return ScheduledRollCallMonitorCard(
              period: schedule.timeRange.period,
              courseName: schedule.targetCourse.name,
              selectedWeekDay: schedule.timeRange.selectedWeekDay,
              isMonitorEnabled: schedule.enabled,
              onRemoveMonitorPressed: () => controller.removeSchedule(monitorId: schedule.id),
              onRollCallPressed: () => controller.makeRollCall(course: schedule.targetCourse),
              onActivationStatusSwitchPressed: (enabled) => controller.updateSchedule(
                newStatus: enabled,
                schedule: schedule,
              ),
            );
          },
        ),
      );

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _scheduledMonitorList,
            ),
          ),
        ),
      );
}
