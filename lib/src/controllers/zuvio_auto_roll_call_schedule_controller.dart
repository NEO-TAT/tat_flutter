// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/controllers/suspend_interactions_transaction_mixin.dart';
import 'package:flutter_app/src/controllers/zuvio_auth_controller.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/other/my_progress_dialog.dart';
import 'package:get/get.dart';
import 'package:tat_core/tat_core.dart';
import 'package:uuid/uuid.dart';

class ZAutoRollCallScheduleController extends GetxController with SuspendInteractionsTransaction {
  ZAutoRollCallScheduleController({
    required ZGetRollCallUseCase getRollCallUseCase,
    required ZMakeRollCallUseCase makeRollCallUseCase,
    required ZGetStudentCourseListUseCase getCourseListUseCase,
    required AddAutoRollCallScheduleUseCase addAutoRollCallScheduleUseCase,
    required GetMyAutoRollCallScheduleUseCase getMyAutoRollCallScheduleUseCase,
    required CancelAutoRollCallScheduleUseCase cancelAutoRollCallScheduleUseCase,
    required EnableAutoRollCallScheduleUseCase enableAutoRollCallScheduleUseCase,
    required DisableAutoRollCallScheduleUseCase disableAutoRollCallScheduleUseCase,
  })  : _getRollCallUseCase = getRollCallUseCase,
        _makeRollCallUseCase = makeRollCallUseCase,
        _getCourseListUseCase = getCourseListUseCase,
        _addAutoRollCallScheduleUseCase = addAutoRollCallScheduleUseCase,
        _getMyAutoRollCallScheduleUseCase = getMyAutoRollCallScheduleUseCase,
        _cancelAutoRollCallScheduleUseCase = cancelAutoRollCallScheduleUseCase,
        _enableAutoRollCallScheduleUseCase = enableAutoRollCallScheduleUseCase,
        _disableAutoRollCallScheduleUseCase = disableAutoRollCallScheduleUseCase;

  static ZAutoRollCallScheduleController get to => Get.find();

  final ZGetRollCallUseCase _getRollCallUseCase;
  final ZMakeRollCallUseCase _makeRollCallUseCase;
  final ZGetStudentCourseListUseCase _getCourseListUseCase;
  final AddAutoRollCallScheduleUseCase _addAutoRollCallScheduleUseCase;
  final GetMyAutoRollCallScheduleUseCase _getMyAutoRollCallScheduleUseCase;
  final CancelAutoRollCallScheduleUseCase _cancelAutoRollCallScheduleUseCase;
  final EnableAutoRollCallScheduleUseCase _enableAutoRollCallScheduleUseCase;
  final DisableAutoRollCallScheduleUseCase _disableAutoRollCallScheduleUseCase;

  final courses = <ZCourse>[];
  final schedules = <AutoRollCallSchedule>[];

  @override
  void resumeUIInteractions() {
    MyProgressDialog.hideProgressDialog();
  }

  @override
  void suspendUIInteractions() {
    MyProgressDialog.progressDialog(R.current.loading);
  }

  ZUserInfo? _getUserInfo() {
    final userInfo = ZAuthController.to.currentZUserInfo();

    if (userInfo == null) {
      ErrorDialog(
        ErrorDialogParameter(
          desc: R.current.pleaseLogin,
          title: R.current.error,
        ),
      ).show();
      Log.e('User may not logged in, could not get user info');
      return null;
    }

    return userInfo;
  }

  String _generateId() => const Uuid().v4();

  Future<void> _enableSchedule(AutoRollCallSchedule schedule) async {
    await _enableAutoRollCallScheduleUseCase(schedule: schedule);
    await getScheduledAutoRollCalls();
  }

  Future<void> _disableSchedule(AutoRollCallSchedule schedule) async {
    await _disableAutoRollCallScheduleUseCase(schedule: schedule);
    await getScheduledAutoRollCalls();
  }

  Future<void> getScheduledAutoRollCalls() async {
    await suspendInteractionsTransaction(transaction: () async {
      schedules.clear();

      final zUserInfo = _getUserInfo();
      if (zUserInfo == null) {
        return;
      }

      final mySchedules = await _getMyAutoRollCallScheduleUseCase(userId: zUserInfo.id);
      schedules.insertAll(0, mySchedules);
    });
  }

  Future<void> loadZCourses() async {
    await suspendInteractionsTransaction(transaction: () async {
      final zUserInfo = _getUserInfo();
      if (zUserInfo == null) {
        return;
      }

      final fetchedCourses = await _getCourseListUseCase(userInfo: zUserInfo);

      if (fetchedCourses != null) {
        courses
          ..clear()
          ..addAll(fetchedCourses.skipWhile((course) => course.isSpecialCourse));
      }
    });
  }

  Future<void> submitNewSchedule({
    required ZCourse course,
    required Week weekday,
    required TimeOfDayPeriod period,
  }) async {
    await suspendInteractionsTransaction(transaction: () async {
      final zUserInfo = _getUserInfo();

      if (zUserInfo == null) {
        return;
      }

      final newScheduleTimeRange = AutoRollCallScheduleTimeRange(
        period: period,
        selectedWeekDay: weekday,
      );

      final schedule = AutoRollCallSchedule(
        id: _generateId(),
        enabled: true,
        targetCourse: course,
        targetUser: zUserInfo,
        timeRange: newScheduleTimeRange,
      );

      await _addAutoRollCallScheduleUseCase(schedule: schedule);

      return getScheduledAutoRollCalls();
    });
  }

  Future<void> updateSchedule({required bool newStatus, required AutoRollCallSchedule schedule}) =>
      suspendInteractionsTransaction(
        transaction: () => (newStatus ? _enableSchedule(schedule) : _disableSchedule(schedule)),
      );

  Future<void> removeSchedule({required String monitorId}) async {
    await suspendInteractionsTransaction(transaction: () async {
      await _cancelAutoRollCallScheduleUseCase(scheduleId: monitorId);
      return getScheduledAutoRollCalls();
    });
  }

  Future<bool> makeRollCall({required ZCourse course}) async => suspendInteractionsTransaction(transaction: () async {
        final zUserInfo = _getUserInfo();
        if (zUserInfo == null) {
          return false;
        }

        final currentRollCall = await _getRollCallUseCase(course: course, userInfo: zUserInfo);
        if (currentRollCall == null) {
          // TODO: show the message which indicates the reason why this roll-call is null.
          return false;
        }

        return _makeRollCallUseCase(
          userInfo: zUserInfo,
          course: course,
          rollCall: currentRollCall,
        );
      });
}
