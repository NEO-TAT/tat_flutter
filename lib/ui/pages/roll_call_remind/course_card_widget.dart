import 'package:flutter/material.dart';
import 'package:weekday_selector/weekday_selector.dart';

class CourseCard extends StatelessWidget {
  CourseCard({
    super.key,
    required bool isDarkMode,
    required String courseName,
    required String teacherName,
    required String semesterName,
  })  : _isDarkMode = isDarkMode,
        _courseName = courseName,
        _teacherName = teacherName,
        _semesterName = semesterName;

  final bool _isDarkMode;
  final String _courseName;
  final String _teacherName;
  final String _semesterName;
  final _monitoringStartTime = ValueNotifier<TimeOfDay?>(null);
  final _monitoringEndTime = ValueNotifier<TimeOfDay?>(null);
  final _selectedWeekdays = ValueNotifier(List.filled(7, false));

  String _toTimeTextFrom(TimeOfDay? time) {
    String _addLeadingZeroIfNeeded(int value) => value < 10 ? '0$value' : value.toString();
    return time == null ? ' --:-- ' : '${_addLeadingZeroIfNeeded(time.hour)}:${_addLeadingZeroIfNeeded(time.minute)}';
  }

  Widget _buildLeftSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(
              _courseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            child: Row(
              children: [
                const Icon(
                  Icons.account_circle_outlined,
                  color: Colors.white,
                ),
                Text(
                  _teacherName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.schedule,
                  color: Colors.white,
                ),
                Text(
                  _semesterName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildWeekDaySelector(),
        ],
      );

  Widget _buildAddMonitorButton() => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
        ),
        child: Row(
          children: const [
            Icon(
              Icons.add,
              size: 14,
              color: Colors.white,
            ),
            SizedBox(width: 6),
            Text(
              // TODO(TU): replace text with `R.current.xxx`
              "ADD",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _buildTimeSelectionButton({
    required ValueNotifier<TimeOfDay?> monitorTime,
    required VoidCallback onPressed,
    required String defaultText,
  }) =>
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            width: 2,
            color: _isDarkMode ? Colors.white : Colors.black54,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 14,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: ValueListenableBuilder<TimeOfDay?>(
                valueListenable: monitorTime,
                builder: (_, time, __) => Text(
                  time == null ? defaultText : _toTimeTextFrom(time),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildRightSection(BuildContext context) => SizedBox.expand(
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeSelectionButton(
                monitorTime: _monitoringStartTime,
                defaultText: "Begin",
                onPressed: () async {
                  _monitoringStartTime.value = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
              ),
              _buildTimeSelectionButton(
                monitorTime: _monitoringEndTime,
                defaultText: "End",
                onPressed: () async {
                  _monitoringEndTime.value = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
              ),
              _buildAddMonitorButton(),
            ],
          ),
        ),
      );

  Widget _buildWeekDaySelector() => ValueListenableBuilder<List<bool>>(
        valueListenable: _selectedWeekdays,
        builder: (_, selectedWeekdays, __) {
          const border = Border(
            top: BorderSide(width: 6.0, color: Colors.black12),
            left: BorderSide(width: 6.0, color: Colors.black12),
            right: BorderSide(width: 6.0, color: Colors.black26),
            bottom: BorderSide(width: 6.0, color: Colors.black26),
          );
          return WeekdaySelector(
            shape: border,
            selectedShape: border,
            selectedFillColor: Colors.red,
            values: selectedWeekdays,
            onChanged: (day) => _selectedWeekdays.value = List.filled(7, false, growable: false)..[day % 7] = true,
          );
        },
      );

  Widget _buildHorizontalSideContainer({
    required Size size,
    required double ratio,
    required Color color,
    Radius leftRadius = Radius.zero,
    Radius rightRadius = Radius.zero,
    EdgeInsetsGeometry? padding,
    Widget? content,
  }) {
    final borderRadius = BorderRadius.horizontal(
      left: leftRadius,
      right: rightRadius,
    );
    return Material(
      borderRadius: borderRadius,
      elevation: 6,
      color: Colors.transparent,
      child: Container(
        width: size.width * ratio,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: color,
        ),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FittedBox(
      child: SizedBox(
        height: size.height * 0.25,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHorizontalSideContainer(
                size: size,
                ratio: 0.7,
                color: _isDarkMode ? const Color(0xFF205375) : const Color(0xFF2155CD),
                leftRadius: const Radius.circular(15),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                content: _buildLeftSection(),
              ),
              _buildHorizontalSideContainer(
                size: size,
                ratio: 0.3,
                color: _isDarkMode ? const Color(0xFF112B3C) : const Color(0xFFA2E7F7),
                rightRadius: const Radius.circular(15),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                content: _buildRightSection(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
