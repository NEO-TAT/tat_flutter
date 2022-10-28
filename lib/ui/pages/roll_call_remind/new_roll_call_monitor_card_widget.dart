// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/horizontal_side_container.dart';
import 'package:get/get.dart';
import 'package:tat_core/tat_core.dart';
import 'package:weekday_selector/weekday_selector.dart';

/// A type of the function which handles the add roll-call monitor event.
typedef OnAddMonitorPressed = FutureOr<void> Function(Week weekday, TimeOfDayPeriod period);

class NewRollCallMonitorCard extends StatefulWidget {
  const NewRollCallMonitorCard({
    super.key,
    required bool isDarkMode,
    required String courseName,
    required String teacherName,
    required String semesterName,
    required OnAddMonitorPressed onAddMonitorPressed,
  })  : _isDarkMode = isDarkMode,
        _courseName = courseName,
        _teacherName = teacherName,
        _semesterName = semesterName,
        _onAddMonitorPressed = onAddMonitorPressed;

  final bool _isDarkMode;
  final String _courseName;
  final String _teacherName;
  final String _semesterName;
  final OnAddMonitorPressed _onAddMonitorPressed;

  @override
  State<NewRollCallMonitorCard> createState() => _NewRollCallMonitorCardState();
}

class _NewRollCallMonitorCardState extends State<NewRollCallMonitorCard> {
  final _monitoringStartTime = ValueNotifier<TimeOfDay?>(null);
  final _monitoringEndTime = ValueNotifier<TimeOfDay?>(null);
  final _selectedWeekdays = ValueNotifier(List.filled(7, false));

  String _toTimeTextFrom(TimeOfDay? time) {
    String addLeadingZeroIfNeeded(int value) => value < 10 ? '0$value' : value.toString();
    return time == null ? ' --:-- ' : '${addLeadingZeroIfNeeded(time.hour)}:${addLeadingZeroIfNeeded(time.minute)}';
  }

  bool _verifyCardInfo() {
    final hasStartTime = _monitoringStartTime.value != null;
    if (!hasStartTime) {
      ErrorDialog(ErrorDialogParameter(
        dialogType: DialogType.WARNING,
        title: R.current.missingRequiredInformation,
        desc: R.current.pleaseSelectStartTime,
        btnOkText: R.current.sure,
        offCancelBtn: true,
      )).show();
      return false;
    }

    final hasEndTime = _monitoringEndTime.value != null;
    if (!hasEndTime) {
      ErrorDialog(ErrorDialogParameter(
        dialogType: DialogType.WARNING,
        title: R.current.missingRequiredInformation,
        desc: R.current.pleaseSelectEndTime,
        btnOkText: R.current.sure,
        offCancelBtn: true,
      )).show();
      return false;
    }

    final hasWeekDay = _selectedWeekdays.value.any((selection) => selection);
    if (!hasWeekDay) {
      ErrorDialog(ErrorDialogParameter(
        dialogType: DialogType.WARNING,
        title: R.current.missingRequiredInformation,
        desc: R.current.pleaseSelectWeekday,
        btnOkText: R.current.sure,
        offCancelBtn: true,
      )).show();
      return false;
    }

    int timeInMinuteOf(TimeOfDay? time) => time == null ? 0 : time.hour * 60 + time.minute;

    if (timeInMinuteOf(_monitoringStartTime.value) > timeInMinuteOf(_monitoringEndTime.value)) {
      ErrorDialog(ErrorDialogParameter(
        dialogType: DialogType.WARNING,
        title: R.current.incorrectInformationEntered,
        desc: R.current.endTimeMustBeAfterStartTime,
        btnOkText: R.current.sure,
        offCancelBtn: true,
      )).show();
      return false;
    }

    return true;
  }

  void _onAddMonitorButtonPressed() async {
    final isCardValid = _verifyCardInfo();
    if (!isCardValid) {
      return;
    }

    final weekday = Week.values[_selectedWeekdays.value.indexOf(true)];
    final startTime = _monitoringStartTime.value ?? TimeOfDay.now();
    final endTime = _monitoringEndTime.value ?? TimeOfDay.now();

    await widget._onAddMonitorPressed(weekday, TimeOfDayPeriod(startTime, endTime));
    Get.back();
  }

  Widget _buildLeftSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(
              widget._courseName,
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
                  widget._teacherName,
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
                  widget._semesterName,
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
        onPressed: _onAddMonitorButtonPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add,
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              R.current.capitalAdd,
              style: const TextStyle(
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
            color: widget._isDarkMode ? Colors.white : Colors.black54,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 14,
              color: widget._isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: ValueListenableBuilder<TimeOfDay?>(
                valueListenable: monitorTime,
                builder: (_, time, __) => AutoSizeText(
                  time == null ? defaultText : _toTimeTextFrom(time),
                  textAlign: TextAlign.center,
                  minFontSize: 6,
                  wrapWords: false,
                  style: TextStyle(
                    color: widget._isDarkMode
                        ? (time == null ? Colors.white : Colors.yellowAccent)
                        : (time == null ? Colors.black : Colors.purple),
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
                defaultText: R.current.begin,
                onPressed: () async {
                  _monitoringStartTime.value = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
              ),
              _buildTimeSelectionButton(
                monitorTime: _monitoringEndTime,
                defaultText: R.current.end,
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
              HorizontalSideContainer(
                size: size,
                ratio: 0.7,
                color: widget._isDarkMode ? const Color(0xFF205375) : const Color(0xFF2155CD),
                leftRadius: const Radius.circular(15),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                content: _buildLeftSection(),
              ),
              HorizontalSideContainer(
                size: size,
                ratio: 0.3,
                color: widget._isDarkMode ? const Color(0xFF112B3C) : const Color(0xFFA2E7F7),
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
