// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:flutter_app/src/controllers/calendar_controller.dart';
import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/pages/calendar/calendar_detail_dialog.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  Widget _buildEventList(BuildContext context, List<NTUTCalendarJson> selectedEvents) {
    final eventBorderColor = Theme.of(context).colorScheme.onBackground;
    return ListView.builder(
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: ListTile(
              title: Text(event.calTitle),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: eventBorderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => Get.dialog(
                CalendarDetailDialog(calendarDetail: event),
                barrierDismissible: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableCalendar(CalendarController controller) => TableCalendar(
        focusedDay: controller.focusDayRx.value,
        firstDay: controller.firstDay,
        lastDay: controller.lastDay,
        locale: controller.currentCalendarLocaleString,
        calendarFormat: controller.calendarFormatRx.value,
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
        calendarStyle: const CalendarStyle(
          isTodayHighlighted: true,
          selectedDecoration: BoxDecoration(
            color: Colors.lightBlueAccent,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(color: Colors.white),
          todayDecoration: BoxDecoration(
            color: Colors.deepOrange,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: Colors.white),
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle(color: Colors.red),
          markerDecoration: BoxDecoration(
            color: Colors.teal,
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(height: 1),
          weekendStyle: TextStyle(height: 1, color: Colors.red),
        ),
      );

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: CalendarController.to.findFirstEventsFromToday(),
        builder: (context, __) => Scaffold(
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
                  child: _buildEventList(context, controller.selectedEventsRx),
                ),
              ],
            ),
          ),
        ),
      );
}
