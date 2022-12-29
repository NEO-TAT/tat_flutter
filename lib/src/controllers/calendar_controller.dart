// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:collection';

import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/task/ntut/ntut_calendar_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarController extends GetxController {
  static CalendarController get to => Get.find();

  final Map<DateTime, List<NTUTCalendarJson>> knownHolidays = {
    // TODO: Define the source of holidays in a correct way.
    // FIXME: The type of holiday should not be `NTUTCalendarJson`.
  };

  final knownSchoolEvents = LinkedHashMap<DateTime, List<NTUTCalendarJson>>(equals: isSameDay);

  final selectedEvents = <NTUTCalendarJson>[].obs;
  final calendarFormat = CalendarFormat.month.obs;
  final focusDay = DateTime.now().toLocal().obs;
  final selectedDay = DateTime.now().toLocal().obs;

  final firstDay = DateTime(1990);
  final lastDay = DateTime(2099);

  final _storedMonthSet = <DateTime>{};

  String get currentCalendarLocaleString => (LanguageUtil.getLangIndex() == LangEnum.zh) ? "zh_CN" : "en_US";

  List<NTUTCalendarJson> getEventsFromDay(DateTime day) => knownSchoolEvents[day] ?? const [];

  bool isHoliday(DateTime day) => knownHolidays.containsKey(day);

  bool isSelectingSelectedDay(DateTime day) => isSameDay(selectedDay.value, day);

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(this.selectedDay.value, selectedDay)) {
      this.selectedDay.value = selectedDay;
      focusDay.value = focusedDay;
      selectedEvents.value = getEventsFromDay(selectedDay);
      update();
    }
  }

  Future<void> onPageChanged(DateTime focusedDay) async {
    focusDay.value = focusedDay;
    await _getMonthlyEvents(startTime: focusedDay);

    // change the selected day to the first day of current month.
    selectedDay.value = DateTime(focusedDay.year, focusedDay.month, 1).toUTCLocal();

    // change the selected events to the first day of current month.
    selectedEvents.value = getEventsFromDay(selectedDay.value);

    update();
  }

  void onFormatChanged(CalendarFormat format) {
    calendarFormat.value = format;
    update();
  }

  Future<void> findFirstEventsFromToday() async {
    final now = DateTime.now();

    // Only preserve the day part of the date.
    final today = DateTime(now.year, now.month, now.day).toUTCLocal();

    await _getMonthlyEvents(startTime: today);
    selectedEvents.value = getEventsFromDay(today);
  }

  /// Get the events of the month of the given [startTime].
  /// If the [startTime] is not the first day of the month, the [startTime] will be set to the first day of the month.
  Future<void> _getMonthlyEvents({required DateTime startTime}) async {
    // Since the backend api only supports monthly query, we need to query the whole month.
    const fixedEventRequestDay = 1;

    final firstDayOfTargetMonth = DateTime(startTime.year, startTime.month, fixedEventRequestDay);
    if (_storedMonthSet.contains(firstDayOfTargetMonth)) {
      return;
    }

    // Use `zero` to represent the last day of the month.
    const fixedEventRequestLastDayOfAnyMonth = 0;

    final lastDayOfTargetMonth = DateTime(startTime.year, startTime.month + 1, fixedEventRequestLastDayOfAnyMonth);

    final taskFlow = TaskFlow();
    final calendarTask = NTUTCalendarTask(firstDayOfTargetMonth, lastDayOfTargetMonth);
    taskFlow.addTask(calendarTask);

    if (await taskFlow.start()) {
      final schoolEvents = calendarTask.result;
      if (schoolEvents == null) {
        return;
      }

      for (final nonAddedSchoolEvent in schoolEvents) {
        final eventTime = nonAddedSchoolEvent.startTime.toLocal();
        knownSchoolEvents.update(
          eventTime,
          (addedEvents) => [...addedEvents, nonAddedSchoolEvent],
          ifAbsent: () => [nonAddedSchoolEvent],
        );
      }

      _storedMonthSet.add(firstDayOfTargetMonth);
    }
  }
}

extension on DateTime {
  static const taipeiTimeZoneHours = 8;

  /// Convert the [DateTime] to the [DateTime] in the Asia/Taipei time zone.
  /// You may not use `toLocal()` here, since the `toString()` method of `DateTime` will generate different results with the UTC time's.
  ///
  /// In specific terms, UTC time is represented by a 'Z' character that is appended to the string representation of the time.
  /// For example, if the current time in UTC is 3:00 PM, it might be represented as "15:00Z".
  ///
  /// It is important to note that the keys for the `knownSchoolEvents` map use UTC time.
  /// If a non-UTC time is used in the map query, it may not be able to find the corresponding value.
  DateTime toUTCLocal() => toUtc().add(const Duration(hours: taipeiTimeZoneHours));
}
