import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/task/ntut/ntut_calendar_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/src/util/language_utils.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_detail_dialog.dart';

/*
firstDay是日曆的第一天。用戶將無法在訪問前幾天訪問。
lastDay是日曆的最後可用日期。幾天后用戶將無法訪問。
focusedDay是當前的目標日期。使用此屬性來確定當前應顯示的月份。
 */
final kNow = DateTime.now();
final kFirstDay = DateTime(kNow.year, kNow.month - 3, kNow.day);
final kLastDay = DateTime(kNow.year, kNow.month + 3, kNow.day);

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List _selectedEvents;
  Map<DateTime, List<NTUTCalendarJson>> _events = Map();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;
  DateTime _rangeStart;
  DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = [];
    _addEvent();
  }

  void _addEvent() async {
    var _selectedDay = DateTime.now();
    _selectedDay = _selectedDay.add(Duration(hours: 8)); //to TW time
    print(_selectedDay.toIso8601String());
    await _getEvent(_selectedDay);
  }

  void _selectEvent() {
    for (DateTime time in _events.keys) {
      //顯示當天事件
      int diffDays = _selectedDay.difference(time).inDays;
      bool isSame = (diffDays == 0);
      if (isSame) {
        setState(() {
          _selectedEvents = _events[time];
        });
        break;
      }
    }
  }

  Future<void> _getEvent(DateTime time) async {
    DateTime startTime = DateTime(time.year, time.month, 1);
    DateTime endTime = DateTime(time.year, time.month + 1, 1);
    List<NTUTCalendarJson> eventNTUTs;
    TaskFlow taskFlow = TaskFlow();
    var calendarTask = NTUTCalendarTask(startTime, endTime);
    taskFlow.addTask(calendarTask);
    _events = Map();
    if (await taskFlow.start()) {
      eventNTUTs = calendarTask.result;
      _events = Map();
      for (int i = 0; i < eventNTUTs.length; i++) {
        NTUTCalendarJson eventNTUT = eventNTUTs[i];
        for (var time = DateTime.utc(eventNTUT.startTime.year,
                eventNTUT.startTime.month, eventNTUT.startTime.day);
            time.isBefore(eventNTUT.endTime);
            time = time.add(Duration(days: 1))) {
          if (_events.containsKey(time)) {
            _events[time].add(eventNTUT);
          } else {
            _events[time] = [eventNTUT];
          }
        }
      }
    }
    setState(() {
      _selectedDay = time;
    });
    _selectEvent();
  }

  List<NTUTCalendarJson> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_focusedDay, focusedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        _selectedEvents = _getEventsForDay(focusedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.calendar),
      ),
      body: Column(
        children: [
          TableCalendar<NTUTCalendarJson>(
            locale: (LanguageUtils.getLangIndex() == LangEnum.zh)
                ? "zh_CN"
                : "en_US",
            availableCalendarFormats: {
              CalendarFormat.month: 'Month',
            },
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Color(0xFF4F4F4F),
              ),
              weekendStyle: TextStyle(
                color: Colors.deepOrange,
              ),
            ),
            calendarStyle: CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: Colors.deepOrange,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.brown[700],
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepOrange[300],
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.deepOrange[200],
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
              _getEvent(_focusedDay);
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                    title: Text(event.calTitle),
                    onTap: () {
                      Get.dialog(
                        CalendarDetailDialog(calendarDetail: event),
                        useRootNavigator: false,
                        barrierDismissible: true,
                      );
                    }),
              ))
          .toList(),
    );
  }
}
