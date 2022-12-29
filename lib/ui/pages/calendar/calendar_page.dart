// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/controllers/calendar_controller.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/pages/calendar/calendar_detail_dialog.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  Widget _buildEventList(CalendarController controller) => ListView(
        children: controller.selectedEvents
            .map(
              (event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.calTitle),
                  onTap: () => Get.dialog(
                    CalendarDetailDialog(calendarDetail: event),
                    barrierDismissible: true,
                  ),
                ),
              ),
            )
            .toList(),
      );

  Widget _buildTableCalendar(CalendarController controller) => TableCalendar(
        focusedDay: controller.focusDay.value,
        firstDay: controller.firstDay,
        lastDay: controller.lastDay,
        locale: controller.currentCalendarLocaleString,
        calendarFormat: controller.calendarFormat.value,
        eventLoader: controller.getEventsFromDay,
        holidayPredicate: controller.isHoliday,
        selectedDayPredicate: controller.isSelectingSelectedDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onFormatChanged: controller.onFormatChanged,
        onDaySelected: controller.onDaySelected,
        onPageChanged: controller.onPageChanged,
        headerStyle: HeaderStyle(
          formatButtonTextStyle: const TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
          formatButtonDecoration: BoxDecoration(
            color: Colors.deepOrange[400],
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: CalendarController.to.findFirstEventsFromToday(),
        builder: (_, __) => Scaffold(
          appBar: AppBar(
            title: Text(R.current.calendar),
          ),
          body: GetBuilder<CalendarController>(
            builder: (controller) => Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildTableCalendar(controller),
                const SizedBox(height: 16.0),
                Expanded(
                  child: _buildEventList(controller),
                ),
              ],
            ),
          ),
        ),
      );
}
