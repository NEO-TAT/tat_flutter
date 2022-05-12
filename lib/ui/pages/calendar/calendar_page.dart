import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/ntut/ntut_calendar_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:flutter_app/ui/pages/calendar/calendar_detail_dialog.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

// Example holidays
final Map<DateTime, List> _holidays = {
  /*
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
  */
};

class _CalendarPageState extends State<CalendarPage> with TickerProviderStateMixin {
  Map<DateTime, List> _events = {};
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _selectedEvents = [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
    _addEvent();
  }

  void _addEvent() async {
    var selectedDay = DateTime.now();
    selectedDay = selectedDay.add(const Duration(hours: 8)); //to TW time
    await _getEvent(selectedDay);
    for (DateTime time in _events.keys) {
      //顯示當天事件
      int diffDays = selectedDay.difference(time).inDays;
      bool isSame = (diffDays == 0);
      if (isSame) {
        _onDaySelected(selectedDay, _events[time], null);
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
    _events = {};
    if (await taskFlow.start()) {
      eventNTUTs = calendarTask.result;
      _events = {};
      for (int i = 0; i < eventNTUTs.length; i++) {
        NTUTCalendarJson eventNTUT = eventNTUTs[i];
        if (_events.containsKey(eventNTUT.startTime)) {
          _events[eventNTUT.startTime].add(eventNTUT);
        } else {
          _events[eventNTUT.startTime] = [eventNTUT];
        }
      }
    }
    setState(() {
      _selectedEvents = [];
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) async {
    await _getEvent(first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(R.current.calendar),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          // _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          //_buildButtons(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      locale: (LanguageUtil.getLangIndex() == LangEnum.zh) ? "zh_CN" : "en_US",
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: const TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map(
            (event) => Container(
              decoration: BoxDecoration(
                border: Border.all(width: 0.8),
                borderRadius: BorderRadius.circular(12.0),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(event.calTitle),
                onTap: () {
                  Get.dialog(
                    CalendarDetailDialog(calendarDetail: event),
                    barrierDismissible: true,
                  );
                },
              ),
            ),
          )
          .toList(),
    );
  }
}
