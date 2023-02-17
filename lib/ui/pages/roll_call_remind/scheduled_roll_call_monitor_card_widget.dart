// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/msg_dialog.dart';
import 'package:flutter_app/ui/pages/roll_call_remind/horizontal_side_container.dart';
import 'package:get/get.dart';
import 'package:tat_core/tat_core.dart';
import 'package:weekday_selector/weekday_selector.dart';

typedef OnRemoveMonitorPressed = FutureOr<void> Function();
typedef OnRollCallPressed = FutureOr<bool> Function();
typedef OnActivationStatusSwitchPressed = FutureOr<void> Function(bool);

class ScheduledRollCallMonitorCard extends StatelessWidget {
  // TODO(TU): the real _isDarkMode
  const ScheduledRollCallMonitorCard({
    super.key,
    required TimeOfDayPeriod period,
    required String courseName,
    required Week selectedWeekDay,
    required bool isMonitorEnabled,
    required OnRemoveMonitorPressed onRemoveMonitorPressed,
    required OnRollCallPressed onRollCallPressed,
    required OnActivationStatusSwitchPressed onActivationStatusSwitchPressed,
  })  : _period = period,
        _courseName = courseName,
        _selectedWeekDay = selectedWeekDay,
        _isMonitorEnabled = isMonitorEnabled,
        _onRemoveMonitorPressed = onRemoveMonitorPressed,
        _onRollCallPressed = onRollCallPressed,
        _onActivationStatusSwitchPressed = onActivationStatusSwitchPressed;

  final bool _isMonitorEnabled;
  final Week _selectedWeekDay;
  final TimeOfDayPeriod _period;
  final String _courseName;
  final OnRemoveMonitorPressed _onRemoveMonitorPressed;
  final OnRollCallPressed _onRollCallPressed;
  final OnActivationStatusSwitchPressed _onActivationStatusSwitchPressed;

  String _toTimeTextFrom(TimeOfDay? time) {
    String addLeadingZeroIfNeeded(int value) => value < 10 ? '0$value' : value.toString();
    return time == null ? ' --:-- ' : '${addLeadingZeroIfNeeded(time.hour)}:${addLeadingZeroIfNeeded(time.minute)}';
  }

  Widget _buildLeftSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(
              '${_toTimeTextFrom(_period.startTime)} ~ ${_toTimeTextFrom(_period.endTime)}',
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
                  Icons.account_balance,
                  color: Colors.white,
                ),
                Text(
                  _courseName,
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

  Widget _buildWeekDaySelector() {
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
      values: List.generate(7, (index) => index == _selectedWeekDay.index, growable: false),
      onChanged: (_) {},
    );
  }

  Widget _buildRightSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(_isMonitorEnabled ? 'ON' : 'Off'),
              Switch(
                value: _isMonitorEnabled,
                onChanged: _onActivationStatusSwitchPressed,
              ),
            ],
          ),
          _buildRollCallButton(),
          _buildRemoveMonitorButton(),
        ],
      );

  Widget _buildRemoveMonitorButton() => ElevatedButton(
        onPressed: () {
          MsgDialog(MsgDialogParameter(
            dialogType: DialogType.question,
            title: '',
            desc: 'Do you really want to remove this scheduled roll-call remind?',
            okButtonText: R.current.sure,
            onOkButtonClicked: () => _onRemoveMonitorPressed.call(),
          )).show();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
        ),
        child: FittedBox(
          child: Row(
            children: const [
              Icon(
                Icons.cancel_outlined,
                size: 14,
                color: Colors.white,
              ),
              SizedBox(width: 6),
              Text(
                // TODO(TU): replace text with `R.current.xxx`
                'Remove',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildRollCallButton() => ElevatedButton(
        onPressed: () async {
          final isSuccess = await _onRollCallPressed();
          if (isSuccess) {
            MsgDialog(MsgDialogParameter(
              dialogType: DialogType.success,
              title: 'RollCall Success',
              desc: 'You have roll-called to $_courseName.',
              okButtonText: R.current.sure,
              removeCancelButton: true,
            )).show();
          } else {
            MsgDialog(MsgDialogParameter(
              dialogType: DialogType.error,
              title: 'RollCall Failed',
              desc: 'Failed to roll-called to $_courseName, please try again.',
              okButtonText: R.current.sure,
              removeCancelButton: true,
            )).show();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
        child: FittedBox(
          child: Row(
            children: const [
              Icon(
                Icons.games,
                size: 14,
                color: Colors.black,
              ),
              SizedBox(width: 6),
              Text(
                // TODO(TU): replace text with `R.current.xxx`
                'RollCall',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Get.isDarkMode;
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
                color: _isMonitorEnabled
                    ? (isDarkMode ? const Color(0xFFFF9F29) : const Color(0xFF1A4D2E))
                    : const Color(0xFFAAAAAA),
                leftRadius: const Radius.circular(15),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                content: _buildLeftSection(),
              ),
              HorizontalSideContainer(
                size: size,
                ratio: 0.3,
                color: isDarkMode ? const Color(0xFF1A4D2E) : const Color(0xFFA2E7F7),
                rightRadius: const Radius.circular(15),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                content: _buildRightSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
